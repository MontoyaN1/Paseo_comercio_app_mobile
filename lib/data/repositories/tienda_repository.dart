// lib/data/repositories/tienda_repository.dart

import 'dart:async';
import 'package:logger/logger.dart';

import '../datasources/remote/supabase_client.dart';
import '../datasources/local/local_database.dart';
import '../../domain/repositories/tienda_repository_interface.dart';
import '../../core/utils/connectivity_service.dart';

/// Repositorio para manejar operaciones de tiendas
class TiendaRepository implements TiendaRepositoryInterface {
  final SupabaseClientService _supabaseClient;
  final LocalCacheService _localCache;
  final ConnectivityService _connectivityService;
  final Logger _logger;

  // Stream para notificar cambios en las tiendas
  final StreamController<List<Map<String, dynamic>>> _tiendasController =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  TiendaRepository({
    required SupabaseClientService supabaseClient,
    required LocalCacheService localCache,
    required ConnectivityService connectivityService,
  }) : _supabaseClient = supabaseClient,
       _localCache = localCache,
       _connectivityService = connectivityService,
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
          _logger.d('Tiendas obtenidas de caché: ${cachedTiendas.length}');
          return cachedTiendas;
        }
      }

      _logger.d('Obteniendo tiendas desde Supabase...');

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

      if (response == null) {
        _logger.e('Error obteniendo tiendas: response is null');
        return [];
      }

      if (response is! List) {
        _logger.e('Error obteniendo tiendas: response is not a List');
        return [];
      }

      final tiendas = response as List<dynamic>;
      final result = tiendas.whereType<Map<String, dynamic>>().toList();

      // Guardar en caché
      await _localCache.cacheTiendas(result, key: cacheKey);

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
      final cacheKey = 'tienda_$tiendaId';

      // Si no es forzado, intentar obtener de caché primero
      if (!forceRefresh) {
        final cachedTienda = await _localCache.getCachedTienda(tiendaId);
        if (cachedTienda != null) {
          _logger.d('Tienda obtenida de caché: $tiendaId');
          return cachedTienda;
        }
      }

      _logger.d('Obteniendo tienda $tiendaId desde Supabase...');

      final response = await _supabaseClient.tiendas
          .select()
          .eq('id', tiendaId)
          .limit(1);

      if (response == null || response.isEmpty) {
        _logger.w('Tienda no encontrada: $tiendaId');
        return null;
      }

      final tienda = response.first as Map<String, dynamic>?;

      if (tienda != null) {
        // Guardar en caché
        await _localCache.cacheTienda(tienda);
        _logger.i('Tienda obtenida: $tiendaId');
      }

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
      final cacheKey =
          'tiendas_prop_${propietarioId}_page_${page}_limit_${limit}';

      // Si no es forzado, intentar obtener de caché primero
      if (!forceRefresh) {
        final cachedTiendas = await _localCache.getCachedTiendas(key: cacheKey);
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

      if (response == null) {
        _logger.e('Error obteniendo tiendas del propietario');
        return [];
      }

      if (response is! List) {
        _logger.e(
          'Error obteniendo tiendas del propietario: response is not a List',
        );
        return [];
      }

      final tiendas = response as List<dynamic>;
      final result = tiendas.whereType<Map<String, dynamic>>().toList();

      // Guardar en caché
      await _localCache.cacheTiendas(result, key: cacheKey);

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
      _logger.d('Buscando tiendas con query: "$query"');

      final response = await _supabaseClient.tiendas
          .select()
          .ilike('nombre_tienda', '%$query%')
          .order('fecha_creacion', ascending: false)
          .limit(limit);

      if (response == null) {
        _logger.e('Error buscando tiendas');
        return [];
      }

      if (response is! List) {
        _logger.e('Error buscando tiendas: response is not a List');
        return [];
      }

      final tiendas = response as List<dynamic>;
      final result = tiendas.whereType<Map<String, dynamic>>().toList();

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
      _logger.d('Creando nueva tienda: $nombreTienda');

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

      if (response == null) {
        _logger.e('Error creando tienda: response is null');
        return null;
      }

      final tiendaCreada = response as Map<String, dynamic>?;

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
      _logger.d('Actualizando tienda $tiendaId');

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
      _logger.d('Eliminando tienda $tiendaId');

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
      _logger.d('Registrando visita a tienda $tiendaId');

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
      _logger.d('Obteniendo tiendas destacadas');

      final response = await _supabaseClient.tiendas
          .select()
          .order('total_visitas', ascending: false)
          .limit(limit);

      if (response == null) {
        _logger.e('Error obteniendo tiendas destacadas');
        return [];
      }

      if (response is! List) {
        _logger.e(
          'Error obteniendo tiendas destacadas: response is not a List',
        );
        return [];
      }

      final tiendas = response as List<dynamic>;
      final result = tiendas.whereType<Map<String, dynamic>>().toList();

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
      _logger.d('Caché de tiendas invalidada');
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
}
