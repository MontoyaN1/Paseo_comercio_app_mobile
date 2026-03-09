// lib/presentation/pages/organizaciones/organizacion_list_page.dart
//
// 🏛️  PLAZA UNIVERSE — Organizaciones de Lujo
// ────────────────────────────────────────────────────────────
//  ESTÉTICA: Coherente con login_page.dart
//  • Fondo: partículas isométricas flotantes + haces de luz
//  • AppBar: glassmorphism con borde dorado
//  • Cards: glassmorphism con hover glow dorado
//  • Chips de filtro: estilo dorado sobre oscuro
//  • Búsqueda: campo con glow dorado al focus
//  • Stats: íconos y valores en paleta dorada
//  • Loading: spinner dorado pulsante
// ────────────────────────────────────────────────────────────

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../domain/entities/organizacion.dart';
import '../../../../domain/entities/enums.dart';
import '../../../../presentation/blocs/organizacion/organizacion_bloc.dart';
import '../../../../presentation/widgets/profile_floating_button.dart';

// ── Paleta (igual que login_page) ─────────────────────────────
const _kGold = Color(0xFFD4AF37);
const _kGoldLight = Color(0xFFFFE082);
const _kGoldDeep = Color(0xFF9C7A1A);
const _kBg = Color(0xFF07070F);
const _kSurface = Color(0xFF0F0F1E);
const _kSurfaceCard = Color(0xFF12121F);
const _kBorder = Color(0xFF1E1E3A);
const _kHint = Color(0xFF6B6B8A);
const _kTextPrimary = Colors.white;

// ══════════════════════════════════════════════════════════════
//  PAGE PRINCIPAL
// ══════════════════════════════════════════════════════════════
class OrganizacionListPage extends StatefulWidget {
  const OrganizacionListPage({super.key});

  @override
  State<OrganizacionListPage> createState() => _OrganizacionListPageState();
}

