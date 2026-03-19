// lib/data/datasources/remote/favorito_remote_datasource.dart

import 'package:logger/logger.dart';

import '../../models/domain/favorito/favorito.dart';
import 'supabase_client.dart';

class FavoritoRemoteDataSource {
  final SupabaseClientService _supabaseClient;
  final Logger _logger = Logger();

  FavoritoRemoteDataSource(this._supabaseClient);

  Future<List<Favorito>> getTiendasFavoritas(int usuarioId) async {
    try {
      _logger.i('Fetching tiendas favoritas for usuarioId: $usuarioId');
      final response = await _supabaseClient.tiendaFavoritos
          .select()
          .eq('usuario_id', usuarioId)
          .order('fecha_creacion', ascending: false);

      _logger.i('Response: $response');

      return response.map((map) {
        final converted = Map<String, dynamic>.from(map is Map ? map : {});
        return Favorito.fromTiendaMap(converted);
      }).toList();
    } catch (e) {
      _logger.e('Error fetching tiendas favoritas: $e');
      return [];
    }
  }

  Future<List<Favorito>> getProductosFavoritos(int usuarioId) async {
    try {
      _logger.i('Fetching productos favoritos for usuarioId: $usuarioId');
      final response = await _supabaseClient.productoFavoritos
          .select()
          .eq('usuario_id', usuarioId)
          .order('fecha_creacion', ascending: false);

      _logger.i('Response: $response');

      return response.map((map) {
        final converted = Map<String, dynamic>.from(map is Map ? map : {});
        return Favorito.fromProductoMap(converted);
      }).toList();
    } catch (e) {
      _logger.e('Error fetching productos favoritos: $e');
      return [];
    }
  }

  Future<bool> addTiendaFavorito(int usuarioId, int tiendaId) async {
    try {
      _logger.i(
        'Adding tienda favorito - usuarioId: $usuarioId, tiendaId: $tiendaId',
      );
      await _supabaseClient.tiendaFavoritos.insert({
        'usuario_id': usuarioId,
        'tienda_id': tiendaId,
      });
      _logger.i('Tienda favorito añadido exitosamente');
      return true;
    } catch (e) {
      _logger.e('Error adding tienda favorito: $e');
      return false;
    }
  }

  Future<bool> removeTiendaFavorito(int usuarioId, int tiendaId) async {
    try {
      _logger.i(
        'Removing tienda favorito - usuarioId: $usuarioId, tiendaId: $tiendaId',
      );
      await _supabaseClient.tiendaFavoritos.delete().match({
        'usuario_id': usuarioId,
        'tienda_id': tiendaId,
      });
      _logger.i('Tienda favorito eliminado exitosamente');
      return true;
    } catch (e) {
      _logger.e('Error removing tienda favorito: $e');
      return false;
    }
  }

  Future<bool> addProductoFavorito(int usuarioId, int productoId) async {
    try {
      _logger.i(
        'Adding producto favorito - usuarioId: $usuarioId, productoId: $productoId',
      );
      await _supabaseClient.productoFavoritos.insert({
        'usuario_id': usuarioId,
        'producto_id': productoId,
      });
      _logger.i('Producto favorito añadido exitosamente');
      return true;
    } catch (e) {
      _logger.e('Error adding producto favorito: $e');
      return false;
    }
  }

  Future<bool> removeProductoFavorito(int usuarioId, int productoId) async {
    try {
      _logger.i(
        'Removing producto favorito - usuarioId: $usuarioId, productoId: $productoId',
      );
      await _supabaseClient.productoFavoritos.delete().match({
        'usuario_id': usuarioId,
        'producto_id': productoId,
      });
      _logger.i('Producto favorito eliminado exitosamente');
      return true;
    } catch (e) {
      _logger.e('Error removing producto favorito: $e');
      return false;
    }
  }

  Future<bool> isTiendaFavorita(int usuarioId, int tiendaId) async {
    try {
      final response =
          await _supabaseClient.tiendaFavoritos
              .select()
              .eq('usuario_id', usuarioId)
              .eq('tienda_id', tiendaId)
              .maybeSingle();
      return response != null;
    } catch (e) {
      _logger.e('Error checking if tienda is favorite: $e');
      return false;
    }
  }

  Future<bool> isProductoFavorito(int usuarioId, int productoId) async {
    try {
      final response =
          await _supabaseClient.productoFavoritos
              .select()
              .eq('usuario_id', usuarioId)
              .eq('producto_id', productoId)
              .maybeSingle();
      return response != null;
    } catch (e) {
      _logger.e('Error checking if producto is favorite: $e');
      return false;
    }
  }

  Future<bool> toggleTiendaFavorito(int usuarioId, int tiendaId) async {
    final isFavorite = await isTiendaFavorita(usuarioId, tiendaId);
    _logger.i('isTiendaFavorita: $isFavorite');
    if (isFavorite) {
      await removeTiendaFavorito(usuarioId, tiendaId);
      return false; // Now it's NOT a favorite
    } else {
      await addTiendaFavorito(usuarioId, tiendaId);
      return true; // Now it IS a favorite
    }
  }

  Future<bool> toggleProductoFavorito(int usuarioId, int productoId) async {
    final isFavorite = await isProductoFavorito(usuarioId, productoId);
    _logger.i('isProductoFavorito: $isFavorite');
    if (isFavorite) {
      await removeProductoFavorito(usuarioId, productoId);
      return false; // Now it's NOT a favorite
    } else {
      await addProductoFavorito(usuarioId, productoId);
      return true; // Now it IS a favorite
    }
  }
}
