// lib/domain/entities/horario.dart

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'enums.dart';

/// Entidad de dominio para Horario (horarios de atención de tiendas)
class Horario extends Equatable {
  final int id;
  final int? tiendaId;
  final int? plazoletaId;
  final int? organizacionId;
  final DiaSemana diaSemana;
  final TimeOfDay horaApertura;
  final TimeOfDay horaCierre;
  final TipoHorario tipoHorario;
  final bool activo;
  final DateTime fechaCreacion;
  final DateTime? fechaActualizacion;
  final String? notas;
  final Map<String, dynamic>? metadata;
  final bool esHorarioEspecial;
  final String? motivoEspecial;
  final DateTime? fechaInicioEspecial;
  final DateTime? fechaFinEspecial;
  final bool permiteCitas;
  final int? duracionCitaMinutos;
  final int? intervaloCitaMinutos;
  final TimeOfDay? horaInicioCitas;
  final TimeOfDay? horaFinCitas;
  final bool requiereReserva;
  final int? anticipacionMinimaReserva;
  final int? capacidadMaximaSimultanea;
  final bool tieneDescanso;
  final TimeOfDay? horaInicioDescanso;
  final TimeOfDay? horaFinDescanso;
  final int? duracionDescansoMinutos;

  const Horario({
    required this.id,
    this.tiendaId,
    this.plazoletaId,
    this.organizacionId,
    required this.diaSemana,
    required this.horaApertura,
    required this.horaCierre,
    required this.tipoHorario,
    required this.activo,
    required this.fechaCreacion,
    this.fechaActualizacion,
    this.notas,
    this.metadata,
    this.esHorarioEspecial = false,
    this.motivoEspecial,
    this.fechaInicioEspecial,
    this.fechaFinEspecial,
    this.permiteCitas = false,
    this.duracionCitaMinutos,
    this.intervaloCitaMinutos,
    this.horaInicioCitas,
    this.horaFinCitas,
    this.requiereReserva = false,
    this.anticipacionMinimaReserva,
    this.capacidadMaximaSimultanea,
    this.tieneDescanso = false,
    this.horaInicioDescanso,
    this.horaFinDescanso,
    this.duracionDescansoMinutos,
  });

  /// Verificar a qué entidad pertenece el horario
  TipoEntidadHorario get tipoEntidad {
    if (tiendaId != null) return TipoEntidadHorario.tienda;
    if (plazoletaId != null) return TipoEntidadHorario.plazoleta;
    if (organizacionId != null) return TipoEntidadHorario.organizacion;
    return TipoEntidadHorario.general;
  }

  /// Verificar si es horario normal (no especial)
  bool get esHorarioNormal => !esHorarioEspecial && tipoHorario == TipoHorario.normal;

  /// Verificar si es horario festivo
  bool get esHorarioFestivo => tipoHorario == TipoHorario.festivo;

  /// Verificar si es horario especial (temporal)
  bool get esHorarioTemporal => esHorarioEspecial;

  /// Calcular duración total del horario en minutos
  int get duracionTotalMinutos {
    final apertura = horaApertura.hour * 60 + horaApertura.minute;
    final cierre = horaCierre.hour * 60 + horaCierre.minute;
    return cierre - apertura;
  }

  /// Calcular duración en horas (formato decimal)
  double get duracionHoras => duracionTotalMinutos / 60.0;

  /// Verificar si el horario está activo ahora mismo
  bool get estaAbiertoAhora {
    final ahora = TimeOfDay.now();
    return estaAbiertoEnHorario(ahora);
  }

  /// Verificar si está abierto en un horario específico
  bool estaAbiertoEnHorario(TimeOfDay horario) {
    if (!activo) return false;

    // Verificar si es horario especial y está dentro del rango de fechas
    if (esHorarioEspecial) {
      final ahora = DateTime.now();
      if (fechaInicioEspecial != null && ahora.isBefore(fechaInicioEspecial!)) {
        return false;
      }
      if (fechaFinEspecial != null && ahora.isAfter(fechaFinEspecial!)) {
        return false;
      }
    }

    // Verificar si es el día correcto
    final hoy = DateTime.now().weekday;
    final diaHorario = _convertirDiaSemanaAWeekday(diaSemana);
    if (hoy != diaHorario) return false;

    // Verificar rango de horario
    final minutosHorario = horario.hour * 60 + horario.minute;
    final minutosApertura = horaApertura.hour * 60 + horaApertura.minute;
    final minutosCierre = horaCierre.hour * 60 + horaCierre.minute;

    // Verificar descanso si existe
    if (tieneDescanso && horaInicioDescanso != null && horaFinDescanso != null) {
      final minutosInicioDescanso = horaInicioDescanso!.hour * 60 + horaInicioDescanso!.minute;
      final minutosFinDescanso = horaFinDescanso!.hour * 60 + horaFinDescanso!.minute;

      if (minutosHorario >= minutosInicioDescanso && minutosHorario <= minutosFinDescanso) {
        return false;
      }
    }

    return minutosHorario >= minutosApertura && minutosHorario <= minutosCierre;
  }

