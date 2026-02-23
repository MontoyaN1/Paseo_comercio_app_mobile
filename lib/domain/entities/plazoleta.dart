// lib/domain/entities/plazoleta.dart

import 'package:equatable/equatable.dart';

import 'enums.dart';

/// Entidad de dominio para Plazoleta (zona/ubicación en el centro comercial)
class Plazoleta extends Equatable {
  final int id;
  final String nombre;
  final String? descripcion;
  final String? ubicacion;
  final int? capacidadMaxima;
  final int? ordenVisual;
  final bool activa;
  final DateTime fechaCreacion;
  final DateTime? fechaActualizacion;
  final Map<String, dynamic>? metadata;
  final int totalTiendas;
  final int totalVisitas;
  final double? latitud;
  final double? longitud;
  final String? piso;
  final String? sector;
  final String? icono;
  final String? color;
  final TipoUbicacion tipoUbicacion;
  final bool tieneAccesoDiscapacitados;
  final bool tieneEstacionamiento;
  final bool tieneZonaDescanso;
  final bool tieneZonaComida;
  final List<String>? serviciosDisponibles;
  final String? horarioAcceso;
  final String? normasUso;

  const Plazoleta({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.ubicacion,
    this.capacidadMaxima,
    this.ordenVisual,
    required this.activa,
    required this.fechaCreacion,
    this.fechaActualizacion,
    this.metadata,
    this.totalTiendas = 0,
    this.totalVisitas = 0,
    this.latitud,
    this.longitud,
    this.piso,
    this.sector,
    this.icono,
    this.color,
    this.tipoUbicacion = TipoUbicacion.plazoleta,
    this.tieneAccesoDiscapacitados = false,
    this.tieneEstacionamiento = false,
    this.tieneZonaDescanso = false,
    this.tieneZonaComida = false,
    this.serviciosDisponibles,
    this.horarioAcceso,
    this.normasUso,
  });

  /// Verificar si la plazoleta está llena (capacidad máxima alcanzada)
  bool get estaLlena {
    if (capacidadMaxima == null) return false;
    return totalTiendas >= capacidadMaxima!;
  }

  /// Verificar si la plazoleta está disponible (activa y no llena)
  bool get disponible => activa && !estaLlena;

  /// Verificar si tiene ubicación geográfica
  bool get tieneUbicacionGeografica => latitud != null && longitud != null;

  /// Verificar si tiene servicios específicos
  bool tieneServicio(String servicio) {
    return serviciosDisponibles?.contains(servicio) ?? false;
  }

  /// Obtener porcentaje de ocupación
  double get porcentajeOcupacion {
    if (capacidadMaxima == null || capacidadMaxima == 0) return 0.0;
    return (totalTiendas / capacidadMaxima!) * 100;
  }

  /// Verificar si está en un piso específico
  bool estaEnPiso(String pisoBuscado) {
    return piso?.toLowerCase() == pisoBuscado.toLowerCase();
  }

  /// Verificar si está en un sector específico
  bool estaEnSector(String sectorBuscado) {
    return sector?.toLowerCase() == sectorBuscado.toLowerCase();
  }

  /// Verificar si es muy visitada
  bool get esMuyVisitada => totalVisitas > 1000;

  /// Verificar si es popular (muchas tiendas)
  bool get esPopular => totalTiendas > 10;

