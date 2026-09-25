// lib/presentation/blocs/tienda/tienda_bloc.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../data/datasources/remote/supabase_client.dart';
import '../../../../di/service_locator.dart';
import '../../../../domain/usecases/get_tiendas_usecase.dart';
import '../../../../domain/usecases/get_tienda_by_id_usecase.dart';
import '../../../../domain/usecases/search_tiendas_usecase.dart';
import '../../../../domain/usecases/get_productos_usecase.dart';

part 'tienda_event.dart';
part 'tienda_state.dart';

/// BLoC para gestión de tiendas
class TiendaBloc extends Bloc<TiendaEvent, TiendaState> {
  final GetTiendasUseCase _getTiendasUseCase;
  final GetTiendaByIdUseCase _getTiendaByIdUseCase;
  final SearchTiendasUseCase _searchTiendasUseCase;
  final GetProductosUseCase _getProductosUseCase;

  TiendaBloc({
    required GetTiendasUseCase getTiendasUseCase,
    required GetTiendaByIdUseCase getTiendaByIdUseCase,
    required SearchTiendasUseCase searchTiendasUseCase,
    required GetProductosUseCase getProductosUseCase,
  }) : _getTiendasUseCase = getTiendasUseCase,
       _getTiendaByIdUseCase = getTiendaByIdUseCase,
       _searchTiendasUseCase = searchTiendasUseCase,
       _getProductosUseCase = getProductosUseCase,
       super(const TiendaInitial()) {
    on<TiendaLoadRequested>(_onTiendaLoadRequested);
    on<TiendaLoadByIdRequested>(_onTiendaLoadByIdRequested);
    on<TiendaSearchRequested>(_onTiendaSearchRequested);
    on<TiendaLoadMoreRequested>(_onTiendaLoadMoreRequested);
    on<TiendaRefreshRequested>(_onTiendaRefreshRequested);
    on<TiendaClearSearch>(_onTiendaClearSearch);
    on<TiendaErrorCleared>(_onTiendaErrorCleared);
    on<TiendaProductsRequested>(_onTiendaProductsRequested);
    on<TiendaHorariosRequested>(_onTiendaHorariosRequested);
  }

  /// Manejar evento de carga de tiendas
  Future<void> _onTiendaLoadRequested(
    TiendaLoadRequested event,
    Emitter<TiendaState> emit,
  ) async {
    // Si ya estamos cargando, no hacer nada
    if (state is TiendaLoading) return;

    emit(const TiendaLoading());

    try {
      final tiendas = await _getTiendasUseCase.execute(
        GetTiendasParams(
          page: event.page,
          limit: event.limit,
          categoriaId: event.categoriaId,
          soloActivas: event.soloActivas,
          forceRefresh: event.forceRefresh,
        ),
      );

      if (tiendas.isEmpty) {
        emit(const TiendaEmpty());
      } else {
        emit(
          TiendaLoaded(
            tiendas: tiendas,
            currentPage: event.page,
            hasMore: tiendas.length >= event.limit,
            searchQuery: null,
          ),
        );
      }
    } catch (e) {
      emit(TiendaError(message: 'Error al cargar tiendas: $e', error: e));
    }
  }

  /// Manejar evento de carga de tienda por ID
  Future<void> _onTiendaLoadByIdRequested(
    TiendaLoadByIdRequested event,
    Emitter<TiendaState> emit,
  ) async {
    // Si ya estamos cargando, no hacer nada
    if (state is TiendaLoading) return;

    emit(const TiendaLoading());

    try {
      final tienda = await _getTiendaByIdUseCase.execute(
        GetTiendaByIdParams(
          tiendaId: event.tiendaId,
          forceRefresh: event.forceRefresh,
        ),
      );

      if (tienda == null) {
        emit(
          TiendaError(
            message: 'Tienda no encontrada',
            error: Exception('Tienda con ID ${event.tiendaId} no encontrada'),
          ),
        );
      } else {
        emit(TiendaDetailLoaded(tienda: tienda));
      }
    } catch (e) {
      emit(TiendaError(message: 'Error al cargar tienda: $e', error: e));
    }
  }

