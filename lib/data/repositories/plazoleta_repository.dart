// lib/data/repositories/plazoleta_repository.dart

import 'dart:async';
import 'package:logger/logger.dart';

import '../datasources/remote/supabase_client.dart';
import '../datasources/local/local_database.dart';
import '../../domain/repositories/plazoleta_repository_interface.dart';
import '../../domain/entities/plazoleta.dart';
import '../../domain/entities/imagen_base.dart';
import '../../domain/entities/producto.dart';
import '../../domain/entities/tienda.dart';
import '../../domain/entities/enums.dart';
import '../../core/utils/connectivity_service.dart';
import '../../core/utils/cache_service.dart';

/// Repositorio para manejar operaciones de plazoletas
class PlazoletaRepository implements PlazoletaRepositoryInterface {
  final SupabaseClientService _supabaseClient;
  final LocalCacheService _localCache;
  final ConnectivityService _connectivityService;
  final CacheService _cacheService;
  final Logger _logger;

  PlazoletaRepository({
    required SupabaseClientService supabaseClient,
    required LocalCacheService localCache,
    required ConnectivityService connectivityService,
    required CacheService cacheService,
  }) : _supabaseClient = supabaseClient,
       _localCache = localCache,
       _connectivityService = connectivityService,
       _cacheService = cacheService,
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

  // ========== OPERACIONES BÁSICAS DE PLAZOLETAS ==========

  @override
  Future<List<Plazoleta>> getPlazoletasActivas({
    int? page,
    int? limit,
    String? search,
    String? piso,
    String? sector,
    bool? tieneZonaComida,
    bool? tieneEstacionamiento,
  }) async {
    try {
      _logger.i('=== INICIO getPlazoletasActivas ===');
      _logger.i('Parámetros: page=$page, limit=$limit, search=$search');

      // Verificar conectividad
      final hasConnection = await _connectivityService.hasConnection();
      if (!hasConnection) {
        _logger.w('Sin conexión a internet, usando caché local');
        final cachedResult = await _cacheService.get<List<Plazoleta>>('plazoletas_activas');
        if (cachedResult != null) {
          return cachedResult.fold(
            (error) {
              _logger.e('Error de caché: $error');
              return [];
            },
            (data) => data ?? [],
          );
        }
        return [];
      }

      // Construir consulta a Supabase
      final query = _supabaseClient.client.from('plazoleta').select();

      if (search != null && search.isNotEmpty) {
        query.ilike('nombre', '%$search%');
      }

      // Aplicar orden
      query.order('nombre', ascending: true);

      final response = await query;

      _logger.i('Respuesta recibida: ${response.length} registros');

      // Aplicar paginación manualmente si es necesario
      List<dynamic> paginatedResponse = response;
      if (page != null && limit != null) {
        final start = (page - 1) * limit;
        final end = start + limit;
        if (start < response.length) {
          paginatedResponse = response.sublist(
            start,
            end < response.length ? end : response.length,
          );
        } else {
          paginatedResponse = [];
        }
      }

      // Convertir respuesta a objetos Plazoleta
      final plazoletas = paginatedResponse.map<Plazoleta>((data) {
        try {
          return Plazoleta(
            id: (data['id'] as num?)?.toInt() ?? 0,
            nombre: data['nombre'] as String? ?? 'Sin nombre',
            descripcion: data['descripcion'] as String? ?? '',
            activa: true,
            fechaCreacion: DateTime.parse(data['fecha_creacion'] as String? ?? DateTime.now().toString()),
          );
        } catch (e) {
          _logger.e('Error al convertir plazoleta ${data['id']}: $e');
          return Plazoleta(
            id: 0,
            nombre: 'Error en datos',
            descripcion: 'No se pudo cargar la información',
            activa: false,
            fechaCreacion: DateTime.now(),
          );
        }
      }).toList();

      _logger.i('=== FIN getPlazoletasActivas ===');
      _logger.i('Se encontraron ${plazoletas.length} plazoletas activas');

      // Guardar en caché
      await _cacheService.set('plazoletas_activas', plazoletas);

      return plazoletas;
    } catch (e, stackTrace) {
      _logger.e('=== ERROR en getPlazoletasActivas ===');
      _logger.e('Error: $e', error: e, stackTrace: stackTrace);

      // En caso de error, intentar obtener de caché
      final cachedResult = await _cacheService.get<List<Plazoleta>>('plazoletas_activas');
      if (cachedResult != null) {
        return cachedResult.fold(
          (error) {
            _logger.e('Error de caché: $error');
            return [];
          },
          (data) => data ?? [],
        );
      }

      return [];
    }
  }

