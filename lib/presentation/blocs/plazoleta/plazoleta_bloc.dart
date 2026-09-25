// lib/presentation/blocs/plazoleta/plazoleta_bloc.dart

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:logger/logger.dart';

import '../../../domain/repositories/plazoleta_repository_interface.dart';
import '../../../domain/entities/plazoleta.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/entities/imagen_base.dart';
import '../../../domain/entities/producto.dart';
import '../../../domain/entities/tienda.dart';

import 'plazoleta_event.dart';
import 'plazoleta_state.dart';

/// BLoC para manejar la lógica de negocio de las plazoletas
class PlazoletaBloc extends Bloc<PlazoletaEvent, PlazoletaState> {
  final PlazoletaRepositoryInterface _plazoletaRepository;
  final Logger _logger;

  // Variables para manejar paginación
  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMore = true;
  Map<String, dynamic>? _currentFilters;

  // Contador para cancelar eventos pendientes
  int _loadRequestId = 0;

  PlazoletaBloc({required PlazoletaRepositoryInterface plazoletaRepository})
    : _plazoletaRepository = plazoletaRepository,
      _logger = Logger(
        printer: PrettyPrinter(
          methodCount: 0,
          errorMethodCount: 3,
          lineLength: 50,
          colors: true,
          printEmojis: true,
          printTime: false,
        ),
      ),
      super(const PlazoletaInitial()) {
    on<LoadPlazoletasActivas>(_onLoadPlazoletasActivas);
    on<LoadPlazoletaById>(_onLoadPlazoletaById);
    on<LoadPlazoletaBySlug>(_onLoadPlazoletaBySlug);
    on<LoadPlazoletasPopulares>(_onLoadPlazoletasPopulares);
    on<LoadPlazoletasDisponibles>(_onLoadPlazoletasDisponibles);
    on<SearchPlazoletas>(_onSearchPlazoletas);
    on<LoadImagenesPlazoleta>(_onLoadImagenesPlazoleta);
    on<LoadImagenPrincipalPlazoleta>(_onLoadImagenPrincipalPlazoleta);
    on<LoadProductosPlazoleta>(_onLoadProductosPlazoleta);
    on<LoadProductosDestacadosPlazoleta>(_onLoadProductosDestacadosPlazoleta);
    on<LoadTiendasPlazoleta>(_onLoadTiendasPlazoleta);
    on<LoadTiendasDestacadasPlazoleta>(_onLoadTiendasDestacadasPlazoleta);
    on<IncrementarVisitasPlazoleta>(_onIncrementarVisitasPlazoleta);
    on<LoadEstadisticasPlazoleta>(_onLoadEstadisticasPlazoleta);
    on<FilterPlazoletas>(_onFilterPlazoletas);
    on<LoadPlazoletasCercanas>(_onLoadPlazoletasCercanas);
    on<SincronizarPlazoletas>(_onSincronizarPlazoletas);
    on<LimpiarCachePlazoletas>(_onLimpiarCachePlazoletas);
    on<VerificarCachePlazoletas>(_onVerificarCachePlazoletas);
    on<SelectPlazoleta>(_onSelectPlazoleta);
    on<DeselectPlazoleta>(_onDeselectPlazoleta);
    on<NavigateToPlazoletaDetail>(_onNavigateToPlazoletaDetail);
    on<NavigateToPlazoletaProductos>(_onNavigateToPlazoletaProductos);
    on<NavigateToPlazoletaTiendas>(_onNavigateToPlazoletaTiendas);
    on<ResetPlazoletaState>(_onResetPlazoletaState);
    on<PlazoletaError>(_onPlazoletaError);
  }

  // ========== MANEJADORES DE EVENTOS ==========

