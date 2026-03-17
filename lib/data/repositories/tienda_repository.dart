// lib/data/repositories/tienda_repository.dart

import 'dart:async';
import 'package:logger/logger.dart';

import '../../core/app/app_config.dart';
import '../datasources/remote/supabase_client.dart';
import '../datasources/local/local_database.dart';
import '../../domain/repositories/tienda_repository_interface.dart';

/// Repositorio para manejar operaciones de tiendas
class TiendaRepository implements TiendaRepositoryInterface {
  final SupabaseClientService _supabaseClient;
  final LocalCacheService _localCache;
  final Logger _logger;
  final AppConfig _appConfig = AppConfig();

  // Stream para notificar cambios en las tiendas
  final StreamController<List<Map<String, dynamic>>> _tiendasController =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  TiendaRepository({
    required SupabaseClientService supabaseClient,
    required LocalCacheService localCache,
  }) : _supabaseClient = supabaseClient,
       _localCache = localCache,
       _logger = Logger(
         printer: PrettyPrinter(
           methodCount: 0,
           errorMethodCount: 3,
           lineLength: 50,
           colors: true,
           printEmojis: true,
           printTime: false,
         ),
       );

  /// Obtener todas las tiendas con estrategia cache-first
  @override
  Future<List<Map<String, dynamic>>> getTiendas({
    int page = 1,
    int limit = 20,
    String? categoriaId,
    bool? soloActivas = true,
    bool forceRefresh = false,
  }) async {
    try {
      final cacheKey =
          'tiendas_page_${page}_limit_${limit}'
          '${categoriaId != null ? '_cat_$categoriaId' : ''}'
          '${soloActivas == true ? '_activas' : ''}';

      // Si no es forzado, intentar obtener de caché primero
      if (!forceRefresh) {
        final cachedTiendas = await _localCache.getCachedTiendas(key: cacheKey);
        if (cachedTiendas != null && cachedTiendas.isNotEmpty) {
          return cachedTiendas;
        }
      }

      // Usar método básico de Supabase
      var query = _supabaseClient.tiendas.select();

      if (categoriaId != null) {
        query = query.eq('categoria_id', categoriaId);
      }

      if (soloActivas == true) {
        query = query.eq('activa', true);
      }

      final response = await query
          .order('fecha_creacion', ascending: false)
          .range((page - 1) * limit, page * limit - 1);

      // response ya es una List según el tipo de retorno de Supabase

      final result = response.whereType<Map<String, dynamic>>().toList();

      // Guardar en caché
      await _localCache.cacheTiendas(
        result,
        key:
            'tiendas_page_${page}_limit_${limit}${categoriaId != null ? '_cat_$categoriaId' : ''}${soloActivas == true ? '_activas' : ''}',
      );

      _logger.i('Tiendas obtenidas: ${result.length}');
      return result;
    } catch (e) {
      _logger.e('Error obteniendo tiendas: $e');
      return [];
    }
  }

  /// Obtener tienda por ID
  @override
  Future<Map<String, dynamic>?> getTiendaById(
    int tiendaId, {
    bool forceRefresh = false,
  }) async {
    try {
      // Si no es forzado, intentar obtener de caché primero
      if (!forceRefresh) {
        final cachedTienda = await _localCache.getCachedTienda(tiendaId);
        if (cachedTienda != null) {
          return cachedTienda;
        }
      }

      final response = await _supabaseClient.tiendas
          .select('''
            *,
            imagen_tienda!left(*)
          ''')
          .eq('id', tiendaId)
          .limit(1);

      if (response.isEmpty) {
        _logger.w('Tienda no encontrada: $tiendaId');
        return null;
      }

      final rawTienda = response.first as Map<dynamic, dynamic>;
      final tienda = Map<String, dynamic>.from(rawTienda);

      // Transformar URLs de Contabo a Cloudflare R2 para imágenes de tienda
      _transformTiendaUrlsToR2(tienda);

      // Guardar en caché
      await _localCache.cacheTienda(tienda);
      _logger.i('Tienda obtenida: $tiendaId');

      return tienda;
    } catch (e) {
      _logger.e('Error obteniendo tienda $tiendaId: $e');
      return null;
    }
  }

