// lib/presentation/blocs/plazoleta/plazoleta_state.dart

import 'package:equatable/equatable.dart';

import '../../../domain/entities/plazoleta.dart';
import '../../../domain/entities/imagen_base.dart';
import '../../../domain/entities/producto.dart';
import '../../../domain/entities/tienda.dart';
import '../../../domain/failures/failure.dart';

/// Estados para el BLoC de Plazoletas
abstract class PlazoletaState extends Equatable {
  const PlazoletaState();

  @override
  List<Object?> get props => [];
}

// ========== ESTADOS DE CARGA INICIAL ==========

/// Estado inicial
class PlazoletaInitial extends PlazoletaState {
  const PlazoletaInitial();
}

/// Cargando datos iniciales
class PlazoletaLoading extends PlazoletaState {
  final String? message;

  const PlazoletaLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// Carga completada exitosamente
class PlazoletaLoaded extends PlazoletaState {
  final List<Plazoleta> plazoletas;
  final Plazoleta? plazoletaSeleccionada;
  final List<ImagenBase>? imagenesPlazoleta;
  final List<Producto>? productosPlazoleta;
  final List<Tienda>? tiendasPlazoleta;
  final Map<String, dynamic>? estadisticas;
  final bool hasMore;
  final int currentPage;
  final String? searchQuery;
  final Map<String, dynamic>? filters;
  final bool isLoadingImagenes;

  const PlazoletaLoaded({
    required this.plazoletas,
    this.plazoletaSeleccionada,
    this.imagenesPlazoleta,
    this.productosPlazoleta,
    this.tiendasPlazoleta,
    this.estadisticas,
    this.hasMore = true,
    this.currentPage = 1,
    this.searchQuery,
    this.filters,
    this.isLoadingImagenes = false,
  });

  /// Verificar si hay plazoletas
  bool get hasPlazoletas => plazoletas.isNotEmpty;

  /// Verificar si hay imágenes
  bool get hasImagenes =>
      imagenesPlazoleta != null && imagenesPlazoleta!.isNotEmpty;

  /// Verificar si hay productos
  bool get hasProductos =>
      productosPlazoleta != null && productosPlazoleta!.isNotEmpty;

  /// Verificar si hay tiendas
  bool get hasTiendas =>
      tiendasPlazoleta != null && tiendasPlazoleta!.isNotEmpty;

  /// Obtener imagen principal de la plazoleta seleccionada
  ImagenBase? get imagenPrincipalPlazoleta {
    if (imagenesPlazoleta == null) return null;
    return imagenesPlazoleta!.firstWhere(
      (imagen) => imagen.esPrincipal,
      orElse: () => imagenesPlazoleta!.first,
    );
  }

  /// Copiar con nuevos valores
  PlazoletaLoaded copyWith({
    List<Plazoleta>? plazoletas,
    Plazoleta? plazoletaSeleccionada,
    List<ImagenBase>? imagenesPlazoleta,
    List<Producto>? productosPlazoleta,
    List<Tienda>? tiendasPlazoleta,
    Map<String, dynamic>? estadisticas,
    bool? hasMore,
    int? currentPage,
    String? searchQuery,
    Map<String, dynamic>? filters,
    bool? isLoadingImagenes,
  }) {
    return PlazoletaLoaded(
      plazoletas: plazoletas ?? this.plazoletas,
      plazoletaSeleccionada:
          plazoletaSeleccionada ?? this.plazoletaSeleccionada,
      imagenesPlazoleta: imagenesPlazoleta ?? this.imagenesPlazoleta,
      productosPlazoleta: productosPlazoleta ?? this.productosPlazoleta,
      tiendasPlazoleta: tiendasPlazoleta ?? this.tiendasPlazoleta,
      estadisticas: estadisticas ?? this.estadisticas,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      searchQuery: searchQuery ?? this.searchQuery,
      filters: filters ?? this.filters,
      isLoadingImagenes: isLoadingImagenes ?? this.isLoadingImagenes,
    );
  }

  @override
  List<Object?> get props => [
    plazoletas,
    plazoletaSeleccionada,
    imagenesPlazoleta,
    productosPlazoleta,
    tiendasPlazoleta,
    estadisticas,
    hasMore,
    currentPage,
    searchQuery,
    filters,
    isLoadingImagenes,
  ];
}

// ========== ESTADOS DE CARGA ESPECÍFICA ==========

/// Cargando plazoletas activas
class PlazoletasActivasLoading extends PlazoletaState {
  final bool isRefreshing;

  const PlazoletasActivasLoading({this.isRefreshing = false});

