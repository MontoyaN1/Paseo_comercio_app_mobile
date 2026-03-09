// lib/domain/entities/enums.dart

/// Enums correspondientes a los tipos definidos en la base de datos

// ==============================================
// ESTADOS
// ==============================================

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
  banner('banner'),
  icono('icono'),
  thumbnail('thumbnail');

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
      orElse: () => TipoOrganizacion.fundacion,
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
  plazoleta('plazoleta'),
  entrada('entrada'),
  escalera('escalera'),
  ascensor('ascensor'),
  bano('baño'),
  estacionamiento('estacionamiento');

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

// ==============================================
// ENUMS FALTANTES
// ==============================================

/// Días de la semana para horarios
enum DiaSemana {
  lunes('lunes'),
  martes('martes'),
  miercoles('miercoles'),
  jueves('jueves'),
  viernes('viernes'),
  sabado('sabado'),
  domingo('domingo');

  final String value;
  const DiaSemana(this.value);

  factory DiaSemana.fromString(String value) {
    return DiaSemana.values.firstWhere(
      (e) => e.value == value,
      orElse: () => DiaSemana.lunes,
    );
  }

  @override
  String toString() => value;
}

/// Tipo de categoría
enum TipoCategoria {
  producto('producto'),
  servicio('servicio'),
  mixto('mixto');

  final String value;
  const TipoCategoria(this.value);

  factory TipoCategoria.fromString(String value) {
    return TipoCategoria.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TipoCategoria.producto,
    );
  }

  @override
  String toString() => value;
}

/// Nivel de prioridad
enum NivelPrioridad {
  baja('baja'),
  media('media'),
  alta('alta'),
  critica('critica');

  final String value;
  const NivelPrioridad(this.value);

  factory NivelPrioridad.fromString(String value) {
    return NivelPrioridad.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NivelPrioridad.media,
    );
  }

  @override
  String toString() => value;
}

/// Tipo de estadística
enum TipoEstadistica {
  visitas('visitas'),
  interacciones('interacciones'),
  conversiones('conversiones'),
  ingresos('ingresos');

  final String value;
  const TipoEstadistica(this.value);

  factory TipoEstadistica.fromString(String value) {
    return TipoEstadistica.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TipoEstadistica.visitas,
    );
  }

  @override
  String toString() => value;
}

/// Estado de conexión
enum EstadoConexion {
  conectado('conectado'),
  desconectado('desconectado'),
  verificando('verificando');

  final String value;
  const EstadoConexion(this.value);

  factory EstadoConexion.fromString(String value) {
    return EstadoConexion.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EstadoConexion.verificando,
    );
  }

  @override
  String toString() => value;
}

/// Tipo de proveedor de imágenes
enum TipoProveedorImagen {
  r2('r2'),
  s3('s3'),
  supabase('supabase');

  final String value;
  const TipoProveedorImagen(this.value);

  factory TipoProveedorImagen.fromString(String value) {
    return TipoProveedorImagen.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TipoProveedorImagen.r2,
    );
  }

  @override
  String toString() => value;
}

/// Método de ordenación
enum MetodoOrdenacion {
  fecha('fecha'),
  nombre('nombre'),
  popularidad('popularidad'),
  valoracion('valoracion'),
  precio('precio');

  final String value;
  const MetodoOrdenacion(this.value);

  factory MetodoOrdenacion.fromString(String value) {
    return MetodoOrdenacion.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MetodoOrdenacion.fecha,
    );
  }

  @override
  String toString() => value;
}

/// Dirección de ordenación
enum DireccionOrdenacion {
  ascendente('asc'),
  descendente('desc');

  final String value;
  const DireccionOrdenacion(this.value);

  factory DireccionOrdenacion.fromString(String value) {
    return DireccionOrdenacion.values.firstWhere(
      (e) => e.value == value,
      orElse: () => DireccionOrdenacion.descendente,
    );
  }

  @override
  String toString() => value;
}

/// Tipo de plataforma
enum TipoPlataforma {
  android('android'),
  ios('ios'),
  web('web'),
  windows('windows'),
  linux('linux'),
  macos('macos');

  final String value;
  const TipoPlataforma(this.value);

  factory TipoPlataforma.fromString(String value) {
    return TipoPlataforma.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TipoPlataforma.android,
    );
  }

  @override
  String toString() => value;
}

/// Tipo de red social
enum TipoRedSocial {
  facebook('facebook'),
  instagram('instagram'),
  twitter('twitter'),
  tiktok('tiktok'),
  youtube('youtube'),
  whatsapp('whatsapp'),
  linkedin('linkedin'),
  website('website');

  final String value;
  const TipoRedSocial(this.value);

  factory TipoRedSocial.fromString(String value) {
    return TipoRedSocial.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TipoRedSocial.website,
    );
  }

  @override
  String toString() => value;
}

/// Tipo de moneda
enum TipoMoneda {
  usd('USD'),
  eur('EUR'),
  cop('COP'),
  mxn('MXN');

  final String value;
  const TipoMoneda(this.value);

  factory TipoMoneda.fromString(String value) {
    return TipoMoneda.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TipoMoneda.cop,
    );
  }

  @override
  String toString() => value;
}

/// Tipo de unidad de medida
enum TipoUnidadMedida {
  unidad('unidad'),
  kilogramo('kilogramo'),
  gramo('gramo'),
  litro('litro'),
  mililitro('mililitro'),
  metro('metro'),
  centimetro('centimetro');

  final String value;
  const TipoUnidadMedida(this.value);

  factory TipoUnidadMedida.fromString(String value) {
    return TipoUnidadMedida.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TipoUnidadMedida.unidad,
    );
  }

  @override
  String toString() => value;
}

/// Tipo de entidad para horarios
enum TipoEntidadHorario {
  tienda('tienda'),
  plazoleta('plazoleta'),
  organizacion('organizacion'),
  general('general');

  final String value;
  const TipoEntidadHorario(this.value);

  factory TipoEntidadHorario.fromString(String value) {
    return TipoEntidadHorario.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TipoEntidadHorario.general,
    );
  }

  @override
  String toString() => value;
}
