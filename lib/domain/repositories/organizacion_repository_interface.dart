// lib/domain/repositories/organizacion_repository_interface.dart

import '../entities/organizacion.dart';
import '../entities/enums.dart';

/// Interfaz para el repositorio de organizaciones
abstract class OrganizacionRepositoryInterface {
  // ==============================================
  // MÉTODOS DE CONSULTA
  // ==============================================

  /// Obtener todas las organizaciones con paginación
  Future<List<Organizacion>> getOrganizaciones({
    int page = 1,
    int limit = 20,
    TipoOrganizacion? tipo,
    bool? soloActivas,
    String? sortBy,
    bool? ascending,
  });

  /// Obtener organización por ID
  Future<Organizacion> getOrganizacionById(int id);

  /// Buscar organizaciones por query
  Future<List<Organizacion>> searchOrganizaciones(String query);

  /// Obtener organizaciones por anfitrión (usuario)
  Future<List<Organizacion>> getOrganizacionesByAnfitrionId(int anfitrionId);

  /// Obtener organizaciones por tipo
  Future<List<Organizacion>> getOrganizacionesByTipo(TipoOrganizacion tipo);

  /// Obtener organizaciones populares (más visitadas)
  Future<List<Organizacion>> getOrganizacionesPopulares({int limit = 10});

  /// Obtener organizaciones activas recientemente
  Future<List<Organizacion>> getOrganizacionesRecientes({int limit = 10});

  // ==============================================
  // MÉTODOS DE GESTIÓN DE MIEMBROS
  // ==============================================

  /// Obtener miembros de una organización
  Future<List<Map<String, dynamic>>> getMiembrosByOrganizacionId(
    int organizacionId, {
    int page = 1,
    int limit = 20,
  });

  /// Unirse a una organización
  Future<void> joinOrganizacion({
    required int organizacionId,
    required int usuarioId,
    required String email,
    required String nombre,
  });

  /// Salir de una organización
  Future<void> leaveOrganizacion({
    required int organizacionId,
    required int usuarioId,
  });

  /// Verificar si usuario es miembro de organización
  Future<bool> isUsuarioMiembro({
    required int organizacionId,
    required int usuarioId,
  });

  /// Obtener organizaciones del usuario actual
  Future<List<Organizacion>> getOrganizacionesByUsuarioId(int usuarioId);

  // ==============================================
  // MÉTODOS DE GESTIÓN DE TIENDAS
  // ==============================================

  /// Obtener tiendas de una organización
  Future<List<Map<String, dynamic>>> getTiendasByOrganizacionId(
    int organizacionId, {
    int page = 1,
    int limit = 10,
  });

  /// Agregar tienda a organización
  Future<void> addTiendaToOrganizacion({
    required int organizacionId,
    required int tiendaId,
  });

  /// Remover tienda de organización
  Future<void> removeTiendaFromOrganizacion({
    required int organizacionId,
    required int tiendaId,
  });

  /// Verificar si tienda pertenece a organización
  Future<bool> isTiendaInOrganizacion({
    required int organizacionId,
    required int tiendaId,
  });

  // ==============================================
  // MÉTODOS CRUD
  // ==============================================

  /// Crear nueva organización
  Future<Organizacion> createOrganizacion({
    required String nombre,
    String? descripcion,
    required TipoOrganizacion tipo,
    required String emailAnfitrion,
    required int anfitrionId,
    Map<String, dynamic>? metadata,
  });

  /// Actualizar organización existente
  Future<Organizacion> updateOrganizacion({
    required int id,
    String? nombre,
    String? descripcion,
    TipoOrganizacion? tipo,
    String? emailAnfitrion,
    Map<String, dynamic>? metadata,
  });

  /// Eliminar organización
  Future<void> deleteOrganizacion(int id);

  // ==============================================
  // MÉTODOS DE ESTADÍSTICAS
  // ==============================================

  /// Obtener estadísticas de una organización
  Future<Map<String, dynamic>> getOrganizacionStats(
    int organizacionId, {
    DateTime? desde,
    DateTime? hasta,
  });

  /// Obtener estadísticas globales de organizaciones
  Future<Map<String, dynamic>> getGlobalOrganizacionStats();

  /// Incrementar contador de visitas
  Future<void> incrementVisitas(int organizacionId);

  /// Marcar organización como vista
  Future<void> markAsViewed(int organizacionId);

  // ==============================================
  // MÉTODOS DE VALIDACIÓN
  // ==============================================

  /// Verificar si nombre de organización está disponible
  Future<bool> isNombreDisponible(String nombre);

  /// Verificar si email de anfitrión es válido
  Future<bool> isValidEmailAnfitrion(String email);

  /// Validar datos de organización antes de crear/actualizar
  Future<Map<String, dynamic>> validateOrganizacionData({
    String? nombre,
    String? emailAnfitrion,
    TipoOrganizacion? tipo,
  });

  // ==============================================
  // MÉTODOS DE CACHE Y SINCRONIZACIÓN
  // ==============================================

  /// Sincronizar organizaciones con servidor
  Future<void> syncOrganizaciones();

  /// Limpiar cache local de organizaciones
  Future<void> clearCache();

  /// Verificar si hay datos en cache
  Future<bool> hasCachedData();

  /// Obtener timestamp de última sincronización
  Future<DateTime?> getLastSyncTimestamp();
}