  /// Verificar si permite citas en un horario específico
  bool permiteCitaEnHorario(TimeOfDay horario) {
    if (!permiteCitas) return false;
    if (!estaAbiertoEnHorario(horario)) return false;

    if (horaInicioCitas != null && horaFinCitas != null) {
      final minutosHorario = horario.hour * 60 + horario.minute;
      final minutosInicioCitas = horaInicioCitas!.hour * 60 + horaInicioCitas!.minute;
      final minutosFinCitas = horaFinCitas!.hour * 60 + horaFinCitas!.minute;

      return minutosHorario >= minutosInicioCitas && minutosHorario <= minutosFinCitas;
    }

    return true;
  }

  /// Obtener próximo horario disponible para cita
  TimeOfDay? get proximoHorarioCitaDisponible {
    if (!permiteCitas) return null;

    final ahora = TimeOfDay.now();
    if (permiteCitaEnHorario(ahora)) return ahora;

    // Buscar próximo horario disponible basado en intervalo de citas
    if (intervaloCitaMinutos != null) {
      final minutosAhora = ahora.hour * 60 + ahora.minute;
      final minutosApertura = horaApertura.hour * 60 + horaApertura.minute;

      // Calcular próximo intervalo disponible
      var proximoMinuto = minutosAhora + intervaloCitaMinutos!;
      while (proximoMinuto <= (horaCierre.hour * 60 + horaCierre.minute)) {
        final proximoHorario = TimeOfDay(
          hour: proximoMinuto ~/ 60,
          minute: proximoMinuto % 60,
        );

        if (permiteCitaEnHorario(proximoHorario)) {
          return proximoHorario;
        }

        proximoMinuto += intervaloCitaMinutos!;
      }
    }

    return null;
  }

  /// Verificar si requiere reserva con anticipación
  bool requiereReservaConAnticipacion(DateTime fechaReserva) {
    if (!requiereReserva) return false;
    if (anticipacionMinimaReserva == null) return true;

    final diferencia = fechaReserva.difference(DateTime.now());
    return diferencia.inMinutes >= anticipacionMinimaReserva!;
  }

  /// Obtener horario formateado para mostrar
  String get horarioFormateado {
    final apertura = _formatearTimeOfDay(horaApertura);
    final cierre = _formatearTimeOfDay(horaCierre);

    if (tieneDescanso && horaInicioDescanso != null && horaFinDescanso != null) {
      final inicioDescanso = _formatearTimeOfDay(horaInicioDescanso!);
      final finDescanso = _formatearTimeOfDay(horaFinDescanso!);
      return '$apertura - $cierre (Descanso: $inicioDescanso - $finDescanso)';
    }

    return '$apertura - $cierre';
  }

  /// Obtener descripción del tipo de horario
  String get tipoDescripcion {
    switch (tipoHorario) {
      case TipoHorario.normal:
        return esHorarioEspecial ? 'Especial' : 'Normal';
      case TipoHorario.festivo:
        return 'Festivo';
      case TipoHorario.especial:
        return 'Especial';
    }
  }

