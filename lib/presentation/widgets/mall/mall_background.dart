// lib/presentation/widgets/mall/mall_background.dart
//
// 🏛️  PLAZA UNIVERSE v4 — Fondo Atmosférico del Mall
// ────────────────────────────────────────────────────────────
//  Extraído de plazoleta_list_page.dart
//  Contiene: _MallBackground + _BgPainter
//  No aplica theme - es branding/hero image
// ────────────────────────────────────────────────────────────

import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

const _kGold = Color(0xFFD4AF37);
const _kBg = Color(0xFF0A0A0F);
const _kWarmLight = Color(0xFFFFE4A0);
const _kSkylight = Color(0xFFE8F4FF);
const _kGoldGlow = Color(0xFFFFE082);

class MallBackground extends StatelessWidget {
  final AnimationController skylightCtrl;
  final AnimationController ambientCtrl;

  const MallBackground({
    super.key,
    required this.skylightCtrl,
    required this.ambientCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([skylightCtrl, ambientCtrl]),
      builder: (_, __) {
        final sky = skylightCtrl.value;
        final amb = ambientCtrl.value;
        return CustomPaint(painter: _MallBgPainter(sky: sky, amb: amb));
      },
    );
  }
}

class _MallBgPainter extends CustomPainter {
  final double sky, amb;

  const _MallBgPainter({required this.sky, required this.amb});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.0, -0.3),
          radius: 1.1,
          colors: [
            const Color(0xFF141428),
            const Color(0xFF0D0D1E),
            const Color(0xFF080810),
            _kBg,
          ],
          stops: const [0.0, 0.4, 0.7, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    final skylightX = w / 2 + math.sin(sky * math.pi * 2) * w * 0.04;
    final skylightIntensity = math.sin(sky * math.pi * 2) * 0.12 + 0.88;

    final beamPaint =
        Paint()
          ..shader = RadialGradient(
            center: Alignment.topCenter,
            radius: 1.6,
            colors: [
              _kSkylight.withOpacity(0.22 * skylightIntensity),
              _kWarmLight.withOpacity(0.10 * skylightIntensity),
              Colors.transparent,
            ],
            stops: const [0.0, 0.45, 1.0],
          ).createShader(
            Rect.fromLTWH(skylightX - w * 0.4, 0, w * 0.8, h * 0.75),
          );
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h * 0.75), beamPaint);

    for (int i = 0; i < 3; i++) {
      final phase = (sky + i / 3.0) % 1.0;
      final bx = w * (0.25 + i * 0.25) + math.sin(phase * math.pi * 2) * 30;
      final op = math.sin(phase * math.pi) * 0.06;
      if (op <= 0) continue;
      canvas.drawPath(
        Path()
          ..moveTo(bx - 18, 0)
          ..lineTo(bx + 18, 0)
          ..lineTo(bx + 70, h * 0.55)
          ..lineTo(bx - 70, h * 0.55)
          ..close(),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_kSkylight.withOpacity(op), Colors.transparent],
          ).createShader(Rect.fromLTWH(bx - 70, 0, 140, h * 0.55)),
      );
    }

    final ambPulse = math.sin(amb * math.pi * 2) * 0.5 + 0.5;
    final cornerGlows = [
      Offset(0, 0),
      Offset(w, 0),
      Offset(0, h),
      Offset(w, h),
    ];
    for (final c in cornerGlows) {
      canvas.drawCircle(
        c,
        w * 0.55,
        Paint()
          ..color = _kGold.withOpacity(0.025 + ambPulse * 0.015)
          ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 60),
      );
    }

    final rng = math.Random(7);
    for (int i = 0; i < 22; i++) {
      final bx = rng.nextDouble() * w;
      final by = rng.nextDouble() * h;
      final br = rng.nextDouble() * 3.0 + 0.5;
      final phase = (amb + rng.nextDouble()) % 1.0;
      final op = math.sin(phase * math.pi) * 0.25;
      final col =
          i % 3 == 0
              ? _kGold
              : i % 3 == 1
              ? _kSkylight
              : Colors.white;
      canvas.drawCircle(
        Offset(bx, by - phase * 80),
        br,
        Paint()
          ..color = col.withOpacity(op)
          ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, br * 1.5),
      );
    }

    final beamLinePaint =
        Paint()
          ..color = _kGoldGlow.withOpacity(0.045)
          ..strokeWidth = 1.2;
    final numBeams = 7;
    for (int i = 0; i <= numBeams; i++) {
      final x = w * i / numBeams;
      canvas.drawLine(Offset(x, 0), Offset(w / 2, h * 0.38), beamLinePaint);
    }
    for (int i = 0; i <= 5; i++) {
      final y = h * i / 5;
      canvas.drawLine(
        Offset(0, y),
        Offset(w, y),
        Paint()
          ..color = _kGold.withOpacity(0.012)
          ..strokeWidth = 0.6,
      );
    }

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 0.82,
          colors: [Colors.transparent, Colors.black.withOpacity(0.62)],
          stops: const [0.55, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );
  }

  @override
  bool shouldRepaint(_MallBgPainter o) => o.sky != sky || o.amb != amb;
}
