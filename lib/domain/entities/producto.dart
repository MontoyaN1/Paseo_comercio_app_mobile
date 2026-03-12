import 'package:equatable/equatable.dart';

import 'enums.dart';

/// Entidad de dominio para Producto - Basada en esquema DB real
class Producto extends Equatable {
  final int id;
  final DateTime fechaCreacion;
  final DateTime? fechaActualizacion;
  final int tiendaId;
  final int categoriaId;
  final String nombre;
  final String? descripcion;
  final double precioBase;
  final int cantidad;
  final double? calificacionPromedio;
  final int? totalValoracion;
  final EstadoProducto? estadoProducto;
  final int totalVisualizaciones;
  final int? totalClicksWhatsapp;
  final int? totalCompartidos;
  final int? totalClicksInstagram;
  final int? totalClicksFacebook;
  final DateTime? fechaUltimaInteraccion;
  final List<dynamic>? imagenes;

  const Producto({
    required this.id,
    required this.fechaCreacion,
    this.fechaActualizacion,
    required this.tiendaId,
    required this.categoriaId,
    required this.nombre,
    this.descripcion,
    required this.precioBase,
    required this.cantidad,
    this.calificacionPromedio,
    this.totalValoracion,
    this.estadoProducto,
    required this.totalVisualizaciones,
    this.totalClicksWhatsapp,
    this.totalCompartidos,
    this.totalClicksInstagram,
    this.totalClicksFacebook,
    this.fechaUltimaInteraccion,
    this.imagenes,
  });

