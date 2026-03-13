// lib/domain/entities/valoracion_producto.dart

import 'package:equatable/equatable.dart';

import 'enums.dart';

/// Entidad de dominio para Valoración de Producto (reviews/calificaciones)
/// Esquema basado en la tabla: valoracion_producto
/// - id: bigint (auto-increment)
/// - fecha_creacion: timestamp with time zone
/// - producto_id: bigint (FK to producto)
/// - usuario_id: bigint (FK to usuario)
/// - calificacion: smallint (1-5)
/// - comentario: text (nullable)
/// - estado_valoracion: enum estado_valoracion (default 'publicado')
class ValoracionProducto extends Equatable {
  final int id;
  final DateTime fechaCreacion;
  final int productoId;
  final int usuarioId;
  final int calificacion; // 1-5 (smallint en DB)
  final String? comentario;
  final EstadoValoracion estadoValoracion;

  const ValoracionProducto({
    required this.id,
    required this.fechaCreacion,
    required this.productoId,
    required this.usuarioId,
    required this.calificacion,
    this.comentario,
    required this.estadoValoracion,
  });

  /// Verificar si la valoración está publicada
  bool get estaPublicada => estadoValoracion == EstadoValoracion.publicado;

  /// Verificar si la valoración está reportada
  bool get estaReportada => estadoValoracion == EstadoValoracion.reportado;

  /// Verificar si la valoración está eliminada
  bool get estaEliminada => estadoValoracion == EstadoValoracion.eliminado;

  /// Obtener calificación en estrellas (entero)
  int get calificacionEstrellas => calificacion;

  /// Obtener calificación formateada
  String get calificacionFormateada => '$calificacion.0';

  /// Verificar si es una valoración reciente (menos de 7 días)
  bool get esReciente {
    final sieteDiasAtras = DateTime.now().subtract(const Duration(days: 7));
    return fechaCreacion.isAfter(sieteDiasAtras);
  }

  /// Verificar si es una valoración negativa (≤ 2 estrellas)
  bool get esNegativa => calificacion <= 2;

  /// Verificar si es una valoración positiva (≥ 4 estrellas)
  bool get esPositiva => calificacion >= 4;

  /// Verificar si es una valoración neutral (3 estrellas)
  bool get esNeutral => calificacion == 3;

  /// Obtener tiempo desde la creación formateado
  String get tiempoDesdeCreacion {
    final diferencia = DateTime.now().difference(fechaCreacion);

    if (diferencia.inSeconds < 60) {
      return 'Ahora mismo';
    } else if (diferencia.inMinutes < 60) {
      return 'Hace ${diferencia.inMinutes} min';
    } else if (diferencia.inHours < 24) {
      return 'Hace ${diferencia.inHours} h';
    } else if (diferencia.inDays < 7) {
      return 'Hace ${diferencia.inDays} días';
    } else if (diferencia.inDays < 30) {
      final semanas = (diferencia.inDays / 7).floor();
      return 'Hace $semanas ${semanas == 1 ? 'semana' : 'semanas'}';
    } else if (diferencia.inDays < 365) {
      final meses = (diferencia.inDays / 30).floor();
      return 'Hace $meses ${meses == 1 ? 'mes' : 'meses'}';
    } else {
      final anos = (diferencia.inDays / 365).floor();
      return 'Hace $anos ${anos == 1 ? 'año' : 'años'}';
    }
  }

  /// Copiar con nuevos valores
  ValoracionProducto copyWith({
    int? id,
    DateTime? fechaCreacion,
    int? productoId,
    int? usuarioId,
    int? calificacion,
    String? comentario,
    EstadoValoracion? estadoValoracion,
  }) {
    return ValoracionProducto(
      id: id ?? this.id,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      productoId: productoId ?? this.productoId,
      usuarioId: usuarioId ?? this.usuarioId,
      calificacion: calificacion ?? this.calificacion,
      comentario: comentario ?? this.comentario,
      estadoValoracion: estadoValoracion ?? this.estadoValoracion,
    );
  }

  @override
  List<Object?> get props => [
    id,
    fechaCreacion,
    productoId,
    usuarioId,
    calificacion,
    comentario,
    estadoValoracion,
  ];

  @override
  bool get stringify => true;

  /// Descripción del estado
  String get estadoDescripcion {
    switch (estadoValoracion) {
      case EstadoValoracion.publicado:
        return 'Publicado';
      case EstadoValoracion.reportado:
        return 'Reportado';
      case EstadoValoracion.eliminado:
        return 'Eliminado';
    }
  }

  /// Tipo de valoración según calificación
  String get tipoValoracion {
    if (esPositiva) return 'Positiva';
    if (esNegativa) return 'Negativa';
    return 'Neutral';
  }

  /// Crear desde mapa (respuesta de Supabase)
  factory ValoracionProducto.fromMap(Map<String, dynamic> map) {
    return ValoracionProducto(
      id: map['id'] as int,
      fechaCreacion: DateTime.parse(map['fecha_creacion'] as String),
      productoId: map['producto_id'] as int,
      usuarioId: map['usuario_id'] as int,
      calificacion: map['calificacion'] as int,
      comentario: map['comentario'] as String?,
      estadoValoracion: _parseEstadoValoracion(map['estado_valoracion']),
    );
  }

  /// Convertir a mapa para guardar en Supabase
  Map<String, dynamic> toMap() {
    return {
      'producto_id': productoId,
      'usuario_id': usuarioId,
      'calificacion': calificacion,
      if (comentario != null) 'comentario': comentario,
      'estado_valoracion': estadoValoracion.name,
    };
  }

  /// Parsear estado_valoracion desde string
  static EstadoValoracion _parseEstadoValoracion(dynamic value) {
    if (value == null) return EstadoValoracion.publicado;
    if (value is String) {
      return EstadoValoracion.values.firstWhere(
        (e) => e.name == value,
        orElse: () => EstadoValoracion.publicado,
      );
    }
    if (value is EstadoValoracion) return value;
    return EstadoValoracion.publicado;
  }
}
