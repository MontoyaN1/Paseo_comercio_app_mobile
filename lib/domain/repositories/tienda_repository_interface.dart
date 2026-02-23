// lib/domain/repositories/tienda_repository_interface.dart

import 'package:equatable/equatable.dart';

/// Interfaz del repositorio de Tiendas que define los contratos
/// que deben implementar los repositorios concretos.
abstract class TiendaRepositoryInterface {
  /// Obtener todas las tiendas con paginación
  Future<List<Map<String, dynamic>>> getTiendas({
    int page,
    int limit,
    String? categoriaId,
    bool? soloActivas,
    bool forceRefresh,
  });

  /// Obtener una tienda por ID
  Future<Map<String, dynamic>?> getTiendaById(
    int tiendaId, {
    bool forceRefresh,
  });

  /// Obtener tiendas por propietario
  Future<List<Map<String, dynamic>>> getTiendasByPropietario(
    int propietarioId, {
    int page,
    int limit,
    bool forceRefresh,
  });

  /// Buscar tiendas por término de búsqueda
  Future<List<Map<String, dynamic>>> searchTiendas(
    String query, {
    int page,
    int limit,
  });

  /// Crear nueva tienda
  Future<Map<String, dynamic>?> createTienda({
    required int idPropietario,
    required String nombreTienda,
    String? descripcion,
    Map<String, dynamic>? redesSociales,
    int? organizacionId,
    String? emailContacto,
    String? telefonoContacto,
    String? direccion,
  });

  /// Actualizar tienda existente
  Future<bool> updateTienda(
    int tiendaId, {
    String? nombreTienda,
    String? descripcion,
    Map<String, dynamic>? redesSociales,
    int? organizacionId,
    String? emailContacto,
    String? telefonoContacto,
    String? direccion,
  });

  /// Eliminar tienda
  Future<bool> deleteTienda(int tiendaId);

  /// Registrar visita a tienda
  Future<bool> registrarVisitaTienda(int tiendaId);

  /// Obtener tiendas destacadas (más visitadas)
  Future<List<Map<String, dynamic>>> getTiendasDestacadas({int limit});

  /// Obtener stream de cambios en las tiendas
  Stream<List<Map<String, dynamic>>> get tiendasStream;

  /// Limpiar recursos del repositorio
  void dispose();
}

/// Parámetros para obtener tiendas
class GetTiendasParams extends Equatable {
  final int page;
  final int limit;
  final String? categoriaId;
  final bool? soloActivas;
  final bool forceRefresh;

