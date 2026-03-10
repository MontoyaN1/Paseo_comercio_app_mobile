// lib/data/repositories/auth_repository.dart

import '../../domain/repositories/auth_repository_interface.dart';

import 'dart:async';
import 'package:logger/logger.dart';

import '../datasources/remote/supabase_client.dart';
import '../datasources/local/local_database.dart';

/// Repositorio para manejar autenticación y sincronización de usuarios
/// NOTA: La integración con Clerk Flutter está pendiente de implementación
/// debido a que la versión beta (0.0.14-beta) tiene una API limitada.
class AuthRepository implements AuthRepositoryInterface {
  final SupabaseClientService _supabaseClient;
  final LocalCacheService _localCache;
  final Logger _logger;

  // Stream para notificar cambios en el usuario
  final StreamController<Map<String, dynamic>?> _userController =
      StreamController<Map<String, dynamic>?>.broadcast();

  AuthRepository({
    required SupabaseClientService supabaseClient,
    required LocalCacheService localCache,
  }) : _supabaseClient = supabaseClient,
       _localCache = localCache,
       _logger = Logger(
         printer: PrettyPrinter(
           methodCount: 0,
           errorMethodCount: 3,
           lineLength: 50,
           colors: true,
           printEmojis: true,
           printTime: false,
         ),
       ) {
    _logger.i('AuthRepository initialized (Clerk integration pending)');
  }

  /// Sincronizar usuario con Supabase
  Future<Map<String, dynamic>?> _syncUserWithSupabase({
    required String clerkUserId,
    required String nombreCompleto,
    required String email,
    required String telefono,
    String? avatarUrl,
  }) async {
    try {
      _logger.i('Syncing user with Supabase: $clerkUserId');

      // Sincronizar con Supabase
      final supabaseUser = await _supabaseClient.syncUsuarioFromClerk(
        clerkUserId: clerkUserId,
        nombreCompleto: nombreCompleto,
        email: email,
        telefono: telefono,
        avatarUrl: avatarUrl,
      );

      if (supabaseUser != null) {
        // Guardar en caché local
        await _localCache.cacheUsuario(supabaseUser);
        _logger.i('User synced successfully: ${supabaseUser['email']}');
        return supabaseUser;
      } else {
        _logger.w('Failed to sync user with Supabase');
        return null;
      }
    } catch (e) {
      _logger.e('Error syncing user with Supabase: $e');
      return null;
    }
  }

  /// Obtener usuario actual (placeholder hasta que implementemos Clerk)
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      _logger.d('Clerk integration pending - using placeholder user');

