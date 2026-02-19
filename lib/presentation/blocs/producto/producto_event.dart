// lib/presentation/blocs/producto/producto_event.dart

import 'package:equatable/equatable.dart';

part of 'producto_bloc.dart';

/// Eventos base para ProductoBloc
abstract class ProductoEvent extends Equatable {
  const ProductoEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar productos
class ProductoLoadRequested extends ProductoEvent {
  final int page;
  final int limit;
  final int? tiendaId;
  final int? categoriaId;
  final String? estado;
  final bool forceRefresh;

  const ProductoLoadRequested({
    this.page = 1,
    this.limit = 20,
    this.tiendaId,
    this.categoriaId,
    this.estado = 'publicado',
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [
    page,
    limit,
    tiendaId,
    categoriaId,
    estado,
    forceRefresh,
  ];

  ProductoLoadRequested copyWith({
    int? page,
    int? limit,
    int? tiendaId,
    int? categoriaId,
    String? estado,
    bool? forceRefresh,
  }) {
    return ProductoLoadRequested(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      tiendaId: tiendaId ?? this.tiendaId,
      categoriaId: categoriaId ?? this.categoriaId,
      estado: estado ?? this.estado,
      forceRefresh: forceRefresh ?? this.forceRefresh,
    );
  }
}

/// Evento para cargar producto por ID
class ProductoLoadByIdRequested extends ProductoEvent {
  final int productoId;
  final bool forceRefresh;

  const ProductoLoadByIdRequested({
    required this.productoId,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [productoId, forceRefresh];

  ProductoLoadByIdRequested copyWith({int? productoId, bool? forceRefresh}) {
    return ProductoLoadByIdRequested(
      productoId: productoId ?? this.productoId,
      forceRefresh: forceRefresh ?? this.forceRefresh,
    );
  }
}

/// Evento para cargar más productos (paginación)
class ProductoLoadMoreRequested extends ProductoEvent {
  final int limit;

  const ProductoLoadMoreRequested({this.limit = 20});

  @override
  List<Object?> get props => [limit];
}

/// Evento para refrescar productos
class ProductoRefreshRequested extends ProductoEvent {
  const ProductoRefreshRequested();
}

/// Evento para limpiar error
class ProductoErrorCleared extends ProductoEvent {
  const ProductoErrorCleared();
}

/// Evento para filtrar productos por tienda
class ProductoFilterByTiendaRequested extends ProductoEvent {
  final int tiendaId;
  final int limit;
  final bool forceRefresh;

  const ProductoFilterByTiendaRequested({
    required this.tiendaId,
    this.limit = 20,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [tiendaId, limit, forceRefresh];
}

/// Evento para filtrar productos por categoría
class ProductoFilterByCategoriaRequested extends ProductoEvent {
  final int categoriaId;
  final int limit;
  final bool forceRefresh;

  const ProductoFilterByCategoriaRequested({
    required this.categoriaId,
    this.limit = 20,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [categoriaId, limit, forceRefresh];
}

/// Evento para buscar productos
class ProductoSearchRequested extends ProductoEvent {
  final String query;
  final int page;
  final int limit;
  final int? tiendaId;
  final int? categoriaId;

  const ProductoSearchRequested({
    required this.query,
    this.page = 1,
    this.limit = 20,
    this.tiendaId,
    this.categoriaId,
  });

  @override
  List<Object?> get props => [query, page, limit, tiendaId, categoriaId];
}

/// Evento para crear nuevo producto
class ProductoCreateRequested extends ProductoEvent {
  final Map<String, dynamic> productoData;

  const ProductoCreateRequested({required this.productoData});

  @override
  List<Object?> get props => [productoData];
}

/// Evento para actualizar producto
class ProductoUpdateRequested extends ProductoEvent {
  final int productoId;
  final Map<String, dynamic> updateData;

  const ProductoUpdateRequested({
    required this.productoId,
    required this.updateData,
  });

  @override
  List<Object?> get props => [productoId, updateData];
}

/// Evento para eliminar producto
class ProductoDeleteRequested extends ProductoEvent {
  final int productoId;

  const ProductoDeleteRequested({required this.productoId});

  @override
  List<Object?> get props => [productoId];
}

/// Evento para cambiar estado del producto
class ProductoChangeEstadoRequested extends ProductoEvent {
  final int productoId;
  final String nuevoEstado;

  const ProductoChangeEstadoRequested({
    required this.productoId,
    required this.nuevoEstado,
  });

  @override
  List<Object?> get props => [productoId, nuevoEstado];
}

/// Evento para registrar vista de producto
class ProductoVistaRequested extends ProductoEvent {
  final int productoId;

  const ProductoVistaRequested({required this.productoId});

  @override
  List<Object?> get props => [productoId];
}

/// Evento para obtener productos destacados
class ProductoDestacadosRequested extends ProductoEvent {
  final int limit;

  const ProductoDestacadosRequested({this.limit = 12});

  @override
  List<Object?> get props => [limit];
}

/// Evento para obtener productos recientes
class ProductoRecientesRequested extends ProductoEvent {
  final int limit;

  const ProductoRecientesRequested({this.limit = 12});

  @override
  List<Object?> get props => [limit];
}

/// Evento para limpiar filtros
class ProductoClearFilters extends ProductoEvent {
  const ProductoClearFilters();
}

/// Evento para obtener productos por etiqueta
class ProductoByEtiquetaRequested extends ProductoEvent {
  final String etiqueta;
  final int page;
  final int limit;

  const ProductoByEtiquetaRequested({
    required this.etiqueta,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [etiqueta, page, limit];
}

/// Evento para limpiar búsqueda
class ProductoClearSearch extends ProductoEvent {
  const ProductoClearSearch();
}

/// Evento para cambiar orden de productos
class ProductoChangeOrderRequested extends ProductoEvent {
  final String orderBy;
  final bool ascending;

  const ProductoChangeOrderRequested({
    required this.orderBy,
    this.ascending = true,
  });

  @override
  List<Object?> get props => [orderBy, ascending];
}

/// Evento para obtener productos con descuento
class ProductoConDescuentoRequested extends ProductoEvent {
  final int page;
  final int limit;

  const ProductoConDescuentoRequested({this.page = 1, this.limit = 20});

  @override
  List<Object?> get props => [page, limit];
}

/// Evento para obtener productos por rango de precio
class ProductoByPrecioRangeRequested extends ProductoEvent {
  final double minPrecio;
  final double maxPrecio;
  final int page;
  final int limit;

  const ProductoByPrecioRangeRequested({
    required this.minPrecio,
    required this.maxPrecio,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [minPrecio, maxPrecio, page, limit];
}

/// Evento para obtener productos similares
class ProductoSimilaresRequested extends ProductoEvent {
  final int productoId;
  final int limit;

  const ProductoSimilaresRequested({required this.productoId, this.limit = 6});

  @override
  List<Object?> get props => [productoId, limit];
}

/// Evento para obtener productos relacionados
class ProductoRelacionadosRequested extends ProductoEvent {
  final int productoId;
  final int limit;

  const ProductoRelacionadosRequested({
    required this.productoId,
    this.limit = 6,
  });

  @override
  List<Object?> get props => [productoId, limit];
}

/// Evento para obtener productos más vendidos
class ProductoMasVendidosRequested extends ProductoEvent {
  final int limit;

  const ProductoMasVendidosRequested({this.limit = 12});

  @override
  List<Object?> get props => [limit];
}

/// Evento para obtener productos mejor valorados
class ProductoMejorValoradosRequested extends ProductoEvent {
  final int limit;

  const ProductoMejorValoradosRequested({this.limit = 12});

  @override
  List<Object?> get props => [limit];
}

/// Evento para obtener productos con stock bajo
class ProductoStockBajoRequested extends ProductoEvent {
  final int limit;

  const ProductoStockBajoRequested({this.limit = 20});

  @override
  List<Object?> get props => [limit];
}

/// Evento para verificar disponibilidad de producto
class ProductoCheckDisponibilidadRequested extends ProductoEvent {
  final int productoId;
  final int cantidad;

  const ProductoCheckDisponibilidadRequested({
    required this.productoId,
    required this.cantidad,
  });

  @override
  List<Object?> get props => [productoId, cantidad];
}

/// Evento para obtener valoraciones de producto
class ProductoValoracionesRequested extends ProductoEvent {
  final int productoId;
  final int page;
  final int limit;

  const ProductoValoracionesRequested({
    required this.productoId,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [productoId, page, limit];
}

/// Evento para crear valoración de producto
class ProductoCreateValoracionRequested extends ProductoEvent {
  final int productoId;
  final Map<String, dynamic> valoracionData;

  const ProductoCreateValoracionRequested({
    required this.productoId,
    required this.valoracionData,
  });

  @override
  List<Object?> get props => [productoId, valoracionData];
}

/// Evento para obtener imágenes de producto
class ProductoImagesRequested extends ProductoEvent {
  final int productoId;
  final bool forceRefresh;

  const ProductoImagesRequested({
    required this.productoId,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [productoId, forceRefresh];
}

/// Evento para compartir producto
class ProductoShareRequested extends ProductoEvent {
  final int productoId;
  final String platform;

  const ProductoShareRequested({
    required this.productoId,
    required this.platform,
  });

  @override
  List<Object?> get props => [productoId, platform];
}

/// Evento para guardar producto en favoritos
class ProductoToggleFavoriteRequested extends ProductoEvent {
  final int productoId;
  final bool isFavorite;

  const ProductoToggleFavoriteRequested({
    required this.productoId,
    required this.isFavorite,
  });

  @override
  List<Object?> get props => [productoId, isFavorite];
}

/// Evento para obtener productos favoritos
class ProductoFavoritosRequested extends ProductoEvent {
  final int page;
  final int limit;

  const ProductoFavoritosRequested({this.page = 1, this.limit = 20});

  @override
  List<Object?> get props => [page, limit];
}

/// Evento para reportar producto
class ProductoReportRequested extends ProductoEvent {
  final int productoId;
  final String reason;
  final String? description;

  const ProductoReportRequested({
    required this.productoId,
    required this.reason,
    this.description,
  });

  @override
  List<Object?> get props => [productoId, reason, description];
}

/// Evento para verificar permisos de producto
class ProductoCheckPermissionsRequested extends ProductoEvent {
  final int productoId;

  const ProductoCheckPermissionsRequested({required this.productoId});

  @override
  List<Object?> get props => [productoId];
}

/// Evento para sincronizar productos offline
class ProductoSyncOfflineRequested extends ProductoEvent {
  const ProductoSyncOfflineRequested();
}

/// Evento para verificar cambios en productos
class ProductoCheckForUpdatesRequested extends ProductoEvent {
  const ProductoCheckForUpdatesRequested();
}

/// Evento para exportar productos
class ProductoExportRequested extends ProductoEvent {
  final String format;

  const ProductoExportRequested({this.format = 'csv'});

  @override
  List<Object?> get props => [format];
}

/// Evento para cambiar vista (grid/list)
class ProductoChangeViewRequested extends ProductoEvent {
  final bool isGridView;

  const ProductoChangeViewRequested({required this.isGridView});

  @override
  List<Object?> get props => [isGridView];
}
