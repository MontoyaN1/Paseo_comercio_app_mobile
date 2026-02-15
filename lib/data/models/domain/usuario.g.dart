// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usuario.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UsuarioAdapter extends TypeAdapter<Usuario> {
  @override
  final int typeId = 1;

  @override
  Usuario read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Usuario(
      id: fields[0] as int,
      clerkUserId: fields[1] as String,
      nombreCompleto: fields[2] as String,
      email: fields[3] as String,
      telefono: fields[4] as String,
      fechaRegistro: fields[5] as DateTime,
      ultimoLogin: fields[6] as DateTime?,
      perfilPublico: fields[7] as bool,
      estadoUsuario: fields[8] as EstadoUsuario,
      rolesId: fields[9] as int?,
      createdAt: fields[10] as DateTime?,
      updatedAt: fields[11] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Usuario obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.clerkUserId)
      ..writeByte(2)
      ..write(obj.nombreCompleto)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.telefono)
      ..writeByte(5)
      ..write(obj.fechaRegistro)
      ..writeByte(6)
      ..write(obj.ultimoLogin)
      ..writeByte(7)
      ..write(obj.perfilPublico)
      ..writeByte(8)
      ..write(obj.estadoUsuario)
      ..writeByte(9)
      ..write(obj.rolesId)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UsuarioAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
