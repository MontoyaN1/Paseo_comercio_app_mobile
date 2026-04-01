// lib/presentation/pages/tiendas/tienda_detail_page.dart
//
// 🏛️  PLAZA UNIVERSE — Detalle de Tienda
// ────────────────────────────────────────────────────────────

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:paseo_del_comercio/core/app/app_config.dart';
import 'package:paseo_del_comercio/core/utils/share_service.dart';
import 'package:paseo_del_comercio/data/datasources/remote/supabase_client.dart';
import 'package:paseo_del_comercio/di/service_locator.dart';
import 'package:paseo_del_comercio/domain/entities/tienda.dart';

import 'package:paseo_del_comercio/presentation/blocs/tienda/tienda_bloc.dart';
import 'package:paseo_del_comercio/presentation/widgets/tienda/tienda_bg_painter.dart';
import 'package:paseo_del_comercio/presentation/widgets/tienda/tienda_hero.dart';
import 'package:paseo_del_comercio/presentation/widgets/tienda/tienda_app_bar.dart';
import 'package:paseo_del_comercio/presentation/widgets/tienda/tienda_info_tab.dart';
import 'package:paseo_del_comercio/presentation/widgets/tienda/tienda_productos_tab.dart';
import 'package:paseo_del_comercio/presentation/widgets/tienda/tienda_components.dart';
import '../../widgets/profile_floating_button.dart';

const _kGold = Color(0xFFD4AF37);
const _kBg = Color(0xFF07070F);
const _kSurface = Color(0xFF0F0F1E);
const _kBorder = Color(0xFF1E1E3A);
const _kHint = Color(0xFF6B6B8A);

class TiendaDetailPage extends StatefulWidget {
  final int tiendaId;
  final Tienda? tienda;

  const TiendaDetailPage({super.key, required this.tiendaId, this.tienda});

  @override
  State<TiendaDetailPage> createState() => _TiendaDetailPageState();
}

