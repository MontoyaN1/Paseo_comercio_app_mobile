// lib/presentation/pages/organizaciones/organizacion_detail_page.dart
//
// 🏛️  PLAZA UNIVERSE — Detalle de Organización
// ────────────────────────────────────────────────────────────
//  DISEÑO:
//  • Hero header: imagen/logo con overlay degradado dorado
//  • Fondo: partículas isométricas flotantes (mismo que login)
//  • SliverAppBar colapsable con glassmorphism al hacer scroll
//  • Tabs glassmorphism: Información y Tiendas
//  • Stats con glow dorado animado
//  • Cards de tiendas: glassmorphism + hover glow
//  • Info de contacto: filas elegantes sobre fondo oscuro
// ────────────────────────────────────────────────────────────

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../domain/entities/organizacion.dart';
import '../../../../domain/entities/enums.dart';
import '../../../../presentation/blocs/organizacion/organizacion_bloc.dart';
import '../../../../core/app/app_config.dart';
import '../../widgets/profile_floating_button.dart';

// ── Paleta (idéntica al sistema de diseño) ────────────────────
const _kGold = Color(0xFFD4AF37);
const _kGoldLight = Color(0xFFFFE082);
const _kGoldDeep = Color(0xFF9C7A1A);
const _kBg = Color(0xFF07070F);
const _kSurface = Color(0xFF0F0F1E);
const _kSurfaceCard = Color(0xFF12121F);
const _kBorder = Color(0xFF1E1E3A);
const _kHint = Color(0xFF6B6B8A);

// ══════════════════════════════════════════════════════════════
//  PAGE PRINCIPAL
// ══════════════════════════════════════════════════════════════
class OrganizacionDetailPage extends StatefulWidget {
  final int organizacionId;
  final Organizacion? organizacion;

  const OrganizacionDetailPage({
    super.key,
    required this.organizacionId,
    this.organizacion,
  });

  @override
  State<OrganizacionDetailPage> createState() => _OrganizacionDetailPageState();
}

