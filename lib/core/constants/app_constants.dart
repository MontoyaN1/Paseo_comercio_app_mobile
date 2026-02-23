// lib/core/constants/app_constants.dart

/// Constantes globales de la aplicación
class AppConstants {
  // Singleton pattern
  static final AppConstants _instance = AppConstants._internal();
  factory AppConstants() => _instance;
  AppConstants._internal();

  // Nombres de las tablas de la base de datos
  static const String tableUsuario = 'usuario';
  static const String tableTienda = 'tienda';
  static const String tableProducto = 'producto';
  static const String tablePlazoleta = 'plazoleta';
  static const String tableOrganizacion = 'organizacion';
  static const String tableCategoria = 'categoria';
  static const String tableHorario = 'horario';
  static const String tableValoracionProducto = 'valoracion_producto';
  static const String tableEtiquetaTienda = 'etiqueta_tienda';
  static const String tableEtiquetaProducto = 'etiqueta_producto';
  static const String tableImagenTienda = 'imagen_tienda';
  static const String tableImagenProductos = 'imagen_productos';
  static const String tableImagenPlazoleta = 'imagen_plazoleta';
  static const String tableImagenOrganizacion = 'imagen_organizacion';
  static const String tableImagenValoracionProducto =
      'imagen_valoracion_producto';
  static const String tableInteraccion = 'interaccion';
  static const String tableEstadisticasDiarias = 'estadisticas_diarias';
  static const String tableMiembrosOrganizacion = 'miembros_organizacion';
  static const String tableNotificacion = 'notificacion';

  // Nombres de las boxes de Hive
  static const String hiveBoxTiendas = 'tiendas';
  static const String hiveBoxProductos = 'productos';
  static const String hiveBoxCategorias = 'categorias';
  static const String hiveBoxUsuario = 'usuario';
  static const String hiveBoxConfig = 'config';
  static const String hiveBoxCache = 'cache';

  // Type IDs para Hive
  static const int hiveTypeIdTienda = 1;
  static const int hiveTypeIdProducto = 2;
  static const int hiveTypeIdCategoria = 3;
  static const int hiveTypeIdUsuario = 4;

  // Tiempos de caché (en segundos)
  static const int cacheTtlTiendas = 3600; // 1 hora
  static const int cacheTtlProductos = 1800; // 30 minutos
  static const int cacheTtlCategorias = 86400; // 24 horas
  static const int cacheTtlImagenes = 604800; // 7 días

  // Límites de paginación
  static const int itemsPerPageTiendas = 20;
  static const int itemsPerPageProductos = 30;
  static const int itemsPerPageCategorias = 50;

  // Rutas de la aplicación
  static const String routeHome = '/';
  static const String routeLogin = '/login';
  static const String routeProfile = '/profile';
  static const String routeTiendas = '/tiendas';
  static const String routeProductos = '/productos';
  static const String routeCategorias = '/categorias';
  static const String routeFavoritos = '/favoritos';
  static const String routeHistorial = '/historial';
  static const String routeConfiguracion = '/configuracion';

  // URLs y endpoints
  static const String supabaseStorageUrl = 'storage/v1/object/public';
  static const String s3ImageBasePath = 'images';

  // Tamaños de imágenes
  static const List<int> imageVariants = [150, 500, 1200];
  static const String imageVariantThumb = 'thumb';
  static const String imageVariantMedium = 'medium';
  static const String imageVariantLarge = 'large';

  // Nombres de variantes de imágenes
  static const Map<int, String> imageVariantNames = {
    150: imageVariantThumb,
    500: imageVariantMedium,
    1200: imageVariantLarge,
  };

  // Formatos de fecha
  static const String dateFormatDisplay = 'dd/MM/yyyy';
  static const String dateTimeFormatDisplay = 'dd/MM/yyyy HH:mm';
  static const String timeFormatDisplay = 'HH:mm';

  // Mensajes de error
  static const String errorNetwork = 'Error de conexión. Verifica tu internet.';
  static const String errorServer = 'Error del servidor. Intenta más tarde.';
  static const String errorUnknown = 'Error desconocido.';
  static const String errorNoData = 'No se encontraron datos.';
  static const String errorAuthRequired =
      'Debes iniciar sesión para acceder a esta función.';

  // Mensajes de éxito
  static const String successSaved = 'Guardado exitosamente.';
  static const String successUpdated = 'Actualizado exitosamente.';
  static const String successDeleted = 'Eliminado exitosamente.';

  // Textos de UI
  static const String appName = 'Paseo del Comercio';
  static const String appTagline = 'Centro Comercial Virtual';
  static const String loadingText = 'Cargando...';
  static const String retryText = 'Reintentar';
  static const String cancelText = 'Cancelar';
  static const String confirmText = 'Confirmar';
  static const String saveText = 'Guardar';
  static const String editText = 'Editar';
  static const String deleteText = 'Eliminar';
  static const String viewText = 'Ver';
  static const String shareText = 'Compartir';
  static const String favoriteText = 'Favorito';
  static const String unfavoriteText = 'Quitar de favoritos';