class _OrganizacionListPageState extends State<OrganizacionListPage>
    with TickerProviderStateMixin {
  // ── Scroll / búsqueda ─────────────────────────────────────
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  bool _isSearching = false;
  bool _searchFocused = false;
  TipoOrganizacion? _selectedTipoFilter;
  int _currentPage = 1;
  final int _limit = 20;
  DateTime? _lastResetAttempt;
  bool _isResetting = false;

  // ── Animaciones ───────────────────────────────────────────
  late final AnimationController _bgCtrl;
  late final AnimationController _listCtrl;
  late final AnimationController _searchFocusCtrl;

  late final Animation<double> _searchGlow;

  @override
  void initState() {
    super.initState();

    // Fondo continuo (idéntico al login)
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    // Shimmer de focus en búsqueda
    _searchFocusCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _searchGlow = CurvedAnimation(
      parent: _searchFocusCtrl,
      curve: Curves.easeOut,
    );

    // Stagger entrada de la lista
    _listCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _resetToInitial();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recargar automáticamente cuando la página se vuelve a mostrar
    // (por ejemplo, al regresar de otra pantalla)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Usar lógica inteligente para recargar cuando sea necesario
        _reloadOrganizationsIfNeeded();
      }
    });
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _listCtrl.dispose();
    _searchFocusCtrl.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ── Lógica de datos ───────────────────────────────────────
  void _loadOrganizaciones() {
    final bloc = context.read<OrganizacionBloc>();
    if (!bloc.isClosed) {
      bloc.add(LoadOrganizaciones(page: _currentPage, limit: _limit));
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreOrganizaciones();
    }
  }

  void _loadMoreOrganizaciones() {
    final bloc = context.read<OrganizacionBloc>();
    if (bloc.isClosed) return;
    final state = bloc.state;
    if (state is OrganizacionLoaded && state.hasMore) {
      _currentPage++;
      if (!bloc.isClosed) {
        bloc.add(LoadOrganizaciones(page: _currentPage, limit: _limit));
      }
    }
  }

  void _onSearchChanged(String query) {
    final bloc = context.read<OrganizacionBloc>();
    if (bloc.isClosed) return;
    if (query.isNotEmpty) {
      bloc.add(SearchOrganizaciones(query: query));
    } else {
      _resetToInitial();
    }
  }

  void _onTipoFilterChanged(TipoOrganizacion? tipo) {
    setState(() => _selectedTipoFilter = tipo);
    final bloc = context.read<OrganizacionBloc>();
    if (bloc.isClosed) return;
    if (tipo != null) {
      bloc.add(FilterByTipo(tipo: tipo));
    } else {
      _resetToInitial();
    }
  }

  void _onOrganizacionTap(Organizacion organizacion) {
    context.push('/organizaciones/${organizacion.id}', extra: organizacion);
  }

  void _onRefresh() {
    _currentPage = 1;
    _loadOrganizaciones();
  }

  void _resetToInitial() {
    // Evitar múltiples reset en rápida sucesión (menos de 1 segundo)
    if (_lastResetAttempt != null) {
      final secondsSinceLastAttempt =
          DateTime.now().difference(_lastResetAttempt!).inSeconds;
      if (secondsSinceLastAttempt < 1) {
        return;
      }
    }

    // Evitar reset si ya se está ejecutando
    if (_isResetting) {
      return;
    }

    _lastResetAttempt = DateTime.now();
    _isResetting = true;

    final bloc = context.read<OrganizacionBloc>();
    if (bloc.isClosed) {
      _isResetting = false;
      return;
    }

    // Siempre resetear cuando se llama a esta función
    // Esto asegura que los datos se carguen frescos
    bloc.add(const ResetOrganizacionState());
    _currentPage = 1;
    _loadOrganizaciones();

    // Resetear el flag después de un tiempo para permitir nuevas recargas
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _isResetting = false;
      }
    });
  }

  void _reloadOrganizationsIfNeeded() {
    final bloc = context.read<OrganizacionBloc>();
    if (bloc.isClosed) return;
    final state = bloc.state;

    // Recargar siempre que se detecte que la página necesita datos frescos
    // Esto incluye: estado inicial, error, o lista vacía por falta de datos
    bool needsReload = false;

    if (state is OrganizacionInitial) {
      // Siempre recargar en estado inicial
      needsReload = true;
    } else if (state is OrganizacionErrorState) {
      // Recargar si hay error
      needsReload = true;
    } else if (state is OrganizacionLoaded) {
      // Recargar solo si la lista está vacía por falta de datos
      if (state.organizaciones.isEmpty) {
        needsReload = true;
      }
    }
    // No recargar para estados de búsqueda o filtro - el usuario decidirá

    if (needsReload) {
      // Usar un pequeño delay para asegurar que la UI se actualice primero
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _resetToInitial();
        }
      });
    }
  }

  // ── Helpers ───────────────────────────────────────────────
  String _getDescripcionTipo(TipoOrganizacion tipo) {
    switch (tipo) {
      case TipoOrganizacion.fundacion:
        return 'Fundación';
      case TipoOrganizacion.asociacion:
        return 'Asociación';
      case TipoOrganizacion.cooperativa:
        return 'Cooperativa';
      case TipoOrganizacion.empresa:
        return 'Empresa';
      case TipoOrganizacion.comunidad:
        return 'Comunidad';
      case TipoOrganizacion.otro:
        return 'Otra';
    }
  }

  String _getIconoTipo(TipoOrganizacion tipo) {
    switch (tipo) {
      case TipoOrganizacion.fundacion:
        return '🏛️';
      case TipoOrganizacion.asociacion:
        return '🤝';
      case TipoOrganizacion.cooperativa:
        return '👥';
      case TipoOrganizacion.empresa:
        return '🏢';
      case TipoOrganizacion.comunidad:
        return '🏘️';
      case TipoOrganizacion.otro:
        return '🏠';
    }
  }

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) hexColor = 'FF$hexColor';
    return Color(int.parse(hexColor, radix: 16));
  }

  // ══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    // Recargar automáticamente cuando la página se construye
    // Esto cubre el caso de volver desde otra página
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Al volver de otra página, verificar si necesitamos recargar
        _reloadOrganizationsIfNeeded();
      }
    });

    return BlocConsumer<OrganizacionBloc, OrganizacionState>(
      listener: (context, state) {
        if (state is OrganizacionErrorState) {
          _showGoldSnackBar(state.message, isError: true);
        }
        if (state is OrganizacionLoaded) {
          _listCtrl.forward(from: 0);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: _kBg,
          body: Stack(
            children: [
              // ── Fondo animado (idéntico al login) ───────────
              AnimatedBuilder(
                animation: _bgCtrl,
                builder:
                    (_, __) => CustomPaint(
                      size: MediaQuery.of(context).size,
                      painter: _BgPainter(_bgCtrl.value),
                    ),
              ),

              // ── Contenido ───────────────────────────────────
              SafeArea(
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildFilterBar(),
                    Expanded(child: _buildBody(state)),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: ProfileFloatingButton(
            hideOrganizacionesOption: true,
          ),
        );
      },
    );
  }

  // ── AppBar glassmorphism ──────────────────────────────────
  Widget _buildHeader() {
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: _kSurface.withOpacity(0.82),
            border: Border(bottom: BorderSide(color: _kBorder, width: 1)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 16, 14),
          child: Row(
            children: [
              // Título o campo de búsqueda
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  transitionBuilder:
                      (child, anim) => FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.05, 0),
                            end: Offset.zero,
                          ).animate(anim),
                          child: child,
                        ),
                      ),
                  child: _isSearching ? _buildSearchField() : _buildTitleRow(),
                ),
              ),
              const SizedBox(width: 8),
              // Botón buscar / cerrar
              _GoldIconButton(
                icon: _isSearching ? Icons.close_rounded : Icons.search_rounded,
                onTap: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchController.clear();
                      _searchFocusCtrl.reverse();
                      _resetToInitial();
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleRow() {
    return Row(
      key: const ValueKey('title'),
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _kGold.withOpacity(0.55), width: 1.4),
            color: _kGold.withOpacity(0.08),
          ),
          child: const Icon(
            Icons.account_balance_rounded,
            color: _kGold,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask(
              shaderCallback:
                  (b) => const LinearGradient(
                    colors: [_kGoldDeep, _kGold, _kGoldLight],
                  ).createShader(b),
              child: const Text(
                'Organizaciones',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Text(
              'Paseo del Comercio',
              style: TextStyle(color: _kHint, fontSize: 11, letterSpacing: 1.5),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return AnimatedBuilder(
      animation: _searchGlow,
      builder:
          (_, child) => Container(
            key: const ValueKey('search'),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: _kGold.withOpacity(0.20 * _searchGlow.value),
                  blurRadius: 14 * _searchGlow.value + 1,
                  spreadRadius: _searchGlow.value,
                ),
              ],
            ),
            child: child,
          ),
      child: Focus(
        onFocusChange: (focused) {
          setState(() => _searchFocused = focused);
          focused ? _searchFocusCtrl.forward() : _searchFocusCtrl.reverse();
        },
        child: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          cursorColor: _kGold,
          decoration: InputDecoration(
            hintText: 'Buscar organizaciones...',
            hintStyle: TextStyle(color: _kHint, fontSize: 14),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: _searchFocused ? _kGold : _kHint,
              size: 20,
            ),
            filled: true,
            fillColor: Colors.black.withOpacity(0.30),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _kBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _kBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _kGold, width: 1.5),
            ),
          ),
          onChanged: _onSearchChanged,
        ),
      ),
    );
  }

  // ── Barra de filtros dorada ───────────────────────────────
  Widget _buildFilterBar() {
    return Container(
      decoration: BoxDecoration(
        color: _kSurface.withOpacity(0.70),
        border: Border(bottom: BorderSide(color: _kBorder, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _GoldFilterChip(
              label: 'Todas',
              selected: _selectedTipoFilter == null,
              onSelected: () => _onTipoFilterChanged(null),
            ),
            const SizedBox(width: 8),
            ...TipoOrganizacion.values.map(
              (tipo) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _GoldFilterChip(
                  label: _getDescripcionTipo(tipo),
                  emoji: _getIconoTipo(tipo),
                  selected: _selectedTipoFilter == tipo,
                  onSelected: () => _onTipoFilterChanged(tipo),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Body ─────────────────────────────────────────────────
  Widget _buildBody(OrganizacionState state) {
    // Si está en estado inicial, cargar automáticamente las organizaciones
    if (state is OrganizacionInitial) {
      // Cargar organizaciones inmediatamente y mostrar loader
      // Usar lógica inteligente para evitar múltiples recargas
      _reloadOrganizationsIfNeeded();
      return const _GoldLoader();
    }

    if (state is OrganizacionLoading) {
      return const _GoldLoader();
    }

    if (state is OrganizacionErrorState) {
      return _buildErrorState(state.message);
    }

    List<Organizacion> organizaciones = [];
    bool hasMore = false;

    if (state is OrganizacionLoaded) {
      organizaciones = state.organizaciones;
      hasMore = state.hasMore;
    } else if (state is OrganizacionSearchApplied) {
      organizaciones = state.resultados;
    } else if (state is OrganizacionFilterApplied) {
      organizaciones = state.organizacionesFiltradas;
    }

    // Si la lista está vacía, determinar si es por falta de datos o por búsqueda/filtro
    if (organizaciones.isEmpty) {
      // Distinguir entre diferentes casos de lista vacía
      if (state is OrganizacionLoaded) {
        // Lista vacía por falta de datos - recargar automáticamente
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _resetToInitial();
          }
        });
        return const _GoldLoader();
      } else if (state is OrganizacionSearchApplied ||
          state is OrganizacionFilterApplied) {
        // Lista vacía por búsqueda o filtro - mostrar estado vacío apropiado
        return _buildEmptyState(isFiltered: true);
      } else {
        // Otro caso - mostrar estado vacío normal
        return _buildEmptyState(isFiltered: false);
      }
    }

    return RefreshIndicator(
      color: _kGold,
      backgroundColor: _kSurface,
      onRefresh: () async => _onRefresh(),
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        itemCount: organizaciones.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == organizaciones.length) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: _GoldLoader(),
            );
          }
          final org = organizaciones[index];
          return AnimatedBuilder(
            animation: _listCtrl,
            builder: (_, child) {
              final delay = (index * 0.07).clamp(0.0, 0.7);
              final progress = Curves.easeOutCubic.transform(
                (((_listCtrl.value - delay) / (1 - delay)).clamp(0.0, 1.0)),
              );
              return Opacity(
                opacity: progress,
                child: Transform.translate(
                  offset: Offset(0, 30 * (1 - progress)),
                  child: child,
                ),
              );
            },
            child: _OrganizacionCard(
              organizacion: org,
              onTap: () => _onOrganizacionTap(org),
              getDescripcionTipo: _getDescripcionTipo,
              getColorFromHex: _getColorFromHex,
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withOpacity(0.08),
              border: Border.all(color: Colors.red.withOpacity(0.25)),
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 36,
              color: Colors.red[400],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Error al cargar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.red[300],
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              message,
              style: const TextStyle(fontSize: 13, color: _kHint),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 22),
          _GoldOutlineButton(label: 'Reintentar', onTap: _onRefresh),
        ],
      ),
    );
  }

  Widget _buildEmptyState({bool isFiltered = false}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _kGold.withOpacity(0.06),
              border: Border.all(color: _kGold.withOpacity(0.22), width: 1.5),
            ),
            child: const Icon(
              Icons.account_balance_rounded,
              size: 36,
              color: _kGold,
            ),
          ),
          const SizedBox(height: 18),
          ShaderMask(
            shaderCallback:
                (b) => const LinearGradient(
                  colors: [_kGoldDeep, _kGold, _kGoldLight],
                ).createShader(b),
            child: const Text(
              'Sin organizaciones',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isFiltered
                ? (_selectedTipoFilter != null
                    ? 'No hay resultados para este filtro'
                    : 'No se encontraron resultados para la búsqueda')
                : 'No se encontraron organizaciones',
            style: const TextStyle(fontSize: 13, color: _kHint),
          ),
          const SizedBox(height: 22),
          _GoldOutlineButton(
            label: isFiltered ? 'Limpiar' : 'Recargar',
            onTap: isFiltered ? () => _onTipoFilterChanged(null) : _onRefresh,
          ),
        ],
      ),
    );
  }

  void _showGoldSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? const Color(0xFF1A0808) : _kSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isError ? Colors.red.withOpacity(0.35) : _kBorder,
          ),
        ),
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.info_outline_rounded,
              color: isError ? Colors.red[300] : _kGold,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: isError ? Colors.red[300] : Colors.white70,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  FONDO: idéntico al login_page (partículas isométricas)