  /// Cargar plazoletas activas
  Future<void> _onLoadPlazoletasActivas(
    LoadPlazoletasActivas event,
    Emitter<PlazoletaState> emit,
  ) async {
    try {
      _logger.d(
        'Loading plazoletas: page=${event.page}, refresh=${event.forceRefresh}',
      );

      // Si es refresh, resetear paginación
      if (event.forceRefresh) {
        _currentPage = 1;
        _hasMore = true;
      }

      emit(PlazoletasActivasLoading(isRefreshing: event.forceRefresh));

      try {
        final plazoletas = await _plazoletaRepository.getPlazoletasActivas(
          page: event.page ?? _currentPage,
          limit: event.limit ?? _pageSize,
          search: event.search,
          piso: event.piso,
          sector: event.sector,
          tieneZonaComida: event.tieneZonaComida,
          tieneEstacionamiento: event.tieneEstacionamiento,
        );

        _hasMore = plazoletas.length >= (event.limit ?? _pageSize);

        // Obtener imágenes principales para las plazoletas cargadas
        List<ImagenBase> nuevasImagenes = [];
        if (plazoletas.isNotEmpty) {
          try {
            final plazoletaIds = plazoletas.map((p) => p.id).toList();
            final imagenesMap = await _plazoletaRepository
                .getImagenesPrincipalesPlazoletas(plazoletaIds);

            // Convertir mapa a lista de imágenes
            nuevasImagenes =
                imagenesMap.entries
                    .where((entry) => entry.value != null)
                    .map((entry) => entry.value!)
                    .toList();

            _logger.d(
              'Se cargaron ${nuevasImagenes.length} imágenes principales',
            );
          } catch (e) {
            _logger.e('Error al cargar imágenes principales: $e');
            // Continuar sin imágenes si hay error
          }
        }

        if (event.forceRefresh || _currentPage == 1) {
          _logger.d(
            'Emitting PlazoletaLoaded con ${plazoletas.length} plazoletas y ${nuevasImagenes.length} imágenes',
          );
          emit(
            PlazoletaLoaded(
              plazoletas: plazoletas,
              imagenesPlazoleta: nuevasImagenes,
              hasMore: _hasMore,
              currentPage: event.page ?? _currentPage,
              searchQuery: event.search,
              filters: _currentFilters,
            ),
          );
        } else {
          // Para paginación, agregar a las existentes
          if (state is PlazoletaLoaded) {
            _logger.d(' state is PlazoletaLoaded, merging pagination');
            final currentState = state as PlazoletaLoaded;
            final todasPlazoletas = [...currentState.plazoletas, ...plazoletas];

            // Combinar imágenes existentes con nuevas
            final List<ImagenBase> todasImagenes = [
              if (currentState.imagenesPlazoleta != null)
                ...currentState.imagenesPlazoleta!,
              ...nuevasImagenes,
            ];

            _logger.d(
              'Emitting PlazoletaLoaded (paginación) con ${todasPlazoletas.length} plazoletas totales y ${todasImagenes.length} imágenes',
            );
            emit(
              currentState.copyWith(
                plazoletas: todasPlazoletas,
                imagenesPlazoleta: todasImagenes,
                hasMore: _hasMore,
                currentPage: event.page ?? _currentPage,
              ),
            );
          }
        }

        // Incrementar página si no es forceRefresh
        if (!event.forceRefresh && _hasMore) {
          _currentPage++;
        }
      } catch (e) {
        _logger.e('Error loading plazoletas: $e');
        emit(
          PlazoletasActivasError(
            message: 'Error al cargar plazoletas: $e',
            isRefreshing: event.forceRefresh,
          ),
        );
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Error en _onLoadPlazoletasActivas: $e',
        error: e,
        stackTrace: stackTrace,
      );
      emit(
        PlazoletasActivasError(
          message: 'Error al cargar plazoletas: $e',
          stackTrace: stackTrace,
          isRefreshing: event.forceRefresh,
        ),
      );
    }
  }

