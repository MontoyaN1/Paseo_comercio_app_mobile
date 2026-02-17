// lib/core/utils/image_service.dart

import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import '../constants/app_constants.dart';
import '../errors/app_exceptions.dart';
import 'cache_service.dart';
import 'connectivity_service.dart';
import 'image_info.dart';
import 'result.dart';

/// Servicio para manejar imágenes con Cloudflare R2 y fallback a Contabo S3
class ImageService {
  // Singleton pattern
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  // URLs base para los diferentes proveedores
  String? _r2BaseUrl;
  String? _s3BaseUrl;
  String? _supabaseStorageUrl;

  // Configuración actual
  String _primaryProvider = AppConstants.imageProviderR2;
  bool _isConfigured = false;

  /// Configurar el servicio
  void configure({
    String? r2BaseUrl,
    String? s3BaseUrl,
    String? supabaseUrl,
    String? supabaseBucket,
  }) {
    _r2BaseUrl = r2BaseUrl;
    _s3BaseUrl = s3BaseUrl;

    if (supabaseUrl != null && supabaseBucket != null) {
      _supabaseStorageUrl =
          '$supabaseUrl/storage/v1/object/public/$supabaseBucket';
    }

    _isConfigured =
        _r2BaseUrl != null || _s3BaseUrl != null || _supabaseStorageUrl != null;

    if (kDebugMode) {
      print(
        'ImageService: Configurado con proveedores - '
        'R2: ${_r2BaseUrl != null ? "Sí" : "No"}, '
        'S3: ${_s3BaseUrl != null ? "Sí" : "No"}, '
        'Supabase: ${_supabaseStorageUrl != null ? "Sí" : "No"}',
      );
    }
  }

  /// Verificar si el servicio está configurado
  bool get isConfigured => _isConfigured;

  /// Obtener URL de imagen con variante
  String getImageUrl({
    required String entityType,
    required String entityId,
    required String imageName,
    int? size,
    String? provider,
  }) {
    if (!_isConfigured) {
      throw ConfigurationException(message: 'ImageService no está configurado');
    }

    final selectedProvider = provider ?? _primaryProvider;
    final variantName =
        size != null ? AppConstants.getImageVariantName(size) : 'original';

    // Generar nombre de archivo con variante
    final fileName = _getVariantFileName(imageName, variantName);
    final imagePath =
        '${AppConstants.getImageBasePath(entityType)}/$entityId/$fileName';

    // Obtener URL según proveedor
    return _getProviderUrl(selectedProvider, imagePath);
  }

  /// Obtener URLs para todas las variantes de una imagen
  Map<String, String> getImageVariants({
    required String entityType,
    required String entityId,
    required String imageName,
    String? provider,
  }) {
    final variants = <String, String>{};

    // URL original
    variants['original'] = getImageUrl(
      entityType: entityType,
      entityId: entityId,
      imageName: imageName,
      provider: provider,
    );

    // URLs para cada variante de tamaño
    for (final size in AppConstants.imageVariants) {
      variants['${size}px'] = getImageUrl(
        entityType: entityType,
        entityId: entityId,
        imageName: imageName,
        size: size,
        provider: provider,
      );
    }

    return variants;
  }

  /// Cargar imagen con fallback automático entre proveedores
  Future<Result<Uint8List, Exception>> loadImage({
    required String entityType,
    required String entityId,
    required String imageName,
    int? size,
    bool useCache = true,
    List<String>? providerOrder,
  }) async {
    if (!_isConfigured) {
      return Result.error(
        ConfigurationException(message: 'ImageService no está configurado'),
      );
    }

    // Verificar caché primero
    if (useCache) {
      final cacheResult = await _getFromCache(
        entityType: entityType,
        entityId: entityId,
        imageName: imageName,
        size: size,
      );

      if (cacheResult.isSuccess && cacheResult.valueOrNull != null) {
        return Result.success(cacheResult.valueOrNull!);
      }
    }

    // Orden de proveedores a intentar
    final providers = providerOrder ?? _getProviderOrder();

    // Intentar cargar de cada proveedor
    for (final provider in providers) {
      try {
        final imageData = await _loadFromProvider(
          entityType: entityType,
          entityId: entityId,
          imageName: imageName,
          size: size,
          provider: provider,
        );

        // Guardar en caché si se obtuvo exitosamente
        if (useCache && imageData != null) {
          await _saveToCache(
            entityType: entityType,
            entityId: entityId,
            imageName: imageName,
            size: size,
            imageData: imageData,
          );
        }

        if (imageData != null) {
          return Result.success(imageData);
        }
      } catch (error) {
        if (kDebugMode) {
          print('ImageService: Error cargando de $provider - $error');
        }
        // Continuar con el siguiente proveedor
      }
    }

    return Result.error(
      NotFoundException(message: 'Imagen no encontrada en ningún proveedor'),
    );
  }