  /// Copiar con nuevos valores
  Plazoleta copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    String? ubicacion,
    int? capacidadMaxima,
    int? ordenVisual,
    bool? activa,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
    Map<String, dynamic>? metadata,
    int? totalTiendas,
    int? totalVisitas,
    double? latitud,
    double? longitud,
    String? piso,
    String? sector,
    String? icono,
    String? color,
    TipoUbicacion? tipoUbicacion,
    bool? tieneAccesoDiscapacitados,
    bool? tieneEstacionamiento,
    bool? tieneZonaDescanso,
    bool? tieneZonaComida,
    List<String>? serviciosDisponibles,
    String? horarioAcceso,
    String? normasUso,
  }) {
    return Plazoleta(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      ubicacion: ubicacion ?? this.ubicacion,
      capacidadMaxima: capacidadMaxima ?? this.capacidadMaxima,
      ordenVisual: ordenVisual ?? this.ordenVisual,
      activa: activa ?? this.activa,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      metadata: metadata ?? this.metadata,
      totalTiendas: totalTiendas ?? this.totalTiendas,
      totalVisitas: totalVisitas ?? this.totalVisitas,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      piso: piso ?? this.piso,
      sector: sector ?? this.sector,
      icono: icono ?? this.icono,
      color: color ?? this.color,
      tipoUbicacion: tipoUbicacion ?? this.tipoUbicacion,
      tieneAccesoDiscapacitados:
          tieneAccesoDiscapacitados ?? this.tieneAccesoDiscapacitados,
      tieneEstacionamiento: tieneEstacionamiento ?? this.tieneEstacionamiento,
      tieneZonaDescanso: tieneZonaDescanso ?? this.tieneZonaDescanso,
      tieneZonaComida: tieneZonaComida ?? this.tieneZonaComida,
      serviciosDisponibles: serviciosDisponibles ?? this.serviciosDisponibles,
      horarioAcceso: horarioAcceso ?? this.horarioAcceso,
      normasUso: normasUso ?? this.normasUso,
    );
  }

  @override
  List<Object?> get props => [
    id,
    nombre,
    descripcion,
    ubicacion,
    capacidadMaxima,
    ordenVisual,
    activa,
    fechaCreacion,
    fechaActualizacion,
    metadata,
    totalTiendas,
    totalVisitas,
    latitud,
    longitud,
    piso,
    sector,
    icono,
    color,
    tipoUbicacion,
    tieneAccesoDiscapacitados,
    tieneEstacionamiento,
    tieneZonaDescanso,
    tieneZonaComida,
    serviciosDisponibles,
    horarioAcceso,
    normasUso,
  ];

  @override
  bool get stringify => true;

  /// Métodos de utilidad para UI
  String get resumenUbicacion {
    final partes = <String>[];
    if (piso != null) partes.add('Piso $piso');
    if (sector != null) partes.add('Sector $sector');
    if (ubicacion != null) partes.add(ubicacion!);
    return partes.join(' • ');
  }

  String get estadoDescripcion {
    if (!activa) return 'Inactiva';
    if (estaLlena) return 'Completa';
    return 'Disponible';
  }

  List<String> get serviciosLista {
    final servicios = <String>[];

    if (tieneAccesoDiscapacitados) servicios.add('Acceso discapacitados');
    if (tieneEstacionamiento) servicios.add('Estacionamiento');
    if (tieneZonaDescanso) servicios.add('Zona de descanso');
    if (tieneZonaComida) servicios.add('Zona de comida');

    if (serviciosDisponibles != null) {
      servicios.addAll(serviciosDisponibles!);
    }

    return servicios;
  }

  bool get tieneInformacionCompleta {
    return descripcion != null &&
        ubicacion != null &&
        latitud != null &&
        longitud != null;
  }

  /// Métodos de negocio
  bool puedeAlbergarMasTiendas(int cantidadNuevas) {
    if (capacidadMaxima == null) return true;
    return totalTiendas + cantidadNuevas <= capacidadMaxima!;
  }

  bool esMejorQue(Plazoleta otra, {bool porVisitas = true}) {
    if (porVisitas) {
      return totalVisitas > otra.totalVisitas;
    } else {
      return totalTiendas > otra.totalTiendas;
    }
  }

  String get nivelOcupacion {
    final porcentaje = porcentajeOcupacion;
    if (porcentaje >= 90) return 'Crítico';
    if (porcentaje >= 70) return 'Alto';
    if (porcentaje >= 40) return 'Moderado';
    return 'Bajo';
  }

  /// Convertir a Map para serialización JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'ubicacion': ubicacion,
      'capacidadMaxima': capacidadMaxima,
      'ordenVisual': ordenVisual,
      'activa': activa,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fechaActualizacion': fechaActualizacion?.toIso8601String(),
      'metadata': metadata,
      'totalTiendas': totalTiendas,
      'totalVisitas': totalVisitas,
      'latitud': latitud,
      'longitud': longitud,
      'piso': piso,
      'sector': sector,
      'icono': icono,
      'color': color,
      'tipoUbicacion': tipoUbicacion.value,
      'tieneAccesoDiscapacitados': tieneAccesoDiscapacitados,
      'tieneEstacionamiento': tieneEstacionamiento,
      'tieneZonaDescanso': tieneZonaDescanso,
      'tieneZonaComida': tieneZonaComida,
      'serviciosDisponibles': serviciosDisponibles,
      'horarioAcceso': horarioAcceso,
      'normasUso': normasUso,
    };
  }

  /// Crear instancia desde Map (deserialización JSON)
  factory Plazoleta.fromJson(Map<String, dynamic> json) {
    return Plazoleta(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      ubicacion: json['ubicacion'] as String?,
      capacidadMaxima: json['capacidadMaxima'] as int?,
      ordenVisual: json['ordenVisual'] as int?,
      activa: json['activa'] as bool,
      fechaCreacion: DateTime.parse(json['fechaCreacion'] as String),
      fechaActualizacion:
          json['fechaActualizacion'] != null
              ? DateTime.parse(json['fechaActualizacion'] as String)
              : null,
      metadata:
          json['metadata'] != null
              ? Map<String, dynamic>.from(json['metadata'] as Map)
              : null,
      totalTiendas: json['totalTiendas'] as int? ?? 0,
      totalVisitas: json['totalVisitas'] as int? ?? 0,
      latitud: json['latitud'] as double?,
      longitud: json['longitud'] as double?,
      piso: json['piso'] as String?,
      sector: json['sector'] as String?,
      icono: json['icono'] as String?,
      color: json['color'] as String?,
      tipoUbicacion: TipoUbicacion.fromString(json['tipoUbicacion'] as String),
      tieneAccesoDiscapacitados:
          json['tieneAccesoDiscapacitados'] as bool? ?? false,
      tieneEstacionamiento: json['tieneEstacionamiento'] as bool? ?? false,
      tieneZonaDescanso: json['tieneZonaDescanso'] as bool? ?? false,
      tieneZonaComida: json['tieneZonaComida'] as bool? ?? false,
      serviciosDisponibles:
          json['serviciosDisponibles'] != null
              ? List<String>.from(json['serviciosDisponibles'] as List)
              : null,
      horarioAcceso: json['horarioAcceso'] as String?,
      normasUso: json['normasUso'] as String?,
    );
  }
}
