// lib/data/repositories/plazoleta_repository.dart

import 'dart:async';
import 'dart:convert';
import 'package:logger/logger.dart';

import '../../core/app/app_config.dart';

import '../datasources/remote/supabase_client.dart';

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
  final ConnectivityService _connectivityService;
  final CacheService _cacheService;
  final Logger _logger;
  final AppConfig _appConfig;

  PlazoletaRepository({
    required SupabaseClientService supabaseClient,
    required ConnectivityService connectivityService,
    required CacheService cacheService,
  }) : _supabaseClient = supabaseClient,
       _connectivityService = connectivityService,
       _cacheService = cacheService,
       _appConfig = AppConfig(),
       _logger = Logger(level: Level.warning, 
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
        final cachedResult = await _cacheService.get<List<dynamic>>(
          'plazoletas_activas',
        );
        return cachedResult.fold(
          (data) {
            if (data == null) return [];
            try {
              // Deserializar los datos del caché
              return data
                  .map(
                    (item) => Plazoleta.fromJson(item as Map<String, dynamic>),
                  )
                  .toList();
            } catch (e) {
              _logger.e('Error al deserializar plazoletas del caché: $e');
              return [];
            }
          },
          (error) {
            _logger.e('Error de caché: $error');
            return [];
          },
        );
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

      // Convertir respuesta a objetos Plazoleta usando fromSupabaseJson
      final plazoletas =
          paginatedResponse.map<Plazoleta>((data) {
            try {
              return Plazoleta.fromSupabaseJson(data);
            } catch (e) {
              _logger.e('Error al convertir plazoleta ${data['id']}: $e');
              return Plazoleta(
                id: 0,
                fechaCreacion: DateTime.now(),
                nombre: 'Error en datos',
                descripcion: 'No se pudo cargar la información',
                tipoUbicacion: TipoUbicacion.plazoleta,
                slug: 'error',
              );
            }
          }).toList();

      _logger.i('=== FIN getPlazoletasActivas ===');
      _logger.i('Se encontraron ${plazoletas.length} plazoletas activas');

      // Guardar en caché - serializar primero
      final plazoletasSerializadas = plazoletas.map((p) => p.toJson()).toList();
      await _cacheService.set('plazoletas_activas', plazoletasSerializadas);

      return plazoletas;
    } catch (e, stackTrace) {
      _logger.e('=== ERROR en getPlazoletasActivas ===');
      _logger.e('Error: $e', error: e, stackTrace: stackTrace);

      // En caso de error, intentar obtener de caché
      final cachedResult = await _cacheService.get<List<dynamic>>(
        'plazoletas_activas',
      );
      return cachedResult.fold(
        (data) {
          if (data == null) return [];
          try {
            // Deserializar los datos del caché
            return data
                .map((item) => Plazoleta.fromJson(item as Map<String, dynamic>))
                .toList();
          } catch (e) {
            _logger.e('Error al deserializar plazoletas del caché: $e');
            return [];
          }
        },
        (error) {
          _logger.e('Error de caché: $error');
          return [];
        },
      );
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
        final cachedResult = await _cacheService.get<dynamic>('plazoleta_$id');
        return cachedResult.fold((data) {
          if (data != null) {
            try {
              // Deserializar los datos del caché
              return Plazoleta.fromJson(data as Map<String, dynamic>);
            } catch (e) {
              _logger.e('Error al deserializar plazoleta del caché: $e');
              throw Exception('Error al deserializar plazoleta del caché');
            }
          } else {
            throw Exception('Plazoleta no encontrada en caché');
          }
        }, (error) => throw Exception('Error de caché: $error'));
      }

      // Consultar plazoleta por ID
      final response =
          await _supabaseClient.client
              .from('plazoleta')
              .select()
              .eq('id', id)
              .single();

      // Convertir respuesta a objeto Plazoleta usando fromSupabaseJson
      final plazoleta = Plazoleta.fromSupabaseJson(response);

      _logger.i(
        'Plazoleta encontrada: ${plazoleta.nombre}, ID Categoría Principal: ${plazoleta.categoriaPrincipalId}',
      );

      // Guardar en caché - serializar primero
      await _cacheService.set('plazoleta_$id', plazoleta.toJson());

      return plazoleta;
    } catch (e) {
      _logger.e('Error al obtener plazoleta con ID $id', error: e);

      // En caso de error, intentar obtener de caché
      final cachedResult = await _cacheService.get<dynamic>('plazoleta_$id');
      return cachedResult.fold(
        (data) {
          if (data != null) {
            try {
              // Deserializar los datos del caché
              return Plazoleta.fromJson(data as Map<String, dynamic>);
            } catch (e) {
              _logger.e('Error al deserializar plazoleta del caché: $e');
              throw Exception('Error al deserializar plazoleta del caché');
            }
          } else {
            throw Exception('Plazoleta no encontrada');
          }
        },
        (error) =>
            throw Exception('Error al obtener plazoleta del caché: $error'),
      );
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
          final cachedResult = await _cacheService.get<dynamic>(
            'plazoleta_$id',
          );
          cachedResult.fold((data) {
            if (data != null) {
              try {
                // Deserializar los datos del caché
                final plazoleta = Plazoleta.fromJson(
                  data as Map<String, dynamic>,
                );
                cachedPlazoletas.add(plazoleta);
              } catch (e) {
                _logger.w('Error al deserializar plazoleta $id del caché: $e');
              }
            }
          }, (error) => _logger.w('Error en caché para plazoleta $id: $error'));
        }
        return cachedPlazoletas;
      }

      // Consultar plazoletas por IDs
      final response = await _supabaseClient.client
          .from('plazoleta')
          .select()
          .filter('id', 'in', '(${ids.join(',')})');

      // Convertir respuesta a objetos Plazoleta
      final plazoletas =
          response.map<Plazoleta>((data) {
            try {
              return Plazoleta.fromSupabaseJson(data);
            } catch (e) {
              _logger.e('Error al convertir plazoleta ${data['id']}: $e');
              return Plazoleta(
                id: 0,
                fechaCreacion: DateTime.now(),
                nombre: 'Error en datos',
                descripcion: 'No se pudo cargar la información',
                tipoUbicacion: TipoUbicacion.plazoleta,
                slug: 'error',
              );
            }
          }).toList();

      _logger.i('Se encontraron ${plazoletas.length} plazoletas');

      return plazoletas;
    } catch (e, stackTrace) {
      _logger.e(
        'Error al obtener plazoletas por IDs',
        error: e,
        stackTrace: stackTrace,
      );
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
      final resultado =
          limit != null && plazoletas.length > limit
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
  Future<List<Plazoleta>> getPlazoletasDisponibles({
    int? page,
    int? limit,
  }) async {
    try {
      _logger.i('=== INICIO getPlazoletasDisponibles ===');

      // Obtener plazoletas activas
      final plazoletas = await getPlazoletasActivas(page: page, limit: limit);

      // Todas las plazoletas son consideradas disponibles
      // (En el esquema actual no hay campo 'activa')
      _logger.i('=== FIN getPlazoletasDisponibles ===');
      _logger.i('Se encontraron ${plazoletas.length} plazoletas disponibles');

      return plazoletas;
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
      final imagenes =
          response.map<ImagenBase>((data) {
            final tipoImagenStr = data['tipo_imagen'] as String? ?? 'principal';
            final esPrincipal = tipoImagenStr == 'principal';
            String urlOriginal = data['url_imagen'] as String? ?? '';

            // Transformar URL de Contabo a Cloudflare R2 para todas las imágenes
            if (urlOriginal.contains('contabostorage.com')) {
              urlOriginal = _transformContaboUrlToR2(urlOriginal);
            }

            // Reemplazar HTTPS con HTTP solo para URLs de Contabo Storage
            urlOriginal = _convertHttpsToHttp(urlOriginal) ?? urlOriginal;

            // Extraer nombre de archivo y extensión de la URL
            String nombreArchivo = 'imagen_plazoleta_${data['id']}';
            String extension = 'jpg';
            if (urlOriginal.isNotEmpty) {
              try {
                final uri = Uri.parse(urlOriginal);
                final pathSegments = uri.pathSegments;
                if (pathSegments.isNotEmpty) {
                  final fileName = pathSegments.last;
                  nombreArchivo = fileName;
                  final dotIndex = fileName.lastIndexOf('.');
                  if (dotIndex != -1 && dotIndex < fileName.length - 1) {
                    extension = fileName.substring(dotIndex + 1).toLowerCase();
                  }
                }
              } catch (e) {
                _logger.w('Error al parsear URL: $urlOriginal, error: $e');
              }
            }

            // Construir mapa de variantes
            Map<String, String>? urlsVariantes;
            String? urlThumb = data['url_thumb'] as String?;
            String? urlMedium = data['url_medium'] as String?;
            String? urlLarge = data['url_large'] as String?;

            // Reemplazar HTTPS con HTTP en URLs de variantes y transformar Contabo a R2
            urlThumb = _convertHttpsToHttp(urlThumb);
            urlMedium = _convertHttpsToHttp(urlMedium);
            urlLarge = _convertHttpsToHttp(urlLarge);

            // Transformar URLs de Contabo a R2
            if (urlThumb != null && urlThumb.contains('contabostorage.com')) {
              urlThumb = _transformContaboUrlToR2(urlThumb);
            }
            if (urlMedium != null && urlMedium.contains('contabostorage.com')) {
              urlMedium = _transformContaboUrlToR2(urlMedium);
            }
            if (urlLarge != null && urlLarge.contains('contabostorage.com')) {
              urlLarge = _transformContaboUrlToR2(urlLarge);
            }

            if (urlThumb != null || urlMedium != null || urlLarge != null) {
              urlsVariantes = {};
              if (urlThumb != null) urlsVariantes['thumb'] = urlThumb;
              if (urlMedium != null) urlsVariantes['medium'] = urlMedium;
              if (urlLarge != null) urlsVariantes['large'] = urlLarge;
            }

            // Extraer dimensiones y URLs del JSON de variantes si existe
            int ancho = 0;
            int alto = 0;
            dynamic variantesJson = data['variantes'];

            // Parsear variantes si es un String JSON
            if (variantesJson != null && variantesJson is String) {
              try {
                variantesJson = json.decode(variantesJson);
              } catch (e) {
                _logger.w('Error al parsear JSON de variantes: $e');
                variantesJson = null;
              }
            }

            if (variantesJson != null) {
              // Extraer URLs de cada variante
              final variantesMap = variantesJson as Map<String, dynamic>;
              for (final entry in variantesMap.entries) {
                final nombreVariante = entry.key; // 'large', 'thumb', 'medium'
                final datosVariante = entry.value;
                if (datosVariante != null &&
                    datosVariante is Map<String, dynamic>) {
                  final urlVariante = datosVariante['url'] as String?;
                  if (urlVariante != null && urlVariante.isNotEmpty) {
                    // Transformar URL de Contabo a R2 si es necesario
                    String urlTransformada = urlVariante;
                    if (urlTransformada.contains('contabostorage.com')) {
                      urlTransformada = _transformContaboUrlToR2(
                        urlTransformada,
                      );
                    }
                    // Reemplazar HTTPS con HTTP en URLs del JSON
                    final urlVarianteHttp = _convertHttpsToHttp(
                      urlTransformada,
                    );
                    urlsVariantes ??= {};
                    if (urlVarianteHttp != null) {
                      urlsVariantes[nombreVariante] = urlVarianteHttp;
                    }
                    _logger.i(
                      'Agregada variante $nombreVariante desde JSON: $urlVarianteHttp',
                    );
                  }

                  // Extraer dimensiones de la variante large
                  if (nombreVariante == 'large') {
                    ancho = datosVariante['width'] as int? ?? 0;
                    alto = datosVariante['height'] as int? ?? 0;
                  }
                }
              }
            }

            return ImagenPlazoleta(
              id: data['id'] as int,
              urlOriginal: urlOriginal,
              plazoletaId: plazoletaId,
              tipoImagen: TipoImagen.fromString(tipoImagenStr),
              ordenVisual: data['orden'] as int? ?? 0,
              activa: data['activa'] as bool? ?? true,
              fechaCreacion: DateTime.parse(
                data['fecha_subida'] as String? ?? DateTime.now().toString(),
              ),
              tamanoBytes: 0, // No disponible en la base de datos actual
              esPrincipal: esPrincipal,
              extension: extension,
              nombreArchivo: nombreArchivo,
              ancho: ancho,
              alto: alto,
              altText: data['alt_text'] as String?,
              urlsVariantes: urlsVariantes,
            );
          }).toList();

      _logger.i('=== FIN getImagenesPlazoleta ===');
      _logger.i(
        'Se encontraron ${imagenes.length} imágenes para plazoleta $plazoletaId',
      );

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
      _logger.i(
        '${imagenPrincipal != null ? 'Se encontró' : 'No se encontró'} imagen principal',
      );

      return imagenPrincipal;
    } catch (e, stackTrace) {
      _logger.e('=== ERROR en getImagenPrincipalPlazoleta ===');
      _logger.e('Error: $e', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Future<Map<int, ImagenBase?>> getImagenesPrincipalesPlazoletas(
    List<int> plazoletaIds,
  ) async {
    try {
      _logger.i('=== INICIO getImagenesPrincipalesPlazoletas ===');
      _logger.i('Plazoleta IDs: $plazoletaIds');

      // Verificar conectividad
      final hasConnection = await _connectivityService.hasConnection();
      if (!hasConnection) {
        _logger.w('Sin conexión a internet');
        return {};
      }

      // Construir consulta para obtener imágenes principales de múltiples plazoletas
      final query = _supabaseClient.client
          .from('imagen_plazoleta')
          .select()
          .eq('tipo_imagen', 'principal')
          .eq('activa', true)
          .order('orden', ascending: true);

      final response = await query;
      _logger.i(
        'Se encontraron ${response.length} registros de imágenes en total',
      );
      for (final data in response) {
        final plazoletaId = data['id_ubicacion'] as int?;
        final tipoImagen = data['tipo_imagen'] as String?;
        final urlImagen = data['url_imagen'] as String?;
        _logger.i(
          '  - Plazoleta $plazoletaId: tipo=$tipoImagen, url=$urlImagen ${urlImagen?.endsWith('.gif') == true ? '(GIF)' : ''}',
        );
      }

      // Convertir respuesta a mapa de ID de plazoleta a imagen principal
      final Map<int, ImagenBase?> imagenesMap = {};

      // Inicializar mapa con nulls
      for (final plazoletaId in plazoletaIds) {
        imagenesMap[plazoletaId] = null;
      }

      // Agrupar imágenes por plazoleta
      final Map<int, List<ImagenBase>> imagenesPorPlazoleta = {};
      for (final data in response) {
        final plazoletaId = data['id_ubicacion'] as int?;
        if (plazoletaId == null) continue;
        // Filtrar solo las plazoletas que nos interesan
        if (!plazoletaIds.contains(plazoletaId)) continue;

        final tipoImagenStr = data['tipo_imagen'] as String? ?? 'principal';
        final esPrincipal = tipoImagenStr == 'principal';
        String urlOriginal = data['url_imagen'] as String? ?? '';

        // Transformar URL de Contabo a Cloudflare R2 para todas las imágenes
        if (urlOriginal.contains('contabostorage.com')) {
          urlOriginal = _transformContaboUrlToR2(urlOriginal);
        }

        // Reemplazar HTTPS con HTTP solo para URLs de Contabo Storage
        urlOriginal = _convertHttpsToHttp(urlOriginal) ?? urlOriginal;

        // Extraer nombre de archivo y extensión de la URL
        String nombreArchivo = 'imagen_plazoleta_${data['id']}';
        String extension = 'jpg';
        if (urlOriginal.isNotEmpty) {
          try {
            final uri = Uri.parse(urlOriginal);
            final pathSegments = uri.pathSegments;
            if (pathSegments.isNotEmpty) {
              final fileName = pathSegments.last;
              nombreArchivo = fileName;
              final dotIndex = fileName.lastIndexOf('.');
              if (dotIndex != -1 && dotIndex < fileName.length - 1) {
                extension = fileName.substring(dotIndex + 1).toLowerCase();
              }
            }
          } catch (e) {
            _logger.w('Error al parsear URL: $urlOriginal, error: $e');
          }
        }

        // Construir mapa de variantes
        Map<String, String>? urlsVariantes;
        String? urlThumb = data['url_thumb'] as String?;
        String? urlMedium = data['url_medium'] as String?;
        String? urlLarge = data['url_large'] as String?;

        // Reemplazar HTTPS con HTTP en URLs de variantes y transformar Contabo a R2
        urlThumb = _convertHttpsToHttp(urlThumb);
        urlMedium = _convertHttpsToHttp(urlMedium);
        urlLarge = _convertHttpsToHttp(urlLarge);

        // Transformar URLs de Contabo a R2
        if (urlThumb != null && urlThumb.contains('contabostorage.com')) {
          urlThumb = _transformContaboUrlToR2(urlThumb);
        }
        if (urlMedium != null && urlMedium.contains('contabostorage.com')) {
          urlMedium = _transformContaboUrlToR2(urlMedium);
        }
        if (urlLarge != null && urlLarge.contains('contabostorage.com')) {
          urlLarge = _transformContaboUrlToR2(urlLarge);
        }

        if (urlThumb != null || urlMedium != null || urlLarge != null) {
          urlsVariantes = {};
          if (urlThumb != null) urlsVariantes['thumb'] = urlThumb;
          if (urlMedium != null) urlsVariantes['medium'] = urlMedium;
          if (urlLarge != null) urlsVariantes['large'] = urlLarge;
        }

        // Extraer dimensiones y URLs del JSON de variantes si existe
        int ancho = 0;
        int alto = 0;
        dynamic variantesJson = data['variantes'];

        // Parsear variantes si es un String JSON
        if (variantesJson != null && variantesJson is String) {
          try {
            variantesJson = json.decode(variantesJson);
          } catch (e) {
            _logger.w('Error al parsear JSON de variantes: $e');
            variantesJson = null;
          }
        }

        if (variantesJson != null) {
          // Extraer URLs de cada variante
          final variantesMap = variantesJson as Map<String, dynamic>;
          for (final entry in variantesMap.entries) {
            final nombreVariante = entry.key; // 'large', 'thumb', 'medium'
            final datosVariante = entry.value;
            if (datosVariante != null &&
                datosVariante is Map<String, dynamic>) {
              final urlVariante = datosVariante['url'] as String?;
              if (urlVariante != null && urlVariante.isNotEmpty) {
                // Transformar URL de Contabo a R2 si es necesario
                String urlTransformada = urlVariante;
                if (urlTransformada.contains('contabostorage.com')) {
                  urlTransformada = _transformContaboUrlToR2(urlTransformada);
                }
                // Reemplazar HTTPS con HTTP en URLs del JSON
                final urlVarianteHttp = _convertHttpsToHttp(urlTransformada);
                urlsVariantes ??= {};
                if (urlVarianteHttp != null) {
                  urlsVariantes[nombreVariante] = urlVarianteHttp;
                }
                _logger.i(
                  'Agregada variante $nombreVariante desde JSON: $urlVarianteHttp',
                );
              }

              // Extraer dimensiones de la variante large
              if (nombreVariante == 'large') {
                ancho = datosVariante['width'] as int? ?? 0;
                alto = datosVariante['height'] as int? ?? 0;
              }
            }
          }
        }

        final imagen = ImagenPlazoleta(
          id: data['id'] as int,
          urlOriginal: urlOriginal,
          plazoletaId: plazoletaId,
          tipoImagen: TipoImagen.fromString(tipoImagenStr),
          ordenVisual: data['orden'] as int? ?? 0,
          activa: data['activa'] as bool? ?? true,
          fechaCreacion: DateTime.parse(
            data['fecha_subida'] as String? ?? DateTime.now().toString(),
          ),
          tamanoBytes: 0,
          esPrincipal: esPrincipal,
          extension: extension,
          nombreArchivo: nombreArchivo,
          ancho: ancho,
          alto: alto,
          altText: data['alt_text'] as String?,
          urlsVariantes: urlsVariantes,
        );

        _logger.i(
          'Imagen creada para plazoleta $plazoletaId: ${imagen.urlPreferida} (tipo: $tipoImagenStr, esPrincipal: $esPrincipal, extension: $extension)',
        );

        if (!imagenesPorPlazoleta.containsKey(plazoletaId)) {
          imagenesPorPlazoleta[plazoletaId] = [];
        }
        imagenesPorPlazoleta[plazoletaId]!.add(imagen);
        _logger.i(
          'Imagen agregada a plazoleta $plazoletaId (total: ${imagenesPorPlazoleta[plazoletaId]!.length})',
        );
      }

      // Para cada plazoleta, seleccionar la primera imagen (principal o la que tenga orden más bajo)
      for (final plazoletaId in plazoletaIds) {
        final imagenes = imagenesPorPlazoleta[plazoletaId];
        if (imagenes != null && imagenes.isNotEmpty) {
          // Ordenar por ordenVisual y luego por id
          imagenes.sort((a, b) {
            final orderCompare = a.ordenVisual.compareTo(b.ordenVisual);
            if (orderCompare != 0) return orderCompare;
            return a.id.compareTo(b.id);
          });
          imagenesMap[plazoletaId] = imagenes.first;
        }
      }

      _logger.i('=== FIN getImagenesPrincipalesPlazoletas ===');
      _logger.i(
        'Se encontraron imágenes para ${imagenesMap.values.where((img) => img != null).length} de ${plazoletaIds.length} plazoletas',
      );

      // Log detallado de cada plazoleta
      for (final entry in imagenesMap.entries) {
        final plazoletaId = entry.key;
        final imagen = entry.value;
        if (imagen != null) {
          _logger.i(
            '  • Plazoleta $plazoletaId: ${imagen.urlPreferida} (${imagen.extension}) ${imagen.extension == 'gif' ? '🎬 GIF' : '🖼️ Imagen'}',
          );
        } else {
          _logger.i('  • Plazoleta $plazoletaId: ❌ Sin imagen principal');
        }
      }

      return imagenesMap;
    } catch (e, stackTrace) {
      _logger.e('=== ERROR en getImagenesPrincipalesPlazoletas ===');
      _logger.e('Error: $e', error: e, stackTrace: stackTrace);
      return {};
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
      _logger.i(
        'Se encontraron ${imagenes.length} imágenes de tipo $tipoImagen',
      );

      return imagenes;
    } catch (e, stackTrace) {
      _logger.e('=== ERROR en getImagenesPlazoletaPorTipo ===');
      _logger.e('Error: $e', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  // ========== PRODUCTOS RELACIONADOS CON PLAZOLETAS ==========

  @override
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
      _logger.i('Plazoleta ID: \$plazoletaId, page: \$page, limit: \$limit');

      // Verificar conectividad
      final hasConnection = await _connectivityService.hasConnection();
      if (!hasConnection) {
        _logger.w('Sin conexión a internet, usando caché local');
        final cachedResult = await _cacheService.get<List<Producto>>(
          'productos_plazoleta_\$plazoletaId',
        );
        return cachedResult.fold((data) => data ?? [], (error) {
          _logger.e('Error de caché: \$error');
          return [];
        });
      }

      // Lógica: obtener productos por categoría asociada a la plazoleta
      try {
        // 1. Obtener la plazoleta con su categoria_principal_id
        final plazoletaResponse =
            await _supabaseClient.plazoletas
                .select('nombre, categoria_principal_id')
                .eq('id', plazoletaId)
                .single();

        final plazoletaNombre = plazoletaResponse['nombre'] as String;
        final categoriaPrincipalId =
            plazoletaResponse['categoria_principal_id'] as int?;

        _logger.i(
          'Plazoleta ID $plazoletaId -> Nombre: "$plazoletaNombre", Categoría Principal ID: $categoriaPrincipalId',
        );
        _logger.i('Plazoleta response completa: $plazoletaResponse');

        List<int> categoriaIds = [];

        if (categoriaPrincipalId != null) {
          _logger.i('Usando categoría principal ID: $categoriaPrincipalId');
          categoriaIds.add(categoriaPrincipalId);
        } else {
          // Fallback: buscar categorías cuyo nombre coincida con el nombre de la plazoleta
          _logger.i(
            'Buscando categorías con nombre similar a "$plazoletaNombre"',
          );
          final categoriasResponse = await _supabaseClient.categorias
              .select('id')
              .ilike('nombre', '%' + plazoletaNombre + '%')
              .eq('activa', true);

          if (categoriasResponse.isNotEmpty) {
            categoriaIds.addAll(
              categoriasResponse.map((c) => c['id'] as int).toList(),
            );
            _logger.i(
              'Categorías encontradas con nombre similar: ${categoriaIds.length}',
            );
          } else {
            _logger.i(
              'No se encontraron categorías con nombre similar a "$plazoletaNombre"',
            );
          }
        }

        _logger.i('Categorías finales a filtrar: $categoriaIds');
        _logger.i(
          'Procediendo a filtrar productos usando ${categoriaIds.length} categorías',
        );

        if (categoriaIds.isEmpty) {
          _logger.i(
            'No hay categorías asociadas a la plazoleta "$plazoletaNombre", devolviendo lista vacía',
          );
          // Guardar lista vacía en caché
          await _cacheService.set('productos_plazoleta_\$plazoletaId', []);
          return [];
        }

        _logger.i('Filtrando productos por categoria_ids: $categoriaIds');
        var query = _supabaseClient.productos
            .select('''
              *,
              imagen_productos!left(*)
            ''')
            .inFilter('categoria_id', categoriaIds);

        if (search != null && search.isNotEmpty) {
          query = query.ilike('nombre_producto', '%' + search + '%');
        }
        if (soloDisponibles == true) {
          query = query.eq('estado_producto', 'publicado');
        }
        if (precioMin != null) {
          query = query.gte('precio', precioMin);
        }
        if (precioMax != null) {
          query = query.lte('precio', precioMax);
        }

        // Log de filtros aplicados
        _logger.i(
          'Filtros aplicados: search="$search", soloDisponibles=$soloDisponibles, precioMin=$precioMin, precioMax=$precioMax',
        );

        final pageNum = page ?? 1;
        final limitNum = limit ?? 20;
        final response = await query
            .order('fecha_creacion', ascending: false)
            .range(
              (pageNum - 1) * limitNum,
              (pageNum - 1) * limitNum + limitNum - 1,
            );

        _logger.i('Productos response count: ${response.length}');
        if (response.isNotEmpty) {
          _logger.i(
            'Sample producto ID: ${response.first['id']}, categoria_id: ${response.first['categoria_id']}, nombre: ${response.first['nombre_producto']}',
          );
          if (response.length > 1) {
            _logger.i(
              'Segundo producto: ID: ${response[1]['id']}, nombre: ${response[1]['nombre_producto']}',
            );
          }
        } else {
          _logger.w('La consulta de productos retornó una lista vacía');
          _logger.w('Query ejecutada: $query');
        }
        final productos =
            response
                .map((json) {
                  try {
                    // Transformar URLs de imágenes de Contabo a Cloudflare R2
                    final imagenes = json['imagen_productos'] as List<dynamic>?;
                    if (imagenes != null && imagenes.isNotEmpty) {
                      for (final imagen in imagenes) {
                        if (imagen is Map<String, dynamic>) {
                          final urlOriginal = imagen['url_imagen'] as String?;
                          if (urlOriginal != null && urlOriginal.isNotEmpty) {
                            if (urlOriginal.contains('contabostorage.com')) {
                              imagen['url_imagen'] = _transformContaboUrlToR2(
                                urlOriginal,
                              );
                            }
                          }
                        }
                      }
                    }
                    return Producto.fromJson(json);
                  } catch (e, stackTrace) {
                    _logger.e(
                      'Error parsing producto JSON: $e',
                      error: e,
                      stackTrace: stackTrace,
                    );
                    _logger.e('Problematic JSON: $json');
                    return null;
                  }
                })
                .where((producto) => producto != null)
                .cast<Producto>()
                .toList();

        _logger.i(
          'Productos parseados exitosamente: ${productos.length} de ${response.length}',
        );
        if (productos.isNotEmpty) {
          _logger.i(
            'Primer producto parseado: ${productos.first.id} - ${productos.first.nombreProducto}',
          );
        }

        // Guardar en caché
        _logger.i(
          'Guardando ${productos.length} productos en caché para plazoleta ID: $plazoletaId',
        );
        await _cacheService.set('productos_plazoleta_\$plazoletaId', productos);
        _logger.i('=== FIN getProductosPorPlazoleta EXITOSO ===');
        return productos;
      } catch (e, stackTrace) {
        _logger.e(
          'Error en consulta de productos por categoría: ' + e.toString(),
          error: e,
          stackTrace: stackTrace,
        );
        return [];
      }
    } catch (e, stackTrace) {
      _logger.e('=== ERROR en getProductosPorPlazoleta ===');
      _logger.e('Error: \$e', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  @override
  Future<List<Producto>> getProductosDestacadosPlazoleta(
    int plazoletaId, {
    int? limit,
  }) async {
    try {
      _logger.i('=== INICIO getProductosDestacadosPlazoleta ===');
      _logger.i('Plazoleta ID: $plazoletaId, limit: $limit');

      // Usar getProductosPorPlazoleta como base
      final productos = await getProductosPorPlazoleta(plazoletaId);

      // En una implementación real, aquí se filtrarían productos destacados
      final resultado =
          limit != null && productos.length > limit
              ? productos.sublist(0, limit)
              : productos;

      _logger.i('=== FIN getProductosDestacadosPlazoleta ===');
      _logger.i('Se retornan ${resultado.length} productos destacados');

      return resultado;
    } catch (e, stackTrace) {
      _logger.e('=== ERROR en getProductosDestacadosPlazoleta ===');
      _logger.e('Error: $e', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  @override
  Future<Map<String, List<Producto>>> getProductosPorCategoriasPlazoleta(
    int plazoletaId, {
    int? productosPorCategoria,
  }) async {
    try {
      _logger.i('=== INICIO getProductosPorCategoriasPlazoleta ===');
      _logger.i('Plazoleta ID: $plazoletaId');

      // Obtener productos de la plazoleta
      final productos = await getProductosPorPlazoleta(plazoletaId);

      // Agrupar por categoría (implementación simplificada)
      final productosPorCategoriaMap = <String, List<Producto>>{};
      for (final producto in productos) {
        // Usar categoría del producto o "Sin categoría"
        final categoria =
            'Sin categoría'; // TODO: Agregar campo categoria a Producto
        productosPorCategoriaMap.putIfAbsent(categoria, () => []).add(producto);
      }

      // Limitar productos por categoría si se especifica
      if (productosPorCategoria != null) {
        for (final categoria in productosPorCategoriaMap.keys) {
          final lista = productosPorCategoriaMap[categoria]!;
          if (lista.length > productosPorCategoria) {
            productosPorCategoriaMap[categoria] = lista.sublist(
              0,
              productosPorCategoria,
            );
          }
        }
      }

      _logger.i('=== FIN getProductosPorCategoriasPlazoleta ===');
      _logger.i(
        'Se agruparon productos en ${productosPorCategoriaMap.length} categorías',
      );

      return productosPorCategoriaMap;
    } catch (e, stackTrace) {
      _logger.e('=== ERROR en getProductosPorCategoriasPlazoleta ===');
      _logger.e('Error: $e', error: e, stackTrace: stackTrace);
      return {};
    }
  }

  @override
  Future<List<Tienda>> getTiendasPlazoleta(
    int plazoletaId, {
    int? page,
    int? limit,
    String? search,
    bool? soloAbiertas,
  }) async {
    try {
      _logger.i('=== INICIO getTiendasPlazoleta ===');
      _logger.i('Plazoleta ID: \$plazoletaId, page: \$page, limit: \$limit');

      // Verificar conectividad
      final hasConnection = await _connectivityService.hasConnection();
      if (!hasConnection) {
        _logger.w('Sin conexión a internet, usando caché local');
        final cachedResult = await _cacheService.get<List<Tienda>>(
          'tiendas_plazoleta_\$plazoletaId',
        );
        return cachedResult.fold((data) => data ?? [], (error) {
          _logger.e('Error de caché: \$error');
          return [];
        });
      }

      // Nueva lógica: obtener tiendas que tienen productos con la categoría principal de la plazoleta
      try {
        // 1. Obtener la plazoleta con su categoria_principal_id
        final plazoletaResponse =
            await _supabaseClient.plazoletas
                .select('nombre, categoria_principal_id')
                .eq('id', plazoletaId)
                .single();

        final plazoletaNombre = plazoletaResponse['nombre'] as String;
        final categoriaPrincipalId =
            plazoletaResponse['categoria_principal_id'] as int?;

        _logger.i(
          'Plazoleta ID $plazoletaId -> Nombre: "$plazoletaNombre", Categoría Principal ID: $categoriaPrincipalId',
        );
        _logger.i('Plazoleta response completa: $plazoletaResponse');

        List<int> categoriaIds = [];
        List<int> tiendaIds = [];

        if (categoriaPrincipalId != null) {
          _logger.i('Usando categoría principal ID: $categoriaPrincipalId');
          categoriaIds.add(categoriaPrincipalId);
        } else {
          // Fallback: buscar categorías cuyo nombre coincida con el nombre de la plazoleta
          _logger.i(
            'Buscando categorías con nombre similar a "$plazoletaNombre"',
          );
          final categoriasResponse = await _supabaseClient.categorias
              .select('id')
              .ilike('nombre', '%' + plazoletaNombre + '%')
              .eq('activa', true);

          if (categoriasResponse.isNotEmpty) {
            categoriaIds.addAll(
              categoriasResponse.map((c) => c['id'] as int).toList(),
            );
            _logger.i(
              'Categorías encontradas con nombre similar: ${categoriaIds.length}',
            );
          } else {
            _logger.i(
              'No se encontraron categorías con nombre similar a "$plazoletaNombre"',
            );
          }
        }

        _logger.i('Categorías finales a filtrar: $categoriaIds');

        if (categoriaIds.isNotEmpty) {
          _logger.i('Buscando productos por categoria_ids: $categoriaIds');

          // Obtener productos con categoria_id en las categorías encontradas
          final productosResponse = await _supabaseClient.productos
              .select('tienda_id')
              .inFilter('categoria_id', categoriaIds)
              .eq('estado_producto', 'publicado');

          if (productosResponse.isNotEmpty) {
            // Extraer tienda_id únicos
            tiendaIds =
                productosResponse
                    .map((p) => p['tienda_id'] as int)
                    .toSet()
                    .toList();
            _logger.i('Tienda IDs encontrados: ${tiendaIds.length}');
          }
        }

        if (tiendaIds.isEmpty) {
          _logger.i(
            'La plazoleta "$plazoletaNombre" no tiene categorías asociadas o no hay productos con esas categorías, devolviendo lista vacía',
          );
          // Guardar lista vacía en caché
          await _cacheService.set(
            'tiendas_plazoleta_' + plazoletaId.toString(),
            [],
          );
          return [];
        }

        _logger.i('Filtrando tiendas por IDs: $tiendaIds');
        var query = _supabaseClient.tiendas
            .select('''
          *,
          imagen_tienda!left(*)
        ''')
            .inFilter('id', tiendaIds);

        if (search != null && search.isNotEmpty) {
          query = query.ilike('nombre_tienda', '%' + search + '%');
        }

        final pageNum = page ?? 1;
        final limitNum = limit ?? 20;
        final response = await query
            .order('fecha_creacion', ascending: false)
            .range(
              (pageNum - 1) * limitNum,
              (pageNum - 1) * limitNum + limitNum - 1,
            );

        _logger.i('Tiendas response count: ${response.length}');
        if (response.isNotEmpty) {
          _logger.i(
            'Sample tienda ID: ${response.first['id']}, nombre: ${response.first['nombre_tienda']}',
          );
        }

        final tiendas =
            response
                .map((json) {
                  try {
                    return Tienda.fromJson(json);
                  } catch (e, stackTrace) {
                    _logger.e(
                      'Error parsing tienda JSON: $e',
                      error: e,
                      stackTrace: stackTrace,
                    );
                    _logger.e('Problematic JSON: $json');
                    return null;
                  }
                })
                .where((tienda) => tienda != null)
                .cast<Tienda>()
                .toList();

        // Guardar en caché
        await _cacheService.set(
          'tiendas_plazoleta_' + plazoletaId.toString(),
          tiendas,
        );
        return tiendas;
      } catch (e, stackTrace) {
        _logger.e(
          'Error en consulta de tiendas por categoría de plazoleta: ' +
              e.toString(),
          error: e,
          stackTrace: stackTrace,
        );
        return [];
      }
    } catch (e, stackTrace) {
      _logger.e('=== ERROR en getTiendasPlazoleta ===');
      _logger.e('Error: \$e', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  @override
  Future<List<Tienda>> getTiendasDestacadasPlazoleta(
    int plazoletaId, {
    int? limit,
  }) async {
    try {
      _logger.i('=== INICIO getTiendasDestacadasPlazoleta ===');
      _logger.i('Plazoleta ID: $plazoletaId, limit: $limit');

      // Usar getTiendasPlazoleta como base
      final tiendas = await getTiendasPlazoleta(plazoletaId);

      // En una implementación real, aquí se filtrarían tiendas destacadas
      final resultado =
          limit != null && tiendas.length > limit
              ? tiendas.sublist(0, limit)
              : tiendas;

      _logger.i('=== FIN getTiendasDestacadasPlazoleta ===');
      _logger.i('Se retornan ${resultado.length} tiendas destacadas');

      return resultado;
    } catch (e, stackTrace) {
      _logger.e('=== ERROR en getTiendasDestacadasPlazoleta ===');
      _logger.e('Error: $e', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  @override
  Future<Map<String, List<Tienda>>> getTiendasPorCategoriaPlazoleta(
    int plazoletaId, {
    int? tiendasPorCategoria,
  }) async {
    try {
      _logger.i('=== INICIO getTiendasPorCategoriaPlazoleta ===');
      _logger.i('Plazoleta ID: $plazoletaId');

      // Obtener tiendas de la plazoleta
      final tiendas = await getTiendasPlazoleta(plazoletaId);

      // Agrupar por categoría (implementación simplificada)
      final tiendasPorCategoriaMap = <String, List<Tienda>>{};
      for (final tienda in tiendas) {
        // Usar categoría de la tienda o "Sin categoría"
        final categoria =
            'Sin categoría'; // TODO: Agregar campo categoria a Tienda
        tiendasPorCategoriaMap.putIfAbsent(categoria, () => []).add(tienda);
      }

      // Limitar tiendas por categoría si se especifica
      if (tiendasPorCategoria != null) {
        for (final categoria in tiendasPorCategoriaMap.keys) {
          final lista = tiendasPorCategoriaMap[categoria]!;
          if (lista.length > tiendasPorCategoria) {
            tiendasPorCategoriaMap[categoria] = lista.sublist(
              0,
              tiendasPorCategoria,
            );
          }
        }
      }

      _logger.i('=== FIN getTiendasPorCategoriaPlazoleta ===');
      _logger.i(
        'Se agruparon tiendas en ${tiendasPorCategoriaMap.length} categorías',
      );

      return tiendasPorCategoriaMap;
    } catch (e, stackTrace) {
      _logger.e('=== ERROR en getTiendasPorCategoriaPlazoleta ===');
      _logger.e('Error: $e', error: e, stackTrace: stackTrace);
      return {};
    }
  }

  @override
  Future<void> incrementarVisitasPlazoleta(int plazoletaId) async {
    try {
      _logger.i('=== INICIO incrementarVisitasPlazoleta ===');
      _logger.i('Plazoleta ID: $plazoletaId');

      // Verificar conectividad
      final hasConnection = await _connectivityService.hasConnection();
      if (!hasConnection) {
        _logger.w('Sin conexión a internet, no se puede incrementar visitas');
        return;
      }

      // TODO: Implementar incremento real en Supabase
      _logger.w(
        'Método incrementarVisitasPlazoleta no implementado completamente',
      );

      _logger.i('=== FIN incrementarVisitasPlazoleta ===');
    } catch (e, stackTrace) {
      _logger.e('=== ERROR en incrementarVisitasPlazoleta ===');
      _logger.e('Error: $e', error: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<Map<String, dynamic>> getEstadisticasPlazoleta(int plazoletaId) async {
    try {
      _logger.i('=== INICIO getEstadisticasPlazoleta ===');
      _logger.i('Plazoleta ID: $plazoletaId');

      // Verificar conectividad
      final hasConnection = await _connectivityService.hasConnection();
      if (!hasConnection) {
        _logger.w('Sin conexión a internet, usando estadísticas por defecto');
        return {
          'plazoletaId': plazoletaId,
          'totalVisitas': 0,
          'promedioCalificacion': 0.0,
          'totalTiendas': 0,
          'totalProductos': 0,
          'ultimaActualizacion': DateTime.now().toIso8601String(),
        };
      }

      // TODO: Implementar consulta real a Supabase
      _logger.w(
        'Método getEstadisticasPlazoleta no implementado completamente',
      );

      return {
        'plazoletaId': plazoletaId,
        'totalVisitas': 0,
        'promedioCalificacion': 0.0,
        'totalTiendas': 0,
        'totalProductos': 0,
        'ultimaActualizacion': DateTime.now().toIso8601String(),
      };
    } catch (e, stackTrace) {
      _logger.e('=== ERROR en getEstadisticasPlazoleta ===');
      _logger.e('Error: $e', error: e, stackTrace: stackTrace);
      return {};
    }
  }

  @override
  Future<double> getNivelOcupacionPlazoleta(int plazoletaId) async {
    try {
      _logger.i('=== INICIO getNivelOcupacionPlazoleta ===');
      _logger.i('Plazoleta ID: $plazoletaId');

      // Verificar conectividad
      final hasConnection = await _connectivityService.hasConnection();
      if (!hasConnection) {
        _logger.w('Sin conexión a internet, usando valor por defecto');
        return 0.0;
      }

      // TODO: Implementar cálculo real de ocupación
      _logger.w(
        'Método getNivelOcupacionPlazoleta no implementado completamente',
      );

      _logger.i('=== FIN getNivelOcupacionPlazoleta ===');
      return 0.0;
    } catch (e, stackTrace) {
      _logger.e('=== ERROR en getNivelOcupacionPlazoleta ===');
      _logger.e('Error: $e', error: e, stackTrace: stackTrace);
      return 0.0;
    }
  }

  @override
  Future<List<Plazoleta>> filtrarPlazoletas({
    List<String>? pisos,
    List<String>? sectores,
    List<String>? servicios,
    bool? tieneAccesoDiscapacitados,
    bool? tieneEstacionamiento,
    bool? tieneZonaDescanso,
    bool? tieneZonaComida,
    double? latitud,
    double? longitud,
    double? radioKm,
    int? capacidadMinima,
    int? capacidadMaxima,
    bool? soloDisponibles,
  }) async {
    try {
      _logger.i('=== INICIO filtrarPlazoletas ===');
      _logger.i(
        'Parámetros: pisos=$pisos, sectores=$sectores, servicios=$servicios',
      );

      // Obtener todas las plazoletas activas
      final plazoletas = await getPlazoletasActivas();

      // Aplicar filtros (implementación simplificada)
      var filtered = plazoletas;

      // El campo 'activa' no existe en el esquema actual de plazoleta
      // if (soloDisponibles == true) {
      //   filtered = filtered.where((p) => p.activa).toList();
      // }

      // TODO: Implementar filtros reales basados en datos

      _logger.i('=== FIN filtrarPlazoletas ===');
      _logger.i(
        'Se filtraron ${filtered.length} plazoletas de ${plazoletas.length}',
      );

      return filtered;
    } catch (e, stackTrace) {
      _logger.e('=== ERROR en filtrarPlazoletas ===');
      _logger.e('Error: $e', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  @override
  Future<List<Plazoleta>> getPlazoletasCercanas({
    required double latitud,
    required double longitud,
    double? radioKm,
    int? limit,
  }) async {
    try {
      _logger.i('=== INICIO getPlazoletasCercanas ===');
      _logger.i(
        'Ubicación: ($latitud, $longitud), radio: ${radioKm ?? "default"} km',
      );

      // Obtener todas las plazoletas
      final plazoletas = await getPlazoletasActivas();

      // En una implementación real, aquí se calcularían distancias
      // Por ahora, retornamos todas las plazoletas
      final resultado =
          limit != null && plazoletas.length > limit
              ? plazoletas.sublist(0, limit)
              : plazoletas;

      _logger.i('=== FIN getPlazoletasCercanas ===');
      _logger.i('Se retornan ${resultado.length} plazoletas cercanas');

      return resultado;
    } catch (e, stackTrace) {
      _logger.e('=== ERROR en getPlazoletasCercanas ===');
      _logger.e('Error: $e', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  @override
  Future<void> sincronizarPlazoletas() async {
    try {
      _logger.i('=== INICIO sincronizarPlazoletas ===');

      // Verificar conectividad
      final hasConnection = await _connectivityService.hasConnection();
      if (!hasConnection) {
        _logger.w('Sin conexión a internet, no se puede sincronizar');
        return;
      }

      // Obtener datos actualizados
      final plazoletas = await getPlazoletasActivas();

      // Guardar en caché - serializar primero
      final plazoletasSerializadas = plazoletas.map((p) => p.toJson()).toList();
      await _cacheService.set('plazoletas_activas', plazoletasSerializadas);

      _logger.i('=== FIN sincronizarPlazoletas ===');
      _logger.i('Sincronizadas ${plazoletas.length} plazoletas');
    } catch (e, stackTrace) {
      _logger.e('=== ERROR en sincronizarPlazoletas ===');
      _logger.e('Error: $e', error: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> limpiarCachePlazoletas() async {
    try {
      _logger.i('=== INICIO limpiarCachePlazoletas ===');

      // Limpiar caché relacionado con plazoletas
      await _cacheService.remove('plazoletas_activas');
      await _cacheService.remove('plazoletas_populares');
      await _cacheService.remove('plazoletas_disponibles');

      _logger.i('=== FIN limpiarCachePlazoletas ===');
      _logger.i('Caché de plazoletas limpiado');
    } catch (e, stackTrace) {
      _logger.e('=== ERROR en limpiarCachePlazoletas ===');
      _logger.e('Error: $e', error: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<bool> tieneCachePlazoletas() async {
    try {
      _logger.i('=== INICIO tieneCachePlazoletas ===');

      // Verificar si hay datos en caché
      final cachedResult = await _cacheService.get<List<dynamic>>(
        'plazoletas_activas',
      );
      final tieneCache = cachedResult.fold(
        (data) => data != null,
        (error) => false,
      );

      _logger.i('=== FIN tieneCachePlazoletas ===');
      _logger.i('${tieneCache ? "Sí" : "No"} tiene caché de plazoletas');

      return tieneCache;
    } catch (e, stackTrace) {
      _logger.e('=== ERROR en tieneCachePlazoletas ===');
      _logger.e('Error: $e', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  @override
  Future<DateTime?> getUltimaActualizacionPlazoletas() async {
    try {
      _logger.i('=== INICIO getUltimaActualizacionPlazoletas ===');

      // Obtener metadatos del caché
      final metadata = _cacheService.getMetadata('plazoletas_activas');
      final ultimaActualizacion = metadata?.lastAccessed;

      _logger.i('=== FIN getUltimaActualizacionPlazoletas ===');
      _logger.i('Última actualización: $ultimaActualizacion');

      return ultimaActualizacion;
    } catch (e, stackTrace) {
      _logger.e('=== ERROR en getUltimaActualizacionPlazoletas ===');
      _logger.e('Error: $e', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  String? _convertHttpsToHttp(String? url) {
    if (url == null) return null;
    if (url.isEmpty) return url;
    // Solo convertir HTTPS a HTTP para URLs de Contabo Storage
    if (url.startsWith('https://') && url.contains('contabostorage.com')) {
      return url.replaceFirst('https://', 'http://');
    }
    return url;
  }

  /// Transforma una URL de Contabo Storage a Cloudflare R2
  /// Ejemplo: https://usc1.contabostorage.com/paseocomercio/plazoletas/1771266396412-996725795.gif
  ///          → https://[cloudflareR2PublicUrl]/plazoletas/1771266396412-996725795.gif
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

      _logger.i('URL transformada de Contabo a R2: $contaboUrl → $r2Url');
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
