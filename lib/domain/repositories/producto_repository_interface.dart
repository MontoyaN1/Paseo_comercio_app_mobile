// lib/domain/repositories/producto_repository_interface.dart

import 'package:equatable/equatable.dart';

/// Interfaz del repositorio de Productos que define los contratos
/// que deben implementar los repositorios concretos.
abstract class ProductoRepositoryInterface {
  /// Obtener todos los productos con paginación
  Future<List<Map<String, dynamic>>> getProductos({
    int page,
    int limit,
    int? tiendaId,
    int? categoriaId,
    String? estado,
    bool forceRefresh,
  });

  /// Obtener un producto por ID
  Future<Map<String, dynamic>?> getProductoById(
    int productoId, {
    bool forceRefresh,
  });

  /// Obtener productos por tienda
  Future<List<Map<String, dynamic>>> getProductosByTienda(
    int tiendaId, {
    int page,
    int limit,
    String? estado,
    bool forceRefresh,
  });

  /// Obtener productos por categoría
  Future<List<Map<String, dynamic>>> getProductosByCategoria(
    int categoriaId, {
    int page,
    int limit,
    String? estado,
    bool forceRefresh,
  });

  /// Buscar productos por término de búsqueda
  Future<List<Map<String, dynamic>>> searchProductos(
    String query, {
    int page,
    int limit,
    int? tiendaId,
    int? categoriaId,
  });

  /// Crear nuevo producto
  Future<Map<String, dynamic>?> createProducto({
    required int tiendaId,
    required String nombreProducto,
    required String descripcion,
    required double precio,
    String? precioDescuento,
    String? moneda,
    int? categoriaId,
    List<String>? etiquetas,
    List<String>? imagenesUrls,
    String? estadoProducto,
    Map<String, dynamic>? caracteristicas,
  });

  /// Actualizar producto existente
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
  });

  /// Eliminar producto
  Future<bool> deleteProducto(int productoId);

  /// Cambiar estado del producto
  Future<bool> cambiarEstadoProducto(int productoId, String nuevoEstado);

  /// Obtener productos destacados (mejor valorados)
  Future<List<Map<String, dynamic>>> getProductosDestacados({int limit});

  /// Obtener productos recientes
  Future<List<Map<String, dynamic>>> getProductosRecientes({int limit});

  /// Registrar vista de producto
  Future<bool> registrarVistaProducto(int productoId);

  /// Obtener stream de cambios en los productos
  Stream<List<Map<String, dynamic>>> get productosStream;

  /// Limpiar recursos del repositorio
  void dispose();
}

/// Parámetros para obtener productos
class GetProductosParams extends Equatable {
  final int page;
  final int limit;
  final int? tiendaId;
  final int? categoriaId;
  final String? estado;
  final bool forceRefresh;

