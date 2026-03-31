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

import 'dart:async';
import 'dart:ui' as ui;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../di/service_locator.dart';
import '../../../domain/entities/plazoleta.dart';
import '../../blocs/plazoleta/plazoleta_bloc.dart';
import '../../blocs/plazoleta/plazoleta_event.dart';
import '../../blocs/plazoleta/plazoleta_state.dart';
import '../../widgets/mall/mall_background.dart';
import '../../widgets/mall/mall_world_painter.dart';
import '../../widgets/plazoleta/plazoleta_detail_panel.dart';
import '../../widgets/profile_floating_button.dart';

// ══════════════════════════════════════════════════════════════
//  PALETA DE LUJO (branding - no theme)
// ══════════════════════════════════════════════════════════════
const _kGold = Color(0xFFD4AF37);
const _kGoldGlow = Color(0xFFFFE082);
const _kGoldDeep = Color(0xFF9C7A1A);

// ══════════════════════════════════════════════════════════════
//  CONSTANTES ISOMÉTRICAS
// ══════════════════════════════════════════════════════════════
const double _tW = 110.0;
const double _tH = 55.0;
const double _pH = 16.0;
const double _kOriginOffsetY = 60.0;

// ══════════════════════════════════════════════════════════════
//  MODELOS (local types matching original structure)
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

  PlazaDetail toPlazaDetail() => PlazaDetail(
    slot: MallSlot(slot.col, slot.row),
    data: data,
    accent: accent,
    index: index,
    seed: seed,
  );
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
    with TickerProviderStateMixin, WidgetsBindingObserver {
  AnimationController? _ambientCtrl;
  AnimationController? _selectCtrl;
  AnimationController? _panelCtrl;
  AnimationController? _introCtrl;
  AnimationController? _inertiaCtrl;
  AnimationController? _skylightCtrl;
  AnimationController? _navCtrl;
  bool _initialized = false;

  StreamSubscription<User?>? _authSubscription;

  double _scale = 0.72;
  Offset _pan = Offset.zero;
  double _baseSc = 0.72;
  Offset _basePan = Offset.zero;
  Offset _focal = Offset.zero;
  Offset _worldFocalAtStart = Offset.zero;

  Offset _velocity = Offset.zero;
  DateTime _lastPanTime = DateTime.now();

  Animation<double>? _scaleAnim;
  Animation<Offset>? _panAnim;

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
    _navCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _navCtrl!.addListener(_updateNavAnimation);
    _initialized = true;

    WidgetsBinding.instance.addObserver(this);

    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((
      User? user,
    ) {
      getIt<PlazoletaBloc>().add(
        const LoadPlazoletasActivas(page: 1, limit: 20, forceRefresh: true),
      );
    });

    getIt<PlazoletaBloc>().add(const LoadPlazoletasActivas(page: 1, limit: 20));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      getIt<PlazoletaBloc>().add(
        const LoadPlazoletasActivas(page: 1, limit: 20, forceRefresh: true),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSubscription?.cancel();
    _ambientCtrl?.dispose();
    _selectCtrl?.dispose();
    _panelCtrl?.dispose();
    _introCtrl?.dispose();
    _inertiaCtrl?.dispose();
    _skylightCtrl?.dispose();
    _navCtrl?.dispose();
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

  void _onScaleStart(ScaleStartDetails d) {
    _inertiaCtrl?.stop();
    _navCtrl?.stop();
    _baseSc = _scale;
    _basePan = _pan;
    _focal = d.localFocalPoint;
    _velocity = Offset.zero;
    _lastPanTime = DateTime.now();

    final size = context.size ?? Size.zero;
    if (size.isEmpty) return;
    _worldFocalAtStart = _screenToWorld(_focal, size);
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    final now = DateTime.now();
    final dt = now.difference(_lastPanTime).inMilliseconds;

    setState(() {
      final newScale = (_baseSc * d.scale).clamp(0.30, 3.2);
      final size = context.size ?? Size.zero;
      if (size.isEmpty) return;

      if (d.scale != 1.0) {
        final centerX = size.width / 2;
        final centerY = size.height / 2 + _kOriginOffsetY;

        final worldPoint = _worldFocalAtStart;

        final requiredPanX =
            d.localFocalPoint.dx - worldPoint.dx * newScale - centerX;
        final verticalCompensation = 0.9;
        final adjustedWorldY = worldPoint.dy * verticalCompensation;
        final requiredPanY =
            d.localFocalPoint.dy - adjustedWorldY * newScale - centerY;

        _pan = Offset(requiredPanX, requiredPanY);
      } else {
        _pan = _basePan + (d.localFocalPoint - _focal);
      }
      _scale = newScale;
    });

    if (dt > 0) {
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

  void _updateNavAnimation() {
    if (_navCtrl == null || _scaleAnim == null || _panAnim == null) return;
    setState(() {
      _scale = _scaleAnim!.value;
      _pan = _panAnim!.value;
    });
  }

  void _animateZoom(double targetScale) {
    _inertiaCtrl?.stop();
    _navCtrl?.stop();

    final newScale = targetScale.clamp(0.30, 3.2);

    final scaleRatio = newScale / _scale;
    final newPan = Offset(_pan.dx * scaleRatio, _pan.dy * scaleRatio);

    _scaleAnim = Tween<double>(
      begin: _scale,
      end: newScale,
    ).animate(CurvedAnimation(parent: _navCtrl!, curve: Curves.easeOutCubic));

    _panAnim = Tween<Offset>(
      begin: _pan,
      end: newPan,
    ).animate(CurvedAnimation(parent: _navCtrl!, curve: Curves.easeOutCubic));

    _navCtrl!.forward(from: 0);
  }

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
    if (hit != null) {
      _select(hit);
    } else {
      _deselect();
    }
  }

  Offset _screenToWorld(Offset screen, Size size) {
    if (size.isEmpty || _scale == 0) return Offset.zero;
    return Offset(
      (screen.dx - size.width / 2 - _pan.dx) / _scale,
      (screen.dy - size.height / 2 - _pan.dy - _kOriginOffsetY) / _scale,
    );
  }

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
    _navCtrl?.stop();

    _scaleAnim = Tween<double>(
      begin: _scale,
      end: _initScale,
    ).animate(CurvedAnimation(parent: _navCtrl!, curve: Curves.easeOutCubic));

    _panAnim = Tween<Offset>(
      begin: _pan,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _navCtrl!, curve: Curves.easeOutCubic));

    _navCtrl!.forward(from: 0);
    _deselect();
  }

  Future<void> _onRefresh() async {
    _deselect();
    setState(() => _plazas = []);
    getIt<PlazoletaBloc>().add(
      const LoadPlazoletasActivas(page: 1, limit: 20, forceRefresh: true),
    );
  }

  Future<void> _goToDetail(int id) async {
    await context.push('/plazoletas/$id');

    if (mounted) {
      getIt<PlazoletaBloc>().add(
        const LoadPlazoletasActivas(page: 1, limit: 20, forceRefresh: true),
      );
    }
  }

  // Convert local _Plaza to PlazaData for MallWorldPainter
  PlazaData _toPlazaData(_Plaza p) => PlazaData(
    slot: MallSlot(p.slot.col, p.slot.row),
    data: p.data,
    accent: p.accent,
    index: p.index,
    seed: p.seed,
  );

  // ══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0A0F),
        body: Center(
          child: CircularProgressIndicator(color: _kGold, strokeWidth: 2),
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0F),
        body: BlocConsumer<PlazoletaBloc, PlazoletaState>(
          bloc: getIt<PlazoletaBloc>(),
          listener: (_, s) {
            if (s is PlazoletaLoaded) {
              setState(() => _buildPlazas(s.plazoletas));
            }
          },
          builder: (_, s) {
            if (s is PlazoletaLoading ||
                s is PlazoletasActivasLoading ||
                s is PlazoletaLoadingMore ||
                s is PlazoletaDetailLoading ||
                s is PlazoletaImagenesLoading ||
                s is PlazoletaProductosLoading ||
                s is PlazoletaTiendasLoading ||
                s is PlazoletaEstadisticasLoading ||
                s is PlazoletasActivasError ||
                s is PlazoletaDetailError ||
                s is PlazoletaImagenesError ||
                s is PlazoletaProductosError ||
                s is PlazoletaTiendasError ||
                _plazas.isEmpty)
              return _loading();
            if (s is PlazoletaErrorState) return _error(s);
            if (s is PlazoletaLoaded) return _mainView(s);
            if (_plazas.isNotEmpty) {
              final currentState = getIt<PlazoletaBloc>().state;
              if (currentState is PlazoletaLoaded) {
                return _mainView(currentState);
              }
            }
            return _loading();
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
        MallBackground(
          skylightCtrl: _skylightCtrl!,
          ambientCtrl: _ambientCtrl!,
        ),

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
                    painter: MallWorldPainter(
                      plazas: _plazas.map(_toPlazaData).toList(),
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

        _header(state),

        _mapControls(),

        if (hasPanel) ...[
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
                child: PlazoletaDetailPanel(
                  plaza: sel.toPlazaDetail(),
                  state: state,
                  onClose: () => _select(sel.index),
                  onEnter: () {
                    if (sel.data != null) _goToDetail(sel.data!.id);
                  },
                ),
              );
            },
          ),
        ],

        Positioned(
          bottom: hasPanel ? 250 : 24,
          right: 22,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: ProfileFloatingButton(hidePlazoletasOption: true),
          ),
        ),

        _hint(),
      ],
    );
  }

  // ── UI WIDGETS ────────────────────────────────────────────

  Widget _header(PlazoletaLoaded state) {
    final theme = Theme.of(context);
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
                  theme.colorScheme.surface.withValues(alpha: 0.96),
                  theme.colorScheme.surface.withValues(alpha: 0.0),
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: _kGold.withValues(alpha: 0.18),
                  width: 1,
                ),
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
                          'PASEO DEL COMERCIO',
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
                            '${state.plazoletas.length} plazoletas  •  Centro Comercial Virtual',
                            style: TextStyle(
                              color: _kGold.withValues(alpha: 0.65),
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

  Widget _mapControls() {
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
            _mapBtn(Icons.remove, () => _animateZoom(_scale / 1.4)),
            Container(
              width: 1,
              height: 24,
              color: accentColor.withValues(alpha: 0.2),
            ),
            _mapBtn(Icons.add, () => _animateZoom(_scale * 1.4)),
            Container(
              width: 1,
              height: 24,
              color: accentColor.withValues(alpha: 0.2),
            ),
            _mapBtn(
              Icons.center_focus_strong_rounded,
              _resetView,
              accent: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _mapBtn(IconData icon, VoidCallback onTap, {bool accent = false}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? _kGold : const Color(0xFFB8860B);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color:
              accent ? accentColor.withValues(alpha: 0.18) : Colors.transparent,
          borderRadius: accent ? BorderRadius.circular(8) : BorderRadius.zero,
          border: Border.all(
            color:
                accent
                    ? accentColor.withValues(alpha: 0.55)
                    : Colors.transparent,
            width: accent ? 1 : 0,
          ),
        ),
        child: Icon(icon, color: accentColor, size: 18),
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iconColor = isDark ? _kGold : const Color(0xFFB8860B);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color:
              isDark
                  ? theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.88,
                  )
                  : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: iconColor.withValues(alpha: 0.30)),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
    );
  }

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

  Widget _loading() {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
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
                color: _kGold.withValues(alpha: 0.8),
                fontSize: 13,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _error(PlazoletaErrorState s) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              color: theme.colorScheme.error.withValues(alpha: 0.6),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
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
}
