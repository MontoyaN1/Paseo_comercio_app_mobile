// lib/presentation/blocs/image/image_state.dart

import 'package:equatable/equatable.dart';
import 'models/image_bloc_stats.dart';

/// Estados base para ImageBloc
abstract class ImageState extends Equatable {
  const ImageState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ImageInitial extends ImageState {
  const ImageInitial();
}

/// Estado de carga
class ImageLoading extends ImageState {
  final String? message;
  final int? currentUrlIndex;
  final int? totalUrls;

  const ImageLoading({this.message, this.currentUrlIndex, this.totalUrls});

  @override
  List<Object?> get props => [message, currentUrlIndex, totalUrls];
}

/// Estado de imagen cargada exitosamente
class ImageLoaded extends ImageState {
  final String url;
  final String? provider;
  final bool isFromCache;
  final int? width;
  final int? height;
  final DateTime? loadedAt;

  ImageLoaded({
    required this.url,
    this.provider,
    this.isFromCache = false,
    this.width,
    this.height,
    DateTime? loadedAt,
  }) : loadedAt = loadedAt ?? DateTime.now();

  @override
  List<Object?> get props => [
    url,
    provider,
    isFromCache,
    width,
    height,
    loadedAt,
  ];
}

/// Estado de error
class ImageError extends ImageState {
  final String message;
  final String? url;
  final int? errorCode;
  final bool isRetryable;
  final DateTime? occurredAt;

  ImageError({
    required this.message,
    this.url,
    this.errorCode,
    this.isRetryable = true,
    DateTime? occurredAt,
  }) : occurredAt = occurredAt ?? DateTime.now();

  @override
  List<Object?> get props => [message, url, errorCode, isRetryable, occurredAt];
}

/// Estado de cache limpiado
class ImageCacheCleared extends ImageState {
  final int clearedCount;
  final DateTime clearedAt;

  ImageCacheCleared({this.clearedCount = 0, DateTime? clearedAt})
    : clearedAt = clearedAt ?? DateTime.now();

  @override
  List<Object?> get props => [clearedCount, clearedAt];
}

/// Estado de proveedores verificados
class ProvidersChecked extends ImageState {
  final Map<String, bool> providerAvailability;
  final String recommendedProvider;
  final DateTime checkedAt;

  ProvidersChecked({
    required this.providerAvailability,
    required this.recommendedProvider,
    DateTime? checkedAt,
  }) : checkedAt = checkedAt ?? DateTime.now();

  @override
  List<Object?> get props => [
    providerAvailability,
    recommendedProvider,
    checkedAt,
  ];
}

/// Estado de estadísticas
class ImageStatsLoaded extends ImageState {
  final ImageBlocStats stats;
  final DateTime loadedAt;

  ImageStatsLoaded({required this.stats, DateTime? loadedAt})
    : loadedAt = loadedAt ?? DateTime.now();

  @override
  List<Object?> get props => [stats, loadedAt];
}

/// Estado de imágenes precargadas
class ImagesPreloaded extends ImageState {
  final int successfulPreloads;
  final int failedPreloads;
  final int totalPreloads;
  final DateTime preloadedAt;

  ImagesPreloaded({
    required this.successfulPreloads,
    required this.failedPreloads,
    required this.totalPreloads,
    DateTime? preloadedAt,
  }) : preloadedAt = preloadedAt ?? DateTime.now();

  @override
  List<Object?> get props => [
    successfulPreloads,
    failedPreloads,
    totalPreloads,
    preloadedAt,
  ];
}

/// Estado de configuración actualizada
class ImageConfigUpdated extends ImageState {
  final int? cacheTTL;
  final bool? useCache;
  final String? preferredProvider;
  final DateTime updatedAt;

  ImageConfigUpdated({
    this.cacheTTL,
    this.useCache,
    this.preferredProvider,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  @override
  List<Object?> get props => [cacheTTL, useCache, preferredProvider, updatedAt];
}

/// Estado de carga cancelada
class ImageLoadCancelled extends ImageState {
  final String imageUrl;
  final DateTime cancelledAt;

  ImageLoadCancelled({required this.imageUrl, DateTime? cancelledAt})
    : cancelledAt = cancelledAt ?? DateTime.now();

  @override
  List<Object?> get props => [imageUrl, cancelledAt];
}

/// Estado de imagen refrescada
class ImageRefreshed extends ImageState {
  final String url;
  final String? previousUrl;
  final bool cacheCleared;
  final DateTime refreshedAt;

  ImageRefreshed({
    required this.url,
    this.previousUrl,
    this.cacheCleared = false,
    DateTime? refreshedAt,
  }) : refreshedAt = refreshedAt ?? DateTime.now();

  @override
  List<Object?> get props => [url, previousUrl, cacheCleared, refreshedAt];
}
