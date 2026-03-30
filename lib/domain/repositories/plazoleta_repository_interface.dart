// lib/domain/repositories/plazoleta_repository_interface.dart

import '../entities/plazoleta.dart';
import '../entities/imagen_base.dart';
import '../entities/producto.dart';
import '../entities/tienda.dart';
import '../entities/enums.dart';

/// Interfaz del repositorio para manejar operaciones de plazoletas
abstract class PlazoletaRepositoryInterface {
  // ========== OPERACIONES BÁSICAS DE PLAZOLETAS ==========

  /// Obtener todas las plazoletas activas
  Future<List<Plazoleta>> getPlazoletasActivas({
    int? page,
    int? limit,
    String? search,
    String? piso,
    String? sector,
    bool? tieneZonaComida,
    bool? tieneEstacionamiento,
  });

  /// Obtener una plazoleta por ID
  Future<Plazoleta> getPlazoletaById(int id);

  /// Obtener una plazoleta por slug (para deep links)
  Future<Plazoleta?> getPlazoletaBySlug(String slug);

  /// Obtener plazoletas por IDs
  Future<List<Plazoleta>> getPlazoletasByIds(List<int> ids);

  /// Obtener plazoletas populares (más visitadas)
  Future<List<Plazoleta>> getPlazoletasPopulares({int? limit});

  /// Obtener plazoletas con disponibilidad (no llenas)
  Future<List<Plazoleta>> getPlazoletasDisponibles({int? page, int? limit});

  /// Buscar plazoletas por término
  Future<List<Plazoleta>> searchPlazoletas(String query);

  // ========== IMÁGENES DE PLAZOLETAS ==========

  /// Obtener imágenes de una plazoleta
  Future<List<ImagenBase>> getImagenesPlazoleta(
    int plazoletaId, {
    TipoImagen? tipoImagen,
    bool? soloActivas,
  });

  /// Obtener imagen principal de una plazoleta
  Future<ImagenBase?> getImagenPrincipalPlazoleta(int plazoletaId);

  /// Obtener imágenes por tipo
  Future<List<ImagenBase>> getImagenesPlazoletaPorTipo(
    int plazoletaId,
    TipoImagen tipoImagen,
  );

  /// Obtener imágenes principales para múltiples plazoletas
  Future<Map<int, ImagenBase?>> getImagenesPrincipalesPlazoletas(
    List<int> plazoletaIds,
  );

  // ========== PRODUCTOS RELACIONADOS CON PLAZOLETAS ==========

  /// Obtener productos por categoría de plazoleta
  Future<List<Producto>> getProductosPorPlazoleta(
    int plazoletaId, {
    int? page,
    int? limit,
    String? search,
    double? precioMin,
    double? precioMax,
    bool? soloDisponibles,
  });

  /// Obtener productos destacados de una plazoleta
  Future<List<Producto>> getProductosDestacadosPlazoleta(
    int plazoletaId, {
    int? limit,
  });

  /// Obtener productos por categorías de una plazoleta
  Future<Map<String, List<Producto>>> getProductosPorCategoriasPlazoleta(
    int plazoletaId, {
    int? productosPorCategoria,
  });

  // ========== TIENDAS RELACIONADAS CON PLAZOLETAS ==========

  /// Obtener tiendas de una plazoleta
  Future<List<Tienda>> getTiendasPlazoleta(
    int plazoletaId, {
    int? page,
    int? limit,
    String? search,
    bool? soloAbiertas,
  });

  /// Obtener tiendas destacadas de una plazoleta
  Future<List<Tienda>> getTiendasDestacadasPlazoleta(
    int plazoletaId, {
    int? limit,
  });

  /// Obtener tiendas por categoría en una plazoleta
  Future<Map<String, List<Tienda>>> getTiendasPorCategoriaPlazoleta(
    int plazoletaId, {
    int? tiendasPorCategoria,
  });

  // ========== ESTADÍSTICAS Y MÉTRICAS ==========

  /// Incrementar contador de visitas de una plazoleta
  Future<void> incrementarVisitasPlazoleta(int plazoletaId);

  /// Obtener estadísticas de una plazoleta
  Future<Map<String, dynamic>> getEstadisticasPlazoleta(int plazoletaId);

  /// Obtener nivel de ocupación de una plazoleta
  Future<double> getNivelOcupacionPlazoleta(int plazoletaId);

  // ========== FILTROS Y BÚSQUEDAS AVANZADAS ==========

  /// Filtrar plazoletas por características
  Future<List<Plazoleta>> filtrarPlazoletas({
    List<String>? pisos,
    List<String>? sectores,
    List<String>? servicios,
    bool? tieneAccesoDiscapacitados,
    bool? tieneEstacionamiento,
    bool? tieneZonaDescanso,
    bool? tieneZonaComida,
    double? latitud,
    double? longitud,
    double? radioKm,
    int? capacidadMinima,
    int? capacidadMaxima,
    bool? soloDisponibles,
  });

  /// Obtener plazoletas cercanas a una ubicación
  Future<List<Plazoleta>> getPlazoletasCercanas({
    required double latitud,
    required double longitud,
    double? radioKm,
    int? limit,
  });

  // ========== CACHÉ Y SINCRONIZACIÓN ==========

  /// Sincronizar datos de plazoletas
  Future<void> sincronizarPlazoletas();

  /// Limpiar caché de plazoletas
  Future<void> limpiarCachePlazoletas();

  /// Verificar si hay datos en caché
  Future<bool> tieneCachePlazoletas();

  /// Obtener fecha de última actualización
  Future<DateTime?> getUltimaActualizacionPlazoletas();
}
