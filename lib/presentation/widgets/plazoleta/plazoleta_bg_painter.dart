// lib/presentation/widgets/plazoleta/plazoleta_bg_painter.dart
//
// 🏛️ PLAZA UNIVERSE — Plazoleta Background Painter
// ────────────────────────────────────────────────────────────
//  FONDO ISOMÉTRICO - USA TEMA
// ────────────────────────────────────────────────────────────

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

const _kGold = Color(0xFFD4AF37);
const _kGoldLight = Color(0xFFFFE082);

class PlazoletaBgPainter extends CustomPainter {
  final double t;
  final Brightness brightness;

  PlazoletaBgPainter(this.t, this.brightness);

  static final _rng = math.Random(42);
  static final _particles = List.generate(
    60,
    (i) => [
      _rng.nextDouble(),
      _rng.nextDouble(),
      _rng.nextDouble() * 0.6 + 0.2,
      _rng.nextDouble() * 2.5 + 0.5,
      _rng.nextInt(3).toDouble(),
    ],
  );

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final isDark = brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF07070F) : const Color(0xFFF5F5F5);
    final particleColor1 = isDark ? _kGold : const Color(0xFFB8860B);
    final particleColor2 = isDark ? _kGoldLight : const Color(0xFFDAA520);
    final diamondColor =
        isDark
            ? _kGold.withOpacity(0.08)
            : const Color(0xFFB8860B).withOpacity(0.12);

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = bgColor);

    if (isDark) {
      final beamOp = math.sin(t * math.pi * 2) * 0.04 + 0.08;
      canvas.drawPath(
        Path()
          ..moveTo(w * 0.35, 0)
          ..lineTo(w * 0.65, 0)
          ..lineTo(w * 0.80, h * 0.55)
          ..lineTo(w * 0.20, h * 0.55)
          ..close(),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_kGoldLight.withOpacity(beamOp), Colors.transparent],
          ).createShader(Rect.fromLTWH(0, 0, w, h * 0.55)),
      );
    }

    final tW = w * 0.18;
    final tH = tW * 0.5;
    for (int row = -1; row <= 14; row++) {
      for (int col = -1; col <= 6; col++) {
        final cx = (col - row) * tW / 2 + w * 0.5;
        final cy = (col + row) * tH / 2 - t * tH * 0.5;
        final pulse = math.sin(t * math.pi * 2 + col * 0.4 + row * 0.3) * 0.012;
        final alpha = (0.05 + pulse).clamp(0.0, isDark ? 0.10 : 0.06);
        final path =
            Path()
              ..moveTo(cx, cy - tH / 2)
              ..lineTo(cx + tW / 2, cy)
              ..lineTo(cx, cy + tH / 2)
              ..lineTo(cx - tW / 2, cy)
              ..close();
        canvas.drawPath(
          path,
          Paint()
            ..color = diamondColor.withAlpha((alpha * 255).toInt())
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.6,
        );
        if (row % 3 == 0) {
          canvas.drawPath(
            path,
            Paint()
              ..color = diamondColor.withAlpha((alpha * 0.22 * 255).toInt()),
          );
        }
      }
    }

    final colors =
        isDark
            ? [particleColor1, particleColor2, Colors.white]
            : [particleColor1, particleColor2, const Color(0xFF8B8B8B)];

    for (final p in _particles) {
      final phase = (t + p[2]) % 1.0;
      final op = math.sin(phase * math.pi) * (isDark ? 0.30 : 0.20);
      if (op <= 0) continue;
      final px = p[0] * w;
      final py = p[1] * h - phase * h * 0.22;
      canvas.drawCircle(
        Offset(px, py),
        p[3],
        Paint()
          ..color = colors[p[4].toInt()].withAlpha((op * 255).toInt())
          ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, p[3] * 1.2),
      );
    }

    if (isDark) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, w, h),
        Paint()
          ..shader = RadialGradient(
            center: Alignment.center,
            radius: 0.78,
            colors: [Colors.transparent, Colors.black.withAlpha(184)],
            stops: const [0.5, 1.0],
          ).createShader(Rect.fromLTWH(0, 0, w, h)),
      );
    }

    if (isDark) {
      final linePaint =
          Paint()
            ..color = _kGold.withAlpha(8)
            ..strokeWidth = 0.7;
      for (int i = 0; i < 6; i++) {
        canvas.drawLine(
          Offset(w * i / 5, 0),
          Offset(w * 0.5, h * 0.5),
          linePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(PlazoletaBgPainter o) =>
      o.t != t || o.brightness != brightness;
}
