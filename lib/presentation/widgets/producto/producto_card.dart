// lib/presentation/widgets/producto/producto_card.dart
//
// 🏛️  PLAZA UNIVERSE — Card de Producto
// ────────────────────────────────────────────────────────────
//  DISEÑO (idéntico al sistema de diseño Plaza Universe):
//  • Fondo: glassmorphism sobre _kSurfaceCard
//  • Borde: _kBorder con glow dorado en hover/press
//  • Imagen: con overlay degradado inferior
//  • Badge de stock: píldoras doradas/verdes/rojas
//  • Precio: ShaderMask dorado animado
//  • Valoración: íconos dorados
//  • Micro-animación de escala al presionar
// ────────────────────────────────────────────────────────────

import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// ── Paleta (idéntica al sistema de diseño) ────────────────────
const _kGold = Color(0xFFD4AF37);
const _kGoldLight = Color(0xFFFFE082);
const _kBg = Color(0xFF07070F);
const _kSurface = Color(0xFF0F0F1E);
const _kSurfaceCard = Color(0xFF12121F);
const _kBorder = Color(0xFF1E1E3A);
const _kHint = Color(0xFF6B6B8A);

// ══════════════════════════════════════════════════════════════
//  WIDGET PRINCIPAL
// ══════════════════════════════════════════════════════════════
class ProductoCard extends StatefulWidget {
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

  @override
  State<ProductoCard> createState() => _ProductoCardState();
}

