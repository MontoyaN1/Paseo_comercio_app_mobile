# Arquitectura del Centro Comercial Virtual - Aplicación Móvil

## Visión General
Aplicación Flutter para llevar la experiencia de un centro comercial al mundo móvil, integrando Supabase como backend, Clerk para autenticación, y Contabo Object Storage para gestión de imágenes.

## Estructura de Carpetas Propuesta

```
lib/
├── main.dart                    # Punto de entrada de la aplicación
├── core/                        # Funcionalidades centrales
│   ├── app/                     # Configuración de la aplicación
│   │   ├── app_config.dart      # Configuración global
│   │   ├── app_router.dart      # Gestión de rutas
│   │   ├── app_theme.dart       # Temas y estilos
│   │   └── app_localizations.dart # Internacionalización
│   ├── constants/               # Constantes globales
│   │   ├── api_constants.dart   # URLs y endpoints
│   │   ├── app_constants.dart   # Constantes de la app
│   │   └── storage_constants.dart # Claves de almacenamiento
│   ├── exceptions/              # Manejo de excepciones
│   │   ├── app_exceptions.dart
│   │   └── network_exceptions.dart
│   └── utils/                   # Utilidades generales
│       ├── validators.dart      # Validaciones de formularios
│       ├── formatters.dart      # Formateadores de datos
│       └── helpers.dart         # Funciones auxiliares
├── data/                        # Capa de datos
│   ├── datasources/             # Fuentes de datos
│   │   ├── local/               # Datos locales
│   │   │   ├── local_database.dart # Base de datos local
│   │   │   └── preferences.dart # Preferencias del usuario
│   │   └── remote/              # Datos remotos
│   │       ├── supabase_client.dart # Cliente Supabase
│   │       ├── s3_client.dart   # Cliente S3 para imágenes
│   │       └── api_service.dart # Servicios API
│   ├── models/                  # Modelos de datos
│   │   ├── domain/              # Modelos de dominio
│   │   │   ├── usuario.dart
│   │   │   ├── tienda.dart
│   │   │   ├── producto.dart
│   │   │   ├── categoria.dart
│   │   │   ├── plazoleta.dart
│   │   │   ├── valoracion.dart
│   │   │   ├── horario.dart
│   │   │   ├── organizacion.dart
│   │   │   └── enums.dart       # Enums de la base de datos
│   │   └── response/            # Modelos de respuesta API
│   │       ├── api_response.dart
│   │       └── paginated_response.dart
│   ├── repositories/            # Repositorios
│   │   ├── auth_repository.dart
│   │   ├── tienda_repository.dart
│   │   ├── producto_repository.dart
│   │   ├── categoria_repository.dart
│   │   ├── imagen_repository.dart
│   │   └── cache_repository.dart
│   └── mappers/                 # Mapeadores
│       └── entity_mappers.dart
├── domain/                      # Lógica de negocio
│   ├── entities/                # Entidades de dominio
│   ├── usecases/                # Casos de uso
│   │   ├── auth_usecases.dart
│   │   ├── tienda_usecases.dart
│   │   ├── producto_usecases.dart
│   │   ├── imagen_usecases.dart
│   │   └── cache_usecases.dart
│   └── repositories/            # Interfaces de repositorios
├── presentation/                # Capa de presentación
│   ├── blocs/                   # Gestión de estado (BLoC)
│   │   ├── auth/
│   │   ├── tienda/
│   │   ├── producto/
│   │   ├── categoria/
│   │   └── imagen/
│   ├── pages/                   # Pantallas
│   │   ├── auth/                # Autenticación
│   │   │   ├── login_page.dart
│   │   │   ├── register_page.dart
│   │   │   └── profile_page.dart
│   │   ├── home/                # Inicio
│   │   │   ├── home_page.dart
│   │   │   ├── dashboard_page.dart
│   │   │   └── search_page.dart
│   │   ├── tiendas/             # Tiendas
│   │   │   ├── tienda_list_page.dart
│   │   │   ├── tienda_detail_page.dart
│   │   │   └── tienda_map_page.dart
│   │   ├── productos/           # Productos
│   │   │   ├── producto_list_page.dart
│   │   │   ├── producto_detail_page.dart
│   │   │   └── producto_search_page.dart
│   │   ├── plazoletas/          # Plazoletas
│   │   │   ├── plazoleta_list_page.dart
│   │   │   └── plazoleta_detail_page.dart
│   │   ├── categorias/          # Categorías
│   │   │   └── categoria_page.dart
│   │   ├── valoraciones/        # Valoraciones
│   │   │   └── valoracion_page.dart
│   │   └── config/              # Configuración
│   │       └── settings_page.dart
│   ├── widgets/                 # Widgets reutilizables
│   │   ├── common/              # Widgets comunes
│   │   │   ├── app_bar.dart
│   │   │   ├── bottom_nav_bar.dart
│   │   │   ├── loading_indicator.dart
│   │   │   └── error_widget.dart
│   │   ├── tienda/              # Widgets de tiendas
│   │   ├── producto/            # Widgets de productos
│   │   ├── imagen/              # Widgets de imágenes
│   │   └── forms/               # Widgets de formularios
│   └── theme/                   # Temas y estilos
│       └── app_colors.dart
└── di/                          # Inyección de dependencias
    └── service_locator.dart
```

