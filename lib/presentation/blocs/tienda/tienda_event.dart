// lib/presentation/blocs/tienda/tienda_event.dart

part of 'tienda_bloc.dart';

/// Eventos base para TiendaBloc
abstract class TiendaEvent extends Equatable {
  const TiendaEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar tiendas
class TiendaLoadRequested extends TiendaEvent {
  final int page;
  final int limit;
  final String? categoriaId;
  final bool? soloActivas;
  final bool forceRefresh;

  const TiendaLoadRequested({
    this.page = 1,
    this.limit = 20,
    this.categoriaId,
    this.soloActivas = true,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [
    page,
    limit,
    categoriaId,
    soloActivas,
    forceRefresh,
  ];

  TiendaLoadRequested copyWith({
    int? page,
    int? limit,
    String? categoriaId,
    bool? soloActivas,
    bool? forceRefresh,
  }) {
    return TiendaLoadRequested(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      categoriaId: categoriaId ?? this.categoriaId,
      soloActivas: soloActivas ?? this.soloActivas,
      forceRefresh: forceRefresh ?? this.forceRefresh,
    );
  }
}

/// Evento para cargar tienda por ID
class TiendaLoadByIdRequested extends TiendaEvent {
  final int tiendaId;
  final bool forceRefresh;

  const TiendaLoadByIdRequested({
    required this.tiendaId,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [tiendaId, forceRefresh];

  TiendaLoadByIdRequested copyWith({int? tiendaId, bool? forceRefresh}) {
    return TiendaLoadByIdRequested(
      tiendaId: tiendaId ?? this.tiendaId,
      forceRefresh: forceRefresh ?? this.forceRefresh,
    );
  }
}

/// Evento para buscar tiendas
class TiendaSearchRequested extends TiendaEvent {
  final String query;
  final int page;
  final int limit;
  final bool forceRefresh;

  const TiendaSearchRequested({
    required this.query,
    this.page = 1,
    this.limit = 20,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [query, page, limit, forceRefresh];

  TiendaSearchRequested copyWith({
    String? query,
    int? page,
    int? limit,
    bool? forceRefresh,
  }) {
    return TiendaSearchRequested(
      query: query ?? this.query,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      forceRefresh: forceRefresh ?? this.forceRefresh,
    );
  }
}

/// Evento para cargar más tiendas (paginación)
class TiendaLoadMoreRequested extends TiendaEvent {
  final int limit;

  const TiendaLoadMoreRequested({this.limit = 20});

  @override
  List<Object?> get props => [limit];
}

/// Evento para refrescar tiendas
class TiendaRefreshRequested extends TiendaEvent {
  const TiendaRefreshRequested();
}

/// Evento para limpiar búsqueda
class TiendaClearSearch extends TiendaEvent {
  const TiendaClearSearch();
}

/// Evento para limpiar error
class TiendaErrorCleared extends TiendaEvent {
  const TiendaErrorCleared();
}

/// Evento para crear nueva tienda
class TiendaCreateRequested extends TiendaEvent {
  final Map<String, dynamic> tiendaData;

  const TiendaCreateRequested({required this.tiendaData});

  @override
  List<Object?> get props => [tiendaData];
}

/// Evento para actualizar tienda
class TiendaUpdateRequested extends TiendaEvent {
  final int tiendaId;
  final Map<String, dynamic> updateData;

  const TiendaUpdateRequested({
    required this.tiendaId,
    required this.updateData,
  });

  @override
  List<Object?> get props => [tiendaId, updateData];
}

/// Evento para eliminar tienda
class TiendaDeleteRequested extends TiendaEvent {
  final int tiendaId;

  const TiendaDeleteRequested({required this.tiendaId});

  @override
  List<Object?> get props => [tiendaId];
}

/// Evento para registrar visita a tienda
class TiendaVisitaRequested extends TiendaEvent {
  final int tiendaId;

  const TiendaVisitaRequested({required this.tiendaId});

  @override
  List<Object?> get props => [tiendaId];
}

/// Evento para obtener tiendas destacadas
class TiendaDestacadasRequested extends TiendaEvent {
  final int limit;

  const TiendaDestacadasRequested({this.limit = 12});

  @override
  List<Object?> get props => [limit];
}

/// Evento para obtener tiendas por propietario
class TiendaByPropietarioRequested extends TiendaEvent {
  final int propietarioId;
  final int page;
  final int limit;
  final bool forceRefresh;

  const TiendaByPropietarioRequested({
    required this.propietarioId,
    this.page = 1,
    this.limit = 20,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [propietarioId, page, limit, forceRefresh];
}

/// Evento para filtrar tiendas por categoría
class TiendaFilterByCategoriaRequested extends TiendaEvent {
  final String categoriaId;
  final int page;
  final int limit;

  const TiendaFilterByCategoriaRequested({
    required this.categoriaId,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [categoriaId, page, limit];
}

/// Evento para cambiar orden de tiendas
class TiendaChangeOrderRequested extends TiendaEvent {
  final String orderBy;
  final bool ascending;

  const TiendaChangeOrderRequested({
    required this.orderBy,
    this.ascending = true,
  });

  @override
  List<Object?> get props => [orderBy, ascending];
}

/// Evento para cambiar filtro de estado
class TiendaChangeEstadoFilterRequested extends TiendaEvent {
  final bool? soloActivas;

  const TiendaChangeEstadoFilterRequested({this.soloActivas});

  @override
  List<Object?> get props => [soloActivas];
}

/// Evento para guardar tienda en favoritos
class TiendaToggleFavoriteRequested extends TiendaEvent {
  final int tiendaId;
  final bool isFavorite;

  const TiendaToggleFavoriteRequested({
    required this.tiendaId,
    required this.isFavorite,
  });

  @override
  List<Object?> get props => [tiendaId, isFavorite];
}

/// Evento para obtener tiendas favoritas
class TiendaFavoritasRequested extends TiendaEvent {
  final int page;
  final int limit;

  const TiendaFavoritasRequested({this.page = 1, this.limit = 20});

  @override
  List<Object?> get props => [page, limit];
}

/// Evento para limpiar filtros
class TiendaClearFilters extends TiendaEvent {
  const TiendaClearFilters();
}

/// Evento para cambiar vista (grid/list)
class TiendaChangeViewRequested extends TiendaEvent {
  final bool isGridView;

  const TiendaChangeViewRequested({required this.isGridView});

  @override
  List<Object?> get props => [isGridView];
}

/// Evento para exportar tiendas
class TiendaExportRequested extends TiendaEvent {
  final String format; // 'csv', 'json', 'pdf'

  const TiendaExportRequested({this.format = 'csv'});

  @override
  List<Object?> get props => [format];
}

/// Evento para sincronizar tiendas offline
class TiendaSyncOfflineRequested extends TiendaEvent {
  const TiendaSyncOfflineRequested();
}

/// Evento para verificar cambios en tiendas
class TiendaCheckForUpdatesRequested extends TiendaEvent {
  const TiendaCheckForUpdatesRequested();
}

/// Evento para obtener estadísticas de tiendas
class TiendaStatsRequested extends TiendaEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const TiendaStatsRequested({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

/// Evento para obtener tiendas cercanas
class TiendaCercanasRequested extends TiendaEvent {
  final double latitude;
  final double longitude;
  final double radius; // en kilómetros
  final int limit;

  const TiendaCercanasRequested({
    required this.latitude,
    required this.longitude,
    this.radius = 10.0,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [latitude, longitude, radius, limit];
}

/// Evento para compartir tienda
class TiendaShareRequested extends TiendaEvent {
  final int tiendaId;
  final String platform; // 'whatsapp', 'facebook', 'twitter', 'copy'

  const TiendaShareRequested({required this.tiendaId, required this.platform});

  @override
  List<Object?> get props => [tiendaId, platform];
}

/// Evento para reportar tienda
class TiendaReportRequested extends TiendaEvent {
  final int tiendaId;
  final String reason;
  final String? description;

  const TiendaReportRequested({
    required this.tiendaId,
    required this.reason,
    this.description,
  });

  @override
  List<Object?> get props => [tiendaId, reason, description];
}

/// Evento para verificar permisos de tienda
class TiendaCheckPermissionsRequested extends TiendaEvent {
  final int tiendaId;

  const TiendaCheckPermissionsRequested({required this.tiendaId});

  @override
  List<Object?> get props => [tiendaId];
}

/// Evento para obtener imágenes de tienda
class TiendaImagesRequested extends TiendaEvent {
  final int tiendaId;
  final bool forceRefresh;

  const TiendaImagesRequested({
    required this.tiendaId,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [tiendaId, forceRefresh];
}

/// Evento para obtener productos de tienda
class TiendaProductsRequested extends TiendaEvent {
  final int tiendaId;
  final int page;
  final int limit;
  final String? estado;

  const TiendaProductsRequested({
    required this.tiendaId,
    this.page = 1,
    this.limit = 20,
    this.estado = 'publicado',
  });

  @override
  List<Object?> get props => [tiendaId, page, limit, estado];
}

/// Evento para obtener horarios de tienda
class TiendaHorariosRequested extends TiendaEvent {
  final int tiendaId;
  final bool forceRefresh;

  const TiendaHorariosRequested({
    required this.tiendaId,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [tiendaId, forceRefresh];
}

/// Evento para obtener valoraciones de tienda
class TiendaValoracionesRequested extends TiendaEvent {
  final int tiendaId;
  final int page;
  final int limit;

  const TiendaValoracionesRequested({
    required this.tiendaId,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [tiendaId, page, limit];
}