  /// Subir imagen a Cloudflare R2
  Future<Result<String, Exception>> uploadImage({
    required String entityType,
    required String entityId,
    required String imageName,
    required Uint8List imageData,
    String? contentType,
    Map<String, String>? metadata,
  }) async {
    if (_r2BaseUrl == null) {
      return Result.error(
        ConfigurationException(message: 'Cloudflare R2 no está configurado'),
      );
    }

    try {
      // Generar variantes de la imagen
      final variants = await _generateImageVariants(imageData);

      // Subir cada variante
      for (final variant in variants.entries) {
        final variantName = variant.key;
        final variantData = variant.value;
        final fileName = _getVariantFileName(imageName, variantName);
        final imagePath =
            '${AppConstants.getImageBasePath(entityType)}/$entityId/$fileName';

        await _uploadToR2(
          path: imagePath,
          data: variantData,
          contentType: contentType ?? 'image/avif',
          metadata: metadata,
        );
      }

      // Devolver URL de la imagen original
      final imageUrl = getImageUrl(
        entityType: entityType,
        entityId: entityId,
        imageName: imageName,
        provider: AppConstants.imageProviderR2,
      );

      return Result.success(imageUrl);
    } catch (error) {
      return Result.error(
        ImageException(message: 'Error al subir imagen', cause: error),
      );
    }
  }

  /// Eliminar imagen de Cloudflare R2
  Future<Result<void, Exception>> deleteImage({
    required String entityType,
    required String entityId,
    required String imageName,
  }) async {
    if (_r2BaseUrl == null) {
      return Result.error(
        ConfigurationException(message: 'Cloudflare R2 no está configurado'),
      );
    }

    try {
      // Eliminar todas las variantes
      for (final variantName in [
        'original',
        ...AppConstants.imageVariantNames.values,
      ]) {
        final fileName = _getVariantFileName(imageName, variantName);
        final imagePath =
            '${AppConstants.getImageBasePath(entityType)}/$entityId/$fileName';

        await _deleteFromR2(imagePath);
      }

      // Limpiar caché
      await _clearImageCache(
        entityType: entityType,
        entityId: entityId,
        imageName: imageName,
      );

      return Result.success(null);
    } catch (error) {
      return Result.error(
        ImageException(message: 'Error al eliminar imagen', cause: error),
      );
    }
  }

  /// Procesar imagen (redimensionar, comprimir, etc.)
  Future<Result<Uint8List, Exception>> processImage({
    required Uint8List imageData,
    int? maxWidth,
    int? maxHeight,
    int quality = AppConstants.imageQuality,
    String format = 'avif',
  }) async {
    try {
      // Decodificar imagen
      final image = img.decodeImage(imageData);
      if (image == null) {
        return Result.error(
          ImageException(message: 'No se pudo decodificar la imagen'),
        );
      }

      // Redimensionar si es necesario
      img.Image processedImage = image;
      if (maxWidth != null || maxHeight != null) {
        processedImage = img.copyResize(
          image,
          width: maxWidth,
          height: maxHeight,
          maintainAspect: true,
        );
      }

      // Codificar en formato deseado
      Uint8List processedData;
      switch (format.toLowerCase()) {
        case 'avif':
          processedData = Uint8List.fromList(
            img.encodeJpg(processedImage, quality: quality),
          );
          break;
        case 'webp':
          processedData = Uint8List.fromList(img.encodePng(processedImage));
          break;
        case 'jpeg':
        case 'jpg':
          processedData = Uint8List.fromList(
            img.encodeJpg(processedImage, quality: quality),
          );
          break;
        case 'png':
          processedData = Uint8List.fromList(img.encodePng(processedImage));
          break;
        default:
          return Result.error(
            ImageException(message: 'Formato de imagen no soportado: $format'),
          );
      }

      // Verificar tamaño máximo
      if (processedData.length > AppConstants.maxImageSizeBytes) {
        return Result.error(
          ImageException(
            message: 'Imagen demasiado grande después de procesar',
          ),
        );
      }

      return Result.success(processedData);
    } catch (error) {
      return Result.error(
        ImageException(message: 'Error al procesar imagen', cause: error),
      );
    }
  }

