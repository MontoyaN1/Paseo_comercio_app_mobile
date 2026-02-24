// lib/data/datasources/remote/supabase_client.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

import '../../../core/app/app_config.dart';

/// Cliente personalizado para Supabase con métodos específicos para cada tabla
class SupabaseClientService {
  static final SupabaseClientService _instance =
      SupabaseClientService._internal();
  factory SupabaseClientService() => _instance;
  SupabaseClientService._internal();

  late SupabaseClient _client;
  late Logger _logger;
  bool _isInitialized = false;

  /// Inicializar el cliente Supabase
  Future<void> initialize() async {
    if (_isInitialized) return;

    final appConfig = AppConfig();

    try {
      await Supabase.initialize(
        url: appConfig.supabaseUrl,
        anonKey: appConfig.supabaseServiceRoleKey,
      );

      _client = Supabase.instance.client;
      _logger = Logger(
        printer: PrettyPrinter(
          methodCount: 0,
          errorMethodCount: 5,
          lineLength: 50,
          colors: true,
          printEmojis: true,
        ),
      );

      _isInitialized = true;

      _logger.i('✅ Supabase client initialized successfully');
      _logger.i('URL: ${appConfig.supabaseUrl}');
    } catch (e) {
      _logger.e('❌ Failed to initialize Supabase client: $e');
      rethrow;
    }
  }

  /// Obtener el cliente Supabase
  SupabaseClient get client {
    if (!_isInitialized) {
      throw Exception(
        'Supabase client not initialized. Call initialize() first.',
      );
    }
    return _client;
  }

  /// Verificar si el cliente está inicializado
  bool get isInitialized => _isInitialized;

  // ========== MÉTODOS PARA TABLAS ESPECÍFICAS ==========

  /// Tabla: usuario
  SupabaseQueryBuilder get usuarios => _client.from('usuario');

  /// Tabla: tienda
  SupabaseQueryBuilder get tiendas => _client.from('tienda');

  /// Tabla: producto
  SupabaseQueryBuilder get productos => _client.from('producto');

  /// Tabla: categoria
  SupabaseQueryBuilder get categorias => _client.from('categoria');

  /// Tabla: plazoleta
  SupabaseQueryBuilder get plazoletas => _client.from('plazoleta');

  /// Tabla: imagen_tienda
  SupabaseQueryBuilder get imagenesTienda => _client.from('imagen_tienda');

  /// Tabla: imagen_productos
  SupabaseQueryBuilder get imagenesProducto => _client.from('imagen_productos');

  /// Tabla: imagen_plazoleta
  SupabaseQueryBuilder get imagenesPlazoleta =>
      _client.from('imagen_plazoleta');

  /// Tabla: valoracion_producto
  SupabaseQueryBuilder get valoraciones => _client.from('valoracion_producto');

  /// Tabla: horario
  SupabaseQueryBuilder get horarios => _client.from('horario');

  /// Tabla: organizacion
  SupabaseQueryBuilder get organizaciones => _client.from('organizacion');

  /// Tabla: etiqueta_tienda
  SupabaseQueryBuilder get etiquetasTienda => _client.from('etiqueta_tienda');

  /// Tabla: etiqueta_producto
  SupabaseQueryBuilder get etiquetasProducto =>
      _client.from('etiqueta_producto');

  /// Tabla: caracteristicas
  SupabaseQueryBuilder get caracteristicas => _client.from('caracteristicas');

  /// Tabla: contactos_empresa
  SupabaseQueryBuilder get contactosEmpresa =>
      _client.from('contactos_empresa');

  /// Tabla: redes_sociales
  SupabaseQueryBuilder get redesSociales => _client.from('redes_sociales');

  /// Tabla: miembros_organizacion
  SupabaseQueryBuilder get miembrosOrganizacion =>
      _client.from('miembros_organizacion');

  /// Tabla: notificacion
  SupabaseQueryBuilder get notificaciones => _client.from('notificacion');

