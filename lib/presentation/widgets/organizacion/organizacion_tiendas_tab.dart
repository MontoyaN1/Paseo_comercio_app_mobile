// lib/presentation/widgets/organizacion/organizacion_tiendas_tab.dart
//
// 🏛️ ORGANIZACION TIENDAS TAB
// ────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import 'package:paseo_del_comercio/presentation/widgets/tienda/tienda_card.dart';

const _kGold = Color(0xFFD4AF37);
const _kGoldDeep = Color(0xFF9C7A1A);
const _kGoldLight = Color(0xFFFFE082);

class OrganizacionTiendasTab extends StatelessWidget {
  final List<Map<String, dynamic>> tiendas;
  final void Function(Map<String, dynamic> tienda)? onTiendaTap;

  const OrganizacionTiendasTab({
    super.key,
    required this.tiendas,
    this.onTiendaTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hintColor = isDark ? const Color(0xFF6B6B8A) : Colors.grey.shade600;

    if (tiendas.isEmpty) {
      return _buildEmptyState(context: context, hintColor: hintColor);
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      itemCount: tiendas.length,
      itemBuilder: (context, index) {
        final tienda = tiendas[index];
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
          child: TiendaCard(
            tienda: tienda,
            onTap: () => onTiendaTap?.call(tienda),
            showDetails: true,
            showFavoriteButton: false,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required BuildContext context,
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
            child: const Icon(Icons.store_rounded, size: 36, color: _kGold),
          ),
          const SizedBox(height: 18),
          ShaderMask(
            shaderCallback:
                (b) => const LinearGradient(
                  colors: [_kGoldDeep, _kGold, _kGoldLight],
                ).createShader(b),
            child: const Text(
              'Sin tiendas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Esta organización aún no tiene\ntiendas asociadas',
            style: TextStyle(color: hintColor, fontSize: 13, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
