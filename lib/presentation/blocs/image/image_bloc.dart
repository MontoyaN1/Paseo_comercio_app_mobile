// lib/presentation/blocs/image/image_bloc.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:logger/logger.dart';
import 'package:flutter/painting.dart';

import '../../../../core/utils/image_service.dart';
import '../../../../core/utils/cache_service.dart';
import '../../../../core/utils/connectivity_service.dart';

import 'models/image_bloc_stats.dart';
import 'image_event.dart';
import 'image_state.dart';

/// BLoC para gestión de imágenes con fallback multi-CDN
class ImageBloc extends Bloc<ImageEvent, ImageState> {
  final ImageService _imageService;
  final CacheService _cacheService;
  final ConnectivityService _connectivityService;
  final Logger _logger;

  /// URLs de fallback para la imagen actual
  List<String> _fallbackUrls = [];

  /// Índice actual de URL que se está intentando
  int _currentUrlIndex = 0;

  /// Tiempo de vida del cache
  int _cacheTTL = 86400; // 24 horas por defecto

  ImageBloc({
    required ImageService imageService,
    required CacheService cacheService,
    required ConnectivityService connectivityService,
  }) : _imageService = imageService,
       _cacheService = cacheService,
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
       ),
       super(const ImageInitial()) {
    on<LoadImage>(_onLoadImage);
    on<RetryImage>(_onRetryImage);
    on<ClearImageCache>(_onClearImageCache);
    on<SwitchImageProvider>(_onSwitchImageProvider);
  }

  /// Obtener estadísticas del BLoC
  ImageBlocStats get stats {
    return ImageBlocStats(
      fallbackUrlsCount: _fallbackUrls.length,
      currentUrlIndex: _currentUrlIndex,
      isConfigured: _imageService.isConfigured,
    );
  }

  /// Intentar cargar desde cache
  Future<String?> _tryLoadFromCache(String originalUrl) async {
    try {
      final cacheKey = 'image_$originalUrl';
      final result = await _cacheService.get<Map<String, dynamic>>(cacheKey);

      return result.fold(
        (cachedData) {
          if (cachedData != null) {
            final cachedUrl = cachedData['url'] as String?;
            final cachedTimestamp = cachedData['timestamp'] as int?;

            if (cachedUrl != null && cachedTimestamp != null) {
              final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
              final age = now - cachedTimestamp;

              if (age < _cacheTTL) {
                return cachedUrl;
              }
            }
          }
          return null;
        },
        (error) {
          // Ignorar errores de cache
          return null;
        },
      );
    } catch (e) {
      // Ignorar errores de cache
      return null;
    }
  }

  /// Guardar en cache
  Future<void> _saveToCache(String originalUrl, String loadedUrl) async {
    try {
      final cacheKey = 'image_$originalUrl';
      final cacheData = {
        'url': loadedUrl,
        'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'originalUrl': originalUrl,
      };

      final result = await _cacheService.save(
        key: cacheKey,
        data: cacheData,
        ttl: Duration(seconds: _cacheTTL),
      );

      result.fold(
        (_) {
          // Éxito, no hacer nada
        },
        (error) {
          // Ignorar errores de cache
          _logger.w('Error al guardar en cache: $error');
        },
      );
    } catch (e) {
      // Ignorar errores de cache
      _logger.w('Error inesperado al guardar en cache: $e');
    }
  }

  /// Intentar cargar una URL específica
  Future<void> _tryLoadUrl(LoadImage event, Emitter<ImageState> emit) async {
    if (_currentUrlIndex >= _fallbackUrls.length) {
      emit(ImageError(message: 'No hay más URLs para intentar'));
      return;
    }

    final url = _fallbackUrls[_currentUrlIndex];

    try {
      // Verificar si la URL está en cache
      if (event.useCache) {
        final cachedUrl = await _tryLoadFromCache(event.originalUrl);
        if (cachedUrl != null) {
          emit(ImageLoaded(url: cachedUrl, isFromCache: true));
          return;
        }
      }

      // Intentar cargar la imagen
      final completer = Completer<void>();
      final imageProvider = CachedNetworkImageProvider(url);

      // Verificar si la imagen se puede cargar
      imageProvider
          .resolve(ImageConfiguration())
          .addListener(
            ImageStreamListener(
              (image, synchronousCall) {
                if (!completer.isCompleted) {
                  completer.complete();
                }
              },
              onError: (error, stackTrace) {
                if (!completer.isCompleted) {
                  completer.completeError(error);
                }
              },
            ),
          );

      await completer.future.timeout(const Duration(seconds: 10));

      // Si llegamos aquí, la imagen se cargó exitosamente
      emit(ImageLoaded(url: url));

      // Guardar en cache
      if (event.useCache) {
        await _saveToCache(event.originalUrl, url);
      }
    } catch (e) {
      // Intentar siguiente URL
      add(
        RetryImage(
          originalUrl: event.originalUrl,
          width: event.width,
          height: event.height,
          quality: event.quality,
          useCache: event.useCache,
          cacheTTL: event.cacheTTL,
        ),
      );
    }
  }

  /// Generar URLs de fallback
  List<String> _generateFallbackUrls({
    required String originalUrl,
    int? width,
    int? height,
    int? quality,
  }) {
    final urls = <String>[];

    // Si el servicio no está configurado, usar solo la URL original
    if (!_imageService.isConfigured) {
      return [originalUrl];
    }

    // Si la URL ya es de un proveedor conocido, mantenerla
    if (originalUrl.contains('r2.cloudflarestorage.com') ||
        originalUrl.contains('contabostorage.com') ||
        originalUrl.contains('supabase.co')) {
      return [originalUrl];
    }

    // Intentar extraer información de la URL para generar alternativas
    try {
      final uri = Uri.parse(originalUrl);
      final pathSegments = uri.pathSegments;

      if (pathSegments.length >= 3) {
        // Asumir formato: /entityType/entityId/imageName
        final entityType = pathSegments[pathSegments.length - 3];
        final entityId = pathSegments[pathSegments.length - 2];
        final imageName = pathSegments.last;

        // Generar URLs para cada proveedor
        // R2 (primario)
        try {
          final r2Url = _imageService.getImageUrl(
            entityType: entityType,
            entityId: entityId,
            imageName: imageName,
            provider: 'r2',
            size: width,
          );
          urls.add(r2Url);
        } catch (e) {
          // Ignorar error, continuar con siguiente proveedor
        }

        // S3 (fallback 1)
        try {
          final s3Url = _imageService.getImageUrl(
            entityType: entityType,
            entityId: entityId,
            imageName: imageName,
            provider: 's3',
            size: width,
          );
          urls.add(s3Url);
        } catch (e) {
          // Ignorar error, continuar con siguiente proveedor
        }

        // Supabase (fallback 2)
        try {
          final supabaseUrl = _imageService.getImageUrl(
            entityType: entityType,
            entityId: entityId,
            imageName: imageName,
            provider: 'supabase',
            size: width,
          );
          urls.add(supabaseUrl);
        } catch (e) {
          // Ignorar error
        }
      }
    } catch (e) {
      // En caso de error, continuar
    }

    // Si no se generaron URLs alternativas, usar la original
    if (urls.isEmpty) {
      urls.add(originalUrl);
    } else if (!urls.contains(originalUrl)) {
      // Añadir la URL original como último fallback
      urls.add(originalUrl);
    }

    return urls;
  }

  /// Manejar evento de carga de imagen
  Future<void> _onLoadImage(LoadImage event, Emitter<ImageState> emit) async {
    // Verificar si ya estamos cargando
    if (state is ImageLoading) return;

    emit(const ImageLoading());

    try {
      // Verificar conectividad
      await _connectivityService.checkConnectivity();
      final isOffline = _connectivityService.isDisconnected;

      if (isOffline) {
        // Intentar cargar desde cache
        final cachedUrl = await _tryLoadFromCache(event.originalUrl);
        if (cachedUrl != null) {
          emit(ImageLoaded(url: cachedUrl, isFromCache: true));
          return;
        } else {
          emit(ImageError(message: 'Sin conexión y sin cache disponible'));
          return;
        }
      }

      // Generar URLs de fallback
      _fallbackUrls = _generateFallbackUrls(
        originalUrl: event.originalUrl,
        width: event.width,
        height: event.height,
        quality: event.quality,
      );

      _cacheTTL = event.cacheTTL;
      _currentUrlIndex = 0;

      // Intentar cargar la primera URL
      await _tryLoadUrl(event, emit);
    } catch (e) {
      emit(ImageError(message: 'Error al cargar imagen: ${e.toString()}'));
    }
  }

  /// Manejar evento de reintento
  Future<void> _onRetryImage(RetryImage event, Emitter<ImageState> emit) async {
    if (_currentUrlIndex < _fallbackUrls.length - 1) {
      // Intentar siguiente URL de fallback
      _currentUrlIndex++;
      emit(const ImageLoading());
      await _tryLoadUrl(
        LoadImage(
          originalUrl: event.originalUrl,
          width: event.width,
          height: event.height,
          quality: event.quality,
          useCache: event.useCache,
          cacheTTL: event.cacheTTL,
        ),
        emit,
      );
    } else {
      // Todas las URLs fallaron
      emit(
        ImageError(
          message: 'No se pudo cargar la imagen desde ningún proveedor',
        ),
      );
    }
  }

  /// Manejar evento de limpiar cache
  Future<void> _onClearImageCache(
    ClearImageCache event,
    Emitter<ImageState> emit,
  ) async {
    try {
      if (event.imageUrl != null) {
        // Limpiar cache específico
        final result = await _cacheService.remove('image_${event.imageUrl}');
        result.fold(
          (_) {
            emit(ImageCacheCleared(clearedCount: 1));
          },
          (error) {
            emit(
              ImageError(
                message: 'Error al limpiar cache: ${error.toString()}',
              ),
            );
          },
        );
      } else {
        // Limpiar todo el cache de imágenes - usar método simplificado
        emit(ImageCacheCleared(clearedCount: 0));
        _logger.w('Cache clearing all images not fully implemented');
      }
    } catch (e) {
      emit(ImageError(message: 'Error al limpiar cache: ${e.toString()}'));
    }
  }

  /// Manejar evento de cambiar proveedor
  Future<void> _onSwitchImageProvider(
    SwitchImageProvider event,
    Emitter<ImageState> emit,
  ) async {
    try {
      // Generar URL con el nuevo proveedor
      final newUrl = _imageService.getImageUrl(
        entityType: event.entityType,
        entityId: event.entityId,
        imageName: event.imageName,
        provider: event.provider,
        size: event.width,
      );

      emit(ImageLoaded(url: newUrl, provider: event.provider));

      // Guardar en cache
      await _saveToCache(event.originalUrl, newUrl);
    } catch (e) {
      emit(ImageError(message: 'Error al cambiar proveedor: ${e.toString()}'));
    }
  }
}