  /// Tabla: interaccion
  SupabaseQueryBuilder get interacciones => _client.from('interaccion');

  /// Tabla: estadisticas_diarias
  SupabaseQueryBuilder get estadisticasDiarias =>
      _client.from('estadisticas_diarias');

  // ========== MÉTODOS DE CONSULTA COMUNES ==========

  /// Obtener usuario por Clerk ID
  Future<Map<String, dynamic>?> getUsuarioByClerkId(String clerkUserId) async {
    try {
      final response = await usuarios
          .select()
          .eq('clerk_user_id', clerkUserId)
          .limit(1);

      if (response.isEmpty) {
        _logger.e('Error getting user by Clerk ID: response is empty');
        return null;
      }

      return response.first;
    } catch (e) {
      _logger.e('Exception getting user by Clerk ID: $e');
      return null;
    }
  }

  /// Obtener usuario por Firebase ID
  Future<Map<String, dynamic>?> getUsuarioByFirebaseId(
    String firebaseUserId,
  ) async {
    try {
      final response = await usuarios
          .select()
          .eq('firebase_user_id', firebaseUserId)
          .limit(1);

      if (response.isEmpty) {
        _logger.d('User not found by Firebase ID: $firebaseUserId');
        return null;
      }

      return response.first;
    } catch (e) {
      _logger.e('Exception getting user by Firebase ID: $e');
      return null;
    }
  }

  /// Obtener usuario por email
  Future<Map<String, dynamic>?> getUsuarioByEmail(String email) async {
    try {
      final response = await usuarios.select().eq('email', email).limit(1);

      if (response.isEmpty) {
        _logger.d('User not found by email: $email');
        return null;
      }

      return response.first;
    } catch (e) {
      _logger.e('Exception getting user by email: $e');
      return null;
    }
  }

  /// Obtener tiendas con paginación
  Future<List<Map<String, dynamic>>> getTiendas({
    int page = 1,
    int limit = 20,
    String? categoriaId,
    bool? soloActivas = true,
  }) async {
    try {
      var query = tiendas.select().order('fecha_creacion', ascending: false);

      if (soloActivas == true) {
        // Aquí podrías agregar filtros si tienes campo 'activa'
      }

      if (categoriaId != null) {
        // Unir con productos para filtrar por categoría
        // Esto es un ejemplo, ajusta según tu esquema
      }

      // Paginación
      final from = (page - 1) * limit;
      final to = from + limit - 1;
      query = query.range(from, to);

      final response = await query;

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _logger.e('Exception getting tiendas: $e');
      return [];
    }
  }

  /// Obtener productos de una tienda
  Future<List<Map<String, dynamic>>> getProductosByTienda(
    int tiendaId, {
    int page = 1,
    int limit = 20,
    String? estado = 'publicado',
  }) async {
    try {
      var query = productos.select().eq('tienda_id', tiendaId);

      if (estado != null) {
        query = query.eq('estado_producto', estado);
      }

      // Aplicar orden y paginación directamente
      final response = await query
          .order('fecha_creacion', ascending: false)
          .range((page - 1) * limit, (page - 1) * limit + limit - 1);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _logger.e('Exception getting productos by tienda: $e');
      return [];
    }
  }

  /// Obtener imágenes de una entidad
  Future<List<Map<String, dynamic>>> getImagenesByEntity({
    required String entityType, // 'tienda', 'producto', 'plazoleta'
    required int entityId,
    String? tipoImagen,
  }) async {
    try {
      PostgrestFilterBuilder<dynamic> query;

      switch (entityType) {
        case 'tienda':
          query = imagenesTienda.select().eq('tienda_id', entityId);
          break;
        case 'producto':
          query = imagenesProducto.select().eq('id_producto', entityId);
          break;
        case 'plazoleta':
          query = imagenesPlazoleta.select().eq('id_ubicacion', entityId);
          break;
        default:
          throw Exception('Tipo de entidad no válido: $entityType');
      }

      if (tipoImagen != null) {
        query = query.eq('tipo_imagen', tipoImagen);
      }

      query = query.eq('activa', true);
      final response = await query.order('orden');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _logger.e('Exception getting imágenes: $e');
      return [];
    }
  }