class _OrganizacionDetailPageState extends State<OrganizacionDetailPage>
    with TickerProviderStateMixin {
  // ── Controllers ───────────────────────────────────────────
  late final TabController _tabController;
  final _scrollController = ScrollController();
  final AppConfig _appConfig = AppConfig();
  bool _hasLoaded = false;

  // ── Animaciones ───────────────────────────────────────────
  late final AnimationController _bgCtrl;
  late final AnimationController _heroCtrl;
  late final AnimationController _contentCtrl;

  late final Animation<double> _heroFade;
  late final Animation<double> _heroScale;
  late final Animation<double> _contentSlide;
  late final Animation<double> _contentFade;

  // ── Scroll state para AppBar ──────────────────────────────
  double _scrollOffset = 0;
  static const double _heroHeight = 300;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Fondo continuo
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    // Hero entrada
    _heroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _heroFade = CurvedAnimation(
      parent: _heroCtrl,
      curve: const Interval(0.0, 0.6),
    );
    _heroScale = Tween<double>(
      begin: 1.08,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutCubic));

    // Contenido stagger
    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _contentSlide = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutCubic),
    );
    _contentFade = CurvedAnimation(
      parent: _contentCtrl,
      curve: const Interval(0.0, 0.7),
    );

    // Listener de scroll para AppBar
    _scrollController.addListener(() {
      setState(() => _scrollOffset = _scrollController.offset);
    });

    Future.delayed(const Duration(milliseconds: 120), () {
      _heroCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 380), () {
      _contentCtrl.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoaded) {
      _hasLoaded = true;
      final bloc = context.read<OrganizacionBloc>();
      if (bloc.isClosed) return;
      if (widget.organizacion != null) {
        bloc.add(
          LoadOrganizacionDetail(
            organizacionId: widget.organizacionId,
            organizacion: widget.organizacion!,
            loadTiendas: true,
            loadMiembros: false,
          ),
        );
      } else {
        bloc.add(
          LoadOrganizacionById(
            organizacionId: widget.organizacionId,
            loadTiendas: true,
            loadMiembros: false,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _bgCtrl.dispose();
    _heroCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────
  void _onShareOrganizacion() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _kSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: _kBorder),
        ),
        content: const Row(
          children: [
            Icon(Icons.share_rounded, color: _kGold, size: 18),
            SizedBox(width: 10),
            Text(
              'Compartir organización (pendiente)',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  void _onTiendaTap(Map<String, dynamic> tienda) {
    final tiendaId = tienda['id'];
    if (tiendaId != null) {
      context.push('/tiendas/$tiendaId');
    }
  }

  String? _getTiendaLogoUrl(Map<String, dynamic> tienda) {
    final imagenes = tienda['imagen_tienda'];
    String? rawUrl;
    if (imagenes != null) {
      if (imagenes is List && imagenes.isNotEmpty) {
        for (final imagen in imagenes) {
          if (imagen is Map<String, dynamic> &&
              imagen['tipo_imagen'] == 'logo') {
            rawUrl = imagen['url_imagen'] as String?;
            break;
          }
        }
        if (rawUrl == null) {
          final p = imagenes[0];
          if (p is Map<String, dynamic>) rawUrl = p['url_imagen'] as String?;
        }
      } else if (imagenes is Map<String, dynamic>) {
        rawUrl = imagenes['url_imagen'] as String?;
      }
    }
    if (rawUrl == null || rawUrl.isEmpty) {
      final logoUrl = tienda['logo_url'] ?? tienda['url_logo'];
      if (logoUrl is String && logoUrl.isNotEmpty) rawUrl = logoUrl;
    }
    if (rawUrl == null || rawUrl.isEmpty) return null;
    return _transformContaboUrlToR2(rawUrl);
  }

  String _getTiendaNombre(Map<String, dynamic> t) {
    final n = t['nombre'] ?? t['nombre_tienda'] ?? t['titulo'] ?? 'Tienda';
    if (n == 'Tienda' || n == 'Tienda sin nombre') {
      final id = t['id'] ?? t['tienda_id'];
      if (id != null) return 'Tienda $id';
    }
    return n;
  }

  String _getTiendaDescripcion(Map<String, dynamic> t) {
    final d =
        t['descripcion'] ??
        t['descripcion_tienda'] ??
        t['descripcion_corta'] ??
        'Sin descripción disponible';
    return d.length > 100 ? '${d.substring(0, 100)}...' : d;
  }

  String? _getTiendaCategoria(Map<String, dynamic> t) {
    final c =
        t['categoria'] ?? t['categoria_tienda'] ?? t['tipo'] ?? t['rubro'];
    if (c is String && c.isNotEmpty) return c;
    return null;
  }

  String _transformContaboUrlToR2(String url) {
    try {
      if (!url.contains('contabostorage.com')) return url;
      if (_appConfig.cloudflareR2PublicUrl.isEmpty) return url;
      final uri = Uri.parse(url);
      final segs = uri.pathSegments;
      final idx = segs.indexWhere((s) => s == 'paseocomercio');
      if (idx == -1 || idx >= segs.length - 1) return url;
      final rel = segs.sublist(idx + 1).join('/');
      String base = _appConfig.cloudflareR2PublicUrl.trim();
      if (base.endsWith('/')) base = base.substring(0, base.length - 1);
      return '$base/$rel';
    } catch (_) {
      return url;
    }
  }

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
        return 'Otra Organización';
    }
  }

  // ── Cuánto ha colapsado el hero (0..1) ────────────────────
  double get _collapseProgress =>
      (_scrollOffset / (_heroHeight - kToolbarHeight)).clamp(0.0, 1.0);

  // ══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrganizacionBloc, OrganizacionState>(
      builder: (context, state) {
        Organizacion? org;
        List<dynamic> tiendas = [];

        if (state is OrganizacionDetailLoaded) {
          org = state.organizacion;
          tiendas = state.tiendas ?? [];
        } else if (widget.organizacion != null) {
          org = widget.organizacion;
        }

        if (org == null) {
          return Scaffold(
            backgroundColor: _kBg,
            body: Stack(
              children: [
                AnimatedBuilder(
                  animation: _bgCtrl,
                  builder:
                      (_, __) => CustomPaint(
                        size: MediaQuery.of(context).size,
                        painter: _BgPainter(_bgCtrl.value),
                      ),
                ),
                const Center(
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(_kGold),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return _buildPage(context, org, tiendas);
      },
    );
  }

  Widget _buildPage(
    BuildContext context,
    Organizacion org,
    List<dynamic> tiendas,
  ) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          // ── Fondo animado ──────────────────────────────────
          AnimatedBuilder(
            animation: _bgCtrl,
            builder:
                (_, __) =>
                    CustomPaint(size: size, painter: _BgPainter(_bgCtrl.value)),
          ),

          // ── Contenido scrollable ───────────────────────────
          NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder:
                (context, innerBoxIsScrolled) => [
                  SliverToBoxAdapter(child: _buildHero(org)),
                ],
            body: Column(
              children: [
                _buildTabBar(org),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildInfoTab(org),
                      _buildTiendasTab(tiendas, org),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── AppBar flotante con glassmorphism ──────────────
          SafeArea(child: _buildFloatingAppBar(org)),
        ],
      ),
      floatingActionButton: ProfileFloatingButton(
        hideOrganizacionesOption: true,
      ),
    );
  }

  // ── AppBar glassmorphism que aparece al hacer scroll ──────
  Widget _buildFloatingAppBar(Organizacion org) {
    final opacity = _collapseProgress;
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20 * opacity, sigmaY: 20 * opacity),
        child: AnimatedContainer(
          duration: Duration.zero,
          height: kToolbarHeight,
          decoration: BoxDecoration(
            color: _kSurface.withOpacity(0.85 * opacity),
            border: Border(
              bottom: BorderSide(
                color: _kBorder.withOpacity(opacity),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 8),
              // Botón back
              _GoldIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () {
                  if (context.canPop()) {
                    Navigator.pop(context);
                  } else {
                    Future.microtask(() => context.go('/organizaciones'));
                  }
                },
              ),
              const SizedBox(width: 12),
              // Título que aparece al colapsar
              Expanded(
                child: AnimatedOpacity(
                  opacity: opacity,
                  duration: Duration.zero,
                  child: Text(
                    org.nombreParaMostrar,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              // Compartir
              _GoldIconButton(
                icon: Icons.share_rounded,
                onTap: _onShareOrganizacion,
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ── Hero expandible ───────────────────────────────────────
  Widget _buildHero(Organizacion org) {
    final logoUrl = org.logoUrlPrincipal;

    return AnimatedBuilder(
      animation: _heroCtrl,
      builder:
          (_, __) => Opacity(
            opacity: _heroFade.value,
            child: Transform.scale(
              scale: _heroScale.value,
              alignment: Alignment.topCenter,
              child: SizedBox(
                height: _heroHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Imagen de fondo o ícono
                    if (logoUrl != null)
                      Image.network(
                        logoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildHeroFallback(org),
                      )
                    else
                      _buildHeroFallback(org),

                    // Overlay degradado negro → transparente → negro
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xCC07070F),
                            Color(0x3307070F),
                            Color(0xFF07070F),
                          ],
                          stops: [0.0, 0.45, 1.0],
                        ),
                      ),
                    ),

                    // Overlay dorado sutil
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _kGold.withOpacity(0.06),
                            Colors.transparent,
                            _kGoldDeep.withOpacity(0.08),
                          ],
                        ),
                      ),
                    ),

                    // Información en la parte inferior del hero
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Badge de tipo
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: _kGold.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _kGold.withOpacity(0.40),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    org.iconoTipo,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _getDescripcionTipo(org.tipo),
                                    style: const TextStyle(
                                      color: _kGold,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Nombre principal
                            ShaderMask(
                              shaderCallback:
                                  (b) => const LinearGradient(
                                    colors: [Colors.white, _kGoldLight],
                                    stops: [0.6, 1.0],
                                  ).createShader(b),
                              child: Text(
                                org.nombreParaMostrar,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Stats rápidos en el hero
                            Row(
                              children: [
                                _HeroStatPill(
                                  icon: Icons.store_rounded,
                                  value: '${org.totalTiendas ?? 0} tiendas',
                                ),
                                const SizedBox(width: 8),
                                _HeroStatPill(
                                  icon: Icons.people_alt_rounded,
                                  value: '${org.totalMiembros ?? 0} miembros',
                                ),
                              ],
                            ),
                          ],
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

  Widget _buildHeroFallback(Organizacion org) {
    return Container(
      color: _kSurface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _kGold.withOpacity(0.08),
                border: Border.all(color: _kGold.withOpacity(0.35), width: 1.5),
              ),
              child: Center(
                child: Text(
                  org.iconoTipo,
                  style: const TextStyle(fontSize: 42),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── TabBar glassmorphism ──────────────────────────────────
  Widget _buildTabBar(Organizacion org) {
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: _kSurface.withOpacity(0.88),
            border: Border(bottom: BorderSide(color: _kBorder, width: 1)),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: _kGold,
            unselectedLabelColor: _kHint,
            indicatorColor: _kGold,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 2,
            dividerColor: Colors.transparent,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 13,
            ),
            tabs: const [
              Tab(
                icon: Icon(Icons.info_outline_rounded, size: 18),
                text: 'Información',
                iconMargin: EdgeInsets.only(bottom: 2),
              ),
              Tab(
                icon: Icon(Icons.store_rounded, size: 18),
                text: 'Tiendas',
                iconMargin: EdgeInsets.only(bottom: 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Tab: Información ──────────────────────────────────────
  Widget _buildInfoTab(Organizacion org) {
    return AnimatedBuilder(
      animation: _contentCtrl,
      builder:
          (_, child) => Opacity(
            opacity: _contentFade.value.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, _contentSlide.value),
              child: child,
            ),
          ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Stats expandidos ──────────────────────────
            _buildStatsRow(org),
            const SizedBox(height: 20),

            // ── Descripción ───────────────────────────────
            if (org.descripcion != null && org.descripcion!.isNotEmpty) ...[
              _buildSection(
                title: 'Sobre la organización',
                icon: Icons.auto_stories_rounded,
                child: Text(
                  org.descripcion!,
                  style: const TextStyle(
                    color: _kHint,
                    fontSize: 14,
                    height: 1.65,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Contacto ──────────────────────────────────
            _buildSection(
              title: 'Información de contacto',
              icon: Icons.contact_page_outlined,
              child: Column(
                children: [
                  _GoldInfoRow(
                    icon: Icons.alternate_email_rounded,
                    label: 'Email del anfitrión',
                    value: org.emailAnfitrion,
                  ),
                  _GoldDivider(),
                  _GoldInfoRow(
                    icon: Icons.schedule_rounded,
                    label: 'Miembro desde',
                    value: org.tiempoDesdeCreacion,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(Organizacion org) {
    return Row(
      children: [
        Expanded(
          child: _GoldStatCard(
            icon: Icons.store_rounded,
            value: org.totalTiendas ?? 0,
            label: 'Tiendas',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _GoldStatCard(
            icon: Icons.people_alt_rounded,
            value: org.totalMiembros ?? 0,
            label: 'Miembros',
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: _kSurfaceCard.withOpacity(0.90),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _kBorder, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado de sección
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _kGold.withOpacity(0.10),
                        border: Border.all(
                          color: _kGold.withOpacity(0.30),
                          width: 1,
                        ),
                      ),
                      child: Icon(icon, color: _kGold, size: 15),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              // Separador dorado
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_kGold.withOpacity(0.30), Colors.transparent],
                  ),
                ),
              ),
              // Contenido
              Padding(padding: const EdgeInsets.all(16), child: child),
            ],
          ),
        ),
      ),
    );
  }

  // ── Tab: Tiendas ──────────────────────────────────────────
  Widget _buildTiendasTab(List<dynamic> tiendas, Organizacion org) {
    if (tiendas.isEmpty) {
      return _buildEmptyTiendas();
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      itemCount: tiendas.length,
      itemBuilder: (context, index) {
        final tienda = tiendas[index] as Map<String, dynamic>;
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 400 + index * 60),
          curve: Curves.easeOutCubic,
          builder:
              (_, v, child) => Opacity(
                opacity: v,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - v)),
                  child: child,
                ),
              ),
          child: _TiendaCard(
            tienda: tienda,
            onTap: _onTiendaTap,
            getLogoUrl: _getTiendaLogoUrl,
            getNombre: _getTiendaNombre,
            getDescripcion: _getTiendaDescripcion,
            getCategoria: _getTiendaCategoria,
          ),
        );
      },
    );
  }

  Widget _buildEmptyTiendas() {
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
            child: const Icon(Icons.store_rounded, size: 36, color: _kGold),
          ),
          const SizedBox(height: 18),
          ShaderMask(
            shaderCallback:
                (b) => const LinearGradient(
                  colors: [_kGoldDeep, _kGold, _kGoldLight],
                ).createShader(b),
            child: const Text(
              'Sin tiendas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Esta organización aún no tiene\ntiendas asociadas',
            style: TextStyle(color: _kHint, fontSize: 13, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  FONDO ISOMÉTRICO (idéntico al sistema de diseño)
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

    final beamOp = math.sin(t * math.pi * 2) * 0.04 + 0.07;
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.35, 0)
        ..lineTo(w * 0.65, 0)
        ..lineTo(w * 0.80, h * 0.50)
        ..lineTo(w * 0.20, h * 0.50)
        ..close(),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_kGoldLight.withOpacity(beamOp), Colors.transparent],
        ).createShader(Rect.fromLTWH(0, 0, w, h * 0.50)),
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
      final op = math.sin(phase * math.pi) * 0.28;
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
  }

  @override
  bool shouldRepaint(_BgPainter o) => o.t != t;
}

// ══════════════════════════════════════════════════════════════
//  PÍLDORA DE STAT EN EL HERO
// ══════════════════════════════════════════════════════════════
class _HeroStatPill extends StatelessWidget {
  final IconData icon;
  final String value;
  const _HeroStatPill({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.40),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _kGold.withOpacity(0.30), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: _kGold, size: 13),
              const SizedBox(width: 5),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
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
//  TARJETA DE STAT (Info Tab)
// ══════════════════════════════════════════════════════════════
class _GoldStatCard extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;
  const _GoldStatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          decoration: BoxDecoration(
            color: _kSurfaceCard.withOpacity(0.90),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _kBorder, width: 1),
            boxShadow: [
              BoxShadow(
                color: _kGold.withOpacity(0.06),
                blurRadius: 16,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kGold.withOpacity(0.10),
                  border: Border.all(color: _kGold.withOpacity(0.28), width: 1),
                ),
                child: Icon(icon, color: _kGold, size: 18),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback:
                        (b) => const LinearGradient(
                          colors: [_kGold, _kGoldLight],
                        ).createShader(b),
                    child: Text(
                      value.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      color: _kHint,
                      fontSize: 12,
                      letterSpacing: 0.3,
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
}

// ══════════════════════════════════════════════════════════════
//  FILA DE INFORMACIÓN CON ÍCONO DORADO
// ══════════════════════════════════════════════════════════════
class _GoldInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _GoldInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _kGold.withOpacity(0.08),
          ),
          child: Icon(icon, color: _kGold.withOpacity(0.80), size: 17),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: _kHint,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GoldDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, _kBorder, Colors.transparent],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  CARD DE TIENDA — glassmorphism + hover glow
// ══════════════════════════════════════════════════════════════
class _TiendaCard extends StatefulWidget {
  final Map<String, dynamic> tienda;
  final void Function(Map<String, dynamic>) onTap;
  final String? Function(Map<String, dynamic>) getLogoUrl;
  final String Function(Map<String, dynamic>) getNombre;
  final String Function(Map<String, dynamic>) getDescripcion;
  final String? Function(Map<String, dynamic>) getCategoria;

  const _TiendaCard({
    required this.tienda,
    required this.onTap,
    required this.getLogoUrl,
    required this.getNombre,
    required this.getDescripcion,
    required this.getCategoria,
  });

  @override
  State<_TiendaCard> createState() => _TiendaCardState();
}

class _TiendaCardState extends State<_TiendaCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logoUrl = widget.getLogoUrl(widget.tienda);
    final nombre = widget.getNombre(widget.tienda);
    final descripcion = widget.getDescripcion(widget.tienda);
    final categoria = widget.getCategoria(widget.tienda);
    final tieneLogo = logoUrl != null && logoUrl.isNotEmpty;

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap(widget.tienda);
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _anim,
        builder:
            (_, child) => Transform.scale(
              scale: 1.0 - (_anim.value * 0.015),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _kGold.withOpacity(0.04 + _anim.value * 0.10),
                      blurRadius: 18 + _anim.value * 14,
                      spreadRadius: _anim.value * 1.5,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.40),
                      blurRadius: 14,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: child,
              ),
            ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              decoration: BoxDecoration(
                color: _kSurfaceCard.withOpacity(0.90),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _kBorder, width: 1),
              ),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Logo / Avatar
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: _kGold.withOpacity(0.06),
                      border: Border.all(
                        color: _kGold.withOpacity(0.22),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child:
                          tieneLogo
                              ? Image.network(
                                logoUrl,
                                width: 58,
                                height: 58,
                                fit: BoxFit.cover,
                                loadingBuilder: (_, child, progress) {
                                  if (progress == null) return child;
                                  return const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.5,
                                        valueColor: AlwaysStoppedAnimation(
                                          _kGold,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder:
                                    (_, __, ___) => Icon(
                                      Icons.store_rounded,
                                      color: _kGold.withOpacity(0.70),
                                      size: 26,
                                    ),
                              )
                              : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.store_rounded,
                                      color: _kGold.withOpacity(0.70),
                                      size: 22,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      nombre.isNotEmpty
                                          ? nombre[0].toUpperCase()
                                          : 'T',
                                      style: TextStyle(
                                        color: _kGold.withOpacity(0.80),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nombre,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          descripcion,
                          style: const TextStyle(
                            color: _kHint,
                            fontSize: 12,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (categoria != null && categoria.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _kGold.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _kGold.withOpacity(0.25),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              categoria,
                              style: const TextStyle(
                                color: _kGold,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: _kGold,
                    size: 14,
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
//  BOTÓN ÍCONO DORADO (reutilizable)
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
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kGold.withOpacity(0.07),
                  border: Border.all(color: _kGold.withOpacity(0.28), width: 1),
                ),
                child: Icon(widget.icon, color: _kGold, size: 18),
              ),
            ),
      ),
    );
  }
}