  /// Copiar con nuevos valores
  Horario copyWith({
    int? id,
    int? tiendaId,
    int? plazoletaId,
    int? organizacionId,
    DiaSemana? diaSemana,
    TimeOfDay? horaApertura,
    TimeOfDay? horaCierre,
    TipoHorario? tipoHorario,
    bool? activo,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
    String? notas,
    Map<String, dynamic>? metadata,
    bool? esHorarioEspecial,
    String? motivoEspecial,
    DateTime? fechaInicioEspecial,
    DateTime? fechaFinEspecial,
    bool? permiteCitas,
    int? duracionCitaMinutos,
    int? intervaloCitaMinutos,
    TimeOfDay? horaInicioCitas,
    TimeOfDay? horaFinCitas,
    bool? requiereReserva,
    int? anticipacionMinimaReserva,
    int? capacidadMaximaSimultanea,
    bool? tieneDescanso,
    TimeOfDay? horaInicioDescanso,
    TimeOfDay? horaFinDescanso,
    int? duracionDescansoMinutos,
  }) {
    return Horario(
      id: id ?? this.id,
      tiendaId: tiendaId ?? this.tiendaId,
      plazoletaId: plazoletaId ?? this.plazoletaId,
      organizacionId: organizacionId ?? this.organizacionId,
      diaSemana: diaSemana ?? this.diaSemana,
      horaApertura: horaApertura ?? this.horaApertura,
      horaCierre: horaCierre ?? this.horaCierre,
      tipoHorario: tipoHorario ?? this.tipoHorario,
      activo: activo ?? this.activo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      notas: notas ?? this.notas,
      metadata: metadata ?? this.metadata,
      esHorarioEspecial: esHorarioEspecial ?? this.esHorarioEspecial,
      motivoEspecial: motivoEspecial ?? this.motivoEspecial,
      fechaInicioEspecial: fechaInicioEspecial ?? this.fechaInicioEspecial,
      fechaFinEspecial: fechaFinEspecial ?? this.fechaFinEspecial,
      permiteCitas: permiteCitas ?? this.permiteCitas,
      duracionCitaMinutos: duracionCitaMinutos ?? this.duracionCitaMinutos,
      intervaloCitaMinutos: intervaloCitaMinutos ?? this.intervaloCitaMinutos,
      horaInicioCitas: horaInicioCitas ?? this.horaInicioCitas,
      horaFinCitas: horaFinCitas ?? this.horaFinCitas,
      requiereReserva: requiereReserva ?? this.requiereReserva,
      anticipacionMinimaReserva: anticipacionMinimaReserva ?? this.anticipacionMinimaReserva,
      capacidadMaximaSimultanea: capacidadMaximaSimultanea ?? this.capacidadMaximaSimultanea,
      tieneDescanso: tieneDescanso ?? this.tieneDescanso,
      horaInicioDescanso: horaInicioDescanso ?? this.horaInicioDescanso,
      horaFinDescanso: horaFinDescanso ?? this.horaFinDescanso,
      duracionDescansoMinutos: duracionDescansoMinutos ?? this.duracionDescansoMinutos,
    );
  }

  @override
  List<Object?> get props => [
    id,
    tiendaId,
    plazoletaId,
    organizacionId,
    diaSemana,
    horaApertura,
    horaCierre,
    tipoHorario,
    activo,
    fechaCreacion,
    fechaActualizacion,
    notas,
    metadata,
    esHorarioEspecial,
    motivoEspecial,
    fechaInicioEspecial,
    fechaFinEspecial,
    permiteCitas,
    duracionCitaMinutos,
    intervaloCitaMinutos,
    horaInicioCitas,
    horaFinCitas,
    requiereReserva,
    anticipacionMinimaReserva,
    capacidadMaximaSimultanea,
    tieneDescanso,
    horaInicioDescanso,
    horaFinDescanso,
    duracionDescansoMinutos,
  ];

  @override
  bool get stringify => true;

  // Métodos privados de utilidad
  int _convertirDiaSemanaAWeekday(DiaSemana dia) {
    switch (dia) {
      case DiaSemana.lunes:
        return DateTime.monday;
      case DiaSemana.martes:
        return DateTime.tuesday;
      case DiaSemana.miercoles:
        return DateTime.wednesday;
      case DiaSemana.jueves:
        return DateTime.thursday;
      case DiaSemana.viernes:
        return DateTime.friday;
      case DiaSemana.sabado:
        return DateTime.saturday;
      case DiaSemana.domingo:
        return DateTime.sunday;
    }
  }

  String _formatearTimeOfDay(TimeOfDay time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour > 12 ? hour - 12 : hour == 0 ? 12 : hour;
    return '$hour12:${minute.toString().padLeft(2, '0')} $period';
  }

  /// Métodos de negocio
  bool esCompatibleConHorario(Horario otroHorario) {
    // Verificar si los horarios se solapan
    if (diaSemana != otroHorario.diaSemana) return true;

    final thisStart = horaApertura.hour * 60 + horaApertura.minute;
    final thisEnd = horaCierre.hour * 60 + horaCierre.minute;
    final otherStart = otroHorario.horaApertura.hour * 60 + otroHorario.horaApertura.minute;
    final otherEnd = otroHorario.horaCierre.hour * 60 + otroHorario.horaCierre.minute;

    // Verificar solapamiento
    return thisEnd <= otherStart || thisStart >= otherEnd;
  }

