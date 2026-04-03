// lib/presentation/pages/plazoletas/plazoleta_detail_page.dart
//
// 🏛️  PLAZA UNIVERSE — Detalle de Plazoleta
// ────────────────────────────────────────────────────────────
//  Phase 8: Fragmented with theme support
// ────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:paseo_del_comercio/domain/entities/plazoleta.dart';
import 'package:paseo_del_comercio/domain/entities/producto.dart';
import 'package:paseo_del_comercio/domain/entities/tienda.dart';
import 'package:paseo_del_comercio/domain/entities/imagen_base.dart';
import 'package:paseo_del_comercio/core/utils/share_service.dart';
import 'package:paseo_del_comercio/di/service_locator.dart';

import 'package:paseo_del_comercio/presentation/blocs/plazoleta/plazoleta_bloc.dart';
import 'package:paseo_del_comercio/presentation/blocs/plazoleta/plazoleta_event.dart';
import 'package:paseo_del_comercio/presentation/blocs/plazoleta/plazoleta_state.dart';
import 'package:paseo_del_comercio/presentation/widgets/plazoleta/plazoleta_bg_painter.dart';
import 'package:paseo_del_comercio/presentation/widgets/plazoleta/detail/plazoleta_hero.dart';
import 'package:paseo_del_comercio/presentation/widgets/plazoleta/detail/plazoleta_app_bar.dart';
import 'package:paseo_del_comercio/presentation/widgets/plazoleta/detail/plazoleta_info_tab.dart';
import 'package:paseo_del_comercio/presentation/widgets/plazoleta/detail/plazoleta_productos_tab.dart';
import 'package:paseo_del_comercio/presentation/widgets/plazoleta/detail/plazoleta_tiendas_tab.dart';
import 'package:paseo_del_comercio/presentation/widgets/plazoleta/plazoleta_components.dart';
import '../../widgets/shared/profile_floating_button.dart';

const _kGold = Color(0xFFD4AF37);
const _kBg = Color(0xFF07070F);

class PlazoletaDetailPage extends StatefulWidget {
  final int plazoletaId;
  final String? slug;

  const PlazoletaDetailPage({super.key, required this.plazoletaId, this.slug});

  @override
  State<PlazoletaDetailPage> createState() => _PlazoletaDetailPageState();
}