## Configuración de Variables de Entorno

### Archivo `.env`
```
# Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# Clerk Authentication
CLERK_PUBLISHABLE_KEY=pk_test_...
CLERK_SECRET_KEY=sk_test_...

# Contabo Object Storage (S3 Compatible)
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_S3_BUCKET_NAME=paseocomercio
AWS_REGION=usc1
S3_ENDPOINT_URL=https://usc1.contabostorage.com
S3_BASE_URL=https://usc1.contabostorage.com/paseocomercio
CONTABO_TENANT_ID=your-tenant-id
CONTABO_BUCKET_FOLDER=plazoletas

# App Configuration
APP_NAME=Paseo del Comercio
APP_VERSION=1.0.0
DEBUG_MODE=true
```

### Configuración en Flutter
Usar el paquete `flutter_dotenv` para cargar variables de entorno:

```yaml
dependencies:
  flutter_dotenv: ^5.1.0
  supabase_flutter: ^2.1.3
  clerk_flutter: ^0.0.14-beta
  dio: ^5.4.0
  cached_network_image: ^3.3.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  image_picker: ^1.0.4
  image: ^4.1.4
  path_provider: ^2.1.0
  connectivity_plus: ^5.0.2
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  get_it: ^7.6.4
  intl: ^0.19.0
  url_launcher: ^6.2.2
  share_plus: ^7.2.0
  google_maps_flutter: ^2.5.0
  geolocator: ^11.0.0
```

## Comunicación con Supabase

### Cliente Supabase Configurado

```dart
// lib/data/datasources/remote/supabase_client.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientService {
  static final SupabaseClientService _instance = SupabaseClientService._internal();
  factory SupabaseClientService() => _instance;
  SupabaseClientService._internal();

  late SupabaseClient _client;
  
  Future<void> initialize() async {
    await Supabase.initialize(
      url: const String.fromEnvironment('SUPABASE_URL'),
      anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
    );
    _client = Supabase.instance.client;
  }

  SupabaseClient get client => _client;
  
  // Métodos específicos para cada tabla
  PostgrestFilterBuilder<dynamic> from(String table) => _client.from(table);
  
  // Métodos para tablas específicas
  PostgrestFilterBuilder<dynamic> get usuarios => _client.from('usuario');
  PostgrestFilterBuilder<dynamic> get tiendas => _client.from('tienda');
  PostgrestFilterBuilder<dynamic> get productos => _client.from('producto');
  PostgrestFilterBuilder<dynamic> get categorias => _client.from('categoria');
  PostgrestFilterBuilder<dynamic> get plazoletas => _client.from('plazoleta');
  PostgrestFilterBuilder<dynamic> get imagenesTienda => _client.from('imagen_tienda');
  PostgrestFilterBuilder<dynamic> get imagenesProducto => _client.from('imagen_productos');
  PostgrestFilterBuilder<dynamic> get imagenesPlazoleta => _client.from('imagen_plazoleta');
  PostgrestFilterBuilder<dynamic> get valoraciones => _client.from('valoracion_producto');
  PostgrestFilterBuilder<dynamic> get horarios => _client.from('horario');
  PostgrestFilterBuilder<dynamic> get organizaciones => _client.from('organizacion');
}
```