  @override
  List<Object?> get props => [isRefreshing];
}

/// Cargando una plazoleta específica
class PlazoletaDetailLoading extends PlazoletaState {
  final int plazoletaId;
  final bool isRefreshing;

  const PlazoletaDetailLoading({
    required this.plazoletaId,
    this.isRefreshing = false,
  });

  @override
  List<Object?> get props => [plazoletaId, isRefreshing];
}

/// Cargando imágenes de plazoleta
class PlazoletaImagenesLoading extends PlazoletaState {
  final int plazoletaId;
  final bool isRefreshing;

  const PlazoletaImagenesLoading({
    required this.plazoletaId,
    this.isRefreshing = false,
  });

  @override
  List<Object?> get props => [plazoletaId, isRefreshing];
}

/// Cargando productos de plazoleta
class PlazoletaProductosLoading extends PlazoletaState {
  final int plazoletaId;
  final bool isRefreshing;

  const PlazoletaProductosLoading({
    required this.plazoletaId,
    this.isRefreshing = false,
  });

  @override
  List<Object?> get props => [plazoletaId, isRefreshing];
}

/// Cargando tiendas de plazoleta
class PlazoletaTiendasLoading extends PlazoletaState {
  final int plazoletaId;
  final bool isRefreshing;

  const PlazoletaTiendasLoading({
    required this.plazoletaId,
    this.isRefreshing = false,
  });

  @override
  List<Object?> get props => [plazoletaId, isRefreshing];
}

/// Cargando estadísticas de plazoleta
class PlazoletaEstadisticasLoading extends PlazoletaState {
  final int plazoletaId;
  final bool isRefreshing;

  const PlazoletaEstadisticasLoading({
    required this.plazoletaId,
    this.isRefreshing = false,
  });

  @override
  List<Object?> get props => [plazoletaId, isRefreshing];
}

// ========== ESTADOS DE ERROR ==========

/// Error general
class PlazoletaErrorState extends PlazoletaState {
  final String message;
  final Failure? failure;
  final StackTrace? stackTrace;
  final bool canRetry;

  const PlazoletaErrorState({
    required this.message,
    this.failure,
    this.stackTrace,
    this.canRetry = true,
  });

  /// Verificar si es error de red
  bool get isNetworkError => failure is NetworkFailure;

  /// Verificar si es error del servidor
  bool get isServerError => failure is ServerFailure;

  /// Verificar si es error de caché
  bool get isCacheError => failure is CacheFailure;

  @override
  List<Object?> get props => [message, failure, stackTrace, canRetry];
}

/// Error al cargar plazoletas activas
class PlazoletasActivasError extends PlazoletaErrorState {
  final bool isRefreshing;

  const PlazoletasActivasError({
    required String message,
    Failure? failure,
    StackTrace? stackTrace,
    bool canRetry = true,
    this.isRefreshing = false,
  }) : super(
         message: message,
         failure: failure,
         stackTrace: stackTrace,
         canRetry: canRetry,
       );

  @override
  List<Object?> get props => [...super.props, isRefreshing];
}

/// Error al cargar detalle de plazoleta
class PlazoletaDetailError extends PlazoletaErrorState {
  final int plazoletaId;
  final bool isRefreshing;

  const PlazoletaDetailError({
    required this.plazoletaId,
    required String message,
    Failure? failure,
    StackTrace? stackTrace,
    bool canRetry = true,
    this.isRefreshing = false,
  }) : super(
         message: message,
         failure: failure,
         stackTrace: stackTrace,
         canRetry: canRetry,
       );

  @override
  List<Object?> get props => [...super.props, plazoletaId, isRefreshing];
}

/// Error al cargar imágenes de plazoleta
class PlazoletaImagenesError extends PlazoletaErrorState {
  final int plazoletaId;
  final bool isRefreshing;

  const PlazoletaImagenesError({
    required this.plazoletaId,
    required String message,
    Failure? failure,
    StackTrace? stackTrace,
    bool canRetry = true,
    this.isRefreshing = false,
  }) : super(
         message: message,
         failure: failure,
         stackTrace: stackTrace,
         canRetry: canRetry,
       );

  @override
  List<Object?> get props => [...super.props, plazoletaId, isRefreshing];
}

/// Error al cargar productos de plazoleta
class PlazoletaProductosError extends PlazoletaErrorState {
  final int plazoletaId;
  final bool isRefreshing;

  const PlazoletaProductosError({
    required this.plazoletaId,
    required String message,
    Failure? failure,
    StackTrace? stackTrace,
    bool canRetry = true,
    this.isRefreshing = false,
  }) : super(
         message: message,
         failure: failure,
         stackTrace: stackTrace,
         canRetry: canRetry,
       );

