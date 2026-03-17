// lib/domain/repositories/favorito_repository_interface.dart

import '../../data/models/domain/favorito/favorito.dart';

abstract class FavoritoRepositoryInterface {
  Future<List<Favorito>> getTiendasFavoritas(int usuarioId);
  Future<List<Favorito>> getProductosFavoritos(int usuarioId);
  Future<bool> toggleTiendaFavorito(int usuarioId, int tiendaId);
  Future<bool> toggleProductoFavorito(int usuarioId, int productoId);
  Future<bool> isTiendaFavorita(int usuarioId, int tiendaId);
  Future<bool> isProductoFavorito(int usuarioId, int productoId);
}
