// lib/domain/entities/caracteristica.dart

import 'package:equatable/equatable.dart';

/// Entidad de dominio para Característica de Producto
/// Representa atributos específicos de un producto como tamaño, color, material, etc.
class Caracteristica extends Equatable {
  final int id;
  final int productoId;
  final String nombre;
  final String valor;
  final DateTime fechaCreacion;
  final String? unidadMedida;
  final int? ordenVisual;
  final bool? activa;
  final String? tipoDato; // texto, numero, booleano, lista
  final String? grupo;
  final bool? esFiltrable;
  final bool? esComparable;
  final String? icono;
  final String? color;
  final String? ayudaTexto;
  final List<String>? valoresPermitidos;
  final String? valorPorDefecto;
  final bool? esRequerida;
  final int? maxCaracteres;
  final String? expresionRegular;
  final String? formatoVisual;
  final double? valorNumericoMin;
  final double? valorNumericoMax;
  final String? unidadConversion;
  final double? factorConversion;

  const Caracteristica({
    required this.id,
    required this.productoId,
    required this.nombre,
    required this.valor,
    required this.fechaCreacion,
    this.unidadMedida,
    this.ordenVisual,
    this.activa = true,
    this.tipoDato = 'texto',
    this.grupo,
    this.esFiltrable = false,
    this.esComparable = false,
    this.icono,
    this.color,
    this.ayudaTexto,
    this.valoresPermitidos,
    this.valorPorDefecto,
    this.esRequerida = false,
    this.maxCaracteres,
    this.expresionRegular,
    this.formatoVisual,
    this.valorNumericoMin,
    this.valorNumericoMax,
    this.unidadConversion,
    this.factorConversion,
  });

  /// Factory constructor para crear una Caracteristica desde datos de la base de datos
  factory Caracteristica.fromJson(Map<String, dynamic> json) {
    return Caracteristica(
      id: (json['id'] as num).toInt(),
      productoId: (json['producto_id'] as num).toInt(),
      nombre: json['nombre'] as String,
      valor: json['valor'] as String,
      fechaCreacion: DateTime.parse(json['fecha_creacion'] as String),
      unidadMedida: json['unidad_medida'] as String?,
      ordenVisual: json['orden_visual'] as int?,
      activa: json['activa'] as bool? ?? true,
      tipoDato: json['tipo_dato'] as String? ?? 'texto',
      grupo: json['grupo'] as String?,
      esFiltrable: json['es_filtrable'] as bool? ?? false,
      esComparable: json['es_comparable'] as bool? ?? false,
      icono: json['icono'] as String?,
      color: json['color'] as String?,
      ayudaTexto: json['ayuda_texto'] as String?,
      valoresPermitidos:
          json['valores_permitidos'] != null
              ? List<String>.from(json['valores_permitidos'] as List)
              : null,
      valorPorDefecto: json['valor_por_defecto'] as String?,
      esRequerida: json['es_requerida'] as bool? ?? false,
      maxCaracteres: json['max_caracteres'] as int?,
      expresionRegular: json['expresion_regular'] as String?,
      formatoVisual: json['formato_visual'] as String?,
      valorNumericoMin:
          json['valor_numerico_min'] != null
              ? (json['valor_numerico_min'] as num).toDouble()
              : null,
      valorNumericoMax:
          json['valor_numerico_max'] != null
              ? (json['valor_numerico_max'] as num).toDouble()
              : null,
      unidadConversion: json['unidad_conversion'] as String?,
      factorConversion:
          json['factor_conversion'] != null
              ? (json['factor_conversion'] as num).toDouble()
              : null,
    );
  }

