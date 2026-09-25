// lib/domain/entities/imagen_base.dart

import 'package:equatable/equatable.dart';

import 'enums.dart';

/// Entidad base para todas las imágenes del sistema
abstract class ImagenBase extends Equatable {
  final int id;
  final String urlOriginal;
  final String? urlR2;
  final String? urlS3;
  final String? urlSupabase;
  final String nombreArchivo;
  final String extension;
  final int tamanoBytes;
  final int ancho;
  final int alto;
  final TipoImagen tipoImagen;
  final bool esPrincipal;
  final int ordenVisual;
  final String? titulo;
  final String? descripcion;
  final String? altText;
  final Map<String, dynamic>? metadata;
  final DateTime fechaCreacion;
  final DateTime? fechaActualizacion;
  final bool activa;
  final String? hashArchivo;
  final String? proveedorPrincipal;
  final Map<String, String>? urlsVariantes;
  final String? mimeType;
  final bool optimizada;
  final int? calidad;
  final String? formatoOptimizado;

  const ImagenBase({
    required this.id,
    required this.urlOriginal,
    this.urlR2,
    this.urlS3,
    this.urlSupabase,
    required this.nombreArchivo,
    required this.extension,
    required this.tamanoBytes,
    required this.ancho,
    required this.alto,
    required this.tipoImagen,
    required this.esPrincipal,
    required this.ordenVisual,
    this.titulo,
    this.descripcion,
    this.altText,
    this.metadata,
    required this.fechaCreacion,
    this.fechaActualizacion,
    required this.activa,
    this.hashArchivo,
    this.proveedorPrincipal,
    this.urlsVariantes,
    this.mimeType,
    this.optimizada = false,
    this.calidad,
    this.formatoOptimizado,
  });

  /// Obtener URL preferida según proveedor configurado
  String get urlPreferida {
    if (proveedorPrincipal == 'r2' && urlR2 != null) return urlR2!;
    if (proveedorPrincipal == 's3' && urlS3 != null) return urlS3!;
    if (proveedorPrincipal == 'supabase' && urlSupabase != null) {
      return urlSupabase!;
    }
    return urlOriginal;
  }

  /// Verificar si la imagen está activa
  bool get estaActiva => activa;

  /// Verificar si es imagen principal
  bool get esImagenPrincipal => esPrincipal;

  /// Calcular relación de aspecto
  double get relacionAspecto => ancho / alto;

  /// Verificar si es retrato
  bool get esRetrato => alto > ancho;

  /// Verificar si es paisaje
  bool get esPaisaje => ancho > alto;

  /// Verificar si es cuadrada
  bool get esCuadrada => ancho == alto;

  /// Obtener tamaño formateado
  String get tamanoFormateado {
    if (tamanoBytes < 1024) {
      return '${tamanoBytes} B';
    } else if (tamanoBytes < 1024 * 1024) {
      return '${(tamanoBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(tamanoBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Obtener resolución formateada
  String get resolucion => '${ancho}x$alto';

  /// Verificar si tiene variantes
  bool get tieneVariantes => urlsVariantes != null && urlsVariantes!.isNotEmpty;

  /// Obtener URL de variante específica
  String? getVarianteUrl(String nombreVariante) {
    return urlsVariantes?[nombreVariante];
  }

  /// Verificar si está optimizada
  bool get estaOptimizada => optimizada;

  /// Obtener tipo MIME
  String get mimeTypeCalculado {
    if (mimeType != null) return mimeType!;
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'avif':
        return 'image/avif';
      case 'svg':
        return 'image/svg+xml';
      default:
        return 'image/*';
    }
  }

  /// Método abstracto para obtener ID de la entidad relacionada
  int get entidadRelacionadaId;

  /// Método abstracto para obtener tipo de entidad relacionada
  String get tipoEntidadRelacionada;

  @override
  List<Object?> get props => [
    id,
    urlOriginal,
    urlR2,
    urlS3,
    urlSupabase,
    nombreArchivo,
    extension,
    tamanoBytes,
    ancho,
    alto,
    tipoImagen,
    esPrincipal,
    ordenVisual,
    titulo,
    descripcion,
    altText,
    metadata,
    fechaCreacion,
    fechaActualizacion,
    activa,
    hashArchivo,
    proveedorPrincipal,
    urlsVariantes,
    mimeType,
    optimizada,
    calidad,
    formatoOptimizado,
  ];

  @override
  bool get stringify => true;
}

/// Entidad para imágenes de tienda
class ImagenTienda extends ImagenBase {
  final int tiendaId;

