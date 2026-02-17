// lib/domain/entities/notificacion.dart

import 'package:equatable/equatable.dart';

import 'enums.dart';

// ==============================================
// MIEMBROS ORGANIZACIÓN (completar)
// ==============================================

/// Entidad de dominio para Miembros de Organización
class MiembroOrganizacion extends Equatable {
  final int id;
  final int organizacionId;
  final int usuarioId;
  final EstadoMiembro estado;
  final String? rol;
  final DateTime fechaIngreso;
  final DateTime? fechaSalida;
  final String? motivoSalida;
  final Map<String, dynamic>? permisos;
  final Map<String, dynamic>? metadata;
  final bool esAdministrador;
  final bool puedeGestionarMiembros;
  final bool puedeGestionarTiendas;
  final bool puedeGestionarProductos;
  final bool puedeVerEstadisticas;
  final String? departamento;
  final String? cargo;
  final String? telefonoContacto;
  final String? emailContacto;
  final DateTime? fechaUltimaActividad;
  final int? contribucionesTotales;

  const MiembroOrganizacion({
    required this.id,
    required this.organizacionId,
    required this.usuarioId,
    required this.estado,
    this.rol,
    required this.fechaIngreso,
    this.fechaSalida,
    this.motivoSalida,
    this.permisos,
    this.metadata,
    this.esAdministrador = false,
    this.puedeGestionarMiembros = false,
    this.puedeGestionarTiendas = false,
    this.puedeGestionarProductos = false,
    this.puedeVerEstadisticas = false,
    this.departamento,
    this.cargo,
    this.telefonoContacto,
    this.emailContacto,
    this.fechaUltimaActividad,
    this.contribucionesTotales,
  });

  /// Verificar si el miembro está activo
  bool get estaActivo => estado == EstadoMiembro.activo;

  /// Verificar si el miembro está pendiente
  bool get estaPendiente => estado == EstadoMiembro.pendiente;

  /// Verificar si el miembro fue rechazado
  bool get fueRechazado => estado == EstadoMiembro.rechazado;

  /// Verificar si el miembro ha salido de la organización
  bool get haSalido => fechaSalida != null;

  /// Calcular tiempo como miembro (en días)
  int get tiempoComoMiembro {
    final fechaFin = fechaSalida ?? DateTime.now();
    return fechaFin.difference(fechaIngreso).inDays;
  }

  /// Verificar si es miembro reciente (menos de 30 días)
  bool get esReciente => tiempoComoMiembro < 30;

  /// Verificar si es miembro veterano (más de 365 días)
  bool get esVeterano => tiempoComoMiembro > 365;

  /// Verificar si tiene permisos de administrador
  bool get tienePermisosAdministrador => esAdministrador;

  /// Verificar si tiene permisos completos
  bool get tienePermisosCompletos =>
      puedeGestionarMiembros &&
      puedeGestionarTiendas &&
      puedeGestionarProductos &&
      puedeVerEstadisticas;

  /// Verificar si tiene información de contacto
  bool get tieneContacto => telefonoContacto != null || emailContacto != null;

  /// Verificar si está activo recientemente (últimos 7 días)
  bool get estaActivoRecientemente {
    if (fechaUltimaActividad == null) return false;
    final sieteDiasAtras = DateTime.now().subtract(const Duration(days: 7));
    return fechaUltimaActividad!.isAfter(sieteDiasAtras);
  }

  /// Obtener nivel de contribución
  String get nivelContribucion {
    if (contribucionesTotales == null) return 'Sin contribuciones';
    if (contribucionesTotales! > 100) return 'Alta';
    if (contribucionesTotales! > 50) return 'Media';
    if (contribucionesTotales! > 10) return 'Baja';
    return 'Mínima';
  }

