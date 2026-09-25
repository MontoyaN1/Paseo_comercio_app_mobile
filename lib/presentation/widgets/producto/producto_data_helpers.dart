// lib/presentation/widgets/producto/producto_data_helpers.dart
//
// 🏛️ PLAZA UNIVERSE — Producto Data Helpers
// ────────────────────────────────────────────────────────────

import 'package:paseo_del_comercio/core/app/app_config.dart';

class ProductoDataHelpers {
  final AppConfig _appConfig;

  ProductoDataHelpers({AppConfig? appConfig})
    : _appConfig = appConfig ?? AppConfig();

  String? transformUrlToR2(String? url) {
    if (url == null || url.isEmpty) return url;
    if (!url.contains('contabostorage.com')) return url;

    try {
      if (_appConfig.cloudflareR2PublicUrl.isEmpty) return url;
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isEmpty) return url;
      final newPath = pathSegments.join('/');
      return '${_appConfig.cloudflareR2PublicUrl}/$newPath';
    } catch (e) {
      return url;
    }
  }

  Map<String, dynamic> transformTiendaUrlsToR2(Map<String, dynamic> tienda) {
    final tiendaTransformada = Map<String, dynamic>.from(tienda);

    final logoUrl =
        tiendaTransformada['logoUrl'] ??
        tiendaTransformada['logo_url'] ??
        tiendaTransformada['url_logo'] ??
        tiendaTransformada['logo'];
    if (logoUrl != null && logoUrl is String && logoUrl.isNotEmpty) {
      final transformed = transformUrlToR2(logoUrl);
      tiendaTransformada['logoUrl'] = transformed;
      tiendaTransformada['logo_url'] = transformed;
    }

    final imagenesTienda = tiendaTransformada['imagen_tienda'];
    if (imagenesTienda is List) {
      final nuevasImagenes = <Map<String, dynamic>>[];
      for (final img in imagenesTienda) {
        if (img is Map<String, dynamic>) {
          final nuevaImagen = Map<String, dynamic>.from(img);
          final urlImagen = nuevaImagen['url_imagen'] as String?;
          if (urlImagen != null) {
            nuevaImagen['url_imagen'] = transformUrlToR2(urlImagen);
          }
          nuevasImagenes.add(nuevaImagen);
        }
      }
      tiendaTransformada['imagen_tienda'] = nuevasImagenes;
    }

    return tiendaTransformada;
  }

  String? getProductImageUrl(Map<String, dynamic>? productoData) {
    if (productoData == null) return null;

    final imagenProductoData = productoData['imagen_productos'];
    if (imagenProductoData is List && imagenProductoData.isNotEmpty) {
      String? imagenPrincipal;
      for (final img in imagenProductoData) {
        if (img is Map<String, dynamic>) {
          final tipo = img['tipo_imagen'] ?? img['tipo'];
          if (tipo == 'principal' || img['es_principal'] == true) {
            imagenPrincipal = img['url'] ?? img['url_imagen'];
            break;
          }
        }
      }
      if (imagenPrincipal == null && imagenProductoData.isNotEmpty) {
        final primera = imagenProductoData.first;
        if (primera is Map<String, dynamic>) {
          imagenPrincipal = primera['url'] ?? primera['url_imagen'];
        }
      }
      if (imagenPrincipal != null) {
        return transformUrlToR2(imagenPrincipal);
      }
    }

    final imagenUrl =
        productoData['imagen'] ??
        productoData['imagen_url'] ??
        productoData['url_imagen'];
    return transformUrlToR2(imagenUrl?.toString());
  }

  String getProductoNombre(Map<String, dynamic>? productoData) {
    return productoData?['nombre'] ??
        productoData?['nombre_producto'] ??
        'Producto sin nombre';
  }

  double? getProductoPrecio(Map<String, dynamic>? productoData) {
    final precio = productoData?['precio_base'] ?? productoData?['precio'];
    if (precio == null) return null;
    if (precio is int) return precio.toDouble();
    if (precio is double) return precio;
    return null;
  }
}