class _ProductoCardState extends State<ProductoCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.965,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _glow = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ── Helpers de datos ──────────────────────────────────────
  String? _getImage() {
    final imagenes = widget.producto['imagenes'] as List<dynamic>?;
    if (imagenes == null || imagenes.isEmpty) {
      final alt = widget.producto['imagen_productos'] as List<dynamic>?;
      if (alt != null && alt.isNotEmpty) {
        final f = alt.first;
        if (f is Map<String, dynamic>) return f['url_imagen'] as String?;
      }
      return null;
    }
    Map<String, dynamic>? principal;
    for (final img in imagenes) {
      if (img is Map<String, dynamic> && img['tipo_imagen'] == 'principal') {
        principal = img;
        break;
      }
    }
    principal ??=
        imagenes.firstWhere(
              (i) => i is Map<String, dynamic> && i['es_principal'] == true,
              orElse: () => imagenes.first,
            )
            as Map<String, dynamic>?;
    if (principal == null) return null;
    final url = principal['url_imagen'] ?? principal['url'];
    return (url is String && url.isNotEmpty) ? url : null;
  }

  String _getNombre() {
    final n =
        widget.producto['nombre'] ??
        widget.producto['nombre_producto'] ??
        'Producto';
    final s = n.toString();
    if (s.isEmpty || s == 'Producto' || s == 'Producto sin nombre') {
      final id = widget.producto['id'] ?? widget.producto['producto_id'];
      return id != null ? 'Producto $id' : 'Producto';
    }
    return s;
  }

  double _getPrecio() {
    final p = widget.producto['precio'] ?? widget.producto['precio_base'];
    return (p as num?)?.toDouble() ?? 0.0;
  }

  double _getRating() {
    return (widget.producto['calificacion_promedio'] as num?)?.toDouble() ??
        0.0;
  }

  int _getRatingCount() {
    return (widget.producto['total_valoracion'] as int?) ?? 0;
  }

  int _getStock() {
    return (widget.producto['stock_disponible'] as int?) ??
        (widget.producto['cantidad'] as int?) ??
        0;
  }

  bool _isDisponible() =>
      (widget.producto['estado_producto'] as String?) == 'publicado';

  String? _getCategoria() {
    final cat = widget.producto['categoria'];
    if (cat is Map<String, dynamic>) return cat['nombre_categoria'] as String?;
    return null;
  }

  IconData _getCategoryIcon() {
    final c = (_getCategoria() ?? '').toLowerCase();
    if (c.contains('ropa') || c.contains('moda'))
      return Icons.checkroom_rounded;
    if (c.contains('comida') || c.contains('alimento'))
      return Icons.restaurant_rounded;
    if (c.contains('tecno') || c.contains('electr'))
      return Icons.devices_rounded;
    if (c.contains('belleza') || c.contains('salud')) return Icons.spa_rounded;
    if (c.contains('hogar') || c.contains('decor')) return Icons.chair_rounded;
    if (c.contains('deporte') || c.contains('fit')) return Icons.sports_rounded;
    if (c.contains('libro') || c.contains('papel'))
      return Icons.menu_book_rounded;
    if (c.contains('jugu') || c.contains('niño')) return Icons.toys_rounded;
    if (c.contains('joya') || c.contains('acceso'))
      return Icons.diamond_rounded;
    if (c.contains('zapato') || c.contains('calzado'))
      return Icons.shopping_bag_rounded;
    return Icons.shopping_basket_rounded;
  }

  // ── Stock badge ───────────────────────────────────────────
  _StockBadgeData _getStockBadge() {
    if (!_isDisponible()) {
      return _StockBadgeData(
        icon: Icons.block_rounded,
        label: 'No disponible',
        color: const Color(0xFFEF4444),
      );
    }
    final s = _getStock();
    if (s <= 0) {
      return _StockBadgeData(
        icon: Icons.inventory_2_rounded,
        label: 'Agotado',
        color: const Color(0xFFF97316),
      );
    }
    if (s <= 5) {
      return _StockBadgeData(
        icon: Icons.timer_rounded,
        label: 'Últimas $s uds.',
        color: const Color(0xFFF59E0B),
      );
    }
    return _StockBadgeData(
      icon: Icons.check_circle_rounded,
      label: 'En stock',
      color: const Color(0xFF22C55E),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _getImage();
    final nombre = _getNombre();
    final precio = _getPrecio();
    final rating = _getRating();
    final ratingCnt = _getRatingCount();
    final badge = _getStockBadge();
    final categoria = _getCategoria();

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder:
            (_, child) => Transform.scale(
              scale: _scale.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _kGold.withOpacity(0.04 + _glow.value * 0.12),
                      blurRadius: 18 + _glow.value * 14,
                      spreadRadius: _glow.value * 2,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.45),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: child,
              ),
            ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              decoration: BoxDecoration(
                color: _kSurfaceCard.withOpacity(0.92),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _kBorder, width: 1),
              ),
              child:
                  widget.showDetails
                      ? _buildFullCard(
                        imageUrl,
                        nombre,
                        precio,
                        rating,
                        ratingCnt,
                        badge,
                        categoria,
                      )
                      : _buildCompactCard(nombre, precio, badge),
            ),
          ),
        ),
      ),
    );
  }

  // ── Tarjeta completa ──────────────────────────────────────
  // La imagen ocupa toda la tarjeta; la info flota sobre el
  // degradado inferior en glassmorphism.
  Widget _buildFullCard(
    String? imageUrl,
    String nombre,
    double precio,
    double rating,
    int ratingCnt,
    _StockBadgeData badge,
    String? categoria,
  ) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Imagen a pantalla completa ──────────────────────
        _buildImageSection(imageUrl),

        // ── Overlay degradado fuerte en la parte inferior ───
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  _kBg.withOpacity(0.55),
                  _kBg.withOpacity(0.92),
                ],
                stops: const [0.0, 0.42, 0.68, 1.0],
              ),
            ),
          ),
        ),

        // ── Badge stock (top-left) ──────────────────────────
        Positioned(
          top: 8,
          left: 8,
          child: _buildStockBadge(badge, small: true),
        ),

        // ── Botón favorito (top-right) ──────────────────────
        if (widget.showFavoriteButton)
          Positioned(
            top: 6,
            right: 6,
            child: _FavButton(
              isFavorite: widget.isFavorite,
              onTap: widget.onFavoriteToggle,
            ),
          ),

        // ── Panel de info inferior superpuesto ──────────────
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nombre
                Text(
                  nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    letterSpacing: 0.1,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 6,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 5),

                // Precio + Rating en fila
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Precio con ShaderMask dorado
                    Flexible(
                      child: ShaderMask(
                        shaderCallback:
                            (b) => const LinearGradient(
                              colors: [_kGold, _kGoldLight],
                            ).createShader(b),
                        child: Text(
                          '\$${precio.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                    // Rating
                    _buildRatingMini(rating, ratingCnt),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Tarjeta compacta (fila) ───────────────────────────────
  Widget _buildCompactCard(
    String nombre,
    double precio,
    _StockBadgeData badge,
  ) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Ícono de categoría en círculo dorado
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _kGold.withOpacity(0.08),
              border: Border.all(color: _kGold.withOpacity(0.26), width: 1),
            ),
            child: Icon(_getCategoryIcon(), color: _kGold, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                ShaderMask(
                  shaderCallback:
                      (b) => const LinearGradient(
                        colors: [_kGold, _kGoldLight],
                      ).createShader(b),
                  child: Text(
                    '\$${precio.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (widget.showAddToCartButton && _isDisponible() && _getStock() > 0)
            _AddCartButton(onTap: widget.onAddToCart),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_forward_ios_rounded, color: _kGold, size: 13),
        ],
      ),
    );
  }

  // ── Sección de imagen ─────────────────────────────────────
  Widget _buildImageSection(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (_, __) => _buildImageFallback(loading: true),
        errorWidget: (_, __, ___) => _buildImageFallback(),
      );
    }
    return _buildImageFallback();
  }

  Widget _buildImageFallback({bool loading = false}) {
    return Container(
      color: _kSurface,
      child: Center(
        child:
            loading
                ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    valueColor: AlwaysStoppedAnimation(_kGold),
                  ),
                )
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getCategoryIcon(),
                      color: _kGold.withOpacity(0.45),
                      size: 28,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getNombre().isNotEmpty
                          ? _getNombre()[0].toUpperCase()
                          : 'P',
                      style: TextStyle(
                        color: _kGold.withOpacity(0.55),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  // ── Badge de stock ────────────────────────────────────────
  Widget _buildStockBadge(_StockBadgeData data, {bool small = false}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: small ? 7 : 10,
            vertical: small ? 3 : 5,
          ),
          decoration: BoxDecoration(
            color: data.color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: data.color.withOpacity(0.45), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(data.icon, color: data.color, size: small ? 9 : 11),
              const SizedBox(width: 4),
              Text(
                data.label,
                style: TextStyle(
                  color: data.color,
                  fontSize: small ? 9 : 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Rating mini ───────────────────────────────────────────
  Widget _buildRatingMini(double rating, int count) {
    if (rating == 0) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_border_rounded,
            size: 11,
            color: _kHint.withOpacity(0.7),
          ),
          const SizedBox(width: 2),
          Text(
            'S/V',
            style: TextStyle(fontSize: 9, color: _kHint.withOpacity(0.7)),
          ),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 11, color: _kGold),
        const SizedBox(width: 2),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            color: _kGoldLight,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          '($count)',
          style: TextStyle(color: _kHint.withOpacity(0.8), fontSize: 9),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  BOTÓN FAVORITO
// ══════════════════════════════════════════════════════════════
class _FavButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback? onTap;
  const _FavButton({required this.isFavorite, this.onTap});

  @override
  State<_FavButton> createState() => _FavButtonState();
}

class _FavButtonState extends State<_FavButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.80,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder:
            (_, __) => Transform.scale(
              scale: _scale.value,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            widget.isFavorite
                                ? const Color(0xFFEF4444).withOpacity(0.55)
                                : _kBorder,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      widget.isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 15,
                      color:
                          widget.isFavorite ? const Color(0xFFEF4444) : _kHint,
                    ),
                  ),
                ),
              ),
            ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  BOTÓN AGREGAR AL CARRITO
// ══════════════════════════════════════════════════════════════
class _AddCartButton extends StatefulWidget {
  final VoidCallback? onTap;
  const _AddCartButton({this.onTap});

  @override
  State<_AddCartButton> createState() => _AddCartButtonState();
}

class _AddCartButtonState extends State<_AddCartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.85,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder:
            (_, __) => Transform.scale(
              scale: _scale.value,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kGold.withOpacity(0.12),
                  border: Border.all(color: _kGold.withOpacity(0.40), width: 1),
                ),
                child: const Icon(
                  Icons.add_shopping_cart_rounded,
                  color: _kGold,
                  size: 15,
                ),
              ),
            ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  DATA CLASS PARA BADGE DE STOCK
// ══════════════════════════════════════════════════════════════
class _StockBadgeData {
  final IconData icon;
  final String label;
  final Color color;
  const _StockBadgeData({
    required this.icon,
    required this.label,
    required this.color,
  });
}
