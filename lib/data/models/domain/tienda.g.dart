// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tienda.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TiendaAdapter extends TypeAdapter<Tienda> {
  @override
  final int typeId = 2;

  @override
  Tienda read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Tienda(
      id: fields[0] as int,
      fechaCreacion: fields[1] as DateTime,
      idPropietario: fields[2] as int,
      nombreTienda: fields[3] as String,
      descripcion: fields[4] as String?,
      redesSociales: (fields[5] as Map?)?.cast<String, dynamic>(),
      organizacionId: fields[6] as int?,
      emailContacto: fields[7] as String?,
      telefonoContacto: fields[8] as String?,
      direccion: fields[9] as String?,
      totalVisitas: fields[10] as int,
      totalContactosWhatsapp: fields[11] as int,
      fechaUltimaVisita: fields[12] as DateTime?,
      updatedAt: fields[13] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Tienda obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fechaCreacion)
      ..writeByte(2)
      ..write(obj.idPropietario)
      ..writeByte(3)
      ..write(obj.nombreTienda)
      ..writeByte(4)
      ..write(obj.descripcion)
      ..writeByte(5)
      ..write(obj.redesSociales)
      ..writeByte(6)
      ..write(obj.organizacionId)
      ..writeByte(7)
      ..write(obj.emailContacto)
      ..writeByte(8)
      ..write(obj.telefonoContacto)
      ..writeByte(9)
      ..write(obj.direccion)
      ..writeByte(10)
      ..write(obj.totalVisitas)
      ..writeByte(11)
      ..write(obj.totalContactosWhatsapp)
      ..writeByte(12)
      ..write(obj.fechaUltimaVisita)
      ..writeByte(13)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TiendaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
