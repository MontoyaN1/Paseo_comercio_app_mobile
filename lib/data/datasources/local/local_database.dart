// lib/data/datasources/local/local_database.dart

import 'dart:typed_data';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';

/// Servicio de caché local usando Hive
class LocalCacheService {
  static final LocalCacheService _instance = LocalCacheService._internal();
  factory LocalCacheService() => _instance;
  LocalCacheService._internal();

  late Logger _logger;
  bool _isInitialized = false;

  // Nombres de las cajas (boxes) de Hive
  static const String tiendasBoxName = 'tiendas_cache';
  static const String productosBoxName = 'productos_cache';
  static const String categoriasBoxName = 'categorias_cache';
  static const String plazoletasBoxName = 'plazoletas_cache';
  static const String imagenesBoxName = 'imagenes_cache';
  static const String usuariosBoxName = 'usuarios_cache';
  static const String metadataBoxName = 'cache_metadata';
  static const String preferencesBoxName = 'app_preferences';

  // Instancias de las cajas
  late Box<Map<String, dynamic>> tiendasBox;
  late Box<Map<String, dynamic>> productosBox;
  late Box<Map<String, dynamic>> categoriasBox;
  late Box<Map<String, dynamic>> plazoletasBox;
  late Box<Map<String, dynamic>> imagenesBox;
  late Box<Map<String, dynamic>> usuariosBox;
  late Box<Map<String, dynamic>> metadataBox;
  late Box<Map<String, dynamic>> preferencesBox;

  /// Inicializar el servicio de caché
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Obtener directorio de documentos
      final appDir = await getApplicationDocumentsDirectory();
      Hive.init(appDir.path);

      // Registrar adaptadores (comentado temporalmente hasta generar con build_runner)
      // Hive.registerAdapter(UsuarioAdapter());
      // Hive.registerAdapter(TiendaAdapter());
      // Nota: Necesitarás generar los adaptadores con build_runner

      _logger = Logger(
        printer: PrettyPrinter(
          methodCount: 0,
          errorMethodCount: 3,
          lineLength: 50,
          colors: true,
          printEmojis: true,
        ),
      );

      // Abrir todas las cajas
      tiendasBox = await Hive.openBox(tiendasBoxName);
      productosBox = await Hive.openBox(productosBoxName);
      categoriasBox = await Hive.openBox(categoriasBoxName);
      plazoletasBox = await Hive.openBox(plazoletasBoxName);
      imagenesBox = await Hive.openBox(imagenesBoxName);
      usuariosBox = await Hive.openBox(usuariosBoxName);
      metadataBox = await Hive.openBox(metadataBoxName);
      preferencesBox = await Hive.openBox(preferencesBoxName);

      _isInitialized = true;

      _logger.i('✅ Local cache initialized successfully');
      _logger.i('Cache directory: ${appDir.path}');

