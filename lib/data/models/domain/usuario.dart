// lib/data/models/domain/usuario.dart

import 'package:hive/hive.dart';

part 'usuario.g.dart';

@HiveType(typeId: 1)
class Usuario extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String clerkUserId;

  @HiveField(2)
  final String nombreCompleto;

  @HiveField(3)
  final String email;

  @HiveField(4)
  final String? telefono;

  @HiveField(5)
  final String? avatarUrl;

  @HiveField(6)
  final String fechaRegistro;

  @HiveField(7)
  final String ultimoLogin;

  @HiveField(8)
  final bool perfilPublico;

  @HiveField(9)
  final String estadoUsuario;

  @HiveField(10)
  final String createdAt;

  @HiveField(11)
  final String updatedAt;

  Usuario({
    required this.id,
    required this.clerkUserId,
    required this.nombreCompleto,
    required this.email,
    this.telefono,
    this.avatarUrl,
    required this.fechaRegistro,
    required this.ultimoLogin,
    required this.perfilPublico,
    required this.estadoUsuario,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id']?.toString() ?? '',
      clerkUserId: map['clerk_user_id']?.toString() ?? '',
      nombreCompleto: map['nombre_completo']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      telefono: map['telefono']?.toString(),
      avatarUrl: map['avatar_url']?.toString(),
      fechaRegistro: map['fecha_registro']?.toString() ?? '',
      ultimoLogin: map['ultimo_login']?.toString() ?? '',
      perfilPublico: map['perfil_publico'] as bool? ?? true,
      estadoUsuario: map['estado_usuario']?.toString() ?? 'activo',
      createdAt: map['created_at']?.toString() ?? '',
      updatedAt: map['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clerk_user_id': clerkUserId,
      'nombre_completo': nombreCompleto,
      'email': email,
      'telefono': telefono,
      'avatar_url': avatarUrl,
      'fecha_registro': fechaRegistro,
      'ultimo_login': ultimoLogin,
      'perfil_publico': perfilPublico,
      'estado_usuario': estadoUsuario,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  Usuario copyWith({
    String? id,
    String? clerkUserId,
    String? nombreCompleto,
    String? email,
    String? telefono,
    String? avatarUrl,
    String? fechaRegistro,
    String? ultimoLogin,
    bool? perfilPublico,
    String? estadoUsuario,
    String? createdAt,
    String? updatedAt,
  }) {
    return Usuario(
      id: id ?? this.id,
      clerkUserId: clerkUserId ?? this.clerkUserId,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      ultimoLogin: ultimoLogin ?? this.ultimoLogin,
      perfilPublico: perfilPublico ?? this.perfilPublico,
      estadoUsuario: estadoUsuario ?? this.estadoUsuario,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
