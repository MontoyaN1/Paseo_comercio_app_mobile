// lib/data/repositories/producto_repository.dart

import 'dart:async';

import 'package:logger/logger.dart';

import '../../domain/repositories/producto_repository_interface.dart';
import '../datasources/remote/supabase_client.dart';
import '../datasources/local/local_database.dart';
import '../../core/utils/connectivity_service.dart';
import '../../core/utils/cache_service.dart';
import '../../core/app/app_config.dart';

/// Repositorio de Productos con datos reales de Supabase
class ProductoRepository implements ProductoRepositoryInterface {
  final StreamController<List<Map<String, dynamic>>>
  _productosStreamController =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  final SupabaseClientService _supabaseClient;
  final ConnectivityService _connectivityService;
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 3,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      printTime: false,
    ),
  );
  final AppConfig _appConfig = AppConfig();

  ProductoRepository({
    required SupabaseClientService supabaseClient,
    required LocalCacheService localCache,
    required ConnectivityService connectivityService,
    required CacheService cacheService,
  }) : _supabaseClient = supabaseClient,
       _connectivityService = connectivityService;

  @override
  Future<List<Map<String, dynamic>>> getProductos({
    int page = 1,
    int limit = 20,
    int? tiendaId,
    int? categoriaId,
    String? estado = 'publicado',
    bool forceRefresh = false,
  }) async {
    try {
      // Verificar conectividad
      final hasConnection = await _connectivityService.hasConnection();
      if (!hasConnection) {
        _logger.w('Sin conexión a internet');
        return [];
      }

      // Construir consulta base con join para obtener imágenes de productos
      var query = _supabaseClient.productos.select('''
          *,
          imagen_productos!left(*)
        ''');

      // Aplicar filtros
      if (tiendaId != null) {
        query = query.eq('tienda_id', tiendaId);
      }
      if (categoriaId != null) {
        query = query.eq('categoria_id', categoriaId);
      }
      if (estado != null && estado.isNotEmpty) {
        query = query.eq('estado_producto', estado);
      }

      // Aplicar paginación y orden
      final response = await query
          .order('fecha_creacion', ascending: false)
          .range((page - 1) * limit, page * limit - 1);

      _logger.d('Productos obtenidos: ${response.length}');

      // Transformar URLs de Contabo a Cloudflare R2
      final productosTransformados =
          response.map((producto) {
            return _transformProductoUrlsToR2(producto);
          }).toList();

      return productosTransformados;
    } catch (e, stackTrace) {
      _logger.e(
        'Error obteniendo productos: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  /// Transformar URLs de Contabo a Cloudflare R2 en los datos del producto
  Map<String, dynamic> _transformProductoUrlsToR2(
    Map<String, dynamic> producto,
  ) {
    final productoTransformado = Map<String, dynamic>.from(producto);

    // Transformar imagen_productos (array de imágenes)
    final imagenesProducto = productoTransformado['imagen_productos'];
    if (imagenesProducto is List) {
      final nuevasImagenes = <Map<String, dynamic>>[];
      for (final img in imagenesProducto) {
        if (img is Map<String, dynamic>) {
          final nuevaImagen = Map<String, dynamic>.from(img);
          // Transformar url_imagen
          final urlImagen = nuevaImagen['url_imagen'] as String?;
          if (urlImagen != null && urlImagen.contains('contabostorage.com')) {
            nuevaImagen['url_imagen'] = _transformContaboUrlToR2(urlImagen);
          }
          // Transformar url_original si existe
          final urlOriginal = nuevaImagen['url_original'] as String?;
          if (urlOriginal != null &&
              urlOriginal.contains('contabostorage.com')) {
            nuevaImagen['url_original'] = _transformContaboUrlToR2(urlOriginal);
          }
          nuevasImagenes.add(nuevaImagen);
        }
      }
      productoTransformado['imagen_productos'] = nuevasImagenes;
    }

    return productoTransformado;
  }

  /// Transformar URL de Contabo a Cloudflare R2
  String _transformContaboUrlToR2(String contaboUrl) {
    try {
      if (_appConfig.cloudflareR2PublicUrl.isEmpty) {
        return contaboUrl;
      }

      final uri = Uri.parse(contaboUrl);
      final pathSegments = uri.pathSegments;

      // Buscar el índice de 'paseocomercio' en la ruta
      final paseocomercioIndex = pathSegments.indexWhere(
        (segment) => segment == 'paseocomercio',
      );
      if (paseocomercioIndex == -1 ||
          paseocomercioIndex >= pathSegments.length - 1) {
        return contaboUrl;
      }

      // Construir ruta relativa después de 'paseocomercio'
      final relativePath = pathSegments
          .sublist(paseocomercioIndex + 1)
          .join('/');

      // Normalizar URL base eliminando barra final si existe
      String baseUrl = _appConfig.cloudflareR2PublicUrl.trim();
      if (baseUrl.endsWith('/')) {
        baseUrl = baseUrl.substring(0, baseUrl.length - 1);
      }

      // Construir URL de R2
      final r2Url = '$baseUrl/$relativePath';

      _logger.d('URL producto transformada: $contaboUrl → $r2Url');
      return r2Url;
    } catch (e) {
      _logger.e('Error transformando URL: $e');
      return contaboUrl;
    }
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
