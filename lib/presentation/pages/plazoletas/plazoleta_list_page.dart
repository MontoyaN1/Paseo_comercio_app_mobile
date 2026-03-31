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
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../di/service_locator.dart';
import '../../../domain/entities/plazoleta.dart';
import '../../../domain/entities/enums.dart';
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
  AnimationController? _skylightCtrl; // luz cenital independiente
  AnimationController? _navCtrl; // animaciones de navegación (zoom/centrar)
  bool _initialized = false;

  // Subscription para escuchar cambios de autenticación
  StreamSubscription<User?>? _authSubscription;

  // Navegación
  double _scale = 0.72;
  Offset _pan = Offset.zero;
  double _baseSc = 0.72;
  Offset _basePan = Offset.zero;
  Offset _focal = Offset.zero;
  Offset _worldFocalAtStart = Offset.zero;

  Offset _velocity = Offset.zero;
  DateTime _lastPanTime = DateTime.now();

  // Animación de navegación
  Animation<double>? _scaleAnim;
  Animation<Offset>? _panAnim;

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
    _navCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _navCtrl!.addListener(_updateNavAnimation);
    _initialized = true;

    // Registrar observer para detectar cuando la app vuelve al primer plano
    WidgetsBinding.instance.addObserver(this);

    // Escuchar cambios de autenticación para recargar datos
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((
      User? user,
    ) {
      // Cuando el estado de auth cambia, recargar plazoletas
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
    // Cuando la app vuelve al primer plano, recargar plazoletas
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
    _navCtrl?.stop(); // Detener animaciones de navegación al comenzar gesto
    _baseSc = _scale;
    _basePan = _pan;
    _focal = d.localFocalPoint;
    _velocity = Offset.zero;
    _lastPanTime = DateTime.now();

    // Convertir el punto táctil a coordenadas del mundo
    // Nota: _screenToWorld ya considera _kOriginOffsetY
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
        // Zoom: mantener el punto del mundo fijo bajo los dedos
        // Fórmula: newPan = currentFocalPoint - worldPoint * newScale - center
        // IMPORTANTE: centerY incluye _kOriginOffsetY para la proyección isométrica
        final centerX = size.width / 2;
        final centerY = size.height / 2 + _kOriginOffsetY;

        // El punto del mundo que estaba bajo los dedos al inicio del gesto
        final worldPoint = _worldFocalAtStart;

        // Calcular el pan necesario para que worldPoint se proyecte a d.localFocalPoint con newScale
        final requiredPanX =
            d.localFocalPoint.dx - worldPoint.dx * newScale - centerX;
        // Ajuste para compensar desfase vertical en proyección isométrica
        // Usar la relación tH/tW = 55/110 = 0.5 de la transformación isométrica
        final verticalCompensation = 0.9; // tH/tW ratio
        final adjustedWorldY = worldPoint.dy * verticalCompensation;
        final requiredPanY =
            d.localFocalPoint.dy - adjustedWorldY * newScale - centerY;

        _pan = Offset(requiredPanX, requiredPanY);
      } else {
        // Pan puro: delta absoluto desde inicio del gesto
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

    // Zoom simple: mantener el mismo punto relativo fijo
    // Para zoom desde el centro de la vista actual
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

  void _goToDetail(int id) async {
    await context.push('/plazoletas/$id');

    // Al regresar, forzar recarga fresca
    if (mounted) {
      getIt<PlazoletaBloc>().add(
        const LoadPlazoletasActivas(page: 1, limit: 20, forceRefresh: true),
      );
    }
  }

  // ══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        backgroundColor: _kBg,
        body: Center(
          child: CircularProgressIndicator(color: _kGold, strokeWidth: 2),
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _kBg,
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
            // Para otros estados (PlazoletaInitial, PlazoletaSelected, etc.)
            // mostrar loading si no hay plazas ya cargadas
            if (_plazas.isNotEmpty) {
              // Reutilizar la vista principal con los datos existentes
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
                child: _DetailPanel(
                  plaza: sel,
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

        // ── FAB perfil ───────────────────────────────────────
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
    top: MediaQuery.of(context).padding.top + 120,
    child: Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E1E).withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kGold.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
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
          Container(width: 1, height: 24, color: _kGold.withOpacity(0.2)),
          _mapBtn(Icons.add, () => _animateZoom(_scale * 1.4)),
          Container(width: 1, height: 24, color: _kGold.withOpacity(0.2)),
          _mapBtn(Icons.center_focus_strong_rounded, _resetView, accent: true),
        ],
      ),
    ),
  );

  Widget _mapBtn(IconData icon, VoidCallback onTap, {bool accent = false}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: accent ? _kGold.withOpacity(0.18) : Colors.transparent,
            borderRadius: accent ? BorderRadius.circular(8) : BorderRadius.zero,
            border: Border.all(
              color: accent ? _kGold.withOpacity(0.55) : Colors.transparent,
              width: accent ? 1 : 0,
            ),
          ),
          child: Icon(icon, color: _kGold, size: 18),
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
        if (img.entidadRelacionadaId == d.id && img.esPrincipal) {
          return img.urlPreferida;
        }
      }
      for (final img in state.imagenesPlazoleta!) {
        if (img.entidadRelacionadaId == d.id) return img.urlPreferida;
      }
    }
    return null;
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
                        if (d.tipoUbicacion == TipoUbicacion.zonaComida)
                          _iconBadge(Icons.restaurant_outlined, acc),
                        if (d.tipoUbicacion ==
                            TipoUbicacion.estacionamiento) ...[
                          const SizedBox(width: 4),
                          _iconBadge(Icons.local_parking, acc),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      d.nombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    if ((d.descripcion ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 10,
                            color: acc.withOpacity(0.75),
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              d.descripcion ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.48),
                                fontSize: 10,
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
                    height: 38,
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