  const ImagenTienda({
    required int id,
    required String urlOriginal,
    String? urlR2,
    String? urlS3,
    String? urlSupabase,
    required String nombreArchivo,
    required String extension,
    required int tamanoBytes,
    required int ancho,
    required int alto,
    required TipoImagen tipoImagen,
    required bool esPrincipal,
    required int ordenVisual,
    String? titulo,
    String? descripcion,
    String? altText,
    Map<String, dynamic>? metadata,
    required DateTime fechaCreacion,
    DateTime? fechaActualizacion,
    required bool activa,
    String? hashArchivo,
    String? proveedorPrincipal,
    Map<String, String>? urlsVariantes,
    String? mimeType,
    bool optimizada = false,
    int? calidad,
    String? formatoOptimizado,
    required this.tiendaId,
  }) : super(
         id: id,
         urlOriginal: urlOriginal,
         urlR2: urlR2,
         urlS3: urlS3,
         urlSupabase: urlSupabase,
         nombreArchivo: nombreArchivo,
         extension: extension,
         tamanoBytes: tamanoBytes,
         ancho: ancho,
         alto: alto,
         tipoImagen: tipoImagen,
         esPrincipal: esPrincipal,
         ordenVisual: ordenVisual,
         titulo: titulo,
         descripcion: descripcion,
         altText: altText,
         metadata: metadata,
         fechaCreacion: fechaCreacion,
         fechaActualizacion: fechaActualizacion,
         activa: activa,
         hashArchivo: hashArchivo,
         proveedorPrincipal: proveedorPrincipal,
         urlsVariantes: urlsVariantes,
         mimeType: mimeType,
         optimizada: optimizada,
         calidad: calidad,
         formatoOptimizado: formatoOptimizado,
       );

  @override
  int get entidadRelacionadaId => tiendaId;

  @override
  String get tipoEntidadRelacionada => 'tienda';

  /// Copiar con nuevos valores
  ImagenTienda copyWith({
    int? id,
    String? urlOriginal,
    String? urlR2,
    String? urlS3,
    String? urlSupabase,
    String? nombreArchivo,
    String? extension,
    int? tamanoBytes,
    int? ancho,
    int? alto,
    TipoImagen? tipoImagen,
    bool? esPrincipal,
    int? ordenVisual,
    String? titulo,
    String? descripcion,
    String? altText,
    Map<String, dynamic>? metadata,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
    bool? activa,
    String? hashArchivo,
    String? proveedorPrincipal,
    Map<String, String>? urlsVariantes,
    String? mimeType,
    bool? optimizada,
    int? calidad,
    String? formatoOptimizado,
    int? tiendaId,
  }) {
    return ImagenTienda(
      id: id ?? this.id,
      urlOriginal: urlOriginal ?? this.urlOriginal,
      urlR2: urlR2 ?? this.urlR2,
      urlS3: urlS3 ?? this.urlS3,
      urlSupabase: urlSupabase ?? this.urlSupabase,
      nombreArchivo: nombreArchivo ?? this.nombreArchivo,
      extension: extension ?? this.extension,
      tamanoBytes: tamanoBytes ?? this.tamanoBytes,
      ancho: ancho ?? this.ancho,
      alto: alto ?? this.alto,
      tipoImagen: tipoImagen ?? this.tipoImagen,
      esPrincipal: esPrincipal ?? this.esPrincipal,
      ordenVisual: ordenVisual ?? this.ordenVisual,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      altText: altText ?? this.altText,
      metadata: metadata ?? this.metadata,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      activa: activa ?? this.activa,
      hashArchivo: hashArchivo ?? this.hashArchivo,
      proveedorPrincipal: proveedorPrincipal ?? this.proveedorPrincipal,
      urlsVariantes: urlsVariantes ?? this.urlsVariantes,
      mimeType: mimeType ?? this.mimeType,
      optimizada: optimizada ?? this.optimizada,
      calidad: calidad ?? this.calidad,
      formatoOptimizado: formatoOptimizado ?? this.formatoOptimizado,
      tiendaId: tiendaId ?? this.tiendaId,
    );
  }
}

/// Entidad para imágenes de productos
class ImagenProducto extends ImagenBase {
  final int productoId;
  final int? varianteId;

