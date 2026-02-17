// lib/domain/entities/sistema_entidades.dart

import 'package:equatable/equatable.dart';

import 'enums.dart';

// ==============================================
// INTERACCIÓN
// ==============================================

/// Entidad de dominio para Interacción (tracking de engagement)
class Interaccion extends Equatable {
  final int id;
  final int usuarioId;
  final String tipoEntidad; // 'tienda', 'producto', 'plazoleta', 'organizacion'
  final int entidadId;
  final TipoInteraccion tipoInteraccion;
  final DateTime fechaInteraccion;
  final Map<String, dynamic>? metadata;
  final String? dispositivo;
  final String? plataforma;
  final String? versionApp;
  final String? ubicacion;
  final double? latitud;
  final double? longitud;
  final int? duracionSegundos;
  final String? referencia;
  final bool sincronizado;
  final DateTime? fechaSincronizacion;

  const Interaccion({
    required this.id,
    required this.usuarioId,
    required this.tipoEntidad,
    required this.entidadId,
    required this.tipoInteraccion,
    required this.fechaInteraccion,
    this.metadata,
    this.dispositivo,
    this.plataforma,
    this.versionApp,
    this.ubicacion,
    this.latitud,
    this.longitud,
    this.duracionSegundos,
    this.referencia,
    this.sincronizado = false,
    this.fechaSincronizacion,
  });

  /// Verificar si es interacción reciente (menos de 1 hora)
  bool get esReciente {
    final unaHoraAtras = DateTime.now().subtract(const Duration(hours: 1));
    return fechaInteraccion.isAfter(unaHoraAtras);
  }

  /// Verificar si es interacción de hoy
  bool get esDeHoy {
    final hoy = DateTime.now();
    return fechaInteraccion.year == hoy.year &&
        fechaInteraccion.month == hoy.month &&
        fechaInteraccion.day == hoy.day;
  }

  /// Verificar si tiene ubicación geográfica
  bool get tieneUbicacion => latitud != null && longitud != null;

  /// Verificar si es interacción de visualización
  bool get esVisualizacion => tipoInteraccion == TipoInteraccion.visualizacion;

  /// Verificar si es interacción de clic en WhatsApp
  bool get esClickWhatsapp => tipoInteraccion == TipoInteraccion.clickWhatsapp;

  /// Verificar si es interacción de favorito
  bool get esFavorito => tipoInteraccion == TipoInteraccion.favorito;

  /// Verificar si es interacción de compartido
  bool get esCompartido => tipoInteraccion == TipoInteraccion.compartido;

  /// Obtener descripción del tipo de interacción
  String get tipoDescripcion {
    switch (tipoInteraccion) {
      case TipoInteraccion.visualizacion:
        return 'Visualización';
      case TipoInteraccion.clickWhatsapp:
        return 'Click WhatsApp';
      case TipoInteraccion.compartido:
        return 'Compartido';
      case TipoInteraccion.clickInstagram:
        return 'Click Instagram';
      case TipoInteraccion.clickFacebook:
        return 'Click Facebook';
      case TipoInteraccion.favorito:
        return 'Favorito';
    }
  }

  /// Copiar con nuevos valores
  Interaccion copyWith({
    int? id,
    int? usuarioId,
    String? tipoEntidad,
    int? entidadId,
    TipoInteraccion? tipoInteraccion,
    DateTime? fechaInteraccion,
    Map<String, dynamic>? metadata,
    String? dispositivo,
    String? plataforma,
    String? versionApp,
    String? ubicacion,
    double? latitud,
    double? longitud,
    int? duracionSegundos,
    String? referencia,
    bool? sincronizado,
    DateTime? fechaSincronizacion,
  }) {
    return Interaccion(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      tipoEntidad: tipoEntidad ?? this.tipoEntidad,
      entidadId: entidadId ?? this.entidadId,
      tipoInteraccion: tipoInteraccion ?? this.tipoInteraccion,
      fechaInteraccion: fechaInteraccion ?? this.fechaInteraccion,
      metadata: metadata ?? this.metadata,
      dispositivo: dispositivo ?? this.dispositivo,
      plataforma: plataforma ?? this.plataforma,
      versionApp: versionApp ?? this.versionApp,
      ubicacion: ubicacion ?? this.ubicacion,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      duracionSegundos: duracionSegundos ?? this.duracionSegundos,
      referencia: referencia ?? this.referencia,
      sincronizado: sincronizado ?? this.sincronizado,
      fechaSincronizacion: fechaSincronizacion ?? this.fechaSincronizacion,
    );
  }

  @override
  List<Object?> get props => [
        id,
        usuarioId,
        tipoEntidad,
        entidadId,
        tipoInteraccion,
        fechaInteraccion,
        metadata,
        dispositivo,
        plataforma,
        versionApp,
        ubicacion,
        latitud,
        longitud,
        duracionSegundos,
        referencia,
        sincronizado,
        fechaSincronizacion,
      ];

  @override
  bool get stringify => true;
}

// ==============================================
// ESTADÍSTICAS DIARIAS
// ==============================================

/// Entidad de dominio para Estadísticas Diarias (métricas analíticas)
class EstadisticasDiarias extends Equatable {
  final int id;
  final DateTime fecha;
  final String tipoEntidad; // 'tienda', 'producto', 'plazoleta', 'organizacion', 'global'
  final int? entidadId;
  final int totalVisitas;
  final int totalInteracciones;
  final int totalFavoritos;
  final int totalCompartidos;
  final int totalClicksWhatsapp;
  final int totalClicksInstagram;
  final int totalClicksFacebook;
  final int nuevosUsuarios;
  final int usuariosActivos;
  final int? ingresosTotales;
  final String? monedaIngresos;
  final int productosVendidos;
  final int? promedioTiempoSesion; // en segundos
  final double? tasaRebote;
  final Map<String, dynamic>? metricasAdicionales;
  final DateTime fechaCalculo;
  final bool consolidado;

