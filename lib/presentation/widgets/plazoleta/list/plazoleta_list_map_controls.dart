// lib/presentation/widgets/plazoleta/plazoleta_list_map_controls.dart
//
// 🏛️ PLAZA UNIVERSE — Plazoleta List Map Controls
// ────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

const _kGold = Color(0xFFD4AF37);

class PlazoletaListMapControls extends StatelessWidget {
  final double scale;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onResetView;

  const PlazoletaListMapControls({
    super.key,
    required this.scale,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onResetView,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? _kGold : const Color(0xFFB8860B);

    return Positioned(
      right: 14,
      top: MediaQuery.of(context).padding.top + 120,
      child: Container(
        decoration: BoxDecoration(
          color:
              isDark
                  ? theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.85,
                  )
                  : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accentColor.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MapControlButton(
              icon: Icons.remove,
              onTap: onZoomOut,
              accentColor: accentColor,
            ),
            Container(
              width: 1,
              height: 24,
              color: accentColor.withValues(alpha: 0.2),
            ),
            _MapControlButton(
              icon: Icons.add,
              onTap: onZoomIn,
              accentColor: accentColor,
            ),
            Container(
              width: 1,
              height: 24,
              color: accentColor.withValues(alpha: 0.2),
            ),
            _MapControlButton(
              icon: Icons.center_focus_strong_rounded,
              onTap: onResetView,
              accentColor: accentColor,
              isAccent: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _MapControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color accentColor;
  final bool isAccent;

  const _MapControlButton({
    required this.icon,
    required this.onTap,
    required this.accentColor,
    this.isAccent = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color:
              isAccent
                  ? accentColor.withValues(alpha: 0.18)
                  : Colors.transparent,
          borderRadius: isAccent ? BorderRadius.circular(8) : BorderRadius.zero,
          border: Border.all(
            color:
                isAccent
                    ? accentColor.withValues(alpha: 0.55)
                    : Colors.transparent,
            width: isAccent ? 1 : 0,
          ),
        ),
        child: Icon(icon, color: accentColor, size: 18),
      ),
    );
  }
}
