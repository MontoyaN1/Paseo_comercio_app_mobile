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
import '../../widgets/plazoleta/list/plazoleta_detail_panel.dart';
import '../../widgets/plazoleta/list/plazoleta_list_header.dart';
import '../../widgets/plazoleta/list/plazoleta_list_loading.dart';
import '../../widgets/plazoleta/list/plazoleta_list_error.dart';
import '../../widgets/plazoleta/list/plazoleta_list_hint.dart';
import '../../widgets/plazoleta/list/plazoleta_list_map_controls.dart';
import '../../widgets/shared/profile_floating_button.dart';

// ══════════════════════════════════════════════════════════════
//  PALETA DE LUJO (branding - no theme)
// ══════════════════════════════════════════════════════════════
const _kGold = Color(0xFFD4AF37);

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
  Offset _pan = Offset(0.0, -_kOriginOffsetY * 3.0);
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
      // No recargar automáticamente para evitar molestar al usuario
      // El usuario puede hacer pull-to-refresh si quiere actualizar
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

    final newScale = _initScale;
    final targetPan = Offset(0.0, -_kOriginOffsetY * 3.0);

    _scaleAnim = Tween<double>(
      begin: _scale,
      end: newScale,
    ).animate(CurvedAnimation(parent: _navCtrl!, curve: Curves.easeOutCubic));

    _panAnim = Tween<Offset>(
      begin: _pan,
      end: targetPan,
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
              return const PlazoletaListLoading();
            if (s is PlazoletaErrorState)
              return PlazoletaListError(
                message: s.message,
                onRetry: _onRefresh,
              );
            if (s is PlazoletaLoaded) return _mainView(s);
            if (_plazas.isNotEmpty) {
              final currentState = getIt<PlazoletaBloc>().state;
              if (currentState is PlazoletaLoaded) {
                return _mainView(currentState);
              }
            }
            return const PlazoletaListLoading();
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

        PlazoletaListHeader(
          plazoletasCount: state.plazoletas.length,
          onRefresh: _onRefresh,
        ),

        PlazoletaListMapControls(
          scale: _scale,
          onZoomIn: () => _animateZoom(_scale * 1.4),
          onZoomOut: () => _animateZoom(_scale / 1.4),
          onResetView: _resetView,
        ),

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

        PlazoletaListHint(introCtrl: _introCtrl!),
      ],
    );
  }
}