  const EstadisticasDiarias({
    required this.id,
    required this.fecha,
    required this.tipoEntidad,
    this.entidadId,
    this.totalVisitas = 0,
    this.totalInteracciones = 0,
    this.totalFavoritos = 0,
    this.totalCompartidos = 0,
    this.totalClicksWhatsapp = 0,
    this.totalClicksInstagram = 0,
    this.totalClicksFacebook = 0,
    this.nuevosUsuarios = 0,
    this.usuariosActivos = 0,
    this.ingresosTotales,
    this.monedaIngresos,
    this.productosVendidos = 0,
    this.promedioTiempoSesion,
    this.tasaRebote,
    this.metricasAdicionales,
    required this.fechaCalculo,
    this.consolidado = false,
  });

  /// Calcular total de engagement
  int get totalEngagement =>
      totalInteracciones +
      totalFavoritos +
      totalCompartidos +
      totalClicksWhatsapp +
      totalClicksInstagram +
      totalClicksFacebook;

  /// Calcular tasa de conversión (si hay ingresos)
  double? get tasaConversion {
    if (totalVisitas == 0 || ingresosTotales == null) return null;
    return (productosVendidos / totalVisitas) * 100;
  }

  /// Verificar si son estadísticas globales
  bool get esGlobal => tipoEntidad == 'global';

  /// Verificar si son estadísticas de entidad específica
  bool get esDeEntidad => entidadId != null;

  /// Verificar si es día de alta actividad
  bool get esDiaAltaActividad {
    return totalVisitas > 1000 ||
        totalInteracciones > 500 ||
        usuariosActivos > 200;
  }

  /// Verificar si es día de baja actividad
  bool get esDiaBajaActividad {
    return totalVisitas < 100 &&
        totalInteracciones < 50 &&
        usuariosActivos < 20;
  }

  /// Calcular valor por usuario activo
  double? get valorPorUsuarioActivo {
    if (usuariosActivos == 0 || ingresosTotales == null) return null;
    return ingresosTotales! / usuariosActivos;
  }

  /// Obtener día de la semana
  String get diaSemana {
    switch (fecha.weekday) {
      case DateTime.monday:
        return 'Lunes';
      case DateTime.tuesday:
        return 'Martes';
      case DateTime.wednesday:
        return 'Miércoles';
      case DateTime.thursday:
        return 'Jueves';
      case DateTime.friday:
        return 'Viernes';
      case DateTime.saturday:
        return 'Sábado';
      case DateTime.sunday:
        return 'Domingo';
      default:
        return 'Desconocido';
    }
  }

  /// Copiar con nuevos valores
  EstadisticasDiarias copyWith({
    int? id,
    DateTime? fecha,
    String? tipoEntidad,
    int? entidadId,
    int? totalVisitas,
    int? totalInteracciones,
    int? totalFavoritos,
    int? totalCompartidos,
    int? totalClicksWhatsapp,
    int? totalClicksInstagram,
    int? totalClicksFacebook,
    int? nuevosUsuarios,
    int? usuariosActivos,
    int? ingresosTotales,
    String? monedaIngresos,
    int? productosVendidos,
    int? promedioTiempoSesion,
    double? tasaRebote,
    Map<String, dynamic>? metricasAdicionales,
    DateTime? fechaCalculo,
    bool? consolidado,
  }) {
    return EstadisticasDiarias(
      id: id ?? this.id,
      fecha: fecha ?? this.fecha,
      tipoEntidad: tipoEntidad ?? this.tipoEntidad,
      entidadId: entidadId ?? this.entidadId,
      totalVisitas: totalVisitas ?? this.totalVisitas,
      totalInteracciones: totalInteracciones ?? this.totalInteracciones,
      totalFavoritos: totalFavoritos ?? this.totalFavoritos,
      totalCompartidos: totalCompartidos ?? this.totalCompartidos,
      totalClicksWhatsapp: totalClicksWhatsapp ?? this.totalClicksWhatsapp,
      totalClicksInstagram: totalClicksInstagram ?? this.totalClicksInstagram,
      totalClicksFacebook: totalClicksFacebook ?? this.totalClicksFacebook,
      nuevosUsuarios: nuevosUsuarios ?? this.nuevosUsuarios,
      usuariosActivos: usuariosActivos ?? this.usuariosActivos,
      ingresosTotales: ingresosTotales ?? this.ingresosTotales,
      monedaIngresos: monedaIngresos ?? this.monedaIngresos,
      productosVendidos: productosVendidos ?? this.productosVendidos,
      promedioTiempoSesion: promedioTiempoSesion ?? this.promedioTiempoSesion,
      tasaRebote: tasaRebote ?? this.tasaRebote,
      metricasAdicionales: metricasAdicionales ?? this.metricasAdicionales,
      fechaCalculo: fechaCalculo ?? this.fechaCalculo,
      consolidado: consolidado ?? this.consolidado,
    );
  }

  @override
  List<Object?> get props => [
        id,
        fecha,
        tipoEntidad,
        entidadId,
        totalVisitas,
        totalInteracciones,
        totalFavoritos,
        totalCompartidos,
        totalClicksWhatsapp,
        totalClicksInstagram,
        totalClicksFacebook,
        nuevosUsuarios,
        usuariosActivos,
        ingresosTotales,
        monedaIngresos,
        productosVendidos,
        promedioTiempoSesion,
        tasaRebote,
        metricasAdicionales,
        fechaCalculo,
        consolidado,
      ];

  @override
  bool get stringify => true;
}

// ==============================================
// MIEMBROS ORGANIZACIÓN
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
      depart
