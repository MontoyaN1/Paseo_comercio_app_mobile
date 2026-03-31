// lib/presentation/widgets/mall/mall_world_painter.dart
//
// 🏛️  PLAZA UNIVERSE v4 — Mall de Lujo Isométrico (Extracted)
// ────────────────────────────────────────────────────────────

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../domain/entities/enums.dart';
import '../../../../domain/entities/plazoleta.dart';

// ══════════════════════════════════════════════════════════════
//  PALETA DE LUJO
// ══════════════════════════════════════════════════════════════
const _kGold = Color(0xFFD4AF37);
const _kGoldGlow = Color(0xFFFFE082);

// Iluminación
const _kWarmLight = Color(0xFFFFE4A0); // luz cálida halógena
const _kCoolLight = Color(0xFFB0D4FF); // luz fría LED
const _kSkylight = Color(0xFFE8F4FF); // luz cenital de claraboya

// Tiendas
const _kNeonBlue = Color(0xFF00C8FF);
const _kNeonPink = Color(0xFFFF2D78);
const _kNeonGreen = Color(0xFF00FF9F);
const _kNeonOrange = Color(0xFFFF8C00);

// ══════════════════════════════════════════════════════════════
//  CONSTANTES ISOMÉTRICAS
// ══════════════════════════════════════════════════════════════
const double _tW = 110.0;
const double _tH = 55.0;
const double _pH = 16.0;
const double _kOriginOffsetY = 60.0;

// ══════════════════════════════════════════════════════════════
//  MODELOS
// ══════════════════════════════════════════════════════════════
class MallSlot {
  final int col, row;
  const MallSlot(this.col, this.row);
}

// ══════════════════════════════════════════════════════════════
//  LAYOUT — igual que v3
// ══════════════════════════════════════════════════════════════
const _slots = <MallSlot>[
  MallSlot(0, 0),
  MallSlot(4, 0),
  MallSlot(8, 0),
  MallSlot(12, 0),
  MallSlot(0, 4),
  MallSlot(12, 4),
  MallSlot(0, 8),
  MallSlot(12, 8),
  MallSlot(0, 12),
  MallSlot(4, 12),
  MallSlot(8, 12),
  MallSlot(12, 12),
  MallSlot(2, 2),
  MallSlot(6, 2),
  MallSlot(10, 2),
  MallSlot(2, 6),
  MallSlot(10, 6),
  MallSlot(2, 10),
  MallSlot(6, 10),
  MallSlot(10, 10),
];

bool _isAtrium(int c, int r) => c >= 4 && c <= 7 && r >= 4 && r <= 7;

const _columnPositions = <MallSlot>[
  MallSlot(3, 3), MallSlot(9, 3), MallSlot(3, 9), MallSlot(9, 9),
  // Columnas extra en corredores principales
  MallSlot(6, 0), MallSlot(0, 6), MallSlot(12, 6), MallSlot(6, 12),
];

// Tipos de tiendas para fachadas variadas
enum _StoreType { fashion, food, tech, beauty, sport, luxury }

// Enum para dirección de fachada
enum FacadeDir { north, west, east }

// ══════════════════════════════════════════════════════════════
//  PAINTER PRINCIPAL — MUNDO ISOMÉTRICO
// ══════════════════════════════════════════════════════════════
class MallWorldPainter extends CustomPainter {
  final List<PlazaData> plazas;
  final int? selIdx;
  final double ambient, skylight, selProg, introProg, scale;
  final Offset pan;

  const MallWorldPainter({
    required this.plazas,
    required this.selIdx,
    required this.ambient,
    required this.skylight,
    required this.selProg,
    required this.introProg,
    required this.scale,
    required this.pan,
  });

  Offset _iso(double c, double r, {double elev = 0}) =>
      Offset((c - r) * _tW / 2, (c + r) * _tH / 2 - elev);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2 + pan.dx;
    final cy = size.height / 2 + pan.dy + _kOriginOffsetY;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(scale);

    _drawMallFloor(canvas, size);
    _drawSkylightBeams(canvas, size);
    _drawWallsAndCeiling(canvas, size);
    _drawColumns(canvas);
    _drawStoresFacades(canvas);
    _drawAtrium(canvas);
    _drawFloorReflections(canvas);

    final sorted = [...plazas]..sort(
      (a, b) => (a.slot.col + a.slot.row).compareTo(b.slot.col + b.slot.row),
    );
    for (final p in sorted) {
      final isSel = p.index == selIdx;
      final elev = isSel ? selProg * 22.0 : 0.0;
      final fade = ((introProg - p.index * 0.032) * 5.0).clamp(0.0, 1.0);
      _drawPlaza(canvas, p, elev: elev, opacity: fade, selected: isSel);
    }

    _drawAmbientParticles(canvas);