  bool tieneSuficienteTiempoParaCita() {
    if (!permiteCitas || duracionCitaMinutos == null) return false;
    return duracionTotalMinutos >= duracionCitaMinutos!;
  }

  int? get citasDisponiblesPorDia {
    if (!permiteCitas || duracionCitaMinutos == null) return null;

    final tiempoDisponible = duracionTotalMinutos;
    if (tieneDescanso && duracionDescansoMinutos != null) {
      return (tiempoDisponible - duracionDescansoMinutos!) ~/ duracionCitaMinutos!;
    }

    return tiempoDisponible ~/ duracionCitaMinutos!;
  }

  bool esHorarioExtendido() {
    return duracionHoras > 8; // Más de 8 horas se considera extendido
  }

  bool esHorarioReducido() {
    return duracionHoras < 4; // Menos de 4 horas se considera reducido
  }

  bool esHorarioNocturno() {
    return horaApertura.hour >= 18 || horaCierre.hour <= 6;
  }

  bool esHorarioMatutino() {
    return horaApertura.hour < 12;
  }

  bool esHorarioVespertino() {
    return horaApertura.hour >= 12 && horaApertura.hour < 18;
  }

  String get franjaHoraria {
    if (esHorarioNocturno()) return 'Nocturno';
    if (esHorarioMatutino()) return 'Matutino';
    if (esHorarioVespertino()) return 'Vespertino';
    return 'Mixto';
  }

  bool necesitaActualizacion() {
    // Horarios inactivos por más de 30 días
    if (!activo && fechaActualizacion != null) {
      final treintaDiasAtras = DateTime.now().subtract(const Duration(days: 30));
      return fechaActualizacion!.isBefore(treintaDiasAtras);
    }

    // Horarios especiales que ya pasaron su fecha de fin
    if (esHorarioEspecial && fechaFinEspecial != null) {
      return DateTime.now().isAfter(fechaFinEspecial!);
    }

    return false;
  }

  /// Métodos de utilidad para UI
  String get diaSemanaFormateado {
    switch (diaSemana) {
      case DiaSemana.lunes:
        return 'Lunes';
      case DiaSemana.martes:
        return 'Martes';
      case DiaSemana.miercoles:
        return 'Miércoles';
      case DiaSemana.jueves:
        return 'Jueves';
      case DiaSemana.viernes:
        return 'Viernes';
      case DiaSemana.sabado:
        return 'Sábado';
      case DiaSemana.domingo:
        return 'Domingo';
    }
  }

  String get estadoDescripcion {
    if (!activo) return 'Inactivo';
    if (esHorarioEspecial) return 'Especial';
    return 'Activo';
  }

  String get entidadDescripcion {
    switch (tipoEntidad) {
      case TipoEntidadHorario.tienda:
        return 'Tienda';
      case TipoEntidadHorario.plazoleta:
        return 'Plazoleta';
      case TipoEntidadHorario.organizacion:
        return 'Organización';
      case TipoEntidadHorario.general:
        return 'General';
    }
  }

  List<String> get caracteristicasLista {
    final caracteristicas = <String>[];

    if (permiteCitas) caracteristicas.add('Permite citas');
    if (requiereReserva) caracteristicas.add('Requiere reserva');
    if (tieneDescanso) caracteristicas.add('Tiene descanso');
    if (esHorarioEspecial) caracteristicas.add('Horario especial');
    if (esHorarioFestivo) caracteristicas.add('Festivo');
    if (esHorarioExtendido()) caracteristicas.add('Horario extendido');
    if (esHorarioReducido()) caracteristicas.add('Horario reducido');
    if (esHorarioNocturno()) caracteristicas.add('Nocturno');

    return caracteristicas;
  }

