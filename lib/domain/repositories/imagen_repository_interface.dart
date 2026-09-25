// lib/domain/repositories/imagen_repository_interface.dart

import 'package:equatable/equatable.dart';

/// Interfaz del repositorio de Imágenes que define los contratos
/// que deben implementar los repositorios concretos.
abstract class ImagenRepositoryInterface {
  /// Obtener imágenes de una entidad específica
  Future<List<Map<String, dynamic>>> getImagenesByEntity({
    required String entityType,
    required int entityId,
    String? tipoImagen,
    bool forceRefresh,
  });

  /// Obtener una imagen por ID
  Future<Map<String, dynamic>?> getImagenById(
    int imagenId, {
    bool forceRefresh,
  });

  /// Subir imagen para una entidad
  Future<Map<String, dynamic>?> uploadImagen({
    required String entityType,
    required int entityId,
    required String filePath,
    required String fileName,
    String? tipoImagen,
    int? orden,
    String? descripcion,
    bool? esPrincipal,
  });

  /// Subir múltiples imágenes
  Future<List<Map<String, dynamic>>> uploadMultipleImagenes({
    required String entityType,
    required int entityId,
    required List<String> filePaths,
    List<String>? fileNames,
    String? tipoImagen,
    List<int>? ordenes,
    List<String>? descripciones,
    List<bool>? esPrincipalList,
  });

  /// Eliminar imagen
  Future<bool> deleteImagen(int imagenId);

  /// Actualizar información de imagen
  Future<bool> updateImagen(
    int imagenId, {
    String? tipoImagen,
    int? orden,
    String? descripcion,
    bool? activa,
    bool? esPrincipal,
  });

  /// Obtener URL optimizada de imagen con variantes
  Future<Map<String, String>> getOptimizedImageUrls({
    required String originalUrl,
    List<int>? sizes,
    String? format,
  });

  /// Obtener imagen principal de una entidad
  Future<Map<String, dynamic>?> getImagenPrincipal({
    required String entityType,
    required int entityId,
    bool forceRefresh,
  });

  /// Cambiar imagen principal de una entidad
  Future<bool> setImagenPrincipal({
    required String entityType,
    required int entityId,
    required int imagenId,
  });

  /// Obtener imágenes por tipo
  Future<List<Map<String, dynamic>>> getImagenesByTipo(
    String tipoImagen, {
    int? entityId,
    String? entityType,
    bool forceRefresh,
  });

  /// Obtener stream de cambios en las imágenes de una entidad
  Stream<List<Map<String, dynamic>>> getImagenesStream({
    required String entityType,
    required int entityId,
  });

  /// Limpiar caché de imágenes
  Future<void> clearImageCache();

  /// Limpiar recursos del repositorio
  void dispose();
}

/// Parámetros para obtener imágenes por entidad
class GetImagenesByEntityParams extends Equatable {
  final String entityType;
  final int entityId;
  final String? tipoImagen;
  final bool forceRefresh;