  const ImagenProducto({
    required int id,
    required String urlOriginal,
    String? urlR2,
    String? urlS3,
    String? urlSupabase,
    required String nombreArchivo,
    required String extension,
    required int tamanoBytes,
    required int ancho,
    required int alto,
    required TipoImagen tipoImagen,
    required bool esPrincipal,
    required int ordenVisual,
    String? titulo,
    String? descripcion,
    String? altText,
    Map<String, dynamic>? metadata,
    required DateTime fechaCreacion,
    DateTime? fechaActualizacion,
    required bool activa,
    String? hashArchivo,
    String? proveedorPrincipal,
    Map<String, String>? urlsVariantes,
    String? mimeType,
    bool optimizada = false,
    int? calidad,
    String? formatoOptimizado,
    required this.productoId,
    this.varianteId,
  }) : super(
         id: id,
         urlOriginal: urlOriginal,
         urlR2: urlR2,
         urlS3: urlS3,
         urlSupabase: urlSupabase,
         nombreArchivo: nombreArchivo,
         extension: extension,
         tamanoBytes: tamanoBytes,
         ancho: ancho,
         alto: alto,
         tipoImagen: tipoImagen,
         esPrincipal: esPrincipal,
         ordenVisual: ordenVisual,
         titulo: titulo,
         descripcion: descripcion,
         altText: altText,
         metadata: metadata,
         fechaCreacion: fechaCreacion,
         fechaActualizacion: fechaActualizacion,
         activa: activa,
         hashArchivo: hashArchivo,
         proveedorPrincipal: proveedorPrincipal,
         urlsVariantes: urlsVariantes,
         mimeType: mimeType,
         optimizada: optimizada,
         calidad: calidad,
         formatoOptimizado: formatoOptimizado,
       );

  @override
  int get entidadRelacionadaId => productoId;

  @override
  String get tipoEntidadRelacionada => 'producto';

  /// Verificar si es imagen de variante
  bool get esDeVariante => varianteId != null;

  /// Copiar con nuevos valores
  ImagenProducto copyWith({
    int? id,
    String? urlOriginal,
    String? urlR2,
    String? urlS3,
    String? urlSupabase,
    String? nombreArchivo,
    String? extension,
    int? tamanoBytes,
    int? ancho,
    int? alto,
    TipoImagen? tipoImagen,
    bool? esPrincipal,
    int? ordenVisual,
    String? titulo,
    String? descripcion,
    String? altText,
    Map<String, dynamic>? metadata,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
    bool? activa,
    String? hashArchivo,
    String? proveedorPrincipal,
    Map<String, String>? urlsVariantes,
    String? mimeType,
    bool? optimizada,
    int? calidad,
    String? formatoOptimizado,
    int? productoId,
    int? varianteId,
  }) {
    return ImagenProducto(
      id: id ?? this.id,
      urlOriginal: urlOriginal ?? this.urlOriginal,
      urlR2: urlR2 ?? this.urlR2,
      urlS3: urlS3 ?? this.urlS3,
      urlSupabase: urlSupabase ?? this.urlSupabase,
      nombreArchivo: nombreArchivo ?? this.nombreArchivo,
      extension: extension ?? this.extension,
      tamanoBytes: tamanoBytes ?? this.tamanoBytes,
      ancho: ancho ?? this.ancho,
      alto: alto ?? this.alto,
      tipoImagen: tipoImagen ?? this.tipoImagen,
      esPrincipal: esPrincipal ?? this.esPrincipal,
      ordenVisual: ordenVisual ?? this.ordenVisual,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      altText: altText ?? this.altText,
      metadata: metadata ?? this.metadata,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      activa: activa ?? this.activa,
      hashArchivo: hashArchivo ?? this.hashArchivo,
      proveedorPrincipal: proveedorPrincipal ?? this.proveedorPrincipal,
      urlsVariantes: urlsVariantes ?? this.urlsVariantes,
      mimeType: mimeType ?? this.mimeType,
      optimizada: optimizada ?? this.optimizada,
      calidad: calidad ?? this.calidad,
      formatoOptimizado: formatoOptimizado ?? this.formatoOptimizado,
      productoId: productoId ?? this.productoId,
      varianteId: varianteId ?? this.varianteId,
    );
  }
}

/// Entidad para imágenes de plazoletas
class ImagenPlazoleta extends ImagenBase {
  final int plazoletaId;