  /// Copiar con nuevos valores
  MiembroOrganizacion copyWith({
    int? id,
    int? organizacionId,
    int? usuarioId,
    EstadoMiembro? estado,
    String? rol,
    DateTime? fechaIngreso,
    DateTime? fechaSalida,
    String? motivoSalida,
    Map<String, dynamic>? permisos,
    Map<String, dynamic>? metadata,
    bool? esAdministrador,
    bool? puedeGestionarMiembros,
    bool? puedeGestionarTiendas,
    bool? puedeGestionarProductos,
    bool? puedeVerEstadisticas,
    String? departamento,
    String? cargo,
    String? telefonoContacto,
    String? emailContacto,
    DateTime? fechaUltimaActividad,
    int? contribucionesTotales,
  }) {
    return MiembroOrganizacion(
      id: id ?? this.id,
      organizacionId: organizacionId ?? this.organizacionId,
      usuarioId: usuarioId ?? this.usuarioId,
      estado: estado ?? this.estado,
      rol: rol ?? this.rol,
      fechaIngreso: fechaIngreso ?? this.fechaIngreso,
      fechaSalida: fechaSalida ?? this.fechaSalida,
      motivoSalida: motivoSalida ?? this.motivoSalida,
      permisos: permisos ?? this.permisos,
      metadata: metadata ?? this.metadata,
      esAdministrador: esAdministrador ?? this.esAdministrador,
      puedeGestionarMiembros: puedeGestionarMiembros ?? this.puedeGestionarMiembros,
      puedeGestionarTiendas: puedeGestionarTiendas ?? this.puedeGestionarTiendas,
      puedeGestionarProductos: puedeGestionarProductos ?? this.puedeGestionarProductos,
      puedeVerEstadisticas: puedeVerEstadisticas ?? this.puedeVerEstadisticas,
      departamento: departamento ?? this.departamento,
      cargo: cargo ?? this.cargo,
      telefonoContacto: telefonoContacto ?? this.telefonoContacto,
      emailContacto: emailContacto ?? this.emailContacto,
      fechaUltimaActividad: fechaUltimaActividad ?? this.fechaUltimaActividad,
      contribucionesTotales: contribucionesTotales ?? this.contribucionesTotales,
    );
  }

  @override
  List<Object?> get props => [
        id,
        organizacionId,
        usuarioId,
        estado,
        rol,
        fechaIngreso,
        fechaSalida,
        motivoSalida,
        permisos,
        metadata,
        esAdministrador,
        puedeGestionarMiembros,
        puedeGestionarTiendas,
        puedeGestionarProductos,
        puedeVerEstadisticas,
        departamento,
        cargo,
        telefonoContacto,
        emailContacto,
        fechaUltimaActividad,
        contribucionesTotales,
      ];

  @override
  bool get stringify => true;
}

// ==============================================
// NOTIFICACIÓN
// ==============================================

/// Entidad de dominio para Notificación (sistema de notificaciones)
class Notificacion extends Equatable {
  final int id;
  final int usuarioId;
  final TipoNotificacion tipoNotificacion;
  final String titulo;
  final String mensaje;
  final bool leida;
  final DateTime fechaCreacion;
  final DateTime? fechaLectura;
  final Map<String, dynamic>? datosAdicionales;
  final String? accionUrl;
  final String? accionTexto;
  final int? entidadRelacionadaId;
  final String? tipoEntidadRelacionada;
  final bool enviadaPush;
  final bool enviadaEmail;
  final bool enviadaSms;
  final String? canalPreferido;
  final int? prioridad; // 1-5, donde 5 es más alta
  final DateTime? fechaExpiracion;
  final String? categoria;
  final Map<String, dynamic>? metadata;
  final bool programada;
  final DateTime? fechaProgramada;
  final bool enviada;
  final DateTime? fechaEnvio;
  final String? errorEnvio;

  const Notificacion({
    required this.id,
    required this.usuarioId,
    required this.tipoNotificacion,
    required this.titulo,
    required this.mensaje,
    this.leida = false,
    required this.fechaCreacion,
    this.fechaLectura,
    this.datosAdicionales,
    this.accionUrl,
    this.accionTexto,
    this.entidadRelacionadaId,
    this.tipoEntidadRelacionada,
    this.enviadaPush = false,
    this.enviadaEmail = false,
    this.enviadaSms = false,
    this.canalPreferido,
    this.prioridad = 3,
    this.fechaExpiracion,
    this.categoria,
    this.metadata,
    this.programada = false,
    this.fechaProgramada,
    this.enviada = false,
    this.fechaEnvio,
    this.errorEnvio,
  });

  /// Verificar si la notificación está expirada
  bool get estaExpirada {
    if (fechaExpiracion == null) return false;
    return DateTime.now().isAfter(fechaExpiracion!);
  }

  /// Verificar si la notificación está pendiente de envío
  bool get estaPendienteEnvio => programada && !enviada;

  /// Verificar si la notificación está programada para el futuro
  bool get estaProgramadaFuturo {
    if (!programada || fechaProgramada == null) return false;
    return fechaProgramada!.isAfter(DateTime.now());
  }

  /// Verificar si la notificación es urgente (prioridad alta)
  bool get esUrgente => prioridad != null && prioridad! >= 4;

  /// Verificar si la notificación es importante (prioridad media-alta)
  bool get esImportante => prioridad != null && prioridad! >= 3;

  ///