## Gestión de Imágenes con Contabo Object Storage

### Cliente S3 para Contabo

```dart
// lib/data/datasources/remote/s3_client.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class S3ImageService {
  final Dio _dio;
  final String _bucketName;
  final String _endpointUrl;
  final String _baseUrl;
  final String _folder;
  
  S3ImageService({
    required String accessKey,
    required String secretKey,
    required String bucketName,
    required String endpointUrl,
    required String baseUrl,
    required String folder,
    required String region,
  }) : _bucketName = bucketName,
       _endpointUrl = endpointUrl,
       _baseUrl = baseUrl,
       _folder = folder,
       _dio = Dio(BaseOptions(
         baseUrl: endpointUrl,
         headers: {
           'Host': endpointUrl.replaceAll('https://', ''),
         },
       )) {
    // Configurar autenticación S3
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Implementar firma AWS S3 v4
        final date = DateTime.now().toUtc();
        final amzDate = '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}T${date.hour.toString().padLeft(2, '0')}${date.minute.toString().padLeft(2, '0')}${date.second.toString().padLeft(2, '0')}Z';
        
        // Aquí iría la lógica de firma S3
        options.headers['x-amz-date'] = amzDate;
        options.headers['Authorization'] = _generateSignature(options, amzDate, accessKey, secretKey, region);
        
        return handler.next(options);
      },
    ));
  }
  
  String _generateSignature(RequestOptions options, String amzDate, String accessKey, String secretKey, String region) {
    // Implementar lógica de firma AWS S3 v4
    // Esto es un placeholder - necesitarías implementar la firma completa
    return 'AWS4-HMAC-SHA256 Credential=$accessKey/$amzDate/$region/s3/aws4_request, ...';
  }
  
  Future<String> uploadImage({
    required File imageFile,
    required String entityType, // 'tienda', 'producto', 'plazoleta'
    required String entityId,
    String? imageType = 'principal', // 'principal', 'galeria', 'detalle', etc.
  }) async {
    try {
      // Generar nombre único para la imagen
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = DateTime.now().microsecondsSinceEpoch % 1000000;
      final fileName = '$timestamp-$random.avif';
      
      // Ruta en S3
      final s3Path = '$_folder/$entityType/$entityId/$fileName';
      
      // Comprimir y optimizar imagen
      final compressedImage = await _compressImage(imageFile);
      
      // Subir a S3
      await _dio.put(
        '/$_bucketName/$s3Path',
        data: compressedImage,
        options: Options(
          headers: {
            'Content-Type': 'image/avif',
          },
        ),
      );
      
      // Generar URLs para diferentes tamaños
      final imageUrl = '$_baseUrl/$s3Path';
      final thumbUrl = '$_baseUrl/${s3Path.replaceAll('.avif', '-thumb.avif')}';
      final mediumUrl = '$_baseUrl/${s3Path.replaceAll('.avif', '-medium.avif')}';
      final largeUrl = '$_baseUrl/${s3Path.replaceAll('.avif', '-large.avif')}';
      
      // Crear variantes (esto podría hacerse en un servicio separado)
      await _createImageVariants(imageFile, s3Path);
      
      return imageUrl;
    } catch (e) {
      throw Exception('Error al subir imagen: $e');
    }
  }
  
  Future<Uint8List> _compressImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    
    if (image == null) throw Exception('No se pudo decodificar la imagen');
    
    // Redimensionar si es muy grande (máximo 2000px en el lado más largo)
    final maxSize = 2000;
    img.Image resizedImage;
    
    if (image.width > maxSize || image.height > maxSize) {
      if (image.width > image.height) {
        resizedImage = img.copyResize(image, width: maxSize);
      } else {
        resizedImage = img.copyResize(image, height: maxSize);
      }
    } else {
      resizedImage = image;
    }
    
    // Codificar a AVIF (formato moderno y eficiente)
    final avifBytes = img.encodeAvif(resizedImage, quality: 80);
    
    return Uint8List.fromList(avifBytes);
  }
  
  Future<void> _createImageVariants(File originalImage, String s3Path) async {
    // Crear variantes en diferentes tamaños
    final sizes = [
      {'suffix': 'thumb', 'width': 150, 'height': 150},
      {'suffix': 'medium', 'width': 500, 'height': 500},
      {'suffix': 'large', 'width': 1200, 'height': 1200},
    ];
    
    for (final size in sizes) {
      final variantBytes = await _resizeImage(
        originalImage,
        size['width'] as int,
        size['height'] as int,
      );
      
      final variantPath = s3Path.replaceAll(
        '.avif',
        '-${size['suffix']}.avif'
      );
      
      await _dio.put(
        '/$_bucketName/$variantPath',
        data: variantBytes,
        options: Options(
          headers: {
            'Content-Type': 'image/avif',
          },
        ),
      );
    }
  }
  
  Future<Uint8List> _resizeImage(File imageFile, int width, int height) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    
    if (image == null) throw Exception('No se pudo decodificar la imagen');
    
    final resizedImage = img.copyResize(
      image,
      width: width,
      height: height,
      interpolation: img.Interpolation.average,
    );
    
    return Uint8List.fromList(img.encodeAvif(resizedImage, quality: 75));
  }
}
```

