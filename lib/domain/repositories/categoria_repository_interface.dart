// lib/domain/repositories/categoria_repository_interface.dart

import 'package:equatable/equatable.dart';

/// Interfaz del repositorio de Categorías que define los contratos
/// que deben implementar los repositorios concretos.
abstract class CategoriaRepositoryInterface {
  /// Obtener todas las categorías
  Future<List<Map<String, dynamic>>> getCategorias({bool forceRefresh});

  /// Obtener una categoría por ID
  Future<Map<String, dynamic>?> getCategoriaById(
    int categoriaId, {
    bool forceRefresh,
  });

  /// Obtener categorías por tipo
  Future<List<Map<String, dynamic>>> getCategoriasByTipo(
    String tipoCategoria, {
    bool forceRefresh,
  });

  /// Obtener categorías padre (sin parent_id)
  Future<List<Map<String, dynamic>>> getCategoriasPadre({bool forceRefresh});

  /// Obtener subcategorías de una categoría padre
  Future<List<Map<String, dynamic>>> getSubcategorias(
    int categoriaPadreId, {
    bool forceRefresh,
  });

  /// Obtener árbol completo de categorías
  Future<List<Map<String, dynamic>>> getArbolCategorias({bool forceRefresh});

  /// Buscar categorías por término de búsqueda
  Future<List<Map<String, dynamic>>> searchCategorias(String query);

  /// Crear nueva categoría
  Future<Map<String, dynamic>?> createCategoria({
    required String nombreCategoria,
    required String tipoCategoria,
    String? descripcion,
    int? parentId,
    String? icono,
    String? color,
    int? orden,
  });

  /// Actualizar categoría existente
  Future<bool> updateCategoria(
    int categoriaId, {
    String? nombreCategoria,
    String? tipoCategoria,
    String? descripcion,
    int? parentId,
    String? icono,
    String? color,
    int? orden,
  });

  /// Eliminar categoría
  Future<bool> deleteCategoria(int categoriaId);

  /// Obtener categorías más populares (con más productos)
  Future<List<Map<String, dynamic>>> getCategoriasPopulares({int limit});

  /// Obtener stream de cambios en las categorías
  Stream<List<Map<String, dynamic>>> get categoriasStream;

  /// Limpiar recursos del repositorio
  void dispose();
}

/// Parámetros para obtener categorías
class GetCategoriasParams extends Equatable {
  final bool forceRefresh;

  const GetCategoriasParams({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];

  GetCategoriasParams copyWith({bool? forceRefresh}) {
    return GetCategoriasParams(forceRefresh: forceRefresh ?? this.forceRefresh);
  }
}

/// Parámetros para obtener categorías por tipo
class GetCategoriasByTipoParams extends Equatable {
  final String tipoCategoria;
  final bool forceRefresh;

