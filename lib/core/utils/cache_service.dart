// lib/core/utils/cache_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'result.dart';

/// Servicio de caché local usando Hive
class CacheService {
  // Singleton pattern
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  static const String _cacheBoxName = 'app_cache';
  static const String _metadataKey = 'cache_metadata';
  static const String _statsKey = 'cache_stats';

  Box? _cacheBox;
  bool _isInitialized = false;

  /// Metadatos de la caché
  final Map<String, CacheMetadata> _metadata = {};

  /// Estadísticas de la caché
  CacheStats _stats = CacheStats(lastCleaned: DateTime.now());

  /// Inicializar servicio de caché
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Inicializar Hive
      final appDir = await getApplicationDocumentsDirectory();
      Hive.init(appDir.path);

      // Abrir o crear la caja de caché
      _cacheBox = await Hive.openBox(_cacheBoxName);

      // Cargar metadatos
      await _loadMetadata();

      // Cargar estadísticas
      await _loadStats();

      _isInitialized = true;
    } catch (error) {
      throw CacheException(message: 'Error al inicializar caché', cause: error);
    }
  }

  /// Asegurar que el servicio esté inicializado
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// Guardar datos en caché
  Future<Result<void, Exception>> save({
    required String key,
    required dynamic data,
    String category = 'general',
    Map<String, dynamic> tags = const {},
    Duration ttl = const Duration(hours: 1),
  }) async {
    try {
      await _ensureInitialized();

      // Serializar datos
      final serializedData = json.encode(data);
      final dataSize = serializedData.length;

      // Crear metadatos
      final metadata = CacheMetadata(
        key: key,
        category: category,
        tags: tags,
        ttl: ttl,
        createdAt: DateTime.now(),
        size: dataSize,
        accessCount: 0,
        lastAccessed: DateTime.now(),
      );

      // Guardar datos y metadatos
      await _cacheBox!.put(key, serializedData);
      _metadata[key] = metadata;
      await _saveMetadata();

      // Actualizar estadísticas
      _stats = _stats.copyWith(
        totalItems: _stats.totalItems + 1,
        totalSize: _stats.totalSize + dataSize,
      );
      await _saveStats();

      return Result.success(null);
    } catch (error) {
      return Result.error(
        CacheException(message: 'Error al guardar en caché', cause: error),
      );
    }
  }

  /// Obtener datos de caché
  Future<Result<T?, Exception>> get<T>(String key) async {
    try {
      await _ensureInitialized();

      // Verificar si existe en metadatos
      final metadata = _metadata[key];
      if (metadata == null) {
        _stats = _stats.copyWith(misses: _stats.misses + 1);
        await _saveStats();
        return Result.success(null);
      }

      // Verificar si ha expirado
      if (metadata.isExpired) {
        await _remove(key);
        _stats = _stats.copyWith(misses: _stats.misses + 1);
        await _saveStats();
        return Result.success(null);
      }

      // Obtener datos
      final data = _cacheBox!.get(key);
      if (data == null) {
        _stats = _stats.copyWith(misses: _stats.misses + 1);
        await _saveStats();
        return Result.success(null);
      }

      // Actualizar metadatos
      final updatedMetadata = metadata.copyWith(
        accessCount: metadata.accessCount + 1,
        lastAccessed: DateTime.now(),
      );
      _metadata[key] = updatedMetadata;
      await _saveMetadata();

      // Actualizar estadísticas
      _stats = _stats.copyWith(hits: _stats.hits + 1);
      await _saveStats();

      // Deserializar datos
      final decodedData = json.decode(data as String);

      // Convertir tipos dinámicos al tipo esperado
      // Usar verificación de tipos en tiempo de ejecución
      if (decodedData is Map) {
        // Si esperamos Map<String, dynamic>
        if (T.toString().contains('Map<String, dynamic>')) {
          final convertedData = _convertDynamicMapToStringMap(decodedData);
          return Result.success(convertedData as T);
        }
        // Para otros tipos de Map, intentar conversión
        try {
          return Result.success(decodedData as T);
        } catch (e) {
          // Si falla, devolver null
          return Result.success(null);
        }
      } else if (decodedData is List) {
        // Si esperamos List<Map<String, dynamic>>
        if (T.toString().contains('List<Map<String, dynamic>>')) {
          final convertedData = _convertDynamicListToMapList(decodedData);
          return Result.success(convertedData as T);
        }
        // Si esperamos List<String>
        if (T.toString().contains('List<String>')) {
          final stringList = decodedData.map((e) => e.toString()).toList();
          return Result.success(stringList as T);
        }
        // Para otros tipos de List, intentar conversión
        try {
          return Result.success(decodedData as T);
        } catch (e) {
          // Si falla, devolver null
          return Result.success(null);
        }
      } else {
        // Para tipos simples, hacer conversión adecuada
        if (T.toString().contains('String')) {
          return Result.success(decodedData.toString() as T);
        } else if (T.toString().contains('int')) {
          final intValue =
              decodedData is int
                  ? decodedData
                  : int.tryParse(decodedData.toString());
          return Result.success(intValue as T);
        } else if (T.toString().contains('double')) {
          final doubleValue =
              decodedData is double
                  ? decodedData
                  : double.tryParse(decodedData.toString());
          return Result.success(doubleValue as T);
        } else if (T.toString().contains('bool')) {
          final boolValue =
              decodedData is bool
                  ? decodedData
                  : decodedData.toString().toLowerCase() == 'true';
          return Result.success(boolValue as T);
        } else {
          // Para otros tipos, intentar el cast normal
          try {
            return Result.success(decodedData as T);
          } catch (e) {
            // Si falla el cast, devolver null
            return Result.success(null);
          }
        }
      }
    } catch (error) {
      return Result.error(
        CacheException(message: 'Error al obtener de caché', cause: error),
      );
    }
  }

  /// Verificar si existe en caché
  Future<Result<bool, Exception>> contains(String key) async {
    try {
      await _ensureInitialized();

      final metadata = _metadata[key];
      if (metadata == null) {
        return Result.success(false);
      }

      if (metadata.isExpired) {
        await _remove(key);
        return Result.success(false);
      }

      return Result.success(true);
    } catch (error) {
      return Result.error(
        CacheException(
          message: 'Error al verificar existencia en caché',
          cause: error,
        ),
      );
    }
  }

  /// Eliminar datos de caché
  Future<Result<void, Exception>> remove(String key) async {
    try {
      await _ensureInitialized();
      await _remove(key);
      return Result.success(null);
    } catch (error) {
      return Result.error(
        CacheException(message: 'Error al eliminar de caché', cause: error),
      );
    }
  }

  /// Eliminar múltiples datos de caché
  Future<Result<void, Exception>> removeMultiple(List<String> keys) async {
    try {
      await _ensureInitialized();

      for (final key in keys) {
        await _remove(key);
      }

      return Result.success(null);
    } catch (error) {
      return Result.error(
        CacheException(
          message: 'Error al eliminar múltiples items de caché',
          cause: error,
        ),
      );
    }
  }

  /// Eliminar todos los datos de caché
  Future<Result<void, Exception>> clear() async {
    try {
      await _ensureInitialized();

      await _cacheBox!.clear();
      _metadata.clear();
      await _saveMetadata();

      _stats = CacheStats(lastCleaned: DateTime.now());
      await _saveStats();

      return Result.success(null);
    } catch (error) {
      return Result.error(
        CacheException(message: 'Error al limpiar caché', cause: error),
      );
    }
  }

  /// Eliminar datos expirados
  Future<Result<int, Exception>> cleanExpired() async {
    try {
      await _ensureInitialized();

      int removedCount = 0;
      final expiredKeys = <String>[];

      for (final entry in _metadata.entries) {
        if (entry.value.isExpired) {
          expiredKeys.add(entry.key);
        }
      }

      for (final key in expiredKeys) {
        await _remove(key);
        removedCount++;
      }

      return Result.success(removedCount);
    } catch (error) {
      return Result.error(
        CacheException(
          message: 'Error al limpiar caché expirada',
          cause: error,
        ),
      );
    }
  }

  /// Limpiar caché por categoría
  Future<Result<int, Exception>> cleanByCategory(String category) async {
    try {
      await _ensureInitialized();

      int removedCount = 0;
      final keysToRemove = <String>[];

      for (final entry in _metadata.entries) {
        if (entry.value.category == category) {
          keysToRemove.add(entry.key);
        }
      }

      for (final key in keysToRemove) {
        await _remove(key);
        removedCount++;
      }

      return Result.success(removedCount);
    } catch (error) {
      return Result.error(
        CacheException(
          message: 'Error al limpiar caché por categoría',
          cause: error,
        ),
      );
    }
  }

  /// Limpiar caché por etiqueta
  Future<Result<int, Exception>> cleanByTag(
    String tagKey,
    String tagValue,
  ) async {
    try {
      await _ensureInitialized();

      int removedCount = 0;
      final keysToRemove = <String>[];

      for (final entry in _metadata.entries) {
        if (entry.value.tags[tagKey] == tagValue) {
          keysToRemove.add(entry.key);
        }
      }

      for (final key in keysToRemove) {
        await _remove(key);
        removedCount++;
      }

      return Result.success(removedCount);
    } catch (error) {
      return Result.error(
        CacheException(
          message: 'Error al limpiar caché por etiqueta',
          cause: error,
        ),
      );
    }
  }

  /// Obtener estadísticas de caché
  CacheStats get stats => _stats;

  /// Obtener metadatos de un item
  CacheMetadata? getMetadata(String key) => _metadata[key];

  /// Obtener todas las claves en caché
  List<String> get keys => _metadata.keys.toList();

  /// Obtener tamaño total de caché en bytes
  int get totalSize => _stats.totalSize;

  /// Obtener número total de items en caché
  int get totalItems => _stats.totalItems;

  /// Verificar si el servicio está inicializado
  bool get isInitialized => _isInitialized;

  /// Cerrar el servicio de caché
  Future<void> close() async {
    if (_cacheBox != null && _cacheBox!.isOpen) {
      await _cacheBox!.close();
    }
    _isInitialized = false;
  }

  // Métodos privados

  /// Eliminar item de caché (método interno)
  Future<void> _remove(String key) async {
    await _cacheBox!.delete(key);
    _metadata.remove(key);
    await _saveMetadata();
  }

  /// Cargar metadatos desde Hive
  Future<void> _loadMetadata() async {
    final metadataData = _cacheBox!.get(_metadataKey);
    if (metadataData != null) {
      final metadataMap =
          json.decode(metadataData as String) as Map<String, dynamic>;
      _metadata.clear();
      metadataMap.forEach((key, value) {
        _metadata[key] = CacheMetadata.fromJson(value as Map<String, dynamic>);
      });
    }
  }

  /// Guardar metadatos en Hive
  Future<void> _saveMetadata() async {
    final metadataMap = <String, dynamic>{};
    _metadata.forEach((key, value) {
      metadataMap[key] = value.toJson();
    });
    await _cacheBox!.put(_metadataKey, json.encode(metadataMap));
  }

  /// Cargar estadísticas desde Hive
  Future<void> _loadStats() async {
    final statsData = _cacheBox!.get(_statsKey);
    if (statsData != null) {
      final statsMap = json.decode(statsData as String) as Map<String, dynamic>;
      _stats = CacheStats.fromJson(statsMap);
    }
  }

  /// Guardar estadísticas en Hive
  Future<void> _saveStats() async {
    await _cacheBox!.put(_statsKey, json.encode(_stats.toJson()));
  }

  /// Convertir Map<dynamic, dynamic> a Map<String, dynamic>
  Map<String, dynamic>? _convertDynamicMapToStringMap(dynamic data) {
    if (data == null) return null;
    if (data is! Map) return null;

    final result = <String, dynamic>{};
    for (final entry in (data as Map).entries) {
      final key = entry.key.toString();
      final value = entry.value;

      // Convertir recursivamente si es necesario
      if (value is Map) {
        result[key] = _convertDynamicMapToStringMap(value);
      } else if (value is List) {
        result[key] = _convertDynamicList(value);
      } else {
        result[key] = value;
      }
    }
    return result;
  }

  /// Convertir List<dynamic> a List<dynamic> con tipos adecuados
  List<dynamic> _convertDynamicList(dynamic data) {
    if (data == null) return [];
    if (data is! List) return [];

    final result = <dynamic>[];
    for (final item in data) {
      if (item is Map) {
        result.add(_convertDynamicMapToStringMap(item));
      } else if (item is List) {
        result.add(_convertDynamicList(item));
      } else {
        result.add(item);
      }
    }
    return result;
  }

  /// Convertir list a map
  List<Map<String, dynamic>>? _convertDynamicListToMapList(dynamic data) {
    if (data == null) return null;
    if (data is! List) return null;

    final result = <Map<String, dynamic>>[];
    for (final item in data) {
      if (item is Map) {
        final converted = _convertDynamicMapToStringMap(item);
        if (converted != null) {
          result.add(converted);
        }
      }
    }
    return result;
  }

  /// Método helper para verificar tipos en tiempo de ejecución
  bool _isType<T>(Type type) {
    return type == T;
  }

  /// Check if key exists in cache (expired items are removed automatically)
  Future<bool> has(String key) async {
    try {
      await _ensureInitialized();

      // Check if exists in metadata
      if (!_metadata.containsKey(key)) {
        return false;
      }

      // Check if expired
      final metadata = _metadata[key]!;
      if (metadata.isExpired) {
        // Remove expired item
        await _remove(key);
        return false;
      }

      return true;
    } catch (error) {
      return false;
    }
  }

  /// Set value in cache with proper error handling
  Future<void> set(String key, dynamic value) async {
    try {
      final result = await save(
        key: key,
        data: value,
        category: 'general',
        tags: {},
        ttl: const Duration(hours: 1),
      );

      // Handle result without throwing
      result.fold<void>(
        (_) {}, // Success, do nothing
        (error) {
          // Log the error but don't throw to allow app to continue
          // The error is already captured in save() and returned as Result
          // We just log it here for debugging
          print(
            'CacheService.set: Error saving to cache for key: $key - $error',
          );
        },
      );
    } catch (e) {
      // Catch any unexpected errors and log them
      print('CacheService.set: Unexpected error for key: $key - $e');
    }
  }
}