## Sistema de Caché para Móviles

### Estrategia de Caché Híbrida

```dart
// lib/data/datasources/local/local_database.dart
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class LocalCacheService {
  static const String _tiendasBox = 'tiendas_cache';
  static const String _productosBox = 'productos_cache';
  static const String _categoriasBox = 'categorias_cache';
  static const String _plazoletasBox = 'plazoletas_cache';
  static const String _imagenesBox = 'imagenes_cache';
  static const String _metadataBox = 'cache_metadata';
  
  late Box _tiendasBox;
  late Box _productosBox;
  late Box _categoriasBox;
  late Box _plazoletasBox;
  late Box _imagenesBox;
  late Box _metadataBox;
  
  Future<void> initialize() async {
    final appDir = await getApplicationDocumentsDirectory();
    Hive.init(appDir.path);
    
    // Registrar adaptadores para modelos
    Hive.registerAdapter(TiendaAdapter());
    Hive.registerAdapter(ProductoAdapter());
    Hive.registerAdapter(CategoriaAdapter());
    Hive.registerAdapter(PlazoletaAdapter());
    Hive.registerAdapter(ImagenAdapter());
    
    _tiendasBox = await Hive.openBox(_tiendasBox);
    _productosBox = await Hive.openBox(_productosBox);
    _categoriasBox = await Hive.openBox(_categoriasBox);
    _plazoletasBox = await Hive.openBox(_plazoletasBox);
    _imagenesBox = await Hive.openBox(_imagenesBox);
    _metadataBox = await Hive.openBox(_metadataBox);
  }
  
  // Estrategia de caché: TTL (Time To Live) + Prioridad
  Future<void> cacheTiendas(List<Tienda> tiendas, {Duration ttl = const Duration(hours: 1)}) async {
    final cacheEntry = {
      'data': tiendas.map((t) => t.toJson()).toList(),
      'timestamp': DateTime.now().toIso8601String(),
      'ttl': ttl.inSeconds,
    };
    
    await _tiendasBox.put('all_tiendas', cacheEntry);
    await _updateMetadata('tiendas', tiendas.length);
  }
  
  Future<List<Tienda>?> getCachedTiendas() async {
    final cacheEntry = _tiendasBox.get('all_tiendas');
    if (cacheEntry == null) return null;
    
    final timestamp = DateTime.parse(cacheEntry['timestamp']);
    final ttl = Duration(seconds: cacheEntry['ttl']);
    
    if (DateTime.now().difference(timestamp) > ttl) {
      await _tiendasBox.delete('all_tiendas');
      return null;
    }
    
    final tiendasData = cacheEntry['data'] as List;
    return tiendasData.map((json) => Tienda.fromJson(json)).toList();
  }
  
  // Caché de imágenes con prioridad
  Future<void> cacheImage(String url, Uint8List bytes, {int priority = 1}) async {
    final cacheKey = _generateImageCacheKey(url);
    final cacheEntry = {
      'data': bytes,
      'timestamp': DateTime.now().toIso8601String(),
      'priority': priority,
      'access_count': 0,
    };
    
    await _imagenesBox.put(cacheKey, cacheEntry);
    
    // Limpiar caché si excede límite (LRU - Least Recently Used)
    await _cleanupImageCache();
  }
  
  Future<Uint8List?> getCachedImage(String url) async {
    final cacheKey = _generateImageCacheKey(url);
    final cacheEntry = _imagenesBox.get(cacheKey);
    
    if (cacheEntry == null) return null;
    
    // Actualizar contador de accesos
    cacheEntry['access_count'] = cacheEntry['access_count'] + 1;
    cacheEntry['last_access'] = DateTime.now().toIso8601String();
    await _imagenesBox.put(cacheKey, cacheEntry);
    
    return cacheEntry['data'] as Uint8List;
  }
  
  String _generateImageCacheKey(String url) {
    // Usar hash de la URL como clave
    return 'img_${url.hashCode}';
  }
  
  Future<void> _cleanupImageCache() async {
    const maxCacheSize = 100 * 1024 * 1024; // 100MB
    const maxItems = 500;
    
    if (_imagenesBox.length > maxItems) {
      // Obtener todas las entradas y ordenar por prioridad y último acceso
      final entries = _imagenesBox.values.toList();
      entries.sort((a, b) {
        final priorityDiff = b['priority'] - a['priority'];
        if (priorityDiff != 0) return priorityDiff;
        
        final lastAccessA = DateTime.parse(a['last_access'] ?? a['timestamp']);
        final lastAccessB = DateTime.parse(b['last_access'] ?? b['timestamp']);
        return lastAccessB.compareTo(lastAccessA);
      });
      
      // Mantener solo las primeras maxItems
      final keysToKeep = entries.take(maxItems).map((e) => e.key).toList();
      final allKeys = _imagenesBox.keys.toList();
      
      for (final key in allKeys) {
        if (!keysToKeep.contains(key)) {
          await _imagenesBox.delete(key);
        }
      }
    }
  }
  
  Future<void> _updateMetadata(String entityType, int count) async {
    final metadata = _metadataBox.get('stats', defaultValue: {});
    metadata[entityType] = {
      'count': count,
      'last_update': DateTime.now().toIso8601String(),
    };
    await _metadataBox.put('stats', metadata);
  }
  
  // Cache-first strategy para repositorios
  Future<List<Tienda>> getTiendasWithCache() async {
    // 1. Intentar obtener de caché
    final cachedTiendas = await getCachedTiendas();
    if (cachedTiendas != null) {
      // Devolver datos en caché inmediatamente
      // Luego actualizar en segundo plano
      _updateTiendasInBackground();
      return cachedTiendas;
    }
    
    // 2. Si no hay caché, obtener de red
    final remoteTiendas = await _fetchTiendasFromRemote();
    
    // 3. Guardar en caché
    await cacheTiendas(remoteTiendas);
    
    return remoteTiendas;
  }
  
  Future<void> _updateTiendasInBackground() async {
    // Actualizar caché en segundo plano
    try {
      final remoteTiendas = await _fetchTiendasFromRemote();
      await cacheTiendas(remoteTiendas);
    } catch (e) {
      // Silenciar errores en actualización en segundo plano
      print('Error updating cache in background: $e');
    }
  }
  
  Future<List<Tienda>> _fetchTiendasFromRemote() async {
    // Implementar llamada real a Supabase
    // Esto es un placeholder
    return [];
  }
}
```

