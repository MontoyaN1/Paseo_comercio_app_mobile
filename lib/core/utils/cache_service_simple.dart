// lib/core/utils/cache_service_simple.dart
// Versión simplificada temporal para resolver problemas de compilación

import 'dart:async';
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'result.dart';

/// Servicio de caché local simplificado usando Hive
class CacheServiceSimple {
  // Singleton pattern
  static final CacheServiceSimple _instance = CacheServiceSimple._internal();
  factory CacheServiceSimple() => _instance;
  CacheServiceSimple._internal();

  static const String _cacheBoxName = 'app_cache_simple';
  Box? _cacheBox;
  bool _isInitialized = false;

  /// Inicializar servicio de caché
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Inicializar Hive
      final appDir = await getApplicationDocumentsDirectory();
      Hive.init(appDir.path);

      // Abrir o crear la caja de caché
      _cacheBox = await Hive.openBox(_cacheBoxName);

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
  Future<Result<void, Exception>> put(
    String key,
    dynamic data, {
    Duration ttl = const Duration(hours: 1),
  }) async {
    try {
      await _ensureInitialized();

      // Serializar datos
      final serializedData = jsonEncode(data);

      // Guardar datos
      await _cacheBox!.put(key, serializedData);

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

      // Obtener datos
      final data = _cacheBox!.get(key);
      if (data == null) {
        return Result.success(null);
      }

      // Deserializar datos
      final decodedData = jsonDecode(data as String);
      return Result.success(decodedData as T);
    } catch (error) {
      return Result.error(
        CacheException(message: 'Error al obtener de caché', cause: error),
      );
    }
  }

  /// Eliminar datos de caché
  Future<Result<void, Exception>> delete(String key) async {
    try {
      await _ensureInitialized();
      await _cacheBox!.delete(key);
      return Result.success(null);
    } catch (error) {
      return Result.error(
        CacheException(message: 'Error al eliminar de caché', cause: error),
      );
    }
  }

  /// Limpiar toda la caché
  Future<Result<void, Exception>> clear() async {
    try {
      await _ensureInitialized();
      await _cacheBox!.clear();
      return Result.success(null);
    } catch (error) {
      return Result.error(
        CacheException(message: 'Error al limpiar caché', cause: error),
      );
    }
  }

  /// Verificar si existe una clave en caché
  Future<Result<bool, Exception>> containsKey(String key) async {
    try {
      await _ensureInitialized();
      final exists = _cacheBox!.containsKey(key);
      return Result.success(exists);
    } catch (error) {
      return Result.error(
        CacheException(
          message: 'Error al verificar clave en caché',
          cause: error,
        ),
      );
    }
  }

  /// Obtener todas las claves en caché
  Future<Result<List<String>, Exception>> getAllKeys() async {
    try {
      await _ensureInitialized();
      final keys = _cacheBox!.keys.cast<String>().toList();
      return Result.success(keys);
    } catch (error) {
      return Result.error(
        CacheException(
          message: 'Error al obtener claves de caché',
          cause: error,
        ),
      );
    }
  }

  /// Obtener estadísticas básicas de caché
  Future<Result<Map<String, dynamic>, Exception>> getStats() async {
    try {
      await _ensureInitialized();

      final keys = _cacheBox!.keys.cast<String>().toList();
      int totalSize = 0;

      for (final key in keys) {
        final data = _cacheBox!.get(key);
        if (data != null) {
          totalSize += data.toString().length;
        }
      }

      final stats = {
        'totalItems': keys.length,
        'totalSize': totalSize,
        'keys': keys,
      };

      return Result.success(stats);
    } catch (error) {
      return Result.error(
        CacheException(
          message: 'Error al obtener estadísticas de caché',
          cause: error,
        ),
      );
    }
  }

  /// Verificar si el servicio está inicializado
  bool get isInitialized => _isInitialized;

  /// Cerrar el servicio de caché
  Future<void> close() async {
    if (_cacheBox != null && _cacheBox!.isOpen) {
      await _cacheBox!.close();
    }
    _isInitialized = false;
  }
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
