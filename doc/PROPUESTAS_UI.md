# Propuesta 3D

Primera versión con fallas en el fondo y ambientación:

```dart

// lib/presentation/pages/plazoletas/plazoleta_list_page.dart
//
// 🌳  PLAZA UNIVERSE v3 — Mall Isométrico 3D
// ────────────────────────────────────────────────────────────
//  FIXES en v3:
//  • Hit-test corregido (inversión precisa del canvas transform)
//  • Hit-test isométrico real (diamante, no rectángulo)
//  • Cuadrícula 12×12 con plazas separadas cada 3 tiles
//  • Fondo de centro comercial: mármol, columnas, luces, plantas
//  • Columnas 3D en intersecciones de pasillos
//  • Luces de techo animadas (cono sobre el suelo)
//  • Vitrinas / fachadas de tiendas en los pasillos
// ────────────────────────────────────────────────────────────

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../di/service_locator.dart';
import '../../../domain/entities/plazoleta.dart';
import '../../blocs/plazoleta/plazoleta_bloc.dart';
import '../../blocs/plazoleta/plazoleta_event.dart';
import '../../blocs/plazoleta/plazoleta_state.dart';
import '../../widgets/profile_floating_button.dart';

// ══════════════════════════════════════════════════════════════
//  CONSTANTES
// ══════════════════════════════════════════════════════════════
const _kGold = Color(0xFFD4AF37);
const _kGoldGlow = Color(0xFFFFE082);
const _kBg = Color(0xFF05050D);

// Tamaño del tile isométrico (más grande = más espacio)
const double _tW = 110.0;
const double _tH = 55.0;
const double _pH = 14.0; // altura plataforma

// Offset Y que el painter aplica (necesario para invertir en _screenToWorld)
const double _kOriginOffsetY = 60.0;

// ══════════════════════════════════════════════════════════════
//  MODELOS
// ══════════════════════════════════════════════════════════════
class _Slot {
  final int col, row;
  const _Slot(this.col, this.row);
}

class _Plaza {
  final _Slot slot;
  final Plazoleta? data;
  final Color accent;
  final int index;
  final int seed;
  const _Plaza({
    required this.slot,
    required this.data,
    required this.accent,
    required this.index,
    required this.seed,
  });
}

// ══════════════════════════════════════════════════════════════
//  LAYOUT  — cuadrícula 12×12, plazas separadas ~3 tiles
//  Atrio central en cols 4-7, rows 4-7
// ══════════════════════════════════════════════════════════════
const _slots = <_Slot>[
  // Esquinas y bordes exteriores
  _Slot(0, 0), _Slot(4, 0), _Slot(8, 0), _Slot(12, 0),
  _Slot(0, 4), _Slot(12, 4),
  _Slot(0, 8), _Slot(12, 8),
  _Slot(0, 12), _Slot(4, 12), _Slot(8, 12), _Slot(12, 12),
  // Interior (entre el anillo exterior y el atrio)
  _Slot(2, 2), _Slot(6, 2), _Slot(10, 2),
  _Slot(2, 6), _Slot(10, 6),
  _Slot(2, 10), _Slot(6, 10), _Slot(10, 10),
];

// El atrio ocupa cols 4–7, rows 4–7
bool _isAtrium(int c, int r) => c >= 4 && c <= 7 && r >= 4 && r <= 7;

// Columnas decorativas en las intersecciones de pasillos
const _columnPositions = <_Slot>[
  _Slot(3, 3),
  _Slot(9, 3),
  _Slot(3, 9),
  _Slot(9, 9),
];

const _accents = <Color>[
  Color(0xFF4CAF50),
  Color(0xFF26A69A),
  Color(0xFF42A5F5),
  Color(0xFFAB47BC),
  Color(0xFF26C6DA),
  Color(0xFF9CCC65),
  Color(0xFFEF5350),
  Color(0xFFFF7043),
  Color(0xFF8D6E63),
  Color(0xFF78909C),
  Color(0xFF5C6BC0),
  Color(0xFFEC407A),
  Color(0xFF29B6F6),
  Color(0xFF66BB6A),
  Color(0xFFD4E157),
  Color(0xFFFFCA28),
  Color(0xFFFFA726),
  Color(0xFF26A69A),
  Color(0xFFAB47BC),
  Color(0xFF42A5F5),
];

// ══════════════════════════════════════════════════════════════
//  PROVIDER
// ══════════════════════════════════════════════════════════════
class PlazoletaBlocProvider extends StatelessWidget {
  final Widget child;
  const PlazoletaBlocProvider({super.key, required this.child});
  @override
  Widget build(BuildContext context) => BlocProvider<PlazoletaBloc>.value(
    value: getIt<PlazoletaBloc>(),
    child: child,
  );
}

// ══════════════════════════════════════════════════════════════
//  PÁGINA PRINCIPAL
// ══════════════════════════════════════════════════════════════
class PlazoletaListPage extends StatefulWidget {
  const PlazoletaListPage({super.key});
  @override
  State<PlazoletaListPage> createState() => _PlazoletaListPageState();
}

class _PlazoletaListPageState extends State<PlazoletaListPage>
    with TickerProviderStateMixin {
  AnimationController? _ambientCtrl;
  AnimationController? _selectCtrl;
  AnimationController? _panelCtrl;
  AnimationController? _introCtrl;
  AnimationController? _inertiaCtrl;
  bool _initialized = false;

  // Navegación
  double _scale = 0.72;
  Offset _pan = Offset.zero;
  double _baseSc = 0.72;
  Offset _basePan = Offset.zero;
  Offset _focal = Offset.zero;
  Offset _velocity = Offset.zero;
  DateTime _lastPanTime = DateTime.now();

  // Estado
  int? _selectedIdx;
  List<_Plaza> _plazas = [];

  static const double _initScale = 0.72;

  @override
  void initState() {
    super.initState();
    _ambientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
    _selectCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _panelCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _introCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..forward();
    _inertiaCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _inertiaCtrl!.addListener(_applyInertia);
    _initialized = true;
    getIt<PlazoletaBloc>().add(const LoadPlazoletasActivas(page: 1, limit: 20));
  }

  @override
  void dispose() {
    _ambientCtrl?.dispose();
    _selectCtrl?.dispose();
    _panelCtrl?.dispose();
    _introCtrl?.dispose();
    _inertiaCtrl?.dispose();
    super.dispose();
  }

  void _buildPlazas(List<Plazoleta> list) {
    _plazas =
        _slots
            .asMap()
            .entries
            .map(
              (e) => _Plaza(
                slot: e.value,
                data: e.key < list.length ? list[e.key] : null,
                accent: _accents[e.key % _accents.length],
                index: e.key,
                seed: e.key * 137 + 42,
              ),
            )
            .toList();
  }

  // ── Selección ──────────────────────────────────────────────
  void _select(int idx) {
    HapticFeedback.lightImpact();
    final same = _selectedIdx == idx;
    setState(() => _selectedIdx = same ? null : idx);
    if (same) {
      _selectCtrl?.reverse();
      _panelCtrl?.reverse();
    } else {
      _selectCtrl?.forward(from: 0);
      _panelCtrl?.forward(from: 0);
    }
  }

  void _deselect() {
    if (_selectedIdx == null) return;
    setState(() => _selectedIdx = null);
    _selectCtrl?.reverse();
    _panelCtrl?.reverse();
  }

  // ── Zoom hacia el punto de pellizco ───────────────────────
  void _onScaleStart(ScaleStartDetails d) {
    _inertiaCtrl?.stop();
    _baseSc = _scale;
    _basePan = _pan;
    _focal = d.localFocalPoint;
    _velocity = Offset.zero;
    _lastPanTime = DateTime.now();
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    final now = DateTime.now();
    final dt = now.difference(_lastPanTime).inMilliseconds;

    setState(() {
      final newScale = (_baseSc * d.scale).clamp(0.30, 3.2);

      if (d.scale != 1.0) {
        // ZOOM: mantener el punto focal fijo
        final ratio = newScale / _baseSc;
        _pan = _focal - (_focal - _basePan) * ratio + d.focalPointDelta;
      } else {
        // PAN puro con 1 dedo: acumular delta directamente
        _pan = _basePan + (d.localFocalPoint - _focal);
      }

      _scale = newScale;
    });

    // Velocidad solo en pan puro
    if (dt > 0 && d.scale == 1.0) {
      _velocity = d.focalPointDelta / dt.toDouble() * 16;
    }
    _lastPanTime = now;
  }

  void _onScaleEnd(ScaleEndDetails _) {
    if (_velocity.distance > 0.5) {
      _inertiaCtrl?.forward(from: 0);
    }
  }

  void _applyInertia() {
    if (_inertiaCtrl == null) return;
    // decay va de 1.0 → 0.0 mientras el controlador va 0 → 1
    final decay = 1.0 - Curves.decelerate.transform(_inertiaCtrl!.value);
    setState(() => _pan += _velocity * decay);
  }

  // ── Tap → hit test ─────────────────────────────────────────
  void _onTapUp(TapUpDetails d) {
    final sz = context.size ?? Size.zero;
    final world = _screenToWorld(d.localPosition, sz);
    int? hit;
    // Iterar en orden inverso al de pintura (adelante → atrás)
    final sorted = [..._plazas]..sort(
      (a, b) => (b.slot.col + b.slot.row).compareTo(a.slot.col + a.slot.row),
    );
    for (final p in sorted) {
      if (_hitTestPlaza(p, world)) {
        hit = p.index;
        break;
      }
    }
    if (hit != null)
      _select(hit);
    else
      _deselect();
  }

  /// Convierte coordenadas de pantalla → coordenadas del mundo (painter)
  /// Debe invertir exactamente: canvas.translate(cx, cy) + canvas.scale(scale)
  /// donde cx = size.width/2 + pan.dx
  ///       cy = size.height/2 + pan.dy + _kOriginOffsetY
  Offset _screenToWorld(Offset screen, Size size) => Offset(
    (screen.dx - size.width / 2 - _pan.dx) / _scale,
    (screen.dy - size.height / 2 - _pan.dy - _kOriginOffsetY) / _scale,
  );

  /// Hit-test isométrico real: verifica si `world` está dentro del
  /// diamante isométrico del tile (col, row) + área vertical de la plaza
  bool _hitTestPlaza(_Plaza p, Offset world) {
    final c = p.slot.col.toDouble();
    final r = p.slot.row.toDouble();
    final elev =
        (p.index == _selectedIdx) ? (_selectCtrl?.value ?? 0) * 22.0 : 0.0;

    // Centro de la cara superior del tile (en coordenadas de mundo)
    final cx = (c + 0.5 - (r + 0.5)) * _tW / 2; // = (c - r) * _tW / 2
    final cy =
        (c + 0.5 + (r + 0.5)) * _tH / 2 -
        elev; // = (c + r + 1) * _tH / 2 - elev

    // Distancias normalizadas en el espacio isométrico
    final ndx = (world.dx - cx).abs() / (_tW / 2);
    final ndy = (world.dy - cy).abs() / (_tH / 2);

    // 1) Dentro del diamante del piso del tile (con margen)
    final inFloor = ndx + ndy <= 1.15;

    // 2) Área vertical encima del tile (para árboles, letrero, etc.)
    //    — ancho restringido, altura desde la plataforma hasta ~80px arriba
    final inVolume =
        ndx <= 0.75 && world.dy >= cy - _pH - 80 && world.dy <= cy + _tH / 2;

    return inFloor || inVolume;
  }

  void _resetView() {
    _inertiaCtrl?.stop();
    setState(() {
      _scale = _initScale;
      _pan = Offset.zero;
    });
    _deselect();
  }

  Future<void> _onRefresh() async {
    _deselect();
    setState(() => _plazas = []);
    getIt<PlazoletaBloc>().add(
      const LoadPlazoletasActivas(page: 1, limit: 20, forceRefresh: true),
    );
  }

  void _goToDetail(int id) => context.go('/plazoletas/$id');

  // ══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    if (!_initialized)
      return const Scaffold(
        backgroundColor: _kBg,
        body: Center(
          child: CircularProgressIndicator(color: _kGold, strokeWidth: 2),
        ),
      );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _kBg,
        body: BlocConsumer<PlazoletaBloc, PlazoletaState>(
          bloc: getIt<PlazoletaBloc>(),
          listener: (_, s) {
            if (s is PlazoletaLoaded)
              setState(() => _buildPlazas(s.plazoletas));
          },
          builder: (_, s) {
            if (s is PlazoletaLoading || _plazas.isEmpty) return _loading();
            if (s is PlazoletaErrorState) return _error(s);
            return _mainView(s as PlazoletaLoaded);
          },
        ),
      ),
    );
  }

  Widget _mainView(PlazoletaLoaded state) {
    final sel =
        _selectedIdx != null
            ? _plazas.firstWhere(
              (p) => p.index == _selectedIdx,
              orElse: () => _plazas.first,
            )
            : null;
    final hasPanel = sel != null;

    return Stack(
      children: [
        // ── Canvas 3D ─────────────────────────────────────────
        GestureDetector(
          onScaleStart: _onScaleStart,
          onScaleUpdate: _onScaleUpdate,
          onScaleEnd: _onScaleEnd,
          onTapUp: _onTapUp,
          child: SizedBox.expand(
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _ambientCtrl!,
                _selectCtrl!,
                _introCtrl!,
              ]),
              builder:
                  (_, __) => CustomPaint(
                    painter: _WorldPainter(
                      plazas: _plazas,
                      selIdx: _selectedIdx,
                      ambient: _ambientCtrl!.value,
                      selProg: _selectCtrl!.value,
                      introProg: _introCtrl!.value,
                      scale: _scale,
                      pan: _pan,
                    ),
                  ),
            ),
          ),
        ),

        // ── Header ────────────────────────────────────────────
        _header(state),

        // ── Controles de mapa ─────────────────────────────────
        _mapControls(),

        // ── Panel de detalle ──────────────────────────────────
        if (hasPanel)
          AnimatedBuilder(
            animation: _panelCtrl!,
            builder: (_, __) {
              final t =
                  CurvedAnimation(
                    parent: _panelCtrl!,
                    curve: Curves.easeOutCubic,
                  ).value;
              return Positioned(
                bottom: (1 - t) * -300,
                left: 0,
                right: 0,
                child: _DetailPanel(
                  plaza: sel!,
                  state: state,
                  onClose: () => _select(sel.index),
                  onEnter: () {
                    if (sel.data != null) _goToDetail(sel.data!.id);
                  },
                ),
              );
            },
          ),

        // ── FAB perfil ─────────────────────────────────────────
        Positioned(
          bottom: hasPanel ? 295 : 24,
          right: 22,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: ProfileFloatingButton(size: 54, backgroundColor: _kGold),
          ),
        ),

        // ── Hint ───────────────────────────────────────────────
        _hint(),
      ],
    );
  }

  // ── WIDGETS UI ─────────────────────────────────────────────

  Widget _header(PlazoletaLoaded state) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + 10,
              20,
              14,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_kBg.withOpacity(0.95), _kBg.withOpacity(0.0)],
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback:
                            (b) => const LinearGradient(
                              colors: [
                                Color(0xFF9C7A1A),
                                _kGold,
                                Color(0xFFFFE082),
                              ],
                            ).createShader(b),
                        child: const Text(
                          'PLAZA UNIVERSE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Poppins',
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: _kGold,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            '${state.plazoletas.length} plazoletas  •  explora el mall',
                            style: TextStyle(
                              color: _kGold.withOpacity(0.65),
                              fontSize: 11,
                              letterSpacing: 1.4,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _iconBtn(Icons.refresh_rounded, _onRefresh),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _mapControls() {
    return Positioned(
      right: 14,
      top: MediaQuery.of(context).padding.top + 80,
      child: Column(
        children: [
          _mapBtn(
            Icons.add,
            () => setState(() => _scale = (_scale * 1.22).clamp(0.30, 3.2)),
          ),
          const SizedBox(height: 5),
          _mapBtn(
            Icons.remove,
            () => setState(() => _scale = (_scale / 1.22).clamp(0.30, 3.2)),
          ),
          const SizedBox(height: 10),
          _mapBtn(Icons.center_focus_strong_rounded, _resetView, accent: true),
        ],
      ),
    );
  }

  Widget _mapBtn(IconData icon, VoidCallback onTap, {bool accent = false}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          margin: const EdgeInsets.only(bottom: 1),
          decoration: BoxDecoration(
            color:
                accent
                    ? _kGold.withOpacity(0.18)
                    : const Color(0xFF10102A).withOpacity(0.9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _kGold.withOpacity(accent ? 0.5 : 0.22)),
          ),
          child: Icon(icon, color: _kGold, size: 17),
        ),
      );

  Widget _iconBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: const Color(0xFF10102A).withOpacity(0.85),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: _kGold.withOpacity(0.22)),
      ),
      child: Icon(icon, color: _kGold, size: 18),
    ),
  );

  Widget _hint() {
    return AnimatedBuilder(
      animation: _introCtrl!,
      builder: (_, __) {
        final t = _introCtrl!.value;
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
                  color: Colors.black.withOpacity(0.72),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: _kGold.withOpacity(0.4)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.touch_app_rounded, color: _kGold, size: 14),
                    SizedBox(width: 8),
                    Text(
                      'Toca una plaza  •  Pellizca para zoom',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontFamily: 'Poppins',
                      ),
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

  Widget _loading() => Container(
    color: _kBg,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(_kGold),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Construyendo el mall…',
            style: TextStyle(
              color: _kGold.withOpacity(0.8),
              fontFamily: 'Poppins',
              fontSize: 13,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _error(PlazoletaErrorState s) => Container(
    color: _kBg,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            color: Colors.red.withOpacity(0.6),
            size: 54,
          ),
          const SizedBox(height: 14),
          Text(
            s.message.isNotEmpty ? s.message : 'Error de conexión',
            style: const TextStyle(
              color: Colors.white60,
              fontFamily: 'Poppins',
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 22),
          GestureDetector(
            onTap: _onRefresh,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9C7A1A), _kGold, Color(0xFFFFE082)],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                'Reintentar',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ══════════════════════════════════════════════════════════════
//  PAINTER: MUNDO ISOMÉTRICO
// ══════════════════════════════════════════════════════════════
class _WorldPainter extends CustomPainter {
  final List<_Plaza> plazas;
  final int? selIdx;
  final double ambient, selProg, introProg, scale;
  final Offset pan;

  const _WorldPainter({
    required this.plazas,
    required this.selIdx,
    required this.ambient,
    required this.selProg,
    required this.introProg,
    required this.scale,
    required this.pan,
  });

  // ISO: tile (col, row, elev) → coordenadas relativas al origen del canvas
  Offset _iso(double c, double r, {double elev = 0}) =>
      Offset((c - r) * _tW / 2, (c + r) * _tH / 2 - elev);

  @override
  void paint(Canvas canvas, Size size) {
    // Origen del canvas: mismo que se invierte en _screenToWorld
    final cx = size.width / 2 + pan.dx;
    final cy = size.height / 2 + pan.dy + _kOriginOffsetY;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(scale);

    // --- capas de fondo (de más lejana a más cercana) ---
    _drawMallFloor(canvas, size);
    _drawCeilingLights(canvas, size);
    _drawColumns(canvas);
    _drawCorridorDetails(canvas);
    _drawAtrium(canvas);

    // --- plazoletas (ordenadas por Z) ---
    final sorted = [...plazas]..sort(
      (a, b) => (a.slot.col + a.slot.row).compareTo(b.slot.col + b.slot.row),
    );
    for (final p in sorted) {
      final isSel = p.index == selIdx;
      final elev = isSel ? selProg * 22.0 : 0.0;
      final fade = ((introProg - p.index * 0.032) * 5.0).clamp(0.0, 1.0);
      _drawPlaza(canvas, p, elev: elev, opacity: fade, selected: isSel);
    }

    _drawLightRays(canvas, size);
    _drawParticles(canvas);

    canvas.restore();
  }

  // ══════════════════════════════════════════════════════════
  //  SUELO DE CENTRO COMERCIAL
  // ══════════════════════════════════════════════════════════
  void _drawMallFloor(Canvas canvas, Size size) {
    // Grilla de -2 a 15 para cubrir el viewport en cualquier zoom/pan
    for (int r = -2; r <= 15; r++) {
      for (int c = -2; c <= 15; c++) {
        final tl = _iso(c.toDouble(), r.toDouble());
        final tr = _iso(c + 1.0, r.toDouble());
        final br = _iso(c + 1.0, r + 1.0);
        final bl = _iso(c.toDouble(), r + 1.0);
        final tilePath = _path4(tl, tr, br, bl);

        final isAtr = _isAtrium(c, r);
        final isPlaza = _slots.any((s) => s.col == c && s.row == r);

        Color tileColor;
        if (isAtr) {
          tileColor = const Color(0xFF0A0A1E);
        } else if (isPlaza) {
          tileColor = const Color(0xFF0D0D22); // tapado por la plazoleta
        } else {
          // Pasillos: patrón de mármol bicolor (tablero ajedrez 2×2)
          final big = (c ~/ 2 + r ~/ 2) % 2 == 0;
          tileColor = big ? const Color(0xFF121230) : const Color(0xFF10102A);
        }

        canvas.drawPath(tilePath, Paint()..color = tileColor);

        // Grout lines del mármol
        if (!isAtr && !isPlaza) {
          canvas.drawPath(
            tilePath,
            Paint()
              ..color = const Color(0xFF1E1E45)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.6,
          );

          // Líneas de diseño dentro de cada mosaico 2×2
          if (c % 2 == 0 && r % 2 == 0) {
            // Diagonal decorativa
            final center = Offset(
              (tl.dx + br.dx) / 2 + (_tW) / 2,
              (tl.dy + br.dy) / 2,
            );
            final tl2 = _iso(c.toDouble(), r.toDouble());
            final br2 = _iso(c + 2.0, r + 2.0);
            final tr2 = _iso(c + 2.0, r.toDouble());
            final bl2 = _iso(c.toDouble(), r + 2.0);
            canvas.drawLine(
              tl2,
              br2,
              Paint()
                ..color = const Color(0xFF242460)
                ..strokeWidth = 0.4,
            );
            canvas.drawLine(
              tr2,
              bl2,
              Paint()
                ..color = const Color(0xFF242460)
                ..strokeWidth = 0.4,
            );
            // Rombo central decorativo
            canvas.drawOval(
              Rect.fromCenter(center: center, width: 6, height: 3),
              Paint()..color = const Color(0xFF2A2A55),
            );
          }
        }
      }
    }

    // Borde dorado alrededor del atrio
    final atrPath =
        Path()
          ..moveTo(_iso(4, 4).dx, _iso(4, 4).dy)
          ..lineTo(_iso(8, 4).dx, _iso(8, 4).dy)
          ..lineTo(_iso(8, 8).dx, _iso(8, 8).dy)
          ..lineTo(_iso(4, 8).dx, _iso(4, 8).dy)
          ..close();
    canvas.drawPath(
      atrPath,
      Paint()
        ..color = _kGold.withOpacity(0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  // ══════════════════════════════════════════════════════════
  //  LUCES DE TECHO (conos de luz sobre el suelo)
  // ══════════════════════════════════════════════════════════
  void _drawCeilingLights(Canvas canvas, Size size) {
    // Luces en los cruces de pasillos principales
    const lightPositions = [
      [2.0, 0.0],
      [6.0, 0.0],
      [10.0, 0.0],
      [0.0, 2.0],
      [12.0, 2.0],
      [0.0, 6.0],
      [12.0, 6.0],
      [0.0, 10.0],
      [12.0, 10.0],
      [2.0, 12.0],
      [6.0, 12.0],
      [10.0, 12.0],
      [3.0, 3.0],
      [9.0, 3.0],
      [3.0, 9.0],
      [9.0, 9.0],
      [6.0, 1.5],
      [6.0, 10.5],
      [1.5, 6.0],
      [10.5, 6.0],
    ];

    final pulse = math.sin(ambient * math.pi * 2) * 0.5 + 0.5;

    for (int i = 0; i < lightPositions.length; i++) {
      final lp = lightPositions[i];
      final center = _iso(lp[0], lp[1]);
      final phase = (ambient + i * 0.07) % 1.0;
      final flicker = math.sin(phase * math.pi * 8 + i) * 0.06 + 0.94;
      final r = (24 + pulse * 4) * flicker;
      final op = 0.055 * flicker;

      canvas.drawOval(
        Rect.fromCenter(center: center, width: r * 2.2, height: r * 1.1),
        Paint()
          ..color = const Color(0xFFFFE8A0).withOpacity(op)
          ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, 14),
      );
      // Punto central más brillante
      canvas.drawCircle(
        center,
        2.5 * flicker,
        Paint()..color = const Color(0xFFFFFFCC).withOpacity(0.35 * flicker),
      );
    }
  }

  // ══════════════════════════════════════════════════════════
  //  COLUMNAS 3D EN INTERSECCIONES
  // ══════════════════════════════════════════════════════════
  void _drawColumns(Canvas canvas) {
    for (final s in _columnPositions) {
      _drawColumn(canvas, s.col.toDouble(), s.row.toDouble());
    }
  }

  void _drawColumn(Canvas canvas, double c, double r) {
    const cW = 5.0; // semiancho de la columna
    const cH = 55.0; // altura de la columna

    final base = _iso(c + 0.5, r + 0.5); // centro del tile

    // Base (plinto) — cara derecha
    canvas.drawPath(
      _path4(
        base.translate(cW, -cW * 0.5),
        base.translate(cW, -cW * 0.5 - 6),
        base.translate(0, -6),
        base.translate(0, 0),
      ),
      Paint()..color = const Color(0xFF1E1E50),
    );

    // Base — cara izquierda
    canvas.drawPath(
      _path4(
        base.translate(-cW, -cW * 0.5),
        base.translate(-cW, -cW * 0.5 - 6),
        base.translate(0, -6),
        base.translate(0, 0),
      ),
      Paint()..color = const Color(0xFF18184A),
    );

    // Fuste derecho
    canvas.drawPath(
      _path4(
        base.translate(cW, -cW * 0.5 - 6),
        base.translate(cW, -cW * 0.5 - 6 - cH),
        base.translate(0, -6 - cH),
        base.translate(0, -6),
      ),
      Paint()..color = const Color(0xFF22224E),
    );

    // Fuste izquierdo
    canvas.drawPath(
      _path4(
        base.translate(-cW, -cW * 0.5 - 6),
        base.translate(-cW, -cW * 0.5 - 6 - cH),
        base.translate(0, -6 - cH),
        base.translate(0, -6),
      ),
      Paint()..color = const Color(0xFF1A1A46),
    );

    // Capitel (cara superior)
    canvas.drawPath(
      _path4(
        base.translate(-cW * 1.3, -cH - 6 - cW * 0.65),
        base.translate(cW * 1.3, -cH - 6 - cW * 0.65),
        base.translate(cW * 1.3, -cH - 6 - cW * 0.65 - 5),
        base.translate(-cW * 1.3, -cH - 6 - cW * 0.65 - 5),
      ),
      Paint()..color = const Color(0xFF2E2E70),
    );

    // Detalle dorado en el capitel
    canvas.drawPath(
      _path4(
        base.translate(-cW * 1.3, -cH - 6 - cW * 0.65 - 5),
        base.translate(cW * 1.3, -cH - 6 - cW * 0.65 - 5),
        base.translate(cW, -cH - 6 - cW * 0.5 - 8),
        base.translate(-cW, -cH - 6 - cW * 0.5 - 8),
      ),
      Paint()..color = _kGold.withOpacity(0.45),
    );

    // Halo de luz en la base de la columna
    canvas.drawOval(
      Rect.fromCenter(center: base, width: 28, height: 14),
      Paint()
        ..color = _kGold.withOpacity(0.07)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 8),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  DETALLES DE PASILLOS (plantas, vitrinas, bancos)
  // ══════════════════════════════════════════════════════════
  void _drawCorridorDetails(Canvas canvas) {
    // Plantas en los pasillos principales
    const plantPositions = [
      [1.5, 1.5],
      [10.5, 1.5],
      [1.5, 10.5],
      [10.5, 10.5],
      [5.5, 1.0],
      [6.5, 1.0],
      [5.5, 11.0],
      [6.5, 11.0],
      [1.0, 5.5],
      [1.0, 6.5],
      [11.0, 5.5],
      [11.0, 6.5],
    ];

    for (final pp in plantPositions) {
      final pos = _iso(pp[0], pp[1]);
      _drawCorridorPlant(canvas, pos);
    }

    // Vitrinas/fachadas en las paredes de los pasillos
    _drawStoreWindows(canvas);
  }

  void _drawCorridorPlant(Canvas canvas, Offset base) {
    // Maceta
    canvas.drawPath(
      _path4(
        base.translate(-5, 0),
        base.translate(5, -2.5),
        base.translate(5, -2.5 - 8),
        base.translate(-5, 0 - 8),
      ),
      Paint()..color = const Color(0xFF5D4037).withOpacity(0.8),
    );

    // Tierra
    canvas.drawOval(
      Rect.fromCenter(center: base.translate(0, -8), width: 10, height: 5),
      Paint()..color = const Color(0xFF3E2723).withOpacity(0.9),
    );

    // Hojas (cono verde)
    for (int i = 0; i < 3; i++) {
      final angle = i * math.pi * 2 / 3 + ambient * math.pi * 0.5;
      final dx = math.cos(angle) * 5;
      final dy = math.sin(angle) * 2.5 - 14 - i * 4.0;
      canvas.drawOval(
        Rect.fromCenter(center: base.translate(dx, dy), width: 8, height: 6),
        Paint()..color = const Color(0xFF2E7D32).withOpacity(0.85),
      );
    }
    canvas.drawOval(
      Rect.fromCenter(center: base.translate(0, -22), width: 7, height: 5),
      Paint()..color = const Color(0xFF4CAF50).withOpacity(0.9),
    );
  }

  void _drawStoreWindows(Canvas canvas) {
    // Fachadas simples a lo largo de los bordes del mapa
    // (solo decoración, no interactivas)
    const facades = [
      [0.0, 2.0, false],
      [0.0, 5.0, false],
      [0.0, 8.0, false],
      [12.0, 2.0, true],
      [12.0, 5.0, true],
      [12.0, 8.0, true],
    ];
    const facadeColors = [
      Color(0xFF1A237E),
      Color(0xFF4A148C),
      Color(0xFF1B5E20),
      Color(0xFF880E4F),
      Color(0xFF0D47A1),
      Color(0xFF4E342E),
    ];

    for (int i = 0; i < facades.length; i++) {
      final f = facades[i];
      final isEast = f[2] as bool;
      final base = _iso(f[0] as double, f[1] as double);
      final color = facadeColors[i % facadeColors.length];
      _drawFacade(canvas, base, color, isEast: isEast);
    }
  }

  void _drawFacade(
    Canvas canvas,
    Offset base,
    Color color, {
    bool isEast = false,
  }) {
    const fW = 16.0;
    const fH = 30.0;
    final sign = isEast ? -1.0 : 1.0;

    // Pared principal
    canvas.drawPath(
      _path4(
        base,
        base.translate(sign * fW, -fW * 0.5),
        base.translate(sign * fW, -fW * 0.5 - fH),
        base.translate(0, -fH),
      ),
      Paint()..color = color.withOpacity(0.6),
    );

    // Ventana iluminada
    final glow = math.sin(ambient * math.pi * 2) * 0.5 + 0.5;
    final winBase = base.translate(sign * fW * 0.4, -fW * 0.2 - fH * 0.4);
    canvas.drawRect(
      Rect.fromCenter(center: winBase, width: 7, height: 9),
      Paint()..color = const Color(0xFFFFEB3B).withOpacity(0.4 + glow * 0.35),
    );
    canvas.drawRect(
      Rect.fromCenter(center: winBase, width: 9, height: 11),
      Paint()
        ..color = const Color(0xFFFFEB3B).withOpacity(0.08 * glow)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 5),
    );

    // Borde de la fachada
    canvas.drawPath(
      _path4(
        base,
        base.translate(sign * fW, -fW * 0.5),
        base.translate(sign * fW, -fW * 0.5 - fH),
        base.translate(0, -fH),
      ),
      Paint()
        ..color = color.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
  }

  // ══════════════════════════════════════════════════════════
  //  ATRIO CENTRAL
  // ══════════════════════════════════════════════════════════
  void _drawAtrium(Canvas canvas) {
    final tl = _iso(4, 4);
    final tr = _iso(8, 4);
    final br = _iso(8, 8);
    final bl = _iso(4, 8);

    canvas.drawPath(
      _path4(tl, tr, br, bl),
      Paint()
        ..shader = RadialGradient(
          colors: [const Color(0xFF14143A), const Color(0xFF08081E)],
        ).createShader(Rect.fromPoints(tl, br)),
    );

    // Reflejo animado
    final sh = math.sin(ambient * math.pi * 2) * 0.5 + 0.5;
    canvas.drawPath(
      _path4(tl, tr, br, bl),
      Paint()..color = const Color(0xFF4080FF).withOpacity(0.025 + sh * 0.03),
    );

    // Líneas de cristal / cúpula
    final lp =
        Paint()
          ..color = const Color(0x1A64B4FF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9;
    for (int i = 1; i < 4; i++) {
      final f = i / 4.0;
      canvas.drawLine(Offset.lerp(tl, br, f)!, Offset.lerp(tr, bl, f)!, lp);
      canvas.drawLine(Offset.lerp(tl, bl, f)!, Offset.lerp(tr, br, f)!, lp);
    }
    canvas.drawPath(
      _path4(tl, tr, br, bl),
      Paint()
        ..color = const Color(0x2864B4FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3,
    );

    _drawCentralFountain(canvas, _iso(6.0, 6.0));
  }

  void _drawCentralFountain(Canvas canvas, Offset center) {
    final pulse = math.sin(ambient * math.pi * 4) * 0.5 + 0.5;

    // Cuenco de la fuente
    canvas.drawOval(
      Rect.fromCenter(center: center, width: _tW * 0.9, height: _tH * 0.9),
      Paint()..color = const Color(0xFF1A2A60),
    );
    canvas.drawOval(
      Rect.fromCenter(center: center, width: _tW * 0.9, height: _tH * 0.9),
      Paint()
        ..color = const Color(0xFF3060C0).withOpacity(0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    // Agua con anillos
    for (int i = 1; i <= 3; i++) {
      final fr = i / 3.0;
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: _tW * 0.85 * fr,
          height: _tH * 0.85 * fr,
        ),
        Paint()
          ..color = const Color(
            0xFF60A0FF,
          ).withOpacity((1 - fr) * (0.22 + pulse * 0.15))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9,
      );
    }

    // Chorro
    canvas.drawCircle(
      center,
      3.5 + pulse * 2,
      Paint()..color = const Color(0xFF80C0FF).withOpacity(0.65 + pulse * 0.3),
    );
    canvas.drawCircle(
      center,
      1.8 + pulse,
      Paint()
        ..color = Colors.white.withOpacity(0.9)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 2),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  PLAZOLETA COMPLETA
  // ══════════════════════════════════════════════════════════
  void _drawPlaza(
    Canvas canvas,
    _Plaza p, {
    required double elev,
    required double opacity,
    required bool selected,
  }) {
    if (opacity <= 0) return;
    final c = p.slot.col.toDouble();
    final r = p.slot.row.toDouble();
    final rng = math.Random(p.seed);
    final acc = p.accent;

    // Vértices del piso (top face de la plataforma)
    final gN = _iso(c, r, elev: elev);
    final gE = _iso(c + 1, r, elev: elev);
    final gS = _iso(c + 1, r + 1, elev: elev);
    final gW = _iso(c, r + 1, elev: elev);

    // Vértices de la base de la plataforma (abajo)
    final bN = gN.translate(0, _pH);
    final bE = gE.translate(0, _pH);
    final bS = gS.translate(0, _pH);
    final bW = gW.translate(0, _pH);

    // ── Lados de la plataforma (zócalo) ──────────────────────
    canvas.drawPath(
      _path4(gE, bE, bS, gS),
      Paint()
        ..color = Color.lerp(
          const Color(0xFF1C1C44),
          acc,
          0.16,
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
    // Borde dorado en el zócalo
    canvas.drawPath(
      _path4(gE, bE, bS, gS),
      Paint()
        ..color = acc.withOpacity(0.15 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7,
    );

    // ── Piso de la plaza ──────────────────────────────────────
    canvas.drawPath(
      _path4(gN, gE, gS, gW),
      Paint()
        ..color = (selected
                ? Color.lerp(
                  const Color(0xFF1E1E42),
                  acc,
                  0.20 + selProg * 0.10,
                )!
                : const Color(0xFF1A1A3E))
            .withOpacity(opacity),
    );

    // Adoquines (4×4 subdivisiones)
    final linePaint =
        Paint()
          ..color = Colors.white.withOpacity(0.035 * opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.45;
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
    // Borde exterior
    canvas.drawPath(
      _path4(gN, gE, gS, gW),
      Paint()
        ..color = acc.withOpacity(0.25 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Marcas de esquina
    for (final corner in [gN, gE, gS, gW]) {
      canvas.drawCircle(
        corner,
        1.6,
        Paint()..color = acc.withOpacity(0.45 * opacity),
      );
    }

    // ── Glow de selección bajo la plaza ───────────────────────
    if (selected && selProg > 0) {
      canvas.drawPath(
        Path()..addOval(
          Rect.fromCenter(
            center: Offset((gN.dx + gS.dx) / 2, gS.dy + 6),
            width: _tW * 1.7,
            height: _tH,
          ),
        ),
        Paint()
          ..color = _kGold.withOpacity(0.30 * selProg)
          ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, 24 * selProg),
      );
    }

    // ── Sendero ───────────────────────────────────────────────
    _drawPathway(canvas, gN, gE, gS, gW, opacity, p.seed);

    // ── Árboles ───────────────────────────────────────────────
    final hasFood = p.data?.tieneZonaComida ?? false;
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

    // ── Banca ─────────────────────────────────────────────────
    if (!hasFood || rng.nextBool()) {
      _drawBench(
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

    // ── Fuente o quiosco ──────────────────────────────────────
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

    // ── Señal de parking ──────────────────────────────────────
    if (p.data?.tieneEstacionamiento ?? false) {
      _drawParkingSign(
        canvas,
        _tilePoint(gN, gE, gS, gW, 0.76, 0.74),
        opacity: opacity,
      );
    }

    // ── Letrero con nombre ────────────────────────────────────
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

    // Tronco der
    canvas.drawPath(
      _path4(
        base,
        base.translate(trW, -trW * 0.5),
        base.translate(trW, -trW * 0.5 - tot * 0.38),
        base.translate(0, -tot * 0.38),
      ),
      Paint()..color = const Color(0xFF5D4037).withOpacity(0.85 * opacity),
    );
    // Tronco izq
    canvas.drawPath(
      _path4(
        base,
        base.translate(-trW, -trW * 0.5),
        base.translate(-trW, -trW * 0.5 - tot * 0.38),
        base.translate(0, -tot * 0.38),
      ),
      Paint()..color = const Color(0xFF4E342E).withOpacity(0.85 * opacity),
    );

    // Copa (sombra + luz)
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

    // Brillo ambiental
    final glow = math.sin(ambient * math.pi * 2 + seed.toDouble()) * 0.5 + 0.5;
    canvas.drawOval(
      Rect.fromCenter(center: fc, width: fR * 2.5, height: fR * 1.5),
      Paint()
        ..color = color.withOpacity(0.05 * glow * opacity)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 7),
    );
  }

  // ── BANCA ──────────────────────────────────────────────────
  void _drawBench(
    Canvas canvas,
    Offset base,
    Color accent, {
    required double opacity,
  }) {
    const bW = 10.0;
    const bH = 5.0;
    canvas.drawPath(
      _path4(
        base,
        base.translate(bW, -bW * 0.5),
        base.translate(bW, -bW * 0.5 - 3),
        base.translate(0, -3),
      ),
      Paint()..color = const Color(0xFF8D6E63).withOpacity(0.88 * opacity),
    );
    canvas.drawPath(
      _path4(
        base.translate(0, -3),
        base.translate(bW, -bW * 0.5 - 3),
        base.translate(bW, -bW * 0.5 - 3 - bH),
        base.translate(0, -3 - bH),
      ),
      Paint()..color = const Color(0xFF795548).withOpacity(0.88 * opacity),
    );
    for (final dx in [bW * 0.15, bW * 0.85]) {
      canvas.drawRect(
        Rect.fromLTWH(base.dx + dx, base.dy - 1, 1.5, 4),
        Paint()..color = const Color(0xFF607D8B).withOpacity(0.8 * opacity),
      );
    }
  }

  // ── FUENTE PEQUEÑA ─────────────────────────────────────────
  void _drawSmallFountain(
    Canvas canvas,
    Offset base,
    Color accent, {
    required double opacity,
  }) {
    final pulse = math.sin(ambient * math.pi * 4) * 0.5 + 0.5;
    const r = 6.5;
    canvas.drawOval(
      Rect.fromCenter(center: base, width: r * 2.2, height: r * 1.1),
      Paint()..color = const Color(0xFF1A237E).withOpacity(0.85 * opacity),
    );
    canvas.drawOval(
      Rect.fromCenter(center: base, width: r * 2.2, height: r * 1.1),
      Paint()
        ..color = accent.withOpacity(0.3 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    canvas.drawOval(
      Rect.fromCenter(center: base, width: r * 1.4, height: r * 0.7),
      Paint()
        ..color = const Color(
          0xFF42A5F5,
        ).withOpacity((0.4 + pulse * 0.3) * opacity),
    );
    canvas.drawCircle(
      base,
      1.6 + pulse,
      Paint()
        ..color = Colors.white.withOpacity(0.8 * opacity)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 2),
    );
  }

  // ── QUIOSCO DE COMIDA ──────────────────────────────────────
  void _drawKiosk(
    Canvas canvas,
    Offset base,
    Color accent, {
    required double opacity,
  }) {
    const kW = 15.0;
    const kH = 18.0;
    const rH = 7.0;
    // Cara derecha
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
    // Cara izquierda
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
    // Techo der
    canvas.drawPath(
      _path4(
        base.translate(0, -kH),
        base.translate(kW, -kW * 0.5 - kH),
        base.translate(kW, -kW * 0.5 - kH - rH),
        base.translate(0, -kH - rH),
      ),
      Paint()..color = accent.withOpacity(0.85 * opacity),
    );
    // Techo izq
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
    // Ventana iluminada
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
    _Plaza p, {
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

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: lW, height: lH),
        const Radius.circular(8),
      ),
      Paint()
        ..color = acc.withOpacity(0.50 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9,
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

  // ── RAYOS DE LUZ ──────────────────────────────────────────
  void _drawLightRays(Canvas canvas, Size size) {
    final rp = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 5; i++) {
      final t = (ambient + i / 5.0) % 1.0;
      final x = math.sin(t * math.pi * 2) * 280;
      final y = -size.height * 0.44;
      final op = math.sin(t * math.pi) * 0.05;
      if (op <= 0) continue;
      rp.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_kGoldGlow.withOpacity(op), Colors.transparent],
      ).createShader(Rect.fromLTWH(x - 80, y, 160, size.height * 0.88));
      canvas.drawPath(
        Path()
          ..moveTo(x - 5, y)
          ..lineTo(x + 5, y)
          ..lineTo(x + 90, size.height * 0.36)
          ..lineTo(x - 90, size.height * 0.36)
          ..close(),
        rp,
      );
    }
  }

  // ── PARTÍCULAS ─────────────────────────────────────────────
  static final _rng0 = math.Random(99);
  static final _pts = List.generate(
    38,
    (i) => [
      _rng0.nextDouble() * 680 - 340,
      _rng0.nextDouble() * 500 - 230,
      _rng0.nextDouble() * 1.5 + 0.3,
      _rng0.nextDouble(),
      _rng0.nextInt(3).toDouble(),
    ],
  );
  static const _pColors = [_kGold, Color(0xFF66BB6A), Colors.white];

  void _drawParticles(Canvas canvas) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final p in _pts) {
      final phase = (ambient + p[3]) % 1.0;
      final alpha = math.sin(phase * math.pi) * 0.36;
      if (alpha <= 0) continue;
      paint.color = _pColors[p[4].toInt()].withOpacity(alpha * 0.5);
      canvas.drawCircle(Offset(p[0], p[1] - phase * 110), p[2], paint);
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
  bool shouldRepaint(_WorldPainter o) =>
      o.ambient != ambient ||
      o.selProg != selProg ||
      o.introProg != introProg ||
      o.selIdx != selIdx ||
      o.scale != scale ||
      o.pan != pan ||
      o.plazas.length != plazas.length;
}

// ══════════════════════════════════════════════════════════════
//  PANEL DE DETALLE
// ══════════════════════════════════════════════════════════════
class _DetailPanel extends StatelessWidget {
  final _Plaza plaza;
  final PlazoletaLoaded state;
  final VoidCallback onClose, onEnter;
  const _DetailPanel({
    required this.plaza,
    required this.state,
    required this.onClose,
    required this.onEnter,
  });

  String? _imgUrl() {
    final d = plaza.data;
    if (d == null) return null;
    if (state.imagenesPlazoleta != null) {
      for (final img in state.imagenesPlazoleta!) {
        if (img.entidadRelacionadaId == d.id && img.esPrincipal)
          return img.urlPreferida;
      }
      for (final img in state.imagenesPlazoleta!) {
        if (img.entidadRelacionadaId == d.id) return img.urlPreferida;
      }
    }
    return d.icono;
  }

  @override
  Widget build(BuildContext context) {
    final acc = plaza.accent;
    final d = plaza.data;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          height: 282,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  const Color(0xFF0E0E22),
                  acc,
                  0.15,
                )!.withOpacity(0.97),
                const Color(0xFF0A0A1A).withOpacity(0.97),
              ],
            ),
            border: Border(
              top: BorderSide(color: acc.withOpacity(0.45), width: 1.5),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: acc.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
                  child: d == null ? _soon(acc) : _detail(d, acc, _imgUrl()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detail(Plazoleta d, Color acc, String? imgUrl) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 86,
            height: 204,
            decoration: BoxDecoration(
              color: const Color(0xFF0D0D1E),
              border: Border.all(color: acc.withOpacity(0.38)),
            ),
            child:
                imgUrl != null
                    ? CachedNetworkImage(
                      imageUrl: imgUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _img(acc),
                    )
                    : _img(acc),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: acc.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: acc.withOpacity(0.45)),
                ),
                child: Text(
                  'Plaza ${plaza.index + 1}',
                  style: TextStyle(
                    color: acc,
                    fontSize: 10,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 7),
              Text(
                d.nombre,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Poppins',
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 7),
              if (d.resumenUbicacion.isNotEmpty)
                Row(
                  children: [
                    Icon(Icons.location_on, size: 11, color: acc),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        d.resumenUbicacion,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.55),
                          fontSize: 11,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 9),
              Wrap(
                spacing: 6,
                runSpacing: 5,
                children: [
                  if (d.tieneZonaComida ?? false)
                    _badge(Icons.restaurant, 'Comida', acc),
                  if (d.tieneEstacionamiento ?? false)
                    _badge(Icons.local_parking, 'Parking', acc),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  GestureDetector(
                    onTap: onClose,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white54,
                        size: 17,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: onEnter,
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              acc.withOpacity(0.9),
                              Color.lerp(acc, Colors.white, 0.2)!,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: acc.withOpacity(0.32),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Entrar a la plaza',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.black,
                                size: 15,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _soon(Color acc) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.park_outlined, size: 44, color: acc.withOpacity(0.4)),
        const SizedBox(height: 10),
        Text(
          'PRÓXIMAMENTE',
          style: TextStyle(
            color: acc.withOpacity(0.6),
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Este espacio pronto estará disponible',
          style: TextStyle(
            color: Colors.white.withOpacity(0.3),
            fontFamily: 'Poppins',
            fontSize: 12,
          ),
        ),
      ],
    ),
  );

  Widget _badge(IconData icon, String label, Color acc) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: acc.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: acc.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: acc),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: acc,
            fontSize: 10,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );

  Widget _img(Color acc) => Container(
    color: const Color(0xFF0D0D1E),
    child: Center(child: Icon(Icons.park, color: acc, size: 28)),
  );
}

```