## Integración Clerk + Supabase

### Sincronización de Usuarios

```dart
// lib/data/repositories/auth_repository.dart
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _supabase;
  final ClerkAuth _clerk;
  
  AuthRepository(this._supabase, this._clerk);
  
  Future<void> syncUserWithSupabase() async {
    final clerkUser = _clerk.user;
    if (clerkUser == null) return;
    
    // Verificar si el usuario ya existe en Supabase
    final existingUser = await _supabase
        .from('usuario')
        .select()
        .eq('clerk_user_id', clerkUser.id)
        .single()
        .catchError((_) => null);
    
    if (existingUser == null) {
      // Crear nuevo usuario en Supabase
      await _supabase.from('usuario').insert({
        'clerk_user_id': clerkUser.id,
        'nombre_completo': clerkUser.fullName ?? 'Usuario',
        'email': clerkUser.primaryEmailAddress?.emailAddress ?? '',
        'telefono': clerkUser.primaryPhoneNumber?.phoneNumber ?? '',
        'fecha_registro': DateTime.now().toIso8601String(),
        'perfil_publico': true,
        'estado_usuario': 'activo',
      });
    } else {
      // Actualizar último login
      await _supabase
          .from('usuario')
          .update({
            'ultimo_login': DateTime.now().toIso8601String(),
          })
          .eq('clerk_user_id', clerkUser.id);
    }
  }
  
  Future<Map<String, dynamic>?> getSupabaseUser() async {
    final clerkUser = _clerk.user;
    if (clerkUser == null) return null;
    
    return await _supabase
        .from('usuario')
        .select()
        .eq('clerk_user_id', clerkUser.id)
        .single()
        .catchError((_) => null);
  }
}
```