  const GetTiendasParams({
    this.page = 1,
    this.limit = 20,
    this.categoriaId,
    this.soloActivas = true,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [
    page,
    limit,
    categoriaId,
    soloActivas,
    forceRefresh,
  ];

  GetTiendasParams copyWith({
    int? page,
    int? limit,
    String? categoriaId,
    bool? soloActivas,
    bool? forceRefresh,
  }) {
    return GetTiendasParams(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      categoriaId: categoriaId ?? this.categoriaId,
      soloActivas: soloActivas ?? this.soloActivas,
      forceRefresh: forceRefresh ?? this.forceRefresh,
    );
  }
}

/// Parámetros para crear tienda
class CreateTiendaParams extends Equatable {
  final int idPropietario;
  final String nombreTienda;
  final String? descripcion;
  final Map<String, dynamic>? redesSociales;
  final int? organizacionId;
  final String? emailContacto;
  final String? telefonoContacto;
  final String? direccion;

  const CreateTiendaParams({
    required this.idPropietario,
    required this.nombreTienda,
    this.descripcion,
    this.redesSociales,
    this.organizacionId,
    this.emailContacto,
    this.telefonoContacto,
    this.direccion,
  });

  @override
  List<Object?> get props => [
    idPropietario,
    nombreTienda,
    descripcion,
    redesSociales,
    organizacionId,
    emailContacto,
    telefonoContacto,
    direccion,
  ];

  Map<String, dynamic> toJson() {
    return {
      'id_propietario': idPropietario,
      'nombre_tienda': nombreTienda,
      'descripcion': descripcion,
      'redes_sociales': redesSociales,
      'organizacion_id': organizacionId,
      'email_contacto': emailContacto,
      'telefono_contacto': telefonoContacto,
      'direccion': direccion,
      'fecha_creacion': DateTime.now().toIso8601String(),
      'total_visitas': 0,
      'total_contactos_whatsapp': 0,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}

/// Parámetros para actualizar tienda
class UpdateTiendaParams extends Equatable {
  final int tiendaId;
  final String? nombreTienda;
  final String? descripcion;
  final Map<String, dynamic>? redesSociales;
  final int? organizacionId;
  final String? emailContacto;
  final String? telefonoContacto;
  final String? direccion;

  const UpdateTiendaParams({
    required this.tiendaId,
    this.nombreTienda,
    this.descripcion,
    this.redesSociales,
    this.organizacionId,
    this.emailContacto,
    this.telefonoContacto,
    this.direccion,
  });

  @override
  List<Object?> get props => [
    tiendaId,
    nombreTienda,
    descripcion,
    redesSociales,
    organizacionId,
    emailContacto,
    telefonoContacto,
    direccion,
  ];

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (nombreTienda != null) json['nombre_tienda'] = nombreTienda;
    if (descripcion != null) json['descripcion'] = descripcion;
    if (redesSociales != null) json['redes_sociales'] = redesSociales;
    if (organizacionId != null) json['organizacion_id'] = organizacionId;
    if (emailContacto != null) json['email_contacto'] = emailContacto;
    if (telefonoContacto != null) json['telefono_contacto'] = telefonoContacto;
    if (direccion != null) json['direccion'] = direccion;
    json['updated_at'] = DateTime.now().toIso8601String();
    return json;
  }

  bool get hasUpdates {
    return nombreTienda != null ||
        descripcion != null ||
        redesSociales != null ||
        organizacionId != null ||
        emailContacto != null ||
        telefonoContacto != null ||
        direccion != null;
  }
}

/// Parámetros para búsqueda de tiendas
class SearchTiendasParams extends Equatable {
  final String query;
  final int page;
  final int limit;

  const SearchTiendasParams({
    required this.query,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [query, page, limit];
}

/// Parámetros para obtener tiendas por propietario
class GetTiendasByPropietarioParams extends Equatable {
  final int propietarioId;
  final int page;
  final int limit;
  final bool forceRefresh;

  const GetTiendasByPropietarioParams({
    required this.propietarioId,
    this.page = 1,
    this.limit = 20,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [propietarioId, page, limit, forceRefresh];
}

/// Parámetros para obtener tiendas destacadas
class GetTiendasDestacadasParams extends Equatable {
  final int limit;

  const GetTiendasDestacadasParams({this.limit = 12});

  @override
  List<Object?> get props => [limit];
}

/// Excepciones del repositorio de tiendas
abstract class TiendaRepositoryException implements Exception {
  final String message;
  final Object? cause;

  const TiendaRepositoryException(this.message, {this.cause});

  @override
  String toString() =>
      'TiendaRepositoryException: $message${cause != null ? ' (Caused by: $cause)' : ''}';
}

/// Excepción cuando no se encuentra una tienda
class TiendaNotFoundException extends TiendaRepositoryException {
  final int tiendaId;

  const TiendaNotFoundException(this.tiendaId)
    : super('Tienda con ID $tiendaId no encontrada');

  @override
  String toString() =>
      'TiendaNotFoundException: Tienda con ID $tiendaId no encontrada';
}

/// Excepción cuando falla la creación de tienda
class TiendaCreationFailedException extends TiendaRepositoryException {
  const TiendaCreationFailedException(Object? cause)
    : super('Error al crear la tienda', cause: cause);
}

/// Excepción cuando falla la actualización de tienda
class TiendaUpdateFailedException extends TiendaRepositoryException {
  final int tiendaId;

  const TiendaUpdateFailedException(this.tiendaId, Object? cause)
    : super('Error al actualizar la tienda $tiendaId', cause: cause);
}

/// Excepción cuando falla la eliminación de tienda
class TiendaDeleteFailedException extends TiendaRepositoryException {
  final int tiendaId;

  const TiendaDeleteFailedException(this.tiendaId, Object? cause)
    : super('Error al eliminar la tienda $tiendaId', cause: cause);
}

/// Excepción cuando no hay conexión a internet
class NoInternetConnectionException extends TiendaRepositoryException {
  const NoInternetConnectionException()
    : super('No hay conexión a internet disponible');
}

/// Excepción cuando la caché está vacía o expirada
class CacheEmptyException extends TiendaRepositoryException {
  const CacheEmptyException() : super('La caché está vacía o ha expirado');
}

/// Excepción cuando hay un error de validación
class ValidationException extends TiendaRepositoryException {
  final Map<String, String> errors;

  const ValidationException(this.errors) : super('Error de validación');

  @override
  String toString() {
    final errorMessages = errors.entries
        .map((e) => '${e.key}: ${e.value}')
        .join(', ');
    return 'ValidationException: $errorMessages';
  }
}
