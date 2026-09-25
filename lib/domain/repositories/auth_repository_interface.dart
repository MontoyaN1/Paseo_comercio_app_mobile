// lib/domain/repositories/auth_repository_interface.dart

import 'package:equatable/equatable.dart';

/// Interfaz del repositorio de Autenticación que define los contratos
/// que deben implementar los repositorios concretos.
abstract class AuthRepositoryInterface {
  /// Verificar si el usuario está autenticado
  Future<bool> isAuthenticated();

  /// Obtener usuario actual
  Future<Map<String, dynamic>?> getCurrentUser();

  /// Iniciar sesión con Clerk
  Future<Map<String, dynamic>?> signInWithClerk({
    required String email,
    required String password,
  });

  /// Registrar nuevo usuario con Clerk
  Future<Map<String, dynamic>?> signUpWithClerk({
    required String email,
    required String password,
    required String nombreCompleto,
    String? telefono,
  });

  /// Iniciar sesión con proveedor social (Google, Facebook, etc.)
  Future<Map<String, dynamic>?> signInWithSocial(String provider);

  /// Cerrar sesión
  Future<bool> signOut();

  /// Verificar si el usuario tiene un perfil en nuestra base de datos
  Future<bool> hasUserProfile();

  /// Sincronizar usuario desde Clerk a nuestra base de datos
  Future<Map<String, dynamic>?> syncUserFromClerk({
    required String clerkUserId,
    required String nombreCompleto,
    required String email,
    String? telefono,
    String? avatarUrl,
  });

  /// Actualizar perfil de usuario
  Future<bool> updateUserProfile({
    String? nombreCompleto,
    String? telefono,
    bool? perfilPublico,
    String? avatarUrl,
  });

  /// Obtener token de autenticación
  Future<String?> getAuthToken();

  /// Verificar si el token es válido
  Future<bool> isTokenValid();

  /// Refrescar token
  Future<String?> refreshToken();

  /// Obtener stream de cambios en el estado de autenticación
  Stream<AuthState> get authStateStream;

  /// Limpiar recursos del repositorio
  void dispose();
}

/// Estados de autenticación
enum AuthState { authenticated, unauthenticated, loading, error }

/// Parámetros para iniciar sesión
class SignInParams extends Equatable {
  final String email;
  final String password;

  const SignInParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}

/// Parámetros para registrar usuario
class SignUpParams extends Equatable {
  final String email;
  final String password;
  final String nombreCompleto;
  final String? telefono;

  const SignUpParams({
    required this.email,
    required this.password,
    required this.nombreCompleto,
    this.telefono,
  });

  @override
  List<Object?> get props => [email, password, nombreCompleto, telefono];

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'nombre_completo': nombreCompleto,
      'telefono': telefono,
    };
  }
}

/// Parámetros para sincronizar usuario desde Clerk
class SyncUserFromClerkParams extends Equatable {
  final String clerkUserId;
  final String nombreCompleto;
  final String email;
  final String? telefono;
  final String? avatarUrl;

