// lib/domain/entities/organizacion.dart

import 'package:equatable/equatable.dart';

import 'enums.dart';

/// Entidad de dominio para Organización (grupos/colectivos de emprendedores)
class Organizacion extends Equatable {
  final int id;
  final String nombre;
  final String? descripcion;
  final TipoOrganizacion tipoOrganizacion;
  final String? nit;
  final String? representanteLegal;
  final String? emailContacto;
  final String? telefonoContacto;
  final String? direccion;
  final String? ciudad;
  final String? departamento;
  final String? pais;
  final String? sitioWeb;
  final Map<String, dynamic>? redesSociales;
  final DateTime fechaCreacion;
  final DateTime? fechaActualizacion;
  final bool activa;
  final String? logoUrl;
  final String? mision;
  final String? vision;
  final String? valores;
  final String? objetivos;
  final int totalMiembros;
  final int totalTiendas;
  final int totalProductos;
  final int totalVisitas;
  final double? calificacionPromedio;
  final Map<String, dynamic>? metadata;
  final String? codigoOrganizacion;
  final String? categoriaFiscal;
  final String? regimenTributario;
  final DateTime? fechaConstitucion;
  final String? actaConstitucion;
  final String? certificadoCamaraComercio;
  final String? certificadoRut;
  final bool verificado;
  final String? nivelVerificacion;
  final List<String>? beneficios;
  final List<String>? serviciosOfrecidos;
  final String? terminosCondiciones;
  final String? politicaPrivacidad;
  final String? politicaDatos;

  const Organizacion({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.tipoOrganizacion,
    this.nit,
    this.representanteLegal,
    this.emailContacto,
    this.telefonoContacto,
    this.direccion,
    this.ciudad,
    this.departamento,
    this.pais,
    this.sitioWeb,
    this.redesSociales,
    required this.fechaCreacion,
    this.fechaActualizacion,
    required this.activa,
    this.logoUrl,
    this.mision,
    this.vision,
    this.valores,
    this.objetivos,
    this.totalMiembros = 0,
    this.totalTiendas = 0,
    this.totalProductos = 0,
    this.totalVisitas = 0,
    this.calificacionPromedio,
    this.metadata,
    this.codigoOrganizacion,
    this.categoriaFiscal,
    this.regimenTributario,
    this.fechaConstitucion,
    this.actaConstitucion,
    this.certificadoCamaraComercio,
    this.certificadoRut,
    this.verificado = false,
    this.nivelVerificacion,
    this.beneficios,
    this.serviciosOfrecidos,
    this.terminosCondiciones,
    this.politicaPrivacidad,
    this.politicaDatos,
  });

  /// Verificar si la organización está activa y verificada
  bool get completamenteOperativa => activa && verificado;

  /// Verificar si tiene información legal completa
  bool get tieneInformacionLegalCompleta {
    return nit != null &&
        representanteLegal != null &&
        direccion != null &&
        categoriaFiscal != null;
  }

  /// Verificar si tiene documentos legales
  bool get tieneDocumentosLegales {
    return actaConstitucion != null ||
        certificadoCamaraComercio != null ||
        certificadoRut != null;
  }

  /// Verificar si tiene información de contacto
  bool get tieneContacto => emailContacto != null || telefonoContacto != null;

  /// Verificar si tiene sitio web
  bool get tieneSitioWeb => sitioWeb != null && sitioWeb!.isNotEmpty;

  /// Verificar si tiene redes sociales
  bool get tieneRedesSociales =>
      redesSociales != null && redesSociales!.isNotEmpty;

  /// Verificar si es una organización grande
  bool get esGrande => totalMiembros > 50 || totalTiendas > 20;

  /// Verificar si es una organización mediana
  bool get esMediana => totalMiembros > 10 && totalMiembros <= 50;

  /// Verificar si es una organización pequeña
  bool get esPequena => totalMiembros <= 10;

  /// Obtener lista de redes sociales disponibles
  List<String>? get redesSocialesDisponibles {
    if (redesSociales == null) return null;
    return redesSociales!.keys.toList();
  }