## Plan de Implementación por Fases

### Fase 1: Configuración y Autenticación (Semanas 1-2)
1. **Configurar entorno de desarrollo**
   - Agregar dependencias necesarias al pubspec.yaml
   - Configurar variables de entorno con flutter_dotenv
   - Estructurar carpetas según arquitectura propuesta

2. **Implementar autenticación Clerk**
   - Integrar Clerk Flutter SDK
   - Crear pantallas de login/registro
   - Sincronizar usuarios con Supabase

3. **Configurar cliente Supabase**
   - Inicializar cliente Supabase
   - Configurar políticas RLS (Row Level Security)
   - Crear servicios base de datos

### Fase 2: Núcleo de la Aplicación (Semanas 3-4)
1. **Sistema de caché local**
   - Implementar Hive para almacenamiento local
   - Crear estrategias de caché (TTL, LRU)
   - Desarrollar repositorios con cache-first strategy

2. **Gestión de imágenes**
   - Integrar Contabo Object Storage
   - Crear servicio de subida/descarga de imágenes
   - Implementar caché de imágenes optimizado

3. **Modelos de datos**
   - Crear modelos Dart para todas las tablas
   - Implementar mapeadores JSON
   - Crear adaptadores Hive

### Fase 3: Funcionalidades Principales (Semanas 5-7)
1. **Pantalla principal y navegación**
   - Dashboard con tiendas destacadas
   - Navegación por categorías
   - Búsqueda y filtros

2. **Gestión de tiendas**
   - Listado de tiendas con imágenes
   - Detalle de tienda con horarios
   - Mapa de ubicaciones (si aplica)

3. **Catálogo de productos**
   - Listado de productos por tienda/categoría
   - Detalle de producto con imágenes
   - Sistema de valoraciones

### Fase 4: Experiencia de Usuario (Semanas 8-10)
1. **Plazoletas virtuales**
   - Navegación por plazoletas temáticas
   - Galerías de imágenes de plazoletas
   - Experiencia inmersiva

2. **Interacciones sociales**
   - Compartir productos/tiendas
   - Sistema de favoritos
   - Historial de visitas

3. **Estadísticas y analíticas**
   - Seguimiento de interacciones
   - Dashboard para emprendedores
   - Reportes básicos

### Fase 5: Optimización y Lanzamiento (Semanas 11-12)
1. **Performance y optimización**
   - Optimizar carga de imágenes
   - Implementar lazy loading
   - Mejorar tiempos de respuesta

