// lib/presentation/widgets/producto/producto_bg_painter.dart
//
// 🏛️ FONDO PRODUCTO: Partículas flotantes (branding adaptativo)
// ────────────────────────────────────────────────────────────
// NOTA: Este painter es branding y permanece en modo oscuro

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

const _kGold = Color(0xFFD4AF37);
const _kGoldLight = Color(0xFFFFE082);
const _kBg = Color(0xFF07070F);

class ProductoBgPainter extends CustomPainter {
  final double t;
  final Brightness brightness;

  ProductoBgPainter(this.t, this.brightness);

  static final _rng = math.Random(42);
  static final _particles = List.generate(
    45,
    (i) => [
      _rng.nextDouble(),
      _rng.nextDouble(),
      _rng.nextDouble() * 0.4 + 0.2,
      _rng.nextDouble() * 1.8 + 0.5,
      _rng.nextInt(3).toDouble(),
    ],
  );

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final isDark = brightness == Brightness.dark;

    final bgColor = isDark ? _kBg : const Color(0xFFF5F5F5);
    final particleColor1 = isDark ? _kGold : const Color(0xFFB8860B);
    final particleColor2 = isDark ? _kGoldLight : const Color(0xFFDAA520);

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = bgColor);

    if (isDark) {
      final beamOp = math.sin(t * math.pi * 2) * 0.03 + 0.05;
      canvas.drawPath(
        Path()
          ..moveTo(w * 0.2, 0)
          ..lineTo(w * 0.6, h)
          ..lineTo(w * 0.4, h)
          ..lineTo(w * 0.0, 0)
          ..close(),
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(w * 0.2, 0),
            Offset(w * 0.4, h),
            [
              Colors.transparent,
              _kGold.withValues(alpha: beamOp),
              Colors.transparent,
            ],
            [0.0, 0.5, 1.0],
          ),
      );
    }

    for (final p in _particles) {
      final px = p[0] * w;
      final py = ((p[1] + t * p[3] * 0.07) % 1.1 - 0.05) * h;
      final pr = p[2];
      final hue = p[4];
      final color =
          hue == 0
              ? particleColor1
              : hue == 1
              ? particleColor2
              : _kGoldLight.withValues(alpha: 0.6);

      final op = (math.sin(t * math.pi * 2 + p[0] * 5) + 1) / 2 * 0.25 + 0.15;

      if (isDark) {
        canvas.drawCircle(
          Offset(px, py),
          pr * 2.5,
          Paint()
            ..color = color.withValues(alpha: op * 0.7)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
        );
        canvas.drawCircle(
          Offset(px, py),
          pr * 1.2,
          Paint()..color = color.withValues(alpha: op),
        );
      } else {
        canvas.drawCircle(
          Offset(px, py),
          pr * 1.5,
          Paint()
            ..color = particleColor1.withValues(alpha: op * 0.25)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
        canvas.drawCircle(
          Offset(px, py),
          pr * 0.8,
          Paint()..color = particleColor1.withValues(alpha: op * 0.4),
        );
      }
    }

    if (isDark) {
      final cornerOp = 0.03 + math.sin(t * math.pi * 2 + 0.5) * 0.015;
      canvas.drawCircle(
        Offset(w, h * 0.3),
        h * 0.35,
        Paint()
          ..shader = ui.Gradient.radial(Offset(w, h * 0.3), h * 0.4, [
            _kGold.withValues(alpha: cornerOp),
            Colors.transparent,
          ]),
      );
    }
  }

  @override
  bool shouldRepaint(ProductoBgPainter oldDelegate) => t != oldDelegate.t;
}