  /// Obtener URL de una red social específica
  String? getRedSocialUrl(String redSocial) {
    return redesSociales?[redSocial] as String?;
  }

  /// Verificar si tiene beneficios específicos
  bool tieneBeneficio(String beneficio) {
    return beneficios?.contains(beneficio) ?? false;
  }

  /// Verificar si ofrece servicios específicos
  bool ofreceServicio(String servicio) {
    return serviciosOfrecidos?.contains(servicio) ?? false;
  }

  /// Copiar con nuevos valores
  Organizacion copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    TipoOrganizacion? tipoOrganizacion,
    String? nit,
    String? representanteLegal,
    String? emailContacto,
    String? telefonoContacto,
    String? direccion,
    String? ciudad,
    String? departamento,
    String? pais,
    String? sitioWeb,
    Map<String, dynamic>? redesSociales,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
    bool? activa,
    String? logoUrl,
    String? mision,
    String? vision,
    String? valores,
    String? objetivos,
    int? totalMiembros,
    int? totalTiendas,
    int? totalProductos,
    int? totalVisitas,
    double? calificacionPromedio,
    Map<String, dynamic>? metadata,
    String? codigoOrganizacion,
    String? categoriaFiscal,
    String? regimenTributario,
    DateTime? fechaConstitucion,
    String? actaConstitucion,
    String? certificadoCamaraComercio,
    String? certificadoRut,
    bool? verificado,
    String? nivelVerificacion,
    List<String>? beneficios,
    List<String>? serviciosOfrecidos,
    String? terminosCondiciones,
    String? politicaPrivacidad,
    String? politicaDatos,
  }) {
    return Organizacion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      tipoOrganizacion: tipoOrganizacion ?? this.tipoOrganizacion,
      nit: nit ?? this.nit,
      representanteLegal: representanteLegal ?? this.representanteLegal,
      emailContacto: emailContacto ?? this.emailContacto,
      telefonoContacto: telefonoContacto ?? this.telefonoContacto,
      direccion: direccion ?? this.direccion,
      ciudad: ciudad ?? this.ciudad,
      departamento: departamento ?? this.departamento,
      pais: pais ?? this.pais,
      sitioWeb: sitioWeb ?? this.sitioWeb,
      redesSociales: redesSociales ?? this.redesSociales,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      activa: activa ?? this.activa,
      logoUrl: logoUrl ?? this.logoUrl,
      mision: mision ?? this.mision,
      vision: vision ?? this.vision,
      valores: valores ?? this.valores,
      objetivos: objetivos ?? this.objetivos,
      totalMiembros: totalMiembros ?? this.totalMiembros,
      totalTiendas: totalTiendas ?? this.totalTiendas,
      totalProductos: totalProductos ?? this.totalProductos,
      totalVisitas: totalVisitas ?? this.totalVisitas,
      calificacionPromedio: calificacionPromedio ?? this.calificacionPromedio,
      metadata: metadata ?? this.metadata,
      codigoOrganizacion: codigoOrganizacion ?? this.codigoOrganizacion,
      categoriaFiscal: categoriaFiscal ?? this.categoriaFiscal,
      regimenTributario: regimenTributario ?? this.regimenTributario,
      fechaConstitucion: fechaConstitucion ?? this.fechaConstitucion,
      actaConstitucion: actaConstitucion ?? this.actaConstitucion,
      certificadoCamaraComercio:
          certificadoCamaraComercio ?? this.certificadoCamaraComercio,
      certificadoRut: certificadoRut ?? this.certificadoRut,
      verificado: verificado ?? this.verificado,
      nivelVerificacion: nivelVerificacion ?? this.nivelVerificacion,
      beneficios: beneficios ?? this.beneficios,
      serviciosOfrecidos: serviciosOfrecidos ?? this.serviciosOfrecidos,
      terminosCondiciones: terminosCondiciones ?? this.terminosCondiciones,
      politicaPrivacidad: politicaPrivacidad ?? this.politicaPrivacidad,
      politicaDatos: politicaDatos ?? this.politicaDatos,
    );
  }

  @override
  List<Object?> get props => [
    id,
    nombre,
    descripcion,
    tipoOrganizacion,
    nit,
    representanteLegal,
    emailContacto,
    telefonoContacto,
    direccion,
    ciudad,
    departamento,
    pais,
    sitioWeb,
    redesSociales,
    fechaCreacion,
    fechaActualizacion,
    activa,
    logoUrl,
    mision,
    vision,
    valores,
    objetivos,
    totalMiembros,
    totalTiendas,
    totalProductos,
    totalVisitas,
    calificacionPromedio,
    metadata,
    codigoOrganizacion,
    categoriaFiscal,
    regimenTributario,
    fechaConstitucion,
    actaConstitucion,
    certificadoCamaraComercio,
    certificadoRut,
    verificado,
    nivelVerificacion,
    beneficios,
    serviciosOfrecidos,
    terminosCondiciones,
    politicaPrivacidad,
    politicaDatos,
  ];

  @override
  bool get stringify => true;

  /// Métodos de utilidad para UI
  String get resumenContacto {
    final contactos = <String>[];
    if (emailContacto != null) contactos.add(emailContacto!);
    if (telefonoContacto != null) contactos.add(telefonoContacto!);
    return contactos.join(' | ');
  }

  String get resumenUbicacion {
    final partes = <String>[];
    if (ciudad != null) partes.add(ciudad!);
    if (departamento != null) partes.add(departamento!);
    if (pais != null) partes.add(pais!);
    return partes.join(', ');
  }

  String get estadoDescripcion {
    if (!activa) return 'Inactiva';
    if (!verificado) return 'Pendiente verificación';
    return 'Activa y verificada';
  }

  String get tamanoDescripcion {
    if (esGrande) return 'Grande';
    if (esMediana) return 'Mediana';
    return 'Pequeña';
  }

  List<String> get informacionLegalLista {
    final info = <String>[];
    if (nit != null) info.add('NIT: $nit');
    if (representanteLegal != null)
      info.add('Representante: $representanteLegal');
    if (categoriaFiscal != null) info.add('Categoría: $categoriaFiscal');
    if (regimenTributario != null) info.add('Régimen: $regimenTributario');
    return info;
  }

  /// Métodos de negocio
  bool puedeAgregarMiembro() {
    // Lógica de negocio: verificar límites de miembros según tipo de organización
    switch (tipoOrganizacion) {
      case TipoOrganizacion.fundacion:
        return totalMiembros < 100;
      case TipoOrganizacion.asociacion:
        return totalMiembros < 200;
      case TipoOrganizacion.cooperativa:
        return totalMiembros < 300;
      case TipoOrganizacion.empresa:
        return totalMiembros < 500;
      case TipoOrganizacion.comunidad:
        return totalMiembros < 1000;
      case TipoOrganizacion.otro:
        return true;
    }
  }

  bool puedeAgregarTienda() {
    // Lógica de negocio: organizaciones verificadas pueden tener más tiendas
    if (!verificado) return totalTiendas < 5;
    return totalTiendas < 50;
  }

  double get promedioProductosPorTienda {
    if (totalTiendas == 0) return 0.0;
    return totalProductos / totalTiendas;
  }

  bool esMasGrandeQue(Organizacion otra) {
    // Comparar por múltiples métricas
    final puntuacionEsta =
        totalMiembros * 3 + totalTiendas * 2 + totalProductos;
    final puntuacionOtra =
        otra.totalMiembros * 3 + otra.totalTiendas * 2 + otra.totalProductos;
    return puntuacionEsta > puntuacionOtra;
  }

  bool necesitaActualizarInformacion() {
    // Información considerada desactualizada si tiene más de 6 meses
    final seisMesesAtras = DateTime.now().subtract(const Duration(days: 180));
    return fechaActualizacion == null ||
        fechaActualizacion!.isBefore(seisMesesAtras);
  }

  String get nivelConfianza {
    if (!verificado) return 'Baja';
    if (totalMiembros < 10) return 'Media';
    if (totalMiembros < 50) return 'Alta';
    if (tieneDocumentosLegales) return 'Muy alta';
    return 'Alta';
  }
}
