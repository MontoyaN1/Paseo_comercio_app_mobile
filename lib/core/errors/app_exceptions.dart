// lib/core/errors/app_exceptions.dart

/// Excepciones personalizadas de la aplicación
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic cause;

  const AppException({required this.message, this.code, this.cause});

  @override
  String toString() {
    final codeStr = code != null ? ' [$code]' : '';
    return '$runtimeType$codeStr: $message${cause != null ? '\nCausa: $cause' : ''}';
  }
}

/// Excepción de red
class NetworkException extends AppException {
  const NetworkException({
    String message = 'Error de conexión de red',
    String? code = 'NETWORK_ERROR',
    dynamic cause,
  }) : super(message: message, code: code, cause: cause);
}

/// Excepción de falta de internet
class NoInternetException extends NetworkException {
  const NoInternetException({
    String message = 'No hay conexión a internet',
    String? code = 'NO_INTERNET',
    dynamic cause,
  }) : super(message: message, code: code, cause: cause);
}

/// Excepción de servidor
class ServerException extends AppException {
  final int? statusCode;

  const ServerException({
    String message = 'Error del servidor',
    String? code = 'SERVER_ERROR',
    this.statusCode,
    dynamic cause,
  }) : super(message: message, code: code, cause: cause);

  @override
  String toString() {
    final statusStr = statusCode != null ? ' (HTTP $statusCode)' : '';
    return '$runtimeType$statusStr: $message${cause != null ? '\nCausa: $cause' : ''}';
  }
}

/// Excepción de autenticación
class AuthException extends AppException {
  const AuthException({
    String message = 'Error de autenticación',
    String? code = 'AUTH_ERROR',
    dynamic cause,
  }) : super(message: message, code: code, cause: cause);
}

/// Excepción de autorización
class AuthorizationException extends AppException {
  const AuthorizationException({
    String message = 'No tienes permisos para realizar esta acción',
    String? code = 'AUTHORIZATION_ERROR',
    dynamic cause,
  }) : super(message: message, code: code, cause: cause);
}

/// Excepción de validación
class ValidationException extends AppException {
  final Map<String, List<String>>? errors;

  const ValidationException({
    String message = 'Error de validación',
    String? code = 'VALIDATION_ERROR',
    this.errors,
    dynamic cause,
  }) : super(message: message, code: code, cause: cause);

  @override
  String toString() {
    final errorsStr =
        errors != null && errors!.isNotEmpty ? '\nErrores: $errors' : '';
    return '$runtimeType: $message$errorsStr${cause != null ? '\nCausa: $cause' : ''}';
  }
}

/// Excepción de datos no encontrados
class NotFoundException extends AppException {
  const NotFoundException({
    String message = 'Recurso no encontrado',
    String? code = 'NOT_FOUND',
    dynamic cause,
  }) : super(message: message, code: code, cause: cause);
}

/// Excepción de caché
class CacheException extends AppException {
  const CacheException({
    String message = 'Error de caché',
    String? code = 'CACHE_ERROR',
    dynamic cause,
  }) : super(message: message, code: code, cause: cause);
}

/// Excepción de base de datos
class DatabaseException extends AppException {
  const DatabaseException({
    String message = 'Error de base de datos',
    String? code = 'DATABASE_ERROR',
    dynamic cause,
  }) : super(message: message, code: code, cause: cause);
}

/// Excepción de formato
class FormatException extends AppException {
  const FormatException({
    String message = 'Error de formato',
    String? code = 'FORMAT_ERROR',
    dynamic cause,
  }) : super(message: message, code: code, cause: cause);
}

/// Excepción de tiempo de espera
class TimeoutException extends AppException {
  const TimeoutException({
    String message = 'Tiempo de espera agotado',
    String? code = 'TIMEOUT_ERROR',
    dynamic cause,
  }) : super(message: message, code: code, cause: cause);
}

/// Excepción de configuración
class ConfigurationException extends AppException {
  const ConfigurationException({
    String message = 'Error de configuración',
    String? code = 'CONFIGURATION_ERROR',
    dynamic cause,
  }) : super(message: message, code: code, cause: cause);
}

/// Excepción de almacenamiento
class StorageException extends AppException {
  const StorageException({
    String message = 'Error de almacenamiento',
    String? code = 'STORAGE_ERROR',
    dynamic cause,
  }) : super(message: message, code: code, cause: cause);
}

/// Excepción de imagen
class ImageException extends AppException {
  const ImageException({
    String message = 'Error de imagen',
    String? code = 'IMAGE_ERROR',
    dynamic cause,
  }) : super(message: message, code: code, cause: cause);
}

