// lib/domain/entities/categoria.dart

import 'package:equatable/equatable.dart';

import 'enums.dart';

/// Entidad de dominio para Categoría (clasificación de productos/servicios)
class Categoria extends Equatable {
  final int id;
  final String nombre;
  final String? descripcion;
  final String? icono;
  final String? color;
  final int? categoriaPadreId;
  final int nivel;
  final String? ruta;
  final int ordenVisual;
  final bool activa;
  final TipoCategoria tipoCategoria;
  final DateTime fechaCreacion;
  final DateTime? fechaActualizacion;
  final Map<String, dynamic>? metadata;
  final int totalProductos;
  final int totalTiendas;
  final int totalSubcategorias;
  final bool destacada;
  final String? imagenUrl;
  final String? keywords;
  final String? normasCategoria;
  final int? edadMinimaRecomendada;
  final int? edadMaximaRecomendada;
  final String? generoRecomendado;
  final String? temporadaRecomendada;
  final double? precioMinimoPromedio;
  final double? precioMaximoPromedio;
  final bool requiereVerificacionEdad;
  final bool esCategoriaSensible;
  final List<String>? etiquetasRelacionadas;
  final String? unidadMedidaPredeterminada;
  final String? monedaPredeterminada;

  const Categoria({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.icono,
    this.color,
    this.categoriaPadreId,
    required this.nivel,
    this.ruta,
    required this.ordenVisual,
    required this.activa,
    required this.tipoCategoria,
    required this.fechaCreacion,
    this.fechaActualizacion,
    this.metadata,
    this.totalProductos = 0,
    this.totalTiendas = 0,
    this.totalSubcategorias = 0,
    this.destacada = false,
    this.imagenUrl,
    this.keywords,
    this.normasCategoria,
    this.edadMinimaRecomendada,
    this.edadMaximaRecomendada,
    this.generoRecomendado,
    this.temporadaRecomendada,
    this.precioMinimoPromedio,
    this.precioMaximoPromedio,
    this.requiereVerificacionEdad = false,
    this.esCategoriaSensible = false,
    this.etiquetasRelacionadas,
    this.unidadMedidaPredeterminada,
    this.monedaPredeterminada,
  });

  /// Verificar si es categoría raíz (sin padre)
  bool get esRaiz => categoriaPadreId == null;

  /// Verificar si es subcategoría
  bool get esSubcategoria => categoriaPadreId != null;

  /// Verificar si tiene subcategorías
  bool get tieneSubcategorias => totalSubcategorias > 0;

  /// Verificar si es categoría popular (muchos productos)
  bool get esPopular => totalProductos > 100;

  /// Verificar si es categoría emergente (crecimiento rápido)
  bool get esEmergente => totalProductos > 10 && totalProductos <= 100;

  /// Verificar si es categoría nueva (pocos productos)
  bool get esNueva => totalProductos <= 10;

  /// Verificar si es categoría para adultos
  bool get esParaAdultos {
    if (edadMinimaRecomendada == null) return false;
    return edadMinimaRecomendada! >= 18;
  }

  /// Verificar si es categoría para niños
  bool get esParaNinos {
    if (edadMaximaRecomendada == null) return false;
    return edadMaximaRecomendada! <= 12;
  }

  /// Verificar si es categoría estacional
  bool get esEstacional => temporadaRecomendada != null;

  /// Verificar si tiene rango de precios definido
  bool get tieneRangoPrecios =>
      precioMinimoPromedio != null && precioMaximoPromedio != null;

  /// Obtener rango de precios formateado
  String? get rangoPreciosFormateado {
    if (!tieneRangoPrecios) return null;
    return '\$$precioMinimoPromedio - \$$precioMaximoPromedio';
  }

  /// Verificar si tiene icono y color
  bool get tieneEstiloVisual => icono != null && color != null;

  /// Obtener ruta completa (jerarquía)
  String get rutaCompleta {
    if (ruta != null) return ruta!;
    return esRaiz ? nombre : 'Categoría Padre > $nombre';
  }

  /// Verificar si es categoría de productos
  bool get esCategoriaProductos => tipoCategoria == TipoCategoria.producto;

