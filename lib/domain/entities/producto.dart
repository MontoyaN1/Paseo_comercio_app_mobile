// lib/domain/entities/producto.dart

import 'package:equatable/equatable.dart';

import 'enums.dart';

/// Entidad de dominio para Producto
class Producto extends Equatable {
  final int id;
  final int tiendaId;
  final String nombreProducto;
  final String descripcion;
  final double precio;
  final String? moneda;
  final int? categoriaId;
  final EstadoProducto estadoProducto;
  final int stockDisponible;
  final int? stockMinimo;
  final int? stockMaximo;
  final Map<String, dynamic>? caracteristicas;
  final Map<String, dynamic>? etiquetas;
  final double? calificacionPromedio;
  final int totalValoraciones;
  final int totalVisualizaciones;
  final int totalCompartidos;
  final int totalFavoritos;
  final DateTime fechaCreacion;
  final DateTime? fechaActualizacion;
  final DateTime? fechaPublicacion;
  final DateTime? fechaEliminacion;
  final bool destacado;
  final bool enOferta;
  final double? precioOferta;
  final DateTime? fechaInicioOferta;
  final DateTime? fechaFinOferta;
  final String? sku;
  final String? codigoBarras;
  final double? peso;
  final String? unidadPeso;
  final double? dimensionAlto;
  final double? dimensionAncho;
  final double? dimensionProfundidad;
  final String? unidadDimension;
  final String? material;
  final String? color;
  final String? marca;
  final String? modelo;
  final int? garantiaMeses;
  final String? instruccionesUso;
  final String? cuidados;
  final String? origen;
  final bool? esEcoFriendly;
  final bool? esReciclable;
  final bool? esBiodegradable;
  final String? certificaciones;

  const Producto({
    required this.id,
    required this.tiendaId,
    required this.nombreProducto,
    required this.descripcion,
    required this.precio,
    this.moneda = 'USD',
    this.categoriaId,
    required this.estadoProducto,
    required this.stockDisponible,
    this.stockMinimo,
    this.stockMaximo,
    this.caracteristicas,
    this.etiquetas,
    this.calificacionPromedio,
    this.totalValoraciones = 0,
    this.totalVisualizaciones = 0,
    this.totalCompartidos = 0,
    this.totalFavoritos = 0,
    required this.fechaCreacion,
    this.fechaActualizacion,
    this.fechaPublicacion,
    this.fechaEliminacion,
    this.destacado = false,
    this.enOferta = false,
    this.precioOferta,
    this.fechaInicioOferta,
    this.fechaFinOferta,
    this.sku,
    this.codigoBarras,
    this.peso,
    this.unidadPeso,
    this.dimensionAlto,
    this.dimensionAncho,
    this.dimensionProfundidad,
    this.unidadDimension,
    this.material,
    this.color,
    this.marca,
    this.modelo,
    this.garantiaMeses,
    this.instruccionesUso,
    this.cuidados,
    this.origen,
    this.esEcoFriendly,
    this.esReciclable,
    this.esBiodegradable,
    this.certificaciones,
  });