class _TiendaDetailPageState extends State<TiendaDetailPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final TabController _tabController;
  final _scrollController = ScrollController();

  bool _hasLoaded = false;

  late final AnimationController _bgCtrl;
  late final AnimationController _heroCtrl;

  late final Animation<double> _heroFade;
  late final Animation<double> _heroScale;

  double _scrollOffset = 0;
  static const double _heroHeight = 280;

  Map<String, dynamic>? _tiendaData;
  List<Map<String, dynamic>> _productos = [];
  List<Map<String, dynamic>> _horarios = [];
  final AppConfig _appConfig = AppConfig();

  int _productosPage = 1;
  bool _hasMoreProductos = true;
  bool _isLoadingMoreProductos = false;
  static const int _productosLimit = 6;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 2, vsync: this);

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

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

    _scrollController.addListener(() {
      setState(() => _scrollOffset = _scrollController.offset);
    });

    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) _heroCtrl.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoaded) {
      _hasLoaded = true;
      _loadTienda();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _tiendaData != null && mounted) {
      _loadTienda();
    }
  }

  @override
  void didUpdateWidget(TiendaDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tiendaId != widget.tiendaId) {
      _hasLoaded = false;
      _tiendaData = null;
      _productos = [];
      _horarios = [];
      _productosPage = 1;
      _hasMoreProductos = true;
      _loadTienda();
      setState(() {});
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    _scrollController.dispose();
    _bgCtrl.dispose();
    _heroCtrl.dispose();
    super.dispose();
  }

  double get _collapseProgress =>
      (_scrollOffset / (_heroHeight - kToolbarHeight)).clamp(0.0, 1.0);

  Future<void> _registrarVisitaTienda() async {
    try {
      final supabase = getIt<SupabaseClientService>();
      final tienda =
          await supabase.tiendas
              .select('total_visitas')
              .eq('id', widget.tiendaId)
              .maybeSingle();

      if (tienda != null) {
        final totalVisitas = (tienda['total_visitas'] as int? ?? 0) + 1;
        await supabase.tiendas
            .update({
              'total_visitas': totalVisitas,
              'fecha_ultima_visita': DateTime.now().toIso8601String(),
            })
            .eq('id', widget.tiendaId);
      }
    } catch (e) {
      debugPrint('Error registrando visita: $e');
    }
  }

  void _loadTienda() {
    try {
      final bloc = context.read<TiendaBloc>();
      if (bloc.isClosed) return;

      if (widget.tienda != null) {
        final logoUrl = _transformUrlToR2(widget.tienda!.logoUrl);

        dynamic imagenTienda = widget.tienda!.imagenTienda;
        if (imagenTienda is List) {
          final nuevasImagenes = <Map<String, dynamic>>[];
          for (final img in imagenTienda) {
            if (img is Map<String, dynamic>) {
              final nuevaImagen = Map<String, dynamic>.from(img);
              final urlImagen = nuevaImagen['url_imagen'] as String?;
              if (urlImagen != null) {
                nuevaImagen['url_imagen'] = _transformUrlToR2(urlImagen);
              }
              nuevasImagenes.add(nuevaImagen);
            }
          }
          imagenTienda = nuevasImagenes;
        }

        _tiendaData = {
          'id': widget.tienda!.id,
          'nombre_tienda': widget.tienda!.nombreTienda,
          'nombre': widget.tienda!.nombreTienda,
          'descripcion': widget.tienda!.descripcion,
          'logoUrl': logoUrl,
          'logo': logoUrl,
          'logo_url': logoUrl,
          'imagen_tienda': imagenTienda,
          'telefono_contacto': widget.tienda!.telefonoContacto,
          'telefono': widget.tienda!.telefonoContacto,
          'email_contacto': widget.tienda!.emailContacto,
          'email': widget.tienda!.emailContacto,
          'direccion': widget.tienda!.direccion,
          'redes_sociales': widget.tienda!.redesSociales,
          'total_visitas': widget.tienda!.totalVisitas,
          'total_contactos_whatsapp': widget.tienda!.totalContactosWhatsapp,
          'fecha_creacion': widget.tienda!.fechaCreacion.toIso8601String(),
        };

        bloc.add(
          TiendaProductsRequested(
            tiendaId: widget.tienda!.id,
            limit: _productosLimit,
          ),
        );
        bloc.add(TiendaHorariosRequested(tiendaId: widget.tienda!.id));
        _registrarVisitaTienda();
      } else {
        bloc.add(
          TiendaLoadByIdRequested(
            tiendaId: widget.tiendaId,
            forceRefresh: true,
          ),
        );
        _registrarVisitaTienda();
      }
    } catch (e) {
      debugPrint('❌ _loadTienda error: $e');
    }
  }

  String? _transformUrlToR2(String? url) {
    if (url == null || url.isEmpty) return url;
    if (!url.contains('contabostorage.com')) return url;

    try {
      if (_appConfig.cloudflareR2PublicUrl.isEmpty) return url;

      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      final paseocomercioIndex = pathSegments.indexWhere(
        (segment) => segment == 'paseocomercio',
      );

      if (paseocomercioIndex == -1 ||
          paseocomercioIndex >= pathSegments.length - 1)
        return url;

      final relativePath = pathSegments
          .sublist(paseocomercioIndex + 1)
          .join('/');
      String baseUrl = _appConfig.cloudflareR2PublicUrl.trim();
      if (baseUrl.endsWith('/')) {
        baseUrl = baseUrl.substring(0, baseUrl.length - 1);
      }
      return '$baseUrl/$relativePath';
    } catch (e) {
      return url;
    }
  }

  void _loadMoreProductos() {
    if (_isLoadingMoreProductos || !_hasMoreProductos) return;

    final tiendaId = _tiendaData?['id'] as int? ?? widget.tienda?.id;
    if (tiendaId == null) return;

    setState(() => _isLoadingMoreProductos = true);

    final nextPage = _productosPage + 1;
    context.read<TiendaBloc>().add(
      TiendaProductsRequested(
        tiendaId: tiendaId,
        page: nextPage,
        limit: _productosLimit,
      ),
    );
  }

  Future<void> _onShareTienda() async {
    if (_tiendaData == null) return;

    try {
      final shareService = getIt<ShareService>();
      final nombre =
          _tiendaData!['nombre_tienda'] ?? _tiendaData!['nombre'] ?? 'Tienda';
      final descripcion = _tiendaData!['descripcion'] as String?;

      await shareService.compartirTienda(
        tiendaId: widget.tiendaId,
        nombreTienda: nombre,
        descripcion: descripcion,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1A0808),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.red.withOpacity(0.35)),
            ),
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red[300], size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Error al compartir: $e',
                    style: TextStyle(color: Colors.red[200], fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  Future<void> _openInMaps() async {
    if (_tiendaData == null) return;

    final direccion = _tiendaData!['direccion'] as String?;
    if (direccion == null || direccion.isEmpty) {
      if (mounted) {
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
                Icon(Icons.location_off_rounded, color: _kHint, size: 18),
                SizedBox(width: 10),
                Text(
                  'Dirección no disponible',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        );
      }
      return;
    }

    try {
      final encodedAddress = Uri.encodeComponent(direccion);
      final mapsUrl =
          'https://www.google.com/maps/search/?api=1&query=$encodedAddress';
      final uri = Uri.parse(mapsUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        final geoUrl = 'geo:0,0?q=$encodedAddress';
        final geoUri = Uri.parse(geoUrl);
        if (await canLaunchUrl(geoUri)) {
          await launchUrl(geoUri, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      debugPrint('Error al abrir mapa: $e');
    }
  }

  void _onProductoTap(Map<String, dynamic> producto) {
    final productoId = producto['id'];
    if (productoId != null) {
      context.push(
        '/productos/$productoId',
        extra: {...producto, 'tienda': _tiendaData},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TiendaBloc, TiendaState>(
      listener: (context, state) {
        if (state is TiendaDetailLoaded && _tiendaData == null) {
          _tiendaData = state.tienda;
          final tiendaId = state.tienda['id'] as int?;
          if (tiendaId != null) {
            context.read<TiendaBloc>().add(
              TiendaProductsRequested(
                tiendaId: tiendaId,
                limit: _productosLimit,
              ),
            );
            context.read<TiendaBloc>().add(
              TiendaHorariosRequested(tiendaId: tiendaId),
            );
          }
        }
        if (state is TiendaProductsLoaded) {
          final currentTiendaId = _tiendaData?['id'] ?? widget.tienda?.id;
          if (state.tiendaId == currentTiendaId) {
            setState(() {
              if (state.currentPage == 1) {
                _productos = state.productos;
              } else {
                _productos = [..._productos, ...state.productos];
              }
              _hasMoreProductos = state.hasMore;
              _productosPage = state.currentPage;
              _isLoadingMoreProductos = false;
            });
          }
        }
        if (state is TiendaHorariosLoaded) {
          setState(() => _horarios = state.horarios);
        }
      },
      child: BlocBuilder<TiendaBloc, TiendaState>(
        builder: (context, state) {
          if (_tiendaData != null) {
            return _buildPage(context, _tiendaData!);
          }

          if (state is TiendaLoading) {
            return _buildLoadingState();
          }

          return _buildErrorState();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? _kBg : Colors.white,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _bgCtrl,
            builder:
                (_, __) => CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: TiendaBgPainter(
                    _bgCtrl.value,
                    Theme.of(context).brightness,
                  ),
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

  Widget _buildErrorState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? _kBg : Colors.white,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _bgCtrl,
            builder:
                (_, __) => CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: TiendaBgPainter(
                    _bgCtrl.value,
                    Theme.of(context).brightness,
                  ),
                ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.store_rounded, color: _kGold, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Tienda no encontrada',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 20),
                TiendaOutlineButton(
                  label: 'Volver',
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/plazoletas');
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(BuildContext context, Map<String, dynamic> tienda) {
    final nombre = tienda['nombre'] ?? tienda['nombre_tienda'] ?? 'Tienda';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? _kBg : Colors.white,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _bgCtrl,
            builder:
                (_, __) => CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: TiendaBgPainter(
                    _bgCtrl.value,
                    Theme.of(context).brightness,
                  ),
                ),
          ),
          NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder:
                (context, _) => [
                  SliverToBoxAdapter(
                    child: TiendaHero(
                      tienda: tienda,
                      heroFade: _heroFade,
                      heroScale: _heroScale,
                      productosCount: _productos.length,
                    ),
                  ),
                ],
            body: Column(
              children: [
                _buildTabBar(context),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      TiendaInfoTab(
                        tienda: tienda,
                        horarios: _horarios,
                        onOpenMaps: _openInMaps,
                      ),
                      TiendaProductosTab(
                        productos: _productos,
                        hasMore: _hasMoreProductos,
                        isLoadingMore: _isLoadingMoreProductos,
                        onLoadMore: _loadMoreProductos,
                        onProductoTap: _onProductoTap,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: TiendaFloatingAppBar(
              title: nombre,
              collapseProgress: _collapseProgress,
              onShare: _onShareTienda,
              tiendaId: tienda['id'] as int?,
            ),
          ),
        ],
      ),
      floatingActionButton: const ProfileFloatingButton(),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tabBgColor =
        isDark ? _kSurface.withOpacity(0.88) : Colors.white.withOpacity(0.88);
    final tabBorderColor = isDark ? _kBorder : Colors.grey.shade300;
    final unselectedLabel = isDark ? _kHint : Colors.grey.shade600;

    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: tabBgColor,
            border: Border(bottom: BorderSide(color: tabBorderColor, width: 1)),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: _kGold,
            unselectedLabelColor: unselectedLabel,
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
                icon: Icon(Icons.shopping_bag_outlined, size: 18),
                text: 'Productos',
                iconMargin: EdgeInsets.only(bottom: 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