      // Limpiar caché expirada al iniciar
      try {
        await _cleanupExpiredCache();
      } catch (e) {
        _logger.w('⚠️ Error cleaning expired cache during initialization: $e');
        // No rethrow - continuar con la inicialización
      }
    } catch (e) {
      _logger.e('❌ Failed to initialize local cache: $e');
      rethrow;
    }
  }

  /// Verificar si el servicio está inicializado
  bool get isInitialized => _isInitialized;

  // ========== MÉTODOS PARA TIENDAS ==========

  /// Guardar tiendas en caché
  Future<void> cacheTiendas(
    List<Map<String, dynamic>> tiendas, {
    String? key,
    Duration ttl = const Duration(hours: 1),
    int priority = 1,
  }) async {
    _checkInitialized();

    final cacheKey = key ?? 'tiendas_list';
    final cacheEntry = _createCacheEntry(
      data: tiendas,
      ttl: ttl,
      priority: priority,
    );

    await tiendasBox.put(cacheKey, cacheEntry);
    await _updateMetadata('tiendas', tiendas.length);
  }

  /// Obtener tiendas desde caché
  Future<List<Map<String, dynamic>>?> getCachedTiendas({
    String? key,
    bool checkExpiry = true,
  }) async {
    _checkInitialized();

    final cacheKey = key ?? 'tiendas_list';
    final cacheEntry = tiendasBox.get(cacheKey);

    if (cacheEntry == null) {
      return null;
    }

    if (checkExpiry && _isCacheExpired(cacheEntry)) {
      await tiendasBox.delete(cacheKey);
      return null;
    }

    // Convertir cacheEntry a Map<String, dynamic> si es necesario
    final Map<String, dynamic> entry = _convertToMapStringDynamic(cacheEntry);

    // Actualizar último acceso
    entry['last_access'] = DateTime.now().toIso8601String();
    entry['access_count'] = (entry['access_count'] ?? 0) + 1;
    await tiendasBox.put(cacheKey, entry);

    final data = entry['data'];
    if (data is List) {
      final convertedList = _convertListDynamic(data);
      // Filtrar solo los elementos que son Map<String, dynamic>
      final result = <Map<String, dynamic>>[];
      for (final item in convertedList) {
        if (item is Map<String, dynamic>) {
          result.add(item);
        } else if (item is Map) {
          result.add(_convertToMapStringDynamic(item));
        }
      }
      return result;
    }
    return null;
  }

  /// Guardar una tienda individual
  Future<void> cacheTienda(Map<String, dynamic> tienda) async {
    _checkInitialized();

    final tiendaId = tienda['id']?.toString();
    if (tiendaId == null) {
      _logger.w('Tienda without ID, cannot cache');
      return;
    }

    final cacheEntry = _createCacheEntry(
      data: tienda,
      ttl: const Duration(hours: 2),
      priority: 2,
    );

    await tiendasBox.put('tienda_$tiendaId', cacheEntry);
  }

  /// Obtener una tienda individual desde caché
  Future<Map<String, dynamic>?> getCachedTienda(int tiendaId) async {
    _checkInitialized();

    final cacheKey = 'tienda_$tiendaId';
    try {
      final cacheEntry = tiendasBox.get(cacheKey);

      if (cacheEntry == null) {
        return null;
      }

      // Convertir el cacheEntry a Map<String, dynamic> de forma segura
      Map<String, dynamic> entry;
      if (cacheEntry is Map<String, dynamic>) {
        entry = cacheEntry;
      } else if (cacheEntry is Map) {
        entry = Map<String, dynamic>.from(
          (cacheEntry).map((key, value) => MapEntry(key.toString(), value)),
        );
      } else {
        _logger.w(
          'Cache entry for tienda $tiendaId has unexpected type: ${cacheEntry.runtimeType}',
        );
        await tiendasBox.delete(cacheKey);
        return null;
      }

      if (_isCacheExpired(entry)) {
        await tiendasBox.delete(cacheKey);
        return null;
      }

      // Actualizar último acceso
      entry['last_access'] = DateTime.now().toIso8601String();
      entry['access_count'] = (entry['access_count'] ?? 0) + 1;
      await tiendasBox.put(cacheKey, entry);

      final data = entry['data'];
      if (data is Map<String, dynamic>) {
        return data;
      } else if (data is Map) {
        return Map<String, dynamic>.from(
          (data).map((key, value) => MapEntry(key.toString(), value)),
        );
      } else if (data != null) {
        _logger.w(
          'Cache data for tienda $tiendaId has unexpected data type: ${data.runtimeType}',
        );
      }
      return null;
    } catch (e) {
      _logger.e('Error getting cached tienda $tiendaId: $e');
      return null;
    }
  }

  // ========== MÉTODOS PARA IMÁGENES ==========

  /// Guardar imagen en caché
  Future<void> cacheImage(
    String url,
    Uint8List bytes, {
    int priority = 1,
    Duration ttl = const Duration(days: 7),
  }) async {
    _checkInitialized();

    final cacheKey = _generateImageCacheKey(url);
    final cacheEntry = _createCacheEntry(
      data: bytes,
      ttl: ttl,
      priority: priority,
      metadata: {'url': url, 'size_bytes': bytes.length},
    );

    await imagenesBox.put(cacheKey, cacheEntry);

    // Limpiar caché si excede límite
    await _cleanupImageCache();
  }

  /// Obtener imagen desde caché
  Future<Uint8List?> getCachedImage(String url) async {
    _checkInitialized();

    final cacheKey = _generateImageCacheKey(url);
    final cacheEntry = imagenesBox.get(cacheKey);

    if (cacheEntry == null) {
      return null;
    }

    if (_isCacheExpired(cacheEntry)) {
      await imagenesBox.delete(cacheKey);
      return null;
    }

    // Convertir cacheEntry a Map<String, dynamic> si es necesario
    final Map<String, dynamic> entry = _convertToMapStringDynamic(cacheEntry);

    // Actualizar último acceso
    entry['last_access'] = DateTime.now().toIso8601String();
    entry['access_count'] = (entry['access_count'] ?? 0) + 1;
    await imagenesBox.put(cacheKey, entry);

    final data = entry['data'];
    if (data is Uint8List) {
      return data;
    } else if (data is List<int>) {
      // Convertir List<int> a Uint8List si es necesario
      return Uint8List.fromList(data.cast<int>());
    }
    return null;
  }

  /// Verificar si una imagen está en caché
  Future<bool> hasCachedImage(String url) async {
    _checkInitialized();

    final cacheKey = _generateImageCacheKey(url);
    final cacheEntry = imagenesBox.get(cacheKey);

    if (cacheEntry == null) return false;
    if (_isCacheExpired(cacheEntry)) {
      await imagenesBox.delete(cacheKey);
      return false;
    }

    return true;
  }

  // ========== MÉTODOS PARA USUARIOS ==========

  /// Guardar usuario en caché
  Future<void> cacheUsuario(Map<String, dynamic> usuario) async {
    _checkInitialized();

    final clerkUserId = usuario['clerk_user_id']?.toString();
    if (clerkUserId == null) {
      _logger.w('Usuario without clerk_user_id, cannot cache');
      return;
    }

    final cacheEntry = _createCacheEntry(
      data: usuario,
      ttl: const Duration(days: 30), // Los usuarios se cachean por más tiempo
      priority: 3, // Alta prioridad
    );

    await usuariosBox.put('usuario_$clerkUserId', cacheEntry);
  }

  /// Obtener usuario desde caché
  Future<Map<String, dynamic>?> getCachedUsuario(String clerkUserId) async {
    _checkInitialized();

    final cacheKey = 'usuario_$clerkUserId';
    final cacheEntry = usuariosBox.get(cacheKey);

    if (cacheEntry == null) {
      return null;
    }

    if (_isCacheExpired(cacheEntry)) {
      await usuariosBox.delete(cacheKey);
      return null;
    }

    // Convertir cacheEntry a Map<String, dynamic> si es necesario
    final Map<String, dynamic> entry = _convertToMapStringDynamic(cacheEntry);

    // Actualizar último acceso
    entry['last_access'] = DateTime.now().toIso8601String();
    entry['access_count'] = (entry['access_count'] ?? 0) + 1;
    await usuariosBox.put(cacheKey, entry);

    final data = entry['data'];
    if (data is Map) {
      return _convertToMapStringDynamic(data);
    } else if (data != null) {
      // Intentar convertir si no es null pero tampoco es Map
      return _convertToMapStringDynamic({'data': data});
    }
    return null;
  }

  // ========== MÉTODOS PARA PREFERENCIAS ==========

  /// Guardar preferencia de usuario
  Future<void> setPreference(String key, dynamic value) async {
    _checkInitialized();
    await preferencesBox.put(key, value);
  }

  /// Obtener preferencia de usuario
  dynamic getPreference(String key, {dynamic defaultValue}) {
    _checkInitialized();
    return preferencesBox.get(key, defaultValue: defaultValue);
  }

  /// Eliminar preferencia
  Future<void> removePreference(String key) async {
    _checkInitialized();
    await preferencesBox.delete(key);
  }

  // ========== MÉTODOS DE LIMPIEZA Y MANTENIMIENTO ==========

  /// Limpiar toda la caché
  Future<void> clearAllCache() async {
    _checkInitialized();

    await tiendasBox.clear();
    await productosBox.clear();
    await categoriasBox.clear();
    await plazoletasBox.clear();
    await imagenesBox.clear();
    await usuariosBox.clear();
    await metadataBox.clear();

    _logger.i('All cache cleared');
  }

  /// Limpiar caché expirada
  Future<void> clearExpiredCache() async {
    _checkInitialized();
    await _cleanupExpiredCache();
  }

  /// Obtener estadísticas de caché
  Future<Map<String, dynamic>> getCacheStats() async {
    _checkInitialized();

    final metadata = metadataBox.get('stats', defaultValue: {});
    final now = DateTime.now();

    return {
      'tiendas_count': tiendasBox.length,
      'productos_count': productosBox.length,
      'categorias_count': categoriasBox.length,
      'imagenes_count': imagenesBox.length,
      'usuarios_count': usuariosBox.length,
      'total_size_bytes': await _calculateTotalSize(),
      'last_cleanup': metadata?['last_cleanup'] ?? 'Never',
      'cleanup_count': metadata?['cleanup_count'] ?? 0,
      'timestamp': now.toIso8601String(),
    };
  }

  // ========== MÉTODOS PRIVADOS ==========

  /// Verificar que el servicio esté inicializado
  void _checkInitialized() {
    if (!_isInitialized) {
      throw Exception('Local cache not initialized. Call initialize() first.');
    }
  }

  /// Crear entrada de caché
  Map<String, dynamic> _createCacheEntry({
    required dynamic data,
    required Duration ttl,
    int priority = 1,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    return {
      'data': data,
      'created_at': now.toIso8601String(),
      'expires_at': now.add(ttl).toIso8601String(),
      'ttl_seconds': ttl.inSeconds,
      'priority': priority,
      'access_count': 0,
      'last_access': now.toIso8601String(),
      'metadata': metadata ?? {},
    };
  }

  /// Verificar si la caché está expirada
  bool _isCacheExpired(dynamic cacheEntry) {
    try {
      if (cacheEntry == null) {
        return true;
      }

      // Manejar Map<dynamic, dynamic> o Map<String, dynamic>
      final Map<dynamic, dynamic> entryMap;
      if (cacheEntry is Map<String, dynamic>) {
        entryMap = cacheEntry;
      } else if (cacheEntry is Map) {
        entryMap = cacheEntry;
      } else {
        return true;
      }

      // Obtener expires_at de forma segura
      final expiresAtDynamic = entryMap['expires_at'];
      if (expiresAtDynamic == null) {
        return true;
      }

      // Convertir a String si es necesario
      final expiresAtString = expiresAtDynamic.toString();

      try {
        final expiresAt = DateTime.parse(expiresAtString);
        return DateTime.now().isAfter(expiresAt);
      } catch (e) {
        return true;
      }
    } catch (e) {
      return true;
    }
  }

  /// Generar clave de caché para imágenes
  String _generateImageCacheKey(String url) {
    // Usar hash de la URL como clave
    final hash = url.hashCode;
    return 'img_${hash.abs()}';
  }

  /// Convertir dynamic a Map<String, dynamic>
  Map<String, dynamic> _convertToMapStringDynamic(dynamic data) {
    if (data == null) return {};
    if (data is Map<String, dynamic>) {
      return data;
    } else if (data is Map) {
      final result = <String, dynamic>{};
      for (final key in data.keys) {
        final value = data[key];
        if (value is Map) {
          result[key.toString()] = _convertToMapStringDynamic(value);
        } else if (value is List) {
          result[key.toString()] = _convertListDynamic(value);
        } else {
          result[key.toString()] = value;
        }
      }
      return result;
    }
    return {};
  }

  /// Convertir List<dynamic> con tipos adecuados
  List<dynamic> _convertListDynamic(dynamic data) {
    if (data == null) return [];
    if (data is! List) return [];

    final result = <dynamic>[];
    for (final item in data) {
      if (item is Map) {
        result.add(_convertToMapStringDynamic(item));
      } else if (item is List) {
        result.add(_convertListDynamic(item));
      } else {
        result.add(item);
      }
    }
    return result;
  }

  /// Limpiar caché expirada
  Future<void> _cleanupExpiredCache() async {
    try {
      final boxes = [
        tiendasBox,
        productosBox,
        categoriasBox,
        plazoletasBox,
        imagenesBox,
        usuariosBox,
      ];

      int totalCleaned = 0;

      for (final box in boxes) {
        final keysToDelete = <dynamic>[];

        for (final key in box.keys) {
          try {
            final entry = box.get(key);
            if (entry != null && _isCacheExpired(entry)) {
              keysToDelete.add(key);
            }
          } catch (e) {
            // Continuar con la siguiente clave
          }
        }

        for (final key in keysToDelete) {
          try {
            await box.delete(key);
            totalCleaned++;
          } catch (e) {
            // Ignorar errores al eliminar
          }
        }
      }

      // Actualizar metadata de forma segura
      try {
        final metadataResult = metadataBox.get('stats', defaultValue: {});
        Map<String, dynamic> metadata = <String, dynamic>{};

        // Manejar el resultado de forma segura
        if (metadataResult != null) {
          final map = metadataResult;
          for (final key in map.keys) {
            final value = map[key];
            // Asegurar que el valor sea serializable
            if (value is String ||
                value is num ||
                value is bool ||
                value == null) {
              metadata[key.toString()] = value;
            } else if (value is Map) {
              // Convertir Map anidado
              final nestedMap = <String, dynamic>{};
              for (final nestedKey in value.keys) {
                final nestedValue = value[nestedKey];
                if (nestedValue is String ||
                    nestedValue is num ||
                    nestedValue is bool ||
                    nestedValue == null) {
                  nestedMap[nestedKey.toString()] = nestedValue;
                } else {
                  nestedMap[nestedKey.toString()] = nestedValue.toString();
                }
              }
              metadata[key.toString()] = nestedMap;
            } else {
              metadata[key.toString()] = value.toString();
            }
          }
        }

        metadata['last_cleanup'] = DateTime.now().toIso8601String();
        metadata['cleanup_count'] = (metadata['cleanup_count'] ?? 0) + 1;

        // Asegurar que todos los valores sean serializables
        final serializableMetadata = <String, dynamic>{};
        for (final key in metadata.keys) {
          final value = metadata[key];
          if (value is String ||
              value is num ||
              value is bool ||
              value == null) {
            serializableMetadata[key] = value;
          } else if (value is Map<String, dynamic>) {
            serializableMetadata[key] = value;
          } else if (value is Map) {
            // Convertir Map<dynamic, dynamic> a Map<String, dynamic>
            final convertedMap = <String, dynamic>{};
            for (final mapKey in value.keys) {
              final mapValue = value[mapKey];
              if (mapValue is String ||
                  mapValue is num ||
                  mapValue is bool ||
                  mapValue == null) {
                convertedMap[mapKey.toString()] = mapValue;
              } else {
                convertedMap[mapKey.toString()] = mapValue.toString();
              }
            }
            serializableMetadata[key] = convertedMap;
          } else {
            serializableMetadata[key] = value.toString();
          }
        }

        await metadataBox.put('stats', serializableMetadata);
      } catch (e) {}

      if (totalCleaned > 0) {
        _logger.i('Cleaned $totalCleaned expired cache entries');
      }
    } catch (e, stackTrace) {
      _logger.e('Error in _cleanupExpiredCache: $e');
      _logger.e('Stack trace: $stackTrace');
      // No rethrow - solo loguear el error
    }
  }

  /// Limpiar caché de imágenes si excede límite
  Future<void> _cleanupImageCache() async {
    // No usar AppConfig directamente, usar valores por defecto
    final maxItems = 100; // Valor por defecto
    const maxSizeMB = 100; // 100MB máximo

    if (imagenesBox.length <= maxItems) {
      return;
    }

    // Obtener todas las entradas y calcular tamaño
    final entries = <Map<String, dynamic>>[];
    int totalSize = 0;

    for (final key in imagenesBox.keys) {
      final entry = imagenesBox.get(key);
      if (entry != null) {
        final data = entry['data'];
        if (data is Uint8List) {
          totalSize += data.length;
        }
        entries.add({
          'key': key,
          'entry': entry,
          'last_access': DateTime.parse(entry['last_access'] as String),
          'priority': entry['priority'] ?? 1,
          'size': data is Uint8List ? data.length : 0,
        });
      }
    }

    // Convertir a MB
    final totalSizeMB = totalSize / (1024 * 1024);

    // Si excede límite de tamaño o cantidad, limpiar
    if (totalSizeMB > maxSizeMB || entries.length > maxItems) {
      // Ordenar por prioridad (menor primero) y luego por último acceso (más antiguo primero)
      entries.sort((a, b) {
        final priorityDiff = (a['priority'] ?? 1) - (b['priority'] ?? 1);
        if (priorityDiff != 0) return priorityDiff;
        return a['last_access'].compareTo(b['last_access']);
      });

      // Mantener solo el 80% de las entradas
      final keepCount = (entries.length * 0.8).floor();
      final entriesToKeep = entries.sublist(0, keepCount);
      final keysToKeep = entriesToKeep.map((e) => e['key']).toSet();

      // Eliminar las que no se van a mantener
      for (final key in imagenesBox.keys) {
        if (!keysToKeep.contains(key)) {
          await imagenesBox.delete(key);
        }
      }

      _logger.i(
        'Image cache cleaned. Kept $keepCount of ${entries.length} entries',
      );
    }
  }

  /// Calcular tamaño total de la caché
  Future<int> _calculateTotalSize() async {
    int totalSize = 0;

    final boxes = [
      tiendasBox,
      productosBox,
      categoriasBox,
      plazoletasBox,
      imagenesBox,
      usuariosBox,
    ];

    for (final box in boxes) {
      for (final key in box.keys) {
        final entry = box.get(key);
        if (entry != null) {
          // Estimación aproximada del tamaño
          totalSize += entry.toString().length;
        }
      }
    }

    return totalSize;
  }

  /// Actualizar metadata
  Future<void> _updateMetadata(String entityType, int count) async {
    final metadataResult = metadataBox.get('stats', defaultValue: {});
    Map<String, dynamic> metadata = <String, dynamic>{};

    // Manejar el resultado de forma segura
    if (metadataResult != null) {
      final map = metadataResult;
      for (final key in map.keys) {
        final value = map[key];
        // Asegurar que el valor sea serializable
        if (value is String || value is num || value is bool || value == null) {
          metadata[key.toString()] = value;
        } else if (value is Map) {
          // Convertir Map anidado
          final nestedMap = <String, dynamic>{};
          for (final nestedKey in value.keys) {
            final nestedValue = value[nestedKey];
            if (nestedValue is String ||
                nestedValue is num ||
                nestedValue is bool ||
                nestedValue == null) {
              nestedMap[nestedKey.toString()] = nestedValue;
            } else {
              nestedMap[nestedKey.toString()] = nestedValue.toString();
            }
          }
          metadata[key.toString()] = nestedMap;
        } else {
          metadata[key.toString()] = value.toString();
        }
      }
    }

    metadata[entityType] = {
      'count': count,
      'last_update': DateTime.now().toIso8601String(),
    };

    // Asegurar que todos los valores sean serializables
    final serializableMetadata = <String, dynamic>{};
    for (final key in metadata.keys) {
      final value = metadata[key];
      if (value is String || value is num || value is bool || value == null) {
        serializableMetadata[key] = value;
      } else if (value is Map<String, dynamic>) {
        serializableMetadata[key] = value;
      } else if (value is Map) {
        // Convertir Map<dynamic, dynamic> a Map<String, dynamic>
        final convertedMap = <String, dynamic>{};
        for (final mapKey in value.keys) {
          final mapValue = value[mapKey];
          if (mapValue is String ||
              mapValue is num ||
              mapValue is bool ||
              mapValue == null) {
            convertedMap[mapKey.toString()] = mapValue;
          } else {
            convertedMap[mapKey.toString()] = mapValue.toString();
          }
        }
        serializableMetadata[key] = convertedMap;
      } else {
        serializableMetadata[key] = value.toString();
      }
    }

    await metadataBox.put('stats', serializableMetadata);
  }

  /// Generic get method for cache
  Future<dynamic> get(String key) async {
    _checkInitialized();
    // Try to find in appropriate box based on key pattern
    // For simplicity, search all boxes (inefficient but works for compilation)
    // This is a stub implementation.
    return null;
  }

  /// Generic set method for cache
  Future<void> set(String key, dynamic value) async {
    _checkInitialized();
    // Stub implementation
  }
}