  const SyncUserFromClerkParams({
    required this.clerkUserId,
    required this.nombreCompleto,
    required this.email,
    this.telefono,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [clerkUserId, nombreCompleto, email, telefono];

  Map<String, dynamic> toJson() {
    return {
      'clerk_user_id': clerkUserId,
      'nombre_completo': nombreCompleto,
      'email': email,
      'telefono': telefono,
      'avatar_url': avatarUrl,
      'fecha_registro': DateTime.now().toIso8601String(),
      'ultimo_login': DateTime.now().toIso8601String(),
      'perfil_publico': true,
      'estado_usuario': 'activo',
    };
  }
}

/// Parámetros para actualizar perfil
class UpdateProfileParams extends Equatable {
  final String? nombreCompleto;
  final String? telefono;
  final bool? perfilPublico;
  final String? avatarUrl;

  const UpdateProfileParams({
    this.nombreCompleto,
    this.telefono,
    this.perfilPublico,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [
    nombreCompleto,
    telefono,
    perfilPublico,
    avatarUrl,
  ];

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (nombreCompleto != null) json['nombre_completo'] = nombreCompleto;
    if (telefono != null) json['telefono'] = telefono;
    if (perfilPublico != null) json['perfil_publico'] = perfilPublico;
    if (avatarUrl != null) json['avatar_url'] = avatarUrl;

    return json;
  }

  bool get hasUpdates {
    return nombreCompleto != null ||
        telefono != null ||
        perfilPublico != null ||
        avatarUrl != null;
  }
}

/// Excepciones del repositorio de autenticación
abstract class AuthRepositoryException implements Exception {
  final String message;
  final Object? cause;

  const AuthRepositoryException(this.message, {this.cause});

  @override
  String toString() =>
      'AuthRepositoryException: $message${cause != null ? ' (Caused by: $cause)' : ''}';
}

/// Excepción cuando las credenciales son inválidas
class InvalidCredentialsException extends AuthRepositoryException {
  const InvalidCredentialsException()
    : super('Credenciales inválidas. Verifica tu email y contraseña.');
}

/// Excepción cuando el usuario no existe
class UserNotFoundException extends AuthRepositoryException {
  final String email;

  const UserNotFoundException(this.email)
    : super('Usuario con email $email no encontrado');
}

/// Excepción cuando el usuario ya existe
class UserAlreadyExistsException extends AuthRepositoryException {
  final String email;

  const UserAlreadyExistsException(this.email)
    : super('Usuario con email $email ya existe');
}

/// Excepción cuando el email no es válido
class InvalidEmailException extends AuthRepositoryException {
  final String email;

  const InvalidEmailException(this.email) : super('Email inválido: $email');
}

/// Excepción cuando la contraseña es demasiado débil
class WeakPasswordException extends AuthRepositoryException {
  const WeakPasswordException()
    : super(
        'La contraseña es demasiado débil. Debe tener al menos 6 caracteres.',
      );
}

/// Excepción cuando el token ha expirado
class TokenExpiredException extends AuthRepositoryException {
  const TokenExpiredException()
    : super(
        'El token de autenticación ha expirado. Por favor, inicia sesión nuevamente.',
      );
}

/// Excepción cuando el token es inválido
class InvalidTokenException extends AuthRepositoryException {
  const InvalidTokenException() : super('Token de autenticación inválido.');
}

/// Excepción cuando no hay conexión a internet
class NoInternetConnectionAuthException extends AuthRepositoryException {
  const NoInternetConnectionAuthException()
    : super('No hay conexión a internet disponible. Verifica tu conexión.');
}

/// Excepción cuando Clerk no está disponible
class ClerkNotAvailableException extends AuthRepositoryException {
  const ClerkNotAvailableException()
    : super(
        'Servicio de autenticación no disponible temporalmente. Intenta más tarde.',
      );
}

/// Excepción cuando falla la sincronización con Supabase
class SyncWithSupabaseFailedException extends AuthRepositoryException {
  const SyncWithSupabaseFailedException(Object? cause)
    : super('Error al sincronizar usuario con la base de datos', cause: cause);
}

/// Excepción cuando el usuario no tiene permisos
class UnauthorizedException extends AuthRepositoryException {
  const UnauthorizedException()
    : super('No tienes permisos para realizar esta acción.');
}

/// Excepción cuando la sesión ha expirado
class SessionExpiredException extends AuthRepositoryException {
  const SessionExpiredException()
    : super('Tu sesión ha expirado. Por favor, inicia sesión nuevamente.');
}

/// Excepción cuando hay demasiados intentos fallidos
class TooManyAttemptsException extends AuthRepositoryException {
  const TooManyAttemptsException()
    : super('Demasiados intentos fallidos. Intenta más tarde.');
}

/// Excepción cuando el proveedor social no está configurado
class SocialProviderNotConfiguredException extends AuthRepositoryException {
  final String provider;

  const SocialProviderNotConfiguredException(this.provider)
    : super('Proveedor $provider no está configurado.');
}

/// Excepción cuando falla la autenticación social
class SocialAuthFailedException extends AuthRepositoryException {
  final String provider;

  const SocialAuthFailedException(this.provider, Object? cause)
    : super('Error al autenticar con $provider', cause: cause);
}

/// Excepción cuando el usuario no ha verificado su email
class EmailNotVerifiedException extends AuthRepositoryException {
  final String email;

  const EmailNotVerifiedException(this.email)
    : super('Por favor, verifica tu email $email antes de iniciar sesión.');
}

/// Excepción cuando la cuenta está desactivada
class AccountDisabledException extends AuthRepositoryException {
  const AccountDisabledException()
    : super('Tu cuenta ha sido desactivada. Contacta al administrador.');
}
