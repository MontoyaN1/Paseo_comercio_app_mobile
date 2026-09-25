// lib/presentation/blocs/organizacion/organizacion_event.dart

part of 'organizacion_bloc.dart';

/// Eventos base para OrganizacionBloc
abstract class OrganizacionEvent extends Equatable {
  const OrganizacionEvent();

  @override
  List<Object?> get props => [];
}

// ==============================================
// EVENTOS DE CARGA Y CONSULTA
// ==============================================

/// Cargar todas las organizaciones
class LoadOrganizaciones extends OrganizacionEvent {
  final int page;
  final int limit;
  final bool forceRefresh;

  const LoadOrganizaciones({
    this.page = 1,
    this.limit = 20,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [page, limit, forceRefresh];
}

/// Cargar más organizaciones (paginación)
class LoadMoreOrganizaciones extends OrganizacionEvent {
  const LoadMoreOrganizaciones();
}

/// Cargar organización por ID
class LoadOrganizacionById extends OrganizacionEvent {
  final int organizacionId;
  final bool loadTiendas;
  final bool loadMiembros;

  const LoadOrganizacionById({
    required this.organizacionId,
    this.loadTiendas = true,
    this.loadMiembros = false,
  });

  @override
  List<Object?> get props => [organizacionId, loadTiendas, loadMiembros];
}

/// Cargar detalle de una organización específica
class LoadOrganizacionDetail extends OrganizacionEvent {
  final int organizacionId;
  final Organizacion? organizacion;
  final bool loadTiendas;
  final bool loadMiembros;

  const LoadOrganizacionDetail({
    required this.organizacionId,
    this.organizacion,
    this.loadTiendas = true,
    this.loadMiembros = true,
  });

  @override
  List<Object?> get props => [
    organizacionId,
    organizacion,
    loadTiendas,
    loadMiembros,
  ];
}

/// Refrescar datos de una organización
class RefreshOrganizacion extends OrganizacionEvent {
  final int organizacionId;

  const RefreshOrganizacion({required this.organizacionId});

  @override
  List<Object?> get props => [organizacionId];
}

/// Buscar organizaciones por query
class SearchOrganizaciones extends OrganizacionEvent {
  final String query;
  final bool immediateSearch;

  const SearchOrganizaciones({
    required this.query,
    this.immediateSearch = false,
  });

  @override
  List<Object?> get props => [query, immediateSearch];
}

/// Limpiar búsqueda
class ClearSearch extends OrganizacionEvent {
  const ClearSearch();
}

/// Filtrar organizaciones por tipo
class FilterByTipo extends OrganizacionEvent {
  final TipoOrganizacion? tipo;

  const FilterByTipo({this.tipo});

  @override
  List<Object?> get props => [tipo];
}

/// Filtrar solo organizaciones activas
class FilterActivasOnly extends OrganizacionEvent {
  final bool soloActivas;

  const FilterActivasOnly({required this.soloActivas});

  @override
  List<Object?> get props => [soloActivas];
}

/// Ordenar organizaciones
class SortOrganizaciones extends OrganizacionEvent {
  final String sortBy; // 'nombre', 'fecha', 'tiendas', 'miembros', 'visitas'
  final bool ascending;

  const SortOrganizaciones({required this.sortBy, this.ascending = true});

  @override
  List<Object?> get props => [sortBy, ascending];
}

// ==============================================
// EVENTOS DE CREACIÓN Y GESTIÓN
// ==============================================

/// Crear nueva organización
class CreateOrganizacion extends OrganizacionEvent {
  final String nombre;
  final String? descripcion;
  final TipoOrganizacion tipo;
  final String emailAnfitrion;
  final int anfitrionId;
  final Map<String, dynamic>? metadata;

  const CreateOrganizacion({
    required this.nombre,
    this.descripcion,
    required this.tipo,
    required this.emailAnfitrion,
    required this.anfitrionId,
    this.metadata,
  });

  @override
  List<Object?> get props => [
    nombre,
    descripcion,
    tipo,
    emailAnfitrion,
    anfitrionId,
    metadata,
  ];
}

/// Actualizar organización existente
class UpdateOrganizacion extends OrganizacionEvent {
  final int organizacionId;
  final String? nombre;
  final String? descripcion;
  final TipoOrganizacion? tipo;
  final String? emailAnfitrion;
  final Map<String, dynamic>? metadata;

  const UpdateOrganizacion({
    required this.organizacionId,
    this.nombre,
    this.descripcion,
    this.tipo,
    this.emailAnfitrion,
    this.metadata,
  });

  @override
  List<Object?> get props => [
    organizacionId,
    nombre,
    descripcion,
    tipo,
    emailAnfitrion,
    metadata,
  ];
}

/// Eliminar organización
class DeleteOrganizacion extends OrganizacionEvent {
  final int organizacionId;

  const DeleteOrganizacion({required this.organizacionId});

  @override
  List<Object?> get props => [organizacionId];
}

// ==============================================
// EVENTOS DE MIEMBROS
// ==============================================

/// Unirse a una organización como miembro
class JoinOrganizacion extends OrganizacionEvent {
  final int organizacionId;
  final int usuarioId;
  final String email;
  final String nombre;

  const JoinOrganizacion({
    required this.organizacionId,
    required this.usuarioId,
    required this.email,
    required this.nombre,
  });

  @override
  List<Object?> get props => [organizacionId, usuarioId, email, nombre];
}

/// Salir de una organización
class LeaveOrganizacion extends OrganizacionEvent {
  final int organizacionId;
  final int usuarioId;

  const LeaveOrganizacion({
    required this.organizacionId,
    required this.usuarioId,
  });

  @override
  List<Object?> get props => [organizacionId, usuarioId];
}

/// Invitar a usuario a organización
class InviteToOrganizacion extends OrganizacionEvent {
  final int organizacionId;
  final String email;
  final String nombre;
  final String? mensaje;

  const InviteToOrganizacion({
    required this.organizacionId,
    required this.email,
    required this.nombre,
    this.mensaje,
  });

  @override
  List<Object?> get props => [organizacionId, email, nombre, mensaje];
}

/// Aceptar invitación a organización
class AcceptInvitation extends OrganizacionEvent {
  final int invitacionId;
  final int usuarioId;

  const AcceptInvitation({required this.invitacionId, required this.usuarioId});

  @override
  List<Object?> get props => [invitacionId, usuarioId];
}

/// Rechazar invitación a organización
class RejectInvitation extends OrganizacionEvent {
  final int invitacionId;

  const RejectInvitation({required this.invitacionId});

  @override
  List<Object?> get props => [invitacionId];
}

// ==============================================
// EVENTOS DE GESTIÓN DE TIENDAS
// ==============================================

/// Agregar tienda a organización
class AddTiendaToOrganizacion extends OrganizacionEvent {
  final int organizacionId;
  final int tiendaId;

  const AddTiendaToOrganizacion({
    required this.organizacionId,
    required this.tiendaId,
  });

  @override
  List<Object?> get props => [organizacionId, tiendaId];
}

/// Remover tienda de organización
class RemoveTiendaFromOrganizacion extends OrganizacionEvent {
  final int organizacionId;
  final int tiendaId;

  const RemoveTiendaFromOrganizacion({
    required this.organizacionId,
    required this.tiendaId,
  });

  @override
  List<Object?> get props => [organizacionId, tiendaId];
}

/// Cargar tiendas de organización
class LoadOrganizacionTiendas extends OrganizacionEvent {
  final int organizacionId;
  final int page;
  final int limit;

  const LoadOrganizacionTiendas({
    required this.organizacionId,
    this.page = 1,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [organizacionId, page, limit];
}

/// Cargar miembros de organización
class LoadOrganizacionMiembros extends OrganizacionEvent {
  final int organizacionId;
  final int page;
  final int limit;

  const LoadOrganizacionMiembros({
    required this.organizacionId,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [organizacionId, page, limit];
}

// ==============================================
// EVENTOS DE ESTADÍSTICAS
// ==============================================

/// Cargar estadísticas de organización
class LoadOrganizacionStats extends OrganizacionEvent {
  final int organizacionId;
  final DateTime? desde;
  final DateTime? hasta;

  const LoadOrganizacionStats({
    required this.organizacionId,
    this.desde,
    this.hasta,
  });

  @override
  List<Object?> get props => [organizacionId, desde, hasta];
}

/// Cargar estadísticas globales de organizaciones
class LoadGlobalOrganizacionStats extends OrganizacionEvent {
  const LoadGlobalOrganizacionStats();
}

// ==============================================
// EVENTOS DE CACHE Y SINCRONIZACIÓN
// ==============================================

/// Sincronizar organizaciones con servidor
class SyncOrganizaciones extends OrganizacionEvent {
  const SyncOrganizaciones();
}

/// Limpiar cache de organizaciones
class ClearOrganizacionCache extends OrganizacionEvent {
  const ClearOrganizacionCache();
}

/// Pre-cargar imágenes de organizaciones
class PreloadOrganizacionImages extends OrganizacionEvent {
  final List<Organizacion> organizaciones;

  const PreloadOrganizacionImages({required this.organizaciones});

  @override
  List<Object?> get props => [organizaciones];
}

// ==============================================
// EVENTOS DE UI/UX
// ==============================================

/// Marcar organización como vista
class MarkOrganizacionAsViewed extends OrganizacionEvent {
  final int organizacionId;

  const MarkOrganizacionAsViewed({required this.organizacionId});

  @override
  List<Object?> get props => [organizacionId];
}

/// Toggle favorito de organización
class ToggleOrganizacionFavorite extends OrganizacionEvent {
  final int organizacionId;
  final bool isFavorite;

  const ToggleOrganizacionFavorite({
    required this.organizacionId,
    required this.isFavorite,
  });

  @override
  List<Object?> get props => [organizacionId, isFavorite];
}

/// Compartir organización
class ShareOrganizacion extends OrganizacionEvent {
  final int organizacionId;
  final String platform; // 'whatsapp', 'facebook', 'instagram', 'twitter'

  const ShareOrganizacion({
    required this.organizacionId,
    required this.platform,
  });

  @override
  List<Object?> get props => [organizacionId, platform];
}

/// Reportar organización
class ReportOrganizacion extends OrganizacionEvent {
  final int organizacionId;
  final String motivo;
  final String? descripcion;

  const ReportOrganizacion({
    required this.organizacionId,
    required this.motivo,
    this.descripcion,
  });

  @override
  List<Object?> get props => [organizacionId, motivo, descripcion];
}

// ==============================================
// EVENTOS DE RESET Y ERROR
// ==============================================

/// Resetear estado del BLoC
class ResetOrganizacionState extends OrganizacionEvent {
  const ResetOrganizacionState();
}

/// Manejar error
class OrganizacionErrorOccurred extends OrganizacionEvent {
  final String message;
  final StackTrace? stackTrace;

  const OrganizacionErrorOccurred({required this.message, this.stackTrace});

  @override
  List<Object?> get props => [message, stackTrace];
}
