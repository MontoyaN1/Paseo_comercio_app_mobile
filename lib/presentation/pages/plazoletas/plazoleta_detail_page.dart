// lib/presentation/pages/plazoletas/plazoleta_detail_page.dart
//
// 🏛️  PLAZA UNIVERSE — Detalle de Plazoleta
// ────────────────────────────────────────────────────────────
//  DISEÑO (idéntico al sistema de diseño de OrganizacionDetailPage):
//  • Hero header: imagen principal con overlay degradado dorado
//  • Fondo: partículas isométricas flotantes (mismo que login)
//  • SliverAppBar colapsable con glassmorphism al hacer scroll
//  • Tabs glassmorphism: Información, Productos y Tiendas
//  • Stats con glow dorado animado
//  • Cards de productos/tiendas: glassmorphism + hover glow
//  • Info de contacto: filas elegantes sobre fondo oscuro
// ────────────────────────────────────────────────────────────

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:paseo_del_comercio/domain/entities/plazoleta.dart';
import 'package:paseo_del_comercio/domain/entities/producto.dart';
import 'package:paseo_del_comercio/domain/entities/tienda.dart';
import 'package:paseo_del_comercio/domain/entities/imagen_base.dart';

import 'package:paseo_del_comercio/presentation/blocs/plazoleta/plazoleta_bloc.dart';
import 'package:paseo_del_comercio/presentation/blocs/plazoleta/plazoleta_event.dart';
import 'package:paseo_del_comercio/presentation/blocs/plazoleta/plazoleta_state.dart';
import 'package:paseo_del_comercio/presentation/widgets/producto/producto_card.dart';
import 'package:paseo_del_comercio/presentation/widgets/tienda/tienda_card.dart';
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
class PlazoletaDetailPage extends StatefulWidget {
  final int plazoletaId;

  const PlazoletaDetailPage({super.key, required this.plazoletaId});

  @override
  State<PlazoletaDetailPage> createState() => _PlazoletaDetailPageState();
}

