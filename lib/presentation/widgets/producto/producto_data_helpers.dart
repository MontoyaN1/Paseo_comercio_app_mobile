// lib/presentation/widgets/producto/producto_data_helpers.dart
//
// 🏛️ PLAZA UNIVERSE — Producto Data Helpers
// ────────────────────────────────────────────────────────────

class ProductoDataHelpers {
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
        return imagenPrincipal;
      }
    }

    final imagenUrl =
        productoData['imagen'] ??
        productoData['imagen_url'] ??
        productoData['url_imagen'];
    return imagenUrl?.toString();
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
