// lib/data/models/domain/tienda.dart

import 'package:equatable/equatable.dart';

class Tienda extends Equatable {
  final int id;

  final DateTime fechaCreacion;

  final int idPropietario;

  final String nombreTienda;

  final String? descripcion;

  final String? logoUrl;

  final dynamic imagenTienda;

  final Map<String, dynamic>? redesSociales;

  final int? organizacionId;

  final String? emailContacto;

  final String? telefonoContacto;

  final String? direccion;

  final int totalVisitas;

  final int totalContactosWhatsapp;

  final DateTime? fechaUltimaVisita;
  final DateTime? updatedAt;

  const Tienda({
    required this.id,
    required this.fechaCreacion,
    required this.idPropietario,
    required this.nombreTienda,
    this.descripcion,
    this.logoUrl,
    this.imagenTienda,
    this.redesSociales,
    this.organizacionId,
    this.emailContacto,
    this.telefonoContacto,
    this.direccion,
    this.totalVisitas = 0,
    this.totalContactosWhatsapp = 0,
    this.fechaUltimaVisita,
    this.updatedAt,
  });

  factory Tienda.fromJson(Map<String, dynamic> json) {
    return Tienda(
      id: (json['id'] as int?) ?? 0,
      fechaCreacion:
          json['fecha_creacion'] != null
              ? DateTime.parse(json['fecha_creacion'] as String)
              : DateTime.now(),
      idPropietario: (json['id_propietario'] as int?) ?? 0,
      nombreTienda:
          ((json['nombre_tienda'] ?? json['nombre']) as String?) ?? '',
      descripcion: json['descripcion'] as String?,
      logoUrl:
          (json['logoUrl'] ?? json['logo_url'] ?? json['url_logo']) as String?,
      redesSociales:
          (json['redes_sociales'] ?? json['redesSociales']) != null
              ? Map<String, dynamic>.from(
                (json['redes_sociales'] ?? json['redesSociales']) as Map,
              )
              : null,
      imagenTienda: json['imagen_tienda'],
      organizacionId:
          (json['organizacion_id'] ?? json['organizacionId']) as int?,
      emailContacto:
          (json['email_contacto'] ?? json['emailContacto']) as String?,
      telefonoContacto:
          (json['telefono_contacto'] ?? json['telefonoContacto']) as String?,
      direccion: json['direccion'] as String?,
      totalVisitas:
          (json['total_visitas'] ?? json['totalVisitas']) as int? ?? 0,
      totalContactosWhatsapp:
          (json['total_contactos_whatsapp'] ?? json['totalContactosWhatsapp'])
              as int? ??
          0,
      fechaUltimaVisita:
          (json['fecha_ultima_visita'] ?? json['fechaUltimaVisita']) != null
              ? DateTime.parse(
                (json['fecha_ultima_visita'] ?? json['fechaUltimaVisita'])
                    as String,
              )
              : null,
      updatedAt:
          (json['updated_at'] ?? json['updatedAt']) != null
              ? DateTime.parse(
                (json['updated_at'] ?? json['updatedAt']) as String,
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'id_propietario': idPropietario,
      'nombre_tienda': nombreTienda,
      'descripcion': descripcion,
      'logoUrl': logoUrl,
      'imagen_tienda': imagenTienda,
      'redes_sociales': redesSociales,
      'organizacion_id': organizacionId,
      'email_contacto': emailContacto,
      'telefono_contacto': telefonoContacto,
      'direccion': direccion,
      'total_visitas': totalVisitas,
      'total_contactos_whatsapp': totalContactosWhatsapp,
      'fecha_ultima_visita': fechaUltimaVisita?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Tienda copyWith({
    int? id,
    DateTime? fechaCreacion,
    int? idPropietario,
    String? nombreTienda,
    String? descripcion,
    String? logoUrl,
    Map<String, dynamic>? redesSociales,
    dynamic imagenTienda,
    int? organizacionId,
    String? emailContacto,
    String? telefonoContacto,
    String? direccion,
    int? totalVisitas,
    int? totalContactosWhatsapp,
    DateTime? fechaUltimaVisita,
    DateTime? updatedAt,
  }) {
    return Tienda(
      id: id ?? this.id,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      idPropietario: idPropietario ?? this.idPropietario,
      nombreTienda: nombreTienda ?? this.nombreTienda,
      descripcion: descripcion ?? this.descripcion,
      logoUrl: logoUrl ?? this.logoUrl,
      redesSociales: redesSociales ?? this.redesSociales,
      imagenTienda: imagenTienda ?? this.imagenTienda,
      organizacionId: organizacionId ?? this.organizacionId,
      emailContacto: emailContacto ?? this.emailContacto,
      telefonoContacto: telefonoContacto ?? this.telefonoContacto,
      direccion: direccion ?? this.direccion,
      totalVisitas: totalVisitas ?? this.totalVisitas,
      totalContactosWhatsapp:
          totalContactosWhatsapp ?? this.totalContactosWhatsapp,
      fechaUltimaVisita: fechaUltimaVisita ?? this.fechaUltimaVisita,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    fechaCreacion,
    idPropietario,
    nombreTienda,
    descripcion,
    logoUrl,
    imagenTienda,
    redesSociales,
    organizacionId,
    emailContacto,
    telefonoContacto,
    direccion,
    totalVisitas,
    totalContactosWhatsapp,
    fechaUltimaVisita,
    updatedAt,
  ];

  @override
  bool get stringify => true;

  // Métodos de utilidad
  bool get tieneRedesSociales =>
      redesSociales != null && redesSociales!.isNotEmpty;
  bool get tieneContacto => emailContacto != null || telefonoContacto != null;
  bool get tieneDireccion => direccion != null && direccion!.isNotEmpty;

  List<String>? get redesSocialesList {
    if (redesSociales == null) return null;
    return redesSociales!.keys.toList();
  }

  String? getRedSocialUrl(String redSocial) {
    return redesSociales?[redSocial] as String?;
  }

  bool get esPopular => totalVisitas > 100;
  bool get esMuyVisitada => totalVisitas > 500;

  String get resumenContacto {
    if (emailContacto != null && telefonoContacto != null) {
      return '$emailContacto | $telefonoContacto';
    } else if (emailContacto != null) {
      return emailContacto!;
    } else if (telefonoContacto != null) {
      return telefonoContacto!;
    }
    return 'Sin contacto';
  }
}
