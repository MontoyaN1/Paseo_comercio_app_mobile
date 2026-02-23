// lib/domain/entities/valoracion_producto.dart

import 'package:equatable/equatable.dart';

import 'enums.dart';

/// Entidad de dominio para Valoración de Producto (reviews/calificaciones)
class ValoracionProducto extends Equatable {
  final int id;
  final int productoId;
  final int usuarioId;
  final double calificacion; // 1.0 a 5.0
  final String? titulo;
  final String? comentario;
  final EstadoValoracion estadoValoracion;
  final DateTime fechaCreacion;
  final DateTime? fechaActualizacion;
  final DateTime? fechaReporte;
  final String? motivoReporte;
  final int? usuarioReporteId;
  final bool esVerificadoCompra;
  final Map<String, dynamic>? metadata;
  final int? respuestaTiendaId;
  final String? respuestaTienda;
  final DateTime? fechaRespuestaTienda;
  final int likes;
  final int dislikes;
  final bool esAnonima;
  final String? ubicacionUsuario;
  final String? caracteristicasProducto; // Talla, color, etc. usados
  final int? tiempoUsoMeses;
  final String? usoFrecuencia; // Diario, semanal, mensual, etc.
  final bool recomiendaProducto;
  final double? precioPagado;
  final String? monedaPago;
  final String? canalCompra; // Online, tienda física, etc.

  const ValoracionProducto({
    required this.id,
    required this.productoId,
    required this.usuarioId,
    required this.calificacion,
    this.titulo,
    this.comentario,
    required this.estadoValoracion,
    required this.fechaCreacion,
    this.fechaActualizacion,
    this.fechaReporte,
    this.motivoReporte,
    this.usuarioReporteId,
    this.esVerificadoCompra = false,
    this.metadata,
    this.respuestaTiendaId,
    this.respuestaTienda,
    this.fechaRespuestaTienda,
    this.likes = 0,
    this.dislikes = 0,
    this.esAnonima = false,
    this.ubicacionUsuario,
    this.caracteristicasProducto,
    this.tiempoUsoMeses,
    this.usoFrecuencia,
    this.recomiendaProducto = true,
    this.precioPagado,
    this.monedaPago,
    this.canalCompra,
  });

  /// Verificar si la valoración está publicada
  bool get estaPublicada => estadoValoracion == EstadoValoracion.publicado;

  /// Verificar si la valoración está reportada
  bool get estaReportada => estadoValoracion == EstadoValoracion.reportado;

  /// Verificar si la valoración está eliminada
  bool get estaEliminada => estadoValoracion == EstadoValoracion.eliminado;

  /// Verificar si tiene respuesta de la tienda
  bool get tieneRespuestaTienda =>
      respuestaTienda != null && respuestaTienda!.isNotEmpty;

  /// Verificar si es una valoración verificada (compra confirmada)
  bool get esVerificada => esVerificadoCompra;

  /// Verificar si es una valoración reciente (menos de 7 días)
  bool get esReciente {
    final sieteDiasAtras = DateTime.now().subtract(const Duration(days: 7));
    return fechaCreacion.isAfter(sieteDiasAtras);
  }

  /// Verificar si es una valoración popular (muchos likes)
  bool get esPopular => likes > 10;

  /// Verificar si es una valoración controversial (muchos likes y dislikes)
  bool get esControversial => likes > 5 && dislikes > 5;

  /// Verificar si es una valoración útil (ratio positivo)
  bool get esUtil {
    if (likes + dislikes == 0) return false;
    return (likes / (likes + dislikes)) > 0.7;
  }

  /// Calcular ratio de utilidad
  double get ratioUtilidad {
    if (likes + dislikes == 0) return 0.0;
    return likes / (likes + dislikes);
  }

  /// Verificar si tiene información detallada
  bool get tieneInformacionDetallada {
    return caracteristicasProducto != null ||
        tiempoUsoMeses != null ||
        usoFrecuencia != null ||
        precioPagado != null;
  }

  /// Obtener calificación en estrellas (entero)
  int get calificacionEstrellas => calificacion.round();

  /// Obtener calificación formateada
  String get calificacionFormateada => calificacion.toStringAsFixed(1);

  /// Verificar si es una valoración negativa (≤ 2 estrellas)
  bool get esNegativa => calificacion <= 2.0;

  /// Verificar si es una valoración positiva (≥ 4 estrellas)
  bool get esPositiva => calificacion >= 4.0;

  /// Verificar si es una valoración neutral (2.1 a 3.9 estrellas)
  bool get esNeutral => calificacion > 2.0 && calificacion < 4.0;