  /// Cargar una plazoleta por ID
  Future<void> _onLoadPlazoletaById(
    LoadPlazoletaById event,
    Emitter<PlazoletaState> emit,
  ) async {
    final requestId = ++_loadRequestId;
    final requestedId = event.id;

    try {
      emit(
        PlazoletaDetailLoading(
          plazoletaId: event.id,
          isRefreshing: event.forceRefresh,
        ),
      );

      try {
        final plazoleta = await _plazoletaRepository.getPlazoletaById(event.id);

        if (requestId != _loadRequestId) {
          _logger.w(
            'LoadPlazoletaById($requestedId) cancelled - newer request pending',
          );
          return;
        }

        // Cargar imágenes de la plazoleta
        List<ImagenBase> imagenes = [];
        try {
          imagenes = await _plazoletaRepository.getImagenesPlazoleta(event.id);
        } catch (e) {
          _logger.w(
            'Error al cargar imágenes de la plazoleta, continuando sin imágenes: $e',
          );
          // Continuamos sin imágenes si hay error
        }

        if (requestId != _loadRequestId) {
          _logger.w(
            'LoadPlazoletaById($requestedId) cancelled after imagenes - newer request pending',
          );
          return;
        }

        // Cargar productos de la plazoleta
        List<Producto> productos = [];
        try {
          productos = await _plazoletaRepository.getProductosPorPlazoleta(
            event.id,
          );
        } catch (e) {
          _logger.w(
            'Error al cargar productos de la plazoleta, continuando sin productos: $e',
          );
          // Continuamos sin productos si hay error
        }

        if (requestId != _loadRequestId) {
          _logger.w(
            'LoadPlazoletaById($requestedId) cancelled after productos - newer request pending',
          );
          return;
        }

        // Cargar tiendas de la plazoleta
        List<Tienda> tiendas = [];
        try {
          tiendas = await _plazoletaRepository.getTiendasPlazoleta(event.id);
        } catch (e) {
          _logger.w(
            'Error al cargar tiendas de la plazoleta, continuando sin tiendas: $e',
          );
          // Continuamos sin tiendas si hay error
        }

        if (requestId != _loadRequestId) {
          _logger.w(
            'LoadPlazoletaById($requestedId) cancelled after tiendas - newer request pending',
          );
          return;
        }

        if (state is PlazoletaLoaded) {
          final currentState = state as PlazoletaLoaded;
          emit(
            currentState.copyWith(
              plazoletaSeleccionada: plazoleta,
              imagenesPlazoleta: imagenes,
              productosPlazoleta: productos,
              tiendasPlazoleta: tiendas,
            ),
          );
        } else {
          emit(
            PlazoletaLoaded(
              plazoletas: [],
              plazoletaSeleccionada: plazoleta,
              imagenesPlazoleta: imagenes,
              productosPlazoleta: productos,
              tiendasPlazoleta: tiendas,
            ),
          );
        }
      } catch (e) {
        emit(
          PlazoletaDetailError(
            plazoletaId: event.id,
            message: 'Error al cargar plazoleta: $e',
            isRefreshing: event.forceRefresh,
          ),
        );
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Error en _onLoadPlazoletaById: $e',
        error: e,
        stackTrace: stackTrace,
      );
      emit(
        PlazoletaDetailError(
          plazoletaId: event.id,
          message: 'Error al cargar plazoleta: $e',
          stackTrace: stackTrace,
          isRefreshing: event.forceRefresh,
        ),
      );
    }
  }

  /// Cargar una plazoleta por slug (para deep links)
  Future<void> _onLoadPlazoletaBySlug(
    LoadPlazoletaBySlug event,
    Emitter<PlazoletaState> emit,
  ) async {
    final requestId = ++_loadRequestId;
    final requestedSlug = event.slug;

    try {
      emit(
        PlazoletaDetailLoading(
          plazoletaId: 0,
          isRefreshing: event.forceRefresh,
        ),
      );

      try {
        final plazoleta = await _plazoletaRepository.getPlazoletaBySlug(
          event.slug,
        );

        if (requestId != _loadRequestId) {
          _logger.w(
            'LoadPlazoletaBySlug($requestedSlug) cancelled - newer request pending',
          );
          return;
        }

        if (plazoleta == null) {
          emit(
            PlazoletaDetailError(
              plazoletaId: 0,
              message: 'No se encontró plazoleta con slug "${event.slug}"',
              isRefreshing: event.forceRefresh,
            ),
          );
          return;
        }

        if (plazoleta.id <= 0) {
          emit(
            PlazoletaDetailError(
              plazoletaId: 0,
              message:
                  'Plazoleta con slug "${event.slug}" tiene ID inválido: ${plazoleta.id}',
              isRefreshing: event.forceRefresh,
            ),
          );
          return;
        }

        final imagenes = await _plazoletaRepository.getImagenesPlazoleta(
          plazoleta.id,
        );

        if (requestId != _loadRequestId) {
          _logger.w(
            'LoadPlazoletaBySlug($requestedSlug) cancelled after imagenes - newer request pending',
          );
          return;
        }

        final productos = await _plazoletaRepository.getProductosPorPlazoleta(
          plazoleta.id,
        );

        if (requestId != _loadRequestId) {
          _logger.w(
            'LoadPlazoletaBySlug($requestedSlug) cancelled after productos - newer request pending',
          );
          return;
        }

        final tiendas = await _plazoletaRepository.getTiendasPlazoleta(
          plazoleta.id,
        );

        if (requestId != _loadRequestId) {
          _logger.w(
            'LoadPlazoletaBySlug($requestedSlug) cancelled after tiendas - newer request pending',
          );
          return;
        }

        emit(
          PlazoletaLoaded(
            plazoletas: [],
            plazoletaSeleccionada: plazoleta,
            imagenesPlazoleta: imagenes,
            productosPlazoleta: productos,
            tiendasPlazoleta: tiendas,
          ),
        );
      } catch (e) {
        if (requestId != _loadRequestId) {
          _logger.w(
            'LoadPlazoletaBySlug($requestedSlug) cancelled due to error - newer request pending',
          );
          return;
        }
        emit(
          PlazoletaDetailError(
            plazoletaId: 0,
            message: 'Error al cargar plazoleta: $e',
            isRefreshing: event.forceRefresh,
          ),
        );
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Error en _onLoadPlazoletaBySlug: $e',
        error: e,
        stackTrace: stackTrace,
      );
      emit(
        PlazoletaDetailError(
          plazoletaId: 0,
          message: 'Error al cargar plazoleta: $e',
          stackTrace: stackTrace,
          isRefreshing: event.forceRefresh,
        ),
      );
    }
  }

