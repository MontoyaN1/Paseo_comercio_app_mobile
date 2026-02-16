// lib/core/app/app_config.dart

/// Configuración global de la aplicación
class AppConfig {
  // Singleton pattern
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  // Información de la aplicación
  String appName = 'Paseo del Comercio';
  String appVersion = '1.0.0';
  String appBuildNumber = '1';

  // Configuración de Supabase
  String supabaseUrl = '';
  String supabaseAnonKey = '';
  String supabaseServiceRoleKey = '';

  // Configuración de Clerk
  String clerkPublishableKey = '';
  String clerkSecretKey = '';

  // Configuración de Contabo Object Storage
  String awsAccessKeyId = '';
  String awsSecretAccessKey = '';
  String awsS3BucketName = '';
  String awsRegion = '';
  String s3EndpointUrl = '';
  String s3BaseUrl = '';
  String contaboTenantId = '';
  String contaboBucketFolder = '';

  // Configuración de caché
  int cacheTtlHours = 1; // Tiempo de vida de caché en horas
  int maxCacheSizeMB = 100; // Tamaño máximo de caché en MB
  int maxImageCacheItems = 500; // Máximo número de imágenes en caché

  // Configuración de red
  int connectionTimeoutSeconds = 30;
  int receiveTimeoutSeconds = 30;

  // Configuración de imágenes
  int maxImageWidth = 2000;
  int maxImageHeight = 2000;
  int imageQuality = 80;
  List<int> imageVariants = [150, 500, 1200]; // Tamaños de variantes

  // Configuración de desarrollo
  bool debugMode = false;
  bool enableLogging = true;
  bool enableAnalytics = true;

  /// Inicializar configuración desde variables de entorno
  Future<void> initializeFromEnv(Map<String, String> env) async {
    // Información de la aplicación
    appName = env['APP_NAME'] ?? appName;
    appVersion = env['APP_VERSION'] ?? appVersion;

    // Supabase
    supabaseUrl = env['SUPABASE_URL'] ?? '';
    supabaseAnonKey = env['SUPABASE_ANON_KEY'] ?? '';
    supabaseServiceRoleKey = env['SUPABASE_SERVICE_ROLE_KEY'] ?? '';

    // Clerk
    clerkPublishableKey = env['CLERK_PUBLISHABLE_KEY'] ?? '';
    clerkSecretKey = env['CLERK_SECRET_KEY'] ?? '';

    // Contabo S3
    awsAccessKeyId = env['AWS_ACCESS_KEY_ID'] ?? '';
    awsSecretAccessKey = env['AWS_SECRET_ACCESS_KEY'] ?? '';
    awsS3BucketName = env['AWS_S3_BUCKET_NAME'] ?? '';
    awsRegion = env['AWS_REGION'] ?? '';
    s3EndpointUrl = env['S3_ENDPOINT_URL'] ?? '';
    s3BaseUrl = env['S3_BASE_URL'] ?? '';
    contaboTenantId = env['CONTABO_TENANT_ID'] ?? '';
    contaboBucketFolder = env['CONTABO_BUCKET_FOLDER'] ?? '';

    // Configuración de caché
    final cacheTtl = env['CACHE_TTL_HOURS'];
    if (cacheTtl != null) {
      cacheTtlHours = int.tryParse(cacheTtl) ?? cacheTtlHours;
    }

    final maxCache = env['MAX_CACHE_SIZE_MB'];
    if (maxCache != null) {
      maxCacheSizeMB = int.tryParse(maxCache) ?? maxCacheSizeMB;
    }

    // Configuración de desarrollo
    debugMode = env['DEBUG_MODE']?.toLowerCase() == 'true';
    enableLogging = env['ENABLE_LOGGING']?.toLowerCase() != 'false';
    enableAnalytics = env['ENABLE_ANALYTICS']?.toLowerCase() != 'false';

    // Validar configuración mínima requerida
    _validateConfiguration();
  }

  /// Validar que la configuración mínima esté presente
  void _validateConfiguration() {
    final errors = <String>[];

    if (supabaseUrl.isEmpty) errors.add('SUPABASE_URL es requerido');
    if (supabaseServiceRoleKey.isEmpty)
      errors.add('SUPABASE_SERVICE_ROLE_KEY es requerido');
    if (clerkPublishableKey.isEmpty) {
      errors.add('CLERK_PUBLISHABLE_KEY es requerido');
    }

    if (errors.isNotEmpty) {
      throw Exception('Configuración incompleta: ${errors.join(', ')}');
    }
  }

  /// Verificar si la configuración de S3 está completa
  bool get isS3Configured =>
      awsAccessKeyId.isNotEmpty &&
      awsSecretAccessKey.isNotEmpty &&
      awsS3BucketName.isNotEmpty &&
      s3EndpointUrl.isNotEmpty;

  /// Verificar si la configuración de Supabase está completa
  bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseServiceRoleKey.isNotEmpty;

  /// Verificar si la configuración de Clerk está completa
  bool get isClerkConfigured => clerkPublishableKey.isNotEmpty;

  /// Obtener URL base para imágenes
  String getImageBaseUrl(String entityType, String entityId) {
    if (!isS3Configured) return '';
    return '$s3BaseUrl/$contaboBucketFolder/$entityType/$entityId';
  }

  /// Obtener variantes de URL para una imagen
  Map<String, String> getImageVariants(String imageUrl) {
    final variants = <String, String>{};

    if (imageUrl.isEmpty) return variants;

    // URL original
    variants['original'] = imageUrl;

    // Generar URLs para cada variante
    for (final size in imageVariants) {
      final variantUrl = imageUrl.replaceAll(
        '.avif',
        '-${size == 150
            ? 'thumb'
            : size == 500
            ? 'medium'
            : 'large'}.avif',
      );
      variants['${size}px'] = variantUrl;
    }

    return variants;
  }

  @override
  String toString() {
    return '''
AppConfig:
  App: $appName v$appVersion
  Supabase: ${isSupabaseConfigured ? 'Configurado' : 'No configurado'}
  Clerk: ${isClerkConfigured ? 'Configurado' : 'No configurado'}
  S3: ${isS3Configured ? 'Configurado' : 'No configurado'}
  Cache: ${cacheTtlHours}h, ${maxCacheSizeMB}MB
  Debug: $debugMode
''';
  }
}