  /// Obtener información de una imagen
  Future<Result<ImageInfo, Exception>> getImageInfo(Uint8List imageData) async {
    try {
      final image = img.decodeImage(imageData);
      if (image == null) {
        return Result.error(
          ImageException(message: 'No se pudo decodificar la imagen'),
        );
      }

      final info = ImageInfo(
        width: image.width,
        height: image.height,
        size: imageData.length,
        format: _detectImageFormat(imageData),
        hasAlpha: image.numChannels == 4,
      );

      return Result.success(info);
    } catch (error) {
      return Result.error(
        ImageException(
          message: 'Error al obtener información de la imagen',
          cause: error,
        ),
      );
    }
  }

  /// Cambiar proveedor primario
  void setPrimaryProvider(String provider) {
    if (![
      AppConstants.imageProviderR2,
      AppConstants.imageProviderS3,
      AppConstants.imageProviderSupabase,
    ].contains(provider)) {
      throw ArgumentError('Proveedor no válido: $provider');
    }

    _primaryProvider = provider;

    if (kDebugMode) {
      print('ImageService: Proveedor primario cambiado a $provider');
    }
  }

  /// Obtener proveedor primario actual
  String get primaryProvider => _primaryProvider;

  /// Obtener proveedores disponibles
  List<String> get availableProviders {
    final providers = <String>[];
    if (_r2BaseUrl != null) providers.add(AppConstants.imageProviderR2);
    if (_s3BaseUrl != null) providers.add(AppConstants.imageProviderS3);
    if (_supabaseStorageUrl != null)
      providers.add(AppConstants.imageProviderSupabase);
    return providers;
  }

  // Métodos privados

  /// Obtener orden de proveedores basado en configuración y conectividad
  List<String> _getProviderOrder() {
    final order = <String>[];

    // Siempre intentar primero el proveedor primario
    order.add(_primaryProvider);

    // Agregar otros proveedores disponibles
    for (final provider in availableProviders) {
      if (provider != _primaryProvider) {
        order.add(provider);
      }
    }

    return order;
  }

  /// Obtener URL de proveedor
  String _getProviderUrl(String provider, String imagePath) {
    switch (provider) {
      case AppConstants.imageProviderR2:
        if (_r2BaseUrl == null) {
          throw ConfigurationException(
            message: 'Cloudflare R2 no está configurado',
          );
        }
        return '$_r2BaseUrl/$imagePath';

      case AppConstants.imageProviderS3:
        if (_s3BaseUrl == null) {
          throw ConfigurationException(message: 'S3 no está configurado');
        }
        return '$_s3BaseUrl/$imagePath';

      case AppConstants.imageProviderSupabase:
        if (_supabaseStorageUrl == null) {
          throw ConfigurationException(
            message: 'Supabase Storage no está configurado',
          );
        }
        return '$_supabaseStorageUrl/$imagePath';

      default:
        throw ArgumentError('Proveedor no válido: $provider');
    }
  }

  /// Obtener nombre de archivo con variante
  String _getVariantFileName(String imageName, String variantName) {
    if (variantName == 'original') {
      return imageName;
    }

    final extension = path.extension(imageName);
    final nameWithoutExtension = path.basenameWithoutExtension(imageName);
    return '$nameWithoutExtension-$variantName$extension';
  }

  /// Cargar imagen desde proveedor
  Future<Uint8List?> _loadFromProvider({
    required String entityType,
    required String entityId,
    required String imageName,
    int? size,
    required String provider,
  }) async {
    final url = getImageUrl(
      entityType: entityType,
      entityId: entityId,
      imageName: imageName,
      size: size,
      provider: provider,
    );

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      }

