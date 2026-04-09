// lib/presentation/widgets/tienda/tienda_productos_tab.dart
//
// 🏛️ PRODUCTOS TAB - Tienda Detail
// ────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import 'package:paseo_del_comercio/presentation/widgets/producto/list/producto_card.dart';

const _kGold = Color(0xFFD4AF37);
const _kGoldDeep = Color(0xFF9C7A1A);
const _kGoldLight = Color(0xFFFFE082);
const _kHint = Color(0xFF6B6B8A);

class TiendaProductosTab extends StatelessWidget {
  final List<Map<String, dynamic>> productos;
  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback? onLoadMore;
  final void Function(Map<String, dynamic> producto)? onProductoTap;

  const TiendaProductosTab({
    super.key,
    required this.productos,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.onLoadMore,
    this.onProductoTap,
  });

  @override
  Widget build(BuildContext context) {
    if (productos.isEmpty) {
      return _buildEmptyState(
        icon: Icons.shopping_bag_rounded,
        title: 'Sin productos',
        subtitle: 'Esta tienda no tiene\nproductos disponibles aún',
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollEndNotification) {
          final metrics = notification.metrics;
          if (metrics.pixels >= metrics.maxScrollExtent - 200) {
            onLoadMore?.call();
          }
        }
        return false;
      },
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemCount: productos.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= productos.length) {
            return _buildLoadMoreIndicator();
          }

          final producto = productos[index];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 400 + index * 60),
            curve: Curves.easeOutCubic,
            builder:
                (_, v, child) => Opacity(
                  opacity: v,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - v)),
                    child: child,
                  ),
                ),
            child: ProductoCard(
              producto: producto,
              onTap: () => onProductoTap?.call(producto),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child:
            isLoadingMore
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(_kGold),
                  ),
                )
                : TextButton(
                  onPressed: onLoadMore,
                  child: const Text(
                    'Cargar más',
                    style: TextStyle(color: _kGold),
                  ),
                ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _kGold.withValues(alpha: 0.06),
              border: Border.all(
                color: _kGold.withValues(alpha: 0.22),
                width: 1.5,
              ),
            ),
            child: Icon(icon, size: 36, color: _kGold),
          ),
          const SizedBox(height: 18),
          ShaderMask(
            shaderCallback:
                (b) => const LinearGradient(
                  colors: [_kGoldDeep, _kGold, _kGoldLight],
                ).createShader(b),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: _kHint, fontSize: 13, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
