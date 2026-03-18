// lib/presentation/blocs/favorito/favorito_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import '../../../core/utils/firebase_auth_service.dart';
import '../../../data/datasources/remote/supabase_client.dart';
import '../../../di/service_locator.dart';
import '../../../domain/repositories/favorito_repository_interface.dart';
import 'favorito_event.dart';
import 'favorito_state.dart';

class FavoritoBloc extends Bloc<FavoritoEvent, FavoritoState> {
  final FavoritoRepositoryInterface _repository;
  final Logger _logger = Logger();
  int? _currentUsuarioId;

  FavoritoBloc(this._repository) : super(const FavoritoInitial()) {
    on<LoadFavoritos>(_onLoadFavoritos);
    on<ToggleTiendaFavorito>(_onToggleTiendaFavorito);
    on<ToggleProductoFavorito>(_onToggleProductoFavorito);
    on<CheckFavoritosStatus>(_onCheckFavoritosStatus);

    _loadInitialFavorites();
  }

  int? get currentUsuarioId => _currentUsuarioId;

  Future<void> _loadInitialFavorites() async {
    try {
      final authService = getIt<FirebaseAuthService>();
      final firebaseUser = authService.currentUser;
      _logger.i('Firebase user: ${firebaseUser?.uid}');

      if (firebaseUser != null) {
        final supabaseClient = getIt<SupabaseClientService>();
        final usuario = await supabaseClient.getUsuarioByFirebaseId(
          firebaseUser.uid,
        );

        _logger.i('Usuario encontrado: $usuario');

        if (usuario != null) {
          _currentUsuarioId = usuario['id'] as int;
          _logger.i('Usuario ID: $_currentUsuarioId');
          add(LoadFavoritos(_currentUsuarioId!));
        }
      } else {
        _logger.w('No hay usuario de Firebase autenticado');
      }
    } catch (e) {
      _logger.e('Error cargando favoritos iniciales: $e');
    }
  }

  Future<void> _onLoadFavoritos(
    LoadFavoritos event,
    Emitter<FavoritoState> emit,
  ) async {
    _logger.i('Cargando favoritos para usuario: ${event.usuarioId}');
    emit(const FavoritoLoading());

    try {
      final tiendasFavoritas = await _repository.getTiendasFavoritas(
        event.usuarioId,
      );
      final productosFavoritos = await _repository.getProductosFavoritos(
        event.usuarioId,
      );

      _logger.i('Tiendas favoritas: ${tiendasFavoritas.length}');
      _logger.i('Productos favoritos: ${productosFavoritos.length}');

      final tiendaIds = tiendasFavoritas.map((f) => f.itemId).toSet();
      final productoIds = productosFavoritos.map((f) => f.itemId).toSet();

      emit(FavoritosLoaded(tiendaIds: tiendaIds, productoIds: productoIds));
    } catch (e) {
      _logger.e('Error al cargar favoritos: $e');
      emit(FavoritoError('Error al cargar favoritos: $e'));
    }
  }

  Future<void> _onToggleTiendaFavorito(
    ToggleTiendaFavorito event,
    Emitter<FavoritoState> emit,
  ) async {
    var usuarioId = event.usuarioId;

    _logger.i(
      'Toggle tienda favorito - usuarioId: $usuarioId, tiendaId: ${event.tiendaId}',
    );

    if (usuarioId == null) {
      _logger.w(
        'Usuario no proporcionado, obteniendo usuario actual de Firebase',
      );
      usuarioId = await _getCurrentUsuarioId();
      if (usuarioId == null) {
        _logger.e('Usuario no autenticado - no se pudo obtener usuario');
        emit(const FavoritoError('Usuario no autenticado'));
        return;
      }
    }
    _currentUsuarioId = usuarioId;

    final currentState = state;
    Set<int> currentTiendaIds = {};
    Set<int> currentProductoIds = {};

    if (currentState is FavoritosLoaded) {
      currentTiendaIds = Set.from(currentState.tiendaIds);
      currentProductoIds = Set.from(currentState.productoIds);
    }

    try {
      final isFavorite = await _repository.toggleTiendaFavorito(
        usuarioId,
        event.tiendaId,
      );

      _logger.i('Toggle resultado - isFavorite: $isFavorite');

      if (isFavorite) {
        currentTiendaIds.add(event.tiendaId);
      } else {
        currentTiendaIds.remove(event.tiendaId);
      }

      emit(
        FavoritoToggled(
          itemId: event.tiendaId,
          tipo: 'tienda',
          isFavorite: isFavorite,
          tiendaIds: currentTiendaIds,
          productoIds: currentProductoIds,
        ),
      );

      emit(
        FavoritosLoaded(
          tiendaIds: currentTiendaIds,
          productoIds: currentProductoIds,
        ),
      );
    } catch (e) {
      _logger.e('Error al toggle favorito: $e');
      emit(FavoritoError('Error al actualizar favorito: $e'));
    }
  }

