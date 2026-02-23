// lib/presentation/blocs/tienda/tienda_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../domain/usecases/get_tiendas_usecase.dart';
import '../../../../domain/usecases/get_tienda_by_id_usecase.dart';
import '../../../../domain/usecases/search_tiendas_usecase.dart';

part 'tienda_event.dart';
part 'tienda_state.dart';

/// BLoC para gestión de tiendas
class TiendaBloc extends Bloc<TiendaEvent, TiendaState> {
  final GetTiendasUseCase _getTiendasUseCase;
  final GetTiendaByIdUseCase _getTiendaByIdUseCase;
  final SearchTiendasUseCase _searchTiendasUseCase;

  TiendaBloc({
    required GetTiendasUseCase getTiendasUseCase,
    required GetTiendaByIdUseCase getTiendaByIdUseCase,
    required SearchTiendasUseCase searchTiendasUseCase,
  }) : _getTiendasUseCase = getTiendasUseCase,
       _getTiendaByIdUseCase = getTiendaByIdUseCase,
       _searchTiendasUseCase = searchTiendasUseCase,
       super(const TiendaInitial()) {
    on<TiendaLoadRequested>(_onTiendaLoadRequested);
    on<TiendaLoadByIdRequested>(_onTiendaLoadByIdRequested);
    on<TiendaSearchRequested>(_onTiendaSearchRequested);
    on<TiendaLoadMoreRequested>(_onTiendaLoadMoreRequested);
    on<TiendaRefreshRequested>(_onTiendaRefreshRequested);
    on<TiendaClearSearch>(_onTiendaClearSearch);
    on<TiendaErrorCleared>(_onTiendaErrorCleared);
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
    // Limpiar recursos si es necesario
    return super.close();
  }
}