  /// Manejar evento de búsqueda de tiendas
  Future<void> _onTiendaSearchRequested(
    TiendaSearchRequested event,
    Emitter<TiendaState> emit,
  ) async {
    // Validar query
    if (event.query.trim().isEmpty) {
      emit(
        const TiendaError(
          message: 'El término de búsqueda no puede estar vacío',
        ),
      );
      return;
    }

    if (event.query.trim().length < 2) {
      emit(
        const TiendaError(
          message: 'El término de búsqueda debe tener al menos 2 caracteres',
        ),
      );
      return;
    }

    // Si ya estamos cargando, no hacer nada
    if (state is TiendaLoading) return;

    emit(TiendaSearchLoading(query: event.query));

    try {
      final tiendas = await _searchTiendasUseCase.execute(
        SearchTiendasParams(
          query: event.query,
          page: event.page,
          limit: event.limit,
        ),
      );

      if (tiendas.isEmpty) {
        emit(TiendaSearchEmpty(query: event.query));
      } else {
        emit(
          TiendaSearchLoaded(
            tiendas: tiendas,
            query: event.query,
            currentPage: event.page,
            hasMore: tiendas.length >= event.limit,
          ),
        );
      }
    } catch (e) {
      emit(TiendaError(message: 'Error al buscar tiendas: $e', error: e));
    }
  }

  /// Manejar evento de cargar más tiendas
  Future<void> _onTiendaLoadMoreRequested(
    TiendaLoadMoreRequested event,
    Emitter<TiendaState> emit,
  ) async {
    // Solo cargar más si estamos en un estado cargado y hay más para cargar
    if (state is! TiendaLoaded && state is! TiendaSearchLoaded) return;
    if (state is TiendaLoadingMore) return;

    final currentState = state;

    if (currentState is TiendaSearchLoaded) {
      final searchState = currentState;
      if (!searchState.hasMore) return;

      emit(searchState.copyWith(isLoadingMore: true));

      try {
        final nextPage = searchState.currentPage + 1;
        final newTiendas = await _searchTiendasUseCase.execute(
          SearchTiendasParams(
            query: searchState.query,
            page: nextPage,
            limit: event.limit,
          ),
        );

        final allTiendas = [...searchState.tiendas, ...newTiendas];
        emit(
          TiendaSearchLoaded(
            tiendas: allTiendas,
            query: searchState.query,
            currentPage: nextPage,
            hasMore: newTiendas.length >= event.limit,
          ),
        );
      } catch (e) {
        // Revertir al estado anterior en caso de error
        emit(currentState);
        emit(TiendaError(message: 'Error al cargar más tiendas: $e', error: e));
      }
    } else if (currentState is TiendaLoaded) {
      final loadedState = currentState;
      if (!loadedState.hasMore) return;

      emit(loadedState.copyWith(isLoadingMore: true));

      try {
        final nextPage = loadedState.currentPage + 1;
        final newTiendas = await _getTiendasUseCase.execute(
          GetTiendasParams(
            page: nextPage,
            limit: event.limit,
            categoriaId: loadedState.categoriaId,
            soloActivas: loadedState.soloActivas,
            forceRefresh: false,
          ),
        );

        final allTiendas = [...loadedState.tiendas, ...newTiendas];
        emit(
          TiendaLoaded(
            tiendas: allTiendas,
            currentPage: nextPage,
            hasMore: newTiendas.length >= event.limit,
            searchQuery: loadedState.searchQuery,
            categoriaId: loadedState.categoriaId,
            soloActivas: loadedState.soloActivas,
          ),
        );
      } catch (e) {
        // Revertir al estado anterior en caso de error
        emit(currentState);
        emit(TiendaError(message: 'Error al cargar más tiendas: $e', error: e));
      }
    }
  }