  Future<void> _onToggleProductoFavorito(
    ToggleProductoFavorito event,
    Emitter<FavoritoState> emit,
  ) async {
    var usuarioId = event.usuarioId;

    _logger.i(
      'Toggle producto favorito - usuarioId: $usuarioId, productoId: ${event.productoId}',
    );

    if (usuarioId == null) {
      _logger.w(
        'Usuario no proporcionado, obteniendo usuario actual de Firebase',
      );
      usuarioId = await _getCurrentUsuarioId();
      if (usuarioId == null) {
        _logger.e('Usuario no autenticado - no se pudo obtener usuario');
        emit(const FavoritoError('Usuario no autenticado'));
        return;
      }
    }
    _currentUsuarioId = usuarioId;

    final currentState = state;
    Set<int> currentTiendaIds = {};
    Set<int> currentProductoIds = {};

    if (currentState is FavoritosLoaded) {
      currentTiendaIds = Set.from(currentState.tiendaIds);
      currentProductoIds = Set.from(currentState.productoIds);
    }

    try {
      final isFavorite = await _repository.toggleProductoFavorito(
        usuarioId,
        event.productoId,
      );

      _logger.i('Toggle resultado - isFavorite: $isFavorite');

      if (isFavorite) {
        currentProductoIds.add(event.productoId);
      } else {
        currentProductoIds.remove(event.productoId);
      }

      emit(
        FavoritoToggled(
          itemId: event.productoId,
          tipo: 'producto',
          isFavorite: isFavorite,
          tiendaIds: currentTiendaIds,
          productoIds: currentProductoIds,
        ),
      );

      emit(
        FavoritosLoaded(
          tiendaIds: currentTiendaIds,
          productoIds: currentProductoIds,
        ),
      );
    } catch (e) {
      _logger.e('Error al toggle favorito: $e');
      emit(FavoritoError('Error al actualizar favorito: $e'));
    }
  }

  Future<void> _onCheckFavoritosStatus(
    CheckFavoritosStatus event,
    Emitter<FavoritoState> emit,
  ) async {
    final currentState = state;
    Set<int> currentTiendaIds = {};
    Set<int> currentProductoIds = {};

    if (currentState is FavoritosLoaded) {
      currentTiendaIds = Set.from(currentState.tiendaIds);
      currentProductoIds = Set.from(currentState.productoIds);
    }

    try {
      if (event.tiendaIds != null) {
        for (final tiendaId in event.tiendaIds!) {
          final isFavorite = await _repository.isTiendaFavorita(
            event.usuarioId,
            tiendaId,
          );
          if (isFavorite) {
            currentTiendaIds.add(tiendaId);
          } else {
            currentTiendaIds.remove(tiendaId);
          }
        }
      }

      if (event.productoIds != null) {
        for (final productoId in event.productoIds!) {
          final isFavorite = await _repository.isProductoFavorito(
            event.usuarioId,
            productoId,
          );
          if (isFavorite) {
            currentProductoIds.add(productoId);
          } else {
            currentProductoIds.remove(productoId);
          }
        }
      }

      emit(
        FavoritosLoaded(
          tiendaIds: currentTiendaIds,
          productoIds: currentProductoIds,
        ),
      );
    } catch (e) {
      _logger.e('Error al verificar favoritos: $e');
      emit(FavoritoError('Error al verificar favoritos: $e'));
    }
  }

  Future<int?> _getCurrentUsuarioId() async {
    try {
      final authService = getIt<FirebaseAuthService>();
      final firebaseUser = authService.currentUser;

      if (firebaseUser != null) {
        final supabaseClient = getIt<SupabaseClientService>();
        final usuario = await supabaseClient.getUsuarioByFirebaseId(
          firebaseUser.uid,
        );

        if (usuario != null) {
          return usuario['id'] as int;
        }
      }
    } catch (e) {
      _logger.e('Error obteniendo usuario actual: $e');
    }
    return null;
  }
}
