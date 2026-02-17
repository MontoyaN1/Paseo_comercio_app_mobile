// lib/presentation/widgets/tienda/tienda_card.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/utils/image_service.dart';
import '../../../di/service_locator.dart';

/// Widget para mostrar una tarjeta de tienda
class TiendaCard extends StatelessWidget {
  final Map<String, dynamic> tienda;
  final VoidCallback onTap;
  final bool showDetails;
  final bool showFavoriteButton;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  const TiendaCard({
    super.key,
    required this.tienda,
    required this.onTap,
    this.showDetails = true,
    this.showFavoriteButton = true,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  /// Obtener imagen principal de la tienda
  String? _getTiendaImage() {
    final imageService = getIt<ImageService>();
    final imagenes = tienda['imagenes'] as List<dynamic>?;

    if (imagenes != null && imagenes.isNotEmpty) {
      // Buscar imagen principal
      final imagenPrincipal = imagenes.firstWhere(
        (imagen) => imagen['es_principal'] == true,
        orElse: () => imagenes.first,
      );

      final url = imagenPrincipal['url'] as String?;
      if (url != null && url.isNotEmpty) {
        return imageService.getImageUrl(
          entityType: 'tienda',
          entityId: tienda['id']?.toString() ?? '',
          imageName: 'logo.jpg',
          size: 300,
        );
      }
    }

    // Imagen por defecto
    return null;
  }

  /// Obtener nombre de la tienda
  String _getTiendaName() {
    return tienda['nombre_tienda'] as String? ?? 'Tienda sin nombre';
  }

  /// Obtener descripción de la tienda
  String _getTiendaDescription() {
    return tienda['descripcion'] as String? ?? 'Sin descripción disponible';
  }

  /// Obtener categoría de la tienda
  String? _getTiendaCategory() {
    final categoria = tienda['categoria'] as Map<String, dynamic>?;
    if (categoria != null) {
      return categoria['nombre_categoria'] as String?;
    }
    return null;
  }

  /// Obtener valoración promedio
  double _getAverageRating() {
    final rating = tienda['promedio_valoracion'] as double?;
    return rating ?? 0.0;
  }

  /// Obtener número de valoraciones
  int _getRatingCount() {
    final count = tienda['total_valoraciones'] as int?;
    return count ?? 0;
  }

  /// Obtener número de visitas
  int _getVisitCount() {
    final visits = tienda['total_visitas'] as int?;
    return visits ?? 0;
  }

  /// Obtener estado de la tienda
  String? _getTiendaStatus() {
    return tienda['estado_tienda'] as String?;
  }

  /// Verificar si la tienda está abierta
  bool _isTiendaOpen() {
    final status = _getTiendaStatus();
    return status == 'activa' || status == 'abierta';
  }

  /// Obtener icono según categoría
  IconData _getCategoryIcon() {
    final categoria = _getTiendaCategory()?.toLowerCase() ?? '';

    if (categoria.contains('ropa') || categoria.contains('moda')) {
      return Icons.shopping_bag;
    } else if (categoria.contains('comida') ||
        categoria.contains('restaurante')) {
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
    }

    return Icons.storefront;
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

  /// Construir widget de estado
  Widget _buildStatusWidget() {
    final isOpen = _isTiendaOpen();
    final status = _getTiendaStatus();

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (isOpen) {
      statusColor = Colors.green;
      statusText = 'Abierta';
      statusIcon = Icons.check_circle;
    } else if (status == 'cerrada') {
      statusColor = Colors.red;
      statusText = 'Cerrada';
      statusIcon = Icons.cancel;
    } else if (status == 'pendiente') {
      statusColor = Colors.orange;
      statusText = 'Pendiente';
      statusIcon = Icons.pending;
    } else {
      statusColor = Colors.grey;
      statusText = 'Desconocido';
      statusIcon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 12, color: statusColor),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Construir widget de visitas
  Widget _buildVisitsWidget() {
    final visits = _getVisitCount();

    return Row(
      children: [
        Icon(Icons.remove_red_eye, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          '$visits',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _getTiendaImage();
    final tiendaName = _getTiendaName();
    final tiendaDescription = _getTiendaDescription();
    final categoria = _getTiendaCategory();

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
            // Imagen de la tienda
            Stack(
              children: [
                Container(
                  height: 160,
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
                                      Icons.storefront,
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
                // Estado de la tienda
                Positioned(top: 8, left: 8, child: _buildStatusWidget()),
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tiendaName,
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
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Descripción
                    Text(
                      tiendaDescription,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 12),

                    // Estadísticas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Valoración
                        _buildRatingWidget(),

                        // Visitas
                        _buildVisitsWidget(),
                      ],
                    ),

                    // Tags o etiquetas (si existen)
                    if (tienda['etiquetas'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children:
                              (tienda['etiquetas'] as List<dynamic>)
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
              // Versión compacta (solo nombre)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(_getCategoryIcon(), size: 20, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tiendaName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