  /// Convertir a mapa para la base de datos
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'producto_id': productoId,
      'nombre': nombre,
      'valor': valor,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'unidad_medida': unidadMedida,
      'orden_visual': ordenVisual,
      'activa': activa,
      'tipo_dato': tipoDato,
      'grupo': grupo,
      'es_filtrable': esFiltrable,
      'es_comparable': esComparable,
      'icono': icono,
      'color': color,
      'ayuda_texto': ayudaTexto,
      'valores_permitidos': valoresPermitidos,
      'valor_por_defecto': valorPorDefecto,
      'es_requerida': esRequerida,
      'max_caracteres': maxCaracteres,
      'expresion_regular': expresionRegular,
      'formato_visual': formatoVisual,
      'valor_numerico_min': valorNumericoMin,
      'valor_numerico_max': valorNumericoMax,
      'unidad_conversion': unidadConversion,
      'factor_conversion': factorConversion,
    };
  }

  /// Verificar si la característica es de tipo numérico
  bool get esNumerica => tipoDato == 'numero';

  /// Verificar si la característica es de tipo booleano
  bool get esBooleana => tipoDato == 'booleano';

  /// Verificar si la característica es de tipo lista
  bool get esLista => tipoDato == 'lista';

  /// Verificar si la característica tiene unidad de medida
  bool get tieneUnidadMedida =>
      unidadMedida != null && unidadMedida!.isNotEmpty;

  /// Obtener el valor como número (si es numérico)
  double? get valorNumerico {
    if (!esNumerica) return null;
    try {
      return double.tryParse(valor);
    } catch (_) {
      return null;
    }
  }

  /// Obtener el valor como booleano (si es booleano)
  bool? get valorBooleano {
    if (!esBooleana) return null;
    return valor.toLowerCase() == 'true' || valor == '1';
  }

  /// Verificar si el valor está dentro del rango permitido (para características numéricas)
  bool get valorEnRango {
    if (!esNumerica || valorNumerico == null) return true;
    final valorNum = valorNumerico!;
    if (valorNumericoMin != null && valorNum < valorNumericoMin!) return false;
    if (valorNumericoMax != null && valorNum > valorNumericoMax!) return false;
    return true;
  }

  /// Verificar si el valor es válido según los valores permitidos (para características de lista)
  bool get valorValido {
    if (valoresPermitidos == null || valoresPermitidos!.isEmpty) return true;
    return valoresPermitidos!.contains(valor);
  }

  /// Obtener el valor formateado con unidad de medida
  String get valorFormateado {
    if (tieneUnidadMedida) {
      return '$valor $unidadMedida';
    }
    return valor;
  }

  /// Verificar si la característica es filtrable en búsquedas
  bool get puedeFiltrar => esFiltrable == true;

  /// Verificar si la característica es comparable entre productos
  bool get puedeComparar => esComparable == true;

  /// Verificar si la característica está activa
  bool get estaActiva => activa == true;

  /// Obtener el grupo de la característica (para agrupación en UI)
  String get grupoVisual => grupo ?? 'General';

  /// Copiar con nuevos valores
  Caracteristica copyWith({
    int? id,
    int? productoId,
    String? nombre,
    String? valor,
    DateTime? fechaCreacion,
    String? unidadMedida,
    int? ordenVisual,
    bool? activa,
    String? tipoDato,
    String? grupo,
    bool? esFiltrable,
    bool? esComparable,
    String? icono,
    String? color,
    String? ayudaTexto,
    List<String>? valoresPermitidos,
    String? valorPorDefecto,
    bool? esRequerida,
    int? maxCaracteres,
    String? expresionRegular,
    String? formatoVisual,
    double? valorNumericoMin,
    double? valorNumericoMax,
    String? unidadConversion,
    double? factorConversion,
  }) {
    return Caracteristica(
      id: id ?? this.id,
      productoId: productoId ?? this.productoId,
      nombre: nombre ?? this.nombre,
      valor: valor ?? this.valor,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      unidadMedida: unidadMedida ?? this.unidadMedida,
      ordenVisual: ordenVisual ?? this.ordenVisual,
      activa: activa ?? this.activa,
      tipoDato: tipoDato ?? this.tipoDato,
      grupo: grupo ?? this.grupo,
      esFiltrable: esFiltrable ?? this.esFiltrable,
      esComparable: esComparable ?? this.esComparable,
      icono: icono ?? this.icono,
      color: color ?? this.color,
      ayudaTexto: ayudaTexto ?? this.ayudaTexto,
      valoresPermitidos: valoresPermitidos ?? this.valoresPermitidos,
      valorPorDefecto: valorPorDefecto ?? this.valorPorDefecto,
      esRequerida: esRequerida ?? this.esRequerida,
      maxCaracteres: maxCaracteres ?? this.maxCaracteres,
      expresionRegular: expresionRegular ?? this.expresionRegular,
      formatoVisual: formatoVisual ?? this.formatoVisual,
      valorNumericoMin: valorNumericoMin ?? this.valorNumericoMin,
      valorNumericoMax: valorNumericoMax ?? this.valorNumericoMax,
      unidadConversion: unidadConversion ?? this.unidadConversion,
      factorConversion: factorConversion ?? this.factorConversion,
    );
  }

  @override
  List<Object?> get props => [
    id,
    productoId,
    nombre,
    valor,
    fechaCreacion,
    unidadMedida,
    ordenVisual,
    activa,
    tipoDato,
    grupo,
    esFiltrable,
    esComparable,
    icono,
    color,
    ayudaTexto,
    valoresPermitidos,
    valorPorDefecto,
    esRequerida,
    maxCaracteres,
    expresionRegular,
    formatoVisual,
    valorNumericoMin,
    valorNumericoMax,
    unidadConversion,
    factorConversion,
  ];

  @override
  bool get stringify => true;

  /// Métodos de utilidad para UI
  String get resumen {
    return '$nombre: $valorFormateado';
  }

  bool get tieneAyuda => ayudaTexto != null && ayudaTexto!.isNotEmpty;

  bool get tieneIcono => icono != null && icono!.isNotEmpty;

  bool get tieneColor => color != null && color!.isNotEmpty;

  /// Métodos de negocio
  bool esSimilarA(Caracteristica otra) {
    return nombre.toLowerCase() == otra.nombre.toLowerCase() &&
        grupoVisual.toLowerCase() == otra.grupoVisual.toLowerCase();
  }

  bool puedeCombinarCon(Caracteristica otra) {
    return esSimilarA(otra) && tipoDato == otra.tipoDato;
  }

  String? get sugerenciaValor {
    if (valoresPermitidos != null && valoresPermitidos!.isNotEmpty) {
      return valoresPermitidos!.first;
    }
    return valorPorDefecto;
  }

  bool get requiereValidacion {
    return esRequerida == true ||
        maxCaracteres != null ||
        expresionRegular != null ||
        (esNumerica &&
            (valorNumericoMin != null || valorNumericoMax != null)) ||
        (esLista && valoresPermitidos != null && valoresPermitidos!.isNotEmpty);
  }

  bool validarValor(String valorAValidar) {
    if (esRequerida == true && valorAValidar.isEmpty) return false;

    if (maxCaracteres != null && valorAValidar.length > maxCaracteres!) {
      return false;
    }

    if (expresionRegular != null && expresionRegular!.isNotEmpty) {
      final regExp = RegExp(expresionRegular!);
      if (!regExp.hasMatch(valorAValidar)) return false;
    }

    if (esNumerica) {
      final valorNum = double.tryParse(valorAValidar);
      if (valorNum == null) return false;
      if (valorNumericoMin != null && valorNum < valorNumericoMin!)
        return false;
      if (valorNumericoMax != null && valorNum > valorNumericoMax!)
        return false;
    }

    if (esLista && valoresPermitidos != null && valoresPermitidos!.isNotEmpty) {
      if (!valoresPermitidos!.contains(valorAValidar)) return false;
    }

    return true;
  }
}
