// lib/core/utils/image_info.dart

/// Información de una imagen
class ImageInfo {
  final int width;
  final int height;
  final int size; // en bytes
  final String format;
  final bool hasAlpha;
  final DateTime? createdAt;
  final String? url;
  final Map<String, dynamic>? metadata;

  const ImageInfo({
    required this.width,
    required this.height,
    required this.size,
    required this.format,
    required this.hasAlpha,
    this.createdAt,
    this.url,
    this.metadata,
  });

  /// Calcular relación de aspecto
  double get aspectRatio => width / height;

  /// Verificar si es retrato
  bool get isPortrait => height > width;

  /// Verificar si es paisaje
  bool get isLandscape => width > height;

  /// Verificar si es cuadrada
  bool get isSquare => width == height;

  /// Obtener tamaño en formato legible
  String get formattedSize {
    if (size < 1024) {
      return '${size} B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Obtener resolución en formato legible
  String get resolution => '${width}x$height';

  /// Verificar si es una imagen grande
  bool get isLarge => size > 1024 * 1024; // > 1MB

  /// Verificar si es una imagen muy grande
  bool get isVeryLarge => size > 5 * 1024 * 1024; // > 5MB

  /// Verificar si el formato es compatible con web
  bool get isWebCompatible {
    const webFormats = {'jpeg', 'jpg', 'png', 'gif', 'webp', 'avif', 'svg'};
    return webFormats.contains(format.toLowerCase());
  }

  /// Verificar si el formato es compatible con móviles
  bool get isMobileCompatible {
    const mobileFormats = {'jpeg', 'jpg', 'png', 'webp', 'avif'};
    return mobileFormats.contains(format.toLowerCase());
  }

  /// Verificar si el formato es vectorial
  bool get isVector => format.toLowerCase() == 'svg';

  /// Verificar si el formato es animado
  bool get isAnimated {
    const animatedFormats = {'gif', 'webp', 'avif'};
    return animatedFormats.contains(format.toLowerCase());
  }

  /// Obtener calidad estimada basada en tamaño y resolución
  String get qualityEstimate {
    final megapixels = (width * height) / 1000000;
    final sizePerPixel = size / (width * height);

    if (megapixels > 8 && sizePerPixel > 2) {
      return 'alta';
    } else if (megapixels > 4 && sizePerPixel > 1) {
      return 'media';
    } else {
      return 'baja';
    }
  }

  /// Obtener recomendación de compresión
  String get compressionRecommendation {
    if (isVeryLarge) {
      return 'Recomendado: Reducir a < 1MB';
    } else if (isLarge) {
      return 'Opcional: Reducir a < 500KB';
    } else {
      return 'Adecuado';
    }
  }

  /// Copiar con nuevos valores
  ImageInfo copyWith({
    int? width,
    int? height,
    int? size,
    String? format,
    bool? hasAlpha,
    DateTime? createdAt,
    String? url,
    Map<String, dynamic>? metadata,
  }) {
    return ImageInfo(
      width: width ?? this.width,
      height: height ?? this.height,
      size: size ?? this.size,
      format: format ?? this.format,
      hasAlpha: hasAlpha ?? this.hasAlpha,
      createdAt: createdAt ?? this.createdAt,
      url: url ?? this.url,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
      'size': size,
      'format': format,
      'hasAlpha': hasAlpha,
      'createdAt': createdAt?.toIso8601String(),
      'url': url,
      'metadata': metadata,
    };
  }

  /// Crear desde JSON
  factory ImageInfo.fromJson(Map<String, dynamic> json) {
    return ImageInfo(
      width: json['width'],
      height: json['height'],
      size: json['size'],
      format: json['format'],
      hasAlpha: json['hasAlpha'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      url: json['url'],
      metadata:
          json['metadata'] != null
              ? Map<String, dynamic>.from(json['metadata'])
              : null,
    );
  }

  /// Crear desde datos básicos
  factory ImageInfo.fromBasic({
    required int width,
    required int height,
    required int size,
    required String format,
  }) {
    return ImageInfo(
      width: width,
      height: height,
      size: size,
      format: format,
      hasAlpha: format.toLowerCase() == 'png' || format.toLowerCase() == 'svg',
    );
  }

  @override
  String toString() {
    return 'ImageInfo($resolution, $formattedSize, $format)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ImageInfo &&
        other.width == width &&
        other.height == height &&
        other.size == size &&
        other.format == format &&
        other.hasAlpha == hasAlpha &&
        other.createdAt == createdAt &&
        other.url == url &&
        _mapEquals(other.metadata, metadata);
  }

  @override
  int get hashCode {
    return Object.hash(
      width,
      height,
      size,
      format,
      hasAlpha,
      createdAt,
      url,
      metadata,
    );
  }

  /// Comparar dos mapas
  static bool _mapEquals(Map<String, dynamic>? a, Map<String, dynamic>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) {
        return false;
      }
    }

    return true;
  }
}

/// Helper para detectar formato de imagen
class ImageFormatDetector {
  /// Detectar formato de imagen desde bytes
  static String detectFromBytes(List<int> bytes) {
    if (bytes.isEmpty) return 'unknown';

    // Verificar magic numbers
    if (_isJpeg(bytes)) return 'jpeg';
    if (_isPng(bytes)) return 'png';
    if (_isGif(bytes)) return 'gif';
    if (_isWebp(bytes)) return 'webp';
    if (_isAvif(bytes)) return 'avif';
    if (_isSvg(bytes)) return 'svg';
    if (_isBmp(bytes)) return 'bmp';
    if (_isTiff(bytes)) return 'tiff';

    return 'unknown';
  }