Segunda versión, con mejor ambientación:


```dart
// lib/presentation/pages/plazoletas/plazoleta_list_page.dart
//
// 🏛️  PLAZA UNIVERSE v4 — Mall de Lujo Isométrico
// ────────────────────────────────────────────────────────────
//  AMBIENTACIÓN v4:
//  • Suelo de mármol blanco/crema con venas doradas
//  • Techo acristalado con luz cenital animada (skylight)
//  • Tiendas con fachadas detalladas: escaparates, neones, toldos
//  • Reflejo dinámico en el suelo (efecto mármol pulido)
//  • Luces de techo tipo downlight con corona de halo
//  • Atmósfera interior: gradiente de luz cálida/fría
//  • Señalética de mall: directorios, letreros de planta
//  • Plantas de interior tipo areca/ficus con macetas decorativas
//  • Fuente central con agua animada y mosaico
//  • Columnas marmóreas con capiteles dorados
//  • Barandales de vidrio templado (zonas de dos pisos)
//  • Efectos de bokeh / partículas de polvo de luz
// ────────────────────────────────────────────────────────────

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../di/service_locator.dart';
import '../../../domain/entities/plazoleta.dart';
import '../../blocs/plazoleta/plazoleta_bloc.dart';
import '../../blocs/plazoleta/plazoleta_event.dart';
import '../../blocs/plazoleta/plazoleta_state.dart';
import '../../widgets/profile_floating_button.dart';

// ══════════════════════════════════════════════════════════════
//  PALETA DE LUJO
// ══════════════════════════════════════════════════════════════
const _kGold = Color(0xFFD4AF37);
const _kGoldGlow = Color(0xFFFFE082);
const _kGoldDeep = Color(0xFF9C7A1A);
const _kBg = Color(0xFF0A0A0F); // negro azulado profundo

// Mármol
const _kMarbleLight = Color(0xFFF5F0E8); // mármol crema
const _kMarbleMid = Color(0xFFE8E0D0); // mármol medio
const _kMarbleDark = Color(0xFFD4C9B0); // mármol oscuro
const _kMarbleVein = Color(0xFFC8B89A); // vena del mármol
const _kMarbleShine = Color(0xFFFFFFFF); // brillo especular

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
class _Slot {
  final int col, row;
  const _Slot(this.col, this.row);
}

class _Plaza {
  final _Slot slot;
  final Plazoleta? data;
  final Color accent;
  final int index;
  final int seed;
  const _Plaza({
    required this.slot,
    required this.data,
    required this.accent,
    required this.index,
    required this.seed,
  });
}

// ══════════════════════════════════════════════════════════════
//  LAYOUT — igual que v3
// ══════════════════════════════════════════════════════════════
const _slots = <_Slot>[
  _Slot(0, 0),
  _Slot(4, 0),
  _Slot(8, 0),
  _Slot(12, 0),
  _Slot(0, 4),
  _Slot(12, 4),
  _Slot(0, 8),
  _Slot(12, 8),
  _Slot(0, 12),
  _Slot(4, 12),
  _Slot(8, 12),
  _Slot(12, 12),
  _Slot(2, 2),
  _Slot(6, 2),
  _Slot(10, 2),
  _Slot(2, 6),
  _Slot(10, 6),
  _Slot(2, 10),
  _Slot(6, 10),
  _Slot(10, 10),
];

bool _isAtrium(int c, int r) => c >= 4 && c <= 7 && r >= 4 && r <= 7;

const _columnPositions = <_Slot>[
  _Slot(3, 3), _Slot(9, 3), _Slot(3, 9), _Slot(9, 9),
  // Columnas extra en corredores principales
  _Slot(6, 0), _Slot(0, 6), _Slot(12, 6), _Slot(6, 12),
];

const _accents = <Color>[
  Color(0xFF4CAF50),
  Color(0xFF26A69A),
  Color(0xFF42A5F5),
  Color(0xFFAB47BC),
  Color(0xFF26C6DA),
  Color(0xFF9CCC65),
  Color(0xFFEF5350),
  Color(0xFFFF7043),
  Color(0xFF8D6E63),
  Color(0xFF78909C),
  Color(0xFF5C6BC0),
  Color(0xFFEC407A),
  Color(0xFF29B6F6),
  Color(0xFF66BB6A),
  Color(0xFFD4E157),
  Color(0xFFFFCA28),
  Color(0xFFFFA726),
  Color(0xFF26A69A),
  Color(0xFFAB47BC),
  Color(0xFF42A5F5),
];

// Tipos de tiendas para fachadas variadas
enum _StoreType { fashion, food, tech, beauty, sport, luxury }

const _storeTypes = _StoreType.values;

// ══════════════════════════════════════════════════════════════
//  PROVIDER
// ══════════════════════════════════════════════════════════════
class PlazoletaBlocProvider extends StatelessWidget {
  final Widget child;
  const PlazoletaBlocProvider({super.key, required this.child});
  @override
  Widget build(BuildContext context) => BlocProvider<PlazoletaBloc>.value(
    value: getIt<PlazoletaBloc>(),
    child: child,
  );
}

// ══════════════════════════════════════════════════════════════
//  PÁGINA PRINCIPAL
// ══════════════════════════════════════════════════════════════
class PlazoletaListPage extends StatefulWidget {
  const PlazoletaListPage({super.key});
  @override
  State<PlazoletaListPage> createState() => _PlazoletaListPageState();
}

class _PlazoletaListPageState extends State<PlazoletaListPage>
    with TickerProviderStateMixin {
  AnimationController? _ambientCtrl;
  AnimationController? _selectCtrl;
  AnimationController? _panelCtrl;
  AnimationController? _introCtrl;
  AnimationController? _inertiaCtrl;
  AnimationController? _skylightCtrl; // luz cenital independiente
  bool _initialized = false;

  // Navegación
  double _scale = 0.72;
  Offset _pan = Offset.zero;
  double _baseSc = 0.72;
  Offset _basePan = Offset.zero;
  Offset _focal = Offset.zero;
  Offset _velocity = Offset.zero;
  DateTime _lastPanTime = DateTime.now();

  // Estado
  int? _selectedIdx;
  List<_Plaza> _plazas = [];

  static const double _initScale = 0.72;

  @override
  void initState() {
    super.initState();
    _ambientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    _skylightCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 28),
    )..repeat();
    _selectCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _panelCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _introCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..forward();
    _inertiaCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _inertiaCtrl!.addListener(_applyInertia);
    _initialized = true;
    getIt<PlazoletaBloc>().add(const LoadPlazoletasActivas(page: 1, limit: 20));
  }

  @override
  void dispose() {
    _ambientCtrl?.dispose();
    _skylightCtrl?.dispose();
    _selectCtrl?.dispose();
    _panelCtrl?.dispose();
    _introCtrl?.dispose();
    _inertiaCtrl?.dispose();
    super.dispose();
  }

  void _buildPlazas(List<Plazoleta> list) {
    _plazas =
        _slots
            .asMap()
            .entries
            .map(
              (e) => _Plaza(
                slot: e.value,
                data: e.key < list.length ? list[e.key] : null,
                accent: _accents[e.key % _accents.length],
                index: e.key,
                seed: e.key * 137 + 42,
              ),
            )
            .toList();
  }

  // ── Selección ──────────────────────────────────────────────
  void _select(int idx) {
    HapticFeedback.lightImpact();
    final same = _selectedIdx == idx;
    setState(() => _selectedIdx = same ? null : idx);
    if (same) {
      _selectCtrl?.reverse();
      _panelCtrl?.reverse();
    } else {
      _selectCtrl?.forward(from: 0);
      _panelCtrl?.forward(from: 0);
    }
  }

  void _deselect() {
    if (_selectedIdx == null) return;
    setState(() => _selectedIdx = null);
    _selectCtrl?.reverse();
    _panelCtrl?.reverse();
  }

  // ── Navegación (fix v4) ────────────────────────────────────
  void _onScaleStart(ScaleStartDetails d) {
    _inertiaCtrl?.stop();
    _baseSc = _scale;
    _basePan = _pan;
    _focal = d.localFocalPoint;
    _velocity = Offset.zero;
    _lastPanTime = DateTime.now();
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    final now = DateTime.now();
    final dt = now.difference(_lastPanTime).inMilliseconds;

    setState(() {
      final newScale = (_baseSc * d.scale).clamp(0.30, 3.2);
      if (d.scale != 1.0) {
        // Zoom: mantener focal fijo
        final ratio = newScale / _baseSc;
        _pan = _focal - (_focal - _basePan) * ratio + d.focalPointDelta;
      } else {
        // Pan puro: delta absoluto desde inicio del gesto
        _pan = _basePan + (d.localFocalPoint - _focal);
      }
      _scale = newScale;
    });

    if (dt > 0 && d.scale == 1.0) {
      _velocity = d.focalPointDelta / dt.toDouble() * 16;
    }
    _lastPanTime = now;
  }

  void _onScaleEnd(ScaleEndDetails _) {
    if (_velocity.distance > 0.5) _inertiaCtrl?.forward(from: 0);
  }

  void _applyInertia() {
    if (_inertiaCtrl == null) return;
    final decay = 1.0 - Curves.decelerate.transform(_inertiaCtrl!.value);
    setState(() => _pan += _velocity * decay);
  }

  // ── Tap ────────────────────────────────────────────────────
  void _onTapUp(TapUpDetails d) {
    final sz = context.size ?? Size.zero;
    final world = _screenToWorld(d.localPosition, sz);
    int? hit;
    final sorted = [..._plazas]..sort(
      (a, b) => (b.slot.col + b.slot.row).compareTo(a.slot.col + a.slot.row),
    );
    for (final p in sorted) {
      if (_hitTestPlaza(p, world)) {
        hit = p.index;
        break;
      }
    }
    if (hit != null)
      _select(hit);
    else
      _deselect();
  }

  Offset _screenToWorld(Offset screen, Size size) => Offset(
    (screen.dx - size.width / 2 - _pan.dx) / _scale,
    (screen.dy - size.height / 2 - _pan.dy - _kOriginOffsetY) / _scale,
  );

  bool _hitTestPlaza(_Plaza p, Offset world) {
    final c = p.slot.col.toDouble();
    final r = p.slot.row.toDouble();
    final elev =
        (p.index == _selectedIdx) ? (_selectCtrl?.value ?? 0) * 22.0 : 0.0;
    final cx = (c - r) * _tW / 2;
    final cy = (c + r + 1) * _tH / 2 - elev;
    final ndx = (world.dx - cx).abs() / (_tW / 2);
    final ndy = (world.dy - cy).abs() / (_tH / 2);
    return (ndx + ndy <= 1.15) ||
        (ndx <= 0.75 && world.dy >= cy - _pH - 80 && world.dy <= cy + _tH / 2);
  }

  void _resetView() {
    _inertiaCtrl?.stop();
    setState(() {
      _scale = _initScale;
      _pan = Offset.zero;
    });
    _deselect();
  }

  Future<void> _onRefresh() async {
    _deselect();
    setState(() => _plazas = []);
    getIt<PlazoletaBloc>().add(
      const LoadPlazoletasActivas(page: 1, limit: 20, forceRefresh: true),
    );
  }

  void _goToDetail(int id) => context.go('/plazoletas/$id');

  // ══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    if (!_initialized)
      return const Scaffold(
        backgroundColor: _kBg,
        body: Center(
          child: CircularProgressIndicator(color: _kGold, strokeWidth: 2),
        ),
      );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _kBg,
        body: BlocConsumer<PlazoletaBloc, PlazoletaState>(
          bloc: getIt<PlazoletaBloc>(),
          listener: (_, s) {
            if (s is PlazoletaLoaded)
              setState(() => _buildPlazas(s.plazoletas));
          },
          builder: (_, s) {
            if (s is PlazoletaLoading || _plazas.isEmpty) return _loading();
            if (s is PlazoletaErrorState) return _error(s);
            return _mainView(s as PlazoletaLoaded);
          },
        ),
      ),
    );
  }

  Widget _mainView(PlazoletaLoaded state) {
    final sel =
        _selectedIdx != null
            ? _plazas.firstWhere(
              (p) => p.index == _selectedIdx,
              orElse: () => _plazas.first,
            )
            : null;
    final hasPanel = sel != null;

    return Stack(
      children: [
        // ── Fondo atmosférico del mall ────────────────────────
        _MallBackground(
          skylightCtrl: _skylightCtrl!,
          ambientCtrl: _ambientCtrl!,
        ),

        // ── Canvas 3D ────────────────────────────────────────
        GestureDetector(
          onScaleStart: _onScaleStart,
          onScaleUpdate: _onScaleUpdate,
          onScaleEnd: _onScaleEnd,
          onTapUp: _onTapUp,
          child: SizedBox.expand(
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _ambientCtrl!,
                _selectCtrl!,
                _introCtrl!,
                _skylightCtrl!,
              ]),
              builder:
                  (_, __) => CustomPaint(
                    painter: _WorldPainter(
                      plazas: _plazas,
                      selIdx: _selectedIdx,
                      ambient: _ambientCtrl!.value,
                      skylight: _skylightCtrl!.value,
                      selProg: _selectCtrl!.value,
                      introProg: _introCtrl!.value,
                      scale: _scale,
                      pan: _pan,
                    ),
                  ),
            ),
          ),
        ),

        // ── Header ───────────────────────────────────────────
        _header(state),

        // ── Controles ────────────────────────────────────────
        _mapControls(),

        // ── Panel ────────────────────────────────────────────
        if (hasPanel)
          AnimatedBuilder(
            animation: _panelCtrl!,
            builder: (_, __) {
              final t =
                  CurvedAnimation(
                    parent: _panelCtrl!,
                    curve: Curves.easeOutCubic,
                  ).value;
              return Positioned(
                bottom: (1 - t) * -240,
                left: 0,
                right: 0,
                child: _DetailPanel(
                  plaza: sel!,
                  state: state,
                  onClose: () => _select(sel.index),
                  onEnter: () {
                    if (sel.data != null) _goToDetail(sel.data!.id);
                  },
                ),
              );
            },
          ),

        // ── FAB perfil ───────────────────────────────────────
        Positioned(
          bottom: hasPanel ? 250 : 24,
          right: 22,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: ProfileFloatingButton(size: 54, backgroundColor: _kGold),
          ),
        ),

        _hint(),
      ],
    );
  }

  // ── UI WIDGETS ────────────────────────────────────────────

  Widget _header(PlazoletaLoaded state) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + 10,
              20,
              14,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0A0A14).withOpacity(0.96),
                  const Color(0xFF0A0A14).withOpacity(0.0),
                ],
              ),
              border: const Border(
                bottom: BorderSide(color: Color(0x18D4AF37), width: 1),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback:
                            (b) => const LinearGradient(
                              colors: [
                                Color(0xFF9C7A1A),
                                _kGold,
                                Color(0xFFFFE082),
                                _kGold,
                              ],
                              stops: [0.0, 0.35, 0.65, 1.0],
                            ).createShader(b),
                        child: const Text(
                          'PLAZA UNIVERSE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: _kGold,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            '${state.plazoletas.length} plazoletas  •  centro comercial virtual',
                            style: TextStyle(
                              color: _kGold.withOpacity(0.65),
                              fontSize: 11,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _iconBtn(Icons.refresh_rounded, _onRefresh),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _mapControls() => Positioned(
    right: 14,
    top: MediaQuery.of(context).padding.top + 80,
    child: Column(
      children: [
        _mapBtn(
          Icons.add,
          () => setState(() => _scale = (_scale * 1.22).clamp(0.30, 3.2)),
        ),
        const SizedBox(height: 5),
        _mapBtn(
          Icons.remove,
          () => setState(() => _scale = (_scale / 1.22).clamp(0.30, 3.2)),
        ),
        const SizedBox(height: 10),
        _mapBtn(Icons.center_focus_strong_rounded, _resetView, accent: true),
      ],
    ),
  );

  Widget _mapBtn(IconData icon, VoidCallback onTap, {bool accent = false}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          margin: const EdgeInsets.only(bottom: 1),
          decoration: BoxDecoration(
            color:
                accent
                    ? _kGold.withOpacity(0.18)
                    : const Color(0xFF0E0E1E).withOpacity(0.92),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _kGold.withOpacity(accent ? 0.55 : 0.22)),
            boxShadow:
                accent
                    ? [
                      BoxShadow(color: _kGold.withOpacity(0.18), blurRadius: 8),
                    ]
                    : null,
          ),
          child: Icon(icon, color: _kGold, size: 17),
        ),
      );

  Widget _iconBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E1E).withOpacity(0.88),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: _kGold.withOpacity(0.22)),
      ),
      child: Icon(icon, color: _kGold, size: 18),
    ),
  );

  Widget _hint() {
    return AnimatedBuilder(
      animation: _introCtrl!,
      builder: (_, __) {
        final t = _introCtrl!.value;
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
                  color: const Color(0xFF0A0A1A).withOpacity(0.88),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: _kGold.withOpacity(0.4)),
                  boxShadow: [
                    BoxShadow(color: _kGold.withOpacity(0.12), blurRadius: 16),
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

  Widget _loading() => Container(
    color: _kBg,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(_kGold),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Construyendo el mall…',
            style: TextStyle(
              color: _kGold.withOpacity(0.8),
              fontSize: 13,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _error(PlazoletaErrorState s) => Container(
    color: _kBg,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            color: Colors.red.withOpacity(0.6),
            size: 54,
          ),
          const SizedBox(height: 14),
          Text(
            s.message.isNotEmpty ? s.message : 'Error de conexión',
            style: const TextStyle(color: Colors.white60, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 22),
          GestureDetector(
            onTap: _onRefresh,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_kGoldDeep, _kGold, _kGoldGlow],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                'Reintentar',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ══════════════════════════════════════════════════════════════
//  FONDO ATMOSFÉRICO DEL MALL (Widget separado)
//  — Techo acristalado con luz cenital, brumas, ambient glow
// ══════════════════════════════════════════════════════════════
class _MallBackground extends StatelessWidget {
  final AnimationController skylightCtrl;
  final AnimationController ambientCtrl;
  const _MallBackground({
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
        return CustomPaint(painter: _BgPainter(sky: sky, amb: amb));
      },
    );
  }
}

class _BgPainter extends CustomPainter {
  final double sky, amb;
  const _BgPainter({required this.sky, required this.amb});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── Gradiente de profundidad interior ──────────────────
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

    // ── Claraboya / skylight central ───────────────────────
    final skylightX = w / 2 + math.sin(sky * math.pi * 2) * w * 0.04;
    final skylightIntensity = math.sin(sky * math.pi * 2) * 0.12 + 0.88;

    // Haz de luz principal (cono desde arriba)
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

    // Haces laterales de claraboya
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

    // ── Aura dorada ambiental (esquinas del techo) ─────────
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

    // ── Polvo de luz flotante (bokeh) ───────────────────────
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

    // ── Líneas de estructura del techo (vigas de cristal) ──
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

    // ── Viñeta perimetral (da sensación de interior cerrado) ─
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
  bool shouldRepaint(_BgPainter o) => o.sky != sky || o.amb != amb;
}

// ══════════════════════════════════════════════════════════════
//  PAINTER PRINCIPAL — MUNDO ISOMÉTRICO
// ══════════════════════════════════════════════════════════════
class _WorldPainter extends CustomPainter {
  final List<_Plaza> plazas;
  final int? selIdx;
  final double ambient, skylight, selProg, introProg, scale;
  final Offset pan;

  const _WorldPainter({
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

      // Banda de rodapié dorada
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
    final rng = math.Random(c.toInt() * 31 + r.toInt() * 17 + type.index);
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
    _Plaza p, {
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

    final bN = gN.translate(0, _pH);
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
    final hasFood = p.data?.tieneZonaComida ?? false;
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
    if (p.data?.tieneEstacionamiento ?? false) {
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
    _Plaza p, {
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
  bool shouldRepaint(_WorldPainter o) =>
      o.ambient != ambient ||
      o.skylight != skylight ||
      o.selProg != selProg ||
      o.introProg != introProg ||
      o.selIdx != selIdx ||
      o.scale != scale ||
      o.pan != pan ||
      o.plazas.length != plazas.length;
}

// Enum para dirección de fachada
enum FacadeDir { north, west, east }

// ══════════════════════════════════════════════════════════════
//  PANEL DE DETALLE — layout final
//
//  ┌──────────────────────────────────────────────────────[X]┐
//  │  ────  (pill)                                           │
//  │  ┌──────────┐  Plaza N  • badge • badge                 │
//  │  │          │  Nombre de la Plaza                       │
//  │  │  imagen  │  📍 Ubicación                             │
//  │  │ cuadrada │                                           │
//  │  └──────────┘  [──────── Entrar a la plaza ────────►]  │
//  └─────────────────────────────────────────────────────────┘
//
//  • X flotante en esquina superior derecha del panel
//  • Imagen cuadrada (110×110) alineada con toda la columna
//  • Columna derecha: chip + badges / nombre / ubicación /
//    botón "Entrar" ancho completo pegado al fondo
//  • Sin espacios muertos
// ══════════════════════════════════════════════════════════════
class _DetailPanel extends StatelessWidget {
  final _Plaza plaza;
  final PlazoletaLoaded state;
  final VoidCallback onClose, onEnter;
  const _DetailPanel({
    required this.plaza,
    required this.state,
    required this.onClose,
    required this.onEnter,
  });

  String? _imgUrl() {
    final d = plaza.data;
    if (d == null) return null;
    if (state.imagenesPlazoleta != null) {
      for (final img in state.imagenesPlazoleta!) {
        if (img.entidadRelacionadaId == d.id && img.esPrincipal)
          return img.urlPreferida;
      }
      for (final img in state.imagenesPlazoleta!) {
        if (img.entidadRelacionadaId == d.id) return img.urlPreferida;
      }
    }
    return d.icono;
  }

  @override
  Widget build(BuildContext context) {
    final acc = plaza.accent;
    final d = plaza.data;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          height: 240,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  const Color(0xFF0E0E22),
                  acc,
                  0.15,
                )!.withOpacity(0.97),
                const Color(0xFF0A0A1A).withOpacity(0.97),
              ],
            ),
            border: Border(
              top: BorderSide(color: acc.withOpacity(0.50), width: 1.5),
            ),
            boxShadow: [
              BoxShadow(
                color: acc.withOpacity(0.10),
                blurRadius: 32,
                offset: const Offset(0, -12),
              ),
            ],
          ),
          child: Stack(
            children: [
              // ── X en esquina superior derecha ─────────────────
              Positioned(
                top: 12,
                right: 14,
                child: GestureDetector(
                  onTap: onClose,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.18)),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white54,
                      size: 16,
                    ),
                  ),
                ),
              ),

              // ── Contenido principal ───────────────────────────
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pill handle centrado
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 14),
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: acc.withOpacity(0.50),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Cuerpo
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child:
                          d == null ? _soon(acc) : _detail(d, acc, _imgUrl()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detail(Plazoleta d, Color acc, String? imgUrl) {
    const imgSize = 110.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Imagen CUADRADA (SizedBox fuerza w=h) ───────────
        SizedBox(
          width: imgSize,
          height: imgSize,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0D0D1E),
                border: Border.all(color: acc.withOpacity(0.40), width: 1.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child:
                  imgUrl != null
                      ? CachedNetworkImage(
                        imageUrl: imgUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _imgPlaceholder(acc),
                      )
                      : _imgPlaceholder(acc),
            ),
          ),
        ),

        const SizedBox(width: 14),

        // ── Columna derecha, misma altura que la imagen ──────
        Expanded(
          child: SizedBox(
            height: imgSize,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ── Info superior ────────────────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _chipLabel('Plaza ${plaza.index + 1}', acc),
                        const SizedBox(width: 6),
                        if (d.tieneZonaComida ?? false)
                          _iconBadge(Icons.restaurant_outlined, acc),
                        if (d.tieneEstacionamiento ?? false) ...[
                          const SizedBox(width: 4),
                          _iconBadge(Icons.local_parking, acc),
                        ],
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      d.nombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    if (d.resumenUbicacion.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 11,
                            color: acc.withOpacity(0.75),
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              d.resumenUbicacion,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.48),
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),

                // ── Botón "Entrar" ancho completo ────────────
                GestureDetector(
                  onTap: onEnter,
                  child: Container(
                    height: 42,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [acc, Color.lerp(acc, Colors.white, 0.22)!],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: acc.withOpacity(0.38),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Entrar a la plaza',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.black,
                          size: 15,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Helpers de widgets ─────────────────────────────────────

  Widget _chipLabel(String text, Color acc) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
    decoration: BoxDecoration(
      color: acc.withOpacity(0.14),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: acc.withOpacity(0.45)),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: acc,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    ),
  );

  Widget _iconBadge(IconData icon, Color acc) => Container(
    width: 26,
    height: 26,
    decoration: BoxDecoration(
      color: acc.withOpacity(0.13),
      borderRadius: BorderRadius.circular(7),
      border: Border.all(color: acc.withOpacity(0.32)),
    ),
    child: Icon(icon, size: 13, color: acc),
  );

  Widget _soon(Color acc) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.park_outlined, size: 44, color: acc.withOpacity(0.4)),
        const SizedBox(height: 10),
        Text(
          'PRÓXIMAMENTE',
          style: TextStyle(
            color: acc.withOpacity(0.6),
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Este espacio pronto estará disponible',
          style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
        ),
      ],
    ),
  );

  Widget _imgPlaceholder(Color acc) => Container(
    color: const Color(0xFF0D0D1E),
    child: Center(
      child: Icon(Icons.park_outlined, color: acc.withOpacity(0.5), size: 32),
    ),
  );
}


```


