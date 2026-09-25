// lib/presentation/widgets/plazoleta/plazoleta_productos_tab.dart
//
// 🏛️ PLAZUELA PRODUCTOS TAB
// ────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import 'package:paseo_del_comercio/presentation/widgets/producto/list/producto_card.dart';

const _kGold = Color(0xFFD4AF37);
const _kGoldDeep = Color(0xFF9C7A1A);
const _kGoldLight = Color(0xFFFFE082);

class PlazoletaProductosTab extends StatelessWidget {
  final List<Map<String, dynamic>> productos;
  final VoidCallback? onRefresh;
  final void Function(Map<String, dynamic> producto)? onProductoTap;

  const PlazoletaProductosTab({
    super.key,
    required this.productos,
    this.onRefresh,
    this.onProductoTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? const Color(0xFF0F0F1E) : Colors.grey.shade100;
    final hintColor = isDark ? const Color(0xFF6B6B8A) : Colors.grey.shade600;

    if (productos.isEmpty) {
      return _buildEmptyState(
        context: context,
        icon: Icons.shopping_bag_rounded,
        title: 'Sin productos',
        subtitle: 'Esta plazoleta no tiene\nproductos disponibles aún',
        surfaceColor: surfaceColor,
        hintColor: hintColor,
      );
    }

    return RefreshIndicator(
      color: _kGold,
      backgroundColor: surfaceColor,
      onRefresh: () async => onRefresh?.call(),
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemCount: productos.length,
        itemBuilder: (context, index) {
          final producto = productos[index];
          return ProductoCard(
            producto: producto,
            onTap: () => onProductoTap?.call(producto),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color surfaceColor,
    required Color hintColor,
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
            style: TextStyle(color: hintColor, fontSize: 13, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
