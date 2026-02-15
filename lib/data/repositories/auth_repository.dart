// lib/data/repositories/auth_repository.dart

import 'dart:async';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

import '../../core/app/app_config.dart';
import '../datasources/remote/supabase_client.dart';
import '../datasources/local/local_database.dart';

/// Repositorio para manejar autenticación y sincronización de usuarios
class AuthRepository {
  final SupabaseClientService _supabaseClient;
  final LocalCacheService _localCache;
  final ClerkAuth _clerkAuth;
  final Logger _logger;

  // Stream para notificar cambios en el usuario
  final StreamController<Map<String, dynamic>?> _userController =
      StreamController<Map<String, dynamic>?>.broadcast();

  AuthRepository({
    required SupabaseClientService supabaseClient,
    required LocalCacheService localCache,
    required ClerkAuth clerkAuth,
  }) : _supabaseClient = supabaseClient,
       _localCache = localCache,
       _clerkAuth = clerkAuth,
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
    // Escuchar cambios en la autenticación de Clerk
    _setupAuthListener();
  }

  /// Configurar listener para cambios de autenticación
  void _setupAuthListener() {
    _clerkAuth.addListener(() {
      final user = _clerkAuth.user;
      if (user != null) {
        // Cuando el usuario inicia sesión en Clerk, sincronizar con Supabase
        _syncUserWithSupabase(user).then((supabaseUser) {
          if (supabaseUser != null) {
            _userController.add(supabaseUser);
          }
        });
      } else {
        // Cuando el usuario cierra sesión
        _userController.add(null);
      }
    });
  }

  /// Sincronizar usuario de Clerk con Supabase
  Future<Map<String, dynamic>?> _syncUserWithSupabase(
    ClerkUser clerkUser,
  ) async {
    try {
      _logger.i('Syncing Clerk user with Supabase: ${clerkUser.id}');

      // Sincronizar con Supabase
      final supabaseUser = await _supabaseClient.syncUsuarioFromClerk(
        clerkUserId: clerkUser.id,
        nombreCompleto: clerkUser.fullName ?? 'Usuario',
        email: clerkUser.primaryEmailAddress?.emailAddress ?? '',
        telefono: clerkUser.primaryPhoneNumber?.phoneNumber ?? '',
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

  /// Obtener usuario actual (combinando Clerk + Supabase)
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final clerkUser = _clerkAuth.user;
      if (clerkUser == null) {
        _logger.d('No Clerk user found');
        return null;
      }

      // Primero intentar obtener de caché local
      final cachedUser = await _localCache.getCachedUsuario(clerkUser.id);
      if (cachedUser != null) {
        _logger.d('User found in local cache');
        return cachedUser;
      }

      // Si no está en caché, obtener de Supabase
      final supabaseUser = await _supabaseClient.getUsuarioByClerkId(
        clerkUser.id,
      );
      if (supabaseUser != null) {
        // Guardar en caché
        await _localCache.cacheUsuario(supabaseUser);
        _logger.d('User retrieved from Supabase and cached');
        return supabaseUser;
      }

      // Si no existe en Supabase, crear nuevo usuario
      _logger.d('User not found in Supabase, creating new...');
      return await _syncUserWithSupabase(clerkUser);
    } catch (e) {
      _logger.e('Error getting current user: $e');
      return null;
    }
  }

  /// Verificar si el usuario está autenticado
  bool get isAuthenticated => _clerkAuth.user != null;

  /// Obtener ID del usuario actual
  String? get currentUserId => _clerkAuth.user?.id;

  /// Obtener email del usuario actual
  String? get currentUserEmail =>
      _clerkAuth.user?.primaryEmailAddress?.emailAddress;

  /// Obtener nombre del usuario actual
  String? get currentUserName => _clerkAuth.user?.fullName;

  /// Obtener imagen del usuario actual
  String? get currentUserImage => _clerkAuth.user?.imageUrl;

  /// Iniciar sesión con Clerk
  Future<void> signIn() async {
    try {
      await _clerkAuth.signIn();
      _logger.i('Sign in initiated');
    } catch (e) {
      _logger.e('Error during sign in: $e');
      rethrow;
    }
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    try {
      await _clerkAuth.signOut();

      // Limpiar caché de usuario
      final userId = currentUserId;
      if (userId != null) {
        await _localCache.removePreference('current_user_$userId');
      }

      _logger.i('Sign out completed');
    } catch (e) {
      _logger.e('Error during sign out: $e');
      rethrow;
    }
  }

  /// Registrar nuevo usuario
  Future<void> signUp({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    try {
      await _clerkAuth.signUp(
        emailAddress: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      _logger.i('Sign up initiated for: $email');
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
      final userRole = user['roles_id'];
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

  /// Actualizar perfil del usuario
  Future<bool> updateProfile({
    String? nombreCompleto,
    String? telefono,
    bool? perfilPublico,
  }) async {
    try {
      final clerkUser = _clerkAuth.user;
      if (clerkUser == null) {
        _logger.w('No user authenticated');
        return false;
      }

      // Actualizar en Supabase
      final updates = <String, dynamic>{};
      if (nombreCompleto != null) updates['nombre_completo'] = nombreCompleto;
      if (telefono != null) updates['telefono'] = telefono;
      if (perfilPublico != null) updates['perfil_publico'] = perfilPublico;
      updates['updated_at'] = DateTime.now().toIso8601String();

      if (updates.isNotEmpty) {
        final response =
            await _supabaseClient.usuarios
                .update(updates)
                .eq('clerk_user_id', clerkUser.id)
                .execute();

        if (response.error != null) {
          _logger.e('Error updating profile in Supabase: ${response.error}');
          return false;
        }

        // Actualizar caché local
        final currentUser = await getCurrentUser();
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
      // Verificar Clerk
      results['clerk'] = _clerkAuth.user != null;

      // Verificar Supabase
      results['supabase'] = await _supabaseClient.checkConnection();

      // Verificar caché local
      results['local_cache'] = _localCache.isInitialized;

      _logger.i('Services status: $results');
    } catch (e) {
      _logger.e('Error checking services status: $e');
      results['error'] = false;
    }

    return results;
  }

  /// Obtener estadísticas del usuario
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final user = await getCurrentUser();
      if (user == null) {
        return {'error': 'No authenticated user'};
      }

      final userId = user['id'];

      // Obtener estadísticas desde Supabase
      final tiendasResponse =
          await _supabaseClient.tiendas
              .select('count')
              .eq('id_propietario', userId)
              .execute();

      final productosResponse =
          await _supabaseClient.productos
              .select('count')
              .eq(
                'tienda_id',
                userId,
              ) // Esto asume que el usuario es dueño de tienda
              .execute();

      final valoracionesResponse =
          await _supabaseClient.valoraciones
              .select('count')
              .eq('usuario_id', userId)
              .execute();

      return {
        'tiendas_count': (tiendasResponse.data as List).first['count'] ?? 0,
        'productos_count': (productosResponse.data as List).first['count'] ?? 0,
        'valoraciones_count':
            (valoracionesResponse.data as List).first['count'] ?? 0,
        'member_since': user['fecha_registro'],
        'last_login': user['ultimo_login'],
        'profile_public': user['perfil_publico'] ?? true,
      };
    } catch (e) {
      _logger.e('Error getting user stats: $e');
      return {'error': e.toString()};
    }
  }

  /// Disposer para limpiar recursos
  void dispose() {
    _userController.close();
    _logger.i('AuthRepository disposed');
  }
}