    canvas.restore();
  }

  // ══════════════════════════════════════════════════════════
  //  SUELO DE MÁRMOL DE LUJO
  // ══════════════════════════════════════════════════════════
  void _drawMallFloor(Canvas canvas, Size size) {
    for (int r = -2; r <= 15; r++) {
      for (int c = -2; c <= 15; c++) {
        final tl = _iso(c.toDouble(), r.toDouble());
        final tr = _iso(c + 1.0, r.toDouble());
        final br = _iso(c + 1.0, r + 1.0);
        final bl = _iso(c.toDouble(), r + 1.0);
        final tilePath = _path4(tl, tr, br, bl);

        final isAtr = _isAtrium(c, r);
        final isSlot = _slots.any((s) => s.col == c && s.row == r);
        final isCorrH = r == 6 || r == 7; // corredor horizontal central
        final isCorrV = c == 6 || c == 7; // corredor vertical central

        if (isAtr) {
          // Atrio: mármol negro marquina
          _drawMarbleTile(
            canvas,
            tilePath,
            tl,
            br,
            dark: const Color(0xFF0C1020),
            light: const Color(0xFF141830),
            vein: const Color(0xFF1E2845),
            isRich: true,
          );
        } else if (isSlot) {
          // Plazoleta: gris grafito pulido
          _drawMarbleTile(
            canvas,
            tilePath,
            tl,
            br,
            dark: const Color(0xFF111124),
            light: const Color(0xFF181830),
            vein: const Color(0xFF20204A),
            isRich: false,
          );
        } else if (isCorrH || isCorrV) {
          // Corredores centrales: mármol blanco crema premium
          _drawLuxuryCorridorTile(canvas, c, r, tl, tr, br, bl, tilePath);
        } else {
          // Resto: mármol crema con patrón de loseta
          _drawStandardMarble(canvas, c, r, tl, tr, br, bl, tilePath);
        }
      }
    }

    // Bordes dorados del atrio
    _drawAtriumBorder(canvas);
    // Cenefas doradas en pasillos principales
    _drawCorridorBorders(canvas);
  }

  void _drawMarbleTile(
    Canvas canvas,
    Path path,
    Offset tl,
    Offset br, {
    required Color dark,
    required Color light,
    required Color vein,
    required bool isRich,
  }) {
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [light, dark],
        ).createShader(Rect.fromPoints(tl, br)),
    );

    if (isRich) {
      // Venas de mármol negro marquina
      canvas.drawPath(
        path,
        Paint()
          ..color = vein.withOpacity(0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5,
      );
    }
  }

  void _drawLuxuryCorridorTile(
    Canvas canvas,
    int c,
    int r,
    Offset tl,
    Offset tr,
    Offset br,
    Offset bl,
    Path tilePath,
  ) {
    // Mármol blanco Carrara en corredores principales
    final big = (c + r) % 2 == 0;
    final baseColor = big ? const Color(0xFF1E1E38) : const Color(0xFF181832);

    canvas.drawPath(
      tilePath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(baseColor, const Color(0xFF2A2A50), 0.3)!,
            baseColor,
            Color.lerp(baseColor, Colors.black, 0.2)!,
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromPoints(tl, br)),
    );

    // Brillo especular del mármol pulido
    final shine =
        math.sin(ambient * math.pi * 2 + c * 0.3 + r * 0.2) * 0.5 + 0.5;
    canvas.drawPath(
      tilePath,
      Paint()..color = Colors.white.withOpacity(0.06 + shine * 0.04),
    );

    // Grout (junta)
    canvas.drawPath(
      tilePath,
      Paint()
        ..color = const Color(0xFF24244A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7,
    );

    // Medallón en intersecciones
    if (c % 3 == 0 && r % 3 == 0) {
      final center = Offset((tl.dx + br.dx) / 2 + _tW / 2, (tl.dy + br.dy) / 2);
      canvas.drawOval(
        Rect.fromCenter(center: center, width: 12, height: 6),
        Paint()..color = _kGold.withOpacity(0.18),
      );
      canvas.drawOval(
        Rect.fromCenter(center: center, width: 10, height: 5),
        Paint()
          ..color = _kGold.withOpacity(0.10)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.6,
      );
    }
  }

  void _drawStandardMarble(
    Canvas canvas,
    int c,
    int r,
    Offset tl,
    Offset tr,
    Offset br,
    Offset bl,
    Path tilePath,
  ) {
    final big = (c ~/ 2 + r ~/ 2) % 2 == 0;
    final base = big ? const Color(0xFF131328) : const Color(0xFF111124);

    canvas.drawPath(tilePath, Paint()..color = base);

    // Brillo isométrico sutil
    canvas.drawPath(
      _path4(tl, tr, Offset.lerp(tr, br, 0.15)!, Offset.lerp(tl, bl, 0.15)!),
      Paint()..color = Colors.white.withOpacity(0.022),
    );

    // Grid de junta
    canvas.drawPath(
      tilePath,
      Paint()
        ..color = const Color(0xFF1C1C3C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );

    // Patrón de venas mármol en grupos 2×2
    if (c % 2 == 0 && r % 2 == 0) {
      final tl2 = _iso(c.toDouble(), r.toDouble());
      final br2 = _iso(c + 2.0, r + 2.0);
      final tr2 = _iso(c + 2.0, r.toDouble());
      final bl2 = _iso(c.toDouble(), r + 2.0);
      // Vena diagonal principal
      canvas.drawLine(
        Offset.lerp(tl2, br2, 0.15)!,
        Offset.lerp(tl2, br2, 0.65)!,
        Paint()
          ..color = const Color(0xFF1E1E45)
          ..strokeWidth = 0.7,
      );
      // Vena secundaria
      canvas.drawLine(
        Offset.lerp(tr2, bl2, 0.25)!,
        Offset.lerp(tr2, bl2, 0.55)!,
        Paint()
          ..color = const Color(0xFF1A1A40)
          ..strokeWidth = 0.4,
      );
    }
  }

  void _drawAtriumBorder(Canvas canvas) {
    // Moldura dorada triple alrededor del atrio
    for (int pass = 0; pass < 3; pass++) {
      final offset = pass * 0.1;
      final atrPath =
          Path()
            ..moveTo(
              _iso(4 - offset, 4 - offset).dx,
              _iso(4 - offset, 4 - offset).dy,
            )
            ..lineTo(
              _iso(8 + offset, 4 - offset).dx,
              _iso(8 + offset, 4 - offset).dy,
            )
            ..lineTo(
              _iso(8 + offset, 8 + offset).dx,
              _iso(8 + offset, 8 + offset).dy,
            )
            ..lineTo(
              _iso(4 - offset, 8 + offset).dx,
              _iso(4 - offset, 8 + offset).dy,
            )
            ..close();
      canvas.drawPath(
        atrPath,
        Paint()
          ..color = _kGold.withOpacity(0.35 - pass * 0.08)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4 - pass * 0.3,
      );
    }
  }

  void _drawCorridorBorders(Canvas canvas) {
    // Cenefa dorada en el borde del corredor central
    final borderPaint =
        Paint()
          ..color = _kGold.withOpacity(0.15)
          ..strokeWidth = 0.8
          ..style = PaintingStyle.stroke;

    // Líneas de corredor horizontal (r=6)
    for (int c = 0; c <= 12; c++) {
      canvas.drawLine(_iso(c.toDouble(), 6.0), _iso(c + 1.0, 6.0), borderPaint);
    }
    // Corredor vertical (c=6)
    for (int r = 0; r <= 12; r++) {
      canvas.drawLine(_iso(6.0, r.toDouble()), _iso(6.0, r + 1.0), borderPaint);
    }
  }

  // ══════════════════════════════════════════════════════════
  //  HACES DE LUZ CENITAL (desde el techo isométrico)
  // ══════════════════════════════════════════════════════════
  void _drawSkylightBeams(Canvas canvas, Size size) {
    // Haces de claraboya que penetran desde arriba
    final beamPositions = [
      [6.0, 0.0],
      [6.0, 6.0],
      [6.0, 12.0],
      [0.0, 6.0],
      [12.0, 6.0],
      [3.0, 3.0],
      [9.0, 3.0],
      [3.0, 9.0],
      [9.0, 9.0],
    ];
    for (int i = 0; i < beamPositions.length; i++) {
      final bp = beamPositions[i];
      final pos = _iso(bp[0], bp[1]);
      final phase = (skylight + i * 0.11) % 1.0;
      final flick = math.sin(phase * math.pi * 6 + i) * 0.08 + 0.92;
      final pulse = math.sin(skylight * math.pi * 2 + i * 0.4) * 0.5 + 0.5;
      final r = (38 + pulse * 8) * flick;

      // Cono de luz sobre el suelo
      canvas.drawOval(
        Rect.fromCenter(center: pos, width: r * 2.4, height: r * 1.2),
        Paint()
          ..color = _kWarmLight.withOpacity(0.08 * flick)
          ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, 20),
      );
      // Punto central (downlight intenso)
      canvas.drawOval(
        Rect.fromCenter(center: pos, width: r * 0.5, height: r * 0.25),
        Paint()..color = _kSkylight.withOpacity(0.22 * flick),
      );
      // Brillo especular central
      canvas.drawCircle(
        pos,
        3.0 * flick,
        Paint()..color = Colors.white.withOpacity(0.55 * flick),
      );
    }
  }

  // ══════════════════════════════════════════════════════════
  //  PAREDES Y TECHO (perímetro del mall)
  // ══════════════════════════════════════════════════════════
  void _drawWallsAndCeiling(Canvas canvas, Size size) {
    // Pared trasera del fondo (NW y NE)
    final wallH = 80.0;
    final wallColors = [const Color(0xFF0E0E22), const Color(0xFF0C0C1E)];

    // Pared norte (NW — lado izquierdo visible)
    for (int c = -1; c <= 13; c++) {
      final base = _iso(c.toDouble(), -1.0);
      final top = base.translate(0, -wallH);
      final next = _iso(c + 1.0, -1.0);
      final topN = next.translate(0, -wallH);

      canvas.drawPath(
        _path4(base, next, topN, top),
        Paint()
          ..color = wallColors[c % 2]
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF0A0A1A), const Color(0xFF131328)],
          ).createShader(Rect.fromPoints(top, next)),
      );

      // Banda de rodapie dorada
      if (c % 2 == 0) {
        canvas.drawPath(
          _path4(base, next, next.translate(0, -6), base.translate(0, -6)),
          Paint()..color = _kGold.withOpacity(0.22),
        );
      }
    }

    // Cornisa superior
    for (int c = -1; c <= 13; c++) {
      final base = _iso(c.toDouble(), -1.0).translate(0, -wallH);
      final next = _iso(c + 1.0, -1.0).translate(0, -wallH);
      canvas.drawLine(
        base,
        next,
        Paint()
          ..color = _kGold.withOpacity(0.35)
          ..strokeWidth = 1.2,
      );
    }
  }

  // ══════════════════════════════════════════════════════════
  //  COLUMNAS MARMÓREAS DE LUJO
  // ══════════════════════════════════════════════════════════
  void _drawColumns(Canvas canvas) {
    for (final s in _columnPositions) {
      _drawLuxuryColumn(canvas, s.col.toDouble(), s.row.toDouble());
    }
  }

  void _drawLuxuryColumn(Canvas canvas, double c, double r) {
    const cW = 5.5; // semiancho
    const cH = 62.0; // altura
    final base = _iso(c + 0.5, r + 0.5);
    final glow = math.sin(ambient * math.pi * 2 + c + r) * 0.5 + 0.5;

    // ─ Plinto (base) ─
    final plintoH = 8.0;
    // Cara frontal derecha del plinto
    canvas.drawPath(
      _path4(
        base.translate(0, 0),
        base.translate(cW * 1.5, -cW * 0.75),
        base.translate(cW * 1.5, -cW * 0.75 - plintoH),
        base.translate(0, -plintoH),
      ),
      Paint()..color = const Color(0xFF1E1E50),
    );
    // Cara frontal izquierda del plinto
    canvas.drawPath(
      _path4(
        base.translate(0, 0),
        base.translate(-cW * 1.5, -cW * 0.75),
        base.translate(-cW * 1.5, -cW * 0.75 - plintoH),
        base.translate(0, -plintoH),
      ),
      Paint()..color = const Color(0xFF18184A),
    );
    // Top del plinto (cara superior)
    canvas.drawPath(
      _path4(
        base.translate(0, -plintoH),
        base.translate(cW * 1.5, -cW * 0.75 - plintoH),
        base.translate(0, -cW * 1.5 - plintoH),
        base.translate(-cW * 1.5, -cW * 0.75 - plintoH),
      ),
      Paint()..color = const Color(0xFF26266A),
    );

    // ─ Fuste (con estrías) ─
    final fusteTop = plintoH + cH;
    // Cara derecha del fuste — mármol crema
    canvas.drawPath(
      _path4(
        base.translate(cW * 1.5, -cW * 0.75 - plintoH),
        base.translate(cW, -cW * 0.5 - fusteTop),
        base.translate(0, -fusteTop),
        base.translate(0, -plintoH),
      ),
      Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFF22224E),
            const Color(0xFF2A2A60),
            const Color(0xFF1E1E4A),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(
          Rect.fromPoints(
            base.translate(cW * 1.5, -plintoH),
            base.translate(0, -fusteTop),
          ),
        ),
    );
    // Cara izquierda del fuste
    canvas.drawPath(
      _path4(
        base.translate(-cW * 1.5, -cW * 0.75 - plintoH),
        base.translate(-cW, -cW * 0.5 - fusteTop),
        base.translate(0, -fusteTop),
        base.translate(0, -plintoH),
      ),
      Paint()..color = const Color(0xFF1A1A46),
    );

    // Estrías verticales (líneas decorativas en el fuste)
    for (int i = 1; i < 4; i++) {
      final f = i / 4.0;
      final striaDx = cW * 1.5 * (1 - f) - cW * f;
      final stria_y0 = -plintoH - cW * 0.75 * f;
      final stria_y1 = -fusteTop - cW * 0.5 * f;
      canvas.drawLine(
        base.translate(striaDx, stria_y0),
        base.translate(striaDx * 0.7, stria_y1),
        Paint()
          ..color = Colors.white.withOpacity(0.06)
          ..strokeWidth = 0.5,
      );
    }

    // ─ Capitel (corona dorada) ─
    final capH = 10.0;
    final capBase = fusteTop;
    canvas.drawPath(
      _path4(
        base.translate(-cW * 2.0, -cW - capBase),
        base.translate(cW * 2.0, -cW - capBase),
        base.translate(cW * 2.0, -cW - capBase - capH),
        base.translate(-cW * 2.0, -cW - capBase - capH),
      ),
      Paint()..color = _kGold.withOpacity(0.55),
    );

    // Cara superior del capitel (techo de la columna)
    canvas.drawPath(
      _path4(
        base.translate(0, -cW * 2.0 - capBase - capH),
        base.translate(cW * 2.0, -cW - capBase - capH),
        base.translate(0, -capBase - capH),
        base.translate(-cW * 2.0, -cW - capBase - capH),
      ),
      Paint()..color = _kGold.withOpacity(0.70),
    );

    // Voluta (detalle curvo del capitel)
    canvas.drawOval(
      Rect.fromCenter(
        center: base.translate(-cW * 1.5, -cW * 0.8 - capBase - capH * 0.5),
        width: cW * 1.4,
        height: cW * 0.7,
      ),
      Paint()
        ..color = _kGoldGlow.withOpacity(0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: base.translate(cW * 1.5, -cW * 0.8 - capBase - capH * 0.5),
        width: cW * 1.4,
        height: cW * 0.7,
      ),
      Paint()
        ..color = _kGoldGlow.withOpacity(0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    // Halo de luz en la base
    canvas.drawOval(
      Rect.fromCenter(center: base, width: 35, height: 17),
      Paint()
        ..color = _kWarmLight.withOpacity(0.06 + glow * 0.04)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 10),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  FACHADAS DE TIENDAS (detalladas por tipo)
  // ══════════════════════════════════════════════════════════
  void _drawStoresFacades(Canvas canvas) {
    // Tiendas en el perímetro norte (borde superior)
    final northFacades = [
      [1.5, 0.0, 0],
      [3.5, 0.0, 1],
      [5.5, 0.0, 2],
      [7.5, 0.0, 3],
      [9.5, 0.0, 4],
      [11.5, 0.0, 5],
    ];
    // Tiendas en el perímetro oeste
    final westFacades = [
      [0.0, 1.5, 0],
      [0.0, 3.5, 3],
      [0.0, 5.5, 1],
      [0.0, 7.5, 4],
      [0.0, 9.5, 2],
      [0.0, 11.5, 5],
    ];
    // Tiendas en el perímetro este
    final eastFacades = [
      [13.0, 1.5, 2],
      [13.0, 3.5, 0],
      [13.0, 5.5, 5],
      [13.0, 7.5, 1],
      [13.0, 9.5, 3],
      [13.0, 11.5, 4],
    ];

    for (final f in northFacades) {
      _drawStoreFacade(
        canvas,
        f[0] as double,
        f[1] as double,
        _StoreType.values[(f[2] as int) % _StoreType.values.length],
        FacadeDir.north,
      );
    }
    for (final f in westFacades) {
      _drawStoreFacade(
        canvas,
        f[0] as double,
        f[1] as double,
        _StoreType.values[(f[2] as int) % _StoreType.values.length],
        FacadeDir.west,
      );
    }
    for (final f in eastFacades) {
      _drawStoreFacade(
        canvas,
        f[0] as double,
        f[1] as double,
        _StoreType.values[(f[2] as int) % _StoreType.values.length],
        FacadeDir.east,
      );
    }
  }

  void _drawStoreFacade(
    Canvas canvas,
    double c,
    double r,
    _StoreType type,
    FacadeDir dir,
  ) {
    final base = _iso(c, r);

    final glow = math.sin(ambient * math.pi * 2 + c * 0.5) * 0.5 + 0.5;

    // Colores por tipo de tienda
    final storeData = _storeAppearance(type);
    final wallColor = storeData['wall'] as Color;
    final neonColor = storeData['neon'] as Color;
    final accentCol = storeData['accent'] as Color;

    const fW = 22.0;
    const fH = 38.0;
    const roH = 6.0;
    final sign = dir == FacadeDir.east ? -1.0 : 1.0;
    final offy = dir == FacadeDir.north ? -fW * 0.5 * sign : -fW * 0.5 * sign;

    // ─ Pared principal ─
    canvas.drawPath(
      _path4(
        base,
        base.translate(sign * fW, offy),
        base.translate(sign * fW, offy - fH),
        base.translate(0, -fH),
      ),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [wallColor.withOpacity(0.85), wallColor.withOpacity(0.60)],
        ).createShader(
          Rect.fromPoints(base, base.translate(sign * fW, offy - fH)),
        ),
    );

    // ─ Escaparate / vitrina ─
    final winX = sign * fW * 0.5;
    final winY = offy * 0.5 - fH * 0.45;
    final winW = fW * 0.55;
    final winH = fH * 0.38;

    // Marco de la vitrina
    canvas.drawRect(
      Rect.fromCenter(
        center: base.translate(winX, winY),
        width: winW,
        height: winH,
      ),
      Paint()..color = const Color(0xFF1A1A3A),
    );
    // Cristal iluminado de la vitrina
    canvas.drawRect(
      Rect.fromCenter(
        center: base.translate(winX, winY),
        width: winW - 2,
        height: winH - 2,
      ),
      Paint()..color = neonColor.withOpacity(0.12 + glow * 0.08),
    );
    // Reflejo del cristal
    canvas.drawRect(
      Rect.fromCenter(
        center: base.translate(winX - winW * 0.15, winY - winH * 0.2),
        width: winW * 0.3,
        height: winH * 0.5,
      ),
      Paint()..color = Colors.white.withOpacity(0.08),
    );
    // Marco dorado de la vitrina
    canvas.drawRect(
      Rect.fromCenter(
        center: base.translate(winX, winY),
        width: winW,
        height: winH,
      ),
      Paint()
        ..color = _kGold.withOpacity(0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7,
    );

    // ─ Toldo / marquesina ─
    final awningTop = base.translate(0, -fH * 0.62);
    final awningEnd = base.translate(sign * fW, offy - fH * 0.62);
    canvas.drawPath(
      _path4(
        awningTop.translate(0, 0),
        awningEnd.translate(0, 0),
        awningEnd.translate(0, -roH),
        awningTop.translate(0, -roH),
      ),
      Paint()..color = accentCol.withOpacity(0.80),
    );
    // Franjas del toldo
    for (int i = 0; i < 4; i++) {
      final f = (i + 0.5) / 4.0;
      final sx = awningTop.dx + (awningEnd.dx - awningTop.dx) * f;
      final sy = awningTop.dy + (awningEnd.dy - awningTop.dy) * f;
      canvas.drawLine(
        Offset(sx, sy),
        Offset(sx, sy - roH),
        Paint()
          ..color = Colors.white.withOpacity(0.20)
          ..strokeWidth = 1.5,
      );
    }

    // ─ Neón del nombre de la tienda ─
    final neonX = base.dx + winX;
    final neonY = base.dy + offy * 0.5 - fH * 0.82;
    canvas.drawRect(
      Rect.fromCenter(center: Offset(neonX, neonY), width: fW * 0.7, height: 5),
      Paint()
        ..color = neonColor.withOpacity(0.65 + glow * 0.30)
        ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, 4),
    );
    // Halo del neón
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(neonX, neonY),
        width: fW * 0.9,
        height: 10,
      ),
      Paint()
        ..color = neonColor.withOpacity(0.08 + glow * 0.06)
        ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, 8),
    );

    // ─ Borde / marco de la fachada ─
    canvas.drawPath(
      _path4(
        base,
        base.translate(sign * fW, offy),
        base.translate(sign * fW, offy - fH),
        base.translate(0, -fH),
      ),
      Paint()
        ..color = accentCol.withOpacity(0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7,
    );

    // ─ Puerta ─
    final doorX = sign * fW * 0.5;
    final doorY = offy * 0.5;
    canvas.drawRect(
      Rect.fromCenter(
        center: base.translate(doorX, doorY),
        width: fW * 0.22,
        height: fH * 0.30,
      ),
      Paint()..color = const Color(0xFF0A0A1E),
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: base.translate(doorX, doorY),
        width: fW * 0.22,
        height: fH * 0.30,
      ),
      Paint()
        ..color = _kGold.withOpacity(0.20)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6,
    );
  }

  Map<String, Color> _storeAppearance(_StoreType type) {
    switch (type) {
      case _StoreType.fashion:
        return {
          'wall': const Color(0xFF1A0A2E),
          'neon': _kNeonPink,
          'accent': const Color(0xFF8B0057),
        };
      case _StoreType.food:
        return {
          'wall': const Color(0xFF1A1200),
          'neon': _kNeonOrange,
          'accent': const Color(0xFF8B4500),
        };
      case _StoreType.tech:
        return {
          'wall': const Color(0xFF001A2E),
          'neon': _kNeonBlue,
          'accent': const Color(0xFF00548B),
        };
      case _StoreType.beauty:
        return {
          'wall': const Color(0xFF1A002E),
          'neon': const Color(0xFFFF80FF),
          'accent': const Color(0xFF6B008B),
        };
      case _StoreType.sport:
        return {
          'wall': const Color(0xFF001A0A),
          'neon': _kNeonGreen,
          'accent': const Color(0xFF005530),
        };
      case _StoreType.luxury:
        return {
          'wall': const Color(0xFF1A1400),
          'neon': _kGold,
          'accent': const Color(0xFF8B7200),
        };
    }
  }

  // ══════════════════════════════════════════════════════════
  //  ATRIO CENTRAL (mejorado)
  // ══════════════════════════════════════════════════════════
  void _drawAtrium(Canvas canvas) {
    final tl = _iso(4, 4);
    final tr = _iso(8, 4);
    final br = _iso(8, 8);
    final bl = _iso(4, 8);

    // Suelo del atrio — mármol negro brillante
    canvas.drawPath(
      _path4(tl, tr, br, bl),
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 0.85,
          colors: [
            const Color(0xFF1A1A40),
            const Color(0xFF0C0C28),
            const Color(0xFF080820),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromPoints(tl, br)),
    );

    // Mosaico de suelo del atrio (patrón de diamantes)
    _drawAtriumMosaic(canvas, tl, tr, br, bl);

    // Reflejo luminoso animado
    final sh = math.sin(ambient * math.pi * 2) * 0.5 + 0.5;
    canvas.drawPath(
      _path4(tl, tr, br, bl),
      Paint()..color = _kCoolLight.withOpacity(0.035 + sh * 0.025),
    );

    // Líneas de cúpula de cristal
    final gridPaint =
        Paint()
          ..color = const Color(0x1A64B4FF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
    for (int i = 1; i < 5; i++) {
      final f = i / 5.0;
      canvas.drawLine(
        Offset.lerp(tl, br, f)!,
        Offset.lerp(tr, bl, f)!,
        gridPaint,
      );
      canvas.drawLine(
        Offset.lerp(tl, bl, f)!,
        Offset.lerp(tr, br, f)!,
        gridPaint,
      );
      canvas.drawLine(
        Offset.lerp(tl, tr, f)!,
        Offset.lerp(bl, br, f)!,
        gridPaint,
      );
    }

    // Borde iluminado del atrio
    canvas.drawPath(
      _path4(tl, tr, br, bl),
      Paint()
        ..color = _kCoolLight.withOpacity(0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    // Fuente central
    _drawGrandFountain(canvas, _iso(6.0, 6.0));

    // Plantas tropicales del atrio
    _drawAtriumPalms(canvas);
  }

  void _drawAtriumMosaic(
    Canvas canvas,
    Offset tl,
    Offset tr,
    Offset br,
    Offset bl,
  ) {
    // Patrón de rombo en mosaico
    for (int i = 1; i < 4; i++) {
      for (int j = 1; j < 4; j++) {
        final fi = i / 4.0;
        final fj = j / 4.0;
        final center =
            Offset.lerp(
              Offset.lerp(tl, tr, fi)!,
              Offset.lerp(bl, br, fi)!,
              fj,
            )!;
        final sz = 4.0;
        if ((i + j) % 2 == 0) {
          canvas.drawOval(
            Rect.fromCenter(center: center, width: sz * 2.2, height: sz * 1.1),
            Paint()..color = _kGold.withOpacity(0.12),
          );
        }
      }
    }
    // Cenefa interior dorada
    const inset = 0.08;
    final itl =
        Offset.lerp(
          Offset.lerp(tl, tr, inset)!,
          Offset.lerp(bl, br, inset)!,
          inset,
        )!;
    final itr =
        Offset.lerp(
          Offset.lerp(tl, tr, 1 - inset)!,
          Offset.lerp(bl, br, 1 - inset)!,
          inset,
        )!;
    final ibr =
        Offset.lerp(
          Offset.lerp(tl, tr, 1 - inset)!,
          Offset.lerp(bl, br, 1 - inset)!,
          1 - inset,
        )!;
    final ibl =
        Offset.lerp(
          Offset.lerp(tl, tr, inset)!,
          Offset.lerp(bl, br, inset)!,
          1 - inset,
        )!;
    canvas.drawPath(
      _path4(itl, itr, ibr, ibl),
      Paint()
        ..color = _kGold.withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  void _drawGrandFountain(Canvas canvas, Offset center) {
    final pulse = math.sin(ambient * math.pi * 4) * 0.5 + 0.5;
    final pulse2 = math.sin(ambient * math.pi * 4 + 1.5) * 0.5 + 0.5;

    // ─ Cuenco exterior ─
    canvas.drawOval(
      Rect.fromCenter(center: center, width: _tW * 1.1, height: _tH * 1.1),
      Paint()..color = const Color(0xFF101030),
    );
    canvas.drawOval(
      Rect.fromCenter(center: center, width: _tW * 1.1, height: _tH * 1.1),
      Paint()
        ..color = _kGold.withOpacity(0.30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    // ─ Agua con mosaico azul ─
    canvas.drawOval(
      Rect.fromCenter(center: center, width: _tW * 0.95, height: _tH * 0.95),
      Paint()
        ..shader = RadialGradient(
          colors: [const Color(0xFF1A3A7A), const Color(0xFF0D1E45)],
        ).createShader(
          Rect.fromCenter(center: center, width: _tW, height: _tH),
        ),
    );

    // Anillos de agua animados
    for (int i = 1; i <= 4; i++) {
      final fr = i / 4.0;
      final ringPhase = (pulse + i * 0.25) % 1.0;
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: _tW * 0.9 * fr,
          height: _tH * 0.9 * fr,
        ),
        Paint()
          ..color = const Color(
            0xFF60A0FF,
          ).withOpacity((1 - fr) * (0.18 + ringPhase * 0.12))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
    }

    // ─ Pedestal central ─
    canvas.drawOval(
      Rect.fromCenter(center: center, width: 18, height: 9),
      Paint()..color = _kGold.withOpacity(0.55),
    );
    canvas.drawOval(
      Rect.fromCenter(center: center, width: 16, height: 8),
      Paint()..color = _kGoldGlow.withOpacity(0.35),
    );

    // ─ Chorro principal ─
    final jetH = 18.0 + pulse2 * 6;
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(0, -jetH * 0.5),
        width: 4 + pulse * 2,
        height: jetH,
      ),
      Paint()
        ..color = const Color(0xFF80C8FF).withOpacity(0.55 + pulse2 * 0.3)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 2),
    );

    // ─ Gotas cayendo ─
    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3 + ambient * math.pi;
      final dr = (10 + pulse * 4).toDouble();
      final dx = math.cos(angle) * dr;
      final dy = math.sin(angle) * dr * 0.5 - 6;
      canvas.drawCircle(
        center.translate(dx, dy),
        1.2 + pulse * 0.5,
        Paint()..color = const Color(0xFF80D0FF).withOpacity(0.55),
      );
    }

    // ─ Halo luminoso de la fuente ─
    canvas.drawOval(
      Rect.fromCenter(center: center, width: _tW * 1.4, height: _tH * 1.4),
      Paint()
        ..color = const Color(0xFF4080FF).withOpacity(0.05 + pulse * 0.04)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 20),
    );
    // Brillo top
    canvas.drawCircle(
      center,
      2.0 + pulse,
      Paint()
        ..color = Colors.white.withOpacity(0.9)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 3),
    );
  }

  void _drawAtriumPalms(Canvas canvas) {
    // Palmeras decorativas en las esquinas del atrio
    const palmPositions = [
      [4.3, 4.3],
      [7.7, 4.3],
      [4.3, 7.7],
      [7.7, 7.7],
    ];
    for (final pp in palmPositions) {
      _drawIndoorPalm(canvas, _iso(pp[0], pp[1]));
    }
  }

  void _drawIndoorPalm(Canvas canvas, Offset base) {
    const tH = 28.0;
    const sW = 2.5;

    // Maceta decorativa dorada
    canvas.drawPath(
      _path4(
        base.translate(-7, 0),
        base.translate(7, -3.5),
        base.translate(6, -3.5 - 9),
        base.translate(-6, -9),
      ),
      Paint()..color = _kGold.withOpacity(0.45),
    );
    canvas.drawPath(
      _path4(
        base.translate(-7, 0),
        base.translate(7, -3.5),
        base.translate(6, -3.5 - 9),
        base.translate(-6, -9),
      ),
      Paint()
        ..color = const Color(0xFF8B6914)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6,
    );
    // Tierra en la maceta
    canvas.drawOval(
      Rect.fromCenter(center: base.translate(0, -9), width: 13, height: 6.5),
      Paint()..color = const Color(0xFF3E2723),
    );

    // Tronco (curvo simulado con segmentos)
    for (int i = 0; i < 4; i++) {
      final f0 = i / 4.0;
      final f1 = (i + 1) / 4.0;
      final x0 = math.sin(f0 * math.pi * 0.6) * 4;
      final y0 = -9 - tH * f0;
      final x1 = math.sin(f1 * math.pi * 0.6) * 4;
      final y1 = -9 - tH * f1;
      canvas.drawPath(
        _path4(
          base.translate(x0 - sW, y0),
          base.translate(x0 + sW, y0 - sW * 0.5),
          base.translate(x1 + sW, y1 - sW * 0.5),
          base.translate(x1 - sW, y1),
        ),
        Paint()..color = const Color(0xFF5D4037),
      );
    }

    // Hojas de palma (frondas)
    final tipX = math.sin(math.pi * 0.6) * 4;
    final tipY = -9 - tH;
    final leafPairs = [
      [1.0, -0.5],
      [-1.0, -0.5],
      [0.5, -1.0],
      [-0.5, -1.0],
      [0.8, -0.8],
      [-0.8, -0.8],
    ];
    for (int i = 0; i < leafPairs.length; i++) {
      final ld = leafPairs[i];
      final lx = ld[0] * 20;
      final ly = ld[1] * 14;
      final wave = math.sin(ambient * math.pi * 2 + i * 0.8) * 1.5;
      // Hoja
      canvas.drawPath(
        Path()
          ..moveTo(base.dx + tipX, base.dy + tipY)
          ..quadraticBezierTo(
            base.dx + tipX + lx * 0.5,
            base.dy + tipY + ly * 0.5,
            base.dx + tipX + lx + wave,
            base.dy + tipY + ly,
          ),
        Paint()
          ..color = const Color(0xFF2E7D32)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
      // Nervio central de la hoja
      canvas.drawPath(
        Path()
          ..moveTo(base.dx + tipX, base.dy + tipY)
          ..quadraticBezierTo(
            base.dx + tipX + lx * 0.5,
            base.dy + tipY + ly * 0.5,
            base.dx + tipX + lx + wave,
            base.dy + tipY + ly,
          ),
        Paint()
          ..color = const Color(0xFF43A047)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  // ══════════════════════════════════════════════════════════
  //  REFLEJO EN EL SUELO (efecto mármol pulido)
  // ══════════════════════════════════════════════════════════
  void _drawFloorReflections(Canvas canvas) {
    // Reflejo tenue de las columnas y la fuente en el suelo
    for (final s in _columnPositions) {
      final base = _iso(s.col + 0.5, s.row + 0.5);
      canvas.drawOval(
        Rect.fromCenter(center: base.translate(0, 8), width: 22, height: 11),
        Paint()
          ..color = _kGold.withOpacity(0.08)
          ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 6),
      );
    }
    // Reflejo de la fuente
    final fCenter = _iso(6.0, 6.0);
    canvas.drawOval(
      Rect.fromCenter(
        center: fCenter.translate(0, 12),
        width: _tW * 0.9,
        height: _tH * 0.45,
      ),
      Paint()
        ..color = const Color(0xFF4080FF).withOpacity(0.06)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 14),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  PLAZOLETA COMPLETA
  // ══════════════════════════════════════════════════════════
  void _drawPlaza(
    Canvas canvas,
    PlazaData p, {
    required double elev,
    required double opacity,
    required bool selected,
  }) {
    if (opacity <= 0) return;
    final c = p.slot.col.toDouble();
    final r = p.slot.row.toDouble();
    final rng = math.Random(p.seed);
    final acc = p.accent;

    final gN = _iso(c, r, elev: elev);
    final gE = _iso(c + 1, r, elev: elev);
    final gS = _iso(c + 1, r + 1, elev: elev);
    final gW = _iso(c, r + 1, elev: elev);

    final bE = gE.translate(0, _pH);
    final bS = gS.translate(0, _pH);
    final bW = gW.translate(0, _pH);

    // ─ Plataforma — zócalo de mármol ─
    canvas.drawPath(
      _path4(gE, bE, bS, gS),
      Paint()
        ..shader = LinearGradient(
          colors: [
            Color.lerp(const Color(0xFF1C1C44), acc, 0.20)!,
            Color.lerp(const Color(0xFF141438), acc, 0.14)!,
          ],
        ).createShader(Rect.fromPoints(gE, bS))
        ..color = Color.lerp(
          const Color(0xFF1C1C44),
          acc,
          0.18,
        )!.withOpacity(opacity),
    );
    canvas.drawPath(
      _path4(gW, bW, bS, gS),
      Paint()
        ..color = Color.lerp(
          const Color(0xFF141438),
          acc,
          0.12,
        )!.withOpacity(opacity),
    );

    // Borde metálico del zócalo
    canvas.drawPath(
      _path4(gE, bE, bS, gS),
      Paint()
        ..color = acc.withOpacity(0.22 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
    canvas.drawPath(
      _path4(gW, bW, bS, gS),
      Paint()
        ..color = acc.withOpacity(0.14 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );

    // ─ Piso de la plazoleta ─
    final floorColor =
        selected
            ? Color.lerp(const Color(0xFF1E1E42), acc, 0.22 + selProg * 0.12)!
            : const Color(0xFF1A1A3E);
    canvas.drawPath(
      _path4(gN, gE, gS, gW),
      Paint()..color = floorColor.withOpacity(opacity),
    );

    // Patrón de adoquines mejorado
    _drawPlazaFloorPattern(canvas, gN, gE, gS, gW, acc, opacity);

    // Borde exterior iluminado
    canvas.drawPath(
      _path4(gN, gE, gS, gW),
      Paint()
        ..color = acc.withOpacity(0.32 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Marcas de esquina
    for (final corner in [gN, gE, gS, gW]) {
      canvas.drawCircle(
        corner,
        2.0,
        Paint()..color = acc.withOpacity(0.55 * opacity),
      );
    }

    // ─ Glow de selección ─
    if (selected && selProg > 0) {
      canvas.drawPath(
        Path()..addOval(
          Rect.fromCenter(
            center: Offset((gN.dx + gS.dx) / 2, gS.dy + 6),
            width: _tW * 1.9,
            height: _tH * 1.1,
          ),
        ),
        Paint()
          ..color = _kGold.withOpacity(0.35 * selProg)
          ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, 28 * selProg),
      );
    }

    // ─ Sendero ─
    _drawPathway(canvas, gN, gE, gS, gW, opacity, p.seed);

    // ─ Árboles / plantas ─
    final hasFood = p.data?.tipoUbicacion == TipoUbicacion.zonaComida;
    final numTrees = hasFood ? 1 : rng.nextInt(2) + 1;
    final treeOffsets = [
      [0.18 + rng.nextDouble() * 0.12, 0.18 + rng.nextDouble() * 0.08],
      [0.68 + rng.nextDouble() * 0.10, 0.18 + rng.nextDouble() * 0.08],
      [0.18 + rng.nextDouble() * 0.10, 0.68 + rng.nextDouble() * 0.08],
    ];
    for (int i = 0; i < numTrees; i++) {
      final uv = treeOffsets[i];
      final pos = _tilePoint(gN, gE, gS, gW, uv[0], uv[1]);
      _drawTree(
        canvas,
        pos,
        color:
            Color.lerp(
              const Color(0xFF2E7D32),
              const Color(0xFF66BB6A),
              rng.nextDouble(),
            )!,
        opacity: opacity,
        heightFactor: 0.65 + rng.nextDouble() * 0.55,
        seed: p.seed + i * 17,
      );
    }

    // ─ Mobiliario ─
    if (!hasFood || rng.nextBool()) {
      _drawPremiumBench(
        canvas,
        _tilePoint(
          gN,
          gE,
          gS,
          gW,
          0.55 + rng.nextDouble() * 0.12,
          0.44 + rng.nextDouble() * 0.08,
        ),
        acc,
        opacity: opacity,
      );
    }
    if (hasFood) {
      _drawKiosk(
        canvas,
        _tilePoint(gN, gE, gS, gW, 0.38, 0.36),
        acc,
        opacity: opacity,
      );
    } else {
      _drawSmallFountain(
        canvas,
        _tilePoint(gN, gE, gS, gW, 0.45, 0.44),
        acc,
        opacity: opacity,
      );
    }
    if (p.data?.tipoUbicacion == TipoUbicacion.estacionamiento) {
      _drawParkingSign(
        canvas,
        _tilePoint(gN, gE, gS, gW, 0.76, 0.74),
        opacity: opacity,
      );
    }
    if (p.data != null) {
      _drawSign(
        canvas,
        p,
        anchor: _tilePoint(gN, gE, gS, gW, 0.5, 0.04).translate(0, -4),
        opacity: opacity,
        selected: selected,
      );
    }
  }

  void _drawPlazaFloorPattern(
    Canvas canvas,
    Offset gN,
    Offset gE,
    Offset gS,
    Offset gW,
    Color acc,
    double opacity,
  ) {
    final linePaint =
        Paint()
          ..color = Colors.white.withOpacity(0.040 * opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5;
    // Grid de adoquines
    for (int i = 1; i < 4; i++) {
      final f = i / 4.0;
      canvas.drawLine(
        Offset.lerp(gN, gW, f)!,
        Offset.lerp(gE, gS, f)!,
        linePaint,
      );
      canvas.drawLine(
        Offset.lerp(gN, gE, f)!,
        Offset.lerp(gW, gS, f)!,
        linePaint,
      );
    }
    // Diamante central decorativo
    final center = _tilePoint(gN, gE, gS, gW, 0.5, 0.5);
    final d0 = _tilePoint(gN, gE, gS, gW, 0.5, 0.2);
    final d1 = _tilePoint(gN, gE, gS, gW, 0.8, 0.5);
    final d2 = _tilePoint(gN, gE, gS, gW, 0.5, 0.8);
    final d3 = _tilePoint(gN, gE, gS, gW, 0.2, 0.5);
    canvas.drawPath(
      _path4(d0, d1, d2, d3),
      Paint()
        ..color = acc.withOpacity(0.10 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7,
    );
    // Punto central
    canvas.drawCircle(
      center,
      1.8,
      Paint()..color = acc.withOpacity(0.35 * opacity),
    );
  }

  // ── SENDERO ────────────────────────────────────────────────
  void _drawPathway(
    Canvas canvas,
    Offset gN,
    Offset gE,
    Offset gS,
    Offset gW,
    double opacity,
    int seed,
  ) {
    final rng = math.Random(seed);
    final paint =
        Paint()..color = const Color(0xFF252555).withOpacity(0.88 * opacity);
    if (rng.nextBool()) {
      canvas.drawPath(
        Path()
          ..moveTo(Offset.lerp(gN, gW, 0.35)!.dx, Offset.lerp(gN, gW, 0.35)!.dy)
          ..lineTo(Offset.lerp(gN, gE, 0.35)!.dx, Offset.lerp(gN, gE, 0.35)!.dy)
          ..lineTo(Offset.lerp(gS, gE, 0.65)!.dx, Offset.lerp(gS, gE, 0.65)!.dy)
          ..lineTo(Offset.lerp(gS, gW, 0.65)!.dx, Offset.lerp(gS, gW, 0.65)!.dy)
          ..close(),
        paint,
      );
    } else {
      canvas.drawPath(
        Path()
          ..moveTo(Offset.lerp(gN, gE, 0.35)!.dx, Offset.lerp(gN, gE, 0.35)!.dy)
          ..lineTo(Offset.lerp(gN, gE, 0.65)!.dx, Offset.lerp(gN, gE, 0.65)!.dy)
          ..lineTo(Offset.lerp(gS, gW, 0.65)!.dx, Offset.lerp(gS, gW, 0.65)!.dy)
          ..lineTo(Offset.lerp(gS, gW, 0.35)!.dx, Offset.lerp(gS, gW, 0.35)!.dy)
          ..close(),
        paint,
      );
    }
  }

  // ── ÁRBOL 3D ───────────────────────────────────────────────
  void _drawTree(
    Canvas canvas,
    Offset base, {
    required Color color,
    required double opacity,
    required double heightFactor,
    required int seed,
  }) {
    const trW = 3.5;
    final tH = 9.0 * heightFactor;
    final fR = 9.0 * heightFactor;
    final tot = tH + fR * 1.4;

    canvas.drawPath(
      _path4(
        base,
        base.translate(trW, -trW * 0.5),
        base.translate(trW, -trW * 0.5 - tot * 0.38),
        base.translate(0, -tot * 0.38),
      ),
      Paint()..color = const Color(0xFF5D4037).withOpacity(0.85 * opacity),
    );
    canvas.drawPath(
      _path4(
        base,
        base.translate(-trW, -trW * 0.5),
        base.translate(-trW, -trW * 0.5 - tot * 0.38),
        base.translate(0, -tot * 0.38),
      ),
      Paint()..color = const Color(0xFF4E342E).withOpacity(0.85 * opacity),
    );

    final fc = base.translate(0, -tot * 0.68);
    canvas.drawOval(
      Rect.fromCenter(center: fc, width: fR * 2.2, height: fR * 1.3),
      Paint()..color = color.withOpacity(0.90 * opacity),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: fc.translate(0, -fR * 0.1),
        width: fR * 1.3,
        height: fR * 0.8,
      ),
      Paint()
        ..color = Color.lerp(
          color,
          Colors.white,
          0.38,
        )!.withOpacity(0.68 * opacity),
    );
    final glow = math.sin(ambient * math.pi * 2 + seed.toDouble()) * 0.5 + 0.5;
    canvas.drawOval(
      Rect.fromCenter(center: fc, width: fR * 2.5, height: fR * 1.5),
      Paint()
        ..color = color.withOpacity(0.05 * glow * opacity)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 7),
    );
  }

  // ── BANCA PREMIUM ──────────────────────────────────────────
  void _drawPremiumBench(
    Canvas canvas,
    Offset base,
    Color accent, {
    required double opacity,
  }) {
    const bW = 12.0;
    const bH = 5.0;
    // Asiento
    canvas.drawPath(
      _path4(
        base,
        base.translate(bW, -bW * 0.5),
        base.translate(bW, -bW * 0.5 - 3),
        base.translate(0, -3),
      ),
      Paint()..color = const Color(0xFF8D6E63).withOpacity(0.88 * opacity),
    );
    // Respaldo
    canvas.drawPath(
      _path4(
        base.translate(0, -3),
        base.translate(bW, -bW * 0.5 - 3),
        base.translate(bW, -bW * 0.5 - 3 - bH),
        base.translate(0, -3 - bH),
      ),
      Paint()..color = const Color(0xFF795548).withOpacity(0.88 * opacity),
    );
    // Patas metálicas doradas
    for (final dx in [bW * 0.12, bW * 0.88]) {
      canvas.drawRect(
        Rect.fromLTWH(base.dx + dx, base.dy - 1.5, 1.8, 5),
        Paint()..color = accent.withOpacity(0.55 * opacity),
      );
    }
    // Detalle dorado en el borde del asiento
    canvas.drawLine(
      base.translate(0, -3),
      base.translate(bW, -bW * 0.5 - 3),
      Paint()
        ..color = accent.withOpacity(0.35 * opacity)
        ..strokeWidth = 0.8,
    );
  }

  // ── FUENTE PEQUEÑA ─────────────────────────────────────────
  void _drawSmallFountain(
    Canvas canvas,
    Offset base,
    Color accent, {
    required double opacity,
  }) {
    final pulse = math.sin(ambient * math.pi * 4) * 0.5 + 0.5;
    const r = 7.0;
    canvas.drawOval(
      Rect.fromCenter(center: base, width: r * 2.4, height: r * 1.2),
      Paint()..color = const Color(0xFF1A237E).withOpacity(0.85 * opacity),
    );
    canvas.drawOval(
      Rect.fromCenter(center: base, width: r * 2.4, height: r * 1.2),
      Paint()
        ..color = accent.withOpacity(0.32 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    canvas.drawOval(
      Rect.fromCenter(center: base, width: r * 1.5, height: r * 0.75),
      Paint()
        ..color = const Color(
          0xFF42A5F5,
        ).withOpacity((0.4 + pulse * 0.3) * opacity),
    );
    canvas.drawCircle(
      base,
      1.8 + pulse,
      Paint()
        ..color = Colors.white.withOpacity(0.8 * opacity)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 2),
    );
  }

  // ── QUIOSCO ────────────────────────────────────────────────
  void _drawKiosk(
    Canvas canvas,
    Offset base,
    Color accent, {
    required double opacity,
  }) {
    const kW = 15.0;
    const kH = 18.0;
    const rH = 7.0;
    canvas.drawPath(
      _path4(
        base,
        base.translate(kW, -kW * 0.5),
        base.translate(kW, -kW * 0.5 - kH),
        base.translate(0, -kH),
      ),
      Paint()
        ..color = Color.lerp(
          const Color(0xFF1A1A3C),
          accent,
          0.22,
        )!.withOpacity(opacity),
    );
    canvas.drawPath(
      _path4(
        base,
        base.translate(-kW, -kW * 0.5),
        base.translate(-kW, -kW * 0.5 - kH),
        base.translate(0, -kH),
      ),
      Paint()
        ..color = Color.lerp(
          const Color(0xFF111130),
          accent,
          0.18,
        )!.withOpacity(opacity),
    );
    canvas.drawPath(
      _path4(
        base.translate(0, -kH),
        base.translate(kW, -kW * 0.5 - kH),
        base.translate(kW, -kW * 0.5 - kH - rH),
        base.translate(0, -kH - rH),
      ),
      Paint()..color = accent.withOpacity(0.85 * opacity),
    );
    canvas.drawPath(
      _path4(
        base.translate(0, -kH),
        base.translate(-kW, -kW * 0.5 - kH),
        base.translate(-kW, -kW * 0.5 - kH - rH),
        base.translate(0, -kH - rH),
      ),
      Paint()
        ..color = Color.lerp(
          accent,
          Colors.white,
          0.22,
        )!.withOpacity(0.85 * opacity),
    );
    final glow = math.sin(ambient * math.pi * 2) * 0.5 + 0.5;
    canvas.drawRect(
      Rect.fromCenter(
        center: base.translate(kW * 0.55, -kW * 0.28 - kH * 0.5),
        width: 6,
        height: 5,
      ),
      Paint()
        ..color = const Color(
          0xFFFFEB3B,
        ).withOpacity((0.5 + glow * 0.4) * opacity),
    );
  }

  // ── SEÑAL DE PARKING ───────────────────────────────────────
  void _drawParkingSign(Canvas canvas, Offset base, {required double opacity}) {
    canvas.drawRect(
      Rect.fromCenter(center: base.translate(0, -9), width: 1.5, height: 14),
      Paint()..color = const Color(0xFF90A4AE).withOpacity(0.8 * opacity),
    );
    final r = Rect.fromCenter(
      center: base.translate(0, -18),
      width: 10,
      height: 8,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(1.5)),
      Paint()..color = const Color(0xFF1565C0).withOpacity(0.9 * opacity),
    );
    final pb =
        ui.ParagraphBuilder(ui.ParagraphStyle(textAlign: TextAlign.center))
          ..pushStyle(
            ui.TextStyle(
              color: Colors.white.withOpacity(opacity),
              fontSize: 6,
              fontWeight: FontWeight.w900,
            ),
          )
          ..addText('P');
    final para = pb.build()..layout(ui.ParagraphConstraints(width: 10));
    canvas.drawParagraph(para, Offset(r.left, r.top + 0.5));
  }

  // ── LETRERO ────────────────────────────────────────────────
  void _drawSign(
    Canvas canvas,
    PlazaData p, {
    required Offset anchor,
    required double opacity,
    required bool selected,
  }) {
    final name = p.data!.nombre;
    final acc = p.accent;
    final sc = selected ? 1.0 + selProg * 0.13 : 1.0;
    final dy = selected ? -selProg * 7.0 : 0.0;

    canvas.save();
    canvas.translate(anchor.dx, anchor.dy + dy - 20);
    canvas.scale(sc);

    const lW = _tW * 1.02;
    const lH = 17.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: lW, height: lH),
        const Radius.circular(8),
      ),
      Paint()
        ..color = Color.lerp(
          const Color(0xFF0C0C22),
          acc,
          0.24,
        )!.withOpacity(0.93 * opacity)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 3),
    );

    // Brillo superior del letrero
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(0, -lH * 0.3),
          width: lW * 0.8,
          height: lH * 0.25,
        ),
        const Radius.circular(4),
      ),
      Paint()..color = Colors.white.withOpacity(0.06 * opacity),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: lW, height: lH),
        const Radius.circular(8),
      ),
      Paint()
        ..color = acc.withOpacity(0.55 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    final pb =
        ui.ParagraphBuilder(
            ui.ParagraphStyle(textAlign: TextAlign.center, maxLines: 1),
          )
          ..pushStyle(
            ui.TextStyle(
              color: Colors.white.withOpacity(0.95 * opacity),
              fontSize: 9.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          )
          ..addText(name.length > 17 ? '${name.substring(0, 15)}…' : name);
    final para = pb.build()..layout(ui.ParagraphConstraints(width: lW));
    canvas.drawParagraph(para, Offset(-lW / 2, -lH / 2 + 3));

    canvas.restore();
  }

  // ── PARTÍCULAS AMBIENTALES (polvo de luz del mall) ─────────
  static final _rng0 = math.Random(99);
  static final _pts = List.generate(
    50,
    (i) => [
      _rng0.nextDouble() * 800 - 400,
      _rng0.nextDouble() * 600 - 280,
      _rng0.nextDouble() * 2.0 + 0.3,
      _rng0.nextDouble(),
      _rng0.nextInt(4).toDouble(),
    ],
  );
  static const _pColors = [_kGold, _kWarmLight, _kSkylight, Colors.white];

  void _drawAmbientParticles(Canvas canvas) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final p in _pts) {
      final phase = (ambient + p[3]) % 1.0;
      final alpha = math.sin(phase * math.pi) * 0.28;
      if (alpha <= 0) continue;
      paint.color = _pColors[p[4].toInt()].withOpacity(alpha * 0.55);
      final dy = p[1] - phase * 130;
      canvas.drawCircle(
        Offset(p[0], dy),
        p[2],
        Paint()
          ..color = _pColors[p[4].toInt()].withOpacity(alpha * 0.55)
          ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, p[2] * 0.8),
      );
    }
  }

  // ── HELPERS ────────────────────────────────────────────────
  Path _path4(Offset a, Offset b, Offset c, Offset d) =>
      Path()
        ..moveTo(a.dx, a.dy)
        ..lineTo(b.dx, b.dy)
        ..lineTo(c.dx, c.dy)
        ..lineTo(d.dx, d.dy)
        ..close();

  Offset _tilePoint(
    Offset gN,
    Offset gE,
    Offset gS,
    Offset gW,
    double u,
    double v,
  ) => Offset.lerp(Offset.lerp(gN, gE, u)!, Offset.lerp(gW, gS, u)!, v)!;

  @override
  bool shouldRepaint(MallWorldPainter o) =>
      o.ambient != ambient ||
      o.skylight != skylight ||
      o.selProg != selProg ||
      o.introProg != introProg ||
      o.selIdx != selIdx ||
      o.scale != scale ||
      o.pan != pan ||
      o.plazas.length != plazas.length;
}

// ══════════════════════════════════════════════════════════════
//  PLAZA DATA — Data class for plaza information
// ══════════════════════════════════════════════════════════════
class PlazaData {
  final MallSlot slot;
  final Plazoleta? data;
  final Color accent;
  final int index;
  final int seed;

  const PlazaData({
    required this.slot,
    required this.data,
    required this.accent,
    required this.index,
    required this.seed,
  });
}