2. **Testing y QA**
   - Pruebas unitarias e integración
   - Testing de UI
   - Pruebas en dispositivos reales

3. **Preparación para producción**
   - Configurar entorno de producción
   - Optimizar tamaño de la app
   - Documentación final

## Consideraciones Especiales para Móviles

### 1. **Offline-First Approach**
- Cache-first strategy para todos los datos
- Sincronización en segundo plano cuando hay conexión
- Indicadores de estado de conexión

### 2. **Optimización de Imágenes**
- Carga progresiva de imágenes
- Formatos modernos (AVIF/WebP)
- Cache de imágenes con prioridad

### 3. **Gestión de Estado**
- BLoC para estado global
- Estado persistente entre sesiones
- Manejo de errores amigable

### 4. **Performance**
- Lazy loading de listas
- Debouncing en búsquedas
- Pre-caching de datos importantes

### 5. **UX Móvil**
- Gestos táctiles
- Navegación intuitiva
- Diseño responsive

## Recomendaciones Técnicas

### Para Clerk en Beta:
1. Mantener versión actual mientras sea estable
2. Tener plan de contingencia (Firebase Auth como backup)
3. Monitorear actualizaciones del SDK

### Para Supabase:
1. Usar políticas RLS para seguridad
2. Implementar real-time subscriptions para datos dinámicos
3. Usar funciones edge para lógica compleja

### Para Contabo S3:
1. Implementar retry logic para subidas
2. Usar multipart upload para imágenes grandes
3. Monitorear uso y costos

## Estructura de Configuración Inicial

### Archivo pubspec.yaml actualizado:
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0
  cupertino_icons: ^1.0.8
  clerk_flutter: ^0.0.14-beta
  supabase_flutter: ^2.1.3
  flutter_dotenv: ^5.1.0
  dio: ^5.4.0
  cached_network_image: ^3.3.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  image_picker: ^1.0.4
  image: ^4.1.4
  path_provider: ^2.1.0
  connectivity_plus: ^5.0.2
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  get_it: ^7.6.4
  url_launcher: ^6.2.2
  share_plus: ^7.2.0
  google_maps_flutter: ^2.5.0
  geolocator: ^11.0.0
  permission_handler: ^10.4.4
  flutter_secure_storage: ^9.0.0
  package_info_plus: ^5.0.1
  device_info_plus: ^9.0.0
```

### Archivo .env.example:
```env
# Copiar este archivo como .env y completar con tus valores

# Supabase
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# Clerk
CLERK_PUBLISHABLE_KEY=pk_test_...
CLERK_SECRET_KEY=sk_test_...

# Contabo S3
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_S3_BUCKET_NAME=paseocomercio
AWS_REGION=usc1
S3_ENDPOINT_URL=https://usc1.contabostorage.com
S3_BASE_URL=https://usc1.contabostorage.com/paseocomercio
CONTABO_TENANT_ID=your-tenant-id
CONTABO_BUCKET_FOLDER=plazoletas

# App
APP_NAME=Paseo del Comercio
APP_VERSION=1.0.0
DEBUG_MODE=true
CACHE_TTL_HOURS=1
MAX_CACHE_SIZE_MB=100
```

## Próximos Pasos Inmediatos

1. **Actualizar pubspec.yaml** con las dependencias necesarias
2. **Crear estructura de carpetas** completa según arquitectura
3. **Configurar variables de entorno** en archivo .env
4. **Implementar cliente Supabase** básico
5. **Crear modelos de datos** para las tablas principales
6. **Configurar inyección de dependencias** con GetIt
7. **Implementar pantalla de login** con Clerk
8. **Crear sistema de caché** básico con Hive

Esta arquitectura proporciona una base sólida y escalable para tu aplicación de centro comercial virtual, con especial atención a:
- Separación clara de responsabilidades
- Estrategia offline-first para móviles
- Integración robusta con Supabase y Contabo
- Sistema de caché optimizado para experiencia de usuario fluida
- Plan de implementación por fases manejable

¿Te gustaría que profundice en alguna parte específica o que comience a implementar alguna de las fases?