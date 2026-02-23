// lib/presentation/blocs/plazoleta/plazoleta_event.dart

import 'package:equatable/equatable.dart';

import '../../../domain/entities/plazoleta.dart';

/// Eventos para el BLoC de Plazoletas
abstract class PlazoletaEvent extends Equatable {
  const PlazoletaEvent();

  @override
  List<Object?> get props => [];
}

// ========== EVENTOS DE CARGA DE PLAZOLETAS ==========

/// Cargar todas las plazoletas activas
class LoadPlazoletasActivas extends PlazoletaEvent {
  final int? page;
  final int? limit;
  final String? search;
  final String? piso;
  final String? sector;
  final bool? tieneZonaComida;
  final bool? tieneEstacionamiento;
  final bool forceRefresh;

  const LoadPlazoletasActivas({
    this.page = 1,
    this.limit = 20,
    this.search,
    this.piso,
    this.sector,
    this.tieneZonaComida,
    this.tieneEstacionamiento,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [
    page,
    limit,
    search,
    piso,
    sector,
    tieneZonaComida,
    tieneEstacionamiento,
    forceRefresh,
  ];
}

/// Cargar una plazoleta específica por ID
class LoadPlazoletaById extends PlazoletaEvent {
  final int id;
  final bool forceRefresh;

  const LoadPlazoletaById({required this.id, this.forceRefresh = false});

  @override
  List<Object?> get props => [id, forceRefresh];
}

/// Cargar plazoletas populares
class LoadPlazoletasPopulares extends PlazoletaEvent {
  final int? limit;
  final bool forceRefresh;

  const LoadPlazoletasPopulares({this.limit = 10, this.forceRefresh = false});

  @override
  List<Object?> get props => [limit, forceRefresh];
}

/// Cargar plazoletas disponibles (no llenas)
class LoadPlazoletasDisponibles extends PlazoletaEvent {
  final int? page;
  final int? limit;
  final bool forceRefresh;

  const LoadPlazoletasDisponibles({
    this.page = 1,
    this.limit = 20,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [page, limit, forceRefresh];
}

/// Buscar plazoletas por término
class SearchPlazoletas extends PlazoletaEvent {
  final String query;
  final bool forceRefresh;

  const SearchPlazoletas({required this.query, this.forceRefresh = false});

  @override
  List<Object?> get props => [query, forceRefresh];
}

// ========== EVENTOS DE IMÁGENES DE PLAZOLETAS ==========

/// Cargar imágenes de una plazoleta
class LoadImagenesPlazoleta extends PlazoletaEvent {
  final int plazoletaId;
  final bool forceRefresh;

  const LoadImagenesPlazoleta({
    required this.plazoletaId,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [plazoletaId, forceRefresh];
}

/// Cargar imagen principal de una plazoleta
class LoadImagenPrincipalPlazoleta extends PlazoletaEvent {
  final int plazoletaId;
  final bool forceRefresh;

  const LoadImagenPrincipalPlazoleta({
    required this.plazoletaId,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [plazoletaId, forceRefresh];
}

// ========== EVENTOS DE PRODUCTOS RELACIONADOS ==========

/// Cargar productos de una plazoleta
class LoadProductosPlazoleta extends PlazoletaEvent {
  final int plazoletaId;
  final int? page;
  final int? limit;
  final String? search;
  final double? precioMin;
  final double? precioMax;
  final bool? soloDisponibles;
  final bool forceRefresh;

  const LoadProductosPlazoleta({
    required this.plazoletaId,
    this.page = 1,
    this.limit = 20,
    this.search,
    this.precioMin,
    this.precioMax,
    this.soloDisponibles,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [
    plazoletaId,
    page,
    limit,
    search,
    precioMin,
    precioMax,
    soloDisponibles,
    forceRefresh,
  ];
}

/// Cargar productos destacados de una plazoleta
class LoadProductosDestacadosPlazoleta extends PlazoletaEvent {
  final int plazoletaId;
  final int? limit;
  final bool forceRefresh;

  const LoadProductosDestacadosPlazoleta({
    required this.plazoletaId,
    this.limit = 10,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [plazoletaId, limit, forceRefresh];
}

// ========== EVENTOS DE TIENDAS RELACIONADAS ==========

/// Cargar tiendas de una plazoleta
class LoadTiendasPlazoleta extends PlazoletaEvent {
  final int plazoletaId;
  final int? page;
  final int? limit;
  final String? search;
  final bool? soloAbiertas;
  final bool forceRefresh;

  const LoadTiendasPlazoleta({
    required this.plazoletaId,
    this.page = 1,
    this.limit = 20,
    this.search,
    this.soloAbiertas,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [
    plazoletaId,
    page,
    limit,
    search,
    soloAbiertas,
    forceRefresh,
  ];
}

/// Cargar tiendas destacadas de una plazoleta
class LoadTiendasDestacadasPlazoleta extends PlazoletaEvent {
  final int plazoletaId;
  final int? limit;
  final bool forceRefresh;

  const LoadTiendasDestacadasPlazoleta({
    required this.plazoletaId,
    this.limit = 10,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [plazoletaId, limit, forceRefresh];
}

// ========== EVENTOS DE ESTADÍSTICAS Y MÉTRICAS ==========

/// Incrementar visitas de una plazoleta
class IncrementarVisitasPlazoleta extends PlazoletaEvent {
  final int plazoletaId;

  const IncrementarVisitasPlazoleta({required this.plazoletaId});

  @override
  List<Object?> get props => [plazoletaId];
}

/// Cargar estadísticas de una plazoleta
class LoadEstadisticasPlazoleta extends PlazoletaEvent {
  final int plazoletaId;
  final bool forceRefresh;

  const LoadEstadisticasPlazoleta({
    required this.plazoletaId,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [plazoletaId, forceRefresh];
}

// ========== EVENTOS DE FILTROS Y BÚSQUEDAS ==========

/// Filtrar plazoletas
class FilterPlazoletas extends PlazoletaEvent {
  final List<String>? pisos;
  final List<String>? sectores;
  final List<String>? servicios;
  final bool? tieneAccesoDiscapacitados;
  final bool? tieneEstacionamiento;
  final bool? tieneZonaDescanso;
  final bool? tieneZonaComida;
  final double? latitud;
  final double? longitud;
  final double? radioKm;
  final int? capacidadMinima;
  final int? capacidadMaxima;
  final bool? soloDisponibles;
  final bool forceRefresh;

  const FilterPlazoletas({
    this.pisos,
    this.sectores,
    this.servicios,
    this.tieneAccesoDiscapacitados,
    this.tieneEstacionamiento,
    this.tieneZonaDescanso,
    this.tieneZonaComida,
    this.latitud,
    this.longitud,
    this.radioKm,
    this.capacidadMinima,
    this.capacidadMaxima,
    this.soloDisponibles,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [
    pisos,
    sectores,
    servicios,
    tieneAccesoDiscapacitados,
    tieneEstacionamiento,
    tieneZonaDescanso,
    tieneZonaComida,
    latitud,
    longitud,
    radioKm,
    capacidadMinima,
    capacidadMaxima,
    soloDisponibles,
    forceRefresh,
  ];
}

/// Cargar plazoletas cercanas
class LoadPlazoletasCercanas extends PlazoletaEvent {
  final double latitud;
  final double longitud;
  final double? radioKm;
  final int? limit;
  final bool forceRefresh;

  const LoadPlazoletasCercanas({
    required this.latitud,
    required this.longitud,
    this.radioKm = 5.0,
    this.limit = 20,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [latitud, longitud, radioKm, limit, forceRefresh];
}

// ========== EVENTOS DE CACHÉ Y SINCRONIZACIÓN ==========

/// Sincronizar datos de plazoletas
class SincronizarPlazoletas extends PlazoletaEvent {
  const SincronizarPlazoletas();
}

/// Limpiar caché de plazoletas
class LimpiarCachePlazoletas extends PlazoletaEvent {
  const LimpiarCachePlazoletas();
}

/// Verificar si hay caché de plazoletas
class VerificarCachePlazoletas extends PlazoletaEvent {
  const VerificarCachePlazoletas();
}

// ========== EVENTOS DE NAVEGACIÓN Y SELECCIÓN ==========

/// Seleccionar una plazoleta
class SelectPlazoleta extends PlazoletaEvent {
  final Plazoleta? plazoleta;
  final int? plazoletaId;

  const SelectPlazoleta({this.plazoleta, this.plazoletaId});

  @override
  List<Object?> get props => [plazoleta, plazoletaId];
}

/// Deseleccionar plazoleta
class DeselectPlazoleta extends PlazoletaEvent {
  const DeselectPlazoleta();
}

/// Navegar a detalle de plazoleta
class NavigateToPlazoletaDetail extends PlazoletaEvent {
  final int plazoletaId;

  const NavigateToPlazoletaDetail({required this.plazoletaId});

  @override
  List<Object?> get props => [plazoletaId];
}

/// Navegar a productos de plazoleta
class NavigateToPlazoletaProductos extends PlazoletaEvent {
  final int plazoletaId;

  const NavigateToPlazoletaProductos({required this.plazoletaId});

  @override
  List<Object?> get props => [plazoletaId];
}

/// Navegar a tiendas de plazoleta
class NavigateToPlazoletaTiendas extends PlazoletaEvent {
  final int plazoletaId;

  const NavigateToPlazoletaTiendas({required this.plazoletaId});

  @override
  List<Object?> get props => [plazoletaId];
}

// ========== EVENTOS DE ERROR Y RESET ==========

/// Resetear estado del BLoC
class ResetPlazoletaState extends PlazoletaEvent {
  const ResetPlazoletaState();
}

/// Manejar error
class PlazoletaError extends PlazoletaEvent {
  final String message;
  final StackTrace? stackTrace;

  const PlazoletaError({required this.message, this.stackTrace});

  @override
  List<Object?> get props => [message, stackTrace];
}
