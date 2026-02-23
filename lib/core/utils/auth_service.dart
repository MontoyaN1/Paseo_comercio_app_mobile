// lib/core/utils/auth_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    hide
        AuthException,
        AuthState; // Hide supabase's AuthException and AuthState to avoid conflict

import '../constants/app_constants.dart';
import '../errors/app_exceptions.dart';
import 'auth_state.dart';
import 'cache_service.dart';
import 'result.dart';

/// Servicio de autenticación con Clerk y fallback a Supabase Auth
class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Estados de autenticación
  AuthState _currentState = AuthState.unknown;
  final StreamController<AuthState> _stateController =
      StreamController<AuthState>.broadcast();

  // Usuario actual
  User? _currentUser;
  dynamic _currentClerkUser;

  // Configuración
  bool _isClerkConfigured = false;
  bool _isSupabaseConfigured = false;
  String _authMode = AppConstants.authModeClerk;

  /// Inicializar servicio de autenticación
  Future<void> initialize({
    required String clerkPublishableKey,
    String? supabaseUrl,
    String? supabaseAnonKey,
  }) async {
    try {
      // Configurar Clerk
      if (clerkPublishableKey.isNotEmpty) {
        _isClerkConfigured = true;
        if (kDebugMode) {
          print('AuthService: Clerk configurado');
        }
      }

      // Configurar Supabase Auth como fallback
      if (supabaseUrl != null &&
          supabaseUrl.isNotEmpty &&
          supabaseAnonKey != null &&
          supabaseAnonKey.isNotEmpty) {
        await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
        _isSupabaseConfigured = true;
        if (kDebugMode) {
          print('AuthService: Supabase Auth configurado como fallback');
        }
      }

      // Verificar estado inicial
      await _checkAuthState();

      if (kDebugMode) {
        print('AuthService: Inicializado en modo $_authMode');
      }
    } catch (error) {
      throw ConfigurationException(
        message: 'Error al inicializar AuthService',
        cause: error,
      );
    }
  }

  /// Obtener stream de cambios de estado de autenticación
  Stream<AuthState> get onAuthStateChanged => _stateController.stream;

  /// Obtener estado actual de autenticación
  AuthState get currentState => _currentState;

  /// Verificar si el usuario está autenticado
  bool get isAuthenticated => _currentState == AuthState.authenticated;

  /// Verificar si el usuario es invitado
  bool get isGuest => _currentState == AuthState.guest;

  /// Obtener usuario actual
  User? get currentUser => _currentUser;

  /// Obtener usuario Clerk actual
  dynamic get currentClerkUser => _currentClerkUser;

  /// Obtener ID del usuario actual
  String? get currentUserId {
    return _currentUser?.id;
  }

  /// Obtener email del usuario actual
  String? get currentUserEmail {
    return _currentUser?.email;
  }

  /// Obtener nombre del usuario actual
  String? get currentUserName {
    return _currentUser?.userMetadata?['name'] as String?;
  }

  /// Obtener URL de imagen del usuario actual
  String? get currentUserImageUrl {
    return _currentUser?.userMetadata?['avatar_url'] as String?;
  }

  /// Iniciar sesión con Clerk
  Future<Result<void, Exception>> signInWithClerk() async {
    if (!_isClerkConfigured) {
      return Result.error(
        ConfigurationException(message: 'Clerk no está configurado'),
      );
    }

    try {
      // En una implementación real, esto abriría el flujo de autenticación de Clerk
      // Por ahora, simulamos un inicio de sesión exitoso
      await _handleClerkSignIn();
      return Result.success(null);
    } catch (error) {
      return Result.error(
        AuthException(
          message: 'Error al iniciar sesión con Clerk',
          cause: error,
        ),
      );
    }
  }

  /// Iniciar sesión con email y contraseña
  Future<Result<void, Exception>> signInWithEmail(
    String email,
    String password,
  ) async {
    if (!_isSupabaseConfigured) {
      return Result.error(
        ConfigurationException(message: 'Supabase Auth no está configurado'),
      );
    }

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _currentUser = response.user;
        await _updateAuthState(AuthState.authenticated);
        return Result.success(null);
      } else {
        return Result.error(AuthException(message: 'Error al iniciar sesión'));
      }
    } catch (error) {
      return Result.error(
        AuthException(
          message: 'Error al iniciar sesión con email',
          cause: error,
        ),
      );
    }
  }

  /// Registrar nuevo usuario con email y contraseña
  Future<Result<void, Exception>> signUpWithEmail(
    String email,
    String password, {
    String? name,
  }) async {
    if (!_isSupabaseConfigured) {
      return Result.error(
        ConfigurationException(message: 'Supabase Auth no está configurado'),
      );
    }

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: name != null ? {'name': name} : null,
      );

      if (response.user != null) {
        _currentUser = response.user;
        await _updateAuthState(AuthState.authenticated);
        return Result.success(null);
      } else {
        return Result.error(
          AuthException(message: 'Error al registrar usuario'),
        );
      }
    } catch (error) {
      return Result.error(
        AuthException(message: 'Error al registrar usuario', cause: error),
      );
    }
  }

  /// Iniciar sesión como invitado
  Future<Result<void, Exception>> signInAsGuest() async {
    try {
      await _updateAuthState(AuthState.guest);
      return Result.success(null);
    } catch (error) {
      return Result.error(
        AuthException(
          message: 'Error al iniciar sesión como invitado',
          cause: error,
        ),
      );
    }
  }

  /// Cerrar sesión
  Future<Result<void, Exception>> signOut() async {
    try {
      if (_authMode == AppConstants.authModeClerk && _isClerkConfigured) {
        await _handleClerkSignOut();
      } else if (_isSupabaseConfigured) {
        await Supabase.instance.client.auth.signOut();
      }

      _currentUser = null;
      _currentClerkUser = null;
      await _updateAuthState(AuthState.unauthenticated);
      return Result.success(null);
    } catch (error) {
      return Result.error(
        AuthException(message: 'Error al cerrar sesión', cause: error),
      );
    }
  }

  /// Verificar sesión actual
  Future<Result<void, Exception>> verifySession() async {
    try {
      await _checkAuthState();
      return Result.success(null);
    } catch (error) {
      return Result.error(
        AuthException(message: 'Error al verificar sesión', cause: error),
      );
    }
  }

  /// Actualizar perfil del usuario
  Future<Result<void, Exception>> updateProfile({
    String? name,
    String? imageUrl,
  }) async {
    try {
      if (_authMode == AppConstants.authModeClerk &&
          _currentClerkUser != null) {
        await _handleClerkProfileUpdate(name: name, imageUrl: imageUrl);
      } else if (_currentUser != null && _isSupabaseConfigured) {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(
            data: {
              if (name != null) 'name': name,
              if (imageUrl != null) 'avatar_url': imageUrl,
            },
          ),
        );
      }

      return Result.success(null);
    } catch (error) {
      return Result.error(
        AuthException(message: 'Error al actualizar perfil', cause: error),
      );
    }
  }

  /// Cambiar contraseña
  Future<Result<void, Exception>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // En Supabase, esto requeriría reautenticación
      // Por ahora, lanzamos excepción de no implementado
      throw NotImplementedException(
        message: 'Cambio de contraseña no implementado',
      );
    } catch (error) {
      return Result.error(
        AuthException(message: 'Error al cambiar contraseña', cause: error),
      );
    }
  }

  /// Restablecer contraseña
  Future<Result<void, Exception>> resetPassword(String email) async {
    if (!_isSupabaseConfigured) {
      return Result.error(
        ConfigurationException(message: 'Supabase Auth no está configurado'),
      );
    }

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      return Result.success(null);
    } catch (error) {
      return Result.error(
        AuthException(message: 'Error al restablecer contraseña', cause: error),
      );
    }
  }

  /// Obtener token de acceso
  Future<Result<String?, Exception>> getAccessToken() async {
    try {
      if (_authMode == AppConstants.authModeClerk && _isClerkConfigured) {
        // Clerk token access
        return Result.success(null); // Placeholder
      } else if (_isSupabaseConfigured) {
        final session = Supabase.instance.client.auth.currentSession;
        return Result.success(session?.accessToken);
      }
      return Result.success(null);
    } catch (error) {
      return Result.error(
        AuthException(
          message: 'Error al obtener token de acceso',
          cause: error,
        ),
      );
    }
  }

  /// Cambiar modo de autenticación
  Future<void> switchAuthMode(String mode) async {
    if (mode == _authMode) return;

    if (mode == AppConstants.authModeClerk && !_isClerkConfigured) {
      throw ConfigurationException(message: 'Clerk no está configurado');
    }

    if (mode == AppConstants.authModeSupabase && !_isSupabaseConfigured) {
      throw ConfigurationException(
        message: 'Supabase Auth no está configurado',
      );
    }

    _authMode = mode;
    await _checkAuthState();
  }

  /// Obtener modo de autenticación actual
  String get authMode => _authMode;

  /// Verificar si Clerk está disponible
  bool get isClerkAvailable => _isClerkConfigured;

  /// Verificar si Supabase Auth está disponible
  bool get isSupabaseAuthAvailable => _isSupabaseConfigured;

  // Métodos privados

  /// Verificar estado de autenticación
  Future<void> _checkAuthState() async {
    try {
      if (_authMode == AppConstants.authModeClerk) {
        await _checkClerkAuthState();
      } else if (_authMode == AppConstants.authModeSupabase) {
        await _checkSupabaseAuthState();
      } else {
        await _updateAuthState(AuthState.unknown);
      }
    } catch (error) {
      await _updateAuthState(AuthState.error);
    }
  }

  /// Verificar estado de autenticación de Clerk
  Future<void> _checkClerkAuthState() async {
    // Implementación simulada para Clerk
    // En una implementación real, verificaría el estado de sesión de Clerk
    await _updateAuthState(AuthState.unauthenticated);
  }

  /// Verificar estado de autenticación de Supabase
  Future<void> _checkSupabaseAuthState() async {
    if (!_isSupabaseConfigured) {
      await _updateAuthState(AuthState.unauthenticated);
      return;
    }

    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      _currentUser = session.user;
      await _updateAuthState(AuthState.authenticated);
    } else {
      _currentUser = null;
      await _updateAuthState(AuthState.unauthenticated);
    }
  }

  /// Actualizar estado de autenticación
  Future<void> _updateAuthState(AuthState newState) async {
    if (_currentState == newState) return;

    _currentState = newState;
    _stateController.add(newState);
    await _saveAuthState();
  }

  /// Guardar estado de autenticación
  Future<void> _saveAuthState() async {
    // Guardar en caché o almacenamiento local
    try {
      final cache = CacheService();
      final result = await cache.save(
        key: 'auth_state',
        data: _currentState.name,
        ttl: Duration(seconds: 86400), // 24 horas
      );
      result.fold(
        (_) {}, // éxito
        (error) => print('Error saving auth state: $error'),
      );
    } catch (_) {
      // Ignorar errores de caché
    }
  }

  /// Manejar inicio de sesión con Clerk (simulado)
  Future<void> _handleClerkSignIn() async {
    // Simulación de inicio de sesión con Clerk
    _currentClerkUser = null; // Placeholder
    await _updateAuthState(AuthState.authenticated);
  }

  /// Manejar cierre de sesión de Clerk (simulado)
  Future<void> _handleClerkSignOut() async {
    // Simulación de cierre de sesión con Clerk
    _currentClerkUser = null;
  }

  /// Manejar actualización de perfil de Clerk (simulado)
  Future<void> _handleClerkProfileUpdate({
    String? name,
    String? imageUrl,
  }) async {
    // Simulación de actualización de perfil con Clerk
    // En una implementación real, llamaría a la API de Clerk
  }
}