  /// Crear o actualizar usuario desde cualquier proveedor (Clerk o Firebase)
  Future<Map<String, dynamic>?> syncUsuario({
    String? clerkUserId,
    String? firebaseUserId,
    required String email,
    required String nombreCompleto,
    String? telefono,
    String? avatarUrl,
  }) async {
    try {
      _logger.d(
        'syncUsuario iniciado - email: $email, nombre: $nombreCompleto, '
        'clerkUserId: $clerkUserId, firebaseUserId: $firebaseUserId',
      );
      // 1. Buscar por ID externo (prioridad)
      if (clerkUserId != null) {
        _logger.d('Buscando usuario por clerkUserId: $clerkUserId');
        final userByClerkId = await getUsuarioByClerkId(clerkUserId);
        if (userByClerkId != null) {
          _logger.d(
            'Usuario encontrado por clerkUserId: ${userByClerkId['id']}',
          );
          await _actualizarUltimoLogin(clerkUserId, null);
          return userByClerkId;
        } else {
          _logger.d('No se encontró usuario con clerkUserId: $clerkUserId');
        }
      }

      if (firebaseUserId != null) {
        _logger.d('Buscando usuario por firebaseUserId: $firebaseUserId');
        final userByFirebaseId = await getUsuarioByFirebaseId(firebaseUserId);
        if (userByFirebaseId != null) {
          _logger.d(
            'Usuario encontrado por firebaseUserId: ${userByFirebaseId['id']}',
          );
          await _actualizarUltimoLogin(null, firebaseUserId);
          return userByFirebaseId;
        } else {
          _logger.d(
            'No se encontró usuario con firebaseUserId: $firebaseUserId',
          );
        }
      }

      // 2. Buscar por email (fusión de cuentas)
      _logger.d('Buscando usuario por email: $email');
      final userByEmail = await getUsuarioByEmail(email);
      if (userByEmail != null) {
        _logger.d(
          'Usuario encontrado por email: ${userByEmail['id']} - '
          'Actualizando ID externo faltante',
        );
        // Actualizar el ID externo faltante y posiblemente el avatar
        await _actualizarIdExterno(
          userByEmail['id'] as int,
          clerkUserId,
          firebaseUserId,
        );
        // Actualizar avatar si se proporciona
        if (avatarUrl != null && avatarUrl.isNotEmpty) {
          _logger.d('Actualizando avatar para usuario ${userByEmail['id']}');
          await _actualizarAvatar(userByEmail['id'] as int, avatarUrl);
        }
        await _actualizarUltimoLogin(clerkUserId, firebaseUserId);
        _logger.d('Usuario fusionado exitosamente: ${userByEmail['id']}');
        return userByEmail;
      } else {
        _logger.d(
          'No se encontró usuario con email: $email - Creando nuevo usuario',
        );
      }

      // 3. Crear nuevo usuario
      _logger.d('Creando nuevo usuario para email: $email');
      final nuevoUsuario = await _crearUsuario(
        clerkUserId: clerkUserId,
        firebaseUserId: firebaseUserId,
        email: email,
        nombreCompleto: nombreCompleto,
        telefono: telefono,
        avatarUrl: avatarUrl,
      );
      if (nuevoUsuario != null) {
        _logger.d('Nuevo usuario creado exitosamente: ${nuevoUsuario['id']}');
      } else {
        _logger.e('Error al crear nuevo usuario para email: $email');
      }
      return nuevoUsuario;
    } catch (e) {
      _logger.e('Exception syncing user: $e');
      return null;
    }
  }

