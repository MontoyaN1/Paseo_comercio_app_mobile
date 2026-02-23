// lib/presentation/blocs/tienda/tienda_state.dart

part of 'tienda_bloc.dart';

/// Estados base para TiendaBloc
abstract class TiendaState extends Equatable {
  const TiendaState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial - Aplicación cargando o sin tiendas cargadas
class TiendaInitial extends TiendaState {
  const TiendaInitial();
}

/// Estado de carga - Operación en progreso
class TiendaLoading extends TiendaState {
  const TiendaLoading();
}

/// Estado de carga de búsqueda - Búsqueda en progreso
class TiendaSearchLoading extends TiendaState {
  final String query;

  const TiendaSearchLoading({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Estado de carga más - Paginación en progreso
class TiendaLoadingMore extends TiendaState {
  const TiendaLoadingMore();
}

/// Estado cargado - Tiendas cargadas exitosamente
class TiendaLoaded extends TiendaState {
  final List<Map<String, dynamic>> tiendas;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final String? searchQuery;
  final String? categoriaId;
  final bool? soloActivas;

  const TiendaLoaded({
    required this.tiendas,
    required this.currentPage,
    required this.hasMore,
    this.isLoadingMore = false,
    this.searchQuery,
    this.categoriaId,
    this.soloActivas = true,
  });

  @override
  List<Object?> get props => [
    tiendas,
    currentPage,
    hasMore,
    isLoadingMore,
    searchQuery,
    categoriaId,
    soloActivas,
  ];

  TiendaLoaded copyWith({
    List<Map<String, dynamic>>? tiendas,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    String? searchQuery,
    String? categoriaId,
    bool? soloActivas,
  }) {
    return TiendaLoaded(
      tiendas: tiendas ?? this.tiendas,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      searchQuery: searchQuery ?? this.searchQuery,
      categoriaId: categoriaId ?? this.categoriaId,
      soloActivas: soloActivas ?? this.soloActivas,
    );
  }
}

/// Estado de búsqueda cargada - Resultados de búsqueda cargados
class TiendaSearchLoaded extends TiendaState {
  final List<Map<String, dynamic>> tiendas;
  final String query;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  const TiendaSearchLoaded({
    required this.tiendas,
    required this.query,
    required this.currentPage,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [
    tiendas,
    query,
    currentPage,
    hasMore,
    isLoadingMore,
  ];

  TiendaSearchLoaded copyWith({
    List<Map<String, dynamic>>? tiendas,
    String? query,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return TiendaSearchLoaded(
      tiendas: tiendas ?? this.tiendas,
      query: query ?? this.query,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// Estado de detalle cargado - Detalle de tienda cargado
class TiendaDetailLoaded extends TiendaState {
  final Map<String, dynamic> tienda;

  const TiendaDetailLoaded({required this.tienda});

  @override
  List<Object?> get props => [tienda];

  TiendaDetailLoaded copyWith({Map<String, dynamic>? tienda}) {
    return TiendaDetailLoaded(tienda: tienda ?? this.tienda);
  }
}

/// Estado vacío - No hay tiendas para mostrar
class TiendaEmpty extends TiendaState {
  final String? message;

  const TiendaEmpty({this.message});

  @override
  List<Object?> get props => [message];
}

/// Estado de búsqueda vacía - No hay resultados de búsqueda
class TiendaSearchEmpty extends TiendaState {
  final String query;
  final String? message;

  const TiendaSearchEmpty({required this.query, this.message});

  @override
  List<Object?> get props => [query, message];
}

/// Estado de error - Ocurrió un error durante la operación
class TiendaError extends TiendaState {
  final String message;
  final Object? error;
  final StackTrace? stackTrace;
  final bool isRetryable;

  const TiendaError({
    required this.message,
    this.error,
    this.stackTrace,
    this.isRetryable = true,
  });

  @override
  List<Object?> get props => [message, error, stackTrace, isRetryable];

  TiendaError copyWith({
    String? message,
    Object? error,
    StackTrace? stackTrace,
    bool? isRetryable,
  }) {
    return TiendaError(
      message: message ?? this.message,
      error: error ?? this.error,
      stackTrace: stackTrace ?? this.stackTrace,
      isRetryable: isRetryable ?? this.isRetryable,
    );
  }
}

/// Estado de creación exitosa - Tienda creada exitosamente
class TiendaCreated extends TiendaState {
  final Map<String, dynamic> tienda;
  final String message;

  const TiendaCreated({
    required this.tienda,
    this.message = 'Tienda creada exitosamente',
  });

  @override
  List<Object?> get props => [tienda, message];
}

/// Estado de actualización exitosa - Tienda actualizada exitosamente
class TiendaUpdated extends TiendaState {
  final Map<String, dynamic> tienda;
  final String message;

  const TiendaUpdated({
    required this.tienda,
    this.message = 'Tienda actualizada exitosamente',
  });

  @override
  List<Object?> get props => [tienda, message];
}

/// Estado de eliminación exitosa - Tienda eliminada exitosamente
class TiendaDeleted extends TiendaState {
  final int tiendaId;
  final String message;

  const TiendaDeleted({
    required this.tiendaId,
    this.message = 'Tienda eliminada exitosamente',
  });

  @override
  List<Object?> get props => [tiendaId, message];
}

/// Estado de visita registrada - Visita a tienda registrada
class TiendaVisitaRegistered extends TiendaState {
  final int tiendaId;
  final String message;

  const TiendaVisitaRegistered({
    required this.tiendaId,
    this.message = 'Visita registrada exitosamente',
  });

  @override
  List<Object?> get props => [tiendaId, message];
}

/// Estado de tiendas destacadas cargadas
class TiendaDestacadasLoaded extends TiendaState {
  final List<Map<String, dynamic>> tiendas;

  const TiendaDestacadasLoaded({required this.tiendas});

  @override
  List<Object?> get props => [tiendas];
}

/// Estado de tiendas por propietario cargadas
class TiendaByPropietarioLoaded extends TiendaState {
  final List<Map<String, dynamic>> tiendas;
  final int propietarioId;
  final int currentPage;
  final bool hasMore;

  const TiendaByPropietarioLoaded({
    required this.tiendas,
    required this.propietarioId,
    required this.currentPage,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [tiendas, propietarioId, currentPage, hasMore];
}

/// Estado de tiendas filtradas por categoría
class TiendaFilteredByCategoria extends TiendaState {
  final List<Map<String, dynamic>> tiendas;
  final String categoriaId;
  final int currentPage;
  final bool hasMore;

  const TiendaFilteredByCategoria({
    required this.tiendas,
    required this.categoriaId,
    required this.currentPage,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [tiendas, categoriaId, currentPage, hasMore];
}

/// Estado de tiendas favoritas cargadas
class TiendaFavoritasLoaded extends TiendaState {
  final List<Map<String, dynamic>> tiendas;
  final int currentPage;
  final bool hasMore;

  const TiendaFavoritasLoaded({
    required this.tiendas,
    required this.currentPage,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [tiendas, currentPage, hasMore];
}

/// Estado de favorito actualizado
class TiendaFavoriteUpdated extends TiendaState {
  final int tiendaId;
  final bool isFavorite;
  final String message;

  const TiendaFavoriteUpdated({
    required this.tiendaId,
    required this.isFavorite,
    this.message = 'Favorito actualizado exitosamente',
  });

  @override
  List<Object?> get props => [tiendaId, isFavorite, message];
}

/// Estado de tiendas cercanas cargadas
class TiendaCercanasLoaded extends TiendaState {
  final List<Map<String, dynamic>> tiendas;
  final double latitude;
  final double longitude;
  final double radius;

  const TiendaCercanasLoaded({
    required this.tiendas,
    required this.latitude,
    required this.longitude,
    required this.radius,
  });

  @override
  List<Object?> get props => [tiendas, latitude, longitude, radius];
}

/// Estado de imágenes de tienda cargadas
class TiendaImagesLoaded extends TiendaState {
  final int tiendaId;
  final List<Map<String, dynamic>> imagenes;

  const TiendaImagesLoaded({required this.tiendaId, required this.imagenes});

  @override
  List<Object?> get props => [tiendaId, imagenes];
}

/// Estado de productos de tienda cargados
class TiendaProductsLoaded extends TiendaState {
  final int tiendaId;
  final List<Map<String, dynamic>> productos;
  final int currentPage;
  final bool hasMore;

  const TiendaProductsLoaded({
    required this.tiendaId,
    required this.productos,
    required this.currentPage,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [tiendaId, productos, currentPage, hasMore];
}

/// Estado de horarios de tienda cargados
class TiendaHorariosLoaded extends TiendaState {
  final int tiendaId;
  final List<Map<String, dynamic>> horarios;

  const TiendaHorariosLoaded({required this.tiendaId, required this.horarios});

  @override
  List<Object?> get props => [tiendaId, horarios];
}

/// Estado de valoraciones de tienda cargadas
class TiendaValoracionesLoaded extends TiendaState {
  final int tiendaId;
  final List<Map<String, dynamic>> valoraciones;
  final int currentPage;
  final bool hasMore;
  final double promedioValoracion;

  const TiendaValoracionesLoaded({
    required this.tiendaId,
    required this.valoraciones,
    required this.currentPage,
    required this.hasMore,
    required this.promedioValoracion,
  });

  @override
  List<Object?> get props => [
    tiendaId,
    valoraciones,
    currentPage,
    hasMore,
    promedioValoracion,
  ];
}

/// Estado de estadísticas de tiendas cargadas
class TiendaStatsLoaded extends TiendaState {
  final Map<String, dynamic> estadisticas;
  final DateTime startDate;
  final DateTime endDate;

  const TiendaStatsLoaded({
    required this.estadisticas,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [estadisticas, startDate, endDate];
}

/// Estado de exportación completada
class TiendaExportCompleted extends TiendaState {
  final String filePath;
  final String format;
  final String message;

  const TiendaExportCompleted({
    required this.filePath,
    required this.format,
    this.message = 'Exportación completada exitosamente',
  });

  @override
  List<Object?> get props => [filePath, format, message];
}

/// Estado de sincronización offline completada
class TiendaSyncOfflineCompleted extends TiendaState {
  final int tiendasSincronizadas;
  final String message;

  const TiendaSyncOfflineCompleted({
    required this.tiendasSincronizadas,
    this.message = 'Sincronización offline completada',
  });

  @override
  List<Object?> get props => [tiendasSincronizadas, message];
}

/// Estado de cambios detectados
class TiendaUpdatesDetected extends TiendaState {
  final int nuevasTiendas;
  final int tiendasActualizadas;
  final int tiendasEliminadas;

  const TiendaUpdatesDetected({
    required this.nuevasTiendas,
    required this.tiendasActualizadas,
    required this.tiendasEliminadas,
  });

  @override
  List<Object?> get props => [
    nuevasTiendas,
    tiendasActualizadas,
    tiendasEliminadas,
  ];
}

/// Estado de permisos verificados
class TiendaPermissionsChecked extends TiendaState {
  final int tiendaId;
  final Map<String, bool> permisos;
  final bool tienePermisos;

  const TiendaPermissionsChecked({
    required this.tiendaId,
    required this.permisos,
    required this.tienePermisos,
  });

  @override
  List<Object?> get props => [tiendaId, permisos, tienePermisos];
}

/// Estado de reporte enviado
class TiendaReportSent extends TiendaState {
  final int tiendaId;
  final String message;

  const TiendaReportSent({
    required this.tiendaId,
    this.message = 'Reporte enviado exitosamente',
  });

  @override
  List<Object?> get props => [tiendaId, message];
}

/// Estado de tienda compartida
class TiendaShared extends TiendaState {
  final int tiendaId;
  final String platform;
  final String message;

  const TiendaShared({
    required this.tiendaId,
    required this.platform,
    this.message = 'Tienda compartida exitosamente',
  });

  @override
  List<Object?> get props => [tiendaId, platform, message];
}

/// Estado de sin conexión - Modo offline activado
class TiendaOfflineMode extends TiendaState {
  final List<Map<String, dynamic>> tiendasOffline;
  final String message;

  const TiendaOfflineMode({
    required this.tiendasOffline,
    this.message = 'Modo offline activado',
  });

  @override
  List<Object?> get props => [tiendasOffline, message];
}

/// Estado de caché cargada - Datos cargados desde caché
class TiendaCacheLoaded extends TiendaState {
  final List<Map<String, dynamic>> tiendas;
  final bool isStale;
  final DateTime lastUpdated;

  const TiendaCacheLoaded({
    required this.tiendas,
    required this.isStale,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [tiendas, isStale, lastUpdated];
}

/// Estado de validación fallida - Error en validación de datos
class TiendaValidationFailed extends TiendaState {
  final Map<String, String> errors;
  final String message;

  const TiendaValidationFailed({
    required this.errors,
    this.message = 'Error de validación',
  });

  @override
  List<Object?> get props => [errors, message];
}

/// Estado de operación no permitida - Permisos insuficientes
class TiendaOperationNotAllowed extends TiendaState {
  final String operation;
  final String message;

  const TiendaOperationNotAllowed({
    required this.operation,
    this.message = 'Operación no permitida',
  });

  @override
  List<Object?> get props => [operation, message];
}

/// Estado de límite alcanzado - Límite de operaciones alcanzado
class TiendaLimitReached extends TiendaState {
  final String limitType;
  final int current;
  final int max;
  final String message;

  const TiendaLimitReached({
    required this.limitType,
    required this.current,
    required this.max,
    this.message = 'Límite alcanzado',
  });

  @override
  List<Object?> get props => [limitType, current, max, message];
}