  /// Manejar evento de refrescar tiendas
  Future<void> _onTiendaRefreshRequested(
    TiendaRefreshRequested event,
    Emitter<TiendaState> emit,
  ) async {
    final currentState = state;

    // Determinar qué tipo de refresco hacer
    if (currentState is TiendaSearchLoaded) {
      // Refrescar búsqueda
      add(
        TiendaSearchRequested(
          query: currentState.query,
          page: 1,
          limit: currentState.tiendas.length,
          forceRefresh: true,
        ),
      );
    } else if (currentState is TiendaLoaded) {
      // Refrescar lista normal
      add(
        TiendaLoadRequested(
          page: 1,
          limit: currentState.tiendas.length,
          categoriaId: currentState.categoriaId,
          soloActivas: currentState.soloActivas,
          forceRefresh: true,
        ),
      );
    } else if (currentState is TiendaDetailLoaded) {
      // Refrescar detalle
      add(
        TiendaLoadByIdRequested(
          tiendaId: currentState.tienda['id'] as int,
          forceRefresh: true,
        ),
      );
    }
  }

  /// Manejar evento de limpiar búsqueda
  void _onTiendaClearSearch(
    TiendaClearSearch event,
    Emitter<TiendaState> emit,
  ) {
    // Volver al estado inicial
    emit(const TiendaInitial());
  }

  /// Manejar evento de limpiar error
  void _onTiendaErrorCleared(
    TiendaErrorCleared event,
    Emitter<TiendaState> emit,
  ) {
    // Volver al estado anterior o inicial
    if (state is TiendaError) {
      emit(const TiendaInitial());
    }
  }

  /// Manejar evento de cargar productos de tienda
  Future<void> _onTiendaProductsRequested(
    TiendaProductsRequested event,
    Emitter<TiendaState> emit,
  ) async {
    try {
      final productos = await _getProductosUseCase.execute(
        GetProductosParams(
          tiendaId: event.tiendaId,
          page: event.page,
          limit: event.limit,
          estado: event.estado,
        ),
      );

      emit(
        TiendaProductsLoaded(
          tiendaId: event.tiendaId,
          productos: productos,
          currentPage: event.page,
          hasMore: productos.length >= event.limit,
        ),
      );
    } catch (e) {
      emit(TiendaError(message: 'Error al cargar productos: $e', error: e));
    }
  }

  /// Manejar evento de cargar horarios de tienda
  Future<void> _onTiendaHorariosRequested(
    TiendaHorariosRequested event,
    Emitter<TiendaState> emit,
  ) async {
    try {
      // Obtener el servicio de Supabase
      final supabase = getIt<SupabaseClientService>();

      // Consultar horarios de la tienda - usando nombres de columna de la DB
      final response = await supabase.horarios.select().eq(
        'tienda_id',
        event.tiendaId,
      );

      debugPrint('========================================');
      debugPrint('🔍 HORARIOS - Tienda ID: ${event.tiendaId}');
      debugPrint('🔍 Raw response count: ${response.length}');
      debugPrint('🔍 Raw response: $response');
      for (var i = 0; i < response.length; i++) {
        debugPrint('🔍 Horario[$i]: ${response[i]}');
        debugPrint('🔍 Keys: ${response[i].keys.toList()}');
      }
      debugPrint('========================================');

      // Transformar los datos al formato esperado por la UI
      final horariosTransformados =
          response.map((h) => _transformarHorario(h)).toList();

      // Ordenar explícitamente por dia_semana (0 = Lunes, 6 = Domingo)
      horariosTransformados.sort((a, b) {
        final diaA = a['dia_semana'] as int? ?? 0;
        final diaB = b['dia_semana'] as int? ?? 0;
        return diaA.compareTo(diaB);
      });

      debugPrint('🔍 Horarios ordenados: $horariosTransformados');

      emit(
        TiendaHorariosLoaded(
          tiendaId: event.tiendaId,
          horarios: horariosTransformados,
        ),
      );
    } catch (e) {
      debugPrint('Error al cargar horarios: $e');
      emit(TiendaHorariosLoaded(tiendaId: event.tiendaId, horarios: []));
    }
  }

