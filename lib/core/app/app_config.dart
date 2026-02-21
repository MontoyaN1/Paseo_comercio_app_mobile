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

  // Configuración de Firebase (se usa firebase_options.dart)
  // No se necesitan variables de entorno para Firebase

  // Configuración de Cloudflare R2
  String cloudflareAccountId = '';
  String cloudflareR2AccessKeyId = '';
  String cloudflareR2SecretAccessKey = '';
  String cloudflareR2BucketName = '';
  String cloudflareR2PublicUrl = '';

  // Configuración de Contabo Object Storage (fallback)
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

    // Firebase - se configura automáticamente con firebase_options.dart
    // No se necesitan variables de entorno

    // Cloudflare R2
    cloudflareAccountId = env['CLOUDFLARE_ACCOUNT_ID'] ?? '';
    cloudflareR2AccessKeyId = env['CLOUDFLARE_R2_ACCESS_KEY_ID'] ?? '';
    cloudflareR2SecretAccessKey = env['CLOUDFLARE_R2_SECRET_ACCESS_KEY'] ?? '';
    cloudflareR2BucketName = env['CLOUDFLARE_R2_BUCKET_NAME'] ?? '';
    cloudflareR2PublicUrl = env['CLOUDFLARE_R2_PUBLIC_URL'] ?? '';

    // Contabo S3 (fallback)
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
    if (supabaseServiceRoleKey.isEmpty) {
      errors.add('SUPABASE_SERVICE_ROLE_KEY es requerido');
    }
    // Firebase se valida automáticamente con firebase_options.dart
    // No se necesitan validaciones de variables de entorno

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

  /// Verificar si la configuración de R2 está completa
  bool get isR2Configured =>
      cloudflareAccountId.isNotEmpty &&
      cloudflareR2AccessKeyId.isNotEmpty &&
      cloudflareR2SecretAccessKey.isNotEmpty &&
      cloudflareR2BucketName.isNotEmpty &&
      cloudflareR2PublicUrl.isNotEmpty;

  /// Verificar si la configuración de Supabase está completa
  bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseServiceRoleKey.isNotEmpty;

  /// Verificar si la configuración de Firebase está completa
  /// Siempre es true porque se usa firebase_options.dart
  bool get isFirebaseConfigured => true;

  /// Obtener URL base para imágenes (prioriza R2, luego S3)
  String getImageBaseUrl(String entityType, String entityId) {
    if (isR2Configured) {
      return '$cloudflareR2PublicUrl/$entityType/$entityId';
    } else if (isS3Configured) {
      return '$s3BaseUrl/$contaboBucketFolder/$entityType/$entityId';
    }
    return '';
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

  /// Obtener lista de variables de entorno requeridas
  Map<String, String> getRequiredEnvVariables() {
    return {
      // Supabase (obligatorias)
      'SUPABASE_URL': 'URL de tu proyecto Supabase',
      'SUPABASE_ANON_KEY': 'Clave anónima de Supabase',
      'SUPABASE_SERVICE_ROLE_KEY': 'Clave de rol de servicio de Supabase',

      // Firebase - configurado automáticamente con firebase_options.dart
      // No se necesitan variables de entorno

      // Cloudflare R2 (opcionales, para migración)
      'CLOUDFLARE_ACCOUNT_ID': 'ID de cuenta de Cloudflare',
      'CLOUDFLARE_R2_ACCESS_KEY_ID': 'Access Key ID de R2',
      'CLOUDFLARE_R2_SECRET_ACCESS_KEY': 'Secret Access Key de R2',
      'CLOUDFLARE_R2_BUCKET_NAME': 'Nombre del bucket R2',
      'CLOUDFLARE_R2_PUBLIC_URL': 'URL pública del bucket R2',

      // Contabo S3 (opcionales, fallback)
      'AWS_ACCESS_KEY_ID': 'Access Key ID de S3',
      'AWS_SECRET_ACCESS_KEY': 'Secret Access Key de S3',
      'AWS_S3_BUCKET_NAME': 'Nombre del bucket S3',
      'AWS_REGION': 'Región de S3',
      'S3_ENDPOINT_URL': 'URL del endpoint S3',
      'S3_BASE_URL': 'URL base para imágenes S3',
      'CONTABO_TENANT_ID': 'ID del tenant Contabo',
      'CONTABO_BUCKET_FOLDER': 'Carpeta del bucket Contabo',

      // Configuración (opcionales)
      'DEBUG_MODE': 'true/false para modo debug',
      'ENABLE_LOGGING': 'true/false para logging',
      'ENABLE_ANALYTICS': 'true/false para analytics',
      'CACHE_TTL_HOURS': 'TTL de caché en horas (default: 1)',
      'MAX_CACHE_SIZE_MB': 'Tamaño máximo de caché en MB (default: 100)',
    };
  }

  @override
  String toString() {
    return '''
AppConfig:
  App: $appName v$appVersion
  Supabase: ${isSupabaseConfigured ? 'Configurado' : 'No configurado'}
  Firebase: Configurado (firebase_options.dart)
  Cloudflare R2: ${isR2Configured ? 'Configurado' : 'No configurado'}
  Contabo S3: ${isS3Configured ? 'Configurado' : 'No configurado'}
  Cache: ${cacheTtlHours}h, ${maxCacheSizeMB}MB
  Debug: $debugMode
''';
  }
}