  @override
  Future<Plazoleta> getPlazoletaById(int id) async {
    try {
      _logger.i('Consultando plazoleta con ID $id desde Supabase');

      // Verificar conectividad
      final hasConnection = await _connectivityService.hasConnection();
      if (!hasConnection) {
        _logger.w('Sin conexión a internet, usando caché local');
        final cachedResult = await _cacheService.get<Plazoleta>('plazoleta_$id');
        if (cachedResult != null) {
          return cachedResult.fold(
            (error) => throw Exception('Error de caché: $error'),
            (data) => data ?? throw Exception('Plazoleta no encontrada en caché'),
          );
        }
        throw Exception('No hay conexión a internet');
      }

      // Consultar plazoleta por ID
      final response = await _supabaseClient.client
          .from('plazoleta')
          .select()
          .eq('id', id)
          .single();

      // Convertir respuesta a objeto Plazoleta
      final plazoleta = Plazoleta(
        id: response['id'] as int,
        nombre: response['nombre'] as String? ?? '',
        descripcion: response['descripcion'] as String? ?? '',
        activa: true,
        fechaCreacion: DateTime.parse(response['fecha_creacion'] as String),
      );

      _logger.i('Plazoleta encontrada: ${plazoleta.nombre}');

      // Guardar en caché
      await _cacheService.set('plazoleta_$id', plazoleta);

      return plazoleta;
    } catch (e) {
      _logger.e('Error al obtener plazoleta con ID $id', error: e);

      // En caso de error, intentar obtener de caché
      final cachedResult = await _cacheService.get<Plazoleta>('plazoleta_$id');
      if (cachedResult != null) {
        return cachedResult.fold(
          (error) => throw Exception('Error de caché: $error'),
          (data) => data ?? throw Exception('Plazoleta no encontrada'),
        );
      }

      // Si no hay datos en caché, relanzar el error
      rethrow;
    }
  }

