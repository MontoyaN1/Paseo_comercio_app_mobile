// lib/presentation/blocs/image/models/image_bloc_stats.dart

import 'package:equatable/equatable.dart';

/// Estadísticas del ImageBloc
class ImageBlocStats extends Equatable {
  final int fallbackUrlsCount;
  final int currentUrlIndex;
  final bool isConfigured;

  const ImageBlocStats({
    required this.fallbackUrlsCount,
    required this.currentUrlIndex,
    required this.isConfigured,
  });

  /// Verificar si hay más URLs para intentar
  bool get hasMoreUrls => currentUrlIndex < fallbackUrlsCount - 1;

  /// Obtener proveedor actual
  String get currentProvider {
    if (fallbackUrlsCount == 0) return 'none';
    return 'unknown';
  }

  @override
  List<Object?> get props => [fallbackUrlsCount, currentUrlIndex, isConfigured];

  @override
  String toString() {
    return 'ImageBlocStats{fallbackUrlsCount: $fallbackUrlsCount, currentUrlIndex: $currentUrlIndex, isConfigured: $isConfigured, hasMoreUrls: $hasMoreUrls, currentProvider: $currentProvider}';
  }
}
