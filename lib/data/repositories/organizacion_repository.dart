// lib/data/repositories/organizacion_repository.dart

import 'dart:async';
import 'package:logger/logger.dart';

import '../datasources/remote/supabase_client.dart';
import '../datasources/local/local_database.dart';
import '../../domain/repositories/organizacion_repository_interface.dart';
import '../../domain/entities/organizacion.dart';
import '../../domain/entities/enums.dart';

/// Repositorio para manejar operaciones de organizaciones
class OrganizacionRepository implements OrganizacionRepositoryInterface {
  final SupabaseClientService _supabaseClient;
  final LocalCacheService _localCache;
  final Logger _logger;

  // Stream para notificar cambios en las organizaciones
  final StreamController<List<Organizacion>> _organizacionesController =
      StreamController<List<Organizacion>>.broadcast();

  OrganizacionRepository({
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

  // ==============================================
  // MÉTODOS DE CONSULTA
  // ==============================================

  /// Obtener todas las organizaciones con estrategia cache-first
  @override
  Future<List<Organizacion>> getOrganizaciones({
    int page = 1,
    int limit = 20,
    TipoOrganizacion? tipo,
    bool? soloActivas,
    String? sortBy,
    bool? ascending,
  }) async {
    try {
      final cacheKey =
          'organizaciones_page_${page}_limit_${limit}'
          '${tipo != null ? '_tipo_${tipo.value}' : ''}'
          '${soloActivas == true ? '_activas' : ''}'
          '${sortBy != null ? '_sort_$sortBy' : ''}'
          '${ascending != null ? '_asc_$ascending' : ''}';

      // Intentar obtener del cache primero
      final cachedData = await _localCache.get(cacheKey) as List<dynamic>?;
      if (cachedData != null && cachedData.isNotEmpty) {
        _logger.i('Organizaciones obtenidas del cache: $cacheKey');
        return cachedData
            .map((json) => Organizacion.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      // Construir query para Supabase con imágenes y contadores
      final response =
          tipo != null
              ? await _supabaseClient.organizaciones
                  .select('''
                    *,
                    imagen_organizacion!left(
                      url_imagen,
                      tipo_imagen
                    ),
                    tiendas:tienda!left(count),
                    miembros:miembros_organizacion!left(count)
                  ''')
                  .eq('tipo', tipo.value)
                  .order('created_at', ascending: false)
                  .range((page - 1) * limit, page * limit - 1)
              : await _supabaseClient.organizaciones
                  .select('''
                    *,
                    imagen_organizacion!left(
                      url_imagen,
                      tipo_imagen
                    ),
                    tiendas:tienda!left(count),
                    miembros:miembros_organizacion!left(count)
                  ''')
                  .order('created_at', ascending: false)
                  .range((page - 1) * limit, page * limit - 1);

      if (response.isEmpty) {
        return [];
      }

      if (response.isEmpty) {
        return [];
      }

      // Convertir a entidades
      final organizaciones =
          response.map((json) => Organizacion.fromJson(json)).toList();

      // Aplicar filtro de activas localmente si es necesario
      if (soloActivas == true) {
        final organizacionesFiltradas =
            organizaciones.where((org) => org.estaActiva).toList();

        // Guardar en cache
        final jsonList =
            organizacionesFiltradas.map((org) => org.toJson()).toList();
        await _localCache.set(cacheKey, jsonList);

        return organizacionesFiltradas;
      }

      // Guardar en cache
      final jsonList = organizaciones.map((org) => org.toJson()).toList();
      await _localCache.set(cacheKey, jsonList);

      return organizaciones;
    } catch (error, stackTrace) {
      _logger.e(
        'Error al obtener organizaciones',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Obtener organización por ID
  @override
  Future<Organizacion> getOrganizacionById(int id) async {
    try {
      final cacheKey = 'organizacion_$id';

      // Intentar obtener del cache primero
      final cachedData =
          await _localCache.get(cacheKey) as Map<String, dynamic>?;
      if (cachedData != null) {
        _logger.i('Organización $id obtenida del cache');
        return Organizacion.fromJson(cachedData);
      }

      // Obtener de Supabase con imágenes y contadores
      final response =
          await _supabaseClient.organizaciones
              .select('''
                *,
                imagen_organizacion!left(
                  url_imagen,
                  tipo_imagen
                ),
                tiendas:tienda!left(count),
                miembros:miembros_organizacion!left(count)
              ''')
              .eq('id', id)
              .single();

      // response no puede ser null con single()

      // Convertir a entidad
      final organizacion = Organizacion.fromJson(response);

      // Guardar en cache
      await _localCache.set(cacheKey, organizacion.toJson());

      return organizacion;
    } catch (error, stackTrace) {
      _logger.e(
        'Error al obtener organización por ID: $id',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Buscar organizaciones por query
  @override
  Future<List<Organizacion>> searchOrganizaciones(String query) async {
    try {
      if (query.isEmpty) {
        return [];
      }

      final cacheKey = 'organizaciones_search_${query.toLowerCase()}';

      // Intentar obtener del cache primero
      final cachedData = await _localCache.get(cacheKey) as List<dynamic>?;
      if (cachedData != null && cachedData.isNotEmpty) {
        _logger.i('Resultados de búsqueda obtenidos del cache: $query');
        return cachedData
            .map((json) => Organizacion.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      // Buscar en Supabase (búsqueda en nombre y descripción)
      // Obtener de Supabase con imágenes y contadores
      final response = await _supabaseClient.organizaciones
          .select('''
            *,
            imagen_organizacion!left(
              url_imagen,
              tipo_imagen
            ),
            tiendas:tienda!left(count),
            miembros:miembros_organizacion!left(count)
          ''')
          .or(
            'nombre.ilike.%$query%,descripcion.ilike.%$query%,email_anfitrion.ilike.%$query%',
          )
          .limit(50);

      if (response.isEmpty) {
        return [];
      }

      if (response.isEmpty) {
        return [];
      }

      // Convertir a entidades
      final organizaciones =
          response.map((json) => Organizacion.fromJson(json)).toList();

      // Guardar en cache
      final jsonList = organizaciones.map((org) => org.toJson()).toList();
      await _localCache.set(cacheKey, jsonList);

      return organizaciones;
    } catch (error, stackTrace) {
      _logger.e(
        'Error al buscar organizaciones: $query',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Obtener organizaciones por anfitrión
  @override
  Future<List<Organizacion>> getOrganizacionesByAnfitrionId(
    int anfitrionId,
  ) async {
    try {
      final cacheKey = 'organizaciones_anfitrion_$anfitrionId';

      // Intentar obtener del cache primero
      final cachedData = await _localCache.get(cacheKey) as List<dynamic>?;
      if (cachedData != null && cachedData.isNotEmpty) {
        return cachedData
            .map((json) => Organizacion.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      // Obtener de Supabase con imágenes y contadores
      final response = await _supabaseClient.organizaciones
          .select('''
            *,
            imagen_organizacion!left(
              url_imagen,
              tipo_imagen
            ),
            tiendas:tienda!left(count),
            miembros:miembros_organizacion!left(count)
          ''')
          .eq('anfitrion_id', anfitrionId)
          .order('created_at', ascending: false);

      if (response.isEmpty) {
        return [];
      }

      if (response.isEmpty) {
        return [];
      }

      // Convertir a entidades
      final organizaciones =
          response.map((json) => Organizacion.fromJson(json)).toList();

      // Guardar en cache
      final jsonList = organizaciones.map((org) => org.toJson()).toList();
      await _localCache.set(cacheKey, jsonList);

      return organizaciones;
    } catch (error, stackTrace) {
      _logger.e(
        'Error al obtener organizaciones por anfitrión: $anfitrionId',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Obtener organizaciones por tipo
  @override
  Future<List<Organizacion>> getOrganizacionesByTipo(
    TipoOrganizacion tipo,
  ) async {
    try {
      final cacheKey = 'organizaciones_tipo_${tipo.value}';

      // Intentar obtener del cache primero
      final cachedData = await _localCache.get(cacheKey) as List<dynamic>?;
      if (cachedData != null && cachedData.isNotEmpty) {
        return cachedData
            .map((json) => Organizacion.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      // Obtener de Supabase con imágenes y contadores
      final response = await _supabaseClient.organizaciones
          .select('''
            *,
            imagen_organizacion!left(
              url_imagen,
              tipo_imagen
            ),
            tiendas:tienda!left(count),
            miembros:miembros_organizacion!left(count)
          ''')
          .eq('tipo', tipo.value)
          .order('created_at', ascending: false)
          .limit(100);

      if (response.isEmpty) {
        return [];
      }

      if (response.isEmpty) {
        return [];
      }

      // Convertir a entidades
      final organizaciones =
          response.map((json) => Organizacion.fromJson(json)).toList();

      // Guardar en cache
      final jsonList = organizaciones.map((org) => org.toJson()).toList();
      await _localCache.set(cacheKey, jsonList);

      return organizaciones;
    } catch (error, stackTrace) {
      _logger.e(
        'Error al obtener organizaciones por tipo: ${tipo.value}',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Obtener organizaciones populares
  @override
  Future<List<Organizacion>> getOrganizacionesPopulares({
    int limit = 10,
  }) async {
    try {
      final cacheKey = 'organizaciones_populares_$limit';

      // Intentar obtener del cache primero
      final cachedData = await _localCache.get(cacheKey) as List<dynamic>?;
      if (cachedData != null && cachedData.isNotEmpty) {
        return cachedData
            .map((json) => Organizacion.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      // Nota: Esta consulta asume que hay una tabla de estadísticas o visitas
      // Por ahora, devolvemos las más recientes como placeholder
      final response = await _supabaseClient.organizaciones
          .select('*')
          .order('created_at', ascending: false)
          .limit(limit);

      if (response.isEmpty) {
        return [];
      }

      if (response.isEmpty) {
        return [];
      }

      // Convertir a entidades
      final organizaciones =
          response.map((json) => Organizacion.fromJson(json)).toList();

      // Guardar en cache
      final jsonList = organizaciones.map((org) => org.toJson()).toList();
      await _localCache.set(cacheKey, jsonList);

      return organizaciones;
    } catch (error, stackTrace) {
      _logger.e(
        'Error al obtener organizaciones populares',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Obtener organizaciones recientes
  @override
  Future<List<Organizacion>> getOrganizacionesRecientes({
    int limit = 10,
  }) async {
    try {
      final cacheKey = 'organizaciones_recientes_$limit';

      // Intentar obtener del cache primero
      final cachedData = await _localCache.get(cacheKey) as List<dynamic>?;
      if (cachedData != null && cachedData.isNotEmpty) {
        return cachedData
            .map((json) => Organizacion.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      // Obtener de Supabase con imágenes y contadores
      final response = await _supabaseClient.organizaciones
          .select('''
            *,
            imagen_organizacion!left(
              url_imagen,
              tipo_imagen
            ),
            tiendas:tienda!left(count),
            miembros:miembros_organizacion!left(count)
          ''')
          .order('created_at', ascending: false)
          .limit(limit);

      if (response.isEmpty) {
        return [];
      }

      if (response.isEmpty) {
        return [];
      }

      // Convertir a entidades
      final organizaciones =
          response.map((json) => Organizacion.fromJson(json)).toList();

      // Guardar en cache
      final jsonList = organizaciones.map((org) => org.toJson()).toList();
      await _localCache.set(cacheKey, jsonList);

      return organizaciones;
    } catch (error, stackTrace) {
      _logger.e(
        'Error al obtener organizaciones recientes',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // ==============================================
  // MÉTODOS DE GESTIÓN DE MIEMBROS
  // ==============================================

  /// Obtener miembros de una organización
  @override
  Future<List<Map<String, dynamic>>> getMiembrosByOrganizacionId(
    int organizacionId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final cacheKey =
          'organizacion_${organizacionId}_miembros_page_${page}_limit_$limit';

      // Intentar obtener del cache primero
      final cachedData = await _localCache.get(cacheKey) as List<dynamic>?;
      if (cachedData != null && cachedData.isNotEmpty) {
        return cachedData.cast<Map<String, dynamic>>();
      }

      // Obtener de Supabase
      final response = await _supabaseClient.client
          .from('miembros_organizacion')
          .select('''
            *,
            usuario:usuario_id(*)
          ''')
          .eq('organizacion_id', organizacionId)
          .order('created_at', ascending: false)
          .range((page - 1) * limit, page * limit - 1);

      if (response.isEmpty) {
        return [];
      }

      if (response.isEmpty) {
        return [];
      }

      // Guardar en cache
      await _localCache.set(cacheKey, response);

      return response.cast<Map<String, dynamic>>();
    } catch (error, stackTrace) {
      _logger.e(
        'Error al obtener miembros de organización: $organizacionId',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Unirse a una organización
  @override
  Future<void> joinOrganizacion({
    required int organizacionId,
    required int usuarioId,
    required String email,
    required String nombre,
  }) async {
    try {
      // Verificar si ya es miembro
      final esMiembro = await isUsuarioMiembro(
        organizacionId: organizacionId,
        usuarioId: usuarioId,
      );

      if (esMiembro) {
        throw Exception('Ya eres miembro de esta organización');
      }

      // Insertar en la tabla de miembros
      await _supabaseClient.client.from('miembros_organizacion').insert({
        'organizacion_id': organizacionId,
        'usuario_id': usuarioId,
        'email': email,
        'nombre': nombre,
        'estado': 'Activo',
        'rol_id': 3, // Rol por defecto: miembro
      });

      // Limpiar cache relacionado
      await _clearRelatedCache(organizacionId);

      _logger.i('Usuario $usuarioId se unió a organización $organizacionId');
    } catch (error, stackTrace) {
      _logger.e(
        'Error al unirse a organización: $organizacionId',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Salir de una organización
  @override
  Future<void> leaveOrganizacion({
    required int organizacionId,
    required int usuarioId,
  }) async {
    try {
      // Verificar si es miembro
      final esMiembro = await isUsuarioMiembro(
        organizacionId: organizacionId,
        usuarioId: usuarioId,
      );

      if (!esMiembro) {
        throw Exception('No eres miembro de esta organización');
      }

      // Eliminar de la tabla de miembros
      await _supabaseClient.client
          .from('miembros_organizacion')
          .delete()
          .eq('organizacion_id', organizacionId)
          .eq('usuario_id', usuarioId);

      // Limpiar cache relacionado
      await _clearRelatedCache(organizacionId);

      _logger.i('Usuario $usuarioId salió de organización $organizacionId');
    } catch (error, stackTrace) {
      _logger.e(
        'Error al salir de organización: $organizacionId',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Verificar si usuario es miembro
  @override
  Future<bool> isUsuarioMiembro({
    required int organizacionId,
    required int usuarioId,
  }) async {
    try {
      final response =
          await _supabaseClient.client
              .from('miembros_organizacion')
              .select('id')
              .eq('organizacion_id', organizacionId)
              .eq('usuario_id', usuarioId)
              .eq('estado', 'Activo')
              .maybeSingle();

      return response != null;
    } catch (error, stackTrace) {
      _logger.e(
        'Error al verificar membresía',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Obtener organizaciones del usuario
  @override
  Future<List<Organizacion>> getOrganizacionesByUsuarioId(int usuarioId) async {
    try {
      final cacheKey = 'organizaciones_usuario_$usuarioId';

      // Intentar obtener del cache primero
      final cachedData = await _localCache.get(cacheKey) as List<dynamic>?;
      if (cachedData != null && cachedData.isNotEmpty) {
        return cachedData
            .map((json) => Organizacion.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      // Obtener organizaciones donde el usuario es anfitrión con imágenes y contadores
      final responseAnfitrion = await _supabaseClient.organizaciones
          .select('''
            *,
            imagen_organizacion!left(
              url_imagen,
              tipo_imagen
            ),
            tiendas:tienda!left(count),
            miembros:miembros_organizacion!left(count)
          ''')
          .eq('anfitrion_id', usuarioId)
          .order('created_at', ascending: false);

      // Obtener organizaciones donde el usuario es miembro con imágenes y contadores
      final responseMiembro = await _supabaseClient.client
          .from('miembros_organizacion')
          .select(
            'organizacion:organizacion_id(*, imagen_organizacion!left(url_imagen, tipo_imagen), tiendas:tienda!left(count), miembros:miembros_organizacion!left(count))',
          )
          .eq('usuario_id', usuarioId)
          .eq('estado', 'Activo');

      // Combinar resultados
      final organizaciones = <Organizacion>[];

      if (responseAnfitrion.isNotEmpty) {
        organizaciones.addAll(
          responseAnfitrion.map((json) => Organizacion.fromJson(json)),
        );
      }

      if (responseMiembro.isNotEmpty) {
        for (final item in responseMiembro) {
          if (item['organizacion'] != null) {
            organizaciones.add(Organizacion.fromJson(item['organizacion']));
          }
        }
      }

      // Eliminar duplicados
      final organizacionesUnicas =
          organizaciones
              .fold<Map<int, Organizacion>>({}, (map, org) {
                map[org.id] = org;
                return map;
              })
              .values
              .toList();

      // Ordenar por fecha de creación
      organizacionesUnicas.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Guardar en cache
      final jsonList = organizacionesUnicas.map((org) => org.toJson()).toList();
      await _localCache.set(cacheKey, jsonList);

      return organizacionesUnicas;
    } catch (error, stackTrace) {
      _logger.e(
        'Error al obtener organizaciones del usuario: $usuarioId',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // ==============================================
  // MÉTODOS DE GESTIÓN DE TIENDAS
  // ==============================================

  /// Obtener tiendas de una organización
  @override
  Future<List<Map<String, dynamic>>> getTiendasByOrganizacionId(
    int organizacionId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final cacheKey =
          'organizacion_${organizacionId}_tiendas_page_${page}_limit_$limit';

      // Intentar obtener del cache primero
      final cachedData = await _localCache.get(cacheKey) as List<dynamic>?;
      if (cachedData != null && cachedData.isNotEmpty) {
        return cachedData.cast<Map<String, dynamic>>();
      }

      // Obtener de Supabase
      final response = await _supabaseClient.tiendas
          .select('''
            *,
            imagen_tienda!left(*)
          ''')
          .eq('organizacion_id', organizacionId)
          .order('fecha_creacion', ascending: false)
          .range((page - 1) * limit, page * limit - 1);

      if (response.isEmpty) {
        return [];
      }

      if (response.isEmpty) {
        return [];
      }

      // Guardar en cache
      await _localCache.set(cacheKey, response);

      return response.cast<Map<String, dynamic>>();
    } catch (error, stackTrace) {
      _logger.e(
        'Error al obtener tiendas de organización: $organizacionId',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Agregar tienda a organización
  @override
  Future<void> addTiendaToOrganizacion({
    required int organizacionId,
    required int tiendaId,
  }) async {
    try {
      // Verificar si la tienda ya pertenece a la organización
      final pertenece = await isTiendaInOrganizacion(
        organizacionId: organizacionId,
        tiendaId: tiendaId,
      );

      if (pertenece) {
        throw Exception('La tienda ya pertenece a esta organización');
      }

      // Actualizar tienda para asignarla a la organización
      await _supabaseClient.tiendas
          .update({'organizacion_id': organizacionId})
          .eq('id', tiendaId);

      // Limpiar cache relacionado
      await _clearRelatedCache(organizacionId);

      _logger.i('Tienda $tiendaId agregada a organización $organizacionId');
    } catch (error, stackTrace) {
      _logger.e(
        'Error al agregar tienda a organización',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Remover tienda de organización
  @override
  Future<void> removeTiendaFromOrganizacion({
    required int organizacionId,
    required int tiendaId,
  }) async {
    try {
      // Verificar si la tienda pertenece a la organización
      final pertenece = await isTiendaInOrganizacion(
        organizacionId: organizacionId,
        tiendaId: tiendaId,
      );

      if (!pertenece) {
        throw Exception('La tienda no pertenece a esta organización');
      }

      // Actualizar tienda para removerla de la organización
      await _supabaseClient.tiendas
          .update({'organizacion_id': null})
          .eq('id', tiendaId);

      // Limpiar cache relacionado
      await _clearRelatedCache(organizacionId);

      _logger.i('Tienda $tiendaId removida de organización $organizacionId');
    } catch (error, stackTrace) {
      _logger.e(
        'Error al remover tienda de organización',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Verificar si tienda pertenece a organización
  @override
  Future<bool> isTiendaInOrganizacion({
    required int organizacionId,
    required int tiendaId,
  }) async {
    try {
      final response =
          await _supabaseClient.tiendas
              .select('id')
              .eq('id', tiendaId)
              .eq('organizacion_id', organizacionId)
              .maybeSingle();

      return response != null;
    } catch (error, stackTrace) {
      _logger.e(
        'Error al verificar pertenencia de tienda',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  // ==============================================
  // MÉTODOS CRUD
  // ==============================================

  /// Crear nueva organización
  @override
  Future<Organizacion> createOrganizacion({
    required String nombre,
    String? descripcion,
    required TipoOrganizacion tipo,
    required String emailAnfitrion,
    required int anfitrionId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Validar datos
      await validateOrganizacionData(
        nombre: nombre,
        emailAnfitrion: emailAnfitrion,
        tipo: tipo,
      );

      // Crear en Supabase
      final response =
          await _supabaseClient.client
              .from('organizacion')
              .insert({
                'nombre': nombre,
                'descripcion': descripcion,
                'tipo': tipo.value,
                'email_anfitrion': emailAnfitrion,
                'anfitrion_id': anfitrionId,
                'metadata': metadata,
              })
              .select()
              .single();

      if (response.isEmpty) {
        throw Exception('Error al crear organización');
      }

      // Convertir a entidad
      final organizacion = Organizacion.fromJson(response);

      // Limpiar cache
      await clearCache();

      _logger.i(
        'Organización creada: ${organizacion.id} - ${organizacion.nombre}',
      );

      return organizacion;
    } catch (error, stackTrace) {
      _logger.e(
        'Error al crear organización',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Actualizar organización existente
  @override
  Future<Organizacion> updateOrganizacion({
    required int id,
    String? nombre,
    String? descripcion,
    TipoOrganizacion? tipo,
    String? emailAnfitrion,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Validar datos si se proporcionan
      if (nombre != null || emailAnfitrion != null || tipo != null) {
        await validateOrganizacionData(
          nombre: nombre,
          emailAnfitrion: emailAnfitrion,
          tipo: tipo,
        );
      }

      // Preparar datos para actualizar
      final updateData = <String, dynamic>{};
      if (nombre != null) updateData['nombre'] = nombre;
      if (descripcion != null) updateData['descripcion'] = descripcion;
      if (tipo != null) updateData['tipo'] = tipo.value;
      if (emailAnfitrion != null)
        updateData['email_anfitrion'] = emailAnfitrion;
      if (metadata != null) updateData['metadata'] = metadata;

      if (updateData.isEmpty) {
        throw Exception('No hay datos para actualizar');
      }

      // Actualizar en Supabase
      final response =
          await _supabaseClient.organizaciones
              .update(updateData)
              .eq('id', id)
              .select()
              .single();

      if (response.isEmpty) {
        throw Exception('Error al actualizar organización');
      }

      // Convertir a entidad
      final organizacion = Organizacion.fromJson(response);

      // Limpiar cache relacionado
      await _clearRelatedCache(id);

      _logger.i('Organización actualizada: $id');

      return organizacion;
    } catch (error, stackTrace) {
      _logger.e(
        'Error al actualizar organización: $id',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Eliminar organización
  @override
  Future<void> deleteOrganizacion(int id) async {
    try {
      // Verificar si la organización existe
      final organizacion = await getOrganizacionById(id);

      // Verificar si tiene tiendas asociadas
      final tiendas = await getTiendasByOrganizacionId(id, limit: 1);
      if (tiendas.isNotEmpty) {
        throw Exception(
          'No se puede eliminar una organización con tiendas asociadas',
        );
      }

      // Eliminar de Supabase
      await _supabaseClient.organizaciones.delete().eq('id', id);

      // Limpiar cache
      await clearCache();

      _logger.i('Organización eliminada: $id - ${organizacion.nombre}');
    } catch (error, stackTrace) {
      _logger.e(
        'Error al eliminar organización: $id',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // ==============================================
  // MÉTODOS DE ESTADÍSTICAS
  // ==============================================

  /// Obtener estadísticas de una organización
  @override
  Future<Map<String, dynamic>> getOrganizacionStats(
    int organizacionId, {
    DateTime? desde,
    DateTime? hasta,
  }) async {
    try {
      final cacheKey =
          'organizacion_${organizacionId}_stats'
          '${desde != null ? '_desde_${desde.toIso8601String()}' : ''}'
          '${hasta != null ? '_hasta_${hasta.toIso8601String()}' : ''}';

      // Intentar obtener del cache primero
      final cachedData =
          await _localCache.get(cacheKey) as Map<String, dynamic>?;
      if (cachedData != null) {
        return cachedData;
      }

      // Obtener estadísticas básicas
      final stats = <String, dynamic>{};

      // Contar tiendas
      final tiendasResponse = await _supabaseClient.tiendas
          .select('*')
          .eq('organizacion_id', organizacionId);

      stats['total_tiendas'] = tiendasResponse.length;

      // Contar miembros activos (incluyendo al anfitrión)
      final miembrosResponse = await _supabaseClient.client
          .from('miembros_organizacion')
          .select('*')
          .eq('organizacion_id', organizacionId)
          .eq('estado', 'Activo');

      stats['total_miembros'] =
          miembrosResponse.length + 1; // +1 por el anfitrión

      // Nota: Las organizaciones no tienen estadísticas de visitas en la tabla estadisticas_diarias
      // Las estadísticas de visitas son solo para tiendas
      stats['total_visitas'] = 0;
      stats['total_clicks_whatsapp'] = 0;
      stats['total_compartidos'] = 0;
      stats['total_visualizaciones'] = 0;

      // Agregar timestamp
      stats['fecha_actualizacion'] = DateTime.now().toIso8601String();

      // Agregar timestamp
      stats['fecha_actualizacion'] = DateTime.now().toIso8601String();

      // Guardar en cache
      await _localCache.set(cacheKey, stats);

      return stats;
    } catch (error, stackTrace) {
      _logger.e(
        'Error al obtener estadísticas de organización: $organizacionId',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Obtener estadísticas globales de organizaciones
  @override
  Future<Map<String, dynamic>> getGlobalOrganizacionStats() async {
    try {
      final cacheKey = 'organizaciones_global_stats';

      // Intentar obtener del cache primero
      final cachedData =
          await _localCache.get(cacheKey) as Map<String, dynamic>?;
      if (cachedData != null) {
        return cachedData;
      }

      final stats = <String, dynamic>{};

      // Contar total de organizaciones
      final totalResponse = await _supabaseClient.organizaciones.select('*');

      stats['total_organizaciones'] = totalResponse.length;

      // Contar por tipo
      final tiposResponse = await _supabaseClient.organizaciones.select('tipo');

      final conteoTipos = <String, int>{};
      for (final item in tiposResponse) {
        final tipo = item['tipo'] as String;
        conteoTipos[tipo] = (conteoTipos[tipo] ?? 0) + 1;
      }

      stats['conteo_por_tipo'] = conteoTipos;

      // Obtener organización más reciente
      final recienteResponse =
          await _supabaseClient.organizaciones
              .select('*')
              .order('created_at', ascending: false)
              .limit(1)
              .single();

      if (recienteResponse.isNotEmpty) {
        stats['organizacion_mas_reciente'] =
            Organizacion.fromJson(recienteResponse).toJson();
      }

      // Agregar timestamp
      stats['fecha_actualizacion'] = DateTime.now().toIso8601String();

      // Guardar en cache
      await _localCache.set(cacheKey, stats);

      return stats;
    } catch (error, stackTrace) {
      _logger.e(
        'Error al obtener estadísticas globales de organizaciones',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Incrementar contador de visitas
  @override
  Future<void> incrementVisitas(int organizacionId) async {
    try {
      // Esta función sería llamada cuando un usuario ve una organización
      // Por ahora, solo registramos en logs
      _logger.i('Visita registrada para organización: $organizacionId');

      // En una implementación real, actualizaríamos una tabla de estadísticas
      // await _supabaseClient.client
      //     .from('organizacion_visitas')
      //     .insert({
      //       'organizacion_id': organizacionId,
      //       'fecha': DateTime.now().toIso8601String(),
      //     });
    } catch (error, stackTrace) {
      _logger.e(
        'Error al incrementar visitas para organización: $organizacionId',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Marcar organización como vista
  @override
  Future<void> markAsViewed(int organizacionId) async {
    try {
      // Esta función sería llamada cuando un usuario ve el detalle de una organización
      _logger.i('Organización marcada como vista: $organizacionId');

      // Podríamos actualizar un campo en la organización o crear un registro de visualización
      // Por ahora, solo registramos en logs
    } catch (error, stackTrace) {
      _logger.e(
        'Error al marcar organización como vista: $organizacionId',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  // ==============================================
  // MÉTODOS DE VALIDACIÓN
  // ==============================================

  /// Verificar si nombre de organización está disponible
  @override
  Future<bool> isNombreDisponible(String nombre) async {
    try {
      if (nombre.isEmpty) {
        return false;
      }

      final response =
          await _supabaseClient.client
              .from('organizacion')
              .select('id')
              .eq('nombre', nombre)
              .maybeSingle();

      return response == null;
    } catch (error, stackTrace) {
      _logger.e(
        'Error al verificar disponibilidad de nombre: $nombre',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Verificar si email de anfitrión es válido
  @override
  Future<bool> isValidEmailAnfitrion(String email) async {
    try {
      if (email.isEmpty || !email.contains('@')) {
        return false;
      }

      // Verificar formato básico de email
      final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      );
      if (!emailRegex.hasMatch(email)) {
        return false;
      }

      // Podríamos verificar si el email existe en la tabla de usuarios
      // Por ahora, solo validamos formato
      return true;
    } catch (error, stackTrace) {
      _logger.e(
        'Error al validar email de anfitrión: $email',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Validar datos de organización antes de crear/actualizar
  @override
  Future<Map<String, dynamic>> validateOrganizacionData({
    String? nombre,
    String? emailAnfitrion,
    TipoOrganizacion? tipo,
  }) async {
    final errores = <String, String>{};
    final warnings = <String, String>{};

    try {
      // Validar nombre
      if (nombre != null && nombre.isNotEmpty) {
        final disponible = await isNombreDisponible(nombre);
        if (!disponible) {
          errores['nombre'] = 'Este nombre de organización ya está en uso';
        }

        if (nombre.length < 3) {
          errores['nombre'] = 'El nombre debe tener al menos 3 caracteres';
        }

        if (nombre.length > 100) {
          warnings['nombre'] = 'El nombre es muy largo, considera abreviarlo';
        }
      }

      // Validar email
      if (emailAnfitrion != null && emailAnfitrion.isNotEmpty) {
        final valido = await isValidEmailAnfitrion(emailAnfitrion);
        if (!valido) {
          errores['email_anfitrion'] = 'El email del anfitrión no es válido';
        }
      }

      // Validar tipo
      if (tipo != null) {
        if (!TipoOrganizacion.values.contains(tipo)) {
          errores['tipo'] = 'Tipo de organización no válido';
        }
      }

      return {
        'valido': errores.isEmpty,
        'errores': errores,
        'warnings': warnings,
      };
    } catch (error, stackTrace) {
      _logger.e(
        'Error al validar datos de organización',
        error: error,
        stackTrace: stackTrace,
      );
      return {
        'valido': false,
        'errores': {'general': 'Error al validar datos: ${error.toString()}'},
        'warnings': {},
      };
    }
  }

  // ==============================================
  // MÉTODOS DE CACHE Y SINCRONIZACIÓN
  // ==============================================

  /// Sincronizar organizaciones con servidor
  @override
  Future<void> syncOrganizaciones() async {
    try {
      _logger.i('Iniciando sincronización de organizaciones');

      // Obtener datos más recientes del servidor
      final organizacionesActualizadas = await getOrganizaciones(
        page: 1,
        limit: 100,
      );

      // Notificar a los listeners
      _organizacionesController.add(organizacionesActualizadas);

      // Actualizar timestamp de última sincronización
      await _localCache.set(
        'organizaciones_last_sync',
        DateTime.now().toIso8601String(),
      );

      _logger.i(
        'Sincronización de organizaciones completada: ${organizacionesActualizadas.length} organizaciones',
      );
    } catch (error, stackTrace) {
      _logger.e(
        'Error al sincronizar organizaciones',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Limpiar cache local de organizaciones
  @override
  Future<void> clearCache() async {
    try {
      // Eliminar todas las claves relacionadas con organizaciones
      await _localCache.clearAllCache();

      _logger.i('Cache de organizaciones limpiado');
    } catch (error, stackTrace) {
      _logger.e(
        'Error al limpiar cache de organizaciones',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Verificar si hay datos en cache
  @override
  Future<bool> hasCachedData() async {
    try {
      // Por ahora, retornar false ya que no hay un método getAllKeys
      return false;
    } catch (error, stackTrace) {
      _logger.e(
        'Error al verificar cache de organizaciones',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Obtener timestamp de última sincronización
  @override
  Future<DateTime?> getLastSyncTimestamp() async {
    try {
      final timestamp =
          await _localCache.get('organizaciones_last_sync') as String?;
      if (timestamp != null) {
        return DateTime.parse(timestamp);
      }
      return null;
    } catch (error, stackTrace) {
      _logger.e(
        'Error al obtener timestamp de última sincronización',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  // ==============================================
  // MÉTODOS AUXILIARES PRIVADOS
  // ==============================================

  /// Limpiar cache relacionado con una organización específica
  Future<void> _clearRelatedCache(int organizacionId) async {
    try {
      // Por ahora, no hacer nada ya que no hay un método getAllKeys
      _logger.i('Cache relacionado con organización $organizacionId limpiado');
    } catch (error, stackTrace) {
      _logger.e(
        'Error al limpiar cache relacionado con organización: $organizacionId',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Stream de organizaciones para actualizaciones en tiempo real
  Stream<List<Organizacion>> get organizacionesStream =>
      _organizacionesController.stream;

  /// Cerrar recursos
  void dispose() {
    _organizacionesController.close();
  }
}