class _PlazoletaDetailPageState extends State<PlazoletaDetailPage>
    with TickerProviderStateMixin {
  // ── Controllers ───────────────────────────────────────────
  late final TabController _tabController;
  final _scrollController = ScrollController();
  int _currentTabIndex = 0;

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
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);

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

    // Cargar plazoleta al iniciar (productos y tiendas se cargan automáticamente)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPlazoleta();
    });

    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) _heroCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 380), () {
      if (mounted) _contentCtrl.forward();
    });

    // Cargar plazoleta al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPlazoleta();
    });
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

  // ── Tab change ────────────────────────────────────────────
  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() => _currentTabIndex = _tabController.index);
      _loadTabData(_tabController.index);
    }
  }

  void _loadPlazoleta() {
    try {
      final bloc = context.read<PlazoletaBloc>();
      if (!bloc.isClosed) {
        bloc.add(LoadPlazoletaById(id: widget.plazoletaId, forceRefresh: true));
      }
    } catch (_) {}
  }

  void _loadTabData(int tabIndex) {
    if (!mounted) return;
    try {
      final bloc = context.read<PlazoletaBloc>();
      if (bloc.isClosed) return;
      switch (tabIndex) {
        case 0:
          bloc.add(LoadImagenesPlazoleta(plazoletaId: widget.plazoletaId));
          break;
        case 1:
          bloc.add(LoadProductosPlazoleta(plazoletaId: widget.plazoletaId));
          break;
        case 2:
          bloc.add(LoadTiendasPlazoleta(plazoletaId: widget.plazoletaId));
          break;
      }
    } catch (_) {}
  }

  Future<void> _onRefresh() async {
    _loadPlazoleta();
    _loadTabData(_currentTabIndex);
  }

  void _onProductoTap(Producto producto) =>
      context.push('/productos/${producto.id}', extra: producto.toJson());
  void _onTiendaTap(Tienda tienda) => context.push('/tiendas/${tienda.id}');

  // ── Cuánto ha colapsado el hero (0..1) ────────────────────
  double get _collapseProgress =>
      (_scrollOffset / (_heroHeight - kToolbarHeight)).clamp(0.0, 1.0);

  String _emojiForTipo(Plazoleta p) {
    if (p.esPlazoletaPrincipal) return '🏛️';
    if (p.esAreaSecundaria) return '🚶';
    if (p.esEntradaSalida) return '🚪';
    return '📍';
  }

  // ── Conversores ───────────────────────────────────────────
  Map<String, dynamic> _productoToMap(Producto p) {
    String? imagenUrl;
    if (p.imagenes != null && p.imagenes!.isNotEmpty) {
      final first = p.imagenes!.first;
      if (first is Map<String, dynamic>)
        imagenUrl = first['url_imagen'] as String?;
    }
    return {
      'id': p.id,
      'nombre': p.nombre,
      'nombre_producto': p.nombre,
      'descripcion': p.descripcion,
      'precio': p.precioBase,
      'precio_base': p.precioBase,
      'imagenUrl': imagenUrl,
      'imagenes': p.imagenes,
      'tiendaId': p.tiendaId,
      'tienda_id': p.tiendaId,
      'categoriaId': p.categoriaId,
      'categoria_id': p.categoriaId,
      'estado': p.estadoProducto?.value ?? 'publicado',
      'stock': p.cantidad,
      'stock_disponible': p.cantidad,
      'cantidad': p.cantidad,
      'calificacion': p.calificacionPromedio,
      'calificacion_promedio': p.calificacionPromedio,
      'totalValoraciones': p.totalValoracion ?? 0,
      'total_valoracion': p.totalValoracion,
      'total_visualizaciones': p.totalVisualizaciones,
      'estado_producto': p.estadoProducto?.value ?? 'publicado',
      'destacado': false,
      'enOferta': false,
      'precioOferta': null,
    };
  }

  Map<String, dynamic> _tiendaToMap(Tienda t) => {
    'id': t.id,
    'nombre': t.nombreTienda,
    'descripcion': t.descripcion,
    'logoUrl': t.logoUrl,
    'imagen_tienda': t.imagenTienda,
    'categorias': [],
    'calificacion': 0.0,
    'totalValoraciones': 0,
    'abierta': true,
    'distancia': '-- km',
    'direccion': t.direccion,
    'telefono': t.telefonoContacto,
    'email': t.emailContacto,
    'redesSociales': t.redesSociales,
    'totalVisitas': t.totalVisitas,
    'totalContactosWhatsapp': t.totalContactosWhatsapp,
  };

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (_) {
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlazoletaBloc, PlazoletaState>(
      builder: (context, state) {
        Plazoleta? plazoleta;
        List<ImagenBase> imagenes = [];
        List<Producto> productos = [];
        List<Tienda> tiendas = [];

        if (state is PlazoletaLoaded && state.plazoletaSeleccionada != null) {
          plazoleta = state.plazoletaSeleccionada!;
          imagenes = state.imagenesPlazoleta ?? [];
          productos = state.productosPlazoleta ?? [];
          tiendas = state.tiendasPlazoleta ?? [];
        }

        if (plazoleta == null) {
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
                // Loading / Error overlay
                _buildLoadingOrError(state),
              ],
            ),
          );
        }

        return _buildPage(context, plazoleta, imagenes, productos, tiendas);
      },
    );
  }

  // ── Loading / error mientras no hay plazoleta ──────────────
  Widget _buildLoadingOrError(PlazoletaState state) {
    if (state is PlazoletaDetailError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: _kGold, size: 48),
            const SizedBox(height: 16),
            Text(
              state.message,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _GoldOutlineButton(label: 'Reintentar', onTap: _loadPlazoleta),
          ],
        ),
      );
    }
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

  Widget _buildPage(
    BuildContext context,
    Plazoleta plazoleta,
    List<ImagenBase> imagenes,
    List<Producto> productos,
    List<Tienda> tiendas,
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
                (context, _) => [
                  SliverToBoxAdapter(
                    child: _buildHero(plazoleta, imagenes, productos, tiendas),
                  ),
                ],
            body: Column(
              children: [
                _buildTabBar(plazoleta),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildInfoTab(plazoleta, imagenes),
                      _buildProductosTab(productos),
                      _buildTiendasTab(tiendas),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── AppBar flotante con glassmorphism ──────────────
          SafeArea(child: _buildFloatingAppBar(plazoleta)),
        ],
      ),
      floatingActionButton: ProfileFloatingButton(),
    );
  }

  // ── AppBar glassmorphism ──────────────────────────────────
  Widget _buildFloatingAppBar(Plazoleta plazoleta) {
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
              _GoldIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    Future.microtask(() => context.go('/plazoletas'));
                  }
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AnimatedOpacity(
                  opacity: opacity,
                  duration: Duration.zero,
                  child: Text(
                    plazoleta.nombre,
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
              _GoldIconButton(
                icon: Icons.share_rounded,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: _kSurface,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: _kBorder),
                      ),
                      content: const Row(
                        children: [
                          Icon(Icons.share_rounded, color: _kGold, size: 18),
                          SizedBox(width: 10),
                          Text(
                            'Compartir plazoleta (pendiente)',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ── Hero expandible ───────────────────────────────────────
  Widget _buildHero(
    Plazoleta plazoleta,
    List<ImagenBase> imagenes,
    List<Producto> productos,
    List<Tienda> tiendas,
  ) {
    final imagenPrincipal =
        imagenes.isNotEmpty
            ? imagenes.firstWhere(
              (i) => i.esPrincipal,
              orElse: () => imagenes.first,
            )
            : null;

    final tieneImagen =
        imagenPrincipal != null && _isValidUrl(imagenPrincipal.urlPreferida);

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
                    // ── Imagen de fondo ─────────────────────────
                    if (tieneImagen)
                      CachedNetworkImage(
                        imageUrl: imagenPrincipal.urlPreferida,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _buildHeroFallback(plazoleta),
                        errorWidget:
                            (_, __, ___) => _buildHeroFallback(plazoleta),
                      )
                    else
                      _buildHeroFallback(plazoleta),

                    // ── Overlay degradado negro → transparente → negro ──
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

                    // ── Overlay dorado sutil ─────────────────────
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

                    // ── Información en la parte inferior ─────────
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
                                    _emojiForTipo(plazoleta),
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    plazoleta.tipoUbicacionTexto,
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
                                plazoleta.nombre,
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
                                  icon: Icons.shopping_bag_rounded,
                                  value: '${productos.length} productos',
                                ),
                                const SizedBox(width: 8),
                                _HeroStatPill(
                                  icon: Icons.store_rounded,
                                  value: '${tiendas.length} tiendas',
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

  Widget _buildHeroFallback(Plazoleta plazoleta) {
    return Container(
      color: _kSurface,
      child: Center(
        child: Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _kGold.withOpacity(0.08),
            border: Border.all(color: _kGold.withOpacity(0.35), width: 1.5),
          ),
          child: Center(
            child: Text(
              _emojiForTipo(plazoleta),
              style: const TextStyle(fontSize: 42),
            ),
          ),
        ),
      ),
    );
  }

  // ── TabBar glassmorphism ──────────────────────────────────
  Widget _buildTabBar(Plazoleta plazoleta) {
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
                icon: Icon(Icons.shopping_bag_rounded, size: 18),
                text: 'Productos',
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
  Widget _buildInfoTab(Plazoleta plazoleta, List<ImagenBase> imagenes) {
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
      child: RefreshIndicator(
        color: _kGold,
        backgroundColor: _kSurface,
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Galería de imágenes ───────────────────────
              if (imagenes.isNotEmpty) ...[
                _buildSection(
                  title: 'Galería',
                  icon: Icons.photo_library_rounded,
                  child: SizedBox(
                    height: 130,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: imagenes.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, i) {
                        final img = imagenes[i];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            children: [
                              CachedNetworkImage(
                                imageUrl: img.urlPreferida,
                                width: 160,
                                height: 130,
                                fit: BoxFit.cover,
                                placeholder:
                                    (_, __) => Container(
                                      width: 160,
                                      color: _kSurface,
                                      child: const Center(
                                        child: SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 1.5,
                                            valueColor: AlwaysStoppedAnimation(
                                              _kGold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                errorWidget:
                                    (_, __, ___) => Container(
                                      width: 160,
                                      color: _kSurface,
                                      child: Icon(
                                        Icons.broken_image_rounded,
                                        color: _kGold.withOpacity(0.4),
                                        size: 28,
                                      ),
                                    ),
                              ),
                              if (img.esPrincipal)
                                Positioned(
                                  top: 6,
                                  left: 6,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _kGold.withOpacity(0.85),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Principal',
                                      style: TextStyle(
                                        color: _kBg,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── Descripción ───────────────────────────────
              if (plazoleta.descripcion != null &&
                  plazoleta.descripcion!.isNotEmpty) ...[
                _buildSection(
                  title: 'Sobre la plazoleta',
                  icon: Icons.auto_stories_rounded,
                  child: Text(
                    plazoleta.descripcion!,
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

              // ── Info general ──────────────────────────────
              _buildSection(
                title: 'Información general',
                icon: Icons.info_outline_rounded,
                child: Column(
                  children: [
                    _GoldInfoRow(
                      icon: Icons.category_rounded,
                      label: 'Tipo de ubicación',
                      value: plazoleta.tipoUbicacionTexto,
                    ),
                    _GoldDivider(),
                    _GoldInfoRow(
                      icon: Icons.calendar_today_rounded,
                      label: 'Fecha de creación',
                      value: plazoleta.fechaCreacionFormateada,
                    ),
                    if (plazoleta.esReciente) ...[
                      _GoldDivider(),
                      _GoldInfoRow(
                        icon: Icons.fiber_new_rounded,
                        label: 'Estado',
                        value: 'Nueva',
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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

  // ── Tab: Productos ────────────────────────────────────────
  Widget _buildProductosTab(List<Producto> productos) {
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
      child:
          productos.isEmpty
              ? _buildEmptyState(
                icon: Icons.shopping_bag_rounded,
                title: 'Sin productos',
                subtitle: 'Esta plazoleta no tiene\nproductos disponibles aún',
                onRetry:
                    () => context.read<PlazoletaBloc>().add(
                      LoadProductosPlazoleta(plazoletaId: widget.plazoletaId),
                    ),
              )
              : RefreshIndicator(
                color: _kGold,
                backgroundColor: _kSurface,
                onRefresh: () async {
                  context.read<PlazoletaBloc>().add(
                    LoadProductosPlazoleta(
                      plazoletaId: widget.plazoletaId,
                      forceRefresh: true,
                    ),
                  );
                  await Future.delayed(const Duration(seconds: 1));
                },
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: productos.length,
                  itemBuilder: (context, index) {
                    final producto = productos[index];
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
                      child: ProductoCard(
                        producto: _productoToMap(producto),
                        onTap: () => _onProductoTap(producto),
                      ),
                    );
                  },
                ),
              ),
    );
  }

  // ── Tab: Tiendas ──────────────────────────────────────────
  Widget _buildTiendasTab(List<Tienda> tiendas) {
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
      child:
          tiendas.isEmpty
              ? _buildEmptyState(
                icon: Icons.store_rounded,
                title: 'Sin tiendas',
                subtitle: 'Esta plazoleta no tiene\ntiendas asociadas aún',
                onRetry:
                    () => context.read<PlazoletaBloc>().add(
                      LoadTiendasPlazoleta(plazoletaId: widget.plazoletaId),
                    ),
              )
              : RefreshIndicator(
                color: _kGold,
                backgroundColor: _kSurface,
                onRefresh: () async {
                  context.read<PlazoletaBloc>().add(
                    LoadTiendasPlazoleta(
                      plazoletaId: widget.plazoletaId,
                      forceRefresh: true,
                    ),
                  );
                  await Future.delayed(const Duration(seconds: 1));
                },
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                  itemCount: tiendas.length,
                  itemBuilder: (context, index) {
                    final tienda = tiendas[index];
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
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TiendaCard(
                          tienda: _tiendaToMap(tienda),
                          onTap: () => _onTiendaTap(tienda),
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onRetry,
  }) {
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
            child: Icon(icon, size: 36, color: _kGold),
          ),
          const SizedBox(height: 18),
          ShaderMask(
            shaderCallback:
                (b) => const LinearGradient(
                  colors: [_kGoldDeep, _kGold, _kGoldLight],
                ).createShader(b),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: _kHint, fontSize: 13, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          _GoldOutlineButton(label: 'Reintentar', onTap: onRetry),
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, _kBorder, Colors.transparent],
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

// ══════════════════════════════════════════════════════════════
//  BOTÓN OUTLINE DORADO (para reintentar / acciones vacías)
// ══════════════════════════════════════════════════════════════
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
      end: 0.94,
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
                  horizontal: 24,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: _kGold.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _kGold.withOpacity(0.45), width: 1),
                ),
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    color: _kGold,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
      ),
    );
  }
}
