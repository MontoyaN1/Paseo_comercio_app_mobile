// lib/presentation/pages/productos/producto_detail_page.dart
//
// 🏛️  PLAZA UNIVERSE — Detalle de Producto
// ────────────────────────────────────────────────────────────

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:paseo_del_comercio/core/app/app_config.dart';
import 'package:paseo_del_comercio/core/utils/firebase_auth_service.dart';
import 'package:paseo_del_comercio/core/utils/share_service.dart';
import 'package:paseo_del_comercio/data/datasources/remote/supabase_client.dart';
import 'package:paseo_del_comercio/di/service_locator.dart';

import 'package:paseo_del_comercio/presentation/blocs/producto/producto_bloc.dart';
import 'package:paseo_del_comercio/presentation/widgets/producto/producto_bg_painter.dart';
import 'package:paseo_del_comercio/presentation/widgets/producto/producto_hero.dart';
import 'package:paseo_del_comercio/presentation/widgets/producto/producto_app_bar.dart';
import 'package:paseo_del_comercio/presentation/widgets/producto/producto_info_tab.dart';
import 'package:paseo_del_comercio/presentation/widgets/producto/producto_tienda_tab.dart';
import 'package:paseo_del_comercio/presentation/widgets/producto/producto_valoraciones_tab.dart';
import 'package:paseo_del_comercio/presentation/widgets/producto/producto_valoracion_dialog.dart';
import '../../widgets/profile_floating_button.dart';

const _kGold = Color(0xFFD4AF37);
const _kBg = Color(0xFF07070F);
const _kSurface = Color(0xFF0F0F1E);
const _kBorder = Color(0xFF1E1E3A);
const _kHint = Color(0xFF6B6B8A);

class ProductoDetailPage extends StatefulWidget {
  final int productoId;
  final Map<String, dynamic>? producto;

  const ProductoDetailPage({
    super.key,
    required this.productoId,
    this.producto,
  });

  @override
  State<ProductoDetailPage> createState() => _ProductoDetailPageState();
}