  /// Métodos de negocio adicionales
  bool esHorarioValido() {
    // Verificar que la hora de apertura sea antes que la de cierre
    final minutosApertura = horaApertura.hour * 60 + horaApertura.minute;
    final minutosCierre = horaCierre.hour * 60 + horaCierre.minute;

    if (minutosApertura >= minutosCierre) {
      return false;
    }

    // Verificar descanso si existe
    if (tieneDescanso && horaInicioDescanso != null && horaFinDescanso != null) {
      final minutosInicioDescanso = horaInicioDescanso!.hour * 60 + horaInicioDescanso!.minute;
      final minutosFinDescanso = horaFinDescanso!.hour * 60 + horaFinDescanso!.minute;

      // Verificar que el descanso esté dentro del horario
      if (minutosInicioDescanso < minutosApertura || minutosFinDescanso > minutosCierre) {
        return false;
      }

      // Verificar que el inicio del descanso sea antes del fin
      if (minutosInicioDescanso >= minutosFinDescanso) {
        return false;
      }
    }

    // Verificar horario de citas si existe
    if (permiteCitas && horaInicioCitas != null && horaFinCitas != null) {
      final minutosInicioCitas = horaInicioCitas!.hour * 60 + horaInicioCitas!.minute;
      final minutosFinCitas = horaFinCitas!.hour * 60 + horaFinCitas!.minute;

      // Verificar que el horario de citas esté dentro del horario general
      if (minutosInicioCitas < minutosApertura || minutosFinCitas > minutosCierre) {
        return false;
      }

      // Verificar que el inicio de citas sea antes del fin
      if (minutosInicioCitas >= minutosFinCitas) {
        return false;
      }
    }

    return true;
  }

  bool puedeAtenderCantidadPersonas(int cantidad) {
    if (capacidadMaximaSimultanea == null) return true;
    return cantidad <= capacidadMaximaSimultanea!;
  }

  TimeOfDay? get siguienteIntervaloCita(TimeOfDay horarioActual) {
    if (!permiteCitas || intervaloCitaMinutos == null) return null;

    final minutosActual = horarioActual.hour * 60 + horarioActual.minute;
    final siguienteMinuto = minutosActual + intervaloCitaMinutos!;

    // Verificar que no exceda el horario de cierre
    final minutosCierreTotal = horaCierre.hour * 60 + horaCierre.minute;
    if (siguienteMinuto > minutosCierreTotal) return null;

    final siguienteHorario = TimeOfDay(
      hour: siguienteMinuto ~/ 60,
      minute: siguienteMinuto % 60,
    );

    // Verificar que esté dentro del horario de citas si existe
    if (horaInicioCitas != null && horaFinCitas != null) {
      final minutosInicioCitas = horaInicioCitas!.hour * 60 + horaInicioCitas!.minute;
      final minutosFinCitas = horaFinCitas!.hour * 60 + horaFinCitas!.minute;

      if (siguienteMinuto < minutosInicioCitas || siguienteMinuto > minutosFinCitas) {
        return null;
      }
    }

    return siguienteHorario;
  }

  bool estaDentroDeHorarioEspecial() {
    if (!esHorarioEspecial) return false;
    if (fechaInicioEspecial == null || fechaFinEspecial == null) return false;

    final ahora = DateTime.now();
    return ahora.isAfter(fechaInicioEspecial!) && ahora.isBefore(fechaFinEspecial!);
  }

  int? get tiempoRestanteHorarioEspecial() {
    if (!estaDentroDeHorarioEspecial() || fechaFinEspecial == null) return null;

    final ahora = DateTime.now();
    return fechaFinEspecial!.difference(ahora).inDays;
  }

  String? get motivoHorarioEspecialFormateado {
    if (!esHorarioEspecial || motivoEspecial == null) return null;
    return 'Motivo: $motivoEspecial';
  }

  bool esHorarioFlexible() {
    // Horario flexible si permite citas y tiene intervalo definido
    return permiteCitas && intervaloCitaMinutos != null;
  }

  bool esHorarioEstricto() {
    // Horario estricto si requiere reserva con anticipación
    return requiereReserva && anticipacionMinimaReserva != null;
  }

  String get nivelFlexibilidad {
    if (esHorarioFlexible()) return 'Flexible';
    if (esHorarioEstricto()) return 'Estricto';
    return 'Normal';
  }

  bool esMejorHorarioQue(Horario otro, {bool porDuracion = true}) {
    if (porDuracion) {
      return duracionHoras > otro.duracionHoras;
    } else {
      // Comparar por flexibilidad
      final flexibilidadEsta = esHorarioFlexible() ? 2 : (esHorarioEstricto() ? 0 : 1);
      final flexibilidadOtro = otro.esHorarioFlexible() ? 2 : (otro.esHorarioEstricto() ? 0 : 1);
      return flexibilidadEsta > flexibilidadOtro;
    }
  }
}
