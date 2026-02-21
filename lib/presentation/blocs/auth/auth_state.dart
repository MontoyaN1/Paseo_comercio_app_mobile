// lib/presentation/blocs/auth/auth_state.dart

part of 'auth_bloc.dart';

/// Estados base para AuthBloc
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial - Aplicación cargando o sin autenticación verificada
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Estado de carga - Operación en progreso
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Estado autenticado - Usuario ha iniciado sesión exitosamente
class AuthAuthenticated extends AuthState {
  final Map<String, dynamic>? user;
  final DateTime? authenticatedAt;

  const AuthAuthenticated({this.user, this.authenticatedAt});

  @override
  List<Object?> get props => [user, authenticatedAt];

  AuthAuthenticated copyWith({
    Map<String, dynamic>? user,
    DateTime? authenticatedAt,
  }) {
    return AuthAuthenticated(
      user: user ?? this.user,
      authenticatedAt: authenticatedAt ?? this.authenticatedAt,
    );
  }
}

/// Estado no autenticado - Usuario no ha iniciado sesión
class AuthUnauthenticated extends AuthState {
  final String? message;

  const AuthUnauthenticated({this.message});

  @override
  List<Object?> get props => [message];
}

/// Estado de error - Ocurrió un error durante la autenticación
class AuthError extends AuthState {
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  const AuthError({required this.message, this.error, this.stackTrace});

  @override
  List<Object?> get props => [message, error, stackTrace];

  AuthError copyWith({String? message, Object? error, StackTrace? stackTrace}) {
    return AuthError(
      message: message ?? this.message,
      error: error ?? this.error,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }
}

/// Estado de registro exitoso - Usuario se registró exitosamente
class AuthRegistered extends AuthState {
  final Map<String, dynamic> user;
  final String message;

  const AuthRegistered({
    required this.user,
    this.message = 'Usuario registrado exitosamente',
  });

  @override
  List<Object?> get props => [user, message];
}

/// Estado de cierre de sesión exitoso
class AuthSignedOut extends AuthState {
  final String message;

  const AuthSignedOut({this.message = 'Sesión cerrada exitosamente'});

  @override
  List<Object?> get props => [message];
}

/// Estado de perfil actualizado
class AuthProfileUpdated extends AuthState {
  final Map<String, dynamic>? updatedUser;
  final String message;

  const AuthProfileUpdated({
    this.updatedUser,
    this.message = 'Perfil actualizado exitosamente',
  });

  @override
  List<Object?> get props => [updatedUser, message];
}

/// Estado de token refrescado
class AuthTokenRefreshed extends AuthState {
  final String newToken;
  final DateTime expiresAt;

  const AuthTokenRefreshed({required this.newToken, required this.expiresAt});

  @override
  List<Object?> get props => [newToken, expiresAt];
}

/// Estado de verificación de email requerida
class AuthEmailVerificationRequired extends AuthState {
  final String email;
  final String message;

  const AuthEmailVerificationRequired({
    required this.email,
    this.message = 'Por favor verifica tu email para continuar',
  });

  @override
  List<Object?> get props => [email, message];
}

/// Estado de restablecimiento de contraseña enviado
class AuthPasswordResetSent extends AuthState {
  final String email;
  final String message;

  const AuthPasswordResetSent({
    required this.email,
    this.message = 'Instrucciones enviadas a tu email',
  });

  @override
  List<Object?> get props => [email, message];
}

/// Estado de contraseña cambiada exitosamente
class AuthPasswordChanged extends AuthState {
  final String message;

  const AuthPasswordChanged({
    this.message = 'Contraseña cambiada exitosamente',
  });

  @override
  List<Object?> get props => [message];
}

/// Estado de cuenta eliminada
class AuthAccountDeleted extends AuthState {
  final String message;

  const AuthAccountDeleted({this.message = 'Cuenta eliminada exitosamente'});

  @override
  List<Object?> get props => [message];
}

/// Estado de autenticación social en progreso
class AuthSocialSignInProgress extends AuthState {
  final String provider;

  const AuthSocialSignInProgress({required this.provider});

  @override
  List<Object?> get props => [provider];
}

/// Estado de sincronización de usuario en progreso
class AuthSyncInProgress extends AuthState {
  final String clerkUserId;

  const AuthSyncInProgress({required this.clerkUserId});

  @override
  List<Object?> get props => [clerkUserId];
}

/// Estado de usuario sincronizado exitosamente
class AuthSynced extends AuthState {
  final Map<String, dynamic> user;
  final String message;

  const AuthSynced({
    required this.user,
    this.message = 'Usuario sincronizado exitosamente',
  });

  @override
  List<Object?> get props => [user, message];
}

/// Estado de sesión expirada
class AuthSessionExpired extends AuthState {
  final String message;

  const AuthSessionExpired({
    this.message =
        'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.',
  });

  @override
  List<Object?> get props => [message];
}

/// Estado de token inválido
class AuthInvalidToken extends AuthState {
  final String message;

  const AuthInvalidToken({this.message = 'Token de autenticación inválido'});

  @override
  List<Object?> get props => [message];
}

/// Estado de usuario sin perfil en base de datos
class AuthNoProfile extends AuthState {
  final String clerkUserId;
  final String email;
  final String nombreCompleto;

  const AuthNoProfile({
    required this.clerkUserId,
    required this.email,
    required this.nombreCompleto,
  });

  @override
  List<Object?> get props => [clerkUserId, email, nombreCompleto];
}

/// Estado de usuario bloqueado o desactivado
class AuthAccountDisabled extends AuthState {
  final String message;
  final String? reason;

  const AuthAccountDisabled({
    this.message = 'Tu cuenta ha sido desactivada',
    this.reason,
  });

  @override
  List<Object?> get props => [message, reason];
}

/// Estado de demasiados intentos fallidos
class AuthTooManyAttempts extends AuthState {
  final String message;
  final DateTime? retryAfter;

  const AuthTooManyAttempts({
    this.message = 'Demasiados intentos fallidos. Intenta más tarde.',
    this.retryAfter,
  });

  @override
  List<Object?> get props => [message, retryAfter];
}

/// Estado de red no disponible
class AuthNetworkError extends AuthState {
  final String message;

  const AuthNetworkError({
    this.message = 'No hay conexión a internet disponible',
  });

  @override
  List<Object?> get props => [message];
}

/// Estado de servicio no disponible
class AuthServiceUnavailable extends AuthState {
  final String service;
  final String message;

  const AuthServiceUnavailable({
    required this.service,
    this.message = 'Servicio no disponible temporalmente',
  });

  @override
  List<Object?> get props => [service, message];
}