  // Colores de la aplicación (como referencia)
  static const int primaryColorValue = 0xFF2196F3; // Azul
  static const int secondaryColorValue = 0xFF4CAF50; // Verde
  static const int accentColorValue = 0xFFFF9800; // Naranja
  static const int backgroundColorValue = 0xFFF8F9FA; // Gris claro
  static const int surfaceColorValue = 0xFFFFFFFF; // Blanco
  static const int errorColorValue = 0xFFF44336; // Rojo
  static const int successColorValue = 0xFF4CAF50; // Verde
  static const int warningColorValue = 0xFFFF9800; // Naranja
  static const int infoColorValue = 0xFF2196F3; // Azul

  // Tamaños de diseño
  static const double defaultPadding = 16.0;
  static const double defaultMargin = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double defaultElevation = 2.0;
  static const double appBarHeight = 56.0;
  static const double bottomNavBarHeight = 56.0;

  // Tiempos de animación (en milisegundos)
  static const int animationDurationShort = 200;
  static const int animationDurationMedium = 300;
  static const int animationDurationLong = 500;

  // Configuración de red
  static const int connectionTimeoutSeconds = 30;
  static const int receiveTimeoutSeconds = 30;
  static const int maxRetryAttempts = 3;
  static const int retryDelayMilliseconds = 1000;

  // Configuración de imágenes
  static const int maxImageWidth = 2000;
  static const int maxImageHeight = 2000;
  static const int imageQuality = 80;
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB

  // Configuración de caché
  static const int maxCacheSizeMB = 100;
  static const int maxImageCacheItems = 500;

  // Estados de conexión
  static const String connectionStatusConnected = 'connected';
  static const String connectionStatusDisconnected = 'disconnected';
  static const String connectionStatusChecking = 'checking';

  // Modos de autenticación
  static const String authModeClerk = 'clerk';
  static const String authModeSupabase = 'supabase';
  static const String authModeGuest = 'guest';

  // Proveedores de almacenamiento de imágenes
  static const String imageProviderR2 = 'r2';
  static const String imageProviderS3 = 's3';
  static const String imageProviderSupabase = 'supabase';

  // Tipos de entidades para imágenes
  static const String imageEntityTienda = 'tienda';
  static const String imageEntityProducto = 'producto';
  static const String imageEntityPlazoleta = 'plazoleta';
  static const String imageEntityOrganizacion = 'organizacion';
  static const String imageEntityValoracion = 'valoracion';

  // Métodos de ordenación
  static const String sortByDate = 'fecha';
  static const String sortByName = 'nombre';
  static const String sortByPopularity = 'popularidad';
  static const String sortByRating = 'valoracion';
  static const String sortByPrice = 'precio';

  // Direcciones de ordenación
  static const String sortAsc = 'asc';
  static const String sortDesc = 'desc';

  // Tipos de notificaciones
  static const String notificationTypeInfo = 'info';
  static const String notificationTypeSuccess = 'success';
  static const String notificationTypeWarning = 'warning';
  static const String notificationTypeError = 'error';

  // Plataformas
  static const String platformAndroid = 'android';
  static const String platformIOS = 'ios';
  static const String platformWeb = 'web';
  static const String platformWindows = 'windows';
  static const String platformLinux = 'linux';
  static const String platformMacOS = 'macos';

  /// Obtener nombre de variante de imagen por tamaño
  static String getImageVariantName(int size) {
    return imageVariantNames[size] ?? imageVariantMedium;
  }

  /// Obtener tamaño de variante por nombre
  static int getImageVariantSize(String name) {
    switch (name) {
      case imageVariantThumb:
        return 150;
      case imageVariantMedium:
        return 500;
      case imageVariantLarge:
        return 1200;
      default:
        return 500;
    }
  }

  /// Verificar si un tamaño es una variante válida
  static bool isValidImageVariant(int size) {
    return imageVariants.contains(size);
  }

  /// Obtener URL base para imágenes según entidad
  static String getImageBasePath(String entityType) {
    return '$s3ImageBasePath/$entityType';
  }

  /// Obtener nombre de tabla por entidad
  static String getTableName(String entityType) {
    switch (entityType) {
      case imageEntityTienda:
        return tableImagenTienda;
      case imageEntityProducto:
        return tableImagenProductos;
      case imageEntityPlazoleta:
        return tableImagenPlazoleta;
      case imageEntityOrganizacion:
        return tableImagenOrganizacion;
      case imageEntityValoracion:
        return tableImagenValoracionProducto;
      default:
        return '';
    }
  }
}