  /// Factory constructor para crear Producto desde JSON
  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: (json['id'] as int?) ?? 0,
      fechaCreacion:
          json['fecha_creacion'] != null
              ? DateTime.parse(json['fecha_creacion'] as String)
              : DateTime.now(),
      fechaActualizacion:
          json['fecha_actualizacion'] != null
              ? DateTime.parse(json['fecha_actualizacion'] as String)
              : null,
      tiendaId: (json['tienda_id'] as int?) ?? 0,
      categoriaId: (json['categoria_id'] as int?) ?? 0,
      nombre: (json['nombre'] as String?) ?? '',
      descripcion: json['descripcion'] as String?,
      precioBase: (json['precio_base'] as num?)?.toDouble() ?? 0.0,
      cantidad: (json['cantidad'] as int?) ?? 0,
      calificacionPromedio:
          json['calificacion_promedio'] != null
              ? (json['calificacion_promedio'] as num).toDouble()
              : null,
      totalValoracion: (json['total_valoracion'] as int?),
      estadoProducto:
          json['estado_producto'] != null
              ? EstadoProducto.fromString(json['estado_producto'] as String)
              : null,
      totalVisualizaciones: (json['total_visualizaciones'] as int?) ?? 0,
      totalClicksWhatsapp: (json['total_clicks_whatsapp'] as int?),
      totalCompartidos: (json['total_compartidos'] as int?),
      totalClicksInstagram: (json['total_clicks_instagram'] as int?),
      totalClicksFacebook: (json['total_clicks_facebook'] as int?),
      fechaUltimaInteraccion:
          json['fecha_ultima_interaccion'] != null
              ? DateTime.parse(json['fecha_ultima_interaccion'] as String)
              : null,
      imagenes: json['imagen_productos'] as List<dynamic>?,
    );
  }

  /// Convertir Producto a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'fecha_actualizacion': fechaActualizacion?.toIso8601String(),
      'tienda_id': tiendaId,
      'categoria_id': categoriaId,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio_base': precioBase,
      'cantidad': cantidad,
      'calificacion_promedio': calificacionPromedio,
      'total_valoracion': totalValoracion,
      'estado_producto': estadoProducto?.toString(),
      'total_visualizaciones': totalVisualizaciones,
      'total_clicks_whatsapp': totalClicksWhatsapp,
      'total_compartidos': totalCompartidos,
      'total_clicks_instagram': totalClicksInstagram,
      'total_clicks_facebook': totalClicksFacebook,
      'fecha_ultima_interaccion': fechaUltimaInteraccion?.toIso8601String(),
      'imagen_productos': imagenes,
    };
  }

  Producto copyWith({
    int? id,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
    int? tiendaId,
    int? categoriaId,
    String? nombre,
    String? descripcion,
    double? precioBase,
    int? cantidad,
    double? calificacionPromedio,
    int? totalValoracion,
    EstadoProducto? estadoProducto,
    int? totalVisualizaciones,
    int? totalClicksWhatsapp,
    int? totalCompartidos,
    int? totalClicksInstagram,
    int? totalClicksFacebook,
    DateTime? fechaUltimaInteraccion,
    List<dynamic>? imagenes,
  }) {
    return Producto(
      id: id ?? this.id,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      tiendaId: tiendaId ?? this.tiendaId,
      categoriaId: categoriaId ?? this.categoriaId,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      precioBase: precioBase ?? this.precioBase,
      cantidad: cantidad ?? this.cantidad,
      calificacionPromedio: calificacionPromedio ?? this.calificacionPromedio,
      totalValoracion: totalValoracion ?? this.totalValoracion,
      estadoProducto: estadoProducto ?? this.estadoProducto,
      totalVisualizaciones: totalVisualizaciones ?? this.totalVisualizaciones,
      totalClicksWhatsapp: totalClicksWhatsapp ?? this.totalClicksWhatsapp,
      totalCompartidos: totalCompartidos ?? this.totalCompartidos,
      totalClicksInstagram: totalClicksInstagram ?? this.totalClicksInstagram,
      totalClicksFacebook: totalClicksFacebook ?? this.totalClicksFacebook,
      fechaUltimaInteraccion:
          fechaUltimaInteraccion ?? this.fechaUltimaInteraccion,
      imagenes: imagenes ?? this.imagenes,
    );
  }

  @override
  List<Object?> get props => [
    id,
    fechaCreacion,
    fechaActualizacion,
    tiendaId,
    categoriaId,
    nombre,
    descripcion,
    precioBase,
    cantidad,
    calificacionPromedio,
    totalValoracion,
    estadoProducto,
    totalVisualizaciones,
    totalClicksWhatsapp,
    totalCompartidos,
    totalClicksInstagram,
    totalClicksFacebook,
    fechaUltimaInteraccion,
    imagenes,
  ];

  @override
  bool get stringify => true;

  // Métodos de utilidad
  bool get estaPublicado => estadoProducto == EstadoProducto.publicado;
  bool get estaAgotado => estadoProducto == EstadoProducto.agotado;
  bool get estaEliminado => estadoProducto == EstadoProducto.eliminado;
  bool get estaInactivo => estadoProducto == EstadoProducto.inactivo;
  bool get estaActivo =>
      estaPublicado ||
      estaAgotado; // Productos agotados siguen siendo visibles pero no disponibles para compra
  bool get tieneStock => cantidad > 0;
  bool get sinStock => cantidad <= 0;
  bool get stockBajo => cantidad < 10;

  // Para compatibilidad con código existente
  String get nombreProducto => nombre;
  double get precio => precioBase;
  int get stockDisponible => cantidad;
  double? get precioOferta => null; // No existe en DB
  bool get enOferta => false; // No existe en DB
  bool get destacado => false; // No existe en DB
  int get totalValoraciones => totalValoracion ?? 0;

  double? get porcentajeDescuento {
    // No hay precio_oferta en DB
    return null;
  }

  bool get ofertaVigente => false;

  // Métodos para manejo de imágenes
  String? get primeraImagenUrl {
    if (imagenes == null || imagenes!.isEmpty) return null;

    final primeraImagen = imagenes!.first;
    if (primeraImagen is Map<String, dynamic>) {
      return primeraImagen['url_imagen'] as String?;
    }
    return null;
  }

  List<String> get todasImagenesUrls {
    final urls = <String>[];
    if (imagenes == null) return urls;

    for (final imagen in imagenes!) {
      if (imagen is Map<String, dynamic>) {
        final url = imagen['url_imagen'] as String?;
        if (url != null && url.isNotEmpty) {
          urls.add(url);
        }
      }
    }
    return urls;
  }

  // Métodos de popularidad
  bool get esPopular =>
      (totalVisualizaciones > 100) || (totalClicksWhatsapp ?? 0) > 50;
  bool get esMuyPopular =>
      (totalVisualizaciones > 500) || (totalClicksWhatsapp ?? 0) > 200;

  int get indicePopularidad {
    var indice = totalVisualizaciones;
    indice += (totalClicksWhatsapp ?? 0) * 2;
    indice += (totalCompartidos ?? 0) * 3;
    indice += (totalClicksInstagram ?? 0) + (totalClicksFacebook ?? 0);
    return indice;
  }

  // Métodos para estadísticas
  Map<String, int> get estadisticasInteraccion => {
    'visualizaciones': totalVisualizaciones,
    'clicks_whatsapp': totalClicksWhatsapp ?? 0,
    'compartidos': totalCompartidos ?? 0,
    'clicks_instagram': totalClicksInstagram ?? 0,
    'clicks_facebook': totalClicksFacebook ?? 0,
  };

  int get totalInteracciones =>
      totalVisualizaciones +
      (totalClicksWhatsapp ?? 0) +
      (totalCompartidos ?? 0) +
      (totalClicksInstagram ?? 0) +
      (totalClicksFacebook ?? 0);

  // Para compatibilidad con ProductoCard
  bool get isInStock => tieneStock;
  bool get isProductoAvailable => estaPublicado && tieneStock;

  String get resumen {
    if (descripcion != null && descripcion!.isNotEmpty) {
      final maxLength = 100;
      if (descripcion!.length > maxLength) {
        return '${descripcion!.substring(0, maxLength)}...';
      }
      return descripcion!;
    }
    return 'Sin descripción';
  }

  bool get tieneBuenaCalificacion =>
      calificacionPromedio != null && calificacionPromedio! >= 4.0;

  bool get esNuevo {
    final now = DateTime.now();
    final diferencia = now.difference(fechaCreacion);
    return diferencia.inDays < 30;
  }

  // Métodos para formatos específicos
  String get precioFormateado => '\$${precioBase.toStringAsFixed(2)}';
  String get stockInfo => '$cantidad unidades';
}