  const GetImagenesByEntityParams({
    required this.entityType,
    required this.entityId,
    this.tipoImagen,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [entityType, entityId, tipoImagen, forceRefresh];

  GetImagenesByEntityParams copyWith({
    String? entityType,
    int? entityId,
    String? tipoImagen,
    bool? forceRefresh,
  }) {
    return GetImagenesByEntityParams(
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      tipoImagen: tipoImagen ?? this.tipoImagen,
      forceRefresh: forceRefresh ?? this.forceRefresh,
    );
  }
}

/// Parámetros para subir imagen
class UploadImagenParams extends Equatable {
  final String entityType;
  final int entityId;
  final String filePath;
  final String fileName;
  final String? tipoImagen;
  final int? orden;
  final String? descripcion;
  final bool? esPrincipal;

  const UploadImagenParams({
    required this.entityType,
    required this.entityId,
    required this.filePath,
    required this.fileName,
    this.tipoImagen,
    this.orden,
    this.descripcion,
    this.esPrincipal = false,
  });

  @override
  List<Object?> get props => [
    entityType,
    entityId,
    filePath,
    fileName,
    tipoImagen,
    orden,
    descripcion,
    esPrincipal,
  ];

  Map<String, dynamic> toJson() {
    return {
      'entity_type': entityType,
      'entity_id': entityId,
      'file_name': fileName,
      'tipo_imagen': tipoImagen ?? 'general',
      'orden': orden ?? 0,
      'descripcion': descripcion,
      'es_principal': esPrincipal ?? false,
      'activa': true,
      'fecha_creacion': DateTime.now().toIso8601String(),
      'total_vistas': 0,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}

/// Parámetros para subir múltiples imágenes
class UploadMultipleImagenesParams extends Equatable {
  final String entityType;
  final int entityId;
  final List<String> filePaths;
  final List<String>? fileNames;
  final String? tipoImagen;
  final List<int>? ordenes;
  final List<String>? descripciones;
  final List<bool>? esPrincipalList;

  const UploadMultipleImagenesParams({
    required this.entityType,
    required this.entityId,
    required this.filePaths,
    this.fileNames,
    this.tipoImagen,
    this.ordenes,
    this.descripciones,
    this.esPrincipalList,
  });

  @override
  List<Object?> get props => [
    entityType,
    entityId,
    filePaths,
    fileNames,
    tipoImagen,
    ordenes,
    descripciones,
    esPrincipalList,
  ];

  List<Map<String, dynamic>> toJsonList() {
    final List<Map<String, dynamic>> result = [];

    for (int i = 0; i < filePaths.length; i++) {
      result.add({
        'entity_type': entityType,
        'entity_id': entityId,
        'file_name':
            fileNames != null && i < fileNames!.length
                ? fileNames![i]
                : 'imagen_${DateTime.now().millisecondsSinceEpoch}_$i',
        'tipo_imagen': tipoImagen ?? 'general',
        'orden': ordenes != null && i < ordenes!.length ? ordenes![i] : i,
        'descripcion':
            descripciones != null && i < descripciones!.length
                ? descripciones![i]
                : null,
        'es_principal':
            esPrincipalList != null && i < esPrincipalList!.length
                ? esPrincipalList![i]
                : i == 0, // Primera imagen es principal por defecto
        'activa': true,
        'fecha_creacion': DateTime.now().toIso8601String(),
        'total_vistas': 0,
        'updated_at': DateTime.now().toIso8601String(),
      });
    }

    return result;
  }
}

/// Parámetros para actualizar imagen
class UpdateImagenParams extends Equatable {
  final int imagenId;
  final String? tipoImagen;
  final int? orden;
  final String? descripcion;
  final bool? activa;
  final bool? esPrincipal;

  const UpdateImagenParams({
    required this.imagenId,
    this.tipoImagen,
    this.orden,
    this.descripcion,
    this.activa,
    this.esPrincipal,
  });

  @override
  List<Object?> get props => [
    imagenId,
    tipoImagen,
    orden,
    descripcion,
    activa,
    esPrincipal,
  ];

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (tipoImagen != null) json['tipo_imagen'] = tipoImagen;
    if (orden != null) json['orden'] = orden;
    if (descripcion != null) json['descripcion'] = descripcion;
    if (activa != null) json['activa'] = activa;
    if (esPrincipal != null) json['es_principal'] = esPrincipal;
    json['updated_at'] = DateTime.now().toIso8601String();
    return json;
  }

  bool get hasUpdates {
    return tipoImagen != null ||
        orden != null ||
        descripcion != null ||
        activa != null ||
        esPrincipal != null;
  }
}

/// Parámetros para obtener imagen principal
class GetImagenPrincipalParams extends Equatable {
  final String entityType;
  final int entityId;
  final bool forceRefresh;

  const GetImagenPrincipalParams({
    required this.entityType,
    required this.entityId,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [entityType, entityId, forceRefresh];
}

/// Parámetros para cambiar imagen principal
class SetImagenPrincipalParams extends Equatable {
  final String entityType;
  final int entityId;
  final int imagenId;

  const SetImagenPrincipalParams({
    required this.entityType,
    required this.entityId,
    required this.imagenId,
  });

  @override
  List<Object?> get props => [entityType, entityId, imagenId];
}

/// Parámetros para obtener imágenes por tipo
class GetImagenesByTipoParams extends Equatable {
  final String tipoImagen;
  final int? entityId;
  final String? entityType;
  final bool forceRefresh;

  const GetImagenesByTipoParams({
    required this.tipoImagen,
    this.entityId,
    this.entityType,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [tipoImagen, entityId, entityType, forceRefresh];
}

/// Parámetros para URLs optimizadas de imagen
class GetOptimizedImageUrlsParams extends Equatable {
  final String originalUrl;
  final List<int>? sizes;
  final String? format;

  const GetOptimizedImageUrlsParams({
    required this.originalUrl,
    this.sizes,
    this.format = 'webp',
  });

  @override
  List<Object?> get props => [originalUrl, sizes, format];
}

/// Excepciones del repositorio de imágenes
abstract class ImagenRepositoryException implements Exception {
  final String message;
  final Object? cause;

  const ImagenRepositoryException(this.message, {this.cause});

  @override
  String toString() =>
      'ImagenRepositoryException: $message${cause != null ? ' (Caused by: $cause)' : ''}';
}

/// Excepción cuando no se encuentra una imagen
class ImagenNotFoundException extends ImagenRepositoryException {
  final int imagenId;

  const ImagenNotFoundException(this.imagenId)
    : super('Imagen con ID $imagenId no encontrada');

  @override
  String toString() =>
      'ImagenNotFoundException: Imagen con ID $imagenId no encontrada';
}

/// Excepción cuando falla la subida de imagen
class ImagenUploadFailedException extends ImagenRepositoryException {
  final String fileName;

  const ImagenUploadFailedException(this.fileName, Object? cause)
    : super('Error al subir la imagen $fileName', cause: cause);
}

/// Excepción cuando falla la eliminación de imagen
class ImagenDeleteFailedException extends ImagenRepositoryException {
  final int imagenId;

  const ImagenDeleteFailedException(this.imagenId, Object? cause)
    : super('Error al eliminar la imagen $imagenId', cause: cause);
}

/// Excepción cuando falla la actualización de imagen
class ImagenUpdateFailedException extends ImagenRepositoryException {
  final int imagenId;

  const ImagenUpdateFailedException(this.imagenId, Object? cause)
    : super('Error al actualizar la imagen $imagenId', cause: cause);
}

/// Excepción cuando el tipo de imagen no es válido
class TipoImagenInvalidoException extends ImagenRepositoryException {
  final String tipoImagen;

  const TipoImagenInvalidoException(this.tipoImagen)
    : super('Tipo de imagen inválido: $tipoImagen');
}

/// Excepción cuando el formato de imagen no es soportado
class FormatoImagenNoSoportadoException extends ImagenRepositoryException {
  final String formato;

  const FormatoImagenNoSoportadoException(this.formato)
    : super('Formato de imagen no soportado: $formato');
}

/// Excepción cuando el tamaño de imagen es demasiado grande
class ImagenDemasiadoGrandeException extends ImagenRepositoryException {
  final double sizeMB;
  final double maxSizeMB;

  const ImagenDemasiadoGrandeException(this.sizeMB, this.maxSizeMB)
    : super(
        'La imagen es demasiado grande: ${sizeMB}MB (máximo: ${maxSizeMB}MB)',
      );
}

/// Excepción cuando no hay espacio suficiente en el almacenamiento
class EspacioInsuficienteException extends ImagenRepositoryException {
  const EspacioInsuficienteException()
    : super('No hay espacio suficiente en el almacenamiento');
}

/// Excepción cuando la entidad no existe
class EntidadNoExisteException extends ImagenRepositoryException {
  final String entityType;
  final int entityId;

  const EntidadNoExisteException(this.entityType, this.entityId)
    : super('$entityType con ID $entityId no existe');
}

/// Excepción cuando no se pueden generar URLs optimizadas
class OptimizedUrlsGenerationFailedException extends ImagenRepositoryException {
  const OptimizedUrlsGenerationFailedException(Object? cause)
    : super('Error al generar URLs optimizadas', cause: cause);
}

/// Excepción cuando la imagen ya es principal
class ImagenYaEsPrincipalException extends ImagenRepositoryException {
  final int imagenId;

  const ImagenYaEsPrincipalException(this.imagenId)
    : super('La imagen $imagenId ya es la imagen principal');
}

/// Excepción cuando no se puede establecer imagen principal
class SetImagenPrincipalFailedException extends ImagenRepositoryException {
  final int imagenId;

  const SetImagenPrincipalFailedException(this.imagenId, Object? cause)
    : super(
        'Error al establecer la imagen $imagenId como principal',
        cause: cause,
      );
}

/// Excepción cuando hay demasiadas imágenes para una entidad
class DemasiadasImagenesException extends ImagenRepositoryException {
  final String entityType;
  final int entityId;
  final int maxImagenes;

  const DemasiadasImagenesException(
    this.entityType,
    this.entityId,
    this.maxImagenes,
  ) : super(
        '$entityType $entityId ya tiene el máximo de $maxImagenes imágenes permitidas',
      );
}

/// Excepción cuando la imagen está inactiva
class ImagenInactivaException extends ImagenRepositoryException {
  final int imagenId;

  const ImagenInactivaException(this.imagenId)
    : super('La imagen $imagenId está inactiva');
}

/// Excepción cuando falla la carga de imagen desde caché
class CacheLoadFailedException extends ImagenRepositoryException {
  const CacheLoadFailedException(Object? cause)
    : super('Error al cargar imagen desde caché', cause: cause);
}

/// Excepción cuando falla el guardado de imagen en caché
class CacheSaveFailedException extends ImagenRepositoryException {
  const CacheSaveFailedException(Object? cause)
    : super('Error al guardar imagen en caché', cause: cause);
}
