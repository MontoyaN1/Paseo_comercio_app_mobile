// lib/data/repositories/tienda_repository.dart

import 'dart:async';
import 'package:logger/logger.dart';

import '../../core/app/app_config.dart';
import '../datasources/remote/supabase_client.dart';
import '../datasources/local/local_database.dart';

/// Repositorio para manejar operaciones de tiendas
class TiendaRepository {
  final SupabaseClientService _supabaseClient;
  final LocalCacheService _localCache;
  final Logger _logger;

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

          // Actualizar en segundo plano
          _updateTiendasInBackground(
            page: page,
            limit: limit,
            categoriaId: categoriaId,
            soloActivas: soloActivas,
          );

          return cachedTiendas;
        }
      }

      _logger.d('Obteniendo tiendas desde Supabase...');
      final tiendas = await _supabaseClient.getTiendas(
        page: page,
        limit: limit,
        categoriaId: categoriaId,
        soloActivas: soloActivas,
      );

      if (tiendas.isNotEmpty) {
        // Guardar en caché
        await _localCache.cacheTiendas(
          tiendas,
          key: cacheKey,
          ttl: const Duration(hours: 1),
          priority: 1,
        );

        // Notificar a los listeners
        _tiendasController.add(tiendas);

        _logger.i('Tiendas obtenidas de Supabase: ${tiendas.length}');
      }

      return tiendas;
    } catch (e) {
      _logger.e('Error obteniendo tiendas: $e');

      // Si hay error, intentar obtener de caché aunque esté expirada
      if (!forceRefresh) {
        final cachedTiendas = await _localCache.getCachedTiendas(
          key: 'tiendas_page_${page}_limit_${limit}',
          checkExpiry: false,
        );
        if (cachedTiendas != null && cachedTiendas.isNotEmpty) {
          _logger.w(
            'Usando tiendas de caché (posiblemente expiradas) debido a error',
          );
          return cachedTiendas;
        }
      }

      return [];
    }
  }

  /// Obtener una tienda por ID
  Future<Map<String, dynamic>?> getTiendaById(
    int tiendaId, {
    bool forceRefresh = false,
  }) async {
    try {
      // Si no es forzado, intentar obtener de caché primero
      if (!forceRefresh) {
        final cachedTienda = await _localCache.getCachedTienda(tiendaId);
        if (cachedTienda != null) {
          _logger.d('Tienda $tiendaId obtenida de caché');

          // Actualizar en segundo plano
          _updateTiendaInBackground(tiendaId);

          return cachedTienda;
        }
      }

      _logger.d('Obteniendo tienda $tiendaId desde Supabase...');
      final response =
          await _supabaseClient.tiendas
              .select()
              .eq('id', tiendaId)
              .single()
              .execute();

      if (response.error != null) {
        _logger.e('Error obteniendo tienda: ${response.error}');
        return null;
      }

      final tienda = response.data as Map<String, dynamic>;

      // Guardar en caché
      await _localCache.cacheTienda(tienda);

      _logger.i('Tienda $tiendaId obtenida de Supabase');

      return tienda;
    } catch (e) {
      _logger.e('Error obteniendo tienda $tiendaId: $e');

      // Si hay error, intentar obtener de caché aunque esté expirada
      if (!forceRefresh) {
        final cachedTienda = await _localCache.getCachedTienda(tiendaId);
        if (cachedTienda != null) {
          _logger.w(
            'Usando tienda de caché (posiblemente expirada) debido a error',
          );
          return cachedTienda;
        }
      }

      return null;
    }
  }

  /// Obtener tiendas por propietario
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
      final response =
          await _supabaseClient.tiendas
              .select()
              .eq('id_propietario', propietarioId)
              .order('fecha_creacion', ascending: false)
              .range((page - 1) * limit, page * limit - 1)
              .execute();

      if (response.error != null) {
        _logger.e(
          'Error obteniendo tiendas del propietario: ${response.error}',
        );
        return [];
      }

      final data = response.data as List<dynamic>;
      final tiendas = data.map((item) => item as Map<String, dynamic>).toList();

      if (tiendas.isNotEmpty) {
        // Guardar en caché
        await _localCache.cacheTiendas(
          tiendas,
          key: cacheKey,
          ttl: const Duration(minutes: 30),
          priority: 2,
        );

        _logger.i(
          'Tiendas del propietario obtenidas de Supabase: ${tiendas.length}',
        );
      }

      return tiendas;
    } catch (e) {
      _logger.e('Error obteniendo tiendas del propietario $propietarioId: $e');
      return [];
    }
  }

  /// Buscar tiendas por término
  Future<List<Map<String, dynamic>>> searchTiendas(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      _logger.d('Buscando tiendas con query: "$query"');

      final response =
          await _supabaseClient.tiendas
              .select()
              .or('nombre_tienda.ilike.%$query%,descripcion.ilike.%$query%')
              .order('fecha_creacion', ascending: false)
              .range((page - 1) * limit, page * limit - 1)
              .execute();

      if (response.error != null) {
        _logger.e('Error buscando tiendas: ${response.error}');
        return [];
      }

      final data = response.data as List<dynamic>;
      final tiendas = data.map((item) => item as Map<String, dynamic>).toList();

      _logger.i('Tiendas encontradas: ${tiendas.length}');

      return tiendas;
    } catch (e) {
      _logger.e('Error buscando tiendas: $e');
      return [];
    }
  }

  /// Crear nueva tienda
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

      final response =
          await _supabaseClient.tiendas.insert(nuevaTienda).execute();

      if (response.error != null) {
        _logger.e('Error creando tienda: ${response.error}');
        return null;
      }

      final tiendaCreada = response.data as Map<String, dynamic>;

      // Guardar en caché
      await _localCache.cacheTienda(tiendaCreada);

      // Invalidar caché de listas de tiendas
      await _invalidateTiendasCache();

      // Notificar a los listeners
      _tiendasController.add([tiendaCreada]);

      _logger.i('Tienda creada exitosamente: ${tiendaCreada['id']}');

      return tiendaCreada;
    } catch (e) {
      _logger.e('Error creando tienda: $e');
      return null;
    }
  }

  /// Actualizar tienda
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

      final response =
          await _supabaseClient.tiendas
              .update(updates)
              .eq('id', tiendaId)
              .execute();

      if (response.error != null) {
        _logger.e('Error actualizando tienda: ${response.error}');
        return false;
      }

      // Actualizar caché
      final tiendaActual = await getTiendaById(tiendaId, forceRefresh: true);
      if (tiendaActual != null) {
        await _localCache.cacheTienda(tiendaActual);
      }

      // Invalidar caché de listas de tiendas
      await _invalidateTiendasCache();

      _logger.i('Tienda $tiendaId actualizada exitosamente');

      return true;
    } catch (e) {
      _logger.e('Error actualizando tienda $tiendaId: $e');
      return false;
    }
  }

  /// Eliminar tienda
  Future<bool> deleteTienda(int tiendaId) async {
    try {
      _logger.d('Eliminando tienda $tiendaId');

      final response =
          await _supabaseClient.tiendas.delete().eq('id', tiendaId).execute();

      if (response.error != null) {
        _logger.e('Error eliminando tienda: ${response.error}');
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

      final response =
          await _supabaseClient.tiendas
              .update({
                'total_visitas': totalVisitas,
                'fecha_ultima_visita': DateTime.now().toIso8601String(),
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', tiendaId)
              .execute();

      if (response.error != null) {
        _logger.e('Error registrando visita: ${response.error}');
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
  Future<List<Map<String, dynamic>>> getTiendasDestacadas({
    int limit = 10,
  }) async {
    try {
      _logger.d('Obteniendo tiendas destacadas');

      final response =
          await _supabaseClient.tiendas
              .select()
              .order('total_visitas', ascending: false)
              .limit(limit)
              .execute();

      if (response.error != null) {
        _logger.e('Error obteniendo tiendas destacadas: ${response.error}');
        return [];
      }

      final data = response.data as List<dynamic>;
      final tiendas = data.map((item) => item as Map<String, dynamic>).toList();

      // Guardar en caché
      await _localCache.cacheTiendas(
        tiendas,
        key: 'tiendas_destacadas',
        ttl: const Duration(hours: 2),
        priority: 3, // Alta prioridad para contenido destacado
      );

      _logger.i('Tiendas destacadas obtenidas: ${tiendas.length}');

      return tiendas;
    } catch (e) {
      _logger.e('Error obteniendo tiendas destacadas: $e');
      return [];
    }
  }

  /// Obtener stream de cambios en las tiendas
  Stream<List<Map<String, dynamic>>> get tiendasStream =>
      _tiendasController.stream;

  // ========== MÉTODOS PRIVADOS ==========

  /// Actualizar tiendas en segundo plano
  Future<void> _updateTiendasInBackground({
    int page = 1,
    int limit = 20,
    String? categoriaId,
    bool? soloActivas,
  }) async {
    try {
      final tiendas = await _supabaseClient.getTiendas(
        page: page,
        limit: limit,
        categoriaId: categoriaId,
        soloActivas: soloActivas,
      );

      if (tiendas.isNotEmpty) {
        final cacheKey =
            'tiendas_page_${page}_limit_${limit}'
            '${categoriaId != null ? '_cat_$categoriaId' : ''}'
            '${soloActivas == true ? '_activas' : ''}';

        await _localCache.cacheTiendas(
          tiendas,
          key: cacheKey,
          ttl: const Duration(hours: 1),
          priority: 1,
        );

        // Notificar a los listeners
        _tiendasController.add(tiendas);

        _logger.d('Tiendas actualizadas en segundo plano: ${tiendas.length}');
      }
    } catch (e) {
      _logger.d('Error actualizando tiendas en segundo plano: $e');
    }
  }

  /// Invalidar caché de listas de tiendas
  Future<void> _invalidateTiendasCache() async {
    try {
      // Eliminar todas las entradas de caché que comiencen con 'tiendas_'
      final keysToDelete = <String>[];

      for (final key in _localCache._tiendasBox.keys) {
        if (key is String && key.startsWith('tiendas_')) {
          keysToDelete.add(key);
        }
      }

      for (final key in keysToDelete) {
        await _localCache._tiendasBox.delete(key);
      }

      _logger.d(
        'Caché de tiendas invalidada: ${keysToDelete.length} entradas eliminadas',
      );
    } catch (e) {
      _logger.e('Error invalidando caché de tiendas: $e');
    }
  }

  /// Disposer para limpiar recursos
  void dispose() {
    _tiendasController.close();
    _logger.i('TiendaRepository disposed');
  }
}
