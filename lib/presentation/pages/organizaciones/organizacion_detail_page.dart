// lib/presentation/pages/organizaciones/organizacion_detail_page.dart
//
// 🏛️  PLAZA UNIVERSE — Detalle de Organización
// ────────────────────────────────────────────────────────────
//  Phase 8: Fragmented with theme support
// ────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:paseo_del_comercio/domain/entities/organizacion.dart';
import 'package:paseo_del_comercio/core/utils/share_service.dart';
import 'package:paseo_del_comercio/di/service_locator.dart';

import 'package:paseo_del_comercio/presentation/blocs/organizacion/organizacion_bloc.dart';
import 'package:paseo_del_comercio/presentation/widgets/organizacion/organizacion_bg_painter.dart';
import 'package:paseo_del_comercio/presentation/widgets/organizacion/detail/organizacion_hero.dart';
import 'package:paseo_del_comercio/presentation/widgets/organizacion/detail/organizacion_app_bar.dart';
import 'package:paseo_del_comercio/presentation/widgets/organizacion/detail/organizacion_info_tab.dart';
import 'package:paseo_del_comercio/presentation/widgets/organizacion/detail/organizacion_tiendas_tab.dart';
import 'package:paseo_del_comercio/presentation/widgets/organizacion/organizacion_components.dart';
import 'package:paseo_del_comercio/presentation/widgets/shared/profile_floating_button.dart';

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
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final TabController _tabController;
  final _scrollController = ScrollController();

  bool _hasLoaded = false;

  late final AnimationController _bgCtrl;
  late final AnimationController _heroCtrl;
  late final AnimationController _contentCtrl;

  late final Animation<double> _heroFade;
  late final Animation<double> _heroScale;
  late final Animation<double> _contentSlide;
  late final Animation<double> _contentFade;

  double _scrollOffset = 0;
  static const double _heroHeight = 300;

  Organizacion? _organizacion;

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
      if (mounted) {
        final bloc = context.read<OrganizacionBloc>();
        if (!bloc.isClosed) {
          bloc.add(
            LoadOrganizacionById(
              organizacionId: widget.organizacionId,
              loadTiendas: true,
              loadMiembros: true,
            ),
          );
        }
      }
    }
  }

  @override
  void didUpdateWidget(OrganizacionDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.organizacionId != widget.organizacionId) {
      _hasLoaded = false;
      final bloc = context.read<OrganizacionBloc>();
      if (!bloc.isClosed) {
        bloc.add(
          LoadOrganizacionById(
            organizacionId: widget.organizacionId,
            loadTiendas: true,
            loadMiembros: true,
          ),
        );
      }
    }
  }

  Future<void> _onShareOrganizacion() async {
    if (_organizacion == null) return;

    try {
      final shareService = getIt<ShareService>();
      await shareService.compartirOrganizacion(
        organizacionId: _organizacion!.id,
        nombreOrganizacion: _organizacion!.nombre ?? 'Organización',
        descripcion: _organizacion!.descripcion,
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

  void _onTiendaTap(Map<String, dynamic> tienda) {
    final tiendaId = tienda['id'];
    if (tiendaId != null) {
      context.push('/tiendas/$tiendaId');
    }
  }

  double get _collapseProgress =>
      (_scrollOffset / (_heroHeight - kToolbarHeight)).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<OrganizacionBloc, OrganizacionState>(
      builder: (context, state) {
        Organizacion? org;
        List<dynamic> tiendas = [];

        if (state is OrganizacionDetailLoaded) {
          org = state.organizacion;
          _organizacion = org;
          tiendas = state.tiendas ?? [];
        } else if (widget.organizacion != null) {
          org = widget.organizacion;
          _organizacion = org;
        }

        if (org == null) {
          return Scaffold(
            backgroundColor:
                isDark ? const Color(0xFF07070F) : Colors.grey.shade100,
            body: Stack(
              children: [
                AnimatedBuilder(
                  animation: _bgCtrl,
                  builder:
                      (_, __) => CustomPaint(
                        size: MediaQuery.of(context).size,
                        painter: OrganizacionBgPainter(
                          _bgCtrl.value,
                          Brightness.dark,
                        ),
                      ),
                ),
                const OrganizacionLoader(),
              ],
            ),
          );
        }

        return _buildPage(context, org, tiendas, isDark);
      },
    );
  }

  Widget _buildPage(
    BuildContext context,
    Organizacion org,
    List<dynamic> tiendas,
    bool isDark,
  ) {
    final size = MediaQuery.of(context).size;
    final tiendasMaps = tiendas.cast<Map<String, dynamic>>();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF07070F) : Colors.grey.shade100,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _bgCtrl,
            builder:
                (_, __) => CustomPaint(
                  size: size,
                  painter: OrganizacionBgPainter(
                    _bgCtrl.value,
                    Theme.of(context).brightness,
                  ),
                ),
          ),
          NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder:
                (context, innerBoxIsScrolled) => [
                  SliverToBoxAdapter(
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_heroFade, _heroScale]),
                      builder:
                          (_, __) => Opacity(
                            opacity: _heroFade.value,
                            child: Transform.scale(
                              scale: _heroScale.value,
                              alignment: Alignment.topCenter,
                              child: OrganizacionHero(organizacion: org),
                            ),
                          ),
                    ),
                  ),
                ],
            body: Column(
              children: [
                OrganizacionTabBar(tabController: _tabController),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      OrganizacionInfoTab(
                        organizacion: org,
                        contentFade: _contentFade,
                        contentSlide: _contentSlide,
                      ),
                      OrganizacionTiendasTab(
                        tiendas: tiendasMaps,
                        onTiendaTap: _onTiendaTap,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: OrganizacionFloatingAppBar(
              title: org.nombreParaMostrar,
              collapseProgress: _collapseProgress,
              onBack: () {
                if (context.canPop()) {
                  Navigator.pop(context);
                } else {
                  Future.microtask(() => context.go('/organizaciones'));
                }
              },
              onShare: _onShareOrganizacion,
            ),
          ),
        ],
      ),
      floatingActionButton: ProfileFloatingButton(),
    );
  }
}