/// Metadatos de un item en caché
class CacheMetadata {
  final String key;
  final String category;
  final Map<String, dynamic> tags;
  final Duration ttl;
  final DateTime createdAt;
  final int size;
  final int accessCount;
  final DateTime lastAccessed;

  const CacheMetadata({
    required this.key,
    required this.category,
    required this.tags,
    required this.ttl,
    required this.createdAt,
    required this.size,
    this.accessCount = 0,
    required this.lastAccessed,
  });

  /// Verificar si el item ha expirado
  bool get isExpired {
    final expiryTime = createdAt.add(ttl);
    return DateTime.now().isAfter(expiryTime);
  }

  /// Obtener tiempo restante hasta expiración
  Duration get timeRemaining {
    final expiryTime = createdAt.add(ttl);
    return expiryTime.difference(DateTime.now());
  }

  /// Copiar con nuevos valores
  CacheMetadata copyWith({
    String? key,
    String? category,
    Map<String, dynamic>? tags,
    Duration? ttl,
    DateTime? createdAt,
    int? size,
    int? accessCount,
    DateTime? lastAccessed,
  }) {
    return CacheMetadata(
      key: key ?? this.key,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      ttl: ttl ?? this.ttl,
      createdAt: createdAt ?? this.createdAt,
      size: size ?? this.size,
      accessCount: accessCount ?? this.accessCount,
      lastAccessed: lastAccessed ?? this.lastAccessed,
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'category': category,
      'tags': tags,
      'ttl': ttl.inSeconds,
      'createdAt': createdAt.toIso8601String(),
      'size': size,
      'accessCount': accessCount,
      'lastAccessed': lastAccessed.toIso8601String(),
    };
  }

