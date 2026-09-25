// lib/core/config/r2_config.dart

/// Configuración simplificada para Cloudflare R2
/// Solo almacena las credenciales necesarias
class R2Config {
  // Singleton pattern
  static final R2Config _instance = R2Config._internal();
  factory R2Config() => _instance;
  R2Config._internal();

  // Credenciales básicas de Cloudflare R2
  String accountId = '';
  String accessKeyId = '';
  String secretAccessKey = '';
  String bucketName = '';
  String publicUrl = '';

  /// Configurar R2 con credenciales básicas
  void configure({
    required String accountId,
    required String accessKeyId,
    required String secretAccessKey,
    required String bucketName,
    required String publicUrl,
  }) {
    this.accountId = accountId;
    this.accessKeyId = accessKeyId;
    this.secretAccessKey = secretAccessKey;
    this.bucketName = bucketName;
    this.publicUrl = publicUrl;
  }

  /// Verificar si R2 está configurado
  bool get isConfigured =>
      accountId.isNotEmpty &&
      accessKeyId.isNotEmpty &&
      secretAccessKey.isNotEmpty &&
      bucketName.isNotEmpty &&
      publicUrl.isNotEmpty;

  /// Obtener URL para una imagen
  String getImageUrl({
    required String entityType,
    required String entityId,
    required String imageName,
    String variant = 'original',
  }) {
    if (!isConfigured) {
      throw Exception('R2 no está configurado');
    }

    final variantSuffix = variant == 'original' ? '' : '-$variant';
    final fileName = '${imageName.split('.').first}$variantSuffix.jpg';

    return '$publicUrl/$entityType/$entityId/$fileName';
  }

  @override
  String toString() {
    return '''
R2Config:
  - Configurado: ${isConfigured ? 'Sí' : 'No'}
  - Bucket: $bucketName
  - Public URL: $publicUrl
''';
  }
}
