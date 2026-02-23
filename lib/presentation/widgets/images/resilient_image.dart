// lib/presentation/widgets/images/resilient_image.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/utils/image_service.dart';
import '../../../core/utils/connectivity_service.dart';
import '../../../core/utils/cache_service.dart';
import '../../../di/service_locator.dart';
// import '../../blocs/image/image_bloc.dart';

/// Widget de imagen resiliente con fallback multi-CDN
///
/// Características:
/// 1. Intenta cargar desde Cloudflare R2 (primario)
/// 2. Fallback a Contabo S3 si R2 falla
/// 3. Fallback a Supabase Storage si ambos fallan
/// 4. Cache local con Hive
/// 5. Optimización automática según tamaño de pantalla
/// 6. Placeholder personalizable
/// 7. Error widget personalizable
/// 8. Soporte para modo offline
class ResilientImage extends StatefulWidget {
  /// URL original de la imagen (puede ser de cualquier proveedor)
  final String imageUrl;

  /// Ancho deseado de la imagen (null para auto)
  final double? width;

  /// Alto deseado de la imagen (null para auto)
  final double? height;

  /// BoxFit para la imagen
  final BoxFit fit;

  /// Widget a mostrar mientras carga
  final Widget? placeholder;

  /// Widget a mostrar cuando hay error
  final Widget? errorWidget;

  /// Si debe usar cache local
  final bool useCache;

  /// Tiempo de vida del cache en segundos
  final int cacheTTL;

  /// Calidad de la imagen (0-100)
  final int? quality;

  /// Si debe usar variantes optimizadas automáticamente
  final bool useOptimizedVariants;

  /// Si debe mostrar indicador de carga
  final bool showLoadingIndicator;

  /// Color de fondo mientras carga
  final Color? backgroundColor;

  /// Border radius de la imagen
  final BorderRadius? borderRadius;

  /// BoxShadow de la imagen
  final List<BoxShadow>? boxShadow;

  /// Callback cuando la imagen se carga exitosamente
  final VoidCallback? onImageLoaded;

  /// Callback cuando ocurre un error
  final Function(String error)? onError;

  /// Si debe usar BLoC para gestión de estado (deprecated, siempre usa sin BLoC)
  final bool useBloc;

  /// ID único para tracking de imagen
  final String? imageId;

  const ResilientImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.useCache = true,
    this.cacheTTL = 86400, // 24 horas por defecto
    this.quality,
    this.useOptimizedVariants = true,
    this.showLoadingIndicator = true,
    this.backgroundColor,
    this.borderRadius,
    this.boxShadow,
    this.onImageLoaded,
    this.onError,
    this.useBloc = false,
    this.imageId,
  });

  @override
  State<ResilientImage> createState() => _ResilientImageState();
}

class _ResilientImageState extends State<ResilientImage> {
  late ImageService _imageService;
  late ConnectivityService _connectivityService;
  late CacheService _cacheService;

  /// URLs de fallback generadas
  List<String> _fallbackUrls = [];

  /// Índice actual de URL que se está intentando
  int _currentUrlIndex = 0;

  /// Si está cargando
  bool _isLoading = true;

  /// Error actual
  String? _error;

  /// URL actual que se está mostrando
  String? _currentDisplayUrl;

