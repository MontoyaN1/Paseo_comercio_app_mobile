// lib/presentation/blocs/producto/producto_state.dart

part of 'producto_bloc.dart';

/// Estados base para ProductoBloc
abstract class ProductoState extends Equatable {
  const ProductoState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial - Aplicación cargando o sin productos cargados
class ProductoInitial extends ProductoState {
  const ProductoInitial();
}

/// Estado de carga - Operación en progreso
class ProductoLoading extends ProductoState {
  const ProductoLoading();
}

/// Estado de carga más - Paginación en progreso
class ProductoLoadingMore extends ProductoState {
  const ProductoLoadingMore();
}

/// Estado de búsqueda cargando - Búsqueda en progreso
class ProductoSearchLoading extends ProductoState {
  final String query;

  const ProductoSearchLoading({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Estado cargado - Productos cargados exitosamente
class ProductoLoaded extends ProductoState {
  final List<Map<String, dynamic>> productos;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final int? tiendaId;
  final int? categoriaId;
  final String? estado;

  const ProductoLoaded({
    required this.productos,
    required this.currentPage,
    required this.hasMore,
    this.isLoadingMore = false,
    this.tiendaId,
    this.categoriaId,
    this.estado = 'publicado',
  });

  @override
  List<Object?> get props => [
    productos,
    currentPage,
    hasMore,
    isLoadingMore,
    tiendaId,
    categoriaId,
    estado,
  ];

  ProductoLoaded copyWith({
    List<Map<String, dynamic>>? productos,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    int? tiendaId,
    int? categoriaId,
    String? estado,
  }) {
    return ProductoLoaded(
      productos: productos ?? this.productos,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      tiendaId: tiendaId ?? this.tiendaId,
      categoriaId: categoriaId ?? this.categoriaId,
      estado: estado ?? this.estado,
    );
  }
}

/// Estado de búsqueda cargada - Resultados de búsqueda cargados
class ProductoSearchLoaded extends ProductoState {
  final List<Map<String, dynamic>> productos;
  final String query;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final int? tiendaId;
  final int? categoriaId;

  const ProductoSearchLoaded({
    required this.productos,
    required this.query,
    required this.currentPage,
    required this.hasMore,
    this.isLoadingMore = false,
    this.tiendaId,
    this.categoriaId,
  });

  @override
  List<Object?> get props => [
    productos,
    query,
    currentPage,
    hasMore,
    isLoadingMore,
    tiendaId,
    categoriaId,
  ];

  ProductoSearchLoaded copyWith({
    List<Map<String, dynamic>>? productos,
    String? query,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    int? tiendaId,
    int? categoriaId,
  }) {
    return ProductoSearchLoaded(
      productos: productos ?? this.productos,
      query: query ?? this.query,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      tiendaId: tiendaId ?? this.tiendaId,
      categoriaId: categoriaId ?? this.categoriaId,
    );
  }
}

/// Estado de detalle cargado - Detalle de producto cargado
class ProductoDetailLoaded extends ProductoState {
  final Map<String, dynamic> producto;

  const ProductoDetailLoaded({required this.producto});

  @override
  List<Object?> get props => [producto];

  ProductoDetailLoaded copyWith({Map<String, dynamic>? producto}) {
    return ProductoDetailLoaded(producto: producto ?? this.producto);
  }
}

/// Estado vacío - No hay productos para mostrar
class ProductoEmpty extends ProductoState {
  final String? message;

  const ProductoEmpty({this.message});

  @override
  List<Object?> get props => [message];
}

/// Estado de búsqueda vacía - No hay resultados de búsqueda
class ProductoSearchEmpty extends ProductoState {
  final String query;
  final String? message;

  const ProductoSearchEmpty({required this.query, this.message});

  @override
  List<Object?> get props => [query, message];
}

/// Estado de error - Ocurrió un error durante la operación
class ProductoError extends ProductoState {
  final String message;
  final Object? error;
  final StackTrace? stackTrace;
  final bool isRetryable;

  const ProductoError({
    required this.message,
    this.error,
    this.stackTrace,
    this.isRetryable = true,
  });

  @override
  List<Object?> get props => [message, error, stackTrace, isRetryable];

  ProductoError copyWith({
    String? message,
    Object? error,
    StackTrace? stackTrace,
    bool? isRetryable,
  }) {
    return ProductoError(
      message: message ?? this.message,
      error: error ?? this.error,
      stackTrace: stackTrace ?? this.stackTrace,
      isRetryable: isRetryable ?? this.isRetryable,
    );
  }
}

/// Estado de creación exitosa - Producto creado exitosamente
class ProductoCreated extends ProductoState {
  final Map<String, dynamic> producto;
  final String message;

  const ProductoCreated({
    required this.producto,
    this.message = 'Producto creado exitosamente',
  });

  @override
  List<Object?> get props => [producto, message];
}

/// Estado de actualización exitosa - Producto actualizado exitosamente
class ProductoUpdated extends ProductoState {
  final Map<String, dynamic> producto;
  final String message;

  const ProductoUpdated({
    required this.producto,
    this.message = 'Producto actualizado exitosamente',
  });

  @override
  List<Object?> get props => [producto, message];
}

/// Estado de eliminación exitosa - Producto eliminado exitosamente
class ProductoDeleted extends ProductoState {
  final int productoId;
  final String message;

  const ProductoDeleted({
    required this.productoId,
    this.message = 'Producto eliminado exitosamente',
  });

  @override
  List<Object?> get props => [productoId, message];
}

/// Estado de cambio de estado exitoso
class ProductoEstadoChanged extends ProductoState {
  final int productoId;
  final String nuevoEstado;
  final String message;

  const ProductoEstadoChanged({
    required this.productoId,
    required this.nuevoEstado,
    this.message = 'Estado del producto actualizado exitosamente',
  });

  @override
  List<Object?> get props => [productoId, nuevoEstado, message];
}

/// Estado de visita registrada - Visita a producto registrada
class ProductoVistaRegistered extends ProductoState {
  final int productoId;
  final String message;

  const ProductoVistaRegistered({
    required this.productoId,
    this.message = 'Visita registrada exitosamente',
  });

  @override
  List<Object?> get props => [productoId, message];
}

/// Estado de productos destacados cargados
class ProductoDestacadosLoaded extends ProductoState {
  final List<Map<String, dynamic>> productos;

  const ProductoDestacadosLoaded({required this.productos});

  @override
  List<Object?> get props => [productos];
}

/// Estado de productos recientes cargados
class ProductoRecientesLoaded extends ProductoState {
  final List<Map<String, dynamic>> productos;

  const ProductoRecientesLoaded({required this.productos});

  @override
  List<Object?> get props => [productos];
}

/// Estado de productos por etiqueta cargados
class ProductoByEtiquetaLoaded extends ProductoState {
  final List<Map<String, dynamic>> productos;
  final String etiqueta;
  final int currentPage;
  final bool hasMore;

  const ProductoByEtiquetaLoaded({
    required this.productos,
    required this.etiqueta,
    required this.currentPage,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [productos, etiqueta, currentPage, hasMore];
}

/// Estado de productos con descuento cargados
class ProductoConDescuentoLoaded extends ProductoState {
  final List<Map<String, dynamic>> productos;
  final int currentPage;
  final bool hasMore;

  const ProductoConDescuentoLoaded({
    required this.productos,
    required this.currentPage,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [productos, currentPage, hasMore];
}

/// Estado de productos por rango de precio cargados
class ProductoByPrecioRangeLoaded extends ProductoState {
  final List<Map<String, dynamic>> productos;
  final double minPrecio;
  final double maxPrecio;
  final int currentPage;
  final bool hasMore;

  const ProductoByPrecioRangeLoaded({
    required this.productos,
    required this.minPrecio,
    required this.maxPrecio,
    required this.currentPage,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [
    productos,
    minPrecio,
    maxPrecio,
    currentPage,
    hasMore,
  ];
}

/// Estado de productos similares cargados
class ProductoSimilaresLoaded extends ProductoState {
  final int productoId;
  final List<Map<String, dynamic>> productos;

  const ProductoSimilaresLoaded({
    required this.productoId,
    required this.productos,
  });

  @override
  List<Object?> get props => [productoId, productos];
}

/// Estado de productos relacionados cargados
class ProductoRelacionadosLoaded extends ProductoState {
  final int productoId;
  final List<Map<String, dynamic>> productos;

  const ProductoRelacionadosLoaded({
    required this.productoId,
    required this.productos,
  });

  @override
  List<Object?> get props => [productoId, productos];
}

/// Estado de productos más vendidos cargados
class ProductoMasVendidosLoaded extends ProductoState {
  final List<Map<String, dynamic>> productos;

  const ProductoMasVendidosLoaded({required this.productos});

  @override
  List<Object?> get props => [productos];
}

/// Estado de productos mejor valorados cargados
class ProductoMejorValoradosLoaded extends ProductoState {
  final List<Map<String, dynamic>> productos;

  const ProductoMejorValoradosLoaded({required this.productos});

  @override
  List<Object?> get props => [productos];
}

/// Estado de productos con stock bajo cargados
class ProductoStockBajoLoaded extends ProductoState {
  final List<Map<String, dynamic>> productos;

  const ProductoStockBajoLoaded({required this.productos});

  @override
  List<Object?> get props => [productos];
}

/// Estado de disponibilidad verificada
class ProductoDisponibilidadChecked extends ProductoState {
  final int productoId;
  final int cantidad;
  final bool disponible;
  final String? message;

  const ProductoDisponibilidadChecked({
    required this.productoId,
    required this.cantidad,
    required this.disponible,
    this.message,
  });

  @override
  List<Object?> get props => [productoId, cantidad, disponible, message];
}

/// Estado de valoraciones de producto cargadas
class ProductoValoracionesLoaded extends ProductoState {
  final int productoId;
  final List<Map<String, dynamic>> valoraciones;
  final int currentPage;
  final bool hasMore;
  final double promedioValoracion;

  const ProductoValoracionesLoaded({
    required this.productoId,
    required this.valoraciones,
    required this.currentPage,
    required this.hasMore,
    required this.promedioValoracion,
  });

  @override
  List<Object?> get props => [
    productoId,
    valoraciones,
    currentPage,
    hasMore,
    promedioValoracion,
  ];
}

/// Estado de valoración creada exitosamente
class ProductoValoracionCreated extends ProductoState {
  final int productoId;
  final Map<String, dynamic> valoracion;
  final String message;

  const ProductoValoracionCreated({
    required this.productoId,
    required this.valoracion,
    this.message = 'Valoración creada exitosamente',
  });

  @override
  List<Object?> get props => [productoId, valoracion, message];
}

/// Estado de imágenes de producto cargadas
class ProductoImagesLoaded extends ProductoState {
  final int productoId;
  final List<Map<String, dynamic>> imagenes;

  const ProductoImagesLoaded({
    required this.productoId,
    required this.imagenes,
  });

  @override
  List<Object?> get props => [productoId, imagenes];
}

/// Estado de producto compartido
class ProductoShared extends ProductoState {
  final int productoId;
  final String platform;
  final String message;

  const ProductoShared({
    required this.productoId,
    required this.platform,
    this.message = 'Producto compartido exitosamente',
  });

  @override
  List<Object?> get props => [productoId, platform, message];
}

/// Estado de favorito actualizado
class ProductoFavoriteUpdated extends ProductoState {
  final int productoId;
  final bool isFavorite;
  final String message;

  const ProductoFavoriteUpdated({
    required this.productoId,
    required this.isFavorite,
    this.message = 'Favorito actualizado exitosamente',
  });

  @override
  List<Object?> get props => [productoId, isFavorite, message];
}

/// Estado de productos favoritos cargados
class ProductoFavoritosLoaded extends ProductoState {
  final List<Map<String, dynamic>> productos;
  final int currentPage;
  final bool hasMore;

  const ProductoFavoritosLoaded({
    required this.productos,
    required this.currentPage,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [productos, currentPage, hasMore];
}

/// Estado de reporte enviado
class ProductoReportSent extends ProductoState {
  final int productoId;
  final String message;

  const ProductoReportSent({
    required this.productoId,
    this.message = 'Reporte enviado exitosamente',
  });

  @override
  List<Object?> get props => [productoId, message];
}

/// Estado de permisos verificados
class ProductoPermissionsChecked extends ProductoState {
  final int productoId;
  final Map<String, bool> permisos;
  final bool tienePermisos;

  const ProductoPermissionsChecked({
    required this.productoId,
    required this.permisos,
    required this.tienePermisos,
  });

  @override
  List<Object?> get props => [productoId, permisos, tienePermisos];
}

/// Estado de sincronización offline completada
class ProductoSyncOfflineCompleted extends ProductoState {
  final int productosSincronizados;
  final String message;

  const ProductoSyncOfflineCompleted({
    required this.productosSincronizados,
    this.message = 'Sincronización offline completada',
  });

  @override
  List<Object?> get props => [productosSincronizados, message];
}

/// Estado de cambios detectados
class ProductoUpdatesDetected extends ProductoState {
  final int nuevosProductos;
  final int productosActualizados;
  final int productosEliminados;

  const ProductoUpdatesDetected({
    required this.nuevosProductos,
    required this.productosActualizados,
    required this.productosEliminados,
  });

  @override
  List<Object?> get props => [
    nuevosProductos,
    productosActualizados,
    productosEliminados,
  ];
}

/// Estado de exportación completada
class ProductoExportCompleted extends ProductoState {
  final String filePath;
  final String format;
  final String message;

  const ProductoExportCompleted({
    required this.filePath,
    required this.format,
    this.message = 'Exportación completada exitosamente',
  });

  @override
  List<Object?> get props => [filePath, format, message];
}

/// Estado de sin conexión - Modo offline activado
class ProductoOfflineMode extends ProductoState {
  final List<Map<String, dynamic>> productosOffline;
  final String message;

  const ProductoOfflineMode({
    required this.productosOffline,
    this.message = 'Modo offline activado',
  });

  @override
  List<Object?> get props => [productosOffline, message];
}

/// Estado de caché cargada - Datos cargados desde caché
class ProductoCacheLoaded extends ProductoState {
  final List<Map<String, dynamic>> productos;
  final bool isStale;
  final DateTime lastUpdated;

  const ProductoCacheLoaded({
    required this.productos,
    required this.isStale,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [productos, isStale, lastUpdated];
}

/// Estado de validación fallida - Error en validación de datos
class ProductoValidationFailed extends ProductoState {
  final Map<String, String> errors;
  final String message;

  const ProductoValidationFailed({
    required this.errors,
    this.message = 'Error de validación',
  });

  @override
  List<Object?> get props => [errors, message];
}

/// Estado de operación no permitida - Permisos insuficientes
class ProductoOperationNotAllowed extends ProductoState {
  final String operation;
  final String message;

  const ProductoOperationNotAllowed({
    required this.operation,
    this.message = 'Operación no permitida',
  });

  @override
  List<Object?> get props => [operation, message];
}
