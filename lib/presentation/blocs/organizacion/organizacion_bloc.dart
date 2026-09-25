// lib/presentation/blocs/organizacion/organizacion_bloc.dart

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/organizacion.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/repositories/organizacion_repository_interface.dart';

part 'organizacion_event.dart';
part 'organizacion_state.dart';

/// BLoC simplificado para gestión de organizaciones
class OrganizacionBloc extends Bloc<OrganizacionEvent, OrganizacionState> {
  final OrganizacionRepositoryInterface _organizacionRepository;

  OrganizacionBloc({
    required OrganizacionRepositoryInterface organizacionRepository,
  }) : _organizacionRepository = organizacionRepository,
       super(const OrganizacionInitial()) {
    on<LoadOrganizaciones>(_onLoadOrganizaciones);
    on<LoadOrganizacionById>(_onLoadOrganizacionById);
    on<LoadOrganizacionDetail>(_onLoadOrganizacionDetail);
    on<SearchOrganizaciones>(_onSearchOrganizaciones);
    on<FilterByTipo>(_onFilterByTipo);
    on<CreateOrganizacion>(_onCreateOrganizacion);
    on<UpdateOrganizacion>(_onUpdateOrganizacion);
    on<DeleteOrganizacion>(_onDeleteOrganizacion);
    on<JoinOrganizacion>(_onJoinOrganizacion);
    on<ResetOrganizacionState>(_onResetOrganizacionState);
  }

  /// Cargar organizaciones
  Future<void> _onLoadOrganizaciones(
    LoadOrganizaciones event,
    Emitter<OrganizacionState> emit,
  ) async {
    try {
      emit(const OrganizacionLoading());

      final organizaciones = await _organizacionRepository.getOrganizaciones(
        page: event.page,
        limit: event.limit,
      );

      emit(
        OrganizacionLoaded(
          organizaciones: organizaciones,
          currentPage: event.page,
          hasMore: organizaciones.length >= event.limit,
        ),
      );
    } catch (e) {
      emit(
        OrganizacionErrorState(
          message: 'Error al cargar organizaciones: $e',
          isNetworkError:
              e.toString().contains('Network') ||
              e.toString().contains('Socket'),
        ),
      );
    }
  }

  /// Cargar organización por ID
  Future<void> _onLoadOrganizacionById(
    LoadOrganizacionById event,
    Emitter<OrganizacionState> emit,
  ) async {
    try {
      emit(const OrganizacionLoading());

      final organizacion = await _organizacionRepository.getOrganizacionById(
        event.organizacionId,
      );

      List<Map<String, dynamic>>? tiendas;
      List<Map<String, dynamic>>? miembros;

      if (event.loadTiendas) {
        tiendas = await _organizacionRepository.getTiendasByOrganizacionId(
          event.organizacionId,
          limit: 10,
        );
      }

      if (event.loadMiembros) {
        miembros = await _organizacionRepository.getMiembrosByOrganizacionId(
          event.organizacionId,
          limit: 20,
        );
      }

      emit(
        OrganizacionDetailLoaded(
          organizacion: organizacion,
          tiendas: tiendas,
          miembros: miembros,
        ),
      );
    } catch (e) {
      emit(
        OrganizacionErrorState(
          message: 'Error al cargar organización: $e',
          isNetworkError:
              e.toString().contains('Network') ||
              e.toString().contains('Socket'),
        ),
      );
    }
  }

  /// Cargar detalle de organización
  Future<void> _onLoadOrganizacionDetail(
    LoadOrganizacionDetail event,
    Emitter<OrganizacionState> emit,
  ) async {
    try {
      emit(const OrganizacionLoading());

      // Si ya tenemos la organización, usarla, de lo contrario cargarla
      final organizacion =
          event.organizacion ??
          await _organizacionRepository.getOrganizacionById(
            event.organizacionId,
          );

      List<Map<String, dynamic>>? tiendas;
      List<Map<String, dynamic>>? miembros;

      if (event.loadTiendas) {
        tiendas = await _organizacionRepository.getTiendasByOrganizacionId(
          event.organizacionId,
          limit: 10,
        );
      }

      if (event.loadMiembros) {
        miembros = await _organizacionRepository.getMiembrosByOrganizacionId(
          event.organizacionId,
          limit: 20,
        );
      }

      emit(
        OrganizacionDetailLoaded(
          organizacion: organizacion,
          tiendas: tiendas,
          miembros: miembros,
        ),
      );
    } catch (e) {
      emit(
        OrganizacionErrorState(
          message: 'Error al cargar detalle de organización: $e',
          isNetworkError:
              e.toString().contains('Network') ||
              e.toString().contains('Socket'),
        ),
      );
    }
  }

