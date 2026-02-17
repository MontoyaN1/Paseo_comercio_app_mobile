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
      id: fields[0] as String,
      nombreTienda: fields[1] as String,
      descripcion: fields[2] as String?,
      logoUrl: fields[3] as String?,
      portadaUrl: fields[4] as String?,
      direccion: fields[5] as String?,
      telefono: fields[6] as String?,
      email: fields[7] as String?,
      sitioWeb: fields[8] as String?,
      horarioAtencion: fields[9] as String?,
      latitud: fields[10] as double?,
      longitud: fields[11] as double?,
      categoriaId: fields[12] as String?,
      idPropietario: fields[13] as String?,
      totalVisitas: fields[14] as int,
      fechaUltimaVisita: fields[15] as String?,
      estadoTienda: fields[16] as String,
      fechaCreacion: fields[17] as String,
      fechaActualizacion: fields[18] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Tienda obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nombreTienda)
      ..writeByte(2)
      ..write(obj.descripcion)
      ..writeByte(3)
      ..write(obj.logoUrl)
      ..writeByte(4)
      ..write(obj.portadaUrl)
      ..writeByte(5)
      ..write(obj.direccion)
      ..writeByte(6)
      ..write(obj.telefono)
      ..writeByte(7)
      ..write(obj.email)
      ..writeByte(8)
      ..write(obj.sitioWeb)
      ..writeByte(9)
      ..write(obj.horarioAtencion)
      ..writeByte(10)
      ..write(obj.latitud)
      ..writeByte(11)
      ..write(obj.longitud)
      ..writeByte(12)
      ..write(obj.categoriaId)
      ..writeByte(13)
      ..write(obj.idPropietario)
      ..writeByte(14)
      ..write(obj.totalVisitas)
      ..writeByte(15)
      ..write(obj.fechaUltimaVisita)
      ..writeByte(16)
      ..write(obj.estadoTienda)
      ..writeByte(17)
      ..write(obj.fechaCreacion)
      ..writeByte(18)
      ..write(obj.fechaActualizacion);
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