  /// Obtener tiempo desde la creación formateado
  String get tiempoDesdeCreacion {
    final diferencia = DateTime.now().difference(fechaCreacion);

    if (diferencia.inSeconds < 60) {
      return 'Ahora mismo';
    } else if (diferencia.inMinutes < 60) {
      return 'Hace ${diferencia.inMinutes} min';
    } else if (diferencia.inHours < 24) {
      return 'Hace ${diferencia.inHours} h';
    } else if (diferencia.inDays < 7) {
      return 'Hace ${diferencia.inDays} días';
    } else if (diferencia.inDays < 30) {
      final semanas = (diferencia.inDays / 7).floor();
      return 'Hace $semanas ${semanas == 1 ? 'semana' : 'semanas'}';
    } else if (diferencia.inDays < 365) {
      final meses = (diferencia.inDays / 30).floor();
      return 'Hace $meses ${meses == 1 ? 'mes' : 'meses'}';
    } else {
      final anos = (diferencia.inDays / 365).floor();
      return 'Hace $anos ${anos == 1 ? 'ano' : 'anos'}';
    }
  }

  /// Copiar con nuevos valores
  ValoracionProducto copyWith({
    int? id,
    int? productoId,
    int? usuarioId,
    double? calificacion,
    String? titulo,
    String? comentario,
    EstadoValoracion? estadoValoracion,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
    DateTime? fechaReporte,
    String? motivoReporte,
    int? usuarioReporteId,
    bool? esVerificadoCompra,
    Map<String, dynamic>? metadata,
    int? respuestaTiendaId,
    String? respuestaTienda,
    DateTime? fechaRespuestaTienda,
    int? likes,
    int? dislikes,
    bool? esAnonima,
    String? ubicacionUsuario,
    String? caracteristicasProducto,
    int? tiempoUsoMeses,
    String? usoFrecuencia,
    bool? recomiendaProducto,
    double? precioPagado,
    String? monedaPago,
    String? canalCompra,
  }) {
    return ValoracionProducto(
      id: id ?? this.id,
      productoId: productoId ?? this.productoId,
      usuarioId: usuarioId ?? this.usuarioId,
      calificacion: calificacion ?? this.calificacion,
      titulo: titulo ?? this.titulo,
      comentario: comentario ?? this.comentario,
      estadoValoracion: estadoValoracion ?? this.estadoValoracion,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      fechaReporte: fechaReporte ?? this.fechaReporte,
      motivoReporte: motivoReporte ?? this.motivoReporte,
      usuarioReporteId: usuarioReporteId ?? this.usuarioReporteId,
      esVerificadoCompra: esVerificadoCompra ?? this.esVerificadoCompra,
      metadata: metadata ?? this.metadata,
      respuestaTiendaId: respuestaTiendaId ?? this.respuestaTiendaId,
      respuestaTienda: respuestaTienda ?? this.respuestaTienda,
      fechaRespuestaTienda: fechaRespuestaTienda ?? this.fechaRespuestaTienda,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
      esAnonima: esAnonima ?? this.esAnonima,
      ubicacionUsuario: ubicacionUsuario ?? this.ubicacionUsuario,
      caracteristicasProducto:
          caracteristicasProducto ?? this.caracteristicasProducto,
      tiempoUsoMeses: tiempoUsoMeses ?? this.tiempoUsoMeses,
      usoFrecuencia: usoFrecuencia ?? this.usoFrecuencia,
      recomiendaProducto: recomiendaProducto ?? this.recomiendaProducto,
      precioPagado: precioPagado ?? this.precioPagado,
      monedaPago: monedaPago ?? this.monedaPago,
      canalCompra: canalCompra ?? this.canalCompra,
    );
  }

  @override
  List<Object?> get props => [
    id,
    productoId,
    usuarioId,
    calificacion,
    titulo,
    comentario,
    estadoValoracion,
    fechaCreacion,
    fechaActualizacion,
    fechaReporte,
    motivoReporte,
    usuarioReporteId,
    esVerificadoCompra,
    metadata,
    respuestaTiendaId,
    respuestaTienda,
    fechaRespuestaTienda,
    likes,
    dislikes,
    esAnonima,
    ubicacionUsuario,
    caracteristicasProducto,
    tiempoUsoMeses,
    usoFrecuencia,
    recomiendaProducto,
    precioPagado,
    monedaPago,
    canalCompra,
  ];

  @override
  bool get stringify => true;

  /// Métodos de utilidad para UI
  String get estadoDescripcion {
    switch (estadoValoracion) {
      case EstadoValoracion.publicado:
        return 'Publicado';
      case EstadoValoracion.reportado:
        return 'Reportado';
      case EstadoValoracion.eliminado:
        return 'Eliminado';
    }
  }

  String get tipoValoracion {
    if (esPositiva) return 'Positiva';
    if (esNegativa) return 'Negativa';
    return 'Neutral';
  }

  String get verificacionDescripcion {
    if (esVerificada) return 'Compra verificada ✓';
    return 'No verificada';
  }