  /// Detectar formato de imagen desde URL
  static String detectFromUrl(String url) {
    final extension = url.toLowerCase().split('.').last;
    const imageExtensions = {
      'jpg': 'jpeg',
      'jpeg': 'jpeg',
      'png': 'png',
      'gif': 'gif',
      'webp': 'webp',
      'avif': 'avif',
      'svg': 'svg',
      'bmp': 'bmp',
      'tiff': 'tiff',
      'tif': 'tiff',
    };

    return imageExtensions[extension] ?? 'unknown';
  }

  // Métodos de verificación de magic numbers
  static bool _isJpeg(List<int> bytes) {
    return bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xD8;
  }

  static bool _isPng(List<int> bytes) {
    return bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A;
  }

  static bool _isGif(List<int> bytes) {
    return bytes.length >= 6 &&
        bytes[0] == 0x47 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x38 &&
        (bytes[4] == 0x37 || bytes[4] == 0x39) &&
        bytes[5] == 0x61;
  }

  static bool _isWebp(List<int> bytes) {
    return bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50;
  }

  static bool _isAvif(List<int> bytes) {
    return bytes.length >= 12 &&
        bytes[4] == 0x66 &&
        bytes[5] == 0x74 &&
        bytes[6] == 0x79 &&
        bytes[7] == 0x70 &&
        bytes[8] == 0x61 &&
        bytes[9] == 0x76 &&
        bytes[10] == 0x69 &&
        bytes[11] == 0x66;
  }

  static bool _isSvg(List<int> bytes) {
    if (bytes.isEmpty) return false;

    final content = String.fromCharCodes(bytes).toLowerCase();
    return content.contains('<svg') && content.contains('</svg>');
  }

  static bool _isBmp(List<int> bytes) {
    return bytes.length >= 2 && bytes[0] == 0x42 && bytes[1] == 0x4D;
  }

  static bool _isTiff(List<int> bytes) {
    return bytes.length >= 4 &&
        ((bytes[0] == 0x49 &&
                bytes[1] == 0x49 &&
                bytes[2] == 0x2A &&
                bytes[3] == 0x00) ||
            (bytes[0] == 0x4D &&
                bytes[1] == 0x4D &&
                bytes[2] == 0x00 &&
                bytes[3] == 0x2A));
  }
}