      return null;
    } catch (error) {
      if (kDebugMode) {
        print('ImageService: Error cargando de $provider - $error');
      }
      return null;
    }
  }

  /// Subir a Cloudflare R2
  Future<void> _uploadToR2({
    required String path,
    required Uint8List data,
    required String contentType,
    Map<String, String>? metadata,
  }) async {
    // Nota: En una implementación real, esto usaría las credenciales de R2
    // Para este ejemplo, asumimos que hay un endpoint configurado
    throw UnimplementedError(
      '_uploadToR2 necesita implementación con credenciales R2',
    );
  }

  /// Eliminar de Cloudflare R2
  Future<void> _deleteFromR2(String path) async {
    // Nota: En una implementación real, esto usaría las credenciales de R2
    throw UnimplementedError(
      '_deleteFromR2 necesita implementación con credenciales R2',
    );
  }

  /// Generar variantes de imagen
  Future<Map<String, Uint8List>> _generateImageVariants(
    Uint8List originalData,
  ) async {
    final variants = <String, Uint8List>{};

    // Variante original
    variants['original'] = originalData;

    // Generar variantes de tamaño
    for (final size in AppConstants.imageVariants) {
      final variantResult = await processImage(
        imageData: originalData,
        maxWidth: size,
        maxHeight: size,
        format: 'avif',
      );

      if (variantResult.isSuccess) {
        final variantName = AppConstants.getImageVariantName(size);
        variants[variantName] = variantResult.valueOrNull!;
      }
    }

    return variants;
  }

  /// Obtener de caché
  Future<Result<Uint8List?, Exception>> _getFromCache({
    required String entityType,
    required String entityId,
    required String imageName,
    int? size,
  }) async {
    final cacheKey = _getCacheKey(
      entityType: entityType,
      entityId: entityId,
      imageName: imageName,
      size: size,
    );

    return await CacheService().get<Uint8List>(cacheKey);
  }

  /// Guardar en caché
  Future<void> _saveToCache({
    required String entityType,
    required String entityId,
    required String imageName,
    int? size,
    required Uint8List imageData,
  }) async {
    final cacheKey = _getCacheKey(
      entityType: entityType,
      entityId: entityId,
      imageName: imageName,
      size: size,
    );

    await CacheService().save(
      key: cacheKey,
      data: imageData,
      ttl: const Duration(days: 7),
      category: CacheCategories.imagenes,
      tags: {
        'entityType': entityType,
        'entityId': entityId,
        'imageName': imageName,
        'size': size?.toString() ?? 'original',
      },
    );
  }

  /// Limpiar caché de imagen
  Future<void> _clearImageCache({
    required String entityType,
    required String entityId,
    required String imageName,
  }) async {
    // Eliminar todas las variantes de la caché
    for (final size in [null, ...AppConstants.imageVariants]) {
      final cacheKey = _getCacheKey(
        entityType: entityType,
        entityId: entityId,
        imageName: imageName,
        size: size,
      );

      await CacheService().remove(cacheKey);
    }
  }

  /// Generar clave de caché
  String _getCacheKey({
    required String entityType,
    required String entityId,
    required String imageName,
    int? size,
  }) {
    final sizeStr = size != null ? '_${size}' : '';
    return 'image_${entityType}_${entityId}_${imageName}$sizeStr';
  }

  /// Detectar formato de imagen a partir de los bytes
  String _detectImageFormat(Uint8List imageData) {
    if (imageData.length < 8) return 'unknown';

    // PNG
    if (imageData[0] == 0x89 &&
        imageData[1] == 0x50 &&
        imageData[2] == 0x4E &&
        imageData[3] == 0x47) {
      return 'png';
    }
    // JPEG
    if (imageData[0] == 0xFF && imageData[1] == 0xD8) {
      return 'jpg';
    }
    // GIF
    if (imageData[0] == 0x47 && imageData[1] == 0x49 && imageData[2] == 0x46) {
      return 'gif';
    }
    // BMP
    if (imageData[0] == 0x42 && imageData[1] == 0x4D) {
      return 'bmp';
    }

    return 'unknown';
  }
}