  @override
  Future<List<Plazoleta>> getPlazoletasByIds(List<int> ids) async {
    try {
      if (ids.isEmpty) return [];

      _logger.i('Consultando plazoletas con IDs: $ids desde Supabase');

      // Verificar conectividad
      final hasConnection = await _connectivityService.hasConnection();
      if (!hasConnection) {
        _logger.w('Sin conexión a internet, usando caché local');
        final List<Plazoleta> cachedPlazoletas = [];
        for (final id in ids) {
          final cachedResult = await _cacheService.get<Plazoleta>('plazoleta_$id');
          if (cachedResult != null) {
            cachedResult.fold(
              (error) => _logger.w('Error en caché para plazoleta $id: $error'),
              (data) {
                if (data != null) cachedPlazoletas.add(data);
              },
            );
          }
        }
        return cachedPlazoletas;
      }

      // Consultar plazoletas por IDs
      final response = await _supabaseClient.client
          .from('plazoleta')
          .select()
          .in_('id', ids);

      // Convertir respuesta a objetos Plazoleta
      final plazoletas = response.map<Plazoleta>((data) {
        try {
          return Plazoleta(
            id: data['id'] as int,
            nombre: data['nombre'] as String? ?? '',
            descripcion: data['descripcion'] as String? ?? '',
            activa: true,
            fechaCreacion: DateTime.parse(data['fecha_creacion'] as String),
          );
        } catch (e) {
          _logger.e('Error al convertir plazoleta ${data['id']}: $e');
          return Plazoleta(
            id: 0,
            nombre: 'Error en datos',
            descripcion: 'No se pudo cargar la información',
            activa: false,
            fechaCreacion: DateTime.now(),
          );
        }
      }).toList();

      _logger.i('Se encontraron ${plazoletas.length} plazoletas');

      return plazoletas;
    } catch (e, stackTrace) {
      _logger.e('Error al obtener plazoletas por IDs', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  @override
  Future<List<Plazoleta>> getPlazoletasPopulares({int? limit}) async {
    try {
      _logger.i('=== INICIO getPlazoletasPopulares ===');

      // Obtener todas las plazoletas activas
      final plazoletas = await getPlazoletasActivas();

      // En una implementación real, aquí se consultarían estadísticas
      // Por ahora, retornamos las primeras plazoletas
      final resultado = limit != null && plazoletas.length > limit
          ? plazoletas.sublist(0, limit)
          : plazoletas;

      _logger.i('=== FIN getPlazoletasPopulares ===');
      _logger.i('Se retornan ${resultado.length} plazoletas populares');

      return resultado;
    } catch (e, stackTrace) {
      _logger.e('=== ERROR en getPlazoletasPopulares ===');
      _logger.e('Error: $e', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  @override
  Future<List<Plazoleta>> getPlazoletasDisponibles({int? page, int? limit}) async {
    try {
      _logger.i('=== INICIO getPlazoletasDisponibles ===');

      // Obtener plazoletas activas
      final plazoletas = await getPlazoletasActivas(page: page, limit: limit);

      // Filtrar solo las activas
      final disponibles = plazoletas.where((p) => p.activa).toList();

      _logger.i('=== FIN getPlazoletasDisponibles ===');
      _logger.i('Se encontraron ${disponibles.length} plazoletas disponibles');

      return disponibles;
    } catch (e, stackTrace) {
      _logger.e('=== ERROR en getPlazoletasDisponibles ===');
      _logger.e('Error: $e', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  @override
  Future<List<Plazoleta>> searchPlazoletas(String query) async {
    try {
      _logger.i('=== INICIO searchPlazoletas ===');
      _logger.i('Búsqueda: "$query"');

      // Usar getPlazoletasActivas con búsqueda
      final plazoletas = await getPlazoletasActivas(search: query);

      _logger.i('=== FIN searchPlazoletas ===');
      _logger.i('Se encontraron ${plazoletas.length} plazoletas para "$query"');

      return plazoletas;
    } catch (e, stackTrace) {
      _logger.e('=== ERROR en searchPlazoletas ===');
      _logger.e('Error: $e', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  // ========== IMÁGENES DE PLAZOLETAS ==========

  @override
  Future<List<ImagenBase>> getImagenesPlazoleta(
    int plazoletaId, {
    TipoImagen? tipoImagen,
    bool? soloActivas,
  }) async {
    try {
      _logger.i('=== INICIO getImagenesPlazoleta ===');
      _logger.i('Plazoleta ID: $plazoletaId, tipoImagen: $tipoImagen');

      // Verificar conectividad
      final hasConnection = await _connectivityService.hasConnection();
      if (!hasConnection) {
        _logger.w('Sin conexión a internet');
        return [];
      }

      // Construir consulta
      final query = _supabaseClient.client
          .from('imagen_plazoleta')
          .select()
          .eq('id_ubicacion', plazoletaId);

      if (tipoImagen != null) {
        query.eq('tipo_imagen', tipoImagen.value);
      }

      if (soloActivas == true) {
        query.eq('activa', true);
      }

      query.order('orden', ascending: true);

      final response = await query;

      // Convertir respuesta a objetos ImagenBase
      final imagenes = response.map<ImagenBase>((data) {
        return ImagenBase(
          id: data['id'] as int,
          urlOriginal: data['url_imagen'] as String? ?? '',
          tipoImagen: TipoImagen.principal,
          ordenVisual: data['orden'] as int? ?? 0,
          activa: data['activa'] as bool? ?? true,
          fechaCreacion: DateTime.parse(data['fecha_subida'] as String? ?? DateTime.now().toString()),
          tamanoBytes: 0,
          esPrincipal: true,
          extension: 'jpg',
          nombreArchivo: 'imagen_plazoleta_${data['id']}',
          ancho: 0,
          alto: 0,
        );
      }).toList();

      _logger.i('=== FIN getImagenesPlazoleta ===');
      _logger.i('Se encontraron ${imagenes.length} imágenes para plazoleta $plazoletaId');

      return imagenes;
    } catch (e, stackTrace) {
      _logger.e('=== ERROR en getImagenesPlazoleta ===');
      _logger.e('Error: $e', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  @override
  Future<ImagenBase?> getImagenPrincipalPlazoleta(int plazoletaId) async {
    try {
      _logger.i('=== INICIO getImagenPrincipalPlazoleta ===');

      // Obtener imágenes de la plazoleta
      final imagenes = await getImagenesPlazoleta(
        plazoletaId,
        tipoImagen: TipoImagen.principal,
        soloActivas: true,
      );

      // Retornar la primera imagen principal o la primera disponible
      final imagenPrincipal = imagenes.isNotEmpty ? imagenes.first : null;

      _logger.i('=== FIN getImagenPrincipalPlazoleta ===');
      _logger.i('${imagenPrincipal != null ? 'Se encontró' : 'No se encontró'} imagen principal');

      return imagenPrincipal;
    } catch (e, stackTrace) {
      _logger.e('=== ERROR en getImagenPrincipalPlazoleta ===');
      _logger.e('Error: $e', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Future<List<ImagenBase>> getImagenesPlazoletaPorTipo(
    int plazoletaId,
    TipoImagen tipoImagen,
  ) async {
    try {
      _logger.i('=== INICIO getImagenesPlazoletaPorTipo ===');
      _logger.i('Plazoleta ID: $plazoletaId, tipoImagen: $tipoImagen');

      // Usar getImagenesPlazoleta con filtro de tipo
      final imagenes = await getImagenesPlazoleta(
        plazoletaId,
        tipoImagen: tipoImagen,
        soloActivas: true,
      );

      _logger.i('=== FIN getImagenesPlazoletaPorTipo ===');
      _logger.i('Se encontraron ${imagenes.length} imágenes de tipo $tipoImagen');

      return imagenes;
    } catch (e, stackTrace) {
      _logger.e('=== ERROR en getImagenesPlazoletaPorTipo ===');
      _logger.e('Error: $e', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  // ========== PRODUCTOS RELACIONADOS CON PLAZOLETAS ==========

  @override
  Future<List<Producto>> getProductosPorPlazoleta(
    int plazoletaId, {
    int? page,
    int? limit,
    String? search,
    double? precioMin,
    double? precioMax,
    bool? soloDisponibles,
  }) async {
    try {
      _logger.i('=== INICIO getProductosPorPlazoleta ===');
      _logger.i('Plazoleta ID: $plazoletaId, page: $page, limit: $limit');

      // Verificar conectividad
      final hasConnection = await _connectivityService.hasConnection();
      if (!hasConnection) {
        _logger.w('Sin conexión a internet, usando caché local');
        final cachedResult = await _cacheService.get<List<Producto>>('productos_plazoleta_$plazoletaId');
        if (cachedResult != null
