// lib/presentation/widgets/producto/producto_card.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/utils/image_service.dart';
import '../../../di/service_locator.dart';

/// Widget para mostrar una tarjeta de producto
class ProductoCard extends StatelessWidget {
  final Map<String, dynamic> producto;
  final VoidCallback onTap;
  final bool showDetails;
  final bool showFavoriteButton;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final bool showAddToCartButton;
  final VoidCallback? onAddToCart;

  const ProductoCard({
    super.key,
    required this.producto,
    required this.onTap,
    this.showDetails = true,
    this.showFavoriteButton = true,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.showAddToCartButton = true,
    this.onAddToCart,
  });

  /// Obtener imagen principal del producto
  String? _getProductoImage() {
    final imageService = getIt<ImageService>();
    final imagenes = producto['imagenes'] as List<dynamic>?;

    if (imagenes != null && imagenes.isNotEmpty) {
      // Buscar imagen principal
      final imagenPrincipal = imagenes.firstWhere(
        (imagen) => imagen['es_principal'] == true,
        orElse: () => imagenes.first,
      );

      final url = imagenPrincipal['url'] as String?;
      if (url != null && url.isNotEmpty) {
        return imageService.getImageUrl(
          entityType: 'producto',
          entityId: producto['id']?.toString() ?? '',
          imageName: 'imagen.jpg',
          size: 300,
        );
      }
    }

    // Imagen por defecto
    return null;
  }

  /// Obtener nombre del producto
  String _getProductoName() {
    return producto['nombre_producto'] as String? ?? 'Producto sin nombre';
  }

  /// Obtener descripción del producto
  String _getProductoDescription() {
    return producto['descripcion'] as String? ?? 'Sin descripción disponible';
  }

  /// Obtener categoría del producto
  String? _getProductoCategory() {
    final categoria = producto['categoria'] as Map<String, dynamic>?;
    if (categoria != null) {
      return categoria['nombre_categoria'] as String?;
    }
    return null;
  }

  /// Obtener tienda del producto
  String? _getTiendaName() {
    final tienda = producto['tienda'] as Map<String, dynamic>?;
    if (tienda != null) {
      return tienda['nombre_tienda'] as String?;
    }
    return null;
  }

  /// Obtener precio del producto
  double _getProductoPrice() {
    final precio = producto['precio'] as double?;
    return precio ?? 0.0;
  }

  /// Obtener precio anterior (si hay descuento)
  double? _getOldPrice() {
    final precioAnterior = producto['precio_anterior'] as double?;
    return precioAnterior;
  }

  /// Calcular porcentaje de descuento
  double? _getDiscountPercentage() {
    final precioActual = _getProductoPrice();
    final precioAnterior = _getOldPrice();

    if (precioAnterior != null &&
        precioAnterior > 0 &&
        precioActual < precioAnterior) {
      return ((precioAnterior - precioActual) / precioAnterior) * 100;
    }
    return null;
  }

  /// Obtener valoración promedio
  double _getAverageRating() {
    final rating = producto['promedio_valoracion'] as double?;
    return rating ?? 0.0;
  }

  /// Obtener número de valoraciones
  int _getRatingCount() {
    final count = producto['total_valoraciones'] as int?;
    return count ?? 0;
  }

  /// Obtener número de ventas
  int _getSalesCount() {
    final sales = producto['total_ventas'] as int?;
    return sales ?? 0;
  }

  /// Obtener stock disponible
  int _getStockAvailable() {
    final stock = producto['stock_disponible'] as int?;
    return stock ?? 0;
  }

  /// Verificar si el producto está en stock
  bool _isInStock() {
    return _getStockAvailable() > 0;
  }

  /// Obtener estado del producto
  String? _getProductoStatus() {
    return producto['estado_producto'] as String?;
  }

  /// Verificar si el producto está disponible
  bool _isProductoAvailable() {
    final status = _getProductoStatus();
    return status == 'activo' || status == 'disponible';
  }

  /// Obtener icono según categoría
  IconData _getCategoryIcon() {
    final categoria = _getProductoCategory()?.toLowerCase() ?? '';

    if (categoria.contains('ropa') || categoria.contains('moda')) {
      return Icons.shopping_bag;
    } else if (categoria.contains('comida') || categoria.contains('alimento')) {
      return Icons.restaurant;
    } else if (categoria.contains('tecnología') ||
        categoria.contains('electrónica')) {
      return Icons.computer;
    } else if (categoria.contains('belleza') || categoria.contains('salud')) {
      return Icons.spa;
    } else if (categoria.contains('hogar') ||
        categoria.contains('decoración')) {
      return Icons.home;
    } else if (categoria.contains('deporte') || categoria.contains('fitness')) {
      return Icons.sports;
    } else if (categoria.contains('libro') || categoria.contains('papelería')) {
      return Icons.menu_book;
    } else if (categoria.contains('juguete') || categoria.contains('niño')) {
      return Icons.toys;
    } else if (categoria.contains('joyería') ||
        categoria.contains('accesorio')) {
      return Icons.diamond;
    } else if (categoria.contains('zapato') || categoria.contains('calzado')) {
      return Icons.shopping_cart;
    } else if (categoria.contains('mueble') ||
        categoria.contains('mobiliario')) {
      return Icons.chair;
    } else if (categoria.contains('herramienta') ||
        categoria.contains('bricolaje')) {
      return Icons.build;
    }

    return Icons.shopping_basket;
  }

