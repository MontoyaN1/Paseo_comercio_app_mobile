// lib/data/datasources/local/local_database.dart

import 'dart:typed_data';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';

import '../../../core/app/app_config.dart';
import '../../../data/models/domain/usuario.dart';
import '../../../data/models/domain/tienda.dart';

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

      // Registrar adaptadores
      Hive.registerAdapter(UsuarioAdapter());
      Hive.registerAdapter(TiendaAdapter());
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
      await _cleanupExpiredCache();
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

    _logger.d('Cached ${tiendas.length} tiendas with key: $cacheKey');
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
      _logger.d('No cache found for key: $cacheKey');
      return null;
    }

    if (checkExpiry && _isCacheExpired(cacheEntry)) {
      _logger.d('Cache expired for key: $cacheKey');
      await tiendasBox.delete(cacheKey);
      return null;
    }

    // Actualizar último acceso
    cacheEntry['last_access'] = DateTime.now().toIso8601String();
    cacheEntry['access_count'] = (cacheEntry['access_count'] ?? 0) + 1;
    await tiendasBox.put(cacheKey, cacheEntry);

    final data = cacheEntry['data'] as List<dynamic>;
    return data.map((item) => item as Map<String, dynamic>).toList();
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
    _logger.d('Cached tienda with ID: $tiendaId');
  }

  /// Obtener una tienda individual desde caché
  Future<Map<String, dynamic>?> getCachedTienda(int tiendaId) async {
    _checkInitialized();

    final cacheKey = 'tienda_$tiendaId';
    final cacheEntry = tiendasBox.get(cacheKey);

    if (cacheEntry == null) {
      return null;
    }

    if (_isCacheExpired(cacheEntry)) {
      await tiendasBox.delete(cacheKey);
      return null;
    }

    // Actualizar último acceso
    cacheEntry['last_access'] = DateTime.now().toIso8601String();
    cacheEntry['access_count'] = (cacheEntry['access_count'] ?? 0) + 1;
    await tiendasBox.put(cacheKey, cacheEntry);

    return cacheEntry['data'] as Map<String, dynamic>;
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
    _logger.d('Cached image: $url (${bytes.length} bytes)');

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

    // Actualizar estadísticas de acceso
    cacheEntry['last_access'] = DateTime.now().toIso8601String();
    cacheEntry['access_count'] = (cacheEntry['access_count'] ?? 0) + 1;
    await imagenesBox.put(cacheKey, cacheEntry);

    return cacheEntry['data'] as Uint8List;
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
    _logger.d('Cached usuario with Clerk ID: $clerkUserId');
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

    // Actualizar último acceso
    cacheEntry['last_access'] = DateTime.now().toIso8601String();
    cacheEntry['access_count'] = (cacheEntry['access_count'] ?? 0) + 1;
    await usuariosBox.put(cacheKey, cacheEntry);

    return cacheEntry['data'] as Map<String, dynamic>;
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
  bool _isCacheExpired(Map<String, dynamic> cacheEntry) {
    final expiresAt = DateTime.parse(cacheEntry['expires_at'] as String);
    return DateTime.now().isAfter(expiresAt);
  }

  /// Generar clave de caché para imágenes
  String _generateImageCacheKey(String url) {
    // Usar hash de la URL como clave
    final hash = url.hashCode;
    return 'img_${hash.abs()}';
  }

  /// Limpiar caché expirada
  Future<void> _cleanupExpiredCache() async {
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
        final entry = box.get(key);
        if (entry != null && _isCacheExpired(entry)) {
          keysToDelete.add(key);
        }
      }

      for (final key in keysToDelete) {
        await box.delete(key);
        totalCleaned++;
      }
    }

    if (totalCleaned > 0) {
      _logger.i('Cleaned $totalCleaned expired cache entries');
    }

    // Actualizar metadata
    final metadata = metadataBox.get('stats', defaultValue: {});
    metadata ??= {};
    metadata['last_cleanup'] = DateTime.now().toIso8601String();
    metadata['cleanup_count'] = (metadata['cleanup_count'] ?? 0) + 1;
    await metadataBox.put('stats', metadata as Map<String, dynamic>);
  }

  /// Limpiar caché de imágenes si excede límite
  Future<void> _cleanupImageCache() async {
    final appConfig = AppConfig();
    final maxItems = appConfig.maxImageCacheItems;
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
        if (entry != null && entry is Map<String, dynamic>) {
          // Estimación aproximada del tamaño
          totalSize += entry.toString().length;
        }
      }
    }

    return totalSize;
  }

  /// Actualizar metadata
  Future<void> _updateMetadata(String entityType, int count) async {
    final metadata = metadataBox.get('stats', defaultValue: {});
    metadata ??= {};
    metadata[entityType] = {
      'count': count,
      'last_update': DateTime.now().toIso8601String(),
    };
    await metadataBox.put('stats', metadata as Map<String, dynamic>);
  }
}
