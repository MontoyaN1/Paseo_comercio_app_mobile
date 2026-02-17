// lib/presentation/blocs/image/image_event.dart

part of 'image_bloc.dart';

/// Eventos base para ImageBloc
abstract class ImageEvent extends Equatable {
  const ImageEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar una imagen
class LoadImage extends ImageEvent {
  final String originalUrl;
  final int? width;
  final int? height;
  final int? quality;
  final bool useCache;
  final int cacheTTL;

  const LoadImage({
    required this.originalUrl,
    this.width,
    this.height,
    this.quality,
    this.useCache = true,
    this.cacheTTL = 86400, // 24 horas por defecto
  });

  @override
  List<Object?> get props => [
    originalUrl,
    width,
    height,
    quality,
    useCache,
    cacheTTL,
  ];
}

/// Evento para reintentar carga de imagen
class RetryImage extends ImageEvent {
  final String originalUrl;
  final int? width;
  final int? height;
  final int? quality;
  final bool useCache;
  final int cacheTTL;

  const RetryImage({
    required this.originalUrl,
    this.width,
    this.height,
    this.quality,
    this.useCache = true,
    this.cacheTTL = 86400,
  });

  @override
  List<Object?> get props => [
    originalUrl,
    width,
    height,
    quality,
    useCache,
    cacheTTL,
  ];
}

/// Evento para limpiar cache de imágenes
class ClearImageCache extends ImageEvent {
  final String? imageUrl;

  const ClearImageCache({this.imageUrl});

  @override
  List<Object?> get props => [imageUrl];
}

/// Evento para cambiar proveedor de imágenes
class SwitchImageProvider extends ImageEvent {
  final String originalUrl;
  final String entityType;
  final String entityId;
  final String imageName;
  final String provider;
  final int? width;

  const SwitchImageProvider({
    required this.originalUrl,
    required this.entityType,
    required this.entityId,
    required this.imageName,
    required this.provider,
    this.width,
  });

  @override
  List<Object?> get props => [
    originalUrl,
    entityType,
    entityId,
    imageName,
    provider,
    width,
  ];
}

/// Evento para precargar imágenes
class PreloadImages extends ImageEvent {
  final List<String> imageUrls;
  final int? width;
  final int? height;
  final bool useCache;

  const PreloadImages({
    required this.imageUrls,
    this.width,
    this.height,
    this.useCache = true,
  });

  @override
  List<Object?> get props => [imageUrls, width, height, useCache];
}

/// Evento para cancelar carga de imagen
class CancelImageLoad extends ImageEvent {
  final String imageUrl;

  const CancelImageLoad({required this.imageUrl});

  @override
  List<Object?> get props => [imageUrl];
}

/// Evento para actualizar configuración de imagen
class UpdateImageConfig extends ImageEvent {
  final int? cacheTTL;
  final bool? useCache;
  final String? preferredProvider;

  const UpdateImageConfig({
    this.cacheTTL,
    this.useCache,
    this.preferredProvider,
  });

  @override
  List<Object?> get props => [cacheTTL, useCache, preferredProvider];
}

/// Evento para obtener estadísticas de imagen
class GetImageStats extends ImageEvent {
  const GetImageStats();
}

/// Evento para verificar disponibilidad de proveedores
class CheckProvidersAvailability extends ImageEvent {
  const CheckProvidersAvailability();
}

/// Evento para forzar refresh de imagen
class ForceRefreshImage extends ImageEvent {
  final String imageUrl;
  final bool clearCache;

  const ForceRefreshImage({required this.imageUrl, this.clearCache = false});

  @override
  List<Object?> get props => [imageUrl, clearCache];
}