      // TODO: Implementar integración real con Clerk Flutter
      // Por ahora, retornamos null o un usuario de prueba
      return null;
    } catch (e) {
      _logger.e('Error getting current user: $e');
      return null;
    }
  }

  /// Obtener usuario por ID de Clerk
  Future<Map<String, dynamic>?> getUserByClerkId(String clerkUserId) async {
    try {
      // Primero intentar obtener de caché local
      final cachedUser = await _localCache.getCachedUsuario(clerkUserId);
      if (cachedUser != null) {
        _logger.d('User found in local cache');
        return cachedUser;
      }

      // Si no está en caché, obtener de Supabase
      final supabaseUser = await _supabaseClient.getUsuarioByClerkId(
        clerkUserId,
      );
      if (supabaseUser != null) {
        // Guardar en caché
        await _localCache.cacheUsuario(supabaseUser);
        _logger.d('User retrieved from Supabase and cached');
        return supabaseUser;
      }

      return null;
    } catch (e) {
      _logger.e('Error getting user by Clerk ID: $e');
      return null;
    }
  }

  /// Verificar si el usuario está autenticado
  @override
  Future<bool> isAuthenticated() async {
    // TODO: Implementar verificación real con Clerk
    _logger.d('Clerk authentication check pending implementation');
    return false;
  }

  /// Obtener ID del usuario actual
  String? get currentUserId {
    // TODO: Implementar obtención real con Clerk
    _logger.d('Clerk user ID retrieval pending implementation');
    return null;
  }

  /// Obtener email del usuario actual
  String? get currentUserEmail {
    // TODO: Implementar obtención real con Clerk
    _logger.d('Clerk user email retrieval pending implementation');
    return null;
  }

  /// Obtener nombre del usuario actual
  String? get currentUserName {
    // TODO: Implementar obtención real con Clerk
    _logger.d('Clerk user name retrieval pending implementation');
    return null;
  }

  /// Obtener imagen del usuario actual
  String? get currentUserImage {
    // TODO: Implementar obtención real con Clerk
    _logger.d('Clerk user image retrieval pending implementation');
    return null;
  }

  /// Iniciar sesión (placeholder)
  Future<void> signIn() async {
    try {
      // TODO: Implementar inicio de sesión real con Clerk
      _logger.i('Sign in functionality pending Clerk implementation');
      throw UnimplementedError('Clerk signIn not implemented');
    } catch (e) {
      _logger.e('Error during sign in: $e');
      rethrow;
    }
  }

  /// Cerrar sesión (placeholder)
  @override
  Future<bool> signOut() async {
    try {
      // TODO: Implementar cierre de sesión real con Clerk
      _logger.i('Sign out functionality pending Clerk implementation');

      // Limpiar caché de usuario
      final userId = currentUserId;
      if (userId != null) {
        await _localCache.removePreference('current_user_$userId');
      }

      _logger.i('Sign out completed (placeholder)');
      return true;
    } catch (e) {
      _logger.e('Error during sign out: $e');
      return false;
    }
  }

  /// Registrar nuevo usuario (placeholder)
  Future<void> signUp({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    try {
      // TODO: Implementar registro real con Clerk
      _logger.i('Sign up functionality pending Clerk implementation: $email');
      throw UnimplementedError('Clerk signUp not implemented');
    } catch (e) {
      _logger.e('Error during sign up: $e');
      rethrow;
    }
  }

  /// Verificar si el usuario tiene un rol específico
  Future<bool> hasRole(String role) async {
    try {
      final user = await getCurrentUser();
      if (user == null) return false;

      // Aquí puedes implementar lógica para verificar roles
      // Por ejemplo, verificar en la tabla de roles de Supabase
      // final userRole = user['roles_id'];
      // Implementar lógica específica según tu esquema de roles

      return false; // Placeholder
    } catch (e) {
      _logger.e('Error checking role: $e');
      return false;
    }
  }

  /// Verificar si el usuario es administrador
  Future<bool> isAdmin() async {
    return await hasRole('admin') || await hasRole('administrador');
  }

  /// Verificar si el usuario es emprendedor (dueño de tienda)
  Future<bool> isEmprendedor() async {
    return await hasRole('emprendedor') || await hasRole('anfitrión');
  }

  /// Actualizar perfil del usuario en Supabase
  Future<bool> updateProfile({
    required String clerkUserId,
    String? nombreCompleto,
    String? telefono,
    bool? perfilPublico,
  }) async {
    try {
      // Actualizar en Supabase
      final updates = <String, dynamic>{};
      if (nombreCompleto != null) updates['nombre_completo'] = nombreCompleto;
      if (telefono != null) updates['telefono'] = telefono;
      if (perfilPublico != null) updates['perfil_publico'] = perfilPublico;

      if (updates.isNotEmpty) {
        final response = await _supabaseClient.usuarios
            .update(updates)
            .eq('clerk_user_id', clerkUserId);

        if (response == null) {
          _logger.e('Error updating profile in Supabase: response is null');
          return false;
        }

        // Actualizar caché local
        final currentUser = await getUserByClerkId(clerkUserId);
        if (currentUser != null) {
          final updatedUser = {...currentUser, ...updates};
          await _localCache.cacheUsuario(updatedUser);
          _userController.add(updatedUser);
        }

        _logger.i('Profile updated successfully');
        return true;
      }

      return false;
    } catch (e) {
      _logger.e('Error updating profile: $e');
      return false;
    }
  }

  /// Obtener stream de cambios en el usuario
  Stream<Map<String, dynamic>?> get userStream => _userController.stream;

  /// Verificar estado de conexión con los servicios
  Future<Map<String, bool>> checkServicesStatus() async {
    final results = <String, bool>{};

    try {
      // Verificar Supabase
      results['supabase'] = await _supabaseClient.checkConnection();

      // Verificar caché local
      results['local_cache'] = _localCache.isInitialized;

      // Clerk está pendiente de implementación
      results['clerk'] = false;

      _logger.i('Services status: $results (Clerk pending)');
    } catch (e) {
      _logger.e('Error checking services status: $e');
      results['error'] = false;
    }

    return results;
  }

  /// Obtener estadísticas del usuario
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      // Obtener estadísticas desde Supabase
      final tiendasResponse =
          await _supabaseClient.tiendas
              .select()
              .eq('usuario_id', userId)
              .count();

      final productosResponse =
          await _supabaseClient.productos
              .select()
              .eq('usuario_id', userId)
              .count();

      final valoracionesResponse =
          await _supabaseClient.valoraciones
              .select()
              .eq('usuario_id', userId)
              .count();

      return {
        'tiendas_count': (tiendasResponse is int) ? tiendasResponse : 0,
        'productos_count': (productosResponse is int) ? productosResponse : 0,
        'valoraciones_count':
            (valoracionesResponse is int) ? valoracionesResponse : 0,
      };
    } catch (e) {
      _logger.e('Error getting user stats: $e');
      return {'error': e.toString()};
    }
  }

  /// Notificar cambio en el usuario
  void notifyUserChange(Map<String, dynamic>? user) {
    _userController.add(user);
  }

  @override
  Stream<AuthState> get authStateStream => Stream.empty();

  @override
  Future<String?> getAuthToken() async {
    _logger.d('getAuthToken not implemented');
    return null;
  }

  @override
  Future<bool> hasUserProfile() async {
    _logger.d('hasUserProfile not implemented');
    return false;
  }

  @override
  Future<bool> isTokenValid() async {
    _logger.d('isTokenValid not implemented');
    return false;
  }

  @override
  Future<String?> refreshToken() async {
    _logger.d('refreshToken not implemented');
    return null;
  }

  @override
  Future<Map<String, dynamic>?> signInWithClerk({
    required String email,
    required String password,
  }) async {
    _logger.d('signInWithClerk not implemented');
    return null;
  }

  @override
  Future<Map<String, dynamic>?> signInWithSocial(String provider) async {
    _logger.d('signInWithSocial not implemented');
    return null;
  }

  @override
  Future<Map<String, dynamic>?> signUpWithClerk({
    required String email,
    required String password,
    required String nombreCompleto,
    String? telefono,
  }) async {
    _logger.d('signUpWithClerk not implemented');
    return null;
  }

  @override
  Future<Map<String, dynamic>?> syncUserFromClerk({
    required String clerkUserId,
    required String nombreCompleto,
    required String email,
    String? telefono,
    String? avatarUrl,
  }) async {
    _logger.d('syncUserFromClerk: delegating to _syncUserWithSupabase');
    return await _syncUserWithSupabase(
      clerkUserId: clerkUserId,
      nombreCompleto: nombreCompleto,
      email: email,
      telefono: telefono ?? '',
      avatarUrl: avatarUrl,
    );
  }

  @override
  Future<bool> updateUserProfile({
    String? nombreCompleto,
    String? telefono,
    bool? perfilPublico,
    String? avatarUrl,
  }) async {
    _logger.d('updateUserProfile: delegating to updateProfile');
    // TODO: Necesitamos obtener el clerkUserId del usuario actual
    final currentUser = await getCurrentUser();
    if (currentUser == null || currentUser['clerk_user_id'] == null) {
      _logger.e('No se puede actualizar perfil: usuario no autenticado');
      return false;
    }

    return await updateProfile(
      clerkUserId: currentUser['clerk_user_id'] as String,
      nombreCompleto: nombreCompleto,
      telefono: telefono,
      perfilPublico: perfilPublico,
    );
  }

  /// Disposer para limpiar recursos
  void dispose() {
    _userController.close();
    _logger.i('AuthRepository disposed');
  }
}
