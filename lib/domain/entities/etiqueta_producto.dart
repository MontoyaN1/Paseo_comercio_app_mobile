// lib/domain/entities/etiqueta_producto.dart

import 'package:equatable/equatable.dart';

/// Entidad de dominio para Etiqueta de Producto (tags/categorías para productos)
class EtiquetaProducto extends Equatable {
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
  final int totalProductos;
  final bool destacada;
  final String? categoria;
  final String? tipoEtiqueta;
  final int? categoriaId;
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
  final bool aplicaVariantes;
  final String? unidadMedida;
  final String? rangoValores;
  final bool esFiltrable;
  final bool esBuscable;
  final bool esComparable;
  final String? tipoDato; // texto, numero, booleano, lista
  final List<String>? valoresPermitidos;
  final String? valorPorDefecto;
  final bool esRequerida;
  final int? maxCaracteres;
  final String? expresionRegular;
  final String? ayudaTexto;

  const EtiquetaProducto({
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
    this.totalProductos = 0,
    this.destacada = false,
    this.categoria,
    this.tipoEtiqueta,
    this.categoriaId,
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
    this.aplicaVariantes = false,
    this.unidadMedida,
    this.rangoValores,
    this.esFiltrable = true,
    this.esBuscable = true,
    this.esComparable = false,
    this.tipoDato = 'texto',
    this.valoresPermitidos,
    this.valorPorDefecto,
    this.esRequerida = false,
    this.maxCaracteres,
    this.expresionRegular,
    this.ayudaTexto,
  });

  /// Verificar si la etiqueta está disponible para uso
  bool get disponibleParaUso {
    if (!activa) return false;
    if (!visiblePublico) return false;
    if (limiteUso != null && totalProductos >= limiteUso!) return false;
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
    return totalProductos >= limiteUso!;
  }

  /// Calcular porcentaje de uso
  double get porcentajeUso {
    if (limiteUso == null || limiteUso == 0) return 0.0;
    return (totalProductos / limiteUso!) * 100;
  }

  /// Verificar si es etiqueta popular (muchos productos)
  bool get esPopular => totalProductos > 100;

  /// Verificar si es etiqueta emergente (crecimiento rápido)
  bool get esEmergente => totalProductos > 20 && totalProductos <= 100;

  /// Verificar si es etiqueta nueva (pocos productos)
  bool get esNueva => totalProductos <= 20;

  /// Verificar si tiene estilo visual (icono y color)
  bool get tieneEstiloVisual => icono != null && color != null;

  /// Verificar si tiene imagen
  bool get tieneImagen => imagenUrl != null && imagenUrl!.isNotEmpty;

  /// Verificar si tiene descripción
  bool get tieneDescripcion => descripcion != null && descripcion!.isNotEmpty;

  /// Verificar si aplica a variantes de producto
  bool get aplicaAVariantes => aplicaVariantes;

  /// Verificar si es filtrable en búsquedas
  bool get esFiltrableEnBusqueda => esFiltrable;

  /// Verificar si es buscable
  bool get esBuscableEnBusqueda => esBuscable;

  /// Verificar si es comparable
  bool get esComparableEnComparacion => esComparable;

  /// Verificar si tiene valores permitidos definidos
  bool get tieneValoresPermitidos =>
      valoresPermitidos != null && valoresPermitidos!.isNotEmpty;

  /// Verificar si es etiqueta numérica
  bool get esNumerica => tipoDato == 'numero';

  /// Verificar si es etiqueta booleana
  bool get esBooleana => tipoDato == 'booleano';

  /// Verificar si es etiqueta de lista
  bool get esLista => tipoDato == 'lista';