  @override
  List<Object?> get props => [...super.props, plazoletaId, isRefreshing];
}

/// Error al cargar tiendas de plazoleta
class PlazoletaTiendasError extends PlazoletaErrorState {
  final int plazoletaId;
  final bool isRefreshing;

  const PlazoletaTiendasError({
    required this.plazoletaId,
    required String message,
    Failure? failure,
    StackTrace? stackTrace,
    bool canRetry = true,
    this.isRefreshing = false,
  }) : super(
         message: message,
         failure: failure,
         stackTrace: stackTrace,
         canRetry: canRetry,
       );

  @override
  List<Object?> get props => [...super.props, plazoletaId, isRefreshing];
}

// ========== ESTADOS DE CACHÉ ==========

/// Datos cargados desde caché
class PlazoletaCacheLoaded extends PlazoletaState {
  final List<Plazoleta> plazoletas;
  final DateTime lastUpdated;
  final bool isStale;

  const PlazoletaCacheLoaded({
    required this.plazoletas,
    required this.lastUpdated,
    this.isStale = false,
  });

  /// Verificar si los datos están obsoletos (más de 1 hora)
  bool get isDataStale {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);
    return difference.inHours > 1;
  }

  @override
  List<Object?> get props => [plazoletas, lastUpdated, isStale];
}

/// Sin datos en caché
class PlazoletaNoCache extends PlazoletaState {
  const PlazoletaNoCache();
}

/// Caché limpiado exitosamente
class PlazoletaCacheCleared extends PlazoletaState {
  const PlazoletaCacheCleared();
}

/// Sincronización completada
class PlazoletaSyncCompleted extends PlazoletaState {
  final int updatedCount;
  final DateTime syncTime;

  const PlazoletaSyncCompleted({
    required this.updatedCount,
    required this.syncTime,
  });

  @override
  List<Object?> get props => [updatedCount, syncTime];
}

// ========== ESTADOS DE FILTRADO Y BÚSQUEDA ==========

/// Búsqueda en progreso
class PlazoletaSearching extends PlazoletaState {
  final String query;

  const PlazoletaSearching({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Filtrado en progreso
class PlazoletaFiltering extends PlazoletaState {
  final Map<String, dynamic> filters;

  const PlazoletaFiltering({required this.filters});

  @override
  List<Object?> get props => [filters];
}

/// Sin resultados de búsqueda
class PlazoletaNoResults extends PlazoletaState {
  final String? query;
  final Map<String, dynamic>? filters;

  const PlazoletaNoResults({this.query, this.filters});

  @override
  List<Object?> get props => [query, filters];
}

// ========== ESTADOS DE ACCIONES ESPECÍFICAS ==========

/// Visitas incrementadas exitosamente
class PlazoletaVisitasIncrementadas extends PlazoletaState {
  final int plazoletaId;
  final int nuevasVisitas;

  const PlazoletaVisitasIncrementadas({
    required this.plazoletaId,
    required this.nuevasVisitas,
  });

  @override
  List<Object?> get props => [plazoletaId, nuevasVisitas];
}

/// Plazoleta seleccionada
class PlazoletaSelected extends PlazoletaState {
  final Plazoleta plazoleta;

  const PlazoletaSelected({required this.plazoleta});

  @override
  List<Object?> get props => [plazoleta];
}

/// Plazoleta deseleccionada
class PlazoletaDeselected extends PlazoletaState {
  const PlazoletaDeselected();
}

// ========== ESTADOS DE PAGINACIÓN ==========

/// Cargando más datos (paginación)
class PlazoletaLoadingMore extends PlazoletaState {
  final List<Plazoleta> currentPlazoletas;
  final int currentPage;

  const PlazoletaLoadingMore({
    required this.currentPlazoletas,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [currentPlazoletas, currentPage];
}

/// No hay más datos para cargar
class PlazoletaNoMoreData extends PlazoletaState {
  final List<Plazoleta> plazoletas;
  final int totalPages;

  const PlazoletaNoMoreData({
    required this.plazoletas,
    required this.totalPages,
  });

  @override
  List<Object?> get props => [plazoletas, totalPages];
}

// ========== ESTADOS DE CONEXIÓN ==========

/// Sin conexión a internet
class PlazoletaOffline extends PlazoletaState {
  final List<Plazoleta>? cachedPlazoletas;
  final bool hasCachedData;

  const PlazoletaOffline({this.cachedPlazoletas, this.hasCachedData = false});

  @override
  List<Object?> get props => [cachedPlazoletas, hasCachedData];
}

/// Reconectando
class PlazoletaReconnecting extends PlazoletaState {
  const PlazoletaReconnecting();
}
