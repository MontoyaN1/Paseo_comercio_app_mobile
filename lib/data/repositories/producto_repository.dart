// lib/data/repositories/producto_repository.dart

import 'dart:async';

import '../../domain/repositories/producto_repository_interface.dart';
import '../datasources/remote/supabase_client.dart';
import '../datasources/local/local_database.dart';
import '../../core/utils/connectivity_service.dart';
import '../../core/utils/cache_service.dart';

/// Implementación dummy del repositorio de Productos para pruebas
class ProductoRepository implements ProductoRepositoryInterface {
  final SupabaseClientService _supabaseClient;
  final LocalCacheService _localCache;
  final ConnectivityService _connectivityService;
  final CacheService _cacheService;
  final StreamController<List<Map<String, dynamic>>>
  _productosStreamController =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  ProductoRepository({
    required SupabaseClientService supabaseClient,
    required LocalCacheService localCache,
    required ConnectivityService connectivityService,
    required CacheService cacheService,
  }) : _supabaseClient = supabaseClient,
       _localCache = localCache,
       _connectivityService = connectivityService,
       _cacheService = cacheService;

  @override
  Future<List<Map<String, dynamic>>> getProductos({
    int page = 1,
    int limit = 20,
    int? tiendaId,
    int? categoriaId,
    String? estado = 'publicado',
    bool forceRefresh = false,
  }) async {
    // Retornar datos dummy para pruebas
    return [
      {
        'id': 1,
        'nombre_producto': 'Producto de Prueba 1',
        'descripcion': 'Descripción del producto de prueba 1',
        'precio': 29.99,
        'precio_descuento': null,
        'moneda': 'USD',
        'tienda_id': 1,
        'categoria_id': 1,
        'estado_producto': 'publicado',
        'fecha_creacion': DateTime.now().toIso8601String(),
        'total_visitas': 100,
        'total_valoraciones': 5,
        'promedio_valoracion': 4.5,
        'tiendas': {
          'id': 1,
          'nombre_tienda': 'Tienda de Prueba',
          'descripcion': 'Descripción de tienda de prueba',
        },
        'categorias': {'id': 1, 'nombre_categoria': 'Categoría de Prueba'},
      },
      {
        'id': 2,
        'nombre_producto': 'Producto de Prueba 2',
        'descripcion': 'Descripción del producto de prueba 2',
        'precio': 49.99,
        'precio_descuento': 39.99,
        'moneda': 'USD',
        'tienda_id': 1,
        'categoria_id': 1,
        'estado_producto': 'publicado',
        'fecha_creacion': DateTime.now().toIso8601String(),
        'total_visitas': 150,
        'total_valoraciones': 8,
        'promedio_valoracion': 4.8,
        'tiendas': {
          'id': 1,
          'nombre_tienda': 'Tienda de Prueba',
          'descripcion': 'Descripción de tienda de prueba',
        },
        'categorias': {'id': 1, 'nombre_categoria': 'Categoría de Prueba'},
      },
    ];
  }