  /// Construir widget de valoración
  Widget _buildRatingWidget() {
    final rating = _getAverageRating();
    final count = _getRatingCount();

    if (rating == 0.0) {
      return Row(
        children: [
          const Icon(Icons.star_border, size: 16, color: Colors.grey),
          const SizedBox(width: 4),
          Text(
            'Sin valoraciones',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      );
    }

    return Row(
      children: [
        Icon(Icons.star, size: 16, color: Colors.amber),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 4),
        Text(
          '($count)',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  /// Construir widget de precio
  Widget _buildPriceWidget() {
    final precio = _getProductoPrice();
    final precioAnterior = _getOldPrice();
    final descuento = _getDiscountPercentage();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (descuento != null && precioAnterior != null)
          Row(
            children: [
              Text(
                '\$${precioAnterior.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '-${descuento.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(height: 4),
        Text(
          '\$${precio.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  /// Construir widget de stock
  Widget _buildStockWidget() {
    final stock = _getStockAvailable();
    final isAvailable = _isProductoAvailable();

    if (!isAvailable) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cancel, size: 12, color: Colors.red),
            const SizedBox(width: 4),
            Text(
              'No disponible',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ],
        ),
      );
    }

    if (stock <= 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning, size: 12, color: Colors.orange),
            const SizedBox(width: 4),
            Text(
              'Agotado',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      );
    }

    if (stock <= 5) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.timer, size: 12, color: Colors.orange),
            const SizedBox(width: 4),
            Text(
              'Últimas $stock unidades',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 12, color: Colors.green),
          const SizedBox(width: 4),
          Text(
            'En stock',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  /// Construir widget de ventas
  Widget _buildSalesWidget() {
    final sales = _getSalesCount();

    return Row(
      children: [
        Icon(Icons.shopping_cart, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          '$sales vendidos',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _getProductoImage();
    final productoName = _getProductoName();
    final productoDescription = _getProductoDescription();
    final categoria = _getProductoCategory();
    final tienda = _getTiendaName();
    final isAvailable = _isProductoAvailable();
    final isInStock = _isInStock();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagen del producto
            Stack(
              children: [
                Container(
                  height: 180,
                  color: Colors.grey[200],
                  child:
                      imageUrl != null
                          ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder:
                                (context, url) => Container(
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                            errorWidget:
                                (context, url, error) => Container(
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(
                                      Icons.shopping_basket,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                          )
                          : Center(
                            child: Icon(
                              _getCategoryIcon(),
                              size: 64,
                              color: Colors.grey,
                            ),
                          ),
                ),
                // Botón de favorito
                if (showFavoriteButton)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                          size: 20,
                        ),
                        onPressed: onFavoriteToggle,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                      ),
                    ),
                  ),
                // Estado del producto (stock/disponibilidad)
                Positioned(top: 8, left: 8, child: _buildStockWidget()),
                // Descuento (si aplica)
                if (_getDiscountPercentage() != null)
                  Positioned(
                    top: 8,
                    right: showFavoriteButton ? 48 : 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        '-${_getDiscountPercentage()!.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            if (showDetails) ...[
              // Contenido de la tarjeta
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre y categoría
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productoName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (categoria != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              categoria,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        if (tienda != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.store,
                                  size: 12,
                                  color: Colors.grey[500],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  tienda,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Descripción
                    Text(
                      productoDescription,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 12),

                    // Precio y valoración
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Precio
                        Expanded(child: _buildPriceWidget()),

                        // Valoración
                        _buildRatingWidget(),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Estadísticas y botones
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Ventas
                        _buildSalesWidget(),

                        // Botón de añadir al carrito
                        if (showAddToCartButton && isAvailable && isInStock)
                          ElevatedButton.icon(
                            onPressed: onAddToCart,
                            icon: const Icon(Icons.add_shopping_cart, size: 16),
                            label: const Text('Añadir'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                      ],
                    ),

                    // Tags o etiquetas (si existen)
                    if (producto['etiquetas'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children:
                              (producto['etiquetas'] as List<dynamic>)
                                  .take(3)
                                  .map((tag) {
                                    final tagName =
                                        tag['nombre'] as String? ??
                                        tag.toString();
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        tagName,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.blue[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  })
                                  .toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ] else ...[
              // Versión compacta (solo nombre y precio)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(_getCategoryIcon(), size: 20, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            productoName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '\$${_getProductoPrice().toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (showAddToCartButton && isAvailable && isInStock)
                      IconButton(
                        icon: const Icon(Icons.add_shopping_cart, size: 20),
                        onPressed: onAddToCart,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
