// lib/domain/usecases/authenticate_user_usecase.dart

import 'package:equatable/equatable.dart';

import '../repositories/auth_repository_interface.dart';

/// Caso de uso para autenticar usuario
class AuthenticateUserUseCase {
  final AuthRepositoryInterface _authRepository;

  AuthenticateUserUseCase(this._authRepository);

  /// Ejecutar el caso de uso para iniciar sesión
  Future<Map<String, dynamic>?> signIn(SignInParams params) async {
    try {
      return await _authRepository.signInWithClerk(
        email: params.email,
        password: params.password,
      );
    } catch (e) {
      // Re-lanzar la excepción para que sea manejada por la capa de presentación
      rethrow;
    }
  }

  /// Ejecutar el caso de uso para registrar usuario
  Future<Map<String, dynamic>?> signUp(SignUpParams params) async {
    try {
      return await _authRepository.signUpWithClerk(
        email: params.email,
        password: params.password,
        nombreCompleto: params.nombreCompleto,
        telefono: params.telefono,
      );
    } catch (e) {
      // Re-lanzar la excepción para que sea manejada por la capa de presentación
      rethrow;
    }
  }

  /// Ejecutar el caso de uso para cerrar sesión
  Future<bool> signOut() async {
    try {
      return await _authRepository.signOut();
    } catch (e) {
      // Re-lanzar la excepción para que sea manejada por la capa de presentación
      rethrow;
    }
  }

  /// Ejecutar el caso de uso para verificar si el usuario está autenticado
  Future<bool> isAuthenticated() async {
    try {
      return await _authRepository.isAuthenticated();
    } catch (e) {
      // Re-lanzar la excepción para que sea manejada por la capa de presentación
      rethrow;
    }
  }

  /// Ejecutar el caso de uso para obtener usuario actual
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      return await _authRepository.getCurrentUser();
    } catch (e) {
      // Re-lanzar la excepción para que sea manejada por la capa de presentación
      rethrow;
    }
  }

  /// Ejecutar el caso de uso para sincronizar usuario desde Clerk
  Future<Map<String, dynamic>?> syncUserFromClerk(
    SyncUserFromClerkParams params,
  ) async {
    try {
      return await _authRepository.syncUserFromClerk(
        clerkUserId: params.clerkUserId,
        nombreCompleto: params.nombreCompleto,
        email: params.email,
        telefono: params.telefono,
      );
    } catch (e) {
      // Re-lanzar la excepción para que sea manejada por la capa de presentación
      rethrow;
    }
  }

  /// Ejecutar el caso de uso para actualizar perfil
  Future<bool> updateProfile(UpdateProfileParams params) async {
    try {
      return await _authRepository.updateUserProfile(
        nombreCompleto: params.nombreCompleto,
        telefono: params.telefono,
        perfilPublico: params.perfilPublico,
        avatarUrl: params.avatarUrl,
      );
    } catch (e) {
      // Re-lanzar la excepción para que sea manejada por la capa de presentación
      rethrow;
    }
  }

  /// Ejecutar el caso de uso para obtener token de autenticación
  Future<String?> getAuthToken() async {
    try {
      return await _authRepository.getAuthToken();
    } catch (e) {
      // Re-lanzar la excepción para que sea manejada por la capa de presentación
      rethrow;
    }
  }
}

/// Parámetros para el caso de uso SignIn
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

/// Parámetros para el caso de uso SignUp
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

/// Parámetros para el caso de uso SyncUserFromClerk
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
  List<Object?> get props => [
    clerkUserId,
    nombreCompleto,
    email,
    telefono,
    avatarUrl,
  ];

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

/// Parámetros para el caso de uso UpdateProfile
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
    json['updated_at'] = DateTime.now().toIso8601String();
    return json;
  }

  bool get hasUpdates {
    return nombreCompleto != null ||
        telefono != null ||
        perfilPublico != null ||
        avatarUrl != null;
  }
}
