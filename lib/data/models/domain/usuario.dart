// lib/data/models/domain/usuario.dart

import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

import 'enums.dart';

part 'usuario.g.dart';

@HiveType(typeId: 1)
class Usuario extends Equatable {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String clerkUserId;

  @HiveField(2)
  final String nombreCompleto;

  @HiveField(3)
  final String email;

  @HiveField(4)
  final String telefono;

  @HiveField(5)
  final DateTime fechaRegistro;

  @HiveField(6)
  final DateTime? ultimoLogin;

  @HiveField(7)
  final bool perfilPublico;

  @HiveField(8)
  final EstadoUsuario estadoUsuario;

  @HiveField(9)
  final int? rolesId;

  @HiveField(10)
  final DateTime? createdAt;

  @HiveField(11)
  final DateTime? updatedAt;

  const Usuario({
    required this.id,
    required this.clerkUserId,
    required this.nombreCompleto,
    required this.email,
    required this.telefono,
    required this.fechaRegistro,
    this.ultimoLogin,
    required this.perfilPublico,
    required this.estadoUsuario,
    this.rolesId,
    this.createdAt,
    this.updatedAt,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as int,
      clerkUserId: json['clerk_user_id'] as String,
      nombreCompleto: json['nombre_completo'] as String,
      email: json['email'] as String,
      telefono: json['telefono'] as String,
      fechaRegistro: DateTime.parse(json['fecha_registro'] as String),
      ultimoLogin:
          json['ultimo_login'] != null
              ? DateTime.parse(json['ultimo_login'] as String)
              : null,
      perfilPublico: json['perfil_publico'] as bool,
      estadoUsuario: EstadoUsuario.fromString(json['estado_usuario'] as String),
      rolesId: json['roles_id'] as int?,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clerk_user_id': clerkUserId,
      'nombre_completo': nombreCompleto,
      'email': email,
      'telefono': telefono,
      'fecha_registro': fechaRegistro.toIso8601String(),
      'ultimo_login': ultimoLogin?.toIso8601String(),
      'perfil_publico': perfilPublico,
      'estado_usuario': estadoUsuario.toString(),
      'roles_id': rolesId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Usuario copyWith({
    int? id,
    String? clerkUserId,
    String? nombreCompleto,
    String? email,
    String? telefono,
    DateTime? fechaRegistro,
    DateTime? ultimoLogin,
    bool? perfilPublico,
    EstadoUsuario? estadoUsuario,
    int? rolesId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Usuario(
      id: id ?? this.id,
      clerkUserId: clerkUserId ?? this.clerkUserId,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      ultimoLogin: ultimoLogin ?? this.ultimoLogin,
      perfilPublico: perfilPublico ?? this.perfilPublico,
      estadoUsuario: estadoUsuario ?? this.estadoUsuario,
      rolesId: rolesId ?? this.rolesId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    clerkUserId,
    nombreCompleto,
    email,
    telefono,
    fechaRegistro,
    ultimoLogin,
    perfilPublico,
    estadoUsuario,
    rolesId,
    createdAt,
    updatedAt,
  ];

  @override
  bool get stringify => true;

  // Métodos de utilidad
  bool get isActive => estadoUsuario == EstadoUsuario.activo;
  bool get isAdmin =>
      rolesId != null && rolesId! > 2; // Suponiendo que admin tiene ID > 2
  String get nombreCorto {
    final partes = nombreCompleto.split(' ');
    return partes.length > 1
        ? '${partes.first} ${partes.last[0]}.'
        : nombreCompleto;
  }
}