  /// Obtener tiendas por propietario
  @override
  Future<List<Map<String, dynamic>>> getTiendasByPropietario(
    int propietarioId, {
    int page = 1,
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    try {
      // Si no es forzado, intentar obtener de caché primero
      if (!forceRefresh) {
        final cachedTiendas = await _localCache.getCachedTiendas(
          key: 'tiendas_prop_${propietarioId}_page_${page}_limit_${limit}',
        );
        if (cachedTiendas != null && cachedTiendas.isNotEmpty) {
          _logger.d(
            'Tiendas de propietario obtenidas de caché: ${cachedTiendas.length}',
          );
          return cachedTiendas;
        }
      }

      _logger.d(
        'Obteniendo tiendas del propietario $propietarioId desde Supabase...',
      );

      final response = await _supabaseClient.tiendas
          .select()
          .eq('id_propietario', propietarioId)
          .order('fecha_creacion', ascending: false)
          .range((page - 1) * limit, page * limit - 1);

      // response ya es una List según el tipo de retorno de Supabase

      final result = response.whereType<Map<String, dynamic>>().toList();

      // Guardar en caché
      await _localCache.cacheTiendas(
        result,
        key: 'tiendas_prop_${propietarioId}_page_${page}_limit_${limit}',
      );

      _logger.i('Tiendas del propietario obtenidas: ${result.length}');
      return result;
    } catch (e) {
      _logger.e('Error obteniendo tiendas del propietario $propietarioId: $e');
      return [];
    }
  }

  /// Buscar tiendas por término
  @override
  Future<List<Map<String, dynamic>>> searchTiendas(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _supabaseClient.tiendas
          .select()
          .ilike('nombre_tienda', '%$query%')
          .order('fecha_creacion', ascending: false)
          .limit(limit);

      // response ya es una List según el tipo de retorno de Supabase

      final result = response.whereType<Map<String, dynamic>>().toList();

      _logger.i('Tiendas encontradas: ${result.length}');
      return result;
    } catch (e) {
      _logger.e('Error buscando tiendas: $e');
      return [];
    }
  }