/// Excepción de funcionalidad no implementada
class NotImplementedException extends AppException {
  const NotImplementedException({
    String message = 'Funcionalidad no implementada',
    String? code = 'NOT_IMPLEMENTED',
    dynamic cause,
  }) : super(message: message, code: code, cause: cause);
}

/// Excepción de modo offline
class OfflineException extends AppException {
  const OfflineException({
    String message = 'Modo offline activado',
    String? code = 'OFFLINE_MODE',
    dynamic cause,
  }) : super(message: message, code: code, cause: cause);
}

/// Excepción de límite alcanzado
class LimitExceededException extends AppException {
  const LimitExceededException({
    String message = 'Límite alcanzado',
    String? code = 'LIMIT_EXCEEDED',
    dynamic cause,
  }) : super(message: message, code: code, cause: cause);
}

/// Excepción de pago requerido
class PaymentRequiredException extends AppException {
  const PaymentRequiredException({
    String message = 'Pago requerido',
    String? code = 'PAYMENT_REQUIRED',
    dynamic cause,
  }) : super(message: message, code: code, cause: cause);
}

/// Excepción de conflicto
class ConflictException extends AppException {
  const ConflictException({
    String message = 'Conflicto detectado',
    String? code = 'CONFLICT_ERROR',
    dynamic cause,
  }) : super(message: message, code: code, cause: cause);
}

/// Excepción de versión obsoleta
class VersionException extends AppException {
  final String? requiredVersion;
  final String? currentVersion;

  const VersionException({
    String message = 'Versión obsoleta',
    String? code = 'VERSION_ERROR',
    this.requiredVersion,
    this.currentVersion,
    dynamic cause,
  }) : super(message: message, code: code, cause: cause);

  @override
  String toString() {
    final versionInfo =
        requiredVersion != null
            ? '\nVersión requerida: $requiredVersion${currentVersion != null ? '\nVersión actual: $currentVersion' : ''}'
            : '';
    return '$runtimeType: $message$versionInfo${cause != null ? '\nCausa: $cause' : ''}';
  }
}

/// Excepción de mantenimiento
class MaintenanceException extends AppException {
  final DateTime? estimatedEndTime;

  const MaintenanceException({
    String message = 'Sistema en mantenimiento',
    String? code = 'MAINTENANCE',
    this.estimatedEndTime,
    dynamic cause,
  }) : super(message: message, code: code, cause: cause);

  @override
  String toString() {
    final timeInfo =
        estimatedEndTime != null
            ? '\nEstimado de finalización: $estimatedEndTime'
            : '';
    return '$runtimeType: $message$timeInfo${cause != null ? '\nCausa: $cause' : ''}';
  }
}

/// Excepción de rate limiting
class RateLimitException extends AppException {
  final Duration? retryAfter;

  const RateLimitException({
    String message = 'Límite de solicitudes alcanzado',
    String? code = 'RATE_LIMIT',
    this.retryAfter,
    dynamic cause,
  }) : super(message: message, code: code, cause: cause);

  @override
  String toString() {
    final retryInfo =
        retryAfter != null
            ? '\nReintentar después de: ${retryAfter!.inSeconds} segundos'
            : '';
    return '$runtimeType: $message$retryInfo${cause != null ? '\nCausa: $cause' : ''}';
  }
}

/// Excepción de funcionalidad deshabilitada
class FeatureDisabledException extends AppException {
  const FeatureDisabledException({
    String message = 'Funcionalidad deshabilitada',
    String? code = 'FEATURE_DISABLED',
    dynamic cause,
  }) : super(message: message, code: code, cause: cause);
}

/// Excepción de datos corruptos
class CorruptDataException extends AppException {
  const CorruptDataException({
    String message = 'Datos corruptos detectados',
    String? code = 'CORRUPT_DATA',
    dynamic cause,
  }) : super(message: message, code: code, cause: cause);
}

/// Excepción de sincronización
class SyncException extends AppException {
  const SyncException({
    String message = 'Error de sincronización',
    String? code = 'SYNC_ERROR',
    dynamic cause,
  }) : super(message: message, code: code, cause: cause);
}

/// Excepción de parseo
class ParseException extends AppException {
  const ParseException({
    String message = 'Error al parsear datos',
    String? code = 'PARSE_ERROR',
    dynamic cause,
  }) : super(message: message, code: code, cause: cause);
}

/// Excepción de integridad de datos
class DataIntegrityException extends AppException {
  const DataIntegrityException({
    String message = 'Error de integridad de datos',
    String? code = 'DATA_INTEGRITY_ERROR',
    dynamic cause,
  }) : super(message: message, code: code, cause: cause);
}