class _ProductoDetailPageState extends State<ProductoDetailPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  final _scrollController = ScrollController();
  bool _hasLoaded = false;

  late AnimationController _bgCtrl;
  late AnimationController _heroCtrl;
  late AnimationController _contentCtrl;
  late Animation<double> _heroFade;
  late Animation<double> _heroScale;
  late Animation<double> _contentSlide;
  late Animation<double> _contentFade;

  double _scrollOffset = 0;
  static const double _heroHeight = 320.0;

  Map<String, dynamic>? _productoData;
  Map<String, dynamic>? _tiendaData;
  final AppConfig _appConfig = AppConfig();

  List<Map<String, dynamic>> _valoraciones = [];
  bool _valoracionesLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _heroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _heroFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut));
    _heroScale = Tween<double>(
      begin: 1.1,
      end: 1,
    ).animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut));
    _contentSlide = Tween<double>(
      begin: 30,
      end: 0,
    ).animate(CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut));
    _contentFade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _heroCtrl.forward();
        _contentCtrl.forward();
      }
    });

    if (widget.producto != null) {
      _hasLoaded = true;
      _productoData = widget.producto;
      _procesarProducto(widget.producto!);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoaded && widget.producto == null) {
      _loadProducto();
    } else if (_hasLoaded && _tiendaData == null && _productoData != null) {
      _procesarProducto(_productoData!);
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
    if (state == AppLifecycleState.resumed) {
      if (_hasLoaded && _productoData != null) {
        _procesarProducto(_productoData!);
      }
    }
  }

  @override
  void didUpdateWidget(ProductoDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.productoId != widget.productoId) {
      _hasLoaded = false;
      _productoData = null;
      _tiendaData = null;
      _valoracionesLoaded = false;
      _valoraciones = [];
      _loadProducto();
      setState(() {});
    }
  }

  void _onScroll() {
    setState(() => _scrollOffset = _scrollController.offset);
  }

  double get _collapseProgress {
    if (_scrollController.hasClients) {
      return (_scrollOffset / (_heroHeight - kToolbarHeight)).clamp(0.0, 1.0);
    }
    return 0;
  }

  void _loadProducto() {
    if (_hasLoaded) return;
    getIt<ProductoBloc>().add(
      ProductoLoadByIdRequested(
        productoId: widget.productoId,
        forceRefresh: true,
      ),
    );
  }

  void _procesarProducto(Map<String, dynamic> producto) async {
    if (producto['tienda'] != null) {
      _tiendaData = _transformTiendaUrlsToR2(
        producto['tienda'] as Map<String, dynamic>,
      );
      if (mounted) setState(() {});
    } else if (producto['tiendas'] != null) {
      _tiendaData = _transformTiendaUrlsToR2(
        producto['tiendas'] as Map<String, dynamic>,
      );
      if (mounted) setState(() {});
    } else if (producto['tienda_id'] != null) {
      if (_tiendaData != null && _tiendaData!['id'] == producto['tienda_id'])
        return;

      try {
        final supabase = getIt<SupabaseClientService>();
        final tiendaResponse = await supabase.tiendas
            .select('*, imagen_tienda!left(*)')
            .eq('id', producto['tienda_id'])
            .limit(1);

        if (tiendaResponse.isNotEmpty) {
          _tiendaData = _transformTiendaUrlsToR2(
            Map<String, dynamic>.from(tiendaResponse.first),
          );
          if (mounted) setState(() {});
        } else {
          _tiendaData = {'id': producto['tienda_id']};
        }
      } catch (e) {
        _tiendaData = {'id': producto['tienda_id']};
      }
    }

    _registrarVistaProducto();
    if (_tiendaData?['id'] != null) {
      _registrarVisitaTienda(_tiendaData!['id'] as int);
    }
  }

  Future<void> _registrarVistaProducto() async {
    try {
      final supabase = getIt<SupabaseClientService>();
      final producto =
          await supabase.productos
              .select('total_visualizaciones')
              .eq('id', widget.productoId)
              .maybeSingle();

      if (producto != null) {
        final totalVisualizaciones =
            (producto['total_visualizaciones'] as int? ?? 0) + 1;
        await supabase.productos
            .update({
              'total_visualizaciones': totalVisualizaciones,
              'fecha_ultima_interaccion': DateTime.now().toIso8601String(),
            })
            .eq('id', widget.productoId);
      }
    } catch (e) {
      debugPrint('Error registrando vista del producto: $e');
    }
  }

  Future<void> _registrarVisitaTienda(int tiendaId) async {
    try {
      final supabase = getIt<SupabaseClientService>();
      final tienda =
          await supabase.tiendas
              .select('total_visitas')
              .eq('id', tiendaId)
              .maybeSingle();

      if (tienda != null) {
        final totalVisitas = (tienda['total_visitas'] as int? ?? 0) + 1;
        await supabase.tiendas
            .update({
              'total_visitas': totalVisitas,
              'fecha_ultima_visita': DateTime.now().toIso8601String(),
            })
            .eq('id', tiendaId);
      }
    } catch (e) {
      debugPrint('Error registrando visita a la tienda: $e');
    }
  }

  Future<void> _loadValoraciones() async {
    if (_valoracionesLoaded) return;

    try {
      final supabase = getIt<SupabaseClientService>();
      final response = await supabase.valoraciones
          .select()
          .eq('producto_id', widget.productoId)
          .eq('estado_valoracion', 'publicado')
          .order('fecha_creacion', ascending: false);

      if (response.isNotEmpty) {
        final valoracionesConUsuario = <Map<String, dynamic>>[];

        for (final valoracion in response) {
          final usuarioId = valoracion['usuario_id'];
          if (usuarioId != null) {
            try {
              final usuarioIdInt =
                  usuarioId is int
                      ? usuarioId
                      : int.tryParse(usuarioId.toString());

              Map<String, dynamic>? usuarioResponse;
              try {
                usuarioResponse =
                    usuarioIdInt != null
                        ? await supabase.usuarios
                            .select('id, nombre_completo, email, avatar_url')
                            .eq('id', usuarioIdInt)
                            .maybeSingle()
                        : await supabase.usuarios
                            .select('id, nombre_completo, email, avatar_url')
                            .eq('id', usuarioId.toString())
                            .maybeSingle();
              } catch (_) {
                usuarioResponse =
                    usuarioIdInt != null
                        ? await supabase.usuarios
                            .select()
                            .eq('id', usuarioIdInt)
                            .maybeSingle()
                        : await supabase.usuarios
                            .select()
                            .eq('id', usuarioId.toString())
                            .maybeSingle();
              }

              final valoracionConUsuario = Map<String, dynamic>.from(
                valoracion,
              );
              valoracionConUsuario['usuario'] = usuarioResponse;
              valoracionesConUsuario.add(valoracionConUsuario);
            } catch (_) {
              valoracionesConUsuario.add(valoracion);
            }
          } else {
            valoracionesConUsuario.add(valoracion);
          }
        }

        await _actualizarEstadisticasProducto(
          valoracionesConUsuario.length,
          valoracionesConUsuario,
        );

        setState(() {
          _valoraciones = valoracionesConUsuario;
          _valoracionesLoaded = true;
        });
      } else {
        setState(() {
          _valoraciones = [];
          _valoracionesLoaded = true;
        });
      }
    } catch (e) {
      setState(() {
        _valoraciones = [];
        _valoracionesLoaded = true;
      });
    }
  }

  Future<void> _actualizarEstadisticasProducto(
    int totalValoracionesReales,
    List<Map<String, dynamic>> valoraciones,
  ) async {
    try {
      final supabase = getIt<SupabaseClientService>();
      final productoResponse =
          await supabase.productos
              .select('total_valoracion, calificacion_promedio')
              .eq('id', widget.productoId)
              .maybeSingle();

      if (productoResponse == null) return;

      final totalEnDB = productoResponse['total_valoracion'] as int? ?? 0;
      double promedioCalculado = 0;

      if (totalValoracionesReales > 0) {
        final suma = valoraciones.fold<int>(
          0,
          (sum, v) => sum + ((v['calificacion'] as num?)?.toInt() ?? 0),
        );
        promedioCalculado = suma / totalValoracionesReales;
      }

      if (totalEnDB != totalValoracionesReales) {
        await supabase.productos
            .update({
              'total_valoracion': totalValoracionesReales,
              'calificacion_promedio': promedioCalculado,
            })
            .eq('id', widget.productoId);
      }
    } catch (e) {
      debugPrint('Error actualizando estadísticas: $e');
    }
  }

  String? _transformUrlToR2(String? url) {
    if (url == null || url.isEmpty) return url;
    if (!url.contains('contabostorage.com')) return url;

    try {
      if (_appConfig.cloudflareR2PublicUrl.isEmpty) return url;
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isEmpty) return url;
      final newPath = pathSegments.join('/');
      return '${_appConfig.cloudflareR2PublicUrl}/$newPath';
    } catch (e) {
      return url;
    }
  }

  Map<String, dynamic> _transformTiendaUrlsToR2(Map<String, dynamic> tienda) {
    final tiendaTransformada = Map<String, dynamic>.from(tienda);

    final logoUrl =
        tiendaTransformada['logoUrl'] ??
        tiendaTransformada['logo_url'] ??
        tiendaTransformada['url_logo'] ??
        tiendaTransformada['logo'];
    if (logoUrl != null && logoUrl is String && logoUrl.isNotEmpty) {
      final transformed = _transformUrlToR2(logoUrl);
      tiendaTransformada['logoUrl'] = transformed;
      tiendaTransformada['logo_url'] = transformed;
    }

    final imagenesTienda = tiendaTransformada['imagen_tienda'];
    if (imagenesTienda is List) {
      final nuevasImagenes = <Map<String, dynamic>>[];
      for (final img in imagenesTienda) {
        if (img is Map<String, dynamic>) {
          final nuevaImagen = Map<String, dynamic>.from(img);
          final urlImagen = nuevaImagen['url_imagen'] as String?;
          if (urlImagen != null) {
            nuevaImagen['url_imagen'] = _transformUrlToR2(urlImagen);
          }
          nuevasImagenes.add(nuevaImagen);
        }
      }
      tiendaTransformada['imagen_tienda'] = nuevasImagenes;
    }

    return tiendaTransformada;
  }

  String? _getProductImageUrl() {
    if (_productoData == null) return null;

    final imagenProductoData = _productoData!['imagen_productos'];
    if (imagenProductoData is List && imagenProductoData.isNotEmpty) {
      String? imagenPrincipal;
      for (final img in imagenProductoData) {
        if (img is Map<String, dynamic>) {
          final tipo = img['tipo_imagen'] ?? img['tipo'];
          if (tipo == 'principal' || img['es_principal'] == true) {
            imagenPrincipal = img['url'] ?? img['url_imagen'];
            break;
          }
        }
      }
      if (imagenPrincipal == null && imagenProductoData.isNotEmpty) {
        final primera = imagenProductoData.first;
        if (primera is Map<String, dynamic>) {
          imagenPrincipal = primera['url'] ?? primera['url_imagen'];
        }
      }
      if (imagenPrincipal != null) {
        return _transformUrlToR2(imagenPrincipal);
      }
    }

    final imagenUrl =
        _productoData!['imagen'] ??
        _productoData!['imagen_url'] ??
        _productoData!['url_imagen'];
    return _transformUrlToR2(imagenUrl?.toString());
  }

  String _getProductoNombre() {
    return _productoData?['nombre'] ??
        _productoData?['nombre_producto'] ??
        'Producto sin nombre';
  }

  Future<void> _onShareProducto() async {
    if (_productoData == null) return;

    try {
      final shareService = getIt<ShareService>();
      final nombre = _getProductoNombre();
      final descripcion = _productoData!['descripcion'] as String?;
      final precio = _productoData!['precio'];
      final precioDouble =
          precio is int ? precio.toDouble() : (precio as double?);

      await shareService.compartirProducto(
        productoId: widget.productoId,
        nombreProducto: nombre,
        descripcion: descripcion,
        precio: precioDouble,
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

  Future<void> _enviarWhatsapp() async {
    final telefonoTienda =
        _tiendaData?['telefono_contacto'] ??
        _tiendaData?['telefono'] ??
        _productoData?['telefono_tienda'];

    if (telefonoTienda == null || telefonoTienda.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Teléfono no disponible')));
      }
      return;
    }

    String telefonoLimpio = telefonoTienda.toString();
    if (telefonoLimpio.startsWith('+')) {
      telefonoLimpio = telefonoLimpio.substring(1);
    }
    telefonoLimpio = telefonoLimpio.replaceAll(RegExp(r'[^\d]'), '');

    final mensaje =
        'Hola vengo del Paseo del Comercio y estoy interesado en ${_getProductoNombre()}';
    final url =
        'https://wa.me/$telefonoLimpio?text=${Uri.encodeComponent(mensaje)}';

    await _incrementarClicksWhatsapp();

    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al abrir WhatsApp: $e')));
      }
    }
  }

  Future<void> _incrementarClicksWhatsapp() async {
    try {
      final supabase = getIt<SupabaseClientService>();
      final producto =
          await supabase.productos
              .select('total_clicks_whatsapp')
              .eq('id', widget.productoId)
              .maybeSingle();

      if (producto != null) {
        final totalClicks =
            (producto['total_clicks_whatsapp'] as int? ?? 0) + 1;
        await supabase.productos
            .update({'total_clicks_whatsapp': totalClicks})
            .eq('id', widget.productoId);
      }
    } catch (e) {
      debugPrint('Error registrando click WhatsApp: $e');
    }
  }

  void _onTiendaTap() {
    if (_tiendaData != null) {
      final tiendaId = _tiendaData!['id'];
      if (tiendaId != null) {
        context.push('/tiendas/$tiendaId');
      }
    }
  }

  Future<void> _crearValoracion(double calificacion, String comentario) async {
    try {
      final supabase = getIt<SupabaseClientService>();
      final authService = getIt<FirebaseAuthService>();
      final firebaseUserId = authService.currentUserId;

      if (firebaseUserId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Debes iniciar sesión para valorar')),
          );
        }
        return;
      }

      final usuarioResponse = await supabase.usuarios
          .select()
          .eq('firebase_user_id', firebaseUserId)
          .limit(1);

      if (usuarioResponse.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Usuario no encontrado. Contacta soporte.'),
            ),
          );
        }
        return;
      }

      final usuario = usuarioResponse.first;
      final usuarioId = usuario['id'];

      await supabase.valoraciones.insert({
        'producto_id': widget.productoId,
        'usuario_id': usuarioId,
        'calificacion': calificacion.toInt(),
        'comentario': comentario.trim(),
        'estado_valoracion': 'publicado',
        'fecha_creacion': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Gracias por tu reseña!'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() => _valoracionesLoaded = false);
        await _loadValoraciones();
      }
    } catch (e) {
      debugPrint('Error creando valoración: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar reseña: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductoBloc>.value(
      value: getIt<ProductoBloc>(),
      child: BlocConsumer<ProductoBloc, ProductoState>(
        listener: (context, state) {
          if (state is ProductoDetailLoaded && !_hasLoaded) {
            setState(() {
              _productoData = state.producto;
              _hasLoaded = true;
            });
            _procesarProducto(state.producto);
          }
        },
        builder: (context, state) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Scaffold(
            backgroundColor: isDark ? _kBg : Colors.white,
            body: Stack(
              children: [
                AnimatedBuilder(
                  animation: _bgCtrl,
                  builder:
                      (context, child) => CustomPaint(
                        painter: ProductoBgPainter(
                          _bgCtrl.value,
                          Theme.of(context).brightness,
                        ),
                        size: Size.infinite,
                      ),
                ),
                _buildContent(state),
              ],
            ),
            floatingActionButton: const ProfileFloatingButton(),
          );
        },
      ),
    );
  }

  Widget _buildContent(ProductoState state) {
    if (_productoData == null) {
      if (state is ProductoLoading) {
        return _buildLoadingOrError('Cargando producto...');
      }
      if (state is ProductoError) {
        return _buildLoadingOrError(state.message, onRetry: _loadProducto);
      }
      return _buildLoadingOrError('Producto no encontrado');
    }

    return _buildPage(context, _productoData!);
  }

  Widget _buildLoadingOrError(String message, {VoidCallback? onRetry}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: _kGold),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: _kHint)),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: const Text('Reintentar', style: TextStyle(color: _kGold)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPage(BuildContext context, Map<String, dynamic> producto) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor:
          Theme.of(context).brightness == Brightness.dark ? _kBg : Colors.white,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _bgCtrl,
            builder:
                (context, child) => CustomPaint(
                  size: size,
                  painter: ProductoBgPainter(
                    _bgCtrl.value,
                    Theme.of(context).brightness,
                  ),
                ),
          ),
          NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder:
                (context, _) => [
                  SliverToBoxAdapter(child: _buildHero(producto)),
                ],
            body: Column(
              children: [
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      AnimatedBuilder(
                        animation: _contentCtrl,
                        builder:
                            (_, child) => Opacity(
                              opacity: _contentFade.value.clamp(0.0, 1.0),
                              child: Transform.translate(
                                offset: Offset(0, _contentSlide.value),
                                child: child,
                              ),
                            ),
                        child: ProductoInfoTab(
                          producto: producto,
                          onWhatsApp: _enviarWhatsapp,
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _contentCtrl,
                        builder:
                            (_, child) => Opacity(
                              opacity: _contentFade.value.clamp(0.0, 1.0),
                              child: Transform.translate(
                                offset: Offset(0, _contentSlide.value),
                                child: child,
                              ),
                            ),
                        child: ProductoTiendaTab(
                          tienda: _tiendaData,
                          onTiendaTap: _onTiendaTap,
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _contentCtrl,
                        builder:
                            (_, child) => Opacity(
                              opacity: _contentFade.value.clamp(0.0, 1.0),
                              child: Transform.translate(
                                offset: Offset(0, _contentSlide.value),
                                child: child,
                              ),
                            ),
                        child: ProductoValoracionesTab(
                          valoraciones: _valoraciones,
                          isLoading: !_valoracionesLoaded,
                          onLoad: _loadValoraciones,
                          onAddValoracion:
                              () => showProductoValoracionDialog(
                                context,
                                onSubmit: _crearValoracion,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: ProductoFloatingAppBar(
              title: _getProductoNombre(),
              collapseProgress: _collapseProgress,
              onShare: _onShareProducto,
              productoId: producto['id'] as int?,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(Map<String, dynamic> producto) {
    final precio = producto['precio_base'];
    final precioDouble =
        precio is int ? precio.toDouble() : (precio as double?);

    return ProductoHero(
      imageUrl: _getProductImageUrl(),
      productName: _getProductoNombre(),
      precio: precioDouble,
      heroFade: _heroFade,
      heroScale: _heroScale,
    );
  }

  Widget _buildTabBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tabBgColor =
        isDark
            ? _kSurface.withValues(alpha: 0.88)
            : Colors.white.withValues(alpha: 0.88);
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
                text: 'Info',
                iconMargin: EdgeInsets.only(bottom: 2),
              ),
              Tab(
                icon: Icon(Icons.store_outlined, size: 18),
                text: 'Tienda',
                iconMargin: EdgeInsets.only(bottom: 2),
              ),
              Tab(
                icon: Icon(Icons.star_outline_rounded, size: 18),
                text: 'Reseñas',
                iconMargin: EdgeInsets.only(bottom: 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
