// lib/data/repositories/favorito_repository_impl.dart

import '../../domain/repositories/favorito_repository_interface.dart';
import '../datasources/remote/favorito_remote_datasource.dart';
import '../models/domain/favorito/favorito.dart';

class FavoritoRepositoryImpl implements FavoritoRepositoryInterface {
  final FavoritoRemoteDataSource _remoteDataSource;

  FavoritoRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Favorito>> getTiendasFavoritas(int usuarioId) {
    return _remoteDataSource.getTiendasFavoritas(usuarioId);
  }

  @override
  Future<List<Favorito>> getProductosFavoritos(int usuarioId) {
    return _remoteDataSource.getProductosFavoritos(usuarioId);
  }

  @override
  Future<bool> toggleTiendaFavorito(int usuarioId, int tiendaId) {
    return _remoteDataSource.toggleTiendaFavorito(usuarioId, tiendaId);
  }

  @override
  Future<bool> toggleProductoFavorito(int usuarioId, int productoId) {
    return _remoteDataSource.toggleProductoFavorito(usuarioId, productoId);
  }

  @override
  Future<bool> isTiendaFavorita(int usuarioId, int tiendaId) {
    return _remoteDataSource.isTiendaFavorita(usuarioId, tiendaId);
  }

  @override
  Future<bool> isProductoFavorito(int usuarioId, int productoId) {
    return _remoteDataSource.isProductoFavorito(usuarioId, productoId);
  }
}