/// Excepción de recurso ocupado
class ResourceBusyException extends AppException {
  const ResourceBusyException({
    String message = 'Recurso ocupado',
    String? code = 'RESOURCE_BUSY',
    dynamic cause,
  }) : super(message: message, code: code, cause: cause);
}

/// Excepción de estado inválido
class InvalidStateException extends AppException {
  const InvalidStateException({
    String message = 'Estado inválido',
    String? code = 'INVALID_STATE',
    dynamic cause,
  }) : super(message: message, code: code, cause: cause);
}

/// Excepción de operación cancelada
class OperationCancelledException extends AppException {
  const OperationCancelledException({
    String message = 'Operación cancelada',
    String? code = 'OPERATION_CANCELLED',
    dynamic cause,
  }) : super(message: message, code: code, cause: cause);
}

/// Excepción de prueba
class TestException extends AppException {
  const TestException({
    String message = 'Excepción de prueba',
    String? code = 'TEST_EXCEPTION',
    dynamic cause,
  }) : super(message: message, code: code, cause: cause);
}

/// Excepción genérica para errores no clasificados
class GenericException extends AppException {
  const GenericException({
    String message = 'Error inesperado',
    String? code = 'GENERIC_ERROR',
    dynamic cause,
  }) : super(message: message, code: code, cause: cause);
}

/// Helper para manejar excepciones
class ExceptionHandler {
  /// Convertir cualquier excepción a AppException
  static AppException toAppException(dynamic error, [StackTrace? stackTrace]) {
    if (error is AppException) {
      return error;
    }

    if (error is FormatException) {
      return FormatException(
        message: 'Formato de datos inválido',
        cause: error,
      );
    }

    if (error is TimeoutException) {
      return TimeoutException(
        message: 'Tiempo de espera agotado',
        cause: error,
      );
    }

    // Manejar excepciones de red
    if (error.toString().contains('SocketException') ||
        error.toString().contains('Network is unreachable') ||
        error.toString().contains('Failed host lookup')) {
      return NetworkException(
        message: 'No hay conexión a internet',
        cause: error,
      );
    }

    // Manejar excepciones HTTP
    if (error.toString().contains('HttpException') ||
        error.toString().contains('status code')) {
      return ServerException(
        message: 'Error en la comunicación con el servidor',
        cause: error,
      );
    }

    // Excepción genérica
    return GenericException(
      message: 'Error inesperado: ${error.toString()}',
      cause: error,
    );
  }

  /// Obtener mensaje amigable para el usuario
  static String getUserFriendlyMessage(AppException exception) {
    switch (exception.runtimeType) {
      case NetworkException:
        return 'No hay conexión a internet. Verifica tu conexión e intenta nuevamente.';
      case ServerException:
        return 'Error del servidor. Por favor, intenta más tarde.';
      case AuthException:
        return 'Error de autenticación. Por favor, inicia sesión nuevamente.';
      case AuthorizationException:
        return 'No tienes permisos para realizar esta acción.';
      case ValidationException:
        return 'Por favor, corrige los errores en el formulario.';
      case NotFoundException:
        return 'El recurso solicitado no fue encontrado.';
      case TimeoutException:
        return 'La operación tardó demasiado. Por favor, intenta nuevamente.';
      case OfflineException:
        return 'Estás en modo offline. Algunas funciones pueden no estar disponibles.';
      case MaintenanceException:
        return 'El sistema está en mantenimiento. Por favor, intenta más tarde.';
      case RateLimitException:
        return 'Has realizado demasiadas solicitudes. Por favor, espera un momento.';
      case VersionException:
        return 'Necesitas actualizar la aplicación para continuar.';
      default:
        return 'Ha ocurrido un error inesperado. Por favor, intenta nuevamente.';
    }
  }

  /// Verificar si es un error de red
  static bool isNetworkError(dynamic error) {
    return error is NetworkException ||
        error.toString().contains('SocketException') ||
        error.toString().contains('Network is unreachable');
  }

  /// Verificar si es un error de servidor
  static bool isServerError(dynamic error) {
    return error is ServerException ||
        error.toString().contains('HttpException') ||
        error.toString().contains('status code');
  }

  /// Verificar si es un error de autenticación
  static bool isAuthError(dynamic error) {
    return error is AuthException || error is AuthorizationException;
  }

  /// Verificar si es un error recuperable
  static bool isRecoverableError(dynamic error) {
    return error is NetworkException ||
        error is TimeoutException ||
        error is OfflineException ||
        error is RateLimitException;
  }

  /// Verificar si es un error fatal
  static bool isFatalError(dynamic error) {
    return error is VersionException ||
        error is MaintenanceException ||
        error is ConfigurationException ||
        error is DataIntegrityException;
  }
}
