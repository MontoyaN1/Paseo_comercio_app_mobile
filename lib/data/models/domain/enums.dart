// lib/data/models/domain/enums.dart

/// Enums correspondientes a los tipos definidos en la base de datos

/// Estado de un producto
enum EstadoProducto {
  publicado('publicado'),
  agotado('agotado'),
  eliminado('eliminado'),
  inactivo('inactivo');

  final String value;
  const EstadoProducto(this.value);

  factory EstadoProducto.fromString(String value) {
    return EstadoProducto.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EstadoProducto.publicado,
    );
  }

  @override
  String toString() => value;
}

/// Estado de un usuario
enum EstadoUsuario {
  activo('activo'),
  inactivo('inactivo'),
  bloqueado('bloqueado');

  final String value;
  const EstadoUsuario(this.value);

  factory EstadoUsuario.fromString(String value) {
    return EstadoUsuario.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EstadoUsuario.activo,
    );
  }

  @override
  String toString() => value;
}

/// Estado de una valoración
enum EstadoValoracion {
  publicado('publicado'),
  reportado('reportado'),
  eliminado('eliminado');

  final String value;
  const EstadoValoracion(this.value);

  factory EstadoValoracion.fromString(String value) {
    return EstadoValoracion.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EstadoValoracion.publicado,
    );
  }

  @override
  String toString() => value;
}

/// Estado de un miembro de organización
enum EstadoMiembro {
  pendiente('Pendiente'),
  activo('Activo'),
  rechazado('Rechazado');

  final String value;
  const EstadoMiembro(this.value);

  factory EstadoMiembro.fromString(String value) {
    return EstadoMiembro.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EstadoMiembro.pendiente,
    );
  }

  @override
  String toString() => value;
}

/// Tipo de horario
enum TipoHorario {
  normal('normal'),
  festivo('festivo'),
  especial('especial');

  final String value;
  const TipoHorario(this.value);

  factory TipoHorario.fromString(String value) {
    return TipoHorario.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TipoHorario.normal,
    );
  }

  @override
  String toString() => value;
}

/// Tipo de imagen
enum TipoImagen {
  principal('principal'),
  galeria('galeria'),
  detalle('detalle'),
  zoom('zoom'),
  logo('logo'),
  plazoletaProductosFondo('plazoleta_productos_fondo'),
  banner('banner');

  final String value;
  const TipoImagen(this.value);

  factory TipoImagen.fromString(String value) {
    return TipoImagen.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TipoImagen.principal,
    );
  }

  @override
  String toString() => value;
}

/// Tipo de organización
enum TipoOrganizacion {
  fundacion('fundacion'),
  asociacion('asociacion'),
  cooperativa('cooperativa'),
  empresa('empresa'),
  comunidad('comunidad'),
  otro('otro');

  final String value;
  const TipoOrganizacion(this.value);

  factory TipoOrganizacion.fromString(String value) {
    return TipoOrganizacion.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TipoOrganizacion.empresa,
    );
  }

  @override
  String toString() => value;
}

/// Tipo de rol
enum TipoRol {
  cliente('cliente'),
  emprendedor('emprendedor'),
  anfitrion('anfritrión'),
  administrador('administrador'),
  admin('admin');

  final String value;
  const TipoRol(this.value);

  factory TipoRol.fromString(String value) {
    return TipoRol.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TipoRol.cliente,
    );
  }

  @override
  String toString() => value;
}

/// Tipo de ubicación
enum TipoUbicacion {
  pasillo('pasillo'),
  plazoleta('plazoleta');

  final String value;
  const TipoUbicacion(this.value);

  factory TipoUbicacion.fromString(String value) {
    return TipoUbicacion.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TipoUbicacion.plazoleta,
    );
  }

  @override
  String toString() => value;
}

/// Tipo de interacción
enum TipoInteraccion {
  visualizacion('visualizacion'),
  clickWhatsapp('click_whatsapp'),
  compartido('compartido'),
  clickInstagram('click_instagram'),
  clickFacebook('click_facebook'),
  favorito('favorito');

  final String value;
  const TipoInteraccion(this.value);

  factory TipoInteraccion.fromString(String value) {
    return TipoInteraccion.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TipoInteraccion.visualizacion,
    );
  }

  @override
  String toString() => value;
}

/// Tipo de notificación
enum TipoNotificacion {
  mensajeSistema('mensaje_sistema'),
  nuevaValoracion('nueva_valoracion'),
  nuevoProducto('nuevo_producto'),
  ofertaEspecial('oferta_especial'),
  recordatorio('recordatorio');

  final String value;
  const TipoNotificacion(this.value);

  factory TipoNotificacion.fromString(String value) {
    return TipoNotificacion.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TipoNotificacion.mensajeSistema,
    );
  }

  @override
  String toString() => value;
}
