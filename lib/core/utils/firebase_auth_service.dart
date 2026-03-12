// lib/core/utils/firebase_auth_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kDebugMode, TargetPlatform;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../errors/app_exceptions.dart';
import 'auth_state.dart';
import 'cache_service.dart';
import 'result.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../data/datasources/remote/supabase_client.dart';

/// Servicio de autenticación con Firebase (reemplazo de Clerk)
class FirebaseAuthService {
  // Instancias de Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late GoogleSignIn _googleSignIn;
  final SupabaseClientService _supabaseClient;

  // Estados de autenticación
  AuthState _currentState = AuthState.unknown;
  final StreamController<AuthState> _stateController =
      StreamController<AuthState>.broadcast();

  // Usuario actual
  User? _currentUser;
  Map<String, dynamic>? _userProfile;

  /// Constructor que requiere SupabaseClientService
  FirebaseAuthService({required SupabaseClientService supabaseClient})
    : _supabaseClient = supabaseClient;

  /// Inicializar servicio de autenticación
  Future<void> initialize() async {
    try {
      // Configurar GoogleSignIn con web_client_id si está disponible
      await _configureGoogleSignIn();
      // Firebase ya está inicializado desde main.dart
      // Solo verificamos que esté disponible
      try {
        Firebase.app(); // Esto lanzará excepción si Firebase no está inicializado
      } catch (e) {
        // Firebase no está inicializado
        // No lanzamos excepción, solo registramos el error
        // Firebase se inicializará automáticamente cuando se use
      }

      // Configurar GoogleSignIn con opciones de Android si está disponible
      _configureGoogleSignIn();

      // Escuchar cambios en el estado de autenticación
      _auth.authStateChanges().listen((User? user) async {
        // authStateChanges recibido

        if (user != null) {
          // Usuario autenticado
          _currentUser = user;
          await _loadUserProfile(user.uid);
          await _updateAuthState(AuthState.authenticated);
        } else {
          // Usuario no autenticado, limpiando estado
          _currentUser = null;
          _userProfile = null;
          await _updateAuthState(AuthState.unauthenticated);
        }
      });

      // Cargar usuario actual si existe
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        _currentUser = currentUser;
        await _loadUserProfile(currentUser.uid);
        await _updateAuthState(AuthState.authenticated);
      }

      // Verificar estado inicial
      await _checkAuthState();

      // FirebaseAuthService inicializado correctamente
    } catch (error) {
      // Error al inicializar FirebaseAuthService
      // No lanzamos excepción para no bloquear la app
      // La autenticación fallará silenciosamente
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

  /// Obtener usuario actual de Firebase
  User? get currentUser => _currentUser;

  /// Obtener perfil del usuario actual
  Map<String, dynamic>? get userProfile => _userProfile;

  /// Obtener ID del usuario actual
  String? get currentUserId => _currentUser?.uid;

  /// Obtener email del usuario actual
  String? get currentUserEmail => _currentUser?.email;

  /// Obtener nombre del usuario actual
  String? get currentUserName {
    final displayName = _currentUser?.displayName;
    final nombreCompleto = _userProfile?['nombre_completo'];
    // Obtener nombre del usuario actual
    return displayName ?? nombreCompleto;
  }

  /// Obtener URL de imagen del usuario actual
  String? get currentUserImageUrl =>
      _currentUser?.photoURL ?? _userProfile?['avatar_url'];

  /// Obtener teléfono del usuario actual
  String? get currentUserPhoneNumber {
    final telefono = _userProfile?['telefono'];
    final phoneNumber = _currentUser?.phoneNumber;
    // Obtener número de teléfono del usuario actual
    return telefono ?? phoneNumber;
  }

  /// Iniciar sesión con email y contraseña
  Future<Result<void, Exception>> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await _loadUserProfile(userCredential.user!.uid);

        // Sincronizar con Supabase
        await _syncUserWithSupabase(userCredential.user!);

        return Result.success(null);
      } else {
        return Result.error(AuthException(message: 'Error al iniciar sesión'));
      }
    } on FirebaseAuthException catch (e) {
      return Result.error(_handleFirebaseAuthError(e));
    } catch (error) {
      return Result.error(
        AuthException(
          message: 'Error al iniciar sesión con email',
          cause: error,
        ),
      );
    }
  }

  /// Configurar GoogleSignIn con opciones de plataforma
  Future<void> _configureGoogleSignIn() async {
    try {
      final env = dotenv.env;
      final androidClientId = env['FIREBASE_ANDROID_CLIENT_ID'] ?? '';

      // Configurando GoogleSignIn

      // Configurar GoogleSignIn según la plataforma
      if (defaultTargetPlatform == TargetPlatform.android) {
        // Para Android, usar el web_client_id desde variables de entorno
        // o dejar que Google Sign-In use la configuración automática
        if (androidClientId.isNotEmpty) {
          _googleSignIn = GoogleSignIn(
            scopes: ['email', 'profile'],
            clientId: androidClientId,
          );
          // GoogleSignIn configurado con clientId específico
        } else {
          // Si no hay clientId, usar configuración automática
          _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
          // GoogleSignIn configurado con configuración automática
        }
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        // Para iOS, usar configuración automática
        _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
        // GoogleSignIn configurado para iOS
      } else {
        // Para otras plataformas
        _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
        // GoogleSignIn configurado para $defaultTargetPlatform
      }

      // GoogleSignIn configurado correctamente
    } catch (error) {
      // Error al configurar GoogleSignIn
      // Fallback a configuración básica
      _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
    }
  }

  /// Registrar nuevo usuario con email y contraseña
  Future<Result<void, Exception>> signUpWithEmail(
    String email,
    String password, {
    String? nombre,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Sincronizar con Supabase
        await _syncUserWithSupabase(userCredential.user!);

        // Actualizar display name si se proporcionó
        if (nombre != null) {
          await userCredential.user!.updateDisplayName(nombre);
        }

        await _loadUserProfile(userCredential.user!.uid);

        // Sincronizar con Supabase
        await _syncUserWithSupabase(userCredential.user!);

        return Result.success(null);
      } else {
        return Result.error(
          AuthException(message: 'Error al registrar usuario'),
        );
      }
    } on FirebaseAuthException catch (e) {
      return Result.error(_handleFirebaseAuthError(e));
    } catch (error) {
      return Result.error(
        AuthException(message: 'Error al registrar usuario', cause: error),
      );
    }
  }

  /// Iniciar sesión con Google
  Future<Result<void, Exception>> signInWithGoogle() async {
    try {
      // Iniciando autenticación con Google

      // Iniciar flujo de autenticación de Google
      // Llamando a GoogleSignIn.signIn()

      GoogleSignInAccount? googleUser;
      try {
        googleUser = await _googleSignIn.signIn();
      } catch (signInError) {
        // Error en GoogleSignIn.signIn()

        // Manejar errores específicos de API 10 (DEVELOPER_ERROR)
        if (signInError.toString().contains('ApiException: 10') ||
            signInError.toString().contains('DEVELOPER_ERROR')) {
          return Result.error(
            AuthException(
              message:
                  'Error de configuración de Google Sign-In. Verifica: '
                  '1. SHA-1 fingerprint en Firebase Console\n'
                  '2. Package name: com.paseodelcomercio.app\n'
                  '3. Google Sign-In habilitado en Firebase Auth',
              cause: signInError,
            ),
          );
        }

        return Result.error(
          AuthException(
            message: 'Error al iniciar sesión con Google',
            cause: signInError,
          ),
        );
      }

      if (googleUser == null) {
        // Usuario canceló el flujo de Google Sign-In
        // El usuario canceló la operación, no es un error
        return Result.success(null);
      }

      // Verificar que el usuario de Google tenga email (requerido)
      final email = googleUser.email;
      if (email.isEmpty) {
        // Error - usuario de Google sin email
        return Result.error(
          AuthException(
            message: 'El usuario de Google no tiene un email válido',
            cause: Exception('Email no disponible'),
          ),
        );
      }

      // Usuario de Google obtenido

      // Obtener credenciales de autenticación
      // Obteniendo autenticación de Google
      final GoogleSignInAuthentication googleAuth;
      try {
        googleAuth = await googleUser.authentication;
      } catch (authError) {
        // Error al obtener autenticación de Google
        return Result.error(
          AuthException(
            message: 'Error al obtener credenciales de Google',
            cause: authError,
          ),
        );
      }

      // Creando credencial de Firebase

      // Verificar que al menos un token esté disponible
      if (googleAuth.accessToken == null && googleAuth.idToken == null) {
        // Error - ambos tokens son nulos
        return Result.error(
          AuthException(
            message: 'No se pudieron obtener tokens de autenticación de Google',
          ),
        );
      }

      // Crear credencial de Firebase - al menos uno de los tokens debe estar presente
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      if (kDebugMode) {
        print('FirebaseAuthService: Credencial creada');
      }

      // Iniciar sesión en Firebase
      if (kDebugMode) {
        print(
          'FirebaseAuthService: Iniciando sesión en Firebase con credencial...',
        );
      }
      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        if (kDebugMode) {
          print(
            'FirebaseAuthService: Usuario autenticado exitosamente: ${userCredential.user!.uid}',
          );
          print('FirebaseAuthService: Email: ${userCredential.user!.email}');
          print(
            'FirebaseAuthService: Nombre: ${userCredential.user!.displayName}',
          );
          print(
            'FirebaseAuthService: Foto URL: ${userCredential.user!.photoURL}',
          );
        }

        // Sincronizar usuario con Supabase
        await _syncUserWithSupabase(userCredential.user!);

        await _loadUserProfile(userCredential.user!.uid);

        // Sincronizar con Supabase
        await _syncUserWithSupabase(userCredential.user!);

        // Actualizar estado de autenticación explícitamente
        _currentUser = userCredential.user;
        await _updateAuthState(AuthState.authenticated);

        if (kDebugMode) {
          print('FirebaseAuthService: Perfil creado/actualizado exitosamente');
        }

        return Result.success(null);
      } else {
        if (kDebugMode) {
          print('FirebaseAuthService: Error: userCredential.user es nulo');
        }
        return Result.error(
          AuthException(
            message: 'Error al iniciar sesión con Google - usuario no creado',
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('FirebaseAuthService: FirebaseAuthException capturada:');
        print('FirebaseAuthService: Código: ${e.code}');
        print('FirebaseAuthService: Mensaje: ${e.message}');
        print('FirebaseAuthService: Stack: ${e.stackTrace}');
      }
      return Result.error(_handleFirebaseAuthError(e));
    } catch (error, stackTrace) {
      if (kDebugMode) {
        print('FirebaseAuthService: Error general en signInWithGoogle:');
        print('FirebaseAuthService: Error: $error');
        print('FirebaseAuthService: StackTrace: $stackTrace');
      }
      return Result.error(
        AuthException(
          message: 'Error al iniciar sesión con Google',
          cause: error,
        ),
      );
    }
  }

  /// Iniciar sesión como invitado
  Future<Result<void, Exception>> signInAsGuest() async {
    try {
      // Crear usuario anónimo en Firebase
      final userCredential = await _auth.signInAnonymously();

      if (userCredential.user != null) {
        // Sincronizar con Supabase
        await _syncUserWithSupabase(userCredential.user!);
        await _loadUserProfile(userCredential.user!.uid);
        await _updateAuthState(AuthState.authenticated);
        return Result.success(null);
      } else {
        return Result.error(
          AuthException(message: 'Error al crear usuario anónimo'),
        );
      }
    } on FirebaseAuthException catch (e) {
      return Result.error(_handleFirebaseAuthError(e));
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
      // Cerrar sesión de Google si está activa
      if (_googleSignIn.currentUser != null) {
        await _googleSignIn.signOut();
      }

      // Cerrar sesión de Firebase
      await _auth.signOut();

      _currentUser = null;
      _userProfile = null;
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
    String? nombre,
    String? telefono,
    String? fotoUrl,
  }) async {
    try {
      final userId = _currentUser?.uid;
      if (userId == null) {
        return Result.error(
          AuthException(message: 'No hay usuario autenticado'),
        );
      }

      // Actualizar en Firebase Auth
      if (nombre != null && _currentUser != null) {
        await _currentUser!.updateDisplayName(nombre);
      }

      if (fotoUrl != null && _currentUser != null) {
        await _currentUser!.updatePhotoURL(fotoUrl);
      }

      // Actualizar en Supabase usando syncUsuario
      try {
        final email = _currentUser!.email;
        if (email == null || email.isEmpty) {
          if (kDebugMode) {
            print(
              'FirebaseAuthService: No se puede actualizar en Supabase sin email',
            );
          }
        } else {
          final nombreCompleto =
              nombre ?? _currentUser!.displayName ?? email.split('@')[0];
          await _supabaseClient.syncUsuario(
            firebaseUserId: userId,
            email: email,
            nombreCompleto: nombreCompleto,
            telefono: telefono,
            avatarUrl: fotoUrl,
          );

          if (kDebugMode) {
            print(
              'FirebaseAuthService: Perfil actualizado en Supabase correctamente',
            );
          }
        }
      } catch (supabaseError) {
        if (kDebugMode) {
          print(
            'FirebaseAuthService: Advertencia - No se pudo actualizar en Supabase: $supabaseError',
          );
          print(
            'FirebaseAuthService: El perfil se actualizó en Firebase Auth pero no en Supabase',
          );
        }
      }

      // Recargar perfil localmente
      // Recargar usuario de Firebase Auth para obtener datos actualizados
      if (_currentUser != null) {
        await _currentUser!.reload();
        _currentUser = _auth.currentUser; // Actualizar referencia
      }
      await _loadUserProfile(userId);

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
      final user = _currentUser;
      if (user == null) {
        return Result.error(
          AuthException(message: 'No hay usuario autenticado'),
        );
      }

      // Reautenticar si es necesario (para usuarios email/password)
      if (user.email != null) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);
      }

      // Cambiar contraseña
      await user.updatePassword(newPassword);
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      return Result.error(_handleFirebaseAuthError(e));
    } catch (error) {
      return Result.error(
        AuthException(message: 'Error al cambiar contraseña', cause: error),
      );
    }
  }

  /// Restablecer contraseña
  Future<Result<void, Exception>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      return Result.error(_handleFirebaseAuthError(e));
    } catch (error) {
      return Result.error(
        AuthException(message: 'Error al restablecer contraseña', cause: error),
      );
    }
  }

  /// Obtener token de acceso
  Future<Result<String?, Exception>> getAccessToken() async {
    try {
      final token = await _currentUser?.getIdToken();
      return Result.success(token);
    } catch (error) {
      return Result.error(
        AuthException(
          message: 'Error al obtener token de acceso',
          cause: error,
        ),
      );
    }
  }

  /// Eliminar cuenta de usuario
  Future<Result<void, Exception>> deleteAccount() async {
    try {
      final user = _currentUser;
      if (user == null) {
        return Result.error(
          AuthException(message: 'No hay usuario autenticado'),
        );
      }

      // Eliminar perfil de Supabase
      await _supabaseClient.usuarios.delete().eq('firebase_user_id', user.uid);

      // Eliminar cuenta de Firebase Auth
      await user.delete();

      _currentUser = null;
      _userProfile = null;
      await _updateAuthState(AuthState.unauthenticated);
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      return Result.error(_handleFirebaseAuthError(e));
    } catch (error) {
      return Result.error(
        AuthException(message: 'Error al eliminar cuenta', cause: error),
      );
    }
  }

  // Métodos privados

  /// Verificar estado de autenticación
  Future<void> _checkAuthState() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        _currentUser = user;
        await _loadUserProfile(user.uid);
        await _updateAuthState(AuthState.authenticated);
      } else {
        await _updateAuthState(AuthState.unauthenticated);
      }
    } catch (error) {
      await _updateAuthState(AuthState.error);
    }
  }

  /// Cargar perfil del usuario desde Supabase
  Future<void> _loadUserProfile(String userId) async {
    try {
      final userProfile = await _supabaseClient.getUsuarioByFirebaseId(userId);
      if (userProfile != null) {
        _userProfile = userProfile;
      } else {
        // Si no existe en Supabase, sincronizar usuario
        if (_currentUser != null) {
          await _syncUserWithSupabase(_currentUser!);
          // Intentar cargar nuevamente después de sincronizar
          final refreshedProfile = await _supabaseClient.getUsuarioByFirebaseId(
            userId,
          );
          _userProfile = refreshedProfile;
        } else {
          _userProfile = null;
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error al cargar perfil de usuario desde Supabase: $error');
      }
      _userProfile = null;
    }
  }

  /// Sincronizar usuario con Supabase
  Future<void> _syncUserWithSupabase(User firebaseUser) async {
    try {
      // Obtener información del usuario de Firebase
      final firebaseUserId = firebaseUser.uid;
      final email = firebaseUser.email;
      final nombreCompleto =
          firebaseUser.displayName ??
          (email != null ? email.split('@')[0] : 'Usuario');
      final telefono = firebaseUser.phoneNumber;

      if (email == null || email.isEmpty) {
        if (kDebugMode) {
          print(
            'Usuario de Firebase sin email, no se puede sincronizar con Supabase',
          );
        }
        return;
      }

      // Llamar al método de sincronización unificado en SupabaseClientService
      final supabaseUser = await _supabaseClient.syncUsuario(
        firebaseUserId: firebaseUserId,
        email: email,
        nombreCompleto: nombreCompleto,
        telefono: telefono,
        avatarUrl: firebaseUser.photoURL,
      );

      if (supabaseUser != null && kDebugMode) {
        print('Usuario sincronizado con Supabase: ${supabaseUser['id']}');
      } else if (kDebugMode) {
        print('Error al sincronizar usuario con Supabase');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error en _syncUserWithSupabase: $e');
      }
      // No lanzar excepción para no romper el flujo de autenticación
    }
  }

  /// Actualizar estado de autenticación
  Future<void> _updateAuthState(AuthState newState) async {
    if (_currentState == newState) return;

    if (kDebugMode) {
      print(
        'FirebaseAuthService: Cambiando estado de $_currentState a $newState',
      );
    }

    _currentState = newState;
    _stateController.add(newState);
    await _saveAuthState();

    if (kDebugMode) {
      print('FirebaseAuthService: Estado actualizado a $newState');
      print(
        'FirebaseAuthService: Usuario actual: ${_currentUser?.email ?? "null"}',
      );
      print('FirebaseAuthService: ID usuario: ${_currentUser?.uid ?? "null"}');
    }
  }

  /// Guardar estado de autenticación
  Future<void> _saveAuthState() async {
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

  /// Manejar errores de Firebase Auth
  Exception _handleFirebaseAuthError(FirebaseAuthException e) {
    String message;

    switch (e.code) {
      case 'invalid-email':
        message = 'El formato del email no es válido';
        break;
      case 'user-disabled':
        message = 'Esta cuenta ha sido deshabilitada';
        break;
      case 'user-not-found':
        message = 'No existe una cuenta con este email';
        break;
      case 'wrong-password':
        message = 'La contraseña es incorrecta';
        break;
      case 'email-already-in-use':
        message = 'Ya existe una cuenta con este email';
        break;
      case 'weak-password':
        message = 'La contraseña es demasiado débil';
        break;
      case 'operation-not-allowed':
        message = 'Esta operación no está permitida';
        break;
      case 'too-many-requests':
        message = 'Demasiados intentos. Intenta más tarde';
        break;
      case 'network-request-failed':
        message = 'Error de conexión. Verifica tu internet';
        break;
      case 'requires-recent-login':
        message = 'Debes iniciar sesión nuevamente';
        break;
      case 'provider-already-linked':
        message = 'Esta cuenta ya está vinculada';
        break;
      case 'credential-already-in-use':
        message = 'Estas credenciales ya están en uso';
        break;
      case 'invalid-credential':
        message = 'Credenciales inválidas';
        break;
      case 'account-exists-with-different-credential':
        message = 'Ya existe una cuenta con credenciales diferentes';
        break;
      default:
        message = 'Error de autenticación: ${e.message}';
        break;
    }

    return AuthException(message: message, cause: e);
  }

  /// Verificar si el usuario tiene email verificado
  bool get isEmailVerified => _currentUser?.emailVerified ?? false;

  /// Enviar email de verificación
  Future<Result<void, Exception>> sendEmailVerification() async {
    try {
      final user = _currentUser;
      if (user == null) {
        return Result.error(
          AuthException(message: 'No hay usuario autenticado'),
        );
      }

      await user.sendEmailVerification();
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      return Result.error(_handleFirebaseAuthError(e));
    } catch (error) {
      return Result.error(
        AuthException(
          message: 'Error al enviar email de verificación',
          cause: error,
        ),
      );
    }
  }

  /// Actualizar email del usuario
  Future<Result<void, Exception>> updateEmail(String newEmail) async {
    try {
      final user = _currentUser;
      if (user == null) {
        return Result.error(
          AuthException(message: 'No hay usuario autenticado'),
        );
      }

      await user.verifyBeforeUpdateEmail(newEmail);
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      return Result.error(_handleFirebaseAuthError(e));
    } catch (error) {
      return Result.error(
        AuthException(message: 'Error al actualizar email', cause: error),
      );
    }
  }

  /// Verificar si el usuario está autenticado con Google
  bool get isGoogleUser {
    final user = _currentUser;
    if (user == null) return false;

    for (final provider in user.providerData) {
      if (provider.providerId == 'google.com') {
        return true;
      }
    }
    return false;
  }

  /// Verificar si el usuario está autenticado con email/password
  bool get isEmailPasswordUser {
    final user = _currentUser;
    if (user == null) return false;

    for (final provider in user.providerData) {
      if (provider.providerId == 'password') {
        return true;
      }
    }
    return false;
  }

  /// Obtener proveedores de autenticación del usuario
  List<String> get authProviders {
    final user = _currentUser;
    if (user == null) return [];

    return user.providerData.map((provider) => provider.providerId).toList();
  }

  /// Vincular cuenta con Google
  Future<Result<void, Exception>> linkWithGoogle() async {
    try {
      final user = _currentUser;
      if (user == null) {
        return Result.error(
          AuthException(message: 'No hay usuario autenticado'),
        );
      }

      // Iniciar flujo de autenticación de Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // El usuario canceló la operación, no es un error
        return Result.success(null);
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await user.linkWithCredential(credential);

      // Sincronizar usuario con Supabase
      await _syncUserWithSupabase(user);

      await _loadUserProfile(user.uid);
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      return Result.error(_handleFirebaseAuthError(e));
    } catch (error) {
      return Result.error(
        AuthException(
          message: 'Error al vincular cuenta con Google',
          cause: error,
        ),
      );
    }
  }

  /// Desvincular cuenta de Google
  Future<Result<void, Exception>> unlinkGoogle() async {
    try {
      final user = _currentUser;
      if (user == null) {
        return Result.error(
          AuthException(message: 'No hay usuario autenticado'),
        );
      }

      await user.unlink('google.com');
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      return Result.error(_handleFirebaseAuthError(e));
    } catch (error) {
      return Result.error(
        AuthException(
          message: 'Error al desvincular cuenta de Google',
          cause: error,
        ),
      );
    }
  }

  /// Obtener información del usuario para mostrar en UI
  Map<String, dynamic> get userInfo {
    return {
      'id': currentUserId,
      'email': currentUserEmail,
      'nombre': currentUserName,
      'fotoUrl': currentUserImageUrl,
      'emailVerificado': isEmailVerified,
      'proveedores': authProviders,
      'esGoogleUser': isGoogleUser,
      'esEmailPasswordUser': isEmailPasswordUser,
    };
  }

  /// Verificar si el usuario tiene un perfil completo
  bool get hasCompleteProfile {
    return currentUserName != null &&
        currentUserName!.isNotEmpty &&
        currentUserEmail != null;
  }

  /// Obtener fecha de registro del usuario
  DateTime? get registrationDate {
    if (_userProfile != null) {
      // Intentar obtener de Supabase primero
      final supabaseDate = _userProfile!['created_at'];
      if (supabaseDate != null) {
        if (supabaseDate is String) {
          return DateTime.tryParse(supabaseDate);
        } else if (supabaseDate is DateTime) {
          return supabaseDate;
        }
      }
      // Fallback a fecha de registro de Firestore (obsoleta)
      final firestoreDate = _userProfile!['fechaRegistro'];
      if (firestoreDate != null) {
        if (firestoreDate is String) {
          return DateTime.tryParse(firestoreDate);
        } else if (firestoreDate is DateTime) {
          return firestoreDate;
        }
      }
    }
    return _currentUser?.metadata.creationTime;
  }

  /// Obtener fecha del último acceso
  DateTime? get lastSignInDate {
    if (_userProfile != null) {
      // Intentar obtener de Supabase primero
      final supabaseDate = _userProfile!['updated_at'];
      if (supabaseDate != null) {
        if (supabaseDate is String) {
          return DateTime.tryParse(supabaseDate);
        } else if (supabaseDate is DateTime) {
          return supabaseDate;
        }
      }
      // Fallback a fecha de actualización de Firestore (obsoleta)
      final firestoreDate = _userProfile!['fechaActualizacion'];
      if (firestoreDate != null) {
        if (firestoreDate is String) {
          return DateTime.tryParse(firestoreDate);
        } else if (firestoreDate is DateTime) {
          return firestoreDate;
        }
      }
    }
    return _currentUser?.metadata.lastSignInTime;
  }

  /// Obtener preferencias del usuario
  Map<String, dynamic>? get userPreferences {
    return _userProfile?['preferencias'];
  }

  /// Obtener favoritos del usuario
  List<String>? get userFavorites {
    final favorites = _userProfile?['favoritos'];
    if (favorites is List) {
      return favorites.cast<String>();
    }
    return null;
  }

  /// Verificar si un item está en favoritos
  bool isFavorite(String itemId) {
    final favorites = userFavorites;
    return favorites?.contains(itemId) ?? false;
  }
}