  /// Crear nueva tienda
  @override
  Future<Map<String, dynamic>?> createTienda({
    required int idPropietario,
    required String nombreTienda,
    String? descripcion,
    Map<String, dynamic>? redesSociales,
    int? organizacionId,
    String? emailContacto,
    String? telefonoContacto,
    String? direccion,
  }) async {
    try {
      final nuevaTienda = {
        'id_propietario': idPropietario,
        'nombre_tienda': nombreTienda,
        'descripcion': descripcion,
        'redes_sociales': redesSociales,
        'organizacion_id': organizacionId,
        'email_contacto': emailContacto,
        'telefono_contacto': telefonoContacto,
        'direccion': direccion,
        'fecha_creacion': DateTime.now().toIso8601String(),
        'total_visitas': 0,
        'total_contactos_whatsapp': 0,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabaseClient.tiendas.insert(nuevaTienda);

      final rawTienda = response;
      final tiendaCreada =
          rawTienda != null
              ? Map<String, dynamic>.from(rawTienda as Map<dynamic, dynamic>)
              : null;

      if (tiendaCreada != null) {
        // Guardar en caché
        await _localCache.cacheTienda(tiendaCreada);

        // Invalidar caché de listas de tiendas
        await _invalidateTiendasCache();

        // Notificar a los listeners
        _tiendasController.add([tiendaCreada]);

        _logger.i('Tienda creada exitosamente: ${tiendaCreada['id']}');
      }

      return tiendaCreada;
    } catch (e) {
      _logger.e('Error creando tienda: $e');
      return null;
    }
  }

  /// Actualizar tienda
  @override
  Future<bool> updateTienda(
    int tiendaId, {
    String? nombreTienda,
    String? descripcion,
    Map<String, dynamic>? redesSociales,
    int? organizacionId,
    String? emailContacto,
    String? telefonoContacto,
    String? direccion,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (nombreTienda != null) updates['nombre_tienda'] = nombreTienda;
      if (descripcion != null) updates['descripcion'] = descripcion;
      if (redesSociales != null) updates['redes_sociales'] = redesSociales;
      if (organizacionId != null) updates['organizacion_id'] = organizacionId;
      if (emailContacto != null) updates['email_contacto'] = emailContacto;
      if (telefonoContacto != null)
        updates['telefono_contacto'] = telefonoContacto;
      if (direccion != null) updates['direccion'] = direccion;
      updates['updated_at'] = DateTime.now().toIso8601String();

      if (updates.isEmpty) {
        _logger.w('No hay actualizaciones para la tienda $tiendaId');
        return false;
      }

      final response = await _supabaseClient.tiendas
          .update(updates)
          .eq('id', tiendaId);

      if (response == null) {
        _logger.e('Error actualizando tienda');
        return false;
      }

      // Invalidar caché de esta tienda
      await _localCache.removePreference('tienda_$tiendaId');

      // Invalidar caché de listas de tiendas
      await _invalidateTiendasCache();

      // Obtener tienda actualizada y notificar
      final tiendaActual = await getTiendaById(tiendaId, forceRefresh: true);
      if (tiendaActual != null) {
        _tiendasController.add([tiendaActual]);
      }

      _logger.i('Tienda $tiendaId actualizada exitosamente');
      return true;
    } catch (e) {
      _logger.e('Error actualizando tienda $tiendaId: $e');
      return false;
    }
  }

  /// Eliminar tienda
  @override
  Future<bool> deleteTienda(int tiendaId) async {
    try {
      final response = await _supabaseClient.tiendas.delete().eq(
        'id',
        tiendaId,
      );

      if (response == null) {
        _logger.e('Error eliminando tienda: response is null');
        return false;
      }

      // Eliminar de caché
      await _localCache.removePreference('tienda_$tiendaId');

      // Invalidar caché de listas de tiendas
      await _invalidateTiendasCache();

      _logger.i('Tienda $tiendaId eliminada exitosamente');
      return true;
    } catch (e) {
      _logger.e('Error eliminando tienda $tiendaId: $e');
      return false;
    }
  }

  /// Registrar visita a tienda
  @override
  Future<bool> registrarVisitaTienda(int tiendaId) async {
    try {
      // Obtener tienda actual
      final tienda = await getTiendaById(tiendaId);
      if (tienda == null) {
        _logger.w('Tienda $tiendaId no encontrada');
        return false;
      }

      final totalVisitas = (tienda['total_visitas'] as int? ?? 0) + 1;

      final response = await _supabaseClient.tiendas
          .update({
            'total_visitas': totalVisitas,
            'fecha_ultima_visita': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', tiendaId);

      if (response == null) {
        _logger.e('Error registrando visita: response is null');
        return false;
      }

      // Actualizar caché
      tienda['total_visitas'] = totalVisitas;
      tienda['fecha_ultima_visita'] = DateTime.now().toIso8601String();
      await _localCache.cacheTienda(tienda);

      _logger.i('Visita registrada a tienda $tiendaId');
      return true;
    } catch (e) {
      _logger.e('Error registrando visita a tienda $tiendaId: $e');
      return false;
    }
  }

  /// Obtener tiendas destacadas (más visitadas)
  @override
  Future<List<Map<String, dynamic>>> getTiendasDestacadas({
    int limit = 12,
  }) async {
    try {
      final response = await _supabaseClient.tiendas
          .select()
          .order('total_visitas', ascending: false)
          .limit(limit);

      // response ya es una List según el tipo de retorno de Supabase

      final result = response.whereType<Map<String, dynamic>>().toList();

      // Guardar en caché con prioridad alta
      await _localCache.cacheTiendas(
        result,
        key: 'tiendas_destacadas',
        priority: 3,
      );

      _logger.i('Tiendas destacadas obtenidas: ${result.length}');
      return result;
    } catch (e) {
      _logger.e('Error obteniendo tiendas destacadas: $e');
      return [];
    }
  }

  /// Obtener stream de cambios en las tiendas
  @override
  Stream<List<Map<String, dynamic>>> get tiendasStream =>
      _tiendasController.stream;

  /// Invalidar caché de tiendas
  Future<void> _invalidateTiendasCache() async {
    try {
      // Limpiar caché de tiendas usando el método público
      await _localCache.clearExpiredCache();
    } catch (e) {
      _logger.e('Error invalidando caché de tiendas: $e');
    }
  }

  /// Disposer para limpiar recursos
  @override
  void dispose() {
    _tiendasController.close();
    _logger.i('TiendaRepository disposed');
  }

  /// Transformar URLs de Contabo a Cloudflare R2 en los datos de la tienda
  void _transformTiendaUrlsToR2(Map<String, dynamic> tienda) {
    // Transformar imagen_tienda (array de imágenes)
    final imagenTienda = tienda['imagen_tienda'];
    if (imagenTienda is List) {
      final nuevasImagenes = <Map<String, dynamic>>[];
      for (final img in imagenTienda) {
        if (img is Map<String, dynamic>) {
          final nuevaImagen = Map<String, dynamic>.from(img);
          // Transformar url_imagen
          final urlImagen = nuevaImagen['url_imagen'] as String?;
          if (urlImagen != null && urlImagen.contains('contabostorage.com')) {
            nuevaImagen['url_imagen'] = _transformContaboUrlToR2(urlImagen);
          }
          // Transformar url_original si existe
          final urlOriginal = nuevaImagen['url_original'] as String?;
          if (urlOriginal != null &&
              urlOriginal.contains('contabostorage.com')) {
            nuevaImagen['url_original'] = _transformContaboUrlToR2(urlOriginal);
          }
          nuevasImagenes.add(nuevaImagen);
        }
      }
      tienda['imagen_tienda'] = nuevasImagenes;
    } else if (imagenTienda is String &&
        imagenTienda.contains('contabostorage.com')) {
      // Es una URL directa
      tienda['imagen_tienda'] = _transformContaboUrlToR2(imagenTienda);
    }

    // Transformar logoUrl
    final logoUrl = tienda['logoUrl'] as String?;
    if (logoUrl != null && logoUrl.contains('contabostorage.com')) {
      tienda['logoUrl'] = _transformContaboUrlToR2(logoUrl);
    }

    // Transformar logo_url
    final logoUrlAlt = tienda['logo_url'] as String?;
    if (logoUrlAlt != null && logoUrlAlt.contains('contabostorage.com')) {
      tienda['logo_url'] = _transformContaboUrlToR2(logoUrlAlt);
    }

    // Transformar url_logo
    final urlLogo = tienda['url_logo'] as String?;
    if (urlLogo != null && urlLogo.contains('contabostorage.com')) {
      tienda['url_logo'] = _transformContaboUrlToR2(urlLogo);
    }

    // Transformar imagen (campo genérico)
    final imagen = tienda['imagen'] as String?;
    if (imagen != null && imagen.contains('contabostorage.com')) {
      tienda['imagen'] = _transformContaboUrlToR2(imagen);
    }

    // Transformar imágenes generales (array)
    final imagenes = tienda['imagenes'];
    if (imagenes is List) {
      final nuevasImagenes = <Map<String, dynamic>>[];
      for (final img in imagenes) {
        if (img is Map<String, dynamic>) {
          final nuevaImagen = Map<String, dynamic>.from(img);
          final urlImagen = nuevaImagen['url'] as String?;
          if (urlImagen != null && urlImagen.contains('contabostorage.com')) {
            nuevaImagen['url'] = _transformContaboUrlToR2(urlImagen);
          }
          final urlImagenAlt = nuevaImagen['url_imagen'] as String?;
          if (urlImagenAlt != null &&
              urlImagenAlt.contains('contabostorage.com')) {
            nuevaImagen['url_imagen'] = _transformContaboUrlToR2(urlImagenAlt);
          }
          nuevasImagenes.add(nuevaImagen);
        }
      }
      tienda['imagenes'] = nuevasImagenes;
    }
  }

  /// Transformar URL de Contabo a Cloudflare R2
  /// Ejemplo: https://usc1.contabostorage.com/paseocomercio/tiendas/1771270906396-92260709-large.png
  ///          → https://[cloudflareR2PublicUrl]/tiendas/1771270906396-92260709-large.png
  String _transformContaboUrlToR2(String contaboUrl) {
    try {
      if (_appConfig.cloudflareR2PublicUrl.isEmpty) {
        _logger.w('Cloudflare R2 no configurado, manteniendo URL original');
        return contaboUrl;
      }

      final uri = Uri.parse(contaboUrl);
      final pathSegments = uri.pathSegments;

      // Buscar el índice de 'paseocomercio' en la ruta
      final paseocomercioIndex = pathSegments.indexWhere(
        (segment) => segment == 'paseocomercio',
      );
      if (paseocomercioIndex == -1 ||
          paseocomercioIndex >= pathSegments.length - 1) {
        _logger.w('URL de Contabo no tiene formato esperado: $contaboUrl');
        return contaboUrl;
      }

      // Construir ruta relativa después de 'paseocomercio'
      final relativePath = pathSegments
          .sublist(paseocomercioIndex + 1)
          .join('/');

      // Normalizar URL base eliminando barra final si existe
      String baseUrl = _appConfig.cloudflareR2PublicUrl.trim();
      if (baseUrl.endsWith('/')) {
        baseUrl = baseUrl.substring(0, baseUrl.length - 1);
      }

      // Construir URL de R2
      final r2Url = '$baseUrl/$relativePath';

      return r2Url;
    } catch (e, stackTrace) {
      _logger.e(
        'Error transformando URL de Contabo a R2: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return contaboUrl;
    }
  }
}
