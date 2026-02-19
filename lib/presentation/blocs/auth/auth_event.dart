// lib/presentation/blocs/auth/auth_event.dart

import 'package:equatable/equatable.dart';

part of 'auth_bloc.dart';

/// Eventos base para AuthBloc
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para verificar estado de autenticación
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Evento para iniciar sesión
class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Evento para registrar usuario
class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String nombreCompleto;
  final String? telefono;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.nombreCompleto,
    this.telefono,
  });

  @override
  List<Object?> get props => [email, password, nombreCompleto, telefono];
}

/// Evento para cerrar sesión
class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

/// Evento para sincronizar usuario desde Clerk
class AuthSyncUserRequested extends AuthEvent {
  final String clerkUserId;
  final String nombreCompleto;
  final String email;
  final String? telefono;

  const AuthSyncUserRequested({
    required this.clerkUserId,
    required this.nombreCompleto,
    required this.email,
    this.telefono,
  });

  @override
  List<Object?> get props => [clerkUserId, nombreCompleto, email, telefono];
}

/// Evento para actualizar perfil de usuario
class AuthUpdateProfileRequested extends AuthEvent {
  final String? nombreCompleto;
  final String? telefono;
  final bool? perfilPublico;
  final String? avatarUrl;

  const AuthUpdateProfileRequested({
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
}

/// Evento para obtener usuario actual
class AuthGetCurrentUserRequested extends AuthEvent {
  const AuthGetCurrentUserRequested();
}

/// Evento para refrescar token de autenticación
class AuthRefreshTokenRequested extends AuthEvent {
  const AuthRefreshTokenRequested();
}

/// Evento para verificar si el usuario tiene perfil en base de datos
class AuthCheckProfileRequested extends AuthEvent {
  const AuthCheckProfileRequested();
}

/// Evento para iniciar sesión con proveedor social
class AuthSocialSignInRequested extends AuthEvent {
  final String provider;

  const AuthSocialSignInRequested({required this.provider});

  @override
  List<Object?> get props => [provider];
}

/// Evento para restablecer contraseña
class AuthResetPasswordRequested extends AuthEvent {
  final String email;

  const AuthResetPasswordRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Evento para verificar email
class AuthVerifyEmailRequested extends AuthEvent {
  final String email;
  final String code;

  const AuthVerifyEmailRequested({required this.email, required this.code});

  @override
  List<Object?> get props => [email, code];
}

/// Evento para cambiar contraseña
class AuthChangePasswordRequested extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  const AuthChangePasswordRequested({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

/// Evento para eliminar cuenta
class AuthDeleteAccountRequested extends AuthEvent {
  final String password;

  const AuthDeleteAccountRequested({required this.password});

  @override
  List<Object?> get props => [password];
}

/// Evento para limpiar errores
class AuthClearError extends AuthEvent {
  const AuthClearError();
}

/// Evento para limpiar mensajes de éxito
class AuthClearSuccess extends AuthEvent {
  const AuthClearSuccess();
}