  const ImagenPlazoleta({
    required int id,
    required String urlOriginal,
    String? urlR2,
    String? urlS3,
    String? urlSupabase,
    required String nombreArchivo,
    required String extension,
    required int tamanoBytes,
    required int ancho,
    required int alto,
    required TipoImagen tipoImagen,
    required bool esPrincipal,
    required int ordenVisual,
    String? titulo,
    String? descripcion,
    String? altText,
    Map<String, dynamic>? metadata,
    required DateTime fechaCreacion,
    DateTime? fechaActualizacion,
    required bool activa,
    String? hashArchivo,
    String? proveedorPrincipal,
    Map<String, String>? urlsVariantes,
    String? mimeType,
    bool optimizada = false,
    int? calidad,
    String? formatoOptimizado,
    required this.plazoletaId,
  }) : super(
         id: id,
         urlOriginal: urlOriginal,
         urlR2: urlR2,
         urlS3: urlS3,
         urlSupabase: urlSupabase,
         nombreArchivo: nombreArchivo,
         extension: extension,
         tamanoBytes: tamanoBytes,
         ancho: ancho,
         alto: alto,
         tipoImagen: tipoImagen,
         esPrincipal: esPrincipal,
         ordenVisual: ordenVisual,
         titulo: titulo,
         descripcion: descripcion,
         altText: altText,
         metadata: metadata,
         fechaCreacion: fechaCreacion,
         fechaActualizacion: fechaActualizacion,
         activa: activa,
         hashArchivo: hashArchivo,
         proveedorPrincipal: proveedorPrincipal,
         urlsVariantes: urlsVariantes,
         mimeType: mimeType,
         optimizada: optimizada,
         calidad: calidad,
         formatoOptimizado: formatoOptimizado,
       );

  @override
  int get entidadRelacionadaId => plazoletaId;

  @override
  String get tipoEntidadRelacionada => 'plazoleta';

  /// Copiar con nuevos valores
  ImagenPlazoleta copyWith({
    int? id,
    String? urlOriginal,
    String? urlR2,
    String? urlS3,
    String? urlSupabase,
    String? nombreArchivo,
    String? extension,
    int? tamanoBytes,
    int? ancho,
    int? alto,
    TipoImagen? tipoImagen,
    bool? esPrincipal,
    int? ordenVisual,
    String? titulo,
    String? descripcion,
    String? altText,
    Map<String, dynamic>? metadata,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
    bool? activa,
    String? hashArchivo,
    String? proveedorPrincipal,
    Map<String, String>? urlsVariantes,
    String? mimeType,
    bool? optimizada,
    int? calidad,
    String? formatoOptimizado,
    int? plazoletaId,
  }) {
    return ImagenPlazoleta(
      id: id ?? this.id,
      urlOriginal: urlOriginal ?? this.urlOriginal,
      urlR2: urlR2 ?? this.urlR2,
      urlS3: urlS3 ?? this.urlS3,
      urlSupabase: urlSupabase ?? this.urlSupabase,
      nombreArchivo: nombreArchivo ?? this.nombreArchivo,
      extension: extension ?? this.extension,
      tamanoBytes: tamanoBytes ?? this.tamanoBytes,
      ancho: ancho ?? this.ancho,
      alto: alto ?? this.alto,
      tipoImagen: tipoImagen ?? this.tipoImagen,
      esPrincipal: esPrincipal ?? this.esPrincipal,
      ordenVisual: ordenVisual ?? this.ordenVisual,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      altText: altText ?? this.altText,
      metadata: metadata ?? this.metadata,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      activa: activa ?? this.activa,
      hashArchivo: hashArchivo ?? this.hashArchivo,
      proveedorPrincipal: proveedorPrincipal ?? this.proveedorPrincipal,
      urlsVariantes: urlsVariantes ?? this.urlsVariantes,
      mimeType: mimeType ?? this.mimeType,
      optimizada: optimizada ?? this.optimizada,
      calidad: calidad ?? this.calidad,
      formatoOptimizado: formatoOptimizado ?? this.formatoOptimizado,
      plazoletaId: plazoletaId ?? this.plazoletaId,
    );
  }
}