  /// Buscar organizaciones
  Future<void> _onSearchOrganizaciones(
    SearchOrganizaciones event,
    Emitter<OrganizacionState> emit,
  ) async {
    try {
      if (event.query.isEmpty) {
        add(const LoadOrganizaciones());
        return;
      }

      emit(OrganizacionSearchLoading(query: event.query));

      final resultados = await _organizacionRepository.searchOrganizaciones(
        event.query,
      );

      emit(
        OrganizacionSearchApplied(query: event.query, resultados: resultados),
      );
    } catch (e) {
      emit(
        OrganizacionErrorState(
          message: 'Error al buscar organizaciones: $e',
          isNetworkError:
              e.toString().contains('Network') ||
              e.toString().contains('Socket'),
        ),
      );
    }
  }

  /// Filtrar por tipo
  Future<void> _onFilterByTipo(
    FilterByTipo event,
    Emitter<OrganizacionState> emit,
  ) async {
    try {
      final organizaciones = await _organizacionRepository
          .getOrganizacionesByTipo(event.tipo ?? TipoOrganizacion.fundacion);

      emit(
        OrganizacionFilterApplied(
          tipoFiltro: event.tipo ?? TipoOrganizacion.fundacion,
          organizacionesFiltradas: organizaciones,
        ),
      );
    } catch (e) {
      emit(
        OrganizacionErrorState(
          message: 'Error al filtrar organizaciones: $e',
          isNetworkError:
              e.toString().contains('Network') ||
              e.toString().contains('Socket'),
        ),
      );
    }
  }

  /// Crear organización
  Future<void> _onCreateOrganizacion(
    CreateOrganizacion event,
    Emitter<OrganizacionState> emit,
  ) async {
    try {
      emit(const OrganizacionCreating());

      final nuevaOrganizacion = await _organizacionRepository
          .createOrganizacion(
            nombre: event.nombre,
            descripcion: event.descripcion,
            tipo: event.tipo,
            emailAnfitrion: event.emailAnfitrion,
            anfitrionId: event.anfitrionId,
            metadata: event.metadata,
          );

      emit(
        OrganizacionOperationSuccess(
          message: 'Organización creada exitosamente',
          organizacion: nuevaOrganizacion,
        ),
      );
    } catch (e) {
      emit(
        OrganizacionErrorState(
          message: 'Error al crear organización: $e',
          isNetworkError:
              e.toString().contains('Network') ||
              e.toString().contains('Socket'),
        ),
      );
    }
  }

  /// Actualizar organización
  Future<void> _onUpdateOrganizacion(
    UpdateOrganizacion event,
    Emitter<OrganizacionState> emit,
  ) async {
    try {
      emit(const OrganizacionUpdating());

      final organizacionActualizada = await _organizacionRepository
          .updateOrganizacion(
            id: event.organizacionId,
            nombre: event.nombre,
            descripcion: event.descripcion,
            tipo: event.tipo,
            emailAnfitrion: event.emailAnfitrion,
            metadata: event.metadata,
          );

      emit(
        OrganizacionOperationSuccess(
          message: 'Organización actualizada exitosamente',
          organizacion: organizacionActualizada,
        ),
      );
    } catch (e) {
      emit(
        OrganizacionErrorState(
          message: 'Error al actualizar organización: $e',
          isNetworkError:
              e.toString().contains('Network') ||
              e.toString().contains('Socket'),
        ),
      );
    }
  }

  /// Eliminar organización
  Future<void> _onDeleteOrganizacion(
    DeleteOrganizacion event,
    Emitter<OrganizacionState> emit,
  ) async {
    try {
      emit(const OrganizacionDeleting());

      await _organizacionRepository.deleteOrganizacion(event.organizacionId);

      emit(
        const OrganizacionOperationSuccess(
          message: 'Organización eliminada exitosamente',
        ),
      );
    } catch (e) {
      emit(
        OrganizacionErrorState(
          message: 'Error al eliminar organización: $e',
          isNetworkError:
              e.toString().contains('Network') ||
              e.toString().contains('Socket'),
        ),
      );
    }
  }

  /// Unirse a organización
  Future<void> _onJoinOrganizacion(
    JoinOrganizacion event,
    Emitter<OrganizacionState> emit,
  ) async {
    try {
      emit(const OrganizacionJoining());

      await _organizacionRepository.joinOrganizacion(
        organizacionId: event.organizacionId,
        usuarioId: event.usuarioId,
        email: event.email,
        nombre: event.nombre,
      );

      emit(
        const OrganizacionOperationSuccess(
          message: 'Te has unido a la organización exitosamente',
        ),
      );
    } catch (e) {
      emit(
        OrganizacionErrorState(
          message: 'Error al unirse a la organización: $e',
          isNetworkError:
              e.toString().contains('Network') ||
              e.toString().contains('Socket'),
        ),
      );
    }
  }

  /// Resetear estado
  Future<void> _onResetOrganizacionState(
    ResetOrganizacionState event,
    Emitter<OrganizacionState> emit,
  ) async {
    emit(const OrganizacionInitial());
  }
}
