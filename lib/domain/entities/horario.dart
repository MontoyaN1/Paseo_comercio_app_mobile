// lib/domain/entities/horario.dart

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'enums.dart';

/// Entidad de dominio para Horario (horarios de atención de tiendas)
/// Corresponde al esquema de la DB:
/// - id_horario (PK)
/// - fecha_creacion
/// - tienda_id (FK)
/// - dia_semana (0=Lunes, 6=Domingo)
/// - apertura (time)
/// - cierre (time)
/// - cerrado (boolean)
/// - fecha_especifica (date)
/// - tipo_horario (enum)
class Horario extends Equatable {
  final int id;
  final DateTime fechaCreacion;
  final int tiendaId;
  final int diaSemana;
  final TimeOfDay? apertura;
  final TimeOfDay? cierre;
  final bool cerrado;
  final DateTime? fechaEspecifica;
  final TipoHorario tipoHorario;

  const Horario({
    required this.id,
    required this.fechaCreacion,
    required this.tiendaId,
    required this.diaSemana,
    this.apertura,
    this.cierre,
    this.cerrado = false,
    this.fechaEspecifica,
    this.tipoHorario = TipoHorario.normal,
  });

  /// Factory para crear desde JSON de Supabase
  factory Horario.fromJson(Map<String, dynamic> json) {
    // Parsear dia_semana (0=Lunes, 6=Domingo)
    final dia = json['dia_semana'] as int? ?? 0;

    // Parsear horas
    TimeOfDay? parseHora(dynamic hora) {
      if (hora == null) return null;
      final horaStr = hora.toString();
      final partes = horaStr.split(':');
      if (partes.length >= 2) {
        return TimeOfDay(
          hour: int.tryParse(partes[0]) ?? 0,
          minute: int.tryParse(partes[1]) ?? 0,
        );
      }
      return null;
    }

    // Parsear tipo_horario
    TipoHorario parseTipo(dynamic tipo) {
      if (tipo == null) return TipoHorario.normal;
      if (tipo is String) {
        switch (tipo.toLowerCase()) {
          case 'festivo':
            return TipoHorario.festivo;
          case 'especial':
            return TipoHorario.especial;
          default:
            return TipoHorario.normal;
        }
      }
      return TipoHorario.normal;
    }

    // Parsear fecha_especifica
    DateTime? parseFechaEspecifica(dynamic fecha) {
      if (fecha == null) return null;
      if (fecha is String) {
        return DateTime.tryParse(fecha);
      }
      return null;
    }

    return Horario(
      id: json['id_horario'] as int? ?? 0,
      fechaCreacion:
          json['fecha_creacion'] != null
              ? DateTime.parse(json['fecha_creacion'] as String)
              : DateTime.now(),
      tiendaId: json['tienda_id'] as int? ?? 0,
      diaSemana: dia,
      apertura: parseHora(json['apertura']),
      cierre: parseHora(json['cierre']),
      cerrado: json['cerrado'] as bool? ?? false,
      fechaEspecifica: parseFechaEspecifica(json['fecha_especifica']),
      tipoHorario: parseTipo(json['tipo_horario']),
    );
  }

  /// Convertir a JSON para la DB
  Map<String, dynamic> toJson() {
    // Convertir TimeOfDay a string
    String? horaToString(TimeOfDay? hora) {
      if (hora == null) return null;
      return '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}:00';
    }

    return {
      'id_horario': id,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'tienda_id': tiendaId,
      'dia_semana': diaSemana,
      'apertura': horaToString(apertura),
      'cierre': horaToString(cierre),
      'cerrado': cerrado,
      'fecha_especifica': fechaEspecifica?.toIso8601String().split('T').first,
      'tipo_horario': tipoHorario.name,
    };
  }

  /// Nombre del día de la semana
  String get diaNombre {
    final dias = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    return (diaSemana >= 0 && diaSemana < dias.length)
        ? dias[diaSemana]
        : 'Día $diaSemana';
  }

  /// Horario formateado como string
  String get horarioFormateado {
    if (cerrado || apertura == null || cierre == null) {
      return 'Cerrado';
    }
    return '${_formatearHora(apertura!)} - ${_formatearHora(cierre!)}';
  }

  String _formatearHora(TimeOfDay hora) {
    return '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';
  }

  /// Verificar si está abierto ahora
  bool get estaAbiertoAhora {
    if (cerrado) return false;

    final ahora = DateTime.now();
    final diaActual = ahora.weekday - 1; // Convertir: Lun=0, Dom=6

    // Verificar si es el día correcto
    if (diaActual != diaSemana) return false;

    if (apertura == null || cierre == null) return false;

    final minutosAhora = ahora.hour * 60 + ahora.minute;
    final minutosApertura = apertura!.hour * 60 + apertura!.minute;
    final minutosCierre = cierre!.hour * 60 + cierre!.minute;

    return minutosAhora >= minutosApertura && minutosAhora <= minutosCierre;
  }

  /// Verificar si está abierto en un horario específico
  bool estaAbiertoEnHorario(TimeOfDay horario) {
    if (cerrado) return false;
    if (apertura == null || cierre == null) return false;

    final minutosHorario = horario.hour * 60 + horario.minute;
    final minutosApertura = apertura!.hour * 60 + apertura!.minute;
    final minutosCierre = cierre!.hour * 60 + cierre!.minute;

    return minutosHorario >= minutosApertura && minutosHorario <= minutosCierre;
  }

  /// Crear copia con cambios
  Horario copyWith({
    int? id,
    DateTime? fechaCreacion,
    int? tiendaId,
    int? diaSemana,
    TimeOfDay? apertura,
    TimeOfDay? cierre,
    bool? cerrado,
    DateTime? fechaEspecifica,
    TipoHorario? tipoHorario,
  }) {
    return Horario(
      id: id ?? this.id,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      tiendaId: tiendaId ?? this.tiendaId,
      diaSemana: diaSemana ?? this.diaSemana,
      apertura: apertura ?? this.apertura,
      cierre: cierre ?? this.cierre,
      cerrado: cerrado ?? this.cerrado,
      fechaEspecifica: fechaEspecifica ?? this.fechaEspecifica,
      tipoHorario: tipoHorario ?? this.tipoHorario,
    );
  }

  @override
  List<Object?> get props => [
    id,
    fechaCreacion,
    tiendaId,
    diaSemana,
    apertura,
    cierre,
    cerrado,
    fechaEspecifica,
    tipoHorario,
  ];

  @override
  String toString() {
    return 'Horario(id: $id, tiendaId: $tiendaId, dia: $diaNombre, horario: $horarioFormateado)';
  }
}
