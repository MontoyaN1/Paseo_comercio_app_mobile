// lib/presentation/blocs/favorito/favorito_event.dart

import 'package:equatable/equatable.dart';

abstract class FavoritoEvent extends Equatable {
  const FavoritoEvent();

  @override
  List<Object?> get props => [];
}

class LoadFavoritos extends FavoritoEvent {
  final int usuarioId;

  const LoadFavoritos(this.usuarioId);

  @override
  List<Object?> get props => [usuarioId];
}

class ToggleTiendaFavorito extends FavoritoEvent {
  final int? usuarioId;
  final int tiendaId;

  const ToggleTiendaFavorito({this.usuarioId, required this.tiendaId});

  @override
  List<Object?> get props => [usuarioId, tiendaId];
}

class ToggleProductoFavorito extends FavoritoEvent {
  final int? usuarioId;
  final int productoId;

  const ToggleProductoFavorito({this.usuarioId, required this.productoId});

  @override
  List<Object?> get props => [usuarioId, productoId];
}

class CheckFavoritosStatus extends FavoritoEvent {
  final int usuarioId;
  final List<int>? tiendaIds;
  final List<int>? productoIds;

  const CheckFavoritosStatus({
    required this.usuarioId,
    this.tiendaIds,
    this.productoIds,
  });

  @override
  List<Object?> get props => [usuarioId, tiendaIds, productoIds];
}