  /// Verificar si es etiqueta de texto
  bool get esTexto => tipoDato == 'texto';

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
  EtiquetaProducto copyWith({
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
    int? totalProductos,
    bool? destacada,
    String? categoria,
    String? tipoEtiqueta,
    int? categoriaId,
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
    bool? aplicaVariantes,
    String? unidadMedida,
    String? rangoValores,
    bool? esFiltrable,
    bool? esBuscable,
    bool? esComparable,
    String? tipoDato,
    List<String>? valoresPermitidos,
    String? valorPorDefecto,
    bool? esRequerida,
    int? maxCaracteres,
    String? expresionRegular,
    String? ayudaTexto,
  }) {
    return EtiquetaProducto(
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
      totalProductos: totalProductos ?? this.totalProductos,
      destacada: destacada ?? this.destacada,
      categoria: categoria ?? this.categoria,
      tipoEtiqueta: tipoEtiqueta ?? this.tipoEtiqueta,
      categoriaId: categoriaId ?? this.categoriaId,
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
      aplicaVariantes: aplicaVariantes ?? this.aplicaVariantes,
      unidadMedida: unidadMedida ?? this.unidadMedida,
      rangoValores: rangoValores ?? this.rangoValores,
      esFiltrable: esFiltrable ?? this.esFiltrable,
      esBuscable: esBuscable ?? this.esBuscable,
      esComparable: esComparable ?? this.esComparable,
      tipoDato: tipoDato ?? this.tipoDato,
      valoresPermitidos: valoresPermitidos ?? this.valoresPermitidos,
      valorPorDefecto: valorPorDefecto ?? this.valorPorDefecto,
      esRequerida: esRequerida ?? this.esRequerida,
      maxCaracteres: maxCaracteres ?? this.maxCaracteres,
      expresionRegular: expresionRegular ?? this.expresionRegular,
      ayudaTexto: ayudaTexto ?? this.ayudaTexto,
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
    totalProductos,
    destacada,
    categoria,
    tipoEtiqueta,
    categoriaId,
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
    aplicaVariantes,
    unidadMedida,
    rangoValores,
    esFiltrable,
    esBuscable,
    esComparable,
    tipoDato,
    valoresPermitidos,
    valorPorDefecto,
    esRequerida,
    maxCaracteres,
    expresionRegular,
    ayudaTexto,
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

  String get tipoDatoDescripcion {
    switch (tipoDato) {
      case 'texto':
        return 'Texto';
      case 'numero':
        return 'Número';
      case 'booleano':
        return 'Sí/No';
      case 'lista':
        return 'Lista';
      default:
        return 'Texto';
    }
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
    if (aplicaVariantes) caracteristicas.add('Aplica a variantes');
    if (esFiltrable) caracteristicas.add('Filtrable');
    if (esBuscable) caracteristicas.add('Buscable');
    if (esComparable) caracteristicas.add('Comparable');
    if (esRequerida) caracteristicas.add('Requerida');
    if (unidadMedida != null) caracteristicas.add('Unidad: $unidadMedida');

    return caracteristicas;
  }

  /// Métodos de negocio
  bool puedeSerAsignadaAProducto(int productoId) {
    // Verificar disponibilidad básica
    if (!disponibleParaUso) return false;

    // Verificar límite de uso
    if (limiteAlcanzado) return false;

    // Verificar condiciones especiales si existen
    if (condicionesEspeciales != null) {
      // Aquí se implementaría lógica específica basada en condiciones
      // Por ejemplo: solo para productos premium, solo para categorías específicas, etc.
    }

    return true;
  }

  bool esCompatibleConEtiqueta(EtiquetaProducto otraEtiqueta) {
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

    // Verificar tipos de dato incompatibles
    if (tipoDato != otraEtiqueta.tipoDato) {
      // Algunos tipos pueden ser incompatibles
      if ((esNumerica && otraEtiqueta.esBooleana) ||
          (esBooleana && otraEtiqueta.esNumerica)) {
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

  bool esMasRelevanteQue(EtiquetaProducto otra, {bool porPopularidad = true}) {
    if (porPopularidad) {
      return totalProductos > otra.totalProductos;
    } else {
      return nivelPrioridadCalculado > otra.nivelPrioridadCalculado;
    }
  }

  String get nivelRelevancia {
    final prioridad = nivelPrioridad ?? 0;
    final puntuacion = (totalProductos * 0.5) + (prioridad * 0.5);
    if (puntuacion >= 8) return 'Muy Alta';
    if (puntuacion >= 6) return 'Alta';
    if (puntuacion >= 4) return 'Media';
    if (puntuacion >= 2) return 'Baja';
    return 'Muy Baja';
  }
}
