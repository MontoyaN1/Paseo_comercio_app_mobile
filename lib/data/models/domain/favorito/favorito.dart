// lib/data/models/domain/favorito/favorito.dart

import 'package:equatable/equatable.dart';

enum FavoritoType { tienda, producto }

class Favorito extends Equatable {
  final int id;
  final int usuarioId;
  final int itemId;
  final FavoritoType tipo;
  final DateTime fechaCreacion;

  const Favorito({
    required this.id,
    required this.usuarioId,
    required this.itemId,
    required this.tipo,
    required this.fechaCreacion,
  });

  factory Favorito.fromTiendaMap(Map<String, dynamic> map) {
    return Favorito(
      id: map['id'] as int,
      usuarioId: map['usuario_id'] as int,
      itemId: map['tienda_id'] as int,
      tipo: FavoritoType.tienda,
      fechaCreacion: DateTime.parse(map['fecha_creacion'] as String),
    );
  }

  factory Favorito.fromProductoMap(Map<String, dynamic> map) {
    return Favorito(
      id: map['id'] as int,
      usuarioId: map['usuario_id'] as int,
      itemId: map['producto_id'] as int,
      tipo: FavoritoType.producto,
      fechaCreacion: DateTime.parse(map['fecha_creacion'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      if (tipo == FavoritoType.tienda) 'tienda_id': itemId,
      if (tipo == FavoritoType.producto) 'producto_id': itemId,
      'fecha_creacion': fechaCreacion.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, usuarioId, itemId, tipo, fechaCreacion];
}
