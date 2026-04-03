// lib/presentation/widgets/producto/producto_tienda_tab.dart
//
// 🏛️ TIENDA TAB - Producto Detail
// ────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import 'package:paseo_del_comercio/presentation/widgets/tienda/list/tienda_card.dart';

const _kHint = Color(0xFF6B6B8A);

class ProductoTiendaTab extends StatelessWidget {
  final Map<String, dynamic>? tienda;
  final VoidCallback? onTiendaTap;

  const ProductoTiendaTab({super.key, this.tienda, this.onTiendaTap});

  @override
  Widget build(BuildContext context) {
    if (tienda == null) {
      return _buildEmptyState(
        icon: Icons.store_outlined,
        title: 'Tienda no disponible',
        subtitle: 'No se encontró información de la tienda',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TiendaCard(
            tienda: tienda!,
            onTap: onTiendaTap ?? () {},
            showDetails: true,
            showFavoriteButton: true,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: _kHint),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(color: _kHint),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
