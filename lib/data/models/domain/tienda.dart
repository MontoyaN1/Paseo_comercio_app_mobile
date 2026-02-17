// lib/data/models/domain/tienda.dart

import 'package:hive/hive.dart';

part 'tienda.g.dart';

@HiveType(typeId: 2)
class Tienda extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String nombreTienda;

  @HiveField(2)
  final String? descripcion;

  @HiveField(3)
  final String? logoUrl;

  @HiveField(4)
  final String? portadaUrl;

  @HiveField(5)
  final String? direccion;

  @HiveField(6)
  final String? telefono;

  @HiveField(7)
  final String? email;

  @HiveField(8)
  final String? sitioWeb;

  @HiveField(9)
  final String? horarioAtencion;

  @HiveField(10)
  final double? latitud;

  @HiveField(11)
  final double? longitud;

  @HiveField(12)
  final String? categoriaId;

  @HiveField(13)
  final String? idPropietario;

  @HiveField(14)
  final int totalVisitas;

  @HiveField(15)
  final String? fechaUltimaVisita;

  @HiveField(16)
  final String estadoTienda;

  @HiveField(17)
  final String fechaCreacion;

  @HiveField(18)
  final String fechaActualizacion;

  Tienda({
    required this.id,
    required this.nombreTienda,
    this.descripcion,
    this.logoUrl,
    this.portadaUrl,
    this.direccion,
    this.telefono,
    this.email,
    this.sitioWeb,
    this.horarioAtencion,
    this.latitud,
    this.longitud,
    this.categoriaId,
    this.idPropietario,
    required this.totalVisitas,
    this.fechaUltimaVisita,
    required this.estadoTienda,
    required this.fechaCreacion,
    required this.fechaActualizacion,
  });

  factory Tienda.fromMap(Map<String, dynamic> map) {
    return Tienda(
      id: map['id']?.toString() ?? '',
      nombreTienda: map['nombre_tienda']?.toString() ?? '',
      descripcion: map['descripcion']?.toString(),
      logoUrl: map['logo_url']?.toString(),
      portadaUrl: map['portada_url']?.toString(),
      direccion: map['direccion']?.toString(),
      telefono: map['telefono']?.toString(),
      email: map['email']?.toString(),
      sitioWeb: map['sitio_web']?.toString(),
      horarioAtencion: map['horario_atencion']?.toString(),
      latitud:
          map['latitud'] is num ? (map['latitud'] as num).toDouble() : null,
      longitud:
          map['longitud'] is num ? (map['longitud'] as num).toDouble() : null,
      categoriaId: map['categoria_id']?.toString(),
      idPropietario: map['id_propietario']?.toString(),
      totalVisitas:
          map['total_visitas'] is int ? map['total_visitas'] as int : 0,
      fechaUltimaVisita: map['fecha_ultima_visita']?.toString(),
      estadoTienda: map['estado_tienda']?.toString() ?? 'activa',
      fechaCreacion: map['fecha_creacion']?.toString() ?? '',
      fechaActualizacion: map['fecha_actualizacion']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre_tienda': nombreTienda,
      'descripcion': descripcion,
      'logo_url': logoUrl,
      'portada_url': portadaUrl,
      'direccion': direccion,
      'telefono': telefono,
      'email': email,
      'sitio_web': sitioWeb,
      'horario_atencion': horarioAtencion,
      'latitud': latitud,
      'longitud': longitud,
      'categoria_id': categoriaId,
      'id_propietario': idPropietario,
      'total_visitas': totalVisitas,
      'fecha_ultima_visita': fechaUltimaVisita,
      'estado_tienda': estadoTienda,
      'fecha_creacion': fechaCreacion,
      'fecha_actualizacion': fechaActualizacion,
    };
  }

  Tienda copyWith({
    String? id,
    String? nombreTienda,
    String? descripcion,
    String? logoUrl,
    String? portadaUrl,
    String? direccion,
    String? telefono,
    String? email,
    String? sitioWeb,
    String? horarioAtencion,
    double? latitud,
    double? longitud,
    String? categoriaId,
    String? idPropietario,
    int? totalVisitas,
    String? fechaUltimaVisita,
    String? estadoTienda,
    String? fechaCreacion,
    String? fechaActualizacion,
  }) {
    return Tienda(
      id: id ?? this.id,
      nombreTienda: nombreTienda ?? this.nombreTienda,
      descripcion: descripcion ?? this.descripcion,
      logoUrl: logoUrl ?? this.logoUrl,
      portadaUrl: portadaUrl ?? this.portadaUrl,
      direccion: direccion ?? this.direccion,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      sitioWeb: sitioWeb ?? this.sitioWeb,
      horarioAtencion: horarioAtencion ?? this.horarioAtencion,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      categoriaId: categoriaId ?? this.categoriaId,
      idPropietario: idPropietario ?? this.idPropietario,
      totalVisitas: totalVisitas ?? this.totalVisitas,
      fechaUltimaVisita: fechaUltimaVisita ?? this.fechaUltimaVisita,
      estadoTienda: estadoTienda ?? this.estadoTienda,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }
}
