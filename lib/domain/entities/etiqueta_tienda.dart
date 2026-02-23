// lib/domain/entities/etiqueta_tienda.dart

import 'package:equatable/equatable.dart';

/// Entidad de dominio para Etiqueta de Tienda (tags/categorías para tiendas)
class EtiquetaTienda extends Equatable {
  final int id;
  final String nombre;
  final String? descripcion;
  final String? icono;
  final String? color;
  final int ordenVisual;
  final bool activa;
  final DateTime fechaCreacion;
  final DateTime? fechaActualizacion;
  final Map<String, dynamic>? metadata;
  final int totalTiendas;
  final bool destacada;
  final String? categoria;
  final String? tipoEtiqueta;
  final int? limiteUso;
  final bool requiereAprobacion;
  final String? normasUso;
  final List<String>? etiquetasRelacionadas;
  final String? imagenUrl;
  final String? keywords;
  final bool esExclusiva;
  final int? nivelPrioridad;
  final String? grupo;
  final bool visiblePublico;
  final bool permiteAutoseleccion;
  final int? duracionPromocionDias;
  final String? condicionesEspeciales;

  const EtiquetaTienda({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.icono,
    this.color,
    required this.ordenVisual,
    required this.activa,
    required this.fechaCreacion,
    this.fechaActualizacion,
    this.metadata,
    this.totalTiendas = 0,
    this.destacada = false,
    this.categoria,
    this.tipoEtiqueta,
    this.limiteUso,
    this.requiereAprobacion = false,
    this.normasUso,
    this.etiquetasRelacionadas,
    this.imagenUrl,
    this.keywords,
    this.esExclusiva = false,
    this.nivelPrioridad,
    this.grupo,
    this.visiblePublico = true,
    this.permiteAutoseleccion = true,
    this.duracionPromocionDias,
    this.condicionesEspeciales,
  });

  /// Verificar si la etiqueta está disponible para uso
  bool get disponibleParaUso {
    if (!activa) return false;
    if (!visiblePublico) return false;
    if (limiteUso != null && totalTiendas >= limiteUso!) return false;
    return true;
  }

  /// Verificar si es etiqueta destacada
  bool get esDestacada => destacada;

  /// Verificar si es etiqueta exclusiva
  bool get esExclusivaEtiqueta => esExclusiva;

  /// Verificar si requiere aprobación para uso
  bool get requiereAprobacionParaUso => requiereAprobacion;

  /// Verificar si permite autoselección
  bool get permiteSeleccionAutomatica => permiteAutoseleccion;

  /// Verificar si tiene límite de uso alcanzado
  bool get limiteAlcanzado {
    if (limiteUso == null) return false;
    return totalTiendas >= limiteUso!;
  }

  /// Calcular porcentaje de uso
  double get porcentajeUso {
    if (limiteUso == null || limiteUso == 0) return 0.0;
    return (totalTiendas / limiteUso!) * 100;
  }

  /// Verificar si es etiqueta popular (muchas tiendas)
  bool get esPopular => totalTiendas > 50;

  /// Verificar si es etiqueta emergente (crecimiento rápido)
  bool get esEmergente => totalTiendas > 10 && totalTiendas <= 50;

  /// Verificar si es etiqueta nueva (pocas tiendas)
  bool get esNueva => totalTiendas <= 10;

  /// Verificar si tiene estilo visual (icono y color)
  bool get tieneEstiloVisual => icono != null && color != null;

  /// Verificar si tiene imagen
  bool get tieneImagen => imagenUrl != null && imagenUrl!.isNotEmpty;

  /// Verificar si tiene descripción
  bool get tieneDescripcion => descripcion != null && descripcion!.isNotEmpty;

  /// Obtener nivel de prioridad (1-5, donde 5 es más alto)
  int get nivelPrioridadCalculado {
    if (nivelPrioridad != null) return nivelPrioridad!;
    if (destacada) return 4;
    if (esExclusiva) return 5;
    if (esPopular) return 3;
    if (esEmergente) return 2;
    return 1;
  }