  /// Método privado para actualizar último login
  Future<void> _actualizarUltimoLogin(
    String? clerkUserId,
    String? firebaseUserId,
  ) async {
    try {
      final updates = {'ultimo_login': DateTime.now().toIso8601String()};

      if (clerkUserId != null) {
        await usuarios.update(updates).eq('clerk_user_id', clerkUserId);
      } else if (firebaseUserId != null) {
        await usuarios.update(updates).eq('firebase_user_id', firebaseUserId);
      }
    } catch (e) {
      _logger.e('Error actualizando último login: $e');
    }
  }

  /// Método privado para actualizar ID externo faltante
  Future<void> _actualizarIdExterno(
    int usuarioId,
    String? clerkUserId,
    String? firebaseUserId,
  ) async {
    try {
      final updates = <String, dynamic>{};
      if (clerkUserId != null) {
        updates['clerk_user_id'] = clerkUserId;
      }
      if (firebaseUserId != null) {
        updates['firebase_user_id'] = firebaseUserId;
      }

      if (updates.isNotEmpty) {
        await usuarios.update(updates).eq('id', usuarioId);
      }
    } catch (e) {
      _logger.e('Error actualizando ID externo: $e');
    }
  }

  /// Método privado para actualizar avatar
  Future<void> _actualizarAvatar(int usuarioId, String avatarUrl) async {
    try {
      if (avatarUrl.isEmpty) {
        _logger.d('URL de avatar vacía, omitiendo actualización');
        return;
      }

      await usuarios.update({'avatar_url': avatarUrl}).eq('id', usuarioId);
      _logger.d('Avatar actualizado exitosamente para usuario $usuarioId');
    } catch (e) {
      // Si es un error de columna no encontrada en el esquema, solo registramos warning
      if (e.toString().contains('avatar_url') &&
          e.toString().contains('schema cache')) {
        _logger.w(
          'Columna avatar_url no encontrada en esquema, omitiendo actualización de avatar',
        );
      } else {
        _logger.e('Error actualizando avatar: $e');
      }
    }
  }

  /// Método privado para crear nuevo usuario
  Future<Map<String, dynamic>?> _crearUsuario({
    String? clerkUserId,
    String? firebaseUserId,
    required String email,
    required String nombreCompleto,
    String? telefono,
    String? avatarUrl,
  }) async {
    try {
      _logger.d('Creando nuevo usuario para email: $email');

      // Construir datos base del usuario
      // Generar clerk_user_id si es nulo
      final String clerkUserIdValue;
      if (clerkUserId != null) {
        clerkUserIdValue = clerkUserId;
      } else if (firebaseUserId != null) {
        // Para usuarios de Firebase, generar un clerk_user_id basado en firebase_user_id
        clerkUserIdValue = 'firebase_$firebaseUserId';
      } else {
        // Caso extremo: ambos nulos, generar un ID único
        clerkUserIdValue = 'unknown_${DateTime.now().microsecondsSinceEpoch}';
      }

      // Generar firebase_user_id si es nulo
      final String firebaseUserIdValue;
      if (firebaseUserId != null) {
        firebaseUserIdValue = firebaseUserId;
      } else if (clerkUserId != null) {
        // Para usuarios de Clerk, generar un firebase_user_id basado en clerk_user_id
        firebaseUserIdValue = 'clerk_$clerkUserId';
      } else {
        // Caso extremo: ambos nulos, generar un ID único
        firebaseUserIdValue =
            'unknown_${DateTime.now().microsecondsSinceEpoch + 1}';
      }

      final userData = {
        'clerk_user_id': clerkUserIdValue,
        'firebase_user_id': firebaseUserIdValue,
        'nombre_completo': nombreCompleto,
        'email': email,
        'telefono': telefono ?? '',
        'fecha_registro': DateTime.now().toIso8601String(),
        'ultimo_login': DateTime.now().toIso8601String(),
        'perfil_publico': true,
        'estado_usuario': 'activo',
      };

      // Primero intentar con avatar_url si está presente y no está vacío
      if (avatarUrl != null && avatarUrl.isNotEmpty) {
        _logger.d('Intentando crear usuario con avatar_url: $avatarUrl');
        try {
          final userDataWithAvatar = Map<String, dynamic>.from(userData)
            ..['avatar_url'] = avatarUrl;
          final insertResponse = await usuarios.insert(userDataWithAvatar);
          _logger.d('Usuario creado exitosamente con avatar_url');
          return insertResponse as Map<String, dynamic>?;
        } catch (e) {
          // Si es error de columna no encontrada en el esquema, intentar sin avatar_url
          if (e.toString().contains('avatar_url') &&
              e.toString().contains('schema cache')) {
            _logger.w(
              'Columna avatar_url no encontrada en esquema, creando usuario sin avatar',
            );
            // Continuar para intentar sin avatar_url
          } else {
            // Otro tipo de error, relanzar
            _logger.e('Error creando usuario con avatar_url: $e');
            return null;
          }
        }
      }

      // Intentar sin avatar_url (ya sea porque no hay avatar o porque falló)
      _logger.d('Intentando crear usuario sin avatar_url');
      try {
        final insertResponse = await usuarios.insert(userData);
        _logger.d('Usuario creado exitosamente');
        return insertResponse as Map<String, dynamic>?;
      } catch (e) {
        _logger.e('Error creando usuario: $e');
        return null;
      }
    } catch (e) {
      _logger.e('Error inesperado en _crearUsuario: $e');
      return null;
    }
  }