  const GetProductosParams({
    this.page = 1,
    this.limit = 20,
    this.tiendaId,
    this.categoriaId,
    this.estado = 'publicado',
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [
    page,
    limit,
    tiendaId,
    categoriaId,
    estado,
    forceRefresh,
  ];

  GetProductosParams copyWith({
    int? page,
    int? limit,
    int? tiendaId,
    int? categoriaId,
    String? estado,
    bool? forceRefresh,
  }) {
    return GetProductosParams(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      tiendaId: tiendaId ?? this.tiendaId,
      categoriaId: categoriaId ?? this.categoriaId,
      estado: estado ?? this.estado,
      forceRefresh: forceRefresh ?? this.forceRefresh,
    );
  }
}

/// Parámetros para crear producto
class CreateProductoParams extends Equatable {
  final int tiendaId;
  final String nombreProducto;
  final String descripcion;
  final double precio;
  final String? precioDescuento;
  final String? moneda;
  final int? categoriaId;
  final List<String>? etiquetas;
  final List<String>? imagenesUrls;
  final String? estadoProducto;
  final Map<String, dynamic>? caracteristicas;

  const CreateProductoParams({
    required this.tiendaId,
    required this.nombreProducto,
    required this.descripcion,
    required this.precio,
    this.precioDescuento,
    this.moneda = 'USD',
    this.categoriaId,
    this.etiquetas,
    this.imagenesUrls,
    this.estadoProducto = 'borrador',
    this.caracteristicas,
  });

  @override
  List<Object?> get props => [
    tiendaId,
    nombreProducto,
    descripcion,
    precio,
    precioDescuento,
    moneda,
    categoriaId,
    etiquetas,
    imagenesUrls,
    estadoProducto,
    caracteristicas,
  ];

  Map<String, dynamic> toJson() {
    return {
      'tienda_id': tiendaId,
      'nombre_producto': nombreProducto,
      'descripcion': descripcion,
      'precio': precio,
      'precio_descuento': precioDescuento,
      'moneda': moneda,
      'categoria_id': categoriaId,
      'etiquetas': etiquetas,
      'imagenes_urls': imagenesUrls,
      'estado_producto': estadoProducto,
      'caracteristicas': caracteristicas,
      'fecha_creacion': DateTime.now().toIso8601String(),
      'total_visitas': 0,
      'total_valoraciones': 0,
      'promedio_valoracion': 0.0,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}

/// Parámetros para actualizar producto
class UpdateProductoParams extends Equatable {
  final int productoId;
  final String? nombreProducto;
  final String? descripcion;
  final double? precio;
  final String? precioDescuento;
  final String? moneda;
  final int? categoriaId;
  final List<String>? etiquetas;
  final List<String>? imagenesUrls;
  final String? estadoProducto;
  final Map<String, dynamic>? caracteristicas;

  const UpdateProductoParams({
    required this.productoId,
    this.nombreProducto,
    this.descripcion,
    this.precio,
    this.precioDescuento,
    this.moneda,
    this.categoriaId,
    this.etiquetas,
    this.imagenesUrls,
    this.estadoProducto,
    this.caracteristicas,
  });

  @override
  List<Object?> get props => [
    productoId,
    nombreProducto,
    descripcion,
    precio,
    precioDescuento,
    moneda,
    categoriaId,
    etiquetas,
    imagenesUrls,
    estadoProducto,
    caracteristicas,
  ];

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (nombreProducto != null) json['nombre_producto'] = nombreProducto;
    if (descripcion != null) json['descripcion'] = descripcion;
    if (precio != null) json['precio'] = precio;
    if (precioDescuento != null) json['precio_descuento'] = precioDescuento;
    if (moneda != null) json['moneda'] = moneda;
    if (categoriaId != null) json['categoria_id'] = categoriaId;
    if (etiquetas != null) json['etiquetas'] = etiquetas;
    if (imagenesUrls != null) json['imagenes_urls'] = imagenesUrls;
    if (estadoProducto != null) json['estado_producto'] = estadoProducto;
    if (caracteristicas != null) json['caracteristicas'] = caracteristicas;
    json['updated_at'] = DateTime.now().toIso8601String();
    return json;
  }

  bool get hasUpdates {
    return nombreProducto != null ||
        descripcion != null ||
        precio != null ||
        precioDescuento != null ||
        moneda != null ||
        categoriaId != null ||
        etiquetas != null ||
        imagenesUrls != null ||
        estadoProducto != null ||
        caracteristicas != null;
  }
}

/// Parámetros para búsqueda de productos
class SearchProductosParams extends Equatable {
  final String query;
  final int page;
  final int limit;
  final int? tiendaId;
  final int? categoriaId;

  const SearchProductosParams({
    required this.query,
    this.page = 1,
    this.limit = 20,
    this.tiendaId,
    this.categoriaId,
  });

  @override
  List<Object?> get props => [query, page, limit, tiendaId, categoriaId];
}

/// Parámetros para obtener productos por tienda
class GetProductosByTiendaParams extends Equatable {
  final int tiendaId;
  final int page;
  final int limit;
  final String? estado;
  final bool forceRefresh;

  const GetProductosByTiendaParams({
    required this.tiendaId,
    this.page = 1,
    this.limit = 20,
    this.estado = 'publicado',
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [tiendaId, page, limit, estado, forceRefresh];
}

/// Parámetros para obtener productos por categoría
class GetProductosByCategoriaParams extends Equatable {
  final int categoriaId;
  final int page;
  final int limit;
  final String? estado;
  final bool forceRefresh;

  const GetProductosByCategoriaParams({
    required this.categoriaId,
    this.page = 1,
    this.limit = 20,
    this.estado = 'publicado',
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [categoriaId, page, limit, estado, forceRefresh];
}

/// Parámetros para cambiar estado de producto
class CambiarEstadoProductoParams extends Equatable {
  final int productoId;
  final String nuevoEstado;

  const CambiarEstadoProductoParams({
    required this.productoId,
    required this.nuevoEstado,
  });

  @override
  List<Object?> get props => [productoId, nuevoEstado];
}

/// Parámetros para obtener productos destacados
class GetProductosDestacadosParams extends Equatable {
  final int limit;

  const GetProductosDestacadosParams({this.limit = 12});

  @override
  List<Object?> get props => [limit];
}

/// Parámetros para obtener productos recientes
class GetProductosRecientesParams extends Equatable {
  final int limit;

  const GetProductosRecientesParams({this.limit = 12});

  @override
  List<Object?> get props => [limit];
}

/// Excepciones del repositorio de productos
abstract class ProductoRepositoryException implements Exception {
  final String message;
  final Object? cause;

  const ProductoRepositoryException(this.message, {this.cause});

  @override
  String toString() =>
      'ProductoRepositoryException: $message${cause != null ? ' (Caused by: $cause)' : ''}';
}

/// Excepción cuando no se encuentra un producto
class ProductoNotFoundException extends ProductoRepositoryException {
  final int productoId;

  const ProductoNotFoundException(this.productoId)
    : super('Producto con ID $productoId no encontrado');

  @override
  String toString() =>
      'ProductoNotFoundException: Producto con ID $productoId no encontrado';
}

/// Excepción cuando falla la creación de producto
class ProductoCreationFailedException extends ProductoRepositoryException {
  const ProductoCreationFailedException(Object? cause)
    : super('Error al crear el producto', cause: cause);
}

/// Excepción cuando falla la actualización de producto
class ProductoUpdateFailedException extends ProductoRepositoryException {
  final int productoId;

  const ProductoUpdateFailedException(this.productoId, Object? cause)
    : super('Error al actualizar el producto $productoId', cause: cause);
}

/// Excepción cuando falla la eliminación de producto
class ProductoDeleteFailedException extends ProductoRepositoryException {
  final int productoId;

  const ProductoDeleteFailedException(this.productoId, Object? cause)
    : super('Error al eliminar el producto $productoId', cause: cause);
}

/// Excepción cuando el estado del producto no es válido
class EstadoProductoInvalidoException extends ProductoRepositoryException {
  final String estado;

  const EstadoProductoInvalidoException(this.estado)
    : super('Estado de producto inválido: $estado');
}

/// Excepción cuando el precio no es válido
class PrecioInvalidoException extends ProductoRepositoryException {
  final double precio;

  const PrecioInvalidoException(this.precio)
    : super('Precio inválido: $precio. Debe ser mayor a 0');
}

/// Excepción cuando no hay imágenes para el producto
class ProductoSinImagenesException extends ProductoRepositoryException {
  const ProductoSinImagenesException()
    : super('El producto debe tener al menos una imagen');
}

/// Excepción cuando la tienda no existe
class TiendaNoExisteException extends ProductoRepositoryException {
  final int tiendaId;

  const TiendaNoExisteException(this.tiendaId)
    : super('La tienda con ID $tiendaId no existe');
}

/// Excepción cuando la categoría no existe
class CategoriaNoExisteException extends ProductoRepositoryException {
  final int categoriaId;

  const CategoriaNoExisteException(this.categoriaId)
    : super('La categoría con ID $categoriaId no existe');
}