  @override
  Future<Map<String, dynamic>?> getProductoById(
    int productoId, {
    bool forceRefresh = false,
  }) async {
    // Retornar producto dummy
    return {
      'id': productoId,
      'nombre_producto': 'Producto de Prueba $productoId',
      'descripcion': 'Descripción del producto de prueba $productoId',
      'precio': 99.99,
      'precio_descuento': 79.99,
      'moneda': 'USD',
      'tienda_id': 1,
      'categoria_id': 1,
      'estado_producto': 'publicado',
      'fecha_creacion': DateTime.now().toIso8601String(),
      'total_visitas': 200,
      'total_valoraciones': 10,
      'promedio_valoracion': 4.7,
      'tiendas': {
        'id': 1,
        'nombre_tienda': 'Tienda de Prueba',
        'descripcion': 'Descripción de tienda de prueba',
      },
      'categorias': {'id': 1, 'nombre_categoria': 'Categoría de Prueba'},
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getProductosByTienda(
    int tiendaId, {
    int page = 1,
    int limit = 20,
    String? estado = 'publicado',
    bool forceRefresh = false,
  }) async {
    return getProductos(
      page: page,
      limit: limit,
      tiendaId: tiendaId,
      estado: estado,
      forceRefresh: forceRefresh,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getProductosByCategoria(
    int categoriaId, {
    int page = 1,
    int limit = 20,
    String? estado = 'publicado',
    bool forceRefresh = false,
  }) async {
    return getProductos(
      page: page,
      limit: limit,
      categoriaId: categoriaId,
      estado: estado,
      forceRefresh: forceRefresh,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> searchProductos(
    String query, {
    int page = 1,
    int limit = 20,
    int? tiendaId,
    int? categoriaId,
  }) async {
    // Retornar resultados dummy de búsqueda
    return [
      {
        'id': 3,
        'nombre_producto': 'Producto Buscado: $query',
        'descripcion': 'Resultado de búsqueda para: $query',
        'precio': 39.99,
        'precio_descuento': null,
        'moneda': 'USD',
        'tienda_id': 1,
        'categoria_id': 1,
        'estado_producto': 'publicado',
        'fecha_creacion': DateTime.now().toIso8601String(),
        'total_visitas': 75,
        'total_valoraciones': 3,
        'promedio_valoracion': 4.2,
        'tiendas': {
          'id': 1,
          'nombre_tienda': 'Tienda de Prueba',
          'descripcion': 'Descripción de tienda de prueba',
        },
        'categorias': {'id': 1, 'nombre_categoria': 'Categoría de Prueba'},
      },
    ];
  }

  @override
  Future<Map<String, dynamic>?> createProducto({
    required int tiendaId,
    required String nombreProducto,
    required String descripcion,
    required double precio,
    String? precioDescuento,
    String? moneda = 'USD',
    int? categoriaId,
    List<String>? etiquetas,
    List<String>? imagenesUrls,
    String? estadoProducto = 'borrador',
    Map<String, dynamic>? caracteristicas,
  }) async {
    // Retornar producto creado dummy
    return {
      'id': 999,
      'nombre_producto': nombreProducto,
      'descripcion': descripcion,
      'precio': precio,
      'precio_descuento': precioDescuento,
      'moneda': moneda,
      'tienda_id': tiendaId,
      'categoria_id': categoriaId,
      'estado_producto': estadoProducto ?? 'borrador',
      'fecha_creacion': DateTime.now().toIso8601String(),
      'total_visitas': 0,
      'total_valoraciones': 0,
      'promedio_valoracion': 0.0,
      'tiendas': {'id': tiendaId, 'nombre_tienda': 'Tienda Nueva'},
      'categorias':
          categoriaId != null
              ? {'id': categoriaId, 'nombre_categoria': 'Categoría Nueva'}
              : null,
    };
  }

  @override
  Future<bool> updateProducto(
    int productoId, {
    String? nombreProducto,
    String? descripcion,
    double? precio,
    String? precioDescuento,
    String? moneda,
    int? categoriaId,
    List<String>? etiquetas,
    List<String>? imagenesUrls,
    String? estadoProducto,
    Map<String, dynamic>? caracteristicas,
  }) async {
    // Simular actualización exitosa
    return true;
  }

  @override
  Future<bool> deleteProducto(int productoId) async {
    // Simular eliminación exitosa
    return true;
  }

  @override
  Future<bool> cambiarEstadoProducto(int productoId, String nuevoEstado) async {
    return updateProducto(productoId, estadoProducto: nuevoEstado);
  }

  @override
  Future<List<Map<String, dynamic>>> getProductosDestacados({
    int limit = 12,
  }) async {
    return getProductos(page: 1, limit: limit, estado: 'publicado');
  }

  @override
  Future<List<Map<String, dynamic>>> getProductosRecientes({
    int limit = 12,
  }) async {
    return getProductos(page: 1, limit: limit, estado: 'publicado');
  }

  @override
  Future<bool> registrarVistaProducto(int productoId) async {
    // Simular registro de vista
    return true;
  }

  @override
  Stream<List<Map<String, dynamic>>> get productosStream =>
      _productosStreamController.stream;

  @override
  void dispose() {
    _productosStreamController.close();
  }
}