class _PlazoletaDetailPageState extends State<PlazoletaDetailPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final TabController _tabController;
  final _scrollController = ScrollController();
  int _currentTabIndex = 0;

  late final AnimationController _bgCtrl;
  late final AnimationController _heroCtrl;
  late final AnimationController _contentCtrl;

  late final Animation<double> _heroFade;
  late final Animation<double> _heroScale;
  late final Animation<double> _contentSlide;
  late final Animation<double> _contentFade;

  double _scrollOffset = 0;
  static const double _heroHeight = 300;

  Plazoleta? _plazoleta;

  @override
  void initState() {
    super.initState();
    debugPrint(
      '🔄 PlazoletaDetailPage.initState - plazoletaId=${widget.plazoletaId}, slug=${widget.slug}',
    );
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);

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

    _scrollController.addListener(() {
      setState(() => _scrollOffset = _scrollController.offset);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadPlazoleta();
    });

    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) _heroCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 380), () {
      if (mounted) _contentCtrl.forward();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    _scrollController.dispose();
    _bgCtrl.dispose();
    _heroCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      if (_plazoleta != null && mounted) {
        _loadPlazoleta();
        _loadTabData(_currentTabIndex);
      }
    }
  }

  @override
  void didUpdateWidget(PlazoletaDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slug != widget.slug ||
        oldWidget.plazoletaId != widget.plazoletaId) {
      _plazoleta = null;
      _currentTabIndex = 0;
      setState(() {});
      _loadPlazoleta();
    }
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() => _currentTabIndex = _tabController.index);
      _loadTabData(_tabController.index);
    }
  }

  void _loadPlazoleta() {
    debugPrint(
      '🔄 _loadPlazoleta called - slug=${widget.slug}, id=${widget.plazoletaId}',
    );
    try {
      final bloc = context.read<PlazoletaBloc>();
      debugPrint('🔄 _loadPlazoleta - bloc found, isClosed=${bloc.isClosed}');
      if (!bloc.isClosed) {
        if (widget.slug != null && widget.slug!.isNotEmpty) {
          bloc.add(LoadPlazoletaBySlug(slug: widget.slug!, forceRefresh: true));
        } else {
          bloc.add(
            LoadPlazoletaById(id: widget.plazoletaId, forceRefresh: true),
          );
        }
      }
    } catch (e) {
      debugPrint('🔄 _loadPlazoleta - ERROR: $e');
    }
  }

  void _loadTabData(int tabIndex) {
    if (!mounted) return;
    final effectiveId = _plazoleta?.id ?? widget.plazoletaId;
    if (effectiveId == 0) return;
    try {
      final bloc = context.read<PlazoletaBloc>();
      if (bloc.isClosed) return;
      switch (tabIndex) {
        case 0:
          bloc.add(LoadImagenesPlazoleta(plazoletaId: effectiveId));
          break;
        case 1:
          bloc.add(LoadProductosPlazoleta(plazoletaId: effectiveId));
          break;
        case 2:
          bloc.add(LoadTiendasPlazoleta(plazoletaId: effectiveId));
          break;
      }
    } catch (_) {}
  }

  Future<void> _onRefresh() async {
    _loadPlazoleta();
    _loadTabData(_currentTabIndex);
  }

  Future<void> _onSharePlazoleta() async {
    if (_plazoleta == null) return;

    try {
      final shareService = getIt<ShareService>();
      await shareService.compartirPlazoleta(
        slug: _plazoleta!.slug,
        nombrePlazoleta: _plazoleta!.nombre,
        descripcion: _plazoleta!.descripcion,
      );
    } catch (e) {
      if (mounted) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor:
                isDark ? const Color(0xFF1A0808) : Colors.red.shade900,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: (isDark ? Colors.red : Colors.red.shade300).withOpacity(
                  0.35,
                ),
              ),
            ),
            content: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: isDark ? Colors.red[300] : Colors.red.shade200,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Error al compartir: $e',
                    style: TextStyle(
                      color: isDark ? Colors.red[200] : Colors.red.shade100,
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
  }

  double get _collapseProgress =>
      (_scrollOffset / (_heroHeight - kToolbarHeight)).clamp(0.0, 1.0);

  Map<String, dynamic> _productoToMap(Producto p) {
    String? imagenUrl;
    List<Map<String, dynamic>> imagenesList = [];
    List<Map<String, dynamic>> imagenesProductoList = [];

    if (p.imagenes != null && p.imagenes!.isNotEmpty) {
      for (final img in p.imagenes!) {
        if (img is Map<String, dynamic>) {
          imagenesList.add(img);
          imagenesProductoList.add(img);
          if (imagenUrl == null && img['url_imagen'] != null) {
            imagenUrl = img['url_imagen'] as String?;
          }
        } else {
          final imgMap = {
            'url_imagen': img.urlPreferida,
            'url': img.urlPreferida,
            'tipo_imagen': img.tipoImagen.value,
            'es_principal': img.esPrincipal,
          };
          imagenesList.add(imgMap);
          imagenesProductoList.add(imgMap);
          if (imagenUrl == null && img.esPrincipal) {
            imagenUrl = img.urlPreferida;
          }
        }
      }
      if (imagenUrl == null && imagenesList.isNotEmpty) {
        imagenUrl =
            imagenesList.first['url_imagen'] as String? ??
            imagenesList.first['url'] as String?;
      }
    }

    return {
      'id': p.id,
      'nombre': p.nombre,
      'nombre_producto': p.nombre,
      'descripcion': p.descripcion,
      'precio': p.precioBase,
      'precio_base': p.precioBase,
      'imagenUrl': imagenUrl,
      'imagenes': imagenesList,
      'imagen_productos': imagenesProductoList,
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
    'total_visitas': t.totalVisitas,
    'totalContactosWhatsapp': t.totalContactosWhatsapp,
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<PlazoletaBloc, PlazoletaState>(
      builder: (context, state) {
        Plazoleta? plazoleta;
        List<ImagenBase> imagenes = [];
        List<Producto> productos = [];
        List<Tienda> tiendas = [];

        if (state is PlazoletaLoaded && state.plazoletaSeleccionada != null) {
          plazoleta = state.plazoletaSeleccionada!;
          _plazoleta = plazoleta;
          imagenes = state.imagenesPlazoleta ?? [];
          productos = state.productosPlazoleta ?? [];
          tiendas = state.tiendasPlazoleta ?? [];
        }

        if (plazoleta == null) {
          return Scaffold(
            backgroundColor: isDark ? _kBg : Colors.grey.shade100,
            body: Stack(
              children: [
                AnimatedBuilder(
                  animation: _bgCtrl,
                  builder:
                      (_, __) => CustomPaint(
                        size: MediaQuery.of(context).size,
                        painter: PlazoletaBgPainter(
                          _bgCtrl.value,
                          Theme.of(context).brightness,
                        ),
                      ),
                ),
                _buildLoadingOrError(state, isDark),
              ],
            ),
          );
        }

        return _buildPage(
          context,
          plazoleta,
          imagenes,
          productos,
          tiendas,
          isDark,
        );
      },
    );
  }

  Widget _buildLoadingOrError(PlazoletaState state, bool isDark) {
    if (state is PlazoletaDetailError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: _kGold, size: 48),
            const SizedBox(height: 16),
            Text(
              state.message,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            PlazoletaOutlineButton(label: 'Reintentar', onTap: _loadPlazoleta),
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
    bool isDark,
  ) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDark ? _kBg : Colors.grey.shade100,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _bgCtrl,
            builder:
                (_, __) => CustomPaint(
                  size: size,
                  painter: PlazoletaBgPainter(
                    _bgCtrl.value,
                    isDark ? Brightness.dark : Brightness.light,
                  ),
                ),
          ),
          NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder:
                (context, _) => [
                  SliverToBoxAdapter(
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_heroFade, _heroScale]),
                      builder:
                          (_, __) => Opacity(
                            opacity: _heroFade.value,
                            child: Transform.scale(
                              scale: _heroScale.value,
                              alignment: Alignment.topCenter,
                              child: PlazoletaHero(
                                plazoleta: plazoleta,
                                imagenes: imagenes,
                                productos: productos,
                                tiendas: tiendas,
                              ),
                            ),
                          ),
                    ),
                  ),
                ],
            body: Column(
              children: [
                PlazoletaTabBar(tabController: _tabController),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      PlazoletaInfoTab(
                        plazoleta: plazoleta,
                        imagenes: imagenes,
                        onRefresh: _onRefresh,
                        contentFade: _contentFade,
                        contentSlide: _contentSlide,
                      ),
                      PlazoletaProductosTab(
                        productos: productos.map(_productoToMap).toList(),
                        onRefresh: _onRefresh,
                        onProductoTap: (producto) {
                          final id = producto['id'];
                          if (id != null) {
                            context.push('/productos/$id', extra: producto);
                          }
                        },
                      ),
                      PlazoletaTiendasTab(
                        tiendas: tiendas.map(_tiendaToMap).toList(),
                        onRefresh: _onRefresh,
                        onTiendaTap: (tienda) {
                          final id = tienda['id'];
                          if (id != null) {
                            context.push('/tiendas/$id');
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: PlazoletaFloatingAppBar(
              title: plazoleta.nombre,
              collapseProgress: _collapseProgress,
              onBack: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  Future.microtask(() => context.go('/plazoletas'));
                }
              },
              onShare: _onSharePlazoleta,
            ),
          ),
        ],
      ),
      floatingActionButton: ProfileFloatingButton(),
    );
  }
}