  /// Verificar si es categoría de servicios
  bool get esCategoriaServicios => tipoCategoria == TipoCategoria.servicio;

  /// Verificar si es categoría mixta
  bool get esCategoriaMixta => tipoCategoria == TipoCategoria.mixto;

  /// Copiar con nuevos valores
  Categoria copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    String? icono,
    String? color,
    int? categoriaPadreId,
    int? nivel,
    String? ruta,
    int? ordenVisual,
    bool? activa,
    TipoCategoria? tipoCategoria,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
    Map<String, dynamic>? metadata,
    int? totalProductos,
    int? totalTiendas,
    int? totalSubcategorias,
    bool? destacada,
    String? imagenUrl,
    String? keywords,
    String? normasCategoria,
    int? edadMinimaRecomendada,
    int? edadMaximaRecomendada,
    String? generoRecomendado,
    String? temporadaRecomendada,
    double? precioMinimoPromedio,
    double? precioMaximoPromedio,
    bool? requiereVerificacionEdad,
    bool? esCategoriaSensible,
    List<String>? etiquetasRelacionadas,
    String? unidadMedidaPredeterminada,
    String? monedaPredeterminada,
  }) {
    return Categoria(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      icono: icono ?? this.icono,
      color: color ?? this.color,
      categoriaPadreId: categoriaPadreId ?? this.categoriaPadreId,
      nivel: nivel ?? this.nivel,
      ruta: ruta ?? this.ruta,
      ordenVisual: ordenVisual ?? this.ordenVisual,
      activa: activa ?? this.activa,
      tipoCategoria: tipoCategoria ?? this.tipoCategoria,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      metadata: metadata ?? this.metadata,
      totalProductos: totalProductos ?? this.totalProductos,
      totalTiendas: totalTiendas ?? this.totalTiendas,
      totalSubcategorias: totalSubcategorias ?? this.totalSubcategorias,
      destacada: destacada ?? this.destacada,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      keywords: keywords ?? this.keywords,
      normasCategoria: normasCategoria ?? this.normasCategoria,
      edadMinimaRecomendada:
          edadMinimaRecomendada ?? this.edadMinimaRecomendada,
      edadMaximaRecomendada:
          edadMaximaRecomendada ?? this.edadMaximaRecomendada,
      generoRecomendado: generoRecomendado ?? this.generoRecomendado,
      temporadaRecomendada: temporadaRecomendada ?? this.temporadaRecomendada,
      precioMinimoPromedio: precioMinimoPromedio ?? this.precioMinimoPromedio,
      precioMaximoPromedio: precioMaximoPromedio ?? this.precioMaximoPromedio,
      requiereVerificacionEdad:
          requiereVerificacionEdad ?? this.requiereVerificacionEdad,
      esCategoriaSensible: esCategoriaSensible ?? this.esCategoriaSensible,
      etiquetasRelacionadas:
          etiquetasRelacionadas ?? this.etiquetasRelacionadas,
      unidadMedidaPredeterminada:
          unidadMedidaPredeterminada ?? this.unidadMedidaPredeterminada,
      monedaPredeterminada: monedaPredeterminada ?? this.monedaPredeterminada,
    );
  }

  @override
  List<Object?> get props => [
    id,
    nombre,
    descripcion,
    icono,
    color,
    categoriaPadreId,
    nivel,
    ruta,
    ordenVisual,
    activa,
    tipoCategoria,
    fechaCreacion,
    fechaActualizacion,
    metadata,
    totalProductos,
    totalTiendas,
    totalSubcategorias,
    destacada,
    imagenUrl,
    keywords,
    normasCategoria,
    edadMinimaRecomendada,
    edadMaximaRecomendada,
    generoRecomendado,
    temporadaRecomendada,
    precioMinimoPromedio,
    precioMaximoPromedio,
    requiereVerificacionEdad,
    esCategoriaSensible,
    etiquetasRelacionadas,
    unidadMedidaPredeterminada,
    monedaPredeterminada,
  ];

  @override
  bool get stringify => true;

  /// Métodos de utilidad para UI
  String get estadoDescripcion {
    if (!activa) return 'Inactiva';
    if (destacada) return 'Destacada';
    return 'Activa';
  }

  String get tipoDescripcion {
    switch (tipoCategoria) {
      case TipoCategoria.producto:
        return 'Productos';
      case TipoCategoria.servicio:
        return 'Servicios';
      case TipoCategoria.mixto:
        return 'Mixto';
    }
  }

  String get rangoEdadFormateado {
    if (edadMinimaRecomendada == null && edadMaximaRecomendada == null) {
      return 'Todas las edades';
    }
    if (edadMinimaRecomendada != null && edadMaximaRecomendada != null) {
      return '$edadMinimaRecomendada-$edadMaximaRecomendada años';
    }
    if (edadMinimaRecomendada != null) {
      return 'Mayores de $edadMinimaRecomendada años';
    }
    return 'Menores de $edadMaximaRecomendada años';
  }

  String get nivelDescripcion {
    switch (nivel) {
      case 0:
        return 'Raíz';
      case 1:
        return 'Principal';
      case 2:
        return 'Subcategoría';
      case 3:
        return 'Sub-subcategoría';
      default:
        return 'Nivel $nivel';
    }
  }

  List<String> get caracteristicasLista {
    final caracteristicas = <String>[];

    if (esCategoriaSensible) caracteristicas.add('Sensible');
    if (requiereVerificacionEdad) caracteristicas.add('Verificación edad');
    if (destacada) caracteristicas.add('Destacada');
    if (esParaAdultos) caracteristicas.add('Adultos');
    if (esParaNinos) caracteristicas.add('Niños');
    if (esEstacional) caracteristicas.add('Estacional: $temporadaRecomendada');
    if (generoRecomendado != null)
      caracteristicas.add('Género: $generoRecomendado');

    return caracteristicas;
  }

  /// Métodos de negocio
  bool puedeContenerProducto(double precio) {
    if (!tieneRangoPrecios) return true;
    return precio >= precioMinimoPromedio! && precio <= precioMaximoPromedio!;
  }

  bool esAptaParaEdad(int edad) {
    if (edadMinimaRecomendada == null && edadMaximaRecomendada == null) {
      return true;
    }
    if (edadMinimaRecomendada != null && edad < edadMinimaRecomendada!) {
      return false;
    }
    if (edadMaximaRecomendada != null && edad > edadMaximaRecomendada!) {
      return false;
    }
    return true;
  }

  bool esAptaParaGenero(String genero) {
    if (generoRecomendado == null) return true;
    return generoRecomendado!.toLowerCase() == genero.toLowerCase() ||
        generoRecomendado!.toLowerCase() == 'unisex';
  }

  bool esAptaParaTemporada(String temporadaActual) {
    if (temporadaRecomendada == null) return true;
    return temporadaRecomendada!.toLowerCase() == temporadaActual.toLowerCase();
  }

  double get densidadProductos {
    if (totalSubcategorias == 0) return totalProductos.toDouble();
    return totalProductos / totalSubcategorias;
  }

  bool esMasEspecificaQue(Categoria otra) {
    // Una categoría es más específica si tiene un nivel mayor
    return nivel > otra.nivel;
  }

  bool esCategoriaHermana(Categoria otra) {
    // Dos categorías son hermanas si tienen el mismo padre
    return categoriaPadreId == otra.categoriaPadreId;
  }

  bool esCategoriaHija(Categoria posiblePadre) {
    // Verificar si esta categoría es hija de la posible padre
    return categoriaPadreId == posiblePadre.id;
  }

  bool esCategoriaPadre(Categoria posibleHija) {
    // Verificar si esta categoría es padre de la posible hija
    return id == posibleHija.categoriaPadreId;
  }

  String get nivelPopularidad {
    if (totalProductos > 500) return 'Muy popular';
    if (totalProductos > 100) return 'Popular';
    if (totalProductos > 20) return 'Moderada';
    return 'Nueva';
  }

  bool necesitaActualizacion() {
    // Categorías con pocos productos o desactualizadas
    if (totalProductos == 0 &&
        fechaCreacion.isBefore(
          DateTime.now().subtract(const Duration(days: 90)),
        )) {
      return true;
    }

    // Categorías sin descripción o icono
    if (descripcion == null || icono == null) {
      return true;
    }

    return false;
  }
}