  String get recomendacionDescripcion {
    return recomiendaProducto
        ? 'Recomienda este producto'
        : 'No recomienda este producto';
  }

  List<String> get caracteristicasLista {
    final caracteristicas = <String>[];

    if (esVerificada) caracteristicas.add('Verificada');
    if (esReciente) caracteristicas.add('Reciente');
    if (esPopular) caracteristicas.add('Popular');
    if (esUtil) caracteristicas.add('Útil');
    if (tieneRespuestaTienda) caracteristicas.add('Con respuesta');
    if (esAnonima) caracteristicas.add('Anónima');
    if (ubicacionUsuario != null)
      caracteristicas.add('Desde: $ubicacionUsuario');

    return caracteristicas;
  }

  /// Métodos de negocio
  bool puedeSerReportadaPorUsuario(int usuarioIdReportante) {
    // Un usuario no puede reportar su propia valoración
    if (usuarioId == usuarioIdReportante) return false;

    // Solo valoraciones publicadas pueden ser reportadas
    if (!estaPublicada) return false;

    // Evitar reportes múltiples del mismo usuario
    if (usuarioReporteId == usuarioIdReportante) return false;

    return true;
  }

  bool puedeSerEditadaPorUsuario(int usuarioIdEditor) {
    // Solo el creador puede editar
    if (usuarioId != usuarioIdEditor) return false;

    // Solo valoraciones publicadas pueden ser editadas
    if (!estaPublicada) return false;

    // No se puede editar después de 24 horas
    final veinticuatroHoras = DateTime.now().subtract(
      const Duration(hours: 24),
    );
    if (fechaCreacion.isBefore(veinticuatroHoras)) return false;

    return true;
  }

  bool puedeSerRespondidaPorTienda(
    int tiendaIdRespondente,
    int productoIdActual,
  ) {
    // Verificar que la valoración pertenezca a un producto de la tienda
    // (esto se verificaría en la capa de aplicación)

    // Solo valoraciones publicadas pueden ser respondidas
    if (!estaPublicada) return false;

    // Evitar múltiples respuestas
    if (tieneRespuestaTienda) return false;

    return true;
  }

  bool esMasUtilQue(ValoracionProducto otra) {
    // Comparar por ratio de utilidad
    return ratioUtilidad > otra.ratioUtilidad;
  }

  bool esMasRecienteQue(ValoracionProducto otra) {
    return fechaCreacion.isAfter(otra.fechaCreacion);
  }

  bool esMasDetalladaQue(ValoracionProducto otra) {
    // Contar elementos de información detallada
    final detallesEsta =
        [
          titulo != null,
          comentario != null,
          caracteristicasProducto != null,
          tiempoUsoMeses != null,
          usoFrecuencia != null,
          precioPagado != null,
        ].where((element) => element).length;

    final detallesOtra =
        [
          otra.titulo != null,
          otra.comentario != null,
          otra.caracteristicasProducto != null,
          otra.tiempoUsoMeses != null,
          otra.usoFrecuencia != null,
          otra.precioPagado != null,
        ].where((element) => element).length;

    return detallesEsta > detallesOtra;
  }

  String get nivelDetalle {
    final detalles =
        [
          titulo != null,
          comentario != null,
          caracteristicasProducto != null,
          tiempoUsoMeses != null,
          usoFrecuencia != null,
          precioPagado != null,
        ].where((element) => element).length;

    if (detalles >= 5) return 'Muy detallada';
    if (detalles >= 3) return 'Detallada';
    if (detalles >= 1) return 'Básica';
    return 'Mínima';
  }

  bool necesitaModeracion() {
    // Valoraciones negativas con muchos reportes
    if (esNegativa && dislikes > 10) return true;

    // Valoraciones reportadas
    if (estaReportada) return true;

    // Comentarios potencialmente ofensivos (detección simple)
    if (comentario != null) {
      final palabrasOfensivas = ['odio', 'estafa', 'mentira', 'fraude'];
      final comentarioLower = comentario!.toLowerCase();
      if (palabrasOfensivas.any(
        (palabra) => comentarioLower.contains(palabra),
      )) {
        return true;
      }
    }

    return false;
  }

  double get impactoValoracion {
    // Calcular impacto basado en múltiples factores
    double impacto = 0.0;

    // Calificación (las extremas tienen más impacto)
    if (esNegativa) impacto += 2.0;
    if (esPositiva) impacto += 1.5;

    // Verificación
    if (esVerificada) impacto += 1.0;

    // Utilidad
    if (esUtil) impacto += 0.5;

    // Detalle
    if (tieneInformacionDetallada) impacto += 0.5;

    // Popularidad
    if (esPopular) impacto += 0.3;

    // Respuesta de tienda
    if (tieneRespuestaTienda) impacto += 0.2;

    return impacto;
  }

  bool esValoracionDestacada() {
    return impactoValoracion > 3.0;
  }
}