  /// Copiar con nuevos valores
  EtiquetaTienda copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    String? icono,
    String? color,
    int? ordenVisual,
    bool? activa,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
    Map<String, dynamic>? metadata,
    int? totalTiendas,
    bool? destacada,
    String? categoria,
    String? tipoEtiqueta,
    int? limiteUso,
    bool? requiereAprobacion,
    String? normasUso,
    List<String>? etiquetasRelacionadas,
    String? imagenUrl,
    String? keywords,
    bool? esExclusiva,
    int? nivelPrioridad,
    String? grupo,
    bool? visiblePublico,
    bool? permiteAutoseleccion,
    int? duracionPromocionDias,
    String? condicionesEspeciales,
  }) {
    return EtiquetaTienda(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      icono: icono ?? this.icono,
      color: color ?? this.color,
      ordenVisual: ordenVisual ?? this.ordenVisual,
      activa: activa ?? this.activa,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      metadata: metadata ?? this.metadata,
      totalTiendas: totalTiendas ?? this.totalTiendas,
      destacada: destacada ?? this.destacada,
      categoria: categoria ?? this.categoria,
      tipoEtiqueta: tipoEtiqueta ?? this.tipoEtiqueta,
      limiteUso: limiteUso ?? this.limiteUso,
      requiereAprobacion: requiereAprobacion ?? this.requiereAprobacion,
      normasUso: normasUso ?? this.normasUso,
      etiquetasRelacionadas:
          etiquetasRelacionadas ?? this.etiquetasRelacionadas,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      keywords: keywords ?? this.keywords,
      esExclusiva: esExclusiva ?? this.esExclusiva,
      nivelPrioridad: nivelPrioridad ?? this.nivelPrioridad,
      grupo: grupo ?? this.grupo,
      visiblePublico: visiblePublico ?? this.visiblePublico,
      permiteAutoseleccion: permiteAutoseleccion ?? this.permiteAutoseleccion,
      duracionPromocionDias:
          duracionPromocionDias ?? this.duracionPromocionDias,
      condicionesEspeciales:
          condicionesEspeciales ?? this.condicionesEspeciales,
    );
  }

  @override
  List<Object?> get props => [
    id,
    nombre,
    descripcion,
    icono,
    color,
    ordenVisual,
    activa,
    fechaCreacion,
    fechaActualizacion,
    metadata,
    totalTiendas,
    destacada,
    categoria,
    tipoEtiqueta,
    limiteUso,
    requiereAprobacion,
    normasUso,
    etiquetasRelacionadas,
    imagenUrl,
    keywords,
    esExclusiva,
    nivelPrioridad,
    grupo,
    visiblePublico,
    permiteAutoseleccion,
    duracionPromocionDias,
    condicionesEspeciales,
  ];

  @override
  bool get stringify => true;

  /// Métodos de utilidad para UI
  String get estadoDescripcion {
    if (!activa) return 'Inactiva';
    if (destacada) return 'Destacada';
    if (esExclusiva) return 'Exclusiva';
    return 'Activa';
  }

  String get disponibilidadDescripcion {
    if (!disponibleParaUso) return 'No disponible';
    if (limiteAlcanzado) return 'Límite alcanzado';
    if (requiereAprobacion) return 'Requiere aprobación';
    return 'Disponible';
  }

  String get popularidadDescripcion {
    if (esPopular) return 'Muy popular';
    if (esEmergente) return 'En crecimiento';
    if (esNueva) return 'Nueva';
    return 'Estable';
  }

  List<String> get caracteristicasLista {
    final caracteristicas = <String>[];

    if (destacada) caracteristicas.add('Destacada');
    if (esExclusiva) caracteristicas.add('Exclusiva');
    if (requiereAprobacion) caracteristicas.add('Requiere aprobación');
    if (!permiteAutoseleccion) caracteristicas.add('Selección manual');
    if (!visiblePublico) caracteristicas.add('Privada');
    if (limiteUso != null) caracteristicas.add('Límite: $limiteUso');
    if (duracionPromocionDias != null)
      caracteristicas.add('Promoción: ${duracionPromocionDias}d');
    if (categoria != null) caracteristicas.add('Categoría: $categoria');
    if (grupo != null) caracteristicas.add('Grupo: $grupo');

    return caracteristicas;
  }

  /// Métodos de negocio
  bool puedeSerAsignadaATienda(int tiendaId) {
    // Verificar disponibilidad básica
    if (!disponibleParaUso) return false;

    // Verificar límite de uso
    if (limiteAlcanzado) return false;

    // Verificar condiciones especiales si existen
    if (condicionesEspeciales != null) {
      // Aquí se implementaría lógica específica basada en condiciones
      // Por ejemplo: solo para tiendas verificadas, solo para organizaciones, etc.
    }

    return true;
  }

  bool esCompatibleConEtiqueta(EtiquetaTienda otraEtiqueta) {
    // Verificar si dos etiquetas son compatibles (pueden usarse juntas)

    // Etiquetas exclusivas no son compatibles con otras exclusivas
    if (esExclusiva && otraEtiqueta.esExclusiva) return false;

    // Verificar grupos incompatibles
    if (grupo != null && otraEtiqueta.grupo != null) {
      // Algunos grupos pueden ser mutuamente excluyentes
      final gruposIncompatibles = ['premium', 'basico'];
      if (gruposIncompatibles.contains(grupo) &&
          gruposIncompatibles.contains(otraEtiqueta.grupo) &&
          grupo != otraEtiqueta.grupo) {
        return false;
      }
    }

    // Verificar etiquetas relacionadas (algunas pueden requerir otras)
    if (etiquetasRelacionadas != null &&
        etiquetasRelacionadas!.contains(otraEtiqueta.nombre)) {
      return true;
    }

    if (otraEtiqueta.etiquetasRelacionadas != null &&
        otraEtiqueta.etiquetasRelacionadas!.contains(nombre)) {
      return true;
    }

    // Por defecto, son compatibles
    return true;
  }

  bool necesitaRenovacion() {
    // Etiquetas con duración de promoción que están por expirar
    if (duracionPromocionDias != null) {
      final fechaExpiracion = fechaCreacion.add(
        Duration(days: duracionPromocionDias!),
      );
      final diasRestantes = fechaExpiracion.difference(DateTime.now()).inDays;
      return diasRestantes <= 7; // Renovar una semana antes
    }

    // Etiquetas inactivas por mucho tiempo
    if (!activa && fechaActualizacion != null) {
      final seisMesesAtras = DateTime.now().subtract(const Duration(days: 180));
      return fechaActualizacion!.isBefore(seisMesesAtras);
    }

    return false;
  }

  bool esMasRelevanteQue(EtiquetaTienda otra, {bool porPopularidad = true}) {
    if (porPopularidad) {
      return totalTiendas > otra.totalTiendas;
    } else {
      return nivelPrioridadCalculado > otra.nivelPrioridadCalculado;
    }
  }

  String get nivelRelevancia {
    final puntuacion = (totalTiendas * 0.3) + (nivelPrioridadCalculado * 20);

    if (puntuacion > 100) return 'Muy alta';
    if (puntuacion > 70) return 'Alta';
    if (puntuacion > 40) return 'Media';
    if (puntuacion > 20) return 'Baja';
    return 'Muy baja';
  }

  bool tieneRestriccionesEspeciales() {
    return requiereAprobacion ||
        !permiteAutoseleccion ||
        !visiblePublico ||
        condicionesEspeciales != null;
  }

  bool esEtiquetaPromocional() {
    return duracionPromocionDias != null ||
        destacada ||
        (categoria?.toLowerCase().contains('promo') ?? false);
  }

  bool esEtiquetaEstructural() {
    return categoria == 'categoria' ||
        grupo == 'clasificacion' ||
        (tipoEtiqueta?.toLowerCase().contains('estructura') ?? false);
  }

  bool esEtiquetaDescriptiva() {
    return categoria == 'caracteristica' ||
        grupo == 'descripcion' ||
        (tipoEtiqueta?.toLowerCase().contains('desc') ?? false);
  }

  String get tipoFuncional {
    if (esEtiquetaPromocional()) return 'Promocional';
    if (esEtiquetaEstructural()) return 'Estructural';
    if (esEtiquetaDescriptiva()) return 'Descriptiva';
    return 'General';
  }

  bool puedeSerRecomendadaParaTienda(
    Map<String, dynamic> caracteristicasTienda,
  ) {
    // Lógica para recomendar etiquetas basada en características de la tienda

    // Verificar categoría de la tienda
    if (categoria != null && caracteristicasTienda['categoria'] != null) {
      if (categoria!.toLowerCase() !=
          caracteristicasTienda['categoria'].toString().toLowerCase()) {
        return false;
      }
    }

    // Verificar si la tienda cumple condiciones especiales
    if (condicionesEspeciales != null) {
      // Aquí se implementaría lógica específica de condiciones
      // Por ejemplo: solo para tiendas con más de X productos, solo para tiendas verificadas, etc.
    }

    // Verificar si ya tiene muchas etiquetas similares
    if (caracteristicasTienda['etiquetasSimilares'] != null) {
      final etiquetasSimilares =
          caracteristicasTienda['etiquetasSimilares'] as List<String>;
      if (etiquetasSimilares.length > 5) {
        return false; // Demasiadas etiquetas similares
      }
    }

    return true;
  }

  double get valorEtiqueta {
    // Calcular valor basado en múltiples factores
    double valor = 0.0;

    // Popularidad
    if (esPopular)
      valor += 30.0;
    else if (esEmergente)
      valor += 20.0;
    else if (esNueva)
      valor += 10.0;

    // Exclusividad
    if (esExclusiva) valor += 25.0;

    // Destacada
    if (destacada) valor += 15.0;

    // Prioridad
    valor += nivelPrioridadCalculado * 5.0;

    // Uso actual (más uso = más valor, pero con rendimientos decrecientes)
    if (totalTiendas > 0) {
      valor += (totalTiendas / 100.0).clamp(0.0, 20.0);
    }

    // Duración de promoción
    if (duracionPromocionDias != null) {
      valor += (duracionPromocionDias! / 30.0).clamp(0.0, 10.0);
    }

    return valor;
  }

  bool esEtiquetaValiosa() {
    return valorEtiqueta > 50.0;
  }
}