  /// Transformar horario de la DB al formato esperado por la UI
  Map<String, dynamic> _transformarHorario(Map<String, dynamic> horario) {
    // El esquema DB usa: 1=Lunes, 2=Martes, ..., 6=Sábado, 7=Domingo
    // Normalizar restando 1 para usar como índice de array (0-6)
    final diaSemana = horario['dia_semana'] as int? ?? 1;

    // Normalizar: restar 1 para convertir 1-7 a 0-6
    // Si es 7 (Domingo), queda 6
    final diaNormalizado = (diaSemana - 1).clamp(0, 6);

    final dias = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];

    final diaNombre =
        (diaNormalizado >= 0 && diaNormalizado < dias.length)
            ? dias[diaNormalizado]
            : 'Día $diaSemana';

    // Extraer hora de apertura y cierre (manejar diferentes formatos)
    String? apertura;
    String? cierre;

    if (horario['apertura'] != null) {
      final aperturaStr = horario['apertura'].toString();
      // Formato puede ser: "14:00:00", "14:00:00+00", "14:00:00-05:00"
      // Extraer solo HH:MM
      if (aperturaStr.contains(':')) {
        final partes = aperturaStr.split(':');
        if (partes.length >= 2) {
          apertura = '${partes[0]}:${partes[1]}';
        }
      } else {
        apertura = aperturaStr;
      }
    }

    if (horario['cierre'] != null) {
      final cierreStr = horario['cierre'].toString();
      if (cierreStr.contains(':')) {
        final partes = cierreStr.split(':');
        if (partes.length >= 2) {
          cierre = '${partes[0]}:${partes[1]}';
        }
      } else {
        cierre = cierreStr;
      }
    }

    // Verificar si está cerrado
    // Si hay horarios de apertura y cierre definidos, ignorar el campo "cerrado"
    final cerrado = horario['cerrado'] as bool? ?? false;
    final tieneHorarioDefinido = apertura != null && cierre != null;
    final mostrarComoCerrado = cerrado && !tieneHorarioDefinido;

    return {
      'dia': diaNombre,
      'dia_semana': diaNormalizado, // Usar el día normalizado para ordenamiento
      'hora_apertura': mostrarComoCerrado ? null : apertura,
      'hora_cierre': mostrarComoCerrado ? null : cierre,
      'cerrado': mostrarComoCerrado,
      'fecha_especifica': horario['fecha_especifica'],
      'tipo_horario': horario['tipo_horario'],
    };
  }

  /// Obtener tiendas actuales del estado
  List<Map<String, dynamic>>? get currentTiendas {
    if (state is TiendaLoaded) {
      return (state as TiendaLoaded).tiendas;
    } else if (state is TiendaSearchLoaded) {
      return (state as TiendaSearchLoaded).tiendas;
    }
    return null;
  }

  /// Verificar si hay más tiendas para cargar
  bool get hasMoreTiendas {
    if (state is TiendaLoaded) {
      return (state as TiendaLoaded).hasMore;
    } else if (state is TiendaSearchLoaded) {
      return (state as TiendaSearchLoaded).hasMore;
    }
    return false;
  }

  /// Obtener página actual
  int get currentPage {
    if (state is TiendaLoaded) {
      return (state as TiendaLoaded).currentPage;
    } else if (state is TiendaSearchLoaded) {
      return (state as TiendaSearchLoaded).currentPage;
    }
    return 1;
  }

  /// Obtener query de búsqueda actual
  String? get currentSearchQuery {
    if (state is TiendaSearchLoaded) {
      return (state as TiendaSearchLoaded).query;
    } else if (state is TiendaLoaded) {
      return (state as TiendaLoaded).searchQuery;
    }
    return null;
  }

  /// Disposición del BLoC
  @override
  Future<void> close() {
    // Llamar al método de la clase base para liberar recursos
    return super.close();
  }
}
