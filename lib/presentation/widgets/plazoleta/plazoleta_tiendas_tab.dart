// lib/presentation/widgets/plazoleta/plazoleta_tiendas_tab.dart
//
// 🏛️ PLAZUELA TIENDAS TAB
// ────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import 'package:paseo_del_comercio/presentation/widgets/tienda/tienda_card.dart';

const _kGold = Color(0xFFD4AF37);
const _kGoldDeep = Color(0xFF9C7A1A);
const _kGoldLight = Color(0xFFFFE082);

class PlazoletaTiendasTab extends StatelessWidget {
  final List<Map<String, dynamic>> tiendas;
  final VoidCallback? onRefresh;
  final void Function(Map<String, dynamic> tienda)? onTiendaTap;

  const PlazoletaTiendasTab({
    super.key,
    required this.tiendas,
    this.onRefresh,
    this.onTiendaTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? const Color(0xFF0F0F1E) : Colors.grey.shade100;
    final hintColor = isDark ? const Color(0xFF6B6B8A) : Colors.grey.shade600;

    if (tiendas.isEmpty) {
      return _buildEmptyState(
        context: context,
        icon: Icons.store_rounded,
        title: 'Sin tiendas',
        subtitle: 'Esta plazoleta no tiene\ntiendas asociadas aún',
        surfaceColor: surfaceColor,
        hintColor: hintColor,
      );
    }

    return RefreshIndicator(
      color: _kGold,
      backgroundColor: surfaceColor,
      onRefresh: () async => onRefresh?.call(),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        itemCount: tiendas.length,
        itemBuilder: (context, index) {
          final tienda = tiendas[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TiendaCard(
              tienda: tienda,
              onTap: () => onTiendaTap?.call(tienda),
            ),
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