  /// Cargar plazoletas populares
  Future<void> _onLoadPlazoletasPopulares(
    LoadPlazoletasPopulares event,
    Emitter<PlazoletaState> emit,
  ) async {
    try {
      emit(const PlazoletaLoading(message: 'Cargando plazoletas populares...'));

      try {
        final plazoletas = await _plazoletaRepository.getPlazoletasPopulares(
          limit: event.limit,
        );

        if (state is PlazoletaLoaded) {
          final currentState = state as PlazoletaLoaded;
          emit(currentState.copyWith(plazoletas: plazoletas));
        } else {
          emit(PlazoletaLoaded(plazoletas: plazoletas));
        }
      } catch (e) {
        emit(
          PlazoletaErrorState(
            message: 'Error al cargar plazoletas populares: $e',
          ),
        );
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Error en _onLoadPlazoletasPopulares: $e',
        error: e,
        stackTrace: stackTrace,
      );
      emit(
        PlazoletaErrorState(
          message: 'Error al cargar plazoletas populares: $e',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Cargar plazoletas disponibles
  Future<void> _onLoadPlazoletasDisponibles(
    LoadPlazoletasDisponibles event,
    Emitter<PlazoletaState> emit,
  ) async {
    try {
      emit(
        const PlazoletaLoading(message: 'Cargando plazoletas disponibles...'),
      );

      try {
        final plazoletas = await _plazoletaRepository.getPlazoletasDisponibles(
          page: event.page,
          limit: event.limit,
        );

        if (state is PlazoletaLoaded) {
          final currentState = state as PlazoletaLoaded;
          emit(currentState.copyWith(plazoletas: plazoletas));
        } else {
          emit(PlazoletaLoaded(plazoletas: plazoletas));
        }
      } catch (e) {
        emit(
          PlazoletaErrorState(
            message: 'Error al cargar plazoletas disponibles: $e',
          ),
        );
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Error en _onLoadPlazoletasDisponibles: $e',
        error: e,
        stackTrace: stackTrace,
      );
      emit(
        PlazoletaErrorState(
          message: 'Error al cargar plazoletas disponibles: $e',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Buscar plazoletas
  Future<void> _onSearchPlazoletas(
    SearchPlazoletas event,
    Emitter<PlazoletaState> emit,
  ) async {
    try {
      emit(PlazoletaSearching(query: event.query));

      try {
        final plazoletas = await _plazoletaRepository.searchPlazoletas(
          event.query,
        );

        if (plazoletas.isEmpty) {
          emit(PlazoletaNoResults(query: event.query));
        } else {
          emit(
            PlazoletaLoaded(plazoletas: plazoletas, searchQuery: event.query),
          );
        }
      } catch (e) {
        emit(PlazoletaErrorState(message: 'Error al buscar plazoletas: $e'));
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Error en _onSearchPlazoletas: $e',
        error: e,
        stackTrace: stackTrace,
      );
      emit(
        PlazoletaErrorState(
          message: 'Error al buscar plazoletas: $e',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Cargar imágenes de una plazoleta
  Future<void> _onLoadImagenesPlazoleta(
    LoadImagenesPlazoleta event,
    Emitter<PlazoletaState> emit,
  ) async {
    if (event.plazoletaId <= 0) {
      _logger.w(
        'Ignorando LoadImagenesPlazoleta con plazoletaId inválido: ${event.plazoletaId}',
      );
      return;
    }

    // Guardar el estado actual si es PlazoletaLoaded
    final currentState = state;
    PlazoletaLoaded? savedState =
        currentState is PlazoletaLoaded ? currentState : null;

    try {
      // Emitir estado de carga manteniendo datos si ya existen
      if (savedState != null) {
        // Mantener los datos existentes y añadir indicador de carga
        emit(
          savedState.copyWith(
            imagenesPlazoleta: savedState.imagenesPlazoleta,
            isLoadingImagenes: true,
          ),
        );
      } else {
        // Si no hay estado guardado, emitir estado de carga básico
        emit(
          PlazoletaImagenesLoading(
            plazoletaId: event.plazoletaId,
            isRefreshing: event.forceRefresh,
          ),
        );
      }

      try {
        final imagenes = await _plazoletaRepository.getImagenesPlazoleta(
          event.plazoletaId,
        );

        if (savedState != null) {
          // Actualizar estado guardado con las nuevas imágenes
          emit(
            savedState.copyWith(
              imagenesPlazoleta: imagenes,
              isLoadingImagenes: false,
            ),
          );
        } else if (state is PlazoletaLoaded) {
          // Si después de cargar hay un estado PlazoletaLoaded (caso raro)
          final currentLoadedState = state as PlazoletaLoaded;
          emit(currentLoadedState.copyWith(imagenesPlazoleta: imagenes));
        }
      } catch (e) {
        if (savedState != null) {
          // Restaurar estado original en caso de error
          emit(savedState.copyWith(isLoadingImagenes: false));
        }
        emit(
          PlazoletaImagenesError(
            plazoletaId: event.plazoletaId,
            message: 'Error al cargar imágenes: $e',
            isRefreshing: event.forceRefresh,
          ),
        );
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Error en _onLoadImagenesPlazoleta: $e',
        error: e,
        stackTrace: stackTrace,
      );
      if (savedState != null) {
        // Restaurar estado original en caso de error
        emit(savedState.copyWith(isLoadingImagenes: false));
      }
      emit(
        PlazoletaImagenesError(
          plazoletaId: event.plazoletaId,
          message: 'Error al cargar imágenes: $e',
          stackTrace: stackTrace,
          isRefreshing: event.forceRefresh,
        ),
      );
    }
  }

  /// Cargar imagen principal de una plazoleta
  Future<void> _onLoadImagenPrincipalPlazoleta(
    LoadImagenPrincipalPlazoleta event,
    Emitter<PlazoletaState> emit,
  ) async {
    try {
      try {
        final imagen = await _plazoletaRepository.getImagenPrincipalPlazoleta(
          event.plazoletaId,
        );

        if (imagen != null && state is PlazoletaLoaded) {
          final currentState = state as PlazoletaLoaded;
          final imagenes = currentState.imagenesPlazoleta ?? [];
          if (!imagenes.any((i) => i.id == imagen.id)) {
            emit(
              currentState.copyWith(imagenesPlazoleta: [...imagenes, imagen]),
            );
          }
        }
      } catch (e) {
        _logger.w('No se pudo cargar imagen principal: $e');
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Error en _onLoadImagenPrincipalPlazoleta: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Cargar productos de una plazoleta
  Future<void> _onLoadProductosPlazoleta(
    LoadProductosPlazoleta event,
    Emitter<PlazoletaState> emit,
  ) async {
    if (event.plazoletaId <= 0) {
      _logger.w(
        'Ignorando LoadProductosPlazoleta con plazoletaId inválido: ${event.plazoletaId}',
      );
      return;
    }

    final previousState = state;

    // Si ya tenemos un estado cargado, mantenerlo durante la carga
    if (previousState is PlazoletaLoaded) {
      // Emitir el estado actual (sin cambios) para mantener la UI
      // La pestaña de productos mostrará loading porque productosPlazoleta es null
      // o mostrará datos anteriores mientras se cargan nuevos
      emit(previousState);
    } else {
      // Si no hay estado cargado, mostrar loading general
      emit(
        PlazoletaProductosLoading(
          plazoletaId: event.plazoletaId,
          isRefreshing: event.forceRefresh,
        ),
      );
    }

    try {
      final productos = await _plazoletaRepository.getProductosPorPlazoleta(
        event.plazoletaId,
        page: event.page,
        limit: event.limit,
        search: event.search,
        precioMin: event.precioMin,
        precioMax: event.precioMax,
        soloDisponibles: event.soloDisponibles,
      );

      if (previousState is PlazoletaLoaded) {
        emit(previousState.copyWith(productosPlazoleta: productos));
      } else {
        emit(
          PlazoletaLoaded(
            plazoletas: [],
            plazoletaSeleccionada: null,
            productosPlazoleta: productos,
          ),
        );
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Error en _onLoadProductosPlazoleta: $e',
        error: e,
        stackTrace: stackTrace,
      );
      emit(
        PlazoletaProductosError(
          plazoletaId: event.plazoletaId,
          message: 'Error al cargar productos: $e',
          stackTrace: stackTrace,
          isRefreshing: event.forceRefresh,
        ),
      );
    }
  }

  /// Cargar productos destacados de una plazoleta
  Future<void> _onLoadProductosDestacadosPlazoleta(
    LoadProductosDestacadosPlazoleta event,
    Emitter<PlazoletaState> emit,
  ) async {
    try {
      try {
        final productos = await _plazoletaRepository
            .getProductosDestacadosPlazoleta(
              event.plazoletaId,
              limit: event.limit,
            );

        if (state is PlazoletaLoaded) {
          final currentState = state as PlazoletaLoaded;
          emit(currentState.copyWith(productosPlazoleta: productos));
        }
      } catch (e) {
        _logger.w('No se pudieron cargar productos destacados: $e');
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Error en _onLoadProductosDestacadosPlazoleta: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Cargar tiendas de una plazoleta
  Future<void> _onLoadTiendasPlazoleta(
    LoadTiendasPlazoleta event,
    Emitter<PlazoletaState> emit,
  ) async {
    if (event.plazoletaId <= 0) {
      _logger.w(
        'Ignorando LoadTiendasPlazoleta con plazoletaId inválido: ${event.plazoletaId}',
      );
      return;
    }

    final previousState = state;

    // Si ya tenemos un estado cargado, mantenerlo durante la carga
    if (previousState is PlazoletaLoaded) {
      // Emitir el estado actual (sin cambios) para mantener la UI
      // La pestaña de tiendas mostrará loading porque tiendasPlazoleta es null
      // o mostrará datos anteriores mientras se cargan nuevos
      emit(previousState);
    } else {
      // Si no hay estado cargado, mostrar loading general
      emit(
        PlazoletaTiendasLoading(
          plazoletaId: event.plazoletaId,
          isRefreshing: event.forceRefresh,
        ),
      );
    }

    try {
      final tiendas = await _plazoletaRepository.getTiendasPlazoleta(
        event.plazoletaId,
        page: event.page,
        limit: event.limit,
        search: event.search,
        soloAbiertas: event.soloAbiertas,
      );

      if (previousState is PlazoletaLoaded) {
        emit(previousState.copyWith(tiendasPlazoleta: tiendas));
      } else {
        emit(
          PlazoletaLoaded(
            plazoletas: [],
            plazoletaSeleccionada: null,
            tiendasPlazoleta: tiendas,
          ),
        );
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Error en _onLoadTiendasPlazoleta: $e',
        error: e,
        stackTrace: stackTrace,
      );
      emit(
        PlazoletaTiendasError(
          plazoletaId: event.plazoletaId,
          message: 'Error al cargar tiendas: $e',
          stackTrace: stackTrace,
          isRefreshing: event.forceRefresh,
        ),
      );
    }
  }

  /// Cargar tiendas destacadas de una plazoleta
  Future<void> _onLoadTiendasDestacadasPlazoleta(
    LoadTiendasDestacadasPlazoleta event,
    Emitter<PlazoletaState> emit,
  ) async {
    final previousState = state;
    try {
      try {
        final tiendas = await _plazoletaRepository
            .getTiendasDestacadasPlazoleta(
              event.plazoletaId,
              limit: event.limit,
            );

        if (previousState is PlazoletaLoaded) {
          emit(previousState.copyWith(tiendasPlazoleta: tiendas));
        } else {
          emit(
            PlazoletaLoaded(
              plazoletas: [],
              plazoletaSeleccionada: null,
              tiendasPlazoleta: tiendas,
            ),
          );
        }
      } catch (e) {
        _logger.w('No se pudieron cargar tiendas destacadas: $e');
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Error en _onLoadTiendasDestacadasPlazoleta: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Incrementar visitas de una plazoleta
  Future<void> _onIncrementarVisitasPlazoleta(
    IncrementarVisitasPlazoleta event,
    Emitter<PlazoletaState> emit,
  ) async {
    try {
      // Obtener la plazoleta actual
      final plazoleta = await _plazoletaRepository.getPlazoletaById(
        event.plazoletaId,
      );

      // Incrementar contador de visitas (esto sería una llamada a la API en producción)
      // Por ahora, solo actualizamos localmente
      // Nota: El campo totalVisitas no existe en el esquema actual
      final updatedPlazoleta = plazoleta;

      // Actualizar el estado si estamos en un estado cargado
      if (state is PlazoletaLoaded) {
        final currentState = state as PlazoletaLoaded;

        // Actualizar la lista de plazoletas si está presente
        final updatedPlazoletas =
            currentState.plazoletas.map((p) {
              if (p.id == event.plazoletaId) {
                return updatedPlazoleta;
              }
              return p;
            }).toList();

        emit(
          currentState.copyWith(
            plazoletas: updatedPlazoletas,
            plazoletaSeleccionada:
                currentState.plazoletaSeleccionada?.id == event.plazoletaId
                    ? updatedPlazoleta
                    : currentState.plazoletaSeleccionada,
          ),
        );
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Error en _onIncrementarVisitasPlazoleta: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Cargar estadísticas de una plazoleta
  Future<void> _onLoadEstadisticasPlazoleta(
    LoadEstadisticasPlazoleta event,
    Emitter<PlazoletaState> emit,
  ) async {
    try {
      emit(
        PlazoletaEstadisticasLoading(
          plazoletaId: event.plazoletaId,
          isRefreshing: event.forceRefresh,
        ),
      );

      final result = await _plazoletaRepository.getEstadisticasPlazoleta(
        event.plazoletaId,
      );

      final estadisticas = result;
      if (state is PlazoletaLoaded) {
        final currentState = state as PlazoletaLoaded;
        emit(currentState.copyWith(estadisticas: estadisticas));
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Error en _onLoadEstadisticasPlazoleta: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Filtrar plazoletas
  Future<void> _onFilterPlazoletas(
    FilterPlazoletas event,
    Emitter<PlazoletaState> emit,
  ) async {
    try {
      emit(
        PlazoletaFiltering(
          filters: {
            'pisos': event.pisos,
            'sectores': event.sectores,
            'servicios': event.servicios,
            'tieneAccesoDiscapacitados': event.tieneAccesoDiscapacitados,
            'tieneEstacionamiento': event.tieneEstacionamiento,
            'tieneZonaDescanso': event.tieneZonaDescanso,
            'tieneZonaComida': event.tieneZonaComida,
            'latitud': event.latitud,
            'longitud': event.longitud,
            'radioKm': event.radioKm,
            'capacidadMinima': event.capacidadMinima,
            'capacidadMaxima': event.capacidadMaxima,
            'soloDisponibles': event.soloDisponibles,
          },
        ),
      );

      final result = await _plazoletaRepository.filtrarPlazoletas(
        pisos: event.pisos,
        sectores: event.sectores,
        servicios: event.servicios,
        tieneAccesoDiscapacitados: event.tieneAccesoDiscapacitados,
        tieneEstacionamiento: event.tieneEstacionamiento,
        tieneZonaDescanso: event.tieneZonaDescanso,
        tieneZonaComida: event.tieneZonaComida,
        latitud: event.latitud,
        longitud: event.longitud,
        radioKm: event.radioKm,
        capacidadMinima: event.capacidadMinima,
        capacidadMaxima: event.capacidadMaxima,
        soloDisponibles: event.soloDisponibles,
      );

      final plazoletas = result;
      if (plazoletas.isEmpty) {
        emit(
          PlazoletaNoResults(
            filters: {
              'pisos': event.pisos,
              'sectores': event.sectores,
              'servicios': event.servicios,
            },
          ),
        );
      } else {
        emit(
          PlazoletaLoaded(
            plazoletas: plazoletas,
            filters: {
              'pisos': event.pisos,
              'sectores': event.sectores,
              'servicios': event.servicios,
              'tieneAccesoDiscapacitados': event.tieneAccesoDiscapacitados,
              'tieneEstacionamiento': event.tieneEstacionamiento,
              'tieneZonaDescanso': event.tieneZonaDescanso,
              'tieneZonaComida': event.tieneZonaComida,
              'latitud': event.latitud,
              'longitud': event.longitud,
              'radioKm': event.radioKm,
              'capacidadMinima': event.capacidadMinima,
              'capacidadMaxima': event.capacidadMaxima,
              'soloDisponibles': event.soloDisponibles,
            },
          ),
        );
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Error en _onFilterPlazoletas: $e',
        error: e,
        stackTrace: stackTrace,
      );
      emit(
        PlazoletaErrorState(
          message: 'Error al filtrar plazoletas: $e',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Cargar plazoletas cercanas
  Future<void> _onLoadPlazoletasCercanas(
    LoadPlazoletasCercanas event,
    Emitter<PlazoletaState> emit,
  ) async {
    try {
      emit(const PlazoletaLoading(message: 'Buscando plazoletas cercanas...'));

      final result = await _plazoletaRepository.getPlazoletasCercanas(
        latitud: event.latitud,
        longitud: event.longitud,
        radioKm: event.radioKm,
        limit: event.limit,
      );

      final plazoletas = result;
      if (plazoletas.isEmpty) {
        emit(const PlazoletaNoResults());
      } else {
        emit(PlazoletaLoaded(plazoletas: plazoletas));
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Error en _onLoadPlazoletasCercanas: $e',
        error: e,
        stackTrace: stackTrace,
      );
      emit(
        PlazoletaErrorState(
          message: 'Error al buscar plazoletas cercanas: $e',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Sincronizar datos de plazoletas
  Future<void> _onSincronizarPlazoletas(
    SincronizarPlazoletas event,
    Emitter<PlazoletaState> emit,
  ) async {
    try {
      emit(const PlazoletaLoading(message: 'Sincronizando datos...'));

      await _plazoletaRepository.sincronizarPlazoletas();

      emit(
        PlazoletaSyncCompleted(
          updatedCount: 0, // TODO: Obtener conteo real
          syncTime: DateTime.now(),
        ),
      );
    } catch (e, stackTrace) {
      _logger.e(
        'Error en _onSincronizarPlazoletas: $e',
        error: e,
        stackTrace: stackTrace,
      );
      emit(
        PlazoletaErrorState(
          message: 'Error al sincronizar datos: $e',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Limpiar caché de plazoletas
  Future<void> _onLimpiarCachePlazoletas(
    LimpiarCachePlazoletas event,
    Emitter<PlazoletaState> emit,
  ) async {
    try {
      await _plazoletaRepository.limpiarCachePlazoletas();

      emit(const PlazoletaCacheCleared());
    } catch (e, stackTrace) {
      _logger.e(
        'Error en _onLimpiarCachePlazoletas: $e',
        error: e,
        stackTrace: stackTrace,
      );
      emit(
        PlazoletaErrorState(
          message: 'Error al limpiar caché: $e',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Verificar si hay caché de plazoletas
  Future<void> _onVerificarCachePlazoletas(
    VerificarCachePlazoletas event,
    Emitter<PlazoletaState> emit,
  ) async {
    try {
      final tieneCache = await _plazoletaRepository.tieneCachePlazoletas();

      if (tieneCache) {
        // TODO: Cargar datos desde caché
        emit(PlazoletaCacheLoaded(plazoletas: [], lastUpdated: DateTime.now()));
      } else {
        emit(const PlazoletaNoCache());
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Error en _onVerificarCachePlazoletas: $e',
        error: e,
        stackTrace: stackTrace,
      );
      emit(const PlazoletaNoCache());
    }
  }

  /// Seleccionar una plazoleta
  void _onSelectPlazoleta(SelectPlazoleta event, Emitter<PlazoletaState> emit) {
    if (event.plazoleta != null) {
      emit(PlazoletaSelected(plazoleta: event.plazoleta!));
    } else if (event.plazoletaId != null) {
      // TODO: Cargar plazoleta por ID si no se proporciona
      emit(
        PlazoletaSelected(
          plazoleta: Plazoleta(
            id: 0,
            nombre: '',
            tipoUbicacion: TipoUbicacion.plazoleta,
            slug: 'temp-slug',
            fechaCreacion: DateTime.now(),
          ),
        ),
      );
    }
  }

  /// Deseleccionar plazoleta
  void _onDeselectPlazoleta(
    DeselectPlazoleta event,
    Emitter<PlazoletaState> emit,
  ) {
    emit(const PlazoletaDeselected());
  }

  /// Navegar a detalle de plazoleta
  void _onNavigateToPlazoletaDetail(
    NavigateToPlazoletaDetail event,
    Emitter<PlazoletaState> emit,
  ) {
    // La navegación se maneja en la UI, este evento solo actualiza el estado si es necesario
    if (state is PlazoletaLoaded) {
      final currentState = state as PlazoletaLoaded;
      // Podemos cargar la plazoleta si no está ya cargada
      if (currentState.plazoletaSeleccionada?.id != event.plazoletaId) {
        add(LoadPlazoletaById(id: event.plazoletaId));
      }
    }
  }

  /// Navegar a productos de plazoleta
  void _onNavigateToPlazoletaProductos(
    NavigateToPlazoletaProductos event,
    Emitter<PlazoletaState> emit,
  ) {
    // La navegación se maneja en la UI
    add(LoadProductosPlazoleta(plazoletaId: event.plazoletaId));
  }

  /// Navegar a tiendas de plazoleta
  void _onNavigateToPlazoletaTiendas(
    NavigateToPlazoletaTiendas event,
    Emitter<PlazoletaState> emit,
  ) {
    // La navegación se maneja en la UI
    add(LoadTiendasPlazoleta(plazoletaId: event.plazoletaId));
  }

  /// Resetear estado del BLoC
  void _onResetPlazoletaState(
    ResetPlazoletaState event,
    Emitter<PlazoletaState> emit,
  ) {
    _currentPage = 1;
    _hasMore = true;
    _currentFilters = null;
    emit(const PlazoletaInitial());
  }

  /// Manejar error
  void _onPlazoletaError(PlazoletaError event, Emitter<PlazoletaState> emit) {
    emit(
      PlazoletaErrorState(message: event.message, stackTrace: event.stackTrace),
    );
  }

  @override
  Future<void> close() {
    // Llamar al método de la clase base para liberar recursos
    return super.close();
  }
}