  /// Si está offline
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _generateFallbackUrls();
    _checkConnectivity();
  }

  void _initializeServices() {
    _imageService = getIt<ImageService>();
    _connectivityService = getIt<ConnectivityService>();
    _cacheService = getIt<CacheService>();
  }

  void _generateFallbackUrls() {
    if (!_imageService.isConfigured) {
      _fallbackUrls = [widget.imageUrl];
      return;
    }

    // Extraer información de la URL original
    final originalUrl = widget.imageUrl;

    // Si la URL ya es de un proveedor conocido, mantenerla
    if (originalUrl.contains('r2.cloudflarestorage.com') ||
        originalUrl.contains('contabostorage.com') ||
        originalUrl.contains('supabase.co') ||
        originalUrl.contains('.r2.dev')) {
      _fallbackUrls = [originalUrl];
      return;
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
        final urls = <String>[];

        // R2 (primario)
        try {
          final r2Url = _imageService.getImageUrl(
            entityType: entityType,
            entityId: entityId,
            imageName: imageName,
            provider: 'r2',
            size: widget.width?.toInt(),
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
            size: widget.width?.toInt(),
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
            size: widget.width?.toInt(),
          );
          urls.add(supabaseUrl);
        } catch (e) {
          // Ignorar error
        }

        // Si no se generaron URLs alternativas, usar la original
        _fallbackUrls = urls.isNotEmpty ? urls : [originalUrl];
      } else {
        _fallbackUrls = [originalUrl];
      }
    } catch (e) {
      // En caso de error, usar la URL original
      _fallbackUrls = [originalUrl];
    }

    // Añadir la URL original como último fallback
    if (!_fallbackUrls.contains(originalUrl)) {
      _fallbackUrls.add(originalUrl);
    }
  }

  void _checkConnectivity() async {
    await _connectivityService.checkConnectivity();
    setState(() {
      _isOffline = _connectivityService.isDisconnected;
    });

    if (_isOffline) {
      _tryLoadFromCache();
    }
  }

  void _tryLoadFromCache() async {
    if (!widget.useCache) return;

    final cacheKey = 'image_${widget.imageUrl}';
    final result = await _cacheService.get<Map<String, dynamic>>(cacheKey);

    result.fold(
      (cachedData) {
        if (cachedData != null) {
          final cachedUrl = cachedData['url'] as String?;
          final cachedTimestamp = cachedData['timestamp'] as int?;

          if (cachedUrl != null && cachedTimestamp != null) {
            final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
            final age = now - cachedTimestamp;

            if (age < widget.cacheTTL) {
              setState(() {
                _currentDisplayUrl = cachedUrl;
                _isLoading = false;
              });

              if (widget.onImageLoaded != null) {
                widget.onImageLoaded!();
              }
              return;
            }
          }
        }
      },
      (error) {
        // Ignorar errores de cache
      },
    );
  }

  void _onImageError(String url, dynamic error) {
    if (_currentUrlIndex < _fallbackUrls.length - 1) {
      // Intentar siguiente URL de fallback
      _currentUrlIndex++;
      setState(() {
        _isLoading = true;
        _error = null;
      });

      if (widget.onError != null) {
        widget.onError!('Fallback a proveedor alternativo');
      }
    } else {
      // Todas las URLs fallaron
      setState(() {
        _isLoading = false;
        _error = 'No se pudo cargar la imagen desde ningún proveedor';
      });

      if (widget.onError != null) {
        widget.onError!(_error!);
      }
    }
  }

  Widget _buildPlaceholder() {
    if (widget.placeholder != null) {
      return widget.placeholder!;
    }

    return Container(
      width: widget.width,
      height: widget.height,
      color: widget.backgroundColor ?? Colors.grey[200],
      child:
          widget.showLoadingIndicator
              ? const Center(child: CircularProgressIndicator())
              : null,
    );
  }

  Widget _buildErrorWidget() {
    if (widget.errorWidget != null) {
      return widget.errorWidget!;
    }

    return Container(
      width: widget.width,
      height: widget.height,
      color: widget.backgroundColor ?? Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.broken_image, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              _isOffline ? 'Sin conexión' : 'Error de imagen',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            if (_error != null && _error!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCachedNetworkImage(String url) {
    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.zero,
      child: Container(
        decoration:
            widget.boxShadow != null
                ? BoxDecoration(
                  boxShadow: widget.boxShadow,
                  borderRadius: widget.borderRadius,
                )
                : null,
        child: CachedNetworkImage(
          imageUrl: url,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          placeholder: (context, url) => _buildPlaceholder(),
          errorWidget: (context, url, error) {
            _onImageError(url, error);
            return _buildErrorWidget();
          },
          fadeInDuration: const Duration(milliseconds: 300),
          fadeOutDuration: const Duration(milliseconds: 300),
        ),
      ),
    );
  }

  Widget _buildImageWithoutBloc() {
    final currentUrl =
        _currentDisplayUrl ??
        (_currentUrlIndex < _fallbackUrls.length
            ? _fallbackUrls[_currentUrlIndex]
            : widget.imageUrl);

    if (_isLoading || currentUrl.isEmpty) {
      return _buildPlaceholder();
    }

    if (_error != null) {
      return _buildErrorWidget();
    }

    return _buildCachedNetworkImage(currentUrl);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: _buildImageWithoutBloc(),
    );
  }
}

/// Widget de imagen circular resiliente
class ResilientCircleImage extends StatelessWidget {
  final String imageUrl;
  final double size;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool useCache;
  final int cacheTTL;
  final int? quality;
  final Color? backgroundColor;
  final double borderWidth;
  final Color borderColor;
  final VoidCallback? onImageLoaded;
  final Function(String error)? onError;

  const ResilientCircleImage({
    super.key,
    required this.imageUrl,
    required this.size,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.useCache = true,
    this.cacheTTL = 86400,
    this.quality,
    this.backgroundColor,
    this.borderWidth = 2.0,
    this.borderColor = Colors.white,
    this.onImageLoaded,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: ClipOval(
        child: ResilientImage(
          imageUrl: imageUrl,
          width: size,
          height: size,
          fit: fit,
          placeholder: placeholder,
          errorWidget: errorWidget,
          useCache: useCache,
          cacheTTL: cacheTTL,
          quality: quality,
          backgroundColor: backgroundColor,
          onImageLoaded: onImageLoaded,
          onError: onError,
        ),
      ),
    );
  }
}

/// Widget de imagen con borde redondeado resiliente
class ResilientRoundedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool useCache;
  final int cacheTTL;
  final int? quality;
  final Color? backgroundColor;
  final double borderWidth;
  final Color borderColor;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onImageLoaded;
  final Function(String error)? onError;

  const ResilientRoundedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius = 8.0,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.useCache = true,
    this.cacheTTL = 86400,
    this.quality,
    this.backgroundColor,
    this.borderWidth = 0,
    this.borderColor = Colors.transparent,
    this.boxShadow,
    this.onImageLoaded,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: boxShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: ResilientImage(
          imageUrl: imageUrl,
          width: width,
          height: height,
          fit: fit,
          placeholder: placeholder,
          errorWidget: errorWidget,
          useCache: useCache,
          cacheTTL: cacheTTL,
          quality: quality,
          backgroundColor: backgroundColor,
          onImageLoaded: onImageLoaded,
          onError: onError,
        ),
      ),
    );
  }
}