  /// Crear o actualizar usuario desde Clerk
  Future<Map<String, dynamic>?> syncUsuarioFromClerk({
    required String clerkUserId,
    required String nombreCompleto,
    required String email,
    String? telefono,
    String? avatarUrl,
  }) async {
    return await syncUsuario(
      clerkUserId: clerkUserId,
      firebaseUserId: null,
      email: email,
      nombreCompleto: nombreCompleto,
      telefono: telefono,
      avatarUrl: avatarUrl,
    );
  }

  /// Registrar interacción
  Future<bool> registrarInteraccion({
    required String tipoInteraccion,
    int? productoId,
    int? tiendaId,
    String? sesionId,
    String? dispositivo,
    String? ipCliente,
  }) async {
    try {
      await interacciones.insert({
        'tipo_interaccion': tipoInteraccion,
        'producto_id': productoId,
        'tienda_id': tiendaId,
        'sesion_id': sesionId,
        'dispositivo': dispositivo,
        'ip_cliente': ipCliente,
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      _logger.e('Exception registering interaction: $e');
      return false;
    }
  }

  /// Obtener estadísticas resumidas
  Future<Map<String, dynamic>> getEstadisticasResumen() async {
    try {
      // Ejemplo: contar tiendas, productos, etc.
      final tiendasCount = await tiendas.select().count();
      final productosCount = await productos.select().count();
      final categoriasCount = await categorias.select().count();

      return {
        'total_tiendas': (tiendasCount is int) ? tiendasCount : 0,
        'total_productos': (productosCount is int) ? productosCount : 0,
        'total_categorias': (categoriasCount is int) ? categoriasCount : 0,
        'updated_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      _logger.e('Exception getting statistics: $e');
      return {
        'total_tiendas': 0,
        'total_productos': 0,
        'total_categorias': 0,
        'updated_at': DateTime.now().toIso8601String(),
        'error': e.toString(),
      };
    }
  }

  /// Verificar conexión con Supabase
  Future<bool> checkConnection() async {
    try {
      // Intentar una consulta simple
      await usuarios.select().count();
      return true;
    } catch (e) {
      _logger.e('Connection check failed: $e');
      return false;
    }
  }

  /// Cerrar sesión y limpiar
  Future<void> dispose() async {
    try {
      await _client.auth.signOut();
      _isInitialized = false;
      _logger.i('Supabase client disposed');
    } catch (e) {
      _logger.e('Error disposing Supabase client: $e');
    }
  }
}