// ══════════════════════════════════════════════════════════════
class _BgPainter extends CustomPainter {
  final double t;
  _BgPainter(this.t);

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

    final tW = w * 0.18;
    final tH = tW * 0.5;
    for (int row = -1; row <= 14; row++) {
      for (int col = -1; col <= 6; col++) {
        final cx = (col - row) * tW / 2 + w * 0.5;
        final cy = (col + row) * tH / 2 - t * tH * 0.5;
        final pulse = math.sin(t * math.pi * 2 + col * 0.4 + row * 0.3) * 0.012;
        final alpha = (0.05 + pulse).clamp(0.0, 0.10);
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
        if (row % 3 == 0) {
          canvas.drawPath(
            path,
            Paint()..color = _kGold.withOpacity(alpha * 0.22),
          );
        }
      }
    }

    const colors = [_kGold, _kGoldLight, Colors.white];
    for (final p in _particles) {
      final phase = (t + p[2]) % 1.0;
      final op = math.sin(phase * math.pi) * 0.30;
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

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 0.78,
          colors: [Colors.transparent, Colors.black.withOpacity(0.72)],
          stops: const [0.5, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    final linePaint =
        Paint()
          ..color = _kGold.withOpacity(0.03)
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
//  CARD DE ORGANIZACIÓN — glassmorphism + glow dorado
// ══════════════════════════════════════════════════════════════
class _OrganizacionCard extends StatefulWidget {
  final Organizacion organizacion;
  final VoidCallback onTap;
  final String Function(TipoOrganizacion) getDescripcionTipo;
  final Color Function(String) getColorFromHex;

  const _OrganizacionCard({
    required this.organizacion,
    required this.onTap,
    required this.getDescripcionTipo,
    required this.getColorFromHex,
  });

  @override
  State<_OrganizacionCard> createState() => _OrganizacionCardState();
}

class _OrganizacionCardState extends State<_OrganizacionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hoverCtrl;
  late final Animation<double> _hoverAnim;

  @override
  void initState() {
    super.initState();
    _hoverCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _hoverAnim = CurvedAnimation(parent: _hoverCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _hoverCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final org = widget.organizacion;
    final typeColor = widget.getColorFromHex(org.colorTipo);

    return GestureDetector(
      onTapDown: (_) => _hoverCtrl.forward(),
      onTapUp: (_) {
        _hoverCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _hoverCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _hoverAnim,
        builder:
            (_, child) => Transform.scale(
              scale: 1.0 - (_hoverAnim.value * 0.015),
              child: Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: _kGold.withOpacity(0.05 + _hoverAnim.value * 0.12),
                      blurRadius: 20 + _hoverAnim.value * 16,
                      spreadRadius: _hoverAnim.value * 2,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.45),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: child,
              ),
            ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(
                color: _kSurfaceCard.withOpacity(0.90),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _kBorder, width: 1.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Franja superior de acento de color
                  Container(
                    height: 3,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          _kGold.withOpacity(0.7),
                          typeColor.withOpacity(0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Logo + nombre + descripción ───────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Avatar con borde dorado
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: typeColor.withOpacity(0.08),
                                border: Border.all(
                                  color: _kGold.withOpacity(0.30),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _kGold.withOpacity(0.10),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child:
                                    org.logoUrlPrincipal != null
                                        ? Image.network(
                                          org.logoUrlPrincipal!,
                                          width: 58,
                                          height: 58,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (_, __, ___) => Center(
                                                child: Text(
                                                  org.iconoTipo,
                                                  style: const TextStyle(
                                                    fontSize: 26,
                                                  ),
                                                ),
                                              ),
                                        )
                                        : Center(
                                          child: Text(
                                            org.iconoTipo,
                                            style: const TextStyle(
                                              fontSize: 26,
                                            ),
                                          ),
                                        ),
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Nombre
                                  Text(
                                    org.nombreParaMostrar,
                                    style: const TextStyle(
                                      color: _kTextPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),

                                  // Descripción
                                  Text(
                                    org.descripcion ?? 'Sin descripción',
                                    style: const TextStyle(
                                      color: _kHint,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 10),

                                  // Badge de tipo
                                  _TypeBadge(
                                    label: widget.getDescripcionTipo(org.tipo),
                                    color: typeColor,
                                  ),
                                ],
                              ),
                            ),

                            // Flecha
                            const Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: _kGold,
                                size: 14,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // ── Separador ─────────────────────────
                        Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                _kBorder,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ── Stats ─────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _GoldStatItem(
                              icon: Icons.store_rounded,
                              value: org.totalTiendas ?? 0,
                              label: 'Tiendas',
                            ),
                            Container(width: 1, height: 28, color: _kBorder),
                            _GoldStatItem(
                              icon: Icons.people_alt_rounded,
                              value: org.totalMiembros ?? 0,
                              label: 'Miembros',
                            ),
                          ],
                        ),
                      ],
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

// ── Badge de tipo con glow sutil ──────────────────────────────
class _TypeBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _TypeBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _kGold.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kGold.withOpacity(0.30), width: 1),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _kGold,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ── Stat con ícono dorado ─────────────────────────────────────
class _GoldStatItem extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;
  const _GoldStatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: _kGold.withOpacity(0.75)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: _kHint,
                  fontSize: 11,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  CHIP DE FILTRO DORADO
// ══════════════════════════════════════════════════════════════
class _GoldFilterChip extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final String? emoji;
  const _GoldFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.emoji,
  });

  @override
  State<_GoldFilterChip> createState() => _GoldFilterChipState();
}

class _GoldFilterChipState extends State<_GoldFilterChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: widget.selected ? 1.0 : 0.0,
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void didUpdateWidget(_GoldFilterChip old) {
    super.didUpdateWidget(old);
    if (widget.selected != old.selected) {
      widget.selected ? _ctrl.forward() : _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onSelected,
      child: AnimatedBuilder(
        animation: _anim,
        builder:
            (_, __) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Color.lerp(
                  Colors.black.withOpacity(0.22),
                  _kGold.withOpacity(0.14),
                  _anim.value,
                ),
                border: Border.all(
                  color:
                      Color.lerp(
                        _kBorder,
                        _kGold.withOpacity(0.70),
                        _anim.value,
                      )!,
                  width: 1.0 + _anim.value * 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _kGold.withOpacity(0.12 * _anim.value),
                    blurRadius: 8 * _anim.value,
                    spreadRadius: _anim.value,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.emoji != null) ...[
                    Text(widget.emoji!, style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 5),
                  ],
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: Color.lerp(_kHint, _kGold, _anim.value),
                      fontSize: 13,
                      fontWeight:
                          widget.selected ? FontWeight.w700 : FontWeight.w400,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  COMPONENTES AUXILIARES
// ══════════════════════════════════════════════════════════════

class _GoldIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GoldIconButton({required this.icon, required this.onTap});

  @override
  State<_GoldIconButton> createState() => _GoldIconButtonState();
}

class _GoldIconButtonState extends State<_GoldIconButton>
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
      end: 0.88,
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
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder:
            (_, __) => Transform.scale(
              scale: _scale.value,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kGold.withOpacity(0.07),
                  border: Border.all(color: _kGold.withOpacity(0.28), width: 1),
                ),
                child: Icon(widget.icon, color: _kGold, size: 20),
              ),
            ),
      ),
    );
  }
}

class _GoldOutlineButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _GoldOutlineButton({required this.label, required this.onTap});

  @override
  State<_GoldOutlineButton> createState() => _GoldOutlineButtonState();
}

class _GoldOutlineButtonState extends State<_GoldOutlineButton>
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
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder:
            (_, __) => Transform.scale(
              scale: _scale.value,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _kGold.withOpacity(0.55),
                    width: 1.5,
                  ),
                  color: _kGold.withOpacity(0.06),
                ),
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    color: _kGold,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
      ),
    );
  }
}

// ── Loader con spinner dorado ─────────────────────────────────
class _GoldLoader extends StatelessWidget {
  const _GoldLoader();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 36,
        height: 36,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(_kGold),
        ),
      ),
    );
  }
}
