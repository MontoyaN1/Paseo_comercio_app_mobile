// lib/presentation/widgets/producto/producto_info_tab.dart
//
// 🏛️ INFO TAB - Producto Detail
// ────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

const _kGold = Color(0xFFD4AF37);
const _kHint = Color(0xFF6B6B8A);
const _kSurfaceCard = Color(0xFF12121F);
const _kBorder = Color(0xFF1E1E3A);

class ProductoInfoTab extends StatelessWidget {
  final Map<String, dynamic>? producto;
  final VoidCallback? onWhatsApp;

  const ProductoInfoTab({super.key, this.producto, this.onWhatsApp});

  double get _calificacionPromedio =>
      (producto?['calificacion_promedio'] as num?)?.toDouble() ?? 0.0;

  int get _totalValoraciones => producto?['total_valoracion'] ?? 0;
  int get _visualizaciones => producto?['total_visualizaciones'] ?? 0;
  int get _vendidos => producto?['cantidad'] ?? 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hintColor = isDark ? _kHint : Colors.grey.shade600;
    final textColor = isDark ? Colors.white : Colors.black87;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            context: context,
            title: 'Calificación',
            icon: Icons.star_rounded,
            child: Row(
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    index < _calificacionPromedio.round()
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: _kGold,
                    size: 20,
                  );
                }),
                const SizedBox(width: 8),
                Text(
                  '${_calificacionPromedio.toStringAsFixed(1)} ($_totalValoraciones reseñas)',
                  style: TextStyle(color: textColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _GoldStatCard(
                  icon: Icons.visibility_rounded,
                  value: _visualizaciones,
                  label: 'Vistas',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GoldStatCard(
                  icon: Icons.shopping_bag_rounded,
                  value: _vendidos,
                  label: 'Vendidos',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (producto?['descripcion'] != null &&
              producto!['descripcion'].toString().isNotEmpty) ...[
            _buildSection(
              context: context,
              title: 'Descripción',
              icon: Icons.description_outlined,
              child: Text(
                producto!['descripcion'].toString(),
                style: TextStyle(
                  color: hintColor,
                  fontSize: 14,
                  height: 1.65,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (producto?['estado_producto'] != null)
            _buildSection(
              context: context,
              title: 'Estado',
              icon: Icons.check_circle_outline,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _kGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _kGold.withValues(alpha: 0.40)),
                ),
                child: Text(
                  producto?['estado_producto']?.toString().toUpperCase() ?? '',
                  style: const TextStyle(
                    color: _kGold,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onWhatsApp,
              icon: const Icon(Icons.chat_rounded),
              label: const Text('Contactar por WhatsApp'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg =
        isDark
            ? _kSurfaceCard.withValues(alpha: 0.6)
            : Colors.white.withValues(alpha: 0.9);
    final cardBorder =
        isDark ? _kBorder.withValues(alpha: 0.5) : Colors.grey.shade300;
    final titleColor = isDark ? Colors.white : Colors.black87;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: _kGold),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: titleColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _GoldStatCard extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;

  const _GoldStatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? _kHint : Colors.grey.shade600;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _kGold.withValues(alpha: 0.12),
            isDark ? const Color(0xFF12121F) : Colors.grey.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kGold.withValues(alpha: 0.30), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: _kGold, size: 24),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: TextStyle(
              color: textColor,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: hintColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
