// lib/core/utils/auth_service_simple.dart
// Versión simplificada temporal para resolver problemas de compilación

import 'dart:async';
import '../constants/app_constants.dart';
import '../errors/app_exceptions.dart';
import 'result.dart';

/// Servicio de autenticación simplificado
class AuthServiceSimple {
  // Singleton pattern
  static final AuthServiceSimple _instance = AuthServiceSimple._internal();
  factory AuthServiceSimple() => _instance;
  AuthServiceSimple._internal();

  // Estados de autenticación
  String _authState = 'unknown';
  String _authMode = 'guest';
  dynamic _currentUser;
  bool _isClerkConfigured = false;
  bool _isSupabaseConfigured = false;

  // Stream de cambios de estado
  final StreamController<String> _authStateController =
      StreamController<String>.broadcast();
  final StreamController<dynamic> _userController =
      StreamController<dynamic>.broadcast();

  /// Inicializar servicio
  Future<void> initialize({
    required String clerkPublishableKey,
    String? supabaseUrl,
    String? supabaseAnonKey,
  }) async {
    try {
      // Configurar Clerk si hay clave
      if (clerkPublishableKey.isNotEmpty) {
        _isClerkConfigured = true;
      }

      // Configurar Supabase si hay credenciales
      if (supabaseUrl != null &&
          supabaseUrl.isNotEmpty &&
          supabaseAnonKey != null &&
          supabaseAnonKey.isNotEmpty) {
        _isSupabaseConfigured = true;
      }

      // Establecer estado inicial
      _authState = 'unauthenticated';
      _authMode = AppConstants.authModeGuest;
      _currentUser = null;

      _authStateController.add(_authState);
      _userController.add(_currentUser);
    } catch (error) {
      throw ConfigurationException(
        message: 'Error al inicializar AuthServiceSimple',
        cause: error,
      );
    }
  }

  /// Iniciar sesión con Clerk
  Future<Result<void, Exception>> signInWithClerk() async {
    if (!_isClerkConfigured) {
      return Result.error(
        ConfigurationException(message: 'Clerk no está configurado'),
      );
    }

    try {
      // Simular inicio de sesión exitoso
      _authState = 'authenticated';
      _authMode = AppConstants.authModeClerk;

      // Crear usuario simulado
      _currentUser = {
        'id': 'user_123',
        'fullName': 'Usuario Demo',
        'email': 'usuario@demo.com',
        'phone': '+1234567890',
        'avatarUrl': null,
      };

      _authStateController.add(_authState);
      _userController.add(_currentUser);

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

  /// Iniciar sesión con Supabase
  Future<Result<void, Exception>> signInWithSupabase({
    required String email,
    required String password,
  }) async {
    if (!_isSupabaseConfigured) {
      return Result.error(
        ConfigurationException(message: 'Supabase no está configurado'),
      );
    }

    try {
      // Simular inicio de sesión exitoso
      _authState = 'authenticated';
      _authMode = AppConstants.authModeSupabase;

      // Crear usuario simulado
      _currentUser = {
        'id': 'supabase_user_123',
        'fullName': 'Usuario Supabase',
        'email': email,
        'phone': null,
        'avatarUrl': null,
      };

      _authStateController.add(_authState);
      _userController.add(_currentUser);

      return Result.success(null);
    } catch (error) {
      return Result.error(
        AuthException(
          message: 'Error al iniciar sesión con Supabase',
          cause: error,
        ),
      );
    }
  }

  /// Iniciar sesión como invitado
  Future<Result<void, Exception>> signInAsGuest() async {
    try {
      _authState = 'authenticated';
      _authMode = AppConstants.authModeGuest;
      _currentUser = {
        'id': 'guest_123',
        'fullName': 'Invitado',
        'email': null,
        'phone': null,
        'avatarUrl': null,
      };

      _authStateController.add(_authState);
      _userController.add(_currentUser);

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
      _authState = 'unauthenticated';
      _authMode = AppConstants.authModeGuest;
      _currentUser = null;

      _authStateController.add(_authState);
      _userController.add(_currentUser);

      return Result.success(null);
    } catch (error) {
      return Result.error(
        AuthException(message: 'Error al cerrar sesión', cause: error),
      );
    }
  }

  /// Registrar nuevo usuario
  Future<Result<void, Exception>> signUp({
    required String email,
    required String password,
    String? fullName,
    String? phone,
  }) async {
    if (!_isSupabaseConfigured) {
      return Result.error(
        ConfigurationException(message: 'Supabase no está configurado'),
      );
    }

    try {
      // Simular registro exitoso
      // En una implementación real, esto llamaría a Supabase
      await Future.delayed(const Duration(seconds: 1));

      return Result.success(null);
    } catch (error) {
      return Result.error(
        AuthException(message: 'Error al registrar usuario', cause: error),
      );
    }
  }

  /// Verificar sesión actual
  Future<Result<void, Exception>> checkSession() async {
    try {
      // Simular verificación de sesión
      // En una implementación real, verificaría con Clerk o Supabase

      return Result.success(null);
    } catch (error) {
      return Result.error(
        AuthException(message: 'Error al verificar sesión', cause: error),
      );
    }
  }

  /// Cambiar modo de autenticación
  Future<void> switchAuthMode(String newMode) async {
    if (![
      AppConstants.authModeClerk,
      AppConstants.authModeSupabase,
      AppConstants.authModeGuest,
    ].contains(newMode)) {
      throw ArgumentError('Modo de autenticación no válido: $newMode');
    }

    // Verificar que el modo esté disponible
    if (newMode == AppConstants.authModeClerk && !_isClerkConfigured) {
      throw ConfigurationException(message: 'Clerk no está configurado');
    }

    if (newMode == AppConstants.authModeSupabase && !_isSupabaseConfigured) {
      throw ConfigurationException(message: 'Supabase no está configurado');
    }

    _authMode = newMode;
  }

  /// Obtener estado actual de autenticación
  String get authState => _authState;

  /// Obtener modo actual de autenticación
  String get authMode => _authMode;

  /// Obtener usuario actual
  dynamic get currentUser => _currentUser;

  /// Verificar si el usuario está autenticado
  bool get isAuthenticated => _authState == 'authenticated';

  /// Verificar si es usuario invitado
  bool get isGuest => _authMode == AppConstants.authModeGuest;

  /// Verificar si Clerk está disponible
  bool get isClerkAvailable => _isClerkConfigured;

  /// Verificar si Supabase Auth está disponible
  bool get isSupabaseAvailable => _isSupabaseConfigured;

  /// Stream de cambios de estado de autenticación
  Stream<String> get authStateStream => _authStateController.stream;

  /// Stream de cambios de usuario
  Stream<dynamic> get userStream => _userController.stream;

  /// Disposer
  void dispose() {
    _authStateController.close();
    _userController.close();
  }

  /// Método toString para debugging
  @override
  String toString() {
    return '''
AuthServiceSimple:
  Estado: $authState
  Modo: $authMode
  Autenticado: $isAuthenticated
  Usuario: ${currentUser != null ? 'Sí' : 'No'}
  Clerk disponible: $isClerkAvailable
  Supabase disponible: $isSupabaseAvailable
''';
  }
}

/// Excepción específica para errores de autenticación
class AuthException implements Exception {
  final String message;
  final dynamic cause;

  const AuthException({required this.message, this.cause});

  @override
  String toString() {
    return 'AuthException: $message${cause != null ? ' (Causa: $cause)' : ''}';
  }
}