Login:

```dart
// lib/presentation/pages/auth/login_page.dart
//
// 🏛️  PLAZA UNIVERSE — Login de Lujo
// ────────────────────────────────────────────────────────────
//  ANIMACIONES:
//  • Fondo: partículas isométricas flotantes + haces de luz
//  • Entrada: logo cae desde arriba con rebote elástico
//  • Título: letras aparecen una por una (typewriter dorado)
//  • Card del formulario: sube desde abajo con fade
//  • Campos: se iluminan al focus con glow dorado
//  • Botones: scale + shimmer al hover/press
//  • Error: shake horizontal animado
//  • Loading: spinner con trazo dorado pulsante
// ────────────────────────────────────────────────────────────

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/utils/firebase_auth_service.dart';
import '../../../di/service_locator.dart';

// ── Paleta ────────────────────────────────────────────────────
const _kGold = Color(0xFFD4AF37);
const _kGoldLight = Color(0xFFFFE082);
const _kGoldDeep = Color(0xFF9C7A1A);
const _kBg = Color(0xFF07070F);
const _kSurface = Color(0xFF0F0F1E);
const _kBorder = Color(0xFF1E1E3A);
const _kHint = Color(0xFF6B6B8A);

// ══════════════════════════════════════════════════════════════
//  PAGE WRAPPER — escucha auth state
// ══════════════════════════════════════════════════════════════
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _FullScreenLoader();
          }
          if (snapshot.hasData && snapshot.data != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/plazoletas');
            });
            return const _FullScreenLoader();
          }
          return const _LoginScreen();
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  PANTALLA DE LOGIN — con todas las animaciones
// ══════════════════════════════════════════════════════════════
class _LoginScreen extends StatefulWidget {
  const _LoginScreen();

  @override
  State<_LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<_LoginScreen>
    with TickerProviderStateMixin {
  // ── Controladores de animación ─────────────────────────────
  late final AnimationController _bgCtrl; // fondo continuo
  late final AnimationController _introCtrl; // entrada orquestada
  late final AnimationController _logoCtrl; // logo elástico
  late final AnimationController _titleCtrl; // typewriter
  late final AnimationController _cardCtrl; // card sube
  late final AnimationController _shakeCtrl; // shake error
  late final AnimationController _shimmerCtrl; // shimmer botón

  // ── Animaciones derivadas ──────────────────────────────────
  late final Animation<double> _logoY;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _cardSlide;
  late final Animation<double> _cardOpacity;
  late final Animation<double> _shakeX;

  // ── Form state ────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _authService = getIt<FirebaseAuthService>();
  bool _isLoading = false;
  bool _obscurePass = true;
  String? _errorMessage;
  bool _emailFocused = false;
  bool _passFocused = false;

  @override
  void initState() {
    super.initState();

    // Fondo animado continuo
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    // Shimmer continuo en botón
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Shake de error
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeX = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6, end: -4), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -4, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.linear));

    // Logo: cae desde arriba con rebote elástico
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _logoY = Tween<double>(
      begin: -120,
      end: 0,
    ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoCtrl, curve: const Interval(0, 0.3)),
    );

    // Título typewriter (lo controla el builder con el valor)
    _titleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Card sube desde abajo
    _cardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _cardSlide = Tween<double>(
      begin: 80,
      end: 0,
    ).animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutCubic));
    _cardOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _cardCtrl, curve: const Interval(0, 0.6)),
    );

    // Secuencia de entrada
    _introCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _startIntro();
  }

  Future<void> _startIntro() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    _titleCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 700));
    _cardCtrl.forward();
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _introCtrl.dispose();
    _logoCtrl.dispose();
    _titleCtrl.dispose();
    _cardCtrl.dispose();
    _shakeCtrl.dispose();
    _shimmerCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ── Acciones ──────────────────────────────────────────────
  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await _authService.signInWithEmail(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
      );
      result.fold((_) {}, (err) => _showError(err.toString()));
    } catch (e) {
      _showError('Error inesperado: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await _authService.signUpWithEmail(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
        nombre: _emailCtrl.text.split('@').first,
      );
      result.fold((_) {}, (err) => _showError(err.toString()));
    } catch (e) {
      _showError('Error inesperado: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await _authService.signInWithGoogle();
      result.fold((_) {}, (err) => _showError(err.toString()));
    } catch (e) {
      _showError('Error inesperado: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    setState(() => _errorMessage = msg);
    _shakeCtrl.forward(from: 0);
  }

  void _resetPassword() {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      _showError('Ingresa tu email primero');
      return;
    }
    showDialog(
      context: context,
      builder:
          (_) => _ResetDialog(
            email: email,
            authService: _authService,
            onError: _showError,
          ),
    );
  }

  // ══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Fondo animado ──────────────────────────────────────
        AnimatedBuilder(
          animation: _bgCtrl,
          builder:
              (_, __) => CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _BgPainter(_bgCtrl.value),
              ),
        ),

        // ── Contenido ─────────────────────────────────────────
        SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 48),

                // ── Logo con animación elástica ────────────────
                AnimatedBuilder(
                  animation: _logoCtrl,
                  builder:
                      (_, __) => Opacity(
                        opacity: _logoOpacity.value.clamp(0.0, 1.0),
                        child: Transform.translate(
                          offset: Offset(0, _logoY.value),
                          child: Transform.scale(
                            scale: _logoScale.value,
                            child: const _LogoWidget(),
                          ),
                        ),
                      ),
                ),

                const SizedBox(height: 28),

                // ── Título con typewriter ──────────────────────
                AnimatedBuilder(
                  animation: _titleCtrl,
                  builder: (_, __) => _TitleWidget(progress: _titleCtrl.value),
                ),

                const SizedBox(height: 36),

                // ── Card del formulario ────────────────────────
                AnimatedBuilder(
                  animation: _cardCtrl,
                  builder:
                      (_, __) => Opacity(
                        opacity: _cardOpacity.value.clamp(0.0, 1.0),
                        child: Transform.translate(
                          offset: Offset(0, _cardSlide.value),
                          child: AnimatedBuilder(
                            animation: _shakeCtrl,
                            builder:
                                (_, child) => Transform.translate(
                                  offset: Offset(_shakeX.value, 0),
                                  child: child,
                                ),
                            child: _FormCard(
                              formKey: _formKey,
                              emailCtrl: _emailCtrl,
                              passwordCtrl: _passwordCtrl,
                              isLoading: _isLoading,
                              obscurePass: _obscurePass,
                              errorMessage: _errorMessage,
                              emailFocused: _emailFocused,
                              passFocused: _passFocused,
                              shimmerCtrl: _shimmerCtrl,
                              onTogglePass:
                                  () => setState(
                                    () => _obscurePass = !_obscurePass,
                                  ),
                              onEmailFocus:
                                  (v) => setState(() => _emailFocused = v),
                              onPassFocus:
                                  (v) => setState(() => _passFocused = v),
                              onSignIn: _signIn,
                              onSignUp: _signUp,
                              onGoogle: _googleSignIn,
                              onReset: _resetPassword,
                            ),
                          ),
                        ),
                      ),
                ),

                const SizedBox(height: 36),

                // ── Footer ────────────────────────────────────
                AnimatedBuilder(
                  animation: _cardCtrl,
                  builder:
                      (_, __) => Opacity(
                        opacity: (_cardOpacity.value * 0.7).clamp(0.0, 1.0),
                        child: Text(
                          '© 2026 Paseo del Comercio',
                          style: TextStyle(
                            color: _kHint.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  FONDO: partículas isométricas + claraboya
// ══════════════════════════════════════════════════════════════
class _BgPainter extends CustomPainter {
  final double t;
  _BgPainter(this.t);

  static final _rng = math.Random(42);
  static final _particles = List.generate(
    60,
    (i) => [
      _rng.nextDouble(), // x relativo
      _rng.nextDouble(), // y relativo
      _rng.nextDouble() * 0.6 + 0.2, // fase
      _rng.nextDouble() * 2.5 + 0.5, // radio
      _rng.nextInt(3).toDouble(), // color idx
    ],
  );

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Fondo base
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.4),
          radius: 1.0,
          colors: [const Color(0xFF111128), const Color(0xFF09091A), _kBg],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Haz de luz cenital suave
    final beamOp = math.sin(t * math.pi * 2) * 0.04 + 0.10;
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.35, 0)
        ..lineTo(w * 0.65, 0)
        ..lineTo(w * 0.80, h * 0.65)
        ..lineTo(w * 0.20, h * 0.65)
        ..close(),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_kGoldLight.withOpacity(beamOp), Colors.transparent],
        ).createShader(Rect.fromLTWH(0, 0, w, h * 0.65)),
    );

    // Rombos isométricos decorativos (mini tiles del mall)
    final tileAlpha = 0.06;
    final tW = w * 0.18;
    final tH = tW * 0.5;
    for (int row = -1; row <= 9; row++) {
      for (int col = -1; col <= 6; col++) {
        final cx = (col - row) * tW / 2 + w * 0.5;
        final cy = (col + row) * tH / 2 - t * tH * 0.5;
        final pulse = math.sin(t * math.pi * 2 + col * 0.4 + row * 0.3) * 0.015;
        final alpha = (tileAlpha + pulse).clamp(0.0, 0.12);
        // Cara superior del tile isométrico
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
            ..color = _kGold.withOpacity(alpha)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.6,
        );
        // Cara lateral (sombra)
        if (row % 3 == 0) {
          canvas.drawPath(
            path,
            Paint()..color = _kGold.withOpacity(alpha * 0.25),
          );
        }
      }
    }

    // Partículas de luz flotante
    const colors = [_kGold, _kGoldLight, Colors.white];
    for (final p in _particles) {
      final phase = (t + p[2]) % 1.0;
      final op = math.sin(phase * math.pi) * 0.35;
      if (op <= 0) continue;
      final px = p[0] * w;
      final py = p[1] * h - phase * h * 0.22;
      canvas.drawCircle(
        Offset(px, py),
        p[3],
        Paint()
          ..color = colors[p[4].toInt()].withOpacity(op)
          ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, p[3] * 1.2),
      );
    }

    // Viñeta perimetral
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 0.78,
          colors: [Colors.transparent, Colors.black.withOpacity(0.70)],
          stops: const [0.5, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Líneas de estructura dorada
    final linePaint =
        Paint()
          ..color = _kGold.withOpacity(0.04)
          ..strokeWidth = 0.7;
    for (int i = 0; i < 6; i++) {
      canvas.drawLine(
        Offset(w * i / 5, 0),
        Offset(w * 0.5, h * 0.5),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_BgPainter o) => o.t != t;
}

// ══════════════════════════════════════════════════════════════
//  LOGO ANIMADO
// ══════════════════════════════════════════════════════════════
class _LogoWidget extends StatelessWidget {
  const _LogoWidget();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Anillo de glow exterior
        Container(
          width: 108,
          height: 108,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _kGold.withOpacity(0.35),
                blurRadius: 28,
                spreadRadius: 4,
              ),
              BoxShadow(
                color: _kGold.withOpacity(0.15),
                blurRadius: 56,
                spreadRadius: 8,
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E1E38), Color(0xFF0C0C1E)],
              ),
              border: Border.all(color: _kGold.withOpacity(0.70), width: 1.8),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/icons/favicon.jpeg',
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => const Icon(
                      Icons.storefront_rounded,
                      size: 52,
                      color: _kGold,
                    ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  TÍTULO CON EFECTO TYPEWRITER DORADO
// ══════════════════════════════════════════════════════════════
class _TitleWidget extends StatelessWidget {
  final double progress;
  const _TitleWidget({required this.progress});

  @override
  Widget build(BuildContext context) {
    const line1 = 'Paseo';
    const line2 = 'del comercio';
    const sub = 'Centro Comercial Virtual';

    // Typewriter: cada carácter aparece en secuencia
    final totalChars = line1.length + line2.length;
    final charsVisible =
        (progress * totalChars * 1.3).clamp(0, totalChars.toDouble()).toInt();

    final l1visible = charsVisible.clamp(0, line1.length);
    final l2visible = (charsVisible - line1.length).clamp(0, line2.length);
    final subOpacity = ((progress - 0.75) * 4).clamp(0.0, 1.0);
    final cursorOpacity = progress < 0.98 ? 1.0 : 0.0;

    return Column(
      children: [
        // Línea 1: "Paseo" con cursor
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShaderMask(
              shaderCallback:
                  (b) => const LinearGradient(
                    colors: [_kGoldDeep, _kGold, _kGoldLight, _kGold],
                    stops: [0.0, 0.3, 0.6, 1.0],
                  ).createShader(b),
              child: Text(
                line1.substring(0, l1visible),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Optima',
                  letterSpacing: 2,
                ),
              ),
            ),
            // Cursor parpadeante mientras escribe línea 1
            if (l1visible < line1.length)
              Opacity(
                opacity: cursorOpacity,
                child: Container(
                  width: 2,
                  height: 36,
                  margin: const EdgeInsets.only(left: 2),
                  color: _kGold,
                ),
              ),
          ],
        ),

        // Línea 2: "del comercio"
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: l2visible > 0 ? 1.0 : 0.0,
              child: Text(
                line2.substring(0, l2visible),
                style: TextStyle(
                  color: _kHint,
                  fontSize: 22,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'Poppins',
                  letterSpacing: 1.5,
                ),
              ),
            ),
            // Cursor en línea 2
            if (l1visible >= line1.length && l2visible < line2.length)
              Opacity(
                opacity: cursorOpacity,
                child: Container(
                  width: 1.5,
                  height: 22,
                  margin: const EdgeInsets.only(left: 1),
                  color: _kHint,
                ),
              ),
          ],
        ),

        const SizedBox(height: 6),

        // Subtítulo con fade + separador dorado
        AnimatedOpacity(
          opacity: subOpacity,
          duration: const Duration(milliseconds: 400),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 24,
                    height: 1,
                    color: _kGold.withOpacity(0.4),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    sub,
                    style: TextStyle(
                      color: _kHint.withOpacity(0.75),
                      fontSize: 12,
                      letterSpacing: 2.5,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 24,
                    height: 1,
                    color: _kGold.withOpacity(0.4),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  CARD DEL FORMULARIO
// ══════════════════════════════════════════════════════════════
class _FormCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl, passwordCtrl;
  final bool isLoading, obscurePass, emailFocused, passFocused;
  final String? errorMessage;
  final AnimationController shimmerCtrl;
  final VoidCallback onTogglePass, onSignIn, onSignUp, onGoogle, onReset;
  final ValueChanged<bool> onEmailFocus, onPassFocus;

  const _FormCard({
    required this.formKey,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.isLoading,
    required this.obscurePass,
    required this.errorMessage,
    required this.emailFocused,
    required this.passFocused,
    required this.shimmerCtrl,
    required this.onTogglePass,
    required this.onEmailFocus,
    required this.onPassFocus,
    required this.onSignIn,
    required this.onSignUp,
    required this.onGoogle,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: _kSurface.withOpacity(0.88),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _kBorder, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.55),
                blurRadius: 40,
                spreadRadius: 4,
              ),
              BoxShadow(
                color: _kGold.withOpacity(0.06),
                blurRadius: 60,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Campo email ──────────────────────────────
                _AnimatedField(
                  controller: emailCtrl,
                  label: 'Correo electrónico',
                  icon: Icons.alternate_email_rounded,
                  isFocused: emailFocused,
                  onFocusChange: onEmailFocus,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ingresa tu email';
                    if (!v.contains('@')) return 'Email no válido';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // ── Campo contraseña ─────────────────────────
                _AnimatedField(
                  controller: passwordCtrl,
                  label: 'Contraseña',
                  icon: Icons.lock_outline_rounded,
                  isFocused: passFocused,
                  onFocusChange: onPassFocus,
                  obscureText: obscurePass,
                  suffixIcon: GestureDetector(
                    onTap: onTogglePass,
                    child: Icon(
                      obscurePass
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: _kHint,
                      size: 20,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
                    if (v.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // ── Mensaje de error ─────────────────────────
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  child:
                      errorMessage != null
                          ? Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 11,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.25),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  color: Colors.red[300],
                                  size: 16,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    errorMessage!,
                                    style: TextStyle(
                                      color: Colors.red[300],
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                          : const SizedBox.shrink(),
                ),

                // ── Botón INICIAR SESIÓN (shimmer) ───────────
                _ShimmerButton(
                  label: 'INICIAR SESIÓN',
                  isLoading: isLoading,
                  shimmerCtrl: shimmerCtrl,
                  onTap: onSignIn,
                ),

                const SizedBox(height: 12),

                // ── Botón CREAR CUENTA (outline) ─────────────
                _OutlineActionButton(
                  label: 'CREAR CUENTA',
                  isLoading: isLoading,
                  onTap: onSignUp,
                ),

                const SizedBox(height: 22),

                // ── Separador ────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, _kBorder],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        'o continúa con',
                        style: TextStyle(
                          color: _kHint,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_kBorder, Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // ── Botón Google ─────────────────────────────
                _GoogleButton(isLoading: isLoading, onTap: onGoogle),

                const SizedBox(height: 18),

                // ── Olvidé contraseña ─────────────────────────
                Center(
                  child: GestureDetector(
                    onTap: isLoading ? null : onReset,
                    child: Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(
                        color: _kGold.withOpacity(0.75),
                        fontSize: 13,
                        decoration: TextDecoration.underline,
                        decorationColor: _kGold.withOpacity(0.35),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  CAMPO CON GLOW ANIMADO AL FOCUS
// ══════════════════════════════════════════════════════════════
class _AnimatedField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isFocused;
  final ValueChanged<bool> onFocusChange;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _AnimatedField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.isFocused,
    required this.onFocusChange,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
  });

  @override
  State<_AnimatedField> createState() => _AnimatedFieldState();
}

class _AnimatedFieldState extends State<_AnimatedField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _focusCtrl;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _focusCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _glowAnim = CurvedAnimation(parent: _focusCtrl, curve: Curves.easeOut);
  }

  @override
  void didUpdateWidget(_AnimatedField old) {
    super.didUpdateWidget(old);
    if (widget.isFocused != old.isFocused) {
      widget.isFocused ? _focusCtrl.forward() : _focusCtrl.reverse();
    }
  }

  @override
  void dispose() {
    _focusCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder:
          (_, child) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: _kGold.withOpacity(0.22 * _glowAnim.value),
                  blurRadius: 16 * _glowAnim.value + 1,
                  spreadRadius: _glowAnim.value * 1.5,
                ),
              ],
            ),
            child: child,
          ),
      child: Focus(
        onFocusChange: widget.onFocusChange,
        child: TextFormField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            labelText: widget.label,
            labelStyle: TextStyle(
              color: widget.isFocused ? _kGold.withOpacity(0.9) : _kHint,
              fontSize: 13,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Icon(
                widget.icon,
                color: widget.isFocused ? _kGold : _kHint,
                size: 20,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            suffixIcon:
                widget.suffixIcon != null
                    ? Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: widget.suffixIcon,
                    )
                    : null,
            filled: true,
            fillColor: Colors.black.withOpacity(0.28),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _kBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _kBorder, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _kGold, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.red.withOpacity(0.5)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.red.withOpacity(0.7)),
            ),
            errorStyle: const TextStyle(fontSize: 11),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  BOTÓN CON EFECTO SHIMMER DORADO
// ══════════════════════════════════════════════════════════════
class _ShimmerButton extends StatefulWidget {
  final String label;
  final bool isLoading;
  final AnimationController shimmerCtrl;
  final VoidCallback onTap;

  const _ShimmerButton({
    required this.label,
    required this.isLoading,
    required this.shimmerCtrl,
    required this.onTap,
  });

  @override
  State<_ShimmerButton> createState() => _ShimmerButtonState();
}

class _ShimmerButtonState extends State<_ShimmerButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _pressScale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        if (!widget.isLoading) widget.onTap();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: AnimatedBuilder(
        animation: Listenable.merge([_pressCtrl, widget.shimmerCtrl]),
        builder:
            (_, __) => Transform.scale(
              scale: _pressScale.value,
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: _kGold.withOpacity(0.38),
                      blurRadius: 18,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    children: [
                      // Base dorada
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_kGoldDeep, _kGold, _kGoldLight, _kGold],
                            stops: [0.0, 0.35, 0.65, 1.0],
                          ),
                        ),
                      ),
                      // Barrido de shimmer
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: widget.shimmerCtrl,
                          builder: (_, __) {
                            final x = widget.shimmerCtrl.value * 2 - 0.5;
                            return FractionallySizedBox(
                              widthFactor: 0.35,
                              alignment: Alignment(x * 2 - 1, 0),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0),
                                      Colors.white.withOpacity(0.22),
                                      Colors.white.withOpacity(0),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Contenido
                      Center(
                        child:
                            widget.isLoading
                                ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.black,
                                    ),
                                  ),
                                )
                                : Text(
                                  widget.label,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  BOTÓN OUTLINE CON PRESS SCALE
// ══════════════════════════════════════════════════════════════
class _OutlineActionButton extends StatefulWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onTap;

  const _OutlineActionButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  @override
  State<_OutlineActionButton> createState() => _OutlineActionButtonState();
}

class _OutlineActionButtonState extends State<_OutlineActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _ctrl.forward();
        setState(() => _pressed = true);
      },
      onTapUp: (_) {
        _ctrl.reverse();
        setState(() => _pressed = false);
        if (!widget.isLoading) widget.onTap();
      },
      onTapCancel: () {
        _ctrl.reverse();
        setState(() => _pressed = false);
      },
      child: AnimatedBuilder(
        animation: _ctrl,
        builder:
            (_, __) => Transform.scale(
              scale: _scale.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _pressed ? _kGold : _kGold.withOpacity(0.55),
                    width: 1.5,
                  ),
                  color:
                      _pressed ? _kGold.withOpacity(0.08) : Colors.transparent,
                ),
                child: Center(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: _kGold,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  BOTÓN GOOGLE
// ══════════════════════════════════════════════════════════════
class _GoogleButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onTap;
  const _GoogleButton({required this.isLoading, required this.onTap});

  @override
  State<_GoogleButton> createState() => _GoogleButtonState();
}

class _GoogleButtonState extends State<_GoogleButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        if (!widget.isLoading) widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder:
            (_, __) => Transform.scale(
              scale: _scale.value,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF0E0E1E),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _kBorder, width: 1.2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Image.asset(
                        'assets/images/google_logo.png',
                        errorBuilder:
                            (_, __, ___) => const Icon(
                              Icons.g_mobiledata_rounded,
                              color: _kGold,
                              size: 22,
                            ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Continuar con Google',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  DIÁLOGO RESET PASSWORD
// ══════════════════════════════════════════════════════════════
class _ResetDialog extends StatelessWidget {
  final String email;
  final FirebaseAuthService authService;
  final ValueChanged<String> onError;

  const _ResetDialog({
    required this.email,
    required this.authService,
    required this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: _kSurface,
      surfaceTintColor: _kGold,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.lock_reset_rounded, color: _kGold, size: 20),
          const SizedBox(width: 10),
          const Text(
            'Restablecer contraseña',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      content: Text(
        '¿Enviar email de restablecimiento a\n$email?',
        style: const TextStyle(color: _kHint, fontSize: 14, height: 1.5),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: _kHint)),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            try {
              final result = await authService.resetPassword(email);
              result.fold((_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: _kGold,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      content: const Text(
                        'Email enviado ✓',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                }
              }, (err) => onError(err.toString()));
            } catch (e) {
              onError('Error: $e');
            }
          },
          child: const Text(
            'Enviar',
            style: TextStyle(color: _kGold, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  LOADER PANTALLA COMPLETA
// ══════════════════════════════════════════════════════════════
class _FullScreenLoader extends StatelessWidget {
  const _FullScreenLoader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kBg,
      child: const Center(
        child: SizedBox(
          width: 44,
          height: 44,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(_kGold),
          ),
        ),
      ),
    );
  }
}


```
