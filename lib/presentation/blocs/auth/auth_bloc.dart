// lib/presentation/blocs/auth/auth_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../domain/usecases/authenticate_user_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// BLoC para gestión de autenticación
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthenticateUserUseCase _authenticateUserUseCase;

  AuthBloc(this._authenticateUserUseCase) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    on<AuthSyncUserRequested>(_onAuthSyncUserRequested);
    on<AuthUpdateProfileRequested>(_onAuthUpdateProfileRequested);
    on<AuthGetCurrentUserRequested>(_onAuthGetCurrentUserRequested);
  }

  /// Manejar evento de verificación de autenticación
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final isAuthenticated = await _authenticateUserUseCase.isAuthenticated();

      if (isAuthenticated) {
        final user = await _authenticateUserUseCase.getCurrentUser();
        emit(AuthAuthenticated(user: user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: 'Error al verificar autenticación: $e'));
    }
  }

  /// Manejar evento de inicio de sesión
  Future<void> _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final user = await _authenticateUserUseCase.signIn(
        SignInParams(email: event.email, password: event.password),
      );

      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(const AuthError(message: 'Credenciales inválidas'));
      }
    } catch (e) {
      emit(AuthError(message: 'Error al iniciar sesión: $e'));
    }
  }

  /// Manejar evento de registro de usuario
  Future<void> _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final user = await _authenticateUserUseCase.signUp(
        SignUpParams(
          email: event.email,
          password: event.password,
          nombreCompleto: event.nombreCompleto,
          telefono: event.telefono,
        ),
      );

      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(const AuthError(message: 'Error al registrar usuario'));
      }
    } catch (e) {
      emit(AuthError(message: 'Error al registrar usuario: $e'));
    }
  }

  /// Manejar evento de cierre de sesión
  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final success = await _authenticateUserUseCase.signOut();

      if (success) {
        emit(const AuthUnauthenticated());
      } else {
        emit(const AuthError(message: 'Error al cerrar sesión'));
      }
    } catch (e) {
      emit(AuthError(message: 'Error al cerrar sesión: $e'));
    }
  }

  /// Manejar evento de sincronización de usuario desde Clerk
  Future<void> _onAuthSyncUserRequested(
    AuthSyncUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final user = await _authenticateUserUseCase.syncUserFromClerk(
        SyncUserFromClerkParams(
          clerkUserId: event.clerkUserId,
          nombreCompleto: event.nombreCompleto,
          email: event.email,
          telefono: event.telefono,
          avatarUrl: event.avatarUrl,
        ),
      );

      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(const AuthError(message: 'Error al sincronizar usuario'));
      }
    } catch (e) {
      emit(AuthError(message: 'Error al sincronizar usuario: $e'));
    }
  }

  /// Manejar evento de actualización de perfil
  Future<void> _onAuthUpdateProfileRequested(
    AuthUpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final success = await _authenticateUserUseCase.updateProfile(
        UpdateProfileParams(
          nombreCompleto: event.nombreCompleto,
          telefono: event.telefono,
          perfilPublico: event.perfilPublico,
          avatarUrl: event.avatarUrl,
        ),
      );

      if (success) {
        // Obtener usuario actualizado
        final user = await _authenticateUserUseCase.getCurrentUser();
        emit(AuthAuthenticated(user: user));
        emit(const AuthProfileUpdated());
      } else {
        emit(const AuthError(message: 'Error al actualizar perfil'));
      }
    } catch (e) {
      emit(AuthError(message: 'Error al actualizar perfil: $e'));
    }
  }

  /// Manejar evento de obtención de usuario actual
  Future<void> _onAuthGetCurrentUserRequested(
    AuthGetCurrentUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final user = await _authenticateUserUseCase.getCurrentUser();

      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: 'Error al obtener usuario actual: $e'));
    }
  }

  /// Verificar si el usuario está autenticado
  bool get isAuthenticated => state is AuthAuthenticated;

  /// Obtener usuario actual del estado
  Map<String, dynamic>? get currentUser {
    if (state is AuthAuthenticated) {
      return (state as AuthAuthenticated).user;
    }
    return null;
  }

  /// Obtener token de autenticación
  Future<String?> getAuthToken() async {
    return await _authenticateUserUseCase.getAuthToken();
  }

  /// Disposición del BLoC
  @override
  Future<void> close() {
    // Llamar al método de la clase base para liberar recursos
    return super.close();
  }
}
