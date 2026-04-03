// lib/presentation/widgets/plazoleta/plazoleta_list_hint.dart
//
// 🏛️ PLAZA UNIVERSE — Plazoleta List Hint
// ────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

const _kGold = Color(0xFFD4AF37);

class PlazoletaListHint extends StatelessWidget {
  final Animation<double> introCtrl;

  const PlazoletaListHint({super.key, required this.introCtrl});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: introCtrl,
      builder: (_, __) {
        final t = introCtrl.value;
        if (t < 0.55 || t > 0.94) return const SizedBox.shrink();
        final op = (t < 0.65
                ? (t - 0.55) / 0.1
                : t > 0.84
                ? 1 - (t - 0.84) / 0.1
                : 1.0)
            .clamp(0.0, 1.0);
        return Positioned(
          bottom: 88,
          left: 0,
          right: 0,
          child: Opacity(
            opacity: op,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: _kGold.withValues(alpha: 0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: _kGold.withValues(alpha: 0.12),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.touch_app_rounded, color: _kGold, size: 14),
                    SizedBox(width: 8),
                    Text(
                      'Toca una plaza  •  Pellizca para zoom',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
