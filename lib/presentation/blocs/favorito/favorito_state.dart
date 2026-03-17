// lib/presentation/blocs/favorito/favorito_state.dart

import 'package:equatable/equatable.dart';

abstract class FavoritoState extends Equatable {
  const FavoritoState();

  @override
  List<Object?> get props => [];
}

class FavoritoInitial extends FavoritoState {
  const FavoritoInitial();
}

class FavoritoLoading extends FavoritoState {
  const FavoritoLoading();
}

class FavoritosLoaded extends FavoritoState {
  final Set<int> tiendaIds;
  final Set<int> productoIds;

  const FavoritosLoaded({required this.tiendaIds, required this.productoIds});

  bool isTiendaFavorita(int tiendaId) => tiendaIds.contains(tiendaId);
  bool isProductoFavorito(int productoId) => productoIds.contains(productoId);

  FavoritosLoaded copyWith({Set<int>? tiendaIds, Set<int>? productoIds}) {
    return FavoritosLoaded(
      tiendaIds: tiendaIds ?? this.tiendaIds,
      productoIds: productoIds ?? this.productoIds,
    );
  }

  @override
  List<Object?> get props => [tiendaIds, productoIds];
}

class FavoritoToggled extends FavoritoState {
  final int itemId;
  final String tipo;
  final bool isFavorite;
  final Set<int> tiendaIds;
  final Set<int> productoIds;

  const FavoritoToggled({
    required this.itemId,
    required this.tipo,
    required this.isFavorite,
    required this.tiendaIds,
    required this.productoIds,
  });

  bool isTiendaFavorita(int tiendaId) => tiendaIds.contains(tiendaId);
  bool isProductoFavorito(int productoId) => productoIds.contains(productoId);

  @override
  List<Object?> get props => [itemId, tipo, isFavorite, tiendaIds, productoIds];
}

class FavoritoError extends FavoritoState {
  final String message;

  const FavoritoError(this.message);

  @override
  List<Object?> get props => [message];
}
