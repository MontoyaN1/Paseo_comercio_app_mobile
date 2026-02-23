// lib/core/utils/firebase_auth_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kDebugMode, TargetPlatform;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../errors/app_exceptions.dart';
import 'auth_state.dart';
import 'cache_service.dart';
import 'result.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Servicio de autenticación con Firebase (reemplazo de Clerk)
class FirebaseAuthService {
  // Singleton pattern
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  // Instancias de Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late GoogleSignIn _googleSignIn;

  // Estados de autenticación
  AuthState _currentState = AuthState.unknown;
  final StreamController<AuthState> _stateController =
      StreamController<AuthState>.broadcast();

  // Usuario actual
  User? _currentUser;
  Map<String, dynamic>? _userProfile;

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
        if (kDebugMode) {
          print('Firebase no está inicializado: $e');
        }
        // No lanzamos excepción, solo registramos el error
        // Firebase se inicializará automáticamente cuando se use
      }

      // Configurar GoogleSignIn con opciones de Android si está disponible
      _configureGoogleSignIn();

      // Escuchar cambios en el estado de autenticación
      _auth.authStateChanges().listen((User? user) async {
        if (user != null) {
          _currentUser = user;
          await _loadUserProfile(user.uid);
          await _updateAuthState(AuthState.authenticated);
        } else {
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

      if (kDebugMode) {
        print('FirebaseAuthService: Inicializado correctamente');
        print('Usuario actual: ${_currentUser?.email ?? "No autenticado"}');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error al inicializar FirebaseAuthService: $error');
      }
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
  String? get currentUserName =>
      _currentUser?.displayName ?? _userProfile?['nombre'];

  /// Obtener URL de imagen del usuario actual
  String? get currentUserImageUrl =>
      _currentUser?.photoURL ?? _userProfile?['fotoUrl'];

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

      if (kDebugMode) {
        print('FirebaseAuthService: Configurando GoogleSignIn...');
        print(
          'FirebaseAuthService: Android Client ID presente: ${androidClientId.isNotEmpty ? "✅" : "❌"}',
        );
      }

      // Configurar GoogleSignIn según la plataforma
      if (defaultTargetPlatform == TargetPlatform.android) {
        // Para Android, usar el web_client_id desde variables de entorno
        // o dejar que Google Sign-In use la configuración automática
        if (androidClientId.isNotEmpty) {
          _googleSignIn = GoogleSignIn(
            scopes: ['email', 'profile'],
            clientId: androidClientId,
          );
          if (kDebugMode) {
            print(
              'FirebaseAuthService: GoogleSignIn configurado con clientId específico',
            );
          }
        } else {
          // Si no hay clientId, usar configuración automática
          _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
          if (kDebugMode) {
            print(
              'FirebaseAuthService: GoogleSignIn configurado con configuración automática',
            );
            print(
              'FirebaseAuthService: NOTA: Para evitar errores API 10, asegúrate de:',
            );
            print(
              'FirebaseAuthService: 1. Configurar SHA-1 en Firebase Console',
            );
            print(
              'FirebaseAuthService: 2. Package name: com.paseodelcomercio.app',
            );
            print(
              'FirebaseAuthService: 3. Habilitar Google Sign-In en Firebase Auth',
            );
          }
        }
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        // Para iOS, usar configuración automática
        _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
        if (kDebugMode) {
          print('FirebaseAuthService: GoogleSignIn configurado para iOS');
        }
      } else {
        // Para otras plataformas
        _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
        if (kDebugMode) {
          print(
            'FirebaseAuthService: GoogleSignIn configurado para $defaultTargetPlatform',
          );
        }
      }

      if (kDebugMode) {
        print('FirebaseAuthService: GoogleSignIn configurado correctamente');
      }
    } catch (error) {
      if (kDebugMode) {
        print('FirebaseAuthService: Error al configurar GoogleSignIn: $error');
      }
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
        // Crear perfil del usuario en Firestore
        await _createUserProfile(
          userId: userCredential.user!.uid,
          email: email,
          nombre: nombre,
        );

        // Actualizar display name si se proporcionó
        if (nombre != null) {
          await userCredential.user!.updateDisplayName(nombre);
        }

        await _loadUserProfile(userCredential.user!.uid);
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
      if (kDebugMode) {
        print('FirebaseAuthService: Iniciando autenticación con Google...');
        print('FirebaseAuthService: Plataforma: $defaultTargetPlatform');
      }

      // Iniciar flujo de autenticación de Google
      if (kDebugMode) {
        print('FirebaseAuthService: Llamando a GoogleSignIn.signIn()...');
      }

      GoogleSignInAccount? googleUser;
      try {
        googleUser = await _googleSignIn.signIn();
      } catch (signInError) {
        if (kDebugMode) {
          print(
            'FirebaseAuthService: Error en GoogleSignIn.signIn(): $signInError',
          );
          print('FirebaseAuthService: StackTrace: ${signInError.toString()}');
        }

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
        if (kDebugMode) {
          print(
            'FirebaseAuthService: Usuario canceló el flujo de Google Sign-In',
          );
        }
        return Result.error(AuthException(message: 'Cancelado por el usuario'));
      }

      // Verificar que el usuario de Google tenga email (requerido)
      if (googleUser.email == null || googleUser.email!.isEmpty) {
        if (kDebugMode) {
          print('FirebaseAuthService: Error - usuario de Google sin email');
        }
        return Result.error(
          AuthException(
            message: 'No se pudo obtener el email de la cuenta de Google',
          ),
        );
      }

      if (kDebugMode) {
        print(
          'FirebaseAuthService: Usuario de Google obtenido: ${googleUser.email}',
        );
        print('FirebaseAuthService: ID: ${googleUser.id}');
      }

      // Obtener credenciales de autenticación
      if (kDebugMode) {
        print('FirebaseAuthService: Obteniendo autenticación de Google...');
      }
      final GoogleSignInAuthentication googleAuth;
      try {
        googleAuth = await googleUser.authentication;
      } catch (authError) {
        if (kDebugMode) {
          print(
            'FirebaseAuthService: Error al obtener autenticación de Google: $authError',
          );
        }
        return Result.error(
          AuthException(
            message: 'Error al obtener credenciales de Google',
            cause: authError,
          ),
        );
      }

      if (kDebugMode) {
        print('FirebaseAuthService: Creando credencial de Firebase...');
        print(
          'FirebaseAuthService: AccessToken presente: ${googleAuth.accessToken != null}',
        );
        print(
          'FirebaseAuthService: IdToken presente: ${googleAuth.idToken != null}',
        );
      }

      // Verificar que al menos un token esté disponible
      if (googleAuth.accessToken == null && googleAuth.idToken == null) {
        if (kDebugMode) {
          print('FirebaseAuthService: Error - ambos tokens son nulos');
        }
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
        }

        // Crear o actualizar perfil del usuario
        await _createOrUpdateUserProfile(
          userId: userCredential.user!.uid,
          email: userCredential.user!.email!,
          nombre: userCredential.user!.displayName,
          fotoUrl: userCredential.user!.photoURL,
        );

        await _loadUserProfile(userCredential.user!.uid);

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
        // Crear perfil básico para usuario anónimo
        await _createBasicUserProfile(userCredential.user!.uid);
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

      // Actualizar en Firestore
      final updates = <String, dynamic>{};
      if (nombre != null) updates['nombre'] = nombre;
      if (telefono != null) updates['telefono'] = telefono;
      if (fotoUrl != null) updates['fotoUrl'] = fotoUrl;
      updates['fechaActualizacion'] = FieldValue.serverTimestamp();

      await _firestore.collection('usuarios').doc(userId).update(updates);

      // Actualizar en Firebase Auth si es necesario
      if (nombre != null && _currentUser != null) {
        await _currentUser!.updateDisplayName(nombre);
      }

      if (fotoUrl != null && _currentUser != null) {
        await _currentUser!.updatePhotoURL(fotoUrl);
      }

      // Recargar perfil
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

      // Eliminar perfil de Firestore
      await _firestore.collection('usuarios').doc(user.uid).delete();

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

  /// Cargar perfil del usuario desde Firestore
  Future<void> _loadUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('usuarios').doc(userId).get();
      if (doc.exists) {
        _userProfile = doc.data();
      } else {
        // Crear perfil básico si no existe
        await _createBasicUserProfile(userId);
        _userProfile = {
          'id': userId,
          'email': _currentUser?.email,
          'nombre': _currentUser?.displayName,
          'fechaRegistro': FieldValue.serverTimestamp(),
        };
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error al cargar perfil de usuario: $error');
      }
      _userProfile = null;
    }
  }

  /// Crear perfil básico de usuario
  Future<void> _createBasicUserProfile(String userId) async {
    try {
      await _firestore.collection('usuarios').doc(userId).set({
        'id': userId,
        'email': _currentUser?.email,
        'nombre': _currentUser?.displayName,
        'fotoUrl': _currentUser?.photoURL,
        'fechaRegistro': FieldValue.serverTimestamp(),
        'fechaActualizacion': FieldValue.serverTimestamp(),
        'preferencias': {
          'notificaciones': true,
          'tema': 'light',
          'idioma': 'es',
        },
        'favoritos': [],
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error al crear perfil básico: $error');
      }
    }
  }

  /// Crear perfil de usuario
  Future<void> _createUserProfile({
    required String userId,
    required String email,
    String? nombre,
  }) async {
    try {
      await _firestore.collection('usuarios').doc(userId).set({
        'id': userId,
        'email': email,
        'nombre': nombre,
        'fechaRegistro': FieldValue.serverTimestamp(),
        'fechaActualizacion': FieldValue.serverTimestamp(),
        'preferencias': {
          'notificaciones': true,
          'tema': 'light',
          'idioma': 'es',
        },
        'favoritos': [],
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error al crear perfil de usuario: $error');
      }
    }
  }

  /// Crear o actualizar perfil de usuario
  Future<void> _createOrUpdateUserProfile({
    required String userId,
    required String email,
    String? nombre,
    String? fotoUrl,
  }) async {
    try {
      final userRef = _firestore.collection('usuarios').doc(userId);
      final doc = await userRef.get();

      if (doc.exists) {
        // Actualizar perfil existente
        await userRef.update({
          'nombre': nombre,
          'fotoUrl': fotoUrl,
          'fechaActualizacion': FieldValue.serverTimestamp(),
        });
      } else {
        // Crear nuevo perfil
        await userRef.set({
          'id': userId,
          'email': email,
          'nombre': nombre,
          'fotoUrl': fotoUrl,
          'fechaRegistro': FieldValue.serverTimestamp(),
          'fechaActualizacion': FieldValue.serverTimestamp(),
          'preferencias': {
            'notificaciones': true,
            'tema': 'light',
            'idioma': 'es',
          },
          'favoritos': [],
        });
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error al crear/actualizar perfil: $error');
      }
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
        return Result.error(AuthException(message: 'Cancelado por el usuario'));
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await user.linkWithCredential(credential);

      // Actualizar perfil con información de Google
      await _createOrUpdateUserProfile(
        userId: user.uid,
        email: user.email!,
        nombre: googleUser.displayName,
        fotoUrl: googleUser.photoUrl,
      );

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

  /// Cargar estado de autenticación guardado
  Future<void> _loadAuthState() async {
    try {
      final cache = CacheService();
      final result = await cache.get<String>('auth_state');
      result.fold((savedState) {
        if (savedState != null) {
          final state = AuthState.fromName(savedState);
          _currentState = state;
          _stateController.add(state);
        }
      }, (error) => print('Error loading auth state: $error'));
    } catch (_) {
      // Ignorar errores de carga
    }
  }

  /// Limpiar estado de autenticación
  Future<void> _clearAuthState() async {
    try {
      final cache = CacheService();
      final result = await cache.remove('auth_state');
      result.fold(
        (_) {}, // éxito
        (error) => print('Error removing auth state: $error'),
      );
    } catch (_) {
      // Ignorar errores
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
    if (_userProfile != null && _userProfile!['fechaRegistro'] != null) {
      final timestamp = _userProfile!['fechaRegistro'];
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      }
    }
    return _currentUser?.metadata.creationTime;
  }

  /// Obtener fecha del último acceso
  DateTime? get lastSignInDate {
    if (_userProfile != null && _userProfile!['fechaActualizacion'] != null) {
      final timestamp = _userProfile!['fechaActualizacion'];
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      }
    }
    return _currentUser?.metadata.lastSignInTime;
  }

  /// Obtener preferencias del usuario
  Map<String, dynamic>? get userPreferences {
    return _userProfile?['preferencias'];
  }

  /// Actualizar preferencias del usuario
  Future<Result<void, Exception>> updatePreferences(
    Map<String, dynamic> preferences,
  ) async {
    try {
      final userId = _currentUser?.uid;
      if (userId == null) {
        return Result.error(
          AuthException(message: 'No hay usuario autenticado'),
        );
      }

      await _firestore.collection('usuarios').doc(userId).update({
        'preferencias': preferences,
        'fechaActualizacion': FieldValue.serverTimestamp(),
      });

      await _loadUserProfile(userId);
      return Result.success(null);
    } catch (error) {
      return Result.error(
        AuthException(
          message: 'Error al actualizar preferencias',
          cause: error,
        ),
      );
    }
  }

  /// Obtener favoritos del usuario
  List<String>? get userFavorites {
    final favorites = _userProfile?['favoritos'];
    if (favorites is List) {
      return favorites.cast<String>();
    }
    return null;
  }

  /// Agregar favorito
  Future<Result<void, Exception>> addFavorite(String itemId) async {
    try {
      final userId = _currentUser?.uid;
      if (userId == null) {
        return Result.error(
          AuthException(message: 'No hay usuario autenticado'),
        );
      }

      await _firestore.collection('usuarios').doc(userId).update({
        'favoritos': FieldValue.arrayUnion([itemId]),
        'fechaActualizacion': FieldValue.serverTimestamp(),
      });

      await _loadUserProfile(userId);
      return Result.success(null);
    } catch (error) {
      return Result.error(
        AuthException(message: 'Error al agregar favorito', cause: error),
      );
    }
  }

  /// Eliminar favorito
  Future<Result<void, Exception>> removeFavorite(String itemId) async {
    try {
      final userId = _currentUser?.uid;
      if (userId == null) {
        return Result.error(
          AuthException(message: 'No hay usuario autenticado'),
        );
      }

      await _firestore.collection('usuarios').doc(userId).update({
        'favoritos': FieldValue.arrayRemove([itemId]),
        'fechaActualizacion': FieldValue.serverTimestamp(),
      });

      await _loadUserProfile(userId);
      return Result.success(null);
    } catch (error) {
      return Result.error(
        AuthException(message: 'Error al eliminar favorito', cause: error),
      );
    }
  }

  /// Verificar si un item está en favoritos
  bool isFavorite(String itemId) {
    final favorites = userFavorites;
    return favorites?.contains(itemId) ?? false;
  }
}