  const GetCategoriasByTipoParams({
    required this.tipoCategoria,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [tipoCategoria, forceRefresh];
}

/// Parámetros para obtener categorías padre
class GetCategoriasPadreParams extends Equatable {
  final bool forceRefresh;

  const GetCategoriasPadreParams({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

/// Parámetros para obtener subcategorías
class GetSubcategoriasParams extends Equatable {
  final int categoriaPadreId;
  final bool forceRefresh;

  const GetSubcategoriasParams({
    required this.categoriaPadreId,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [categoriaPadreId, forceRefresh];
}

/// Parámetros para obtener árbol de categorías
class GetArbolCategoriasParams extends Equatable {
  final bool forceRefresh;

  const GetArbolCategoriasParams({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

/// Parámetros para crear categoría
class CreateCategoriaParams extends Equatable {
  final String nombreCategoria;
  final String tipoCategoria;
  final String? descripcion;
  final int? parentId;
  final String? icono;
  final String? color;
  final int? orden;

  const CreateCategoriaParams({
    required this.nombreCategoria,
    required this.tipoCategoria,
    this.descripcion,
    this.parentId,
    this.icono,
    this.color,
    this.orden,
  });

  @override
  List<Object?> get props => [
    nombreCategoria,
    tipoCategoria,
    descripcion,
    parentId,
    icono,
    color,
    orden,
  ];

  Map<String, dynamic> toJson() {
    return {
      'nombre_categoria': nombreCategoria,
      'tipo_categoria': tipoCategoria,
      'descripcion': descripcion,
      'parent_id': parentId,
      'icono': icono,
      'color': color,
      'orden': orden ?? 0,
      'fecha_creacion': DateTime.now().toIso8601String(),
      'total_productos': 0,
      'total_tiendas': 0,
      'activa': true,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}

/// Parámetros para actualizar categoría
class UpdateCategoriaParams extends Equatable {
  final int categoriaId;
  final String? nombreCategoria;
  final String? tipoCategoria;
  final String? descripcion;
  final int? parentId;
  final String? icono;
  final String? color;
  final int? orden;

  const UpdateCategoriaParams({
    required this.categoriaId,
    this.nombreCategoria,
    this.tipoCategoria,
    this.descripcion,
    this.parentId,
    this.icono,
    this.color,
    this.orden,
  });

  @override
  List<Object?> get props => [
    categoriaId,
    nombreCategoria,
    tipoCategoria,
    descripcion,
    parentId,
    icono,
    color,
    orden,
  ];

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (nombreCategoria != null) json['nombre_categoria'] = nombreCategoria;
    if (tipoCategoria != null) json['tipo_categoria'] = tipoCategoria;
    if (descripcion != null) json['descripcion'] = descripcion;
    if (parentId != null) json['parent_id'] = parentId;
    if (icono != null) json['icono'] = icono;
    if (color != null) json['color'] = color;
    if (orden != null) json['orden'] = orden;
    json['updated_at'] = DateTime.now().toIso8601String();
    return json;
  }

  bool get hasUpdates {
    return nombreCategoria != null ||
        tipoCategoria != null ||
        descripcion != null ||
        parentId != null ||
        icono != null ||
        color != null ||
        orden != null;
  }
}

/// Parámetros para búsqueda de categorías
class SearchCategoriasParams extends Equatable {
  final String query;

  const SearchCategoriasParams({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Parámetros para obtener categorías populares
class GetCategoriasPopularesParams extends Equatable {
  final int limit;

  const GetCategoriasPopularesParams({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}

/// Excepciones del repositorio de categorías
abstract class CategoriaRepositoryException implements Exception {
  final String message;
  final Object? cause;

  const CategoriaRepositoryException(this.message, {this.cause});

  @override
  String toString() =>
      'CategoriaRepositoryException: $message${cause != null ? ' (Caused by: $cause)' : ''}';
}

/// Excepción cuando no se encuentra una categoría
class CategoriaNotFoundException extends CategoriaRepositoryException {
  final int categoriaId;

  const CategoriaNotFoundException(this.categoriaId)
    : super('Categoría con ID $categoriaId no encontrada');

  @override
  String toString() =>
      'CategoriaNotFoundException: Categoría con ID $categoriaId no encontrada';
}

/// Excepción cuando falla la creación de categoría
class CategoriaCreationFailedException extends CategoriaRepositoryException {
  const CategoriaCreationFailedException(Object? cause)
    : super('Error al crear la categoría', cause: cause);
}

/// Excepción cuando falla la actualización de categoría
class CategoriaUpdateFailedException extends CategoriaRepositoryException {
  final int categoriaId;

  const CategoriaUpdateFailedException(this.categoriaId, Object? cause)
    : super('Error al actualizar la categoría $categoriaId', cause: cause);
}

/// Excepción cuando falla la eliminación de categoría
class CategoriaDeleteFailedException extends CategoriaRepositoryException {
  final int categoriaId;

  const CategoriaDeleteFailedException(this.categoriaId, Object? cause)
    : super('Error al eliminar la categoría $categoriaId', cause: cause);
}

/// Excepción cuando el tipo de categoría no es válido
class TipoCategoriaInvalidoException extends CategoriaRepositoryException {
  final String tipoCategoria;

  const TipoCategoriaInvalidoException(this.tipoCategoria)
    : super('Tipo de categoría inválido: $tipoCategoria');
}

/// Excepción cuando la categoría tiene productos asociados
class CategoriaConProductosException extends CategoriaRepositoryException {
  final int categoriaId;

  const CategoriaConProductosException(this.categoriaId)
    : super(
        'La categoría $categoriaId tiene productos asociados y no puede ser eliminada',
      );
}

/// Excepción cuando la categoría tiene subcategorías
class CategoriaConSubcategoriasException extends CategoriaRepositoryException {
  final int categoriaId;

  const CategoriaConSubcategoriasException(this.categoriaId)
    : super(
        'La categoría $categoriaId tiene subcategorías y no puede ser eliminada',
      );
}

/// Excepción cuando se intenta crear un ciclo en el árbol de categorías
class CicloCategoriaException extends CategoriaRepositoryException {
  final int categoriaId;
  final int parentId;

  const CicloCategoriaException(this.categoriaId, this.parentId)
    : super(
        'No se puede asignar la categoría $categoriaId como padre de $parentId porque crearía un ciclo',
      );
}

/// Excepción cuando el nombre de categoría ya existe
class NombreCategoriaDuplicadoException extends CategoriaRepositoryException {
  final String nombreCategoria;

  const NombreCategoriaDuplicadoException(this.nombreCategoria)
    : super('Ya existe una categoría con el nombre: $nombreCategoria');
}

/// Excepción cuando la categoría está inactiva
class CategoriaInactivaException extends CategoriaRepositoryException {
  final int categoriaId;

  const CategoriaInactivaException(this.categoriaId)
    : super('La categoría $categoriaId está inactiva');
}
