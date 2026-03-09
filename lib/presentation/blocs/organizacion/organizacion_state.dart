// lib/presentation/blocs/organizacion/organizacion_state.dart

part of 'organizacion_bloc.dart';

/// Estados base para OrganizacionBloc
abstract class OrganizacionState extends Equatable {
  const OrganizacionState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial - Aplicación cargando o sin organizaciones cargadas
class OrganizacionInitial extends OrganizacionState {
  const OrganizacionInitial();
}

/// Estado de carga - Operación en progreso
class OrganizacionLoading extends OrganizacionState {
  const OrganizacionLoading();
}

/// Estado de carga de búsqueda - Búsqueda en progreso
class OrganizacionSearchLoading extends OrganizacionState {
  final String query;

  const OrganizacionSearchLoading({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Estado de carga más - Paginación en progreso
class OrganizacionLoadingMore extends OrganizacionState {
  const OrganizacionLoadingMore();
}

/// Estado cargado - Organizaciones cargadas exitosamente
class OrganizacionLoaded extends OrganizacionState {
  final List<Organizacion> organizaciones;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final String? searchQuery;
  final TipoOrganizacion? tipoFiltro;
  final bool? soloActivas;

  const OrganizacionLoaded({
    required this.organizaciones,
    required this.currentPage,
    required this.hasMore,
    this.isLoadingMore = false,
    this.searchQuery,
    this.tipoFiltro,
    this.soloActivas,
  });

  /// Copiar con nuevos valores
  OrganizacionLoaded copyWith({
    List<Organizacion>? organizaciones,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    String? searchQuery,
    TipoOrganizacion? tipoFiltro,
    bool? soloActivas,
  }) {
    return OrganizacionLoaded(
      organizaciones: organizaciones ?? this.organizaciones,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      searchQuery: searchQuery ?? this.searchQuery,
      tipoFiltro: tipoFiltro ?? this.tipoFiltro,
      soloActivas: soloActivas ?? this.soloActivas,
    );
  }

  /// Verificar si hay organizaciones
  bool get hasOrganizaciones => organizaciones.isNotEmpty;

  /// Obtener organizaciones activas
  List<Organizacion> get organizacionesActivas {
    return organizaciones.where((org) => org.estaActiva).toList();
  }

  /// Obtener organizaciones populares
  List<Organizacion> get organizacionesPopulares {
    return organizaciones.where((org) => org.esPopular).toList();
  }

  /// Obtener organizaciones por tipo
  List<Organizacion> get organizacionesFundacion {
    return organizaciones.where((org) => org.esFundacion).toList();
  }

  List<Organizacion> get organizacionesAsociacion {
    return organizaciones.where((org) => org.esAsociacion).toList();
  }

  List<Organizacion> get organizacionesCooperativa {
    return organizaciones.where((org) => org.esCooperativa).toList();
  }

  List<Organizacion> get organizacionesEmpresa {
    return organizaciones.where((org) => org.esEmpresa).toList();
  }

  List<Organizacion> get organizacionesComunidad {
    return organizaciones.where((org) => org.esComunidad).toList();
  }

  @override
  List<Object?> get props => [
    organizaciones,
    currentPage,
    hasMore,
    isLoadingMore,
    searchQuery,
    tipoFiltro,
    soloActivas,
  ];
}

/// Estado de detalle cargado - Detalle de organización cargado
class OrganizacionDetailLoaded extends OrganizacionState {
  final Organizacion organizacion;
  final List<Map<String, dynamic>>? tiendas;
  final List<Map<String, dynamic>>? miembros;
  final bool isLoadingTiendas;
  final bool isLoadingMiembros;

  const OrganizacionDetailLoaded({
    required this.organizacion,
    this.tiendas,
    this.miembros,
    this.isLoadingTiendas = false,
    this.isLoadingMiembros = false,
  });

  /// Copiar con nuevos valores
  OrganizacionDetailLoaded copyWith({
    Organizacion? organizacion,
    List<Map<String, dynamic>>? tiendas,
    List<Map<String, dynamic>>? miembros,
    bool? isLoadingTiendas,
    bool? isLoadingMiembros,
  }) {
    return OrganizacionDetailLoaded(
      organizacion: organizacion ?? this.organizacion,
      tiendas: tiendas ?? this.tiendas,
      miembros: miembros ?? this.miembros,
      isLoadingTiendas: isLoadingTiendas ?? this.isLoadingTiendas,
      isLoadingMiembros: isLoadingMiembros ?? this.isLoadingMiembros,
    );
  }

  /// Verificar si tiene tiendas
  bool get hasTiendas => tiendas != null && tiendas!.isNotEmpty;

  /// Verificar si tiene miembros
  bool get hasMiembros => miembros != null && miembros!.isNotEmpty;

  @override
  List<Object?> get props => [
    organizacion,
    tiendas,
    miembros,
    isLoadingTiendas,
    isLoadingMiembros,
  ];
}

/// Estado de error - Error al cargar organizaciones
class OrganizacionErrorState extends OrganizacionState {
  final String message;
  final StackTrace? stackTrace;
  final bool isNetworkError;

  const OrganizacionErrorState({
    required this.message,
    this.stackTrace,
    this.isNetworkError = false,
  });

  /// Crear estado de error de red
  factory OrganizacionErrorState.networkError(String message) {
    return OrganizacionErrorState(message: message, isNetworkError: true);
  }

  /// Crear estado de error de servidor
  factory OrganizacionErrorState.serverError(String message) {
    return OrganizacionErrorState(message: message, isNetworkError: false);
  }

  @override
  List<Object?> get props => [message, stackTrace, isNetworkError];
}

/// Estado de operación exitosa - Para operaciones CRUD
class OrganizacionOperationSuccess extends OrganizacionState {
  final String message;
  final Organizacion? organizacion;

  const OrganizacionOperationSuccess({
    required this.message,
    this.organizacion,
  });

  @override
  List<Object?> get props => [message, organizacion];
}

/// Estado de creación en progreso
class OrganizacionCreating extends OrganizacionState {
  const OrganizacionCreating();
}

/// Estado de actualización en progreso
class OrganizacionUpdating extends OrganizacionState {
  const OrganizacionUpdating();
}

/// Estado de eliminación en progreso
class OrganizacionDeleting extends OrganizacionState {
  const OrganizacionDeleting();
}

/// Estado de unión en progreso
class OrganizacionJoining extends OrganizacionState {
  const OrganizacionJoining();
}

/// Estado de salida en progreso
class OrganizacionLeaving extends OrganizacionState {
  const OrganizacionLeaving();
}

/// Estado de filtro aplicado
class OrganizacionFilterApplied extends OrganizacionState {
  final TipoOrganizacion tipoFiltro;
  final List<Organizacion> organizacionesFiltradas;

  const OrganizacionFilterApplied({
    required this.tipoFiltro,
    required this.organizacionesFiltradas,
  });

  @override
  List<Object?> get props => [tipoFiltro, organizacionesFiltradas];
}

/// Estado de búsqueda aplicada
class OrganizacionSearchApplied extends OrganizacionState {
  final String query;
  final List<Organizacion> resultados;

  const OrganizacionSearchApplied({
    required this.query,
    required this.resultados,
  });

  @override
  List<Object?> get props => [query, resultados];
}

/// Estado de estadísticas cargadas
class OrganizacionStatsLoaded extends OrganizacionState {
  final Map<String, dynamic> estadisticas;
  final DateTime fechaActualizacion;

  const OrganizacionStatsLoaded({
    required this.estadisticas,
    required this.fechaActualizacion,
  });

  @override
  List<Object?> get props => [estadisticas, fechaActualizacion];
}
