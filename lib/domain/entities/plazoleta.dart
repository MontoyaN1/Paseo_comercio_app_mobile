// lib/domain/entities/plazoleta.dart

import 'package:equatable/equatable.dart';

import 'enums.dart';

/// Entidad de dominio para Plazoleta (zona/ubicación en el centro comercial)
/// Corresponde a la tabla `plazoleta` en la base de datos
class Plazoleta extends Equatable {
  final int id;
  final DateTime fechaCreacion;
  final String nombre;
  final String? descripcion;
  final TipoUbicacion tipoUbicacion;
  final String slug;
  final int? categoriaPrincipalId;

  const Plazoleta({
    required this.id,
    required this.fechaCreacion,
    required this.nombre,
    this.descripcion,
    required this.tipoUbicacion,
    required this.slug,
    this.categoriaPrincipalId,
  });

  /// Verificar si la plazoleta tiene categoría principal asociada
  bool get tieneCategoriaPrincipal => categoriaPrincipalId != null;

  /// Obtener slug formateado para URLs
  String get slugFormateado => slug.toLowerCase().replaceAll(' ', '-');

  /// Verificar si es una ubicación principal (tipo 'plazoleta')
  bool get esPlazoletaPrincipal => tipoUbicacion == TipoUbicacion.plazoleta;

  /// Verificar si es un pasillo o área secundaria
  bool get esAreaSecundaria => tipoUbicacion == TipoUbicacion.pasillo;

  /// Verificar si es una entrada/salida
  bool get esEntradaSalida => tipoUbicacion == TipoUbicacion.entrada;

  /// Obtener descripción breve (primeras palabras)
  String get descripcionBreve {
    if (descripcion == null || descripcion!.isEmpty) {
      return 'Plazoleta sin descripción';
    }
    final palabras = descripcion!.split(' ');
    return palabras.length > 10
        ? '${palabras.sublist(0, 10).join(' ')}...'
        : descripcion!;
  }

  /// Obtener inicial del nombre (para avatares/iconos)
  String get inicialNombre => nombre.isNotEmpty ? nombre[0] : 'P';

  /// Copiar con nuevos valores
  Plazoleta copyWith({
    int? id,
    DateTime? fechaCreacion,
    String? nombre,
    String? descripcion,
    TipoUbicacion? tipoUbicacion,
    String? slug,
    int? categoriaPrincipalId,
  }) {
    return Plazoleta(
      id: id ?? this.id,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      tipoUbicacion: tipoUbicacion ?? this.tipoUbicacion,
      slug: slug ?? this.slug,
      categoriaPrincipalId: categoriaPrincipalId ?? this.categoriaPrincipalId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    fechaCreacion,
    nombre,
    descripcion,
    tipoUbicacion,
    slug,
    categoriaPrincipalId,
  ];

  @override
  bool get stringify => true;

  /// Métodos de utilidad para UI
  String get tipoUbicacionTexto {
    switch (tipoUbicacion) {
      case TipoUbicacion.plazoleta:
        return 'Plazoleta';
      case TipoUbicacion.pasillo:
        return 'Pasillo';
      case TipoUbicacion.entrada:
        return 'Entrada/Salida';
      case TipoUbicacion.estacionamiento:
        return 'Estacionamiento';
      case TipoUbicacion.bano:
        return 'Baño';
      case TipoUbicacion.zonaDescanso:
        return 'Zona de Descanso';
      case TipoUbicacion.zonaComida:
        return 'Zona de Comida';
      case TipoUbicacion.ascensor:
        return 'Ascensor';
      case TipoUbicacion.escalera:
        return 'Escalera';
      case TipoUbicacion.otro:
        return 'Otro';
    }
  }

  String get fechaCreacionFormateada {
    return '${fechaCreacion.day}/${fechaCreacion.month}/${fechaCreacion.year}';
  }

  /// Verificar si la plazoleta es reciente (menos de 30 días)
  bool get esReciente {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fechaCreacion);
    return diferencia.inDays < 30;
  }

  /// Verificar si tiene información básica completa
  bool get tieneInformacionCompleta =>
      nombre.isNotEmpty && slug.isNotEmpty && descripcion != null;

  /// Convertir a Map para serialización JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'nombre': nombre,
      'descripcion': descripcion,
      'tipoUbicacion': tipoUbicacion.value,
      'slug': slug,
      'categoriaPrincipalId': categoriaPrincipalId,
    };
  }

  /// Crear instancia desde Map (deserialización JSON)
  /// Compatible con ambos formatos: camelCase y snake_case
  factory Plazoleta.fromJson(Map<String, dynamic> json) {
    // Helper para obtener valor en ambos formatos (camelCase o snake_case)
    dynamic getValue(String camelKey, String snakeKey) {
      if (json.containsKey(camelKey)) {
        return json[camelKey];
      }
      return json[snakeKey];
    }

    // Helper para obtener string con fallback
    String getString(
      String camelKey,
      String snakeKey, [
      String defaultValue = '',
    ]) {
      final value = getValue(camelKey, snakeKey);
      if (value == null) return defaultValue;
      return value.toString();
    }

    // Helper para obtener int con fallback
    int? getInt(String camelKey, String snakeKey) {
      final value = getValue(camelKey, snakeKey);
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString());
    }

    return Plazoleta(
      id: getInt('id', 'id') ?? 0,
      fechaCreacion: DateTime.parse(
        getString(
          'fechaCreacion',
          'fecha_creacion',
          DateTime.now().toIso8601String(),
        ),
      ),
      nombre: getString('nombre', 'nombre', 'Sin nombre'),
      descripcion: getString('descripcion', 'descripcion'),
      tipoUbicacion: TipoUbicacion.fromString(
        getString('tipoUbicacion', 'tipo_ubicacion', 'plazoleta'),
      ),
      slug: getString('slug', 'slug', ''),
      categoriaPrincipalId: getInt(
        'categoriaPrincipalId',
        'categoria_principal_id',
      ),
    );
  }

  /// Crear instancia desde respuesta de Supabase (nombres de columna snake_case)
  /// Mantenido para compatibilidad con código existente
  factory Plazoleta.fromSupabaseJson(Map<String, dynamic> json) {
    return Plazoleta.fromJson(json);
  }
}