  /// Crear desde JSON
  factory CacheMetadata.fromJson(Map<String, dynamic> json) {
    return CacheMetadata(
      key: json['key'],
      category: json['category'],
      tags: Map<String, dynamic>.from(json['tags'] ?? {}),
      ttl: Duration(seconds: json['ttl']),
      createdAt: DateTime.parse(json['createdAt']),
      size: json['size'],
      accessCount: json['accessCount'] ?? 0,
      lastAccessed: DateTime.parse(json['lastAccessed']),
    );
  }
}

/// Estadísticas de la caché
class CacheStats {
  final int totalItems;
  final int totalSize; // en bytes
  final int hits;
  final int misses;
  final DateTime lastCleaned;

  CacheStats({
    this.totalItems = 0,
    this.totalSize = 0,
    this.hits = 0,
    this.misses = 0,
    DateTime? lastCleaned,
  }) : lastCleaned = lastCleaned ?? DateTime.now();

  /// Copiar con nuevos valores
  CacheStats copyWith({
    int? totalItems,
    int? totalSize,
    int? hits,
    int? misses,
    DateTime? lastCleaned,
  }) {
    return CacheStats(
      totalItems: totalItems ?? this.totalItems,
      totalSize: totalSize ?? this.totalSize,
      hits: hits ?? this.hits,
      misses: misses ?? this.misses,
      lastCleaned: lastCleaned ?? this.lastCleaned,
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'totalItems': totalItems,
      'totalSize': totalSize,
      'hits': hits,
      'misses': misses,
      'lastCleaned': lastCleaned.toIso8601String(),
    };
  }

  /// Crear desde JSON
  factory CacheStats.fromJson(Map<String, dynamic> json) {
    return CacheStats(
      totalItems: json['totalItems'] ?? 0,
      totalSize: json['totalSize'] ?? 0,
      hits: json['hits'] ?? 0,
      misses: json['misses'] ?? 0,
      lastCleaned: DateTime.parse(json['lastCleaned']),
    );
  }
}

/// Categorías predefinidas para caché
class CacheCategories {
  static const String tiendas = 'tiendas';
  static const String productos = 'productos';
  static const String categorias = 'categorias';
  static const String usuarios = 'usuarios';
  static const String imagenes = 'imagenes';
  static const String configuracion = 'configuracion';
}

/// Excepción específica para errores de caché
class CacheException implements Exception {
  final String message;
  final dynamic cause;

  const CacheException({required this.message, this.cause});

  @override
  String toString() {
    return 'CacheException: $message${cause != null ? ' (Causa: $cause)' : ''}';
  }
}