  /// Factory constructor para crear Producto desde JSON
  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: (json['id'] as int?) ?? 0,
      tiendaId: (json['tienda_id'] as int?) ?? 0,
      nombreProducto: (json['nombre_producto'] as String?) ?? '',
      descripcion: (json['descripcion'] as String?) ?? '',
      precio: (json['precio'] as num?)?.toDouble() ?? 0.0,
      moneda: json['moneda'] as String?,
      categoriaId: json['categoria_id'] as int?,
      estadoProducto: EstadoProducto.fromString(
        (json['estado_producto'] as String?) ?? 'publicado',
      ),
      stockDisponible: (json['stock_disponible'] as int?) ?? 0,
      stockMinimo: json['stock_minimo'] as int?,
      stockMaximo: json['stock_maximo'] as int?,
      caracteristicas:
          json['caracteristicas'] != null
              ? Map<String, dynamic>.from(json['caracteristicas'] as Map)
              : null,
      etiquetas:
          json['etiquetas'] != null
              ? Map<String, dynamic>.from(json['etiquetas'] as Map)
              : null,
      calificacionPromedio:
          json['calificacion_promedio'] != null
              ? (json['calificacion_promedio'] as num).toDouble()
              : null,
      totalValoraciones: json['total_valoraciones'] as int? ?? 0,
      totalVisualizaciones: json['total_visualizaciones'] as int? ?? 0,
      totalCompartidos: json['total_compartidos'] as int? ?? 0,
      totalFavoritos: json['total_favoritos'] as int? ?? 0,
      fechaCreacion:
          json['fecha_creacion'] != null
              ? DateTime.parse(json['fecha_creacion'] as String)
              : DateTime.now(),
      fechaActualizacion:
          json['fecha_actualizacion'] != null
              ? DateTime.parse(json['fecha_actualizacion'] as String)
              : null,
      fechaPublicacion:
          json['fecha_publicacion'] != null
              ? DateTime.parse(json['fecha_publicacion'] as String)
              : null,
      fechaEliminacion:
          json['fecha_eliminacion'] != null
              ? DateTime.parse(json['fecha_eliminacion'] as String)
              : null,
      destacado: json['destacado'] as bool? ?? false,
      enOferta: json['en_oferta'] as bool? ?? false,
      precioOferta:
          json['precio_oferta'] != null
              ? (json['precio_oferta'] as num).toDouble()
              : null,
      fechaInicioOferta:
          json['fecha_inicio_oferta'] != null
              ? DateTime.parse(json['fecha_inicio_oferta'] as String)
              : null,
      fechaFinOferta:
          json['fecha_fin_oferta'] != null
              ? DateTime.parse(json['fecha_fin_oferta'] as String)
              : null,
      sku: json['sku'] as String?,
      codigoBarras: json['codigo_barras'] as String?,
      peso: json['peso'] != null ? (json['peso'] as num).toDouble() : null,
      unidadPeso: json['unidad_peso'] as String?,
      dimensionAlto:
          json['dimension_alto'] != null
              ? (json['dimension_alto'] as num).toDouble()
              : null,
      dimensionAncho:
          json['dimension_ancho'] != null
              ? (json['dimension_ancho'] as num).toDouble()
              : null,
      dimensionProfundidad:
          json['dimension_profundidad'] != null
              ? (json['dimension_profundidad'] as num).toDouble()
              : null,
      unidadDimension: json['unidad_dimension'] as String?,
      material: json['material'] as String?,
      color: json['color'] as String?,
      marca: json['marca'] as String?,
      modelo: json['modelo'] as String?,
      garantiaMeses: json['garantia_meses'] as int?,
      instruccionesUso: json['instrucciones_uso'] as String?,
      cuidados: json['cuidados'] as String?,
      origen: json['origen'] as String?,
      esEcoFriendly: json['es_eco_friendly'] as bool?,
      esReciclable: json['es_reciclable'] as bool?,
      esBiodegradable: json['es_biodegradable'] as bool?,
      certificaciones: json['certificaciones'] as String?,
    );
  }

  /// Convertir Producto a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tienda_id': tiendaId,
      'nombre_producto': nombreProducto,
      'descripcion': descripcion,
      'precio': precio,
      'moneda': moneda,
      'categoria_id': categoriaId,
      'estado_producto': estadoProducto.toString(),
      'stock_disponible': stockDisponible,
      'stock_minimo': stockMinimo,
      'stock_maximo': stockMaximo,
      'caracteristicas': caracteristicas,
      'etiquetas': etiquetas,
      'calificacion_promedio': calificacionPromedio,
      'total_valoraciones': totalValoraciones,
      'total_visualizaciones': totalVisualizaciones,
      'total_compartidos': totalCompartidos,
      'total_favoritos': totalFavoritos,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'fecha_actualizacion': fechaActualizacion?.toIso8601String(),
      'fecha_publicacion': fechaPublicacion?.toIso8601String(),
      'fecha_eliminacion': fechaEliminacion?.toIso8601String(),
      'destacado': destacado,
      'en_oferta': enOferta,
      'precio_oferta': precioOferta,
      'fecha_inicio_oferta': fechaInicioOferta?.toIso8601String(),
      'fecha_fin_oferta': fechaFinOferta?.toIso8601String(),
      'sku': sku,
      'codigo_barras': codigoBarras,
      'peso': peso,
      'unidad_peso': unidadPeso,
      'dimension_alto': dimensionAlto,
      'dimension_ancho': dimensionAncho,
      'dimension_profundidad': dimensionProfundidad,
      'unidad_dimension': unidadDimension,
      'material': material,
      'color': color,
      'marca': marca,
      'modelo': modelo,
      'garantia_meses': garantiaMeses,
      'instrucciones_uso': instruccionesUso,
      'cuidados': cuidados,
      'origen': origen,
      'es_eco_friendly': esEcoFriendly,
      'es_reciclable': esReciclable,
      'es_biodegradable': esBiodegradable,
      'certificaciones': certificaciones,
    };
  }

  /// Crear copia del Producto con valores actualizados
  Producto copyWith({
    int? id,
    int? tiendaId,
    String? nombreProducto,
    String? descripcion,
    double? precio,
    String? moneda,
    int? categoriaId,
    EstadoProducto? estadoProducto,
    int? stockDisponible,
    int? stockMinimo,
    int? stockMaximo,
    Map<String, dynamic>? caracteristicas,
    Map<String, dynamic>? etiquetas,
    double? calificacionPromedio,
    int? totalValoraciones,
    int? totalVisualizaciones,
    int? totalCompartidos,
    int? totalFavoritos,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
    DateTime? fechaPublicacion,
    DateTime? fechaEliminacion,
    bool? destacado,
    bool? enOferta,
    double? precioOferta,
    DateTime? fechaInicioOferta,
    DateTime? fechaFinOferta,
    String? sku,
    String? codigoBarras,
    double? peso,
    String? unidadPeso,
    double? dimensionAlto,
    double? dimensionAncho,
    double? dimensionProfundidad,
    String? unidadDimension,
    String? material,
    String? color,
    String? marca,
    String? modelo,
    int? garantiaMeses,
    String? instruccionesUso,
    String? cuidados,
    String? origen,
    bool? esEcoFriendly,
    bool? esReciclable,
    bool? esBiodegradable,
    String? certificaciones,
  }) {
    return Producto(
      id: id ?? this.id,
      tiendaId: tiendaId ?? this.tiendaId,
      nombreProducto: nombreProducto ?? this.nombreProducto,
      descripcion: descripcion ?? this.descripcion,
      precio: precio ?? this.precio,
      moneda: moneda ?? this.moneda,
      categoriaId: categoriaId ?? this.categoriaId,
      estadoProducto: estadoProducto ?? this.estadoProducto,
      stockDisponible: stockDisponible ?? this.stockDisponible,
      stockMinimo: stockMinimo ?? this.stockMinimo,
      stockMaximo: stockMaximo ?? this.stockMaximo,
      caracteristicas: caracteristicas ?? this.caracteristicas,
      etiquetas: etiquetas ?? this.etiquetas,
      calificacionPromedio: calificacionPromedio ?? this.calificacionPromedio,
      totalValoraciones: totalValoraciones ?? this.totalValoraciones,
      totalVisualizaciones: totalVisualizaciones ?? this.totalVisualizaciones,
      totalCompartidos: totalCompartidos ?? this.totalCompartidos,
      totalFavoritos: totalFavoritos ?? this.totalFavoritos,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      fechaPublicacion: fechaPublicacion ?? this.fechaPublicacion,
      fechaEliminacion: fechaEliminacion ?? this.fechaEliminacion,
      destacado: destacado ?? this.destacado,
      enOferta: enOferta ?? this.enOferta,
      precioOferta: precioOferta ?? this.precioOferta,
      fechaInicioOferta: fechaInicioOferta ?? this.fechaInicioOferta,
      fechaFinOferta: fechaFinOferta ?? this.fechaFinOferta,
      sku: sku ?? this.sku,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      peso: peso ?? this.peso,
      unidadPeso: unidadPeso ?? this.unidadPeso,
      dimensionAlto: dimensionAlto ?? this.dimensionAlto,
      dimensionAncho: dimensionAncho ?? this.dimensionAncho,
      dimensionProfundidad: dimensionProfundidad ?? this.dimensionProfundidad,
      unidadDimension: unidadDimension ?? this.unidadDimension,
      material: material ?? this.material,
      color: color ?? this.color,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      garantiaMeses: garantiaMeses ?? this.garantiaMeses,
      instruccionesUso: instruccionesUso ?? this.instruccionesUso,
      cuidados: cuidados ?? this.cuidados,
      origen: origen ?? this.origen,
      esEcoFriendly: esEcoFriendly ?? this.esEcoFriendly,
      esReciclable: esReciclable ?? this.esReciclable,
      esBiodegradable: esBiodegradable ?? this.esBiodegradable,
      certificaciones: certificaciones ?? this.certificaciones,
    );
  }

  @override
  List<Object?> get props => [
    id,
    tiendaId,
    nombreProducto,
    descripcion,
    precio,
    moneda,
    categoriaId,
    estadoProducto,
    stockDisponible,
    stockMinimo,
    stockMaximo,
    caracteristicas,
    etiquetas,
    calificacionPromedio,
    totalValoraciones,
    totalVisualizaciones,
    totalCompartidos,
    totalFavoritos,
    fechaCreacion,
    fechaActualizacion,
    fechaPublicacion,
    fechaEliminacion,
    destacado,
    enOferta,
    precioOferta,
    fechaInicioOferta,
    fechaFinOferta,
    sku,
    codigoBarras,
    peso,
    unidadPeso,
    dimensionAlto,
    dimensionAncho,
    dimensionProfundidad,
    unidadDimension,
    material,
    color,
    marca,
    modelo,
    garantiaMeses,
    instruccionesUso,
    cuidados,
    origen,
    esEcoFriendly,
    esReciclable,
    esBiodegradable,
    certificaciones,
  ];

  @override
  bool get stringify => true;

  // ========== MÉTODOS DE UTILIDAD ==========

  /// Verificar si el producto está publicado
  bool get estaPublicado => estadoProducto == EstadoProducto.publicado;

  /// Verificar si el producto está agotado
  bool get estaAgotado => estadoProducto == EstadoProducto.agotado;

  /// Verificar si el producto está activo (publicado o agotado)
  bool get estaActivo => estaPublicado || estaAgotado;

  /// Verificar si hay stock disponible
  bool get tieneStock => stockDisponible > 0;

  /// Verificar si el stock es bajo
  bool get stockBajo => stockMinimo != null && stockDisponible <= stockMinimo!;

  /// Obtener precio actual (oferta o normal)
  double get precioActual =>
      enOferta && precioOferta != null ? precioOferta! : precio;

  /// Calcular porcentaje de descuento
  double? get porcentajeDescuento {
    if (!enOferta || precioOferta == null) return null;
    return ((precio - precioOferta!) / precio) * 100;
  }

  /// Verificar si la oferta está vigente
  bool get ofertaVigente {
    if (!enOferta) return false;
    final now = DateTime.now();
    if (fechaInicioOferta != null && now.isBefore(fechaInicioOferta!))
      return false;
    if (fechaFinOferta != null && now.isAfter(fechaFinOferta!)) return false;
    return true;
  }

  /// Verificar si el producto es ecológico
  bool get esEcologico =>
      esEcoFriendly == true || esReciclable == true || esBiodegradable == true;

  /// Obtener lista de características como texto
  String? get caracteristicasTexto {
    if (caracteristicas == null || caracteristicas!.isEmpty) return null;
    return caracteristicas!.entries
        .map((e) => '${e.key}: ${e.value}')
        .join(', ');
  }

  /// Obtener lista de etiquetas
  List<String>? get etiquetasLista {
    if (etiquetas == null || etiquetas!.isEmpty) return null;
    return etiquetas!.keys.toList();
  }

  /// Verificar si tiene certificaciones
  bool get tieneCertificaciones =>
      certificaciones != null && certificaciones!.isNotEmpty;

  /// Obtener resumen del producto
  String get resumen {
    final partes = <String>[];
    partes.add('$nombreProducto - \$${precioActual.toStringAsFixed(2)}');
    if (enOferta && porcentajeDescuento != null) {
      partes.add('(${porcentajeDescuento!.toStringAsFixed(0)}% OFF)');
    }
    if (stockBajo) partes.add('Stock bajo');
    if (!tieneStock) partes.add('Agotado');
    if (esEcologico) partes.add('🌱 Ecológico');
    return partes.join(' • ');
  }

  /// Verificar si el producto es nuevo (creado en los últimos 30 días)
  bool get esNuevo {
    final diferencia = DateTime.now().difference(fechaCreacion);
    return diferencia.inDays <= 30;
  }

  /// Obtener calificación como estrellas (0-5)
  double get calificacionEstrellas => calificacionPromedio ?? 0.0;

  /// Verificar si tiene buena calificación (4+ estrellas)
  bool get tieneBuenaCalificacion => calificacionEstrellas >= 4.0;

  /// Obtener popularidad basada en interacciones
  double get indicePopularidad {
    double indice = 0.0;
    indice += totalVisualizaciones * 0.1;
    indice += totalFavoritos * 1.0;
    indice += totalCompartidos * 0.5;
    indice += totalValoraciones * 0.8;
    if (calificacionPromedio != null) {
      indice += calificacionPromedio! * 10;
    }
    return indice;
  }

  /// Verificar si el producto es popular
  bool get esPopular => indicePopularidad > 50;

  /// Obtener información de garantía
  String? get garantiaInfo {
    if (garantiaMeses == null) return null;
    return '$garantiaMeses meses';
  }

  /// Obtener dimensiones como texto
  String? get dimensionesTexto {
    if (dimensionAlto == null ||
        dimensionAncho == null ||
        dimensionProfundidad == null) {
      return null;
    }
    return '${dimensionAlto} × ${dimensionAncho} × ${dimensionProfundidad} $unidadDimension';
  }

  /// Verificar si tiene información completa
  bool get tieneInfoCompleta {
    return descripcion.isNotEmpty &&
        (caracteristicas != null && caracteristicas!.isNotEmpty) &&
        (instruccionesUso != null || cuidados != null);
  }
}
