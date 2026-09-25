// lib/domain/failures/failure.dart

import 'package:equatable/equatable.dart';

/// Clase base abstracta para todas las fallas del sistema
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  final StackTrace? stackTrace;

  const Failure({required this.message, this.code, this.stackTrace});

  @override
  List<Object?> get props => [message, code, stackTrace];

  @override
  bool get stringify => true;

  @override
  String toString() {
    final codeStr = code != null ? ' (code: $code)' : '';
    return '$runtimeType: $message$codeStr';
  }
}

/// Fallas relacionadas con la red/conectividad
class NetworkFailure extends Failure {
  const NetworkFailure({
    String message = 'Error de red o conectividad',
    String? code,
    StackTrace? stackTrace,
  }) : super(message: message, code: code, stackTrace: stackTrace);
}

/// Fallas relacionadas con el servidor o API
class ServerFailure extends Failure {
  final int? statusCode;
  final dynamic responseData;

  const ServerFailure({
    String message = 'Error del servidor',
    String? code,
    StackTrace? stackTrace,
    this.statusCode,
    this.responseData,
  }) : super(message: message, code: code, stackTrace: stackTrace);

  @override
  List<Object?> get props => [...super.props, statusCode, responseData];
}

/// Fallas relacionadas con la caché local
class CacheFailure extends Failure {
  const CacheFailure({
    String message = 'Error de caché',
    String? code,
    StackTrace? stackTrace,
  }) : super(message: message, code: code, stackTrace: stackTrace);
}

/// Fallas de validación de datos
class ValidationFailure extends Failure {
  final Map<String, List<String>>? errors;

  const ValidationFailure({
    String message = 'Error de validación',
    String? code,
    StackTrace? stackTrace,
    this.errors,
  }) : super(message: message, code: code, stackTrace: stackTrace);

  @override
  List<Object?> get props => [...super.props, errors];
}

/// Fallas de autenticación/autorización
class AuthFailure extends Failure {
  const AuthFailure({
    String message = 'Error de autenticación',
    String? code,
    StackTrace? stackTrace,
  }) : super(message: message, code: code, stackTrace: stackTrace);
}

/// Fallas de permisos
class PermissionFailure extends Failure {
  const PermissionFailure({
    String message = 'Error de permisos',
    String? code,
    StackTrace? stackTrace,
  }) : super(message: message, code: code, stackTrace: stackTrace);
}

/// Fallas de datos no encontrados
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    String message = 'Recurso no encontrado',
    String? code,
    StackTrace? stackTrace,
  }) : super(message: message, code: code, stackTrace: stackTrace);
}

/// Fallas de tiempo de espera
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    String message = 'Tiempo de espera agotado',
    String? code,
    StackTrace? stackTrace,
  }) : super(message: message, code: code, stackTrace: stackTrace);
}

/// Fallas de parseo/deserialización
class ParseFailure extends Failure {
  final dynamic data;

  const ParseFailure({
    String message = 'Error al procesar los datos',
    String? code,
    StackTrace? stackTrace,
    this.data,
  }) : super(message: message, code: code, stackTrace: stackTrace);

  @override
  List<Object?> get props => [...super.props, data];
}

/// Fallas de base de datos
class DatabaseFailure extends Failure {
  const DatabaseFailure({
    String message = 'Error de base de datos',
    String? code,
    StackTrace? stackTrace,
  }) : super(message: message, code: code, stackTrace: stackTrace);
}

/// Fallas de archivos/sistema
class FileSystemFailure extends Failure {
  const FileSystemFailure({
    String message = 'Error del sistema de archivos',
    String? code,
    StackTrace? stackTrace,
  }) : super(message: message, code: code, stackTrace: stackTrace);
}

/// Fallas de configuración
class ConfigFailure extends Failure {
  const ConfigFailure({
    String message = 'Error de configuración',
    String? code,
    StackTrace? stackTrace,
  }) : super(message: message, code: code, stackTrace: stackTrace);
}

/// Fallas de operación no soportada
class UnsupportedFailure extends Failure {
  const UnsupportedFailure({
    String message = 'Operación no soportada',
    String? code,
    StackTrace? stackTrace,
  }) : super(message: message, code: code, stackTrace: stackTrace);
}

/// Fallas genéricas no categorizadas
class GenericFailure extends Failure {
  const GenericFailure({
    String message = 'Error desconocido',
    String? code,
    StackTrace? stackTrace,
  }) : super(message: message, code: code, stackTrace: stackTrace);
}
