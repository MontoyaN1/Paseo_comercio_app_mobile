// lib/presentation/pages/tiendas/tienda_detail_page.dart
//
// 🏛️  PLAZA UNIVERSE — Detalle de Tienda
// ────────────────────────────────────────────────────────────

import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:paseo_del_comercio/core/app/app_config.dart';
import 'package:paseo_del_comercio/data/datasources/remote/supabase_client.dart';
import 'package:paseo_del_comercio/di/service_locator.dart';
import 'package:paseo_del_comercio/domain/entities/tienda.dart';

import 'package:paseo_del_comercio/presentation/blocs/tienda/tienda_bloc.dart';
import 'package:paseo_del_comercio/presentation/widgets/producto/producto_card.dart';
import '../../widgets/profile_floating_button.dart';

/// Extrae el código de país de un número de teléfono
String? extractCountryCode(String phoneNumber) {
  if (phoneNumber.startsWith('+')) {
    final plusIndex = phoneNumber.indexOf('+');
    final spaceIndex = phoneNumber.indexOf(' ');
    if (spaceIndex > plusIndex) {
      return phoneNumber.substring(plusIndex, spaceIndex);
    } else {
      int i = 1;
      while (i < phoneNumber.length &&
          phoneNumber[i].contains(RegExp(r'[0-9]'))) {
        i++;
      }
      return phoneNumber.substring(0, i);
    }
  }
  return null;
}

/// Obtiene la bandera emoji para un código de país dado
String? getFlagForCountryCode(String countryCode) {
  final Map<String, String> countryCodeToFlag = {
    '+57': '🇨🇴',
    '+34': '🇪🇸',
    '+1': '🇺🇸',
    '+52': '🇲🇽',
    '+54': '🇦🇷',
    '+56': '🇨🇱',
    '+51': '🇵🇪',
    '+58': '🇻🇪',
    '+55': '🇧🇷',
    '+44': '🇬🇧',
    '+33': '🇫🇷',
    '+49': '🇩🇪',
    '+39': '🇮🇹',
    '+81': '🇯🇵',
    '+86': '🇨🇳',
    '+91': '🇮🇳',
    '+7': '🇷🇺',
    '+61': '🇦🇺',
    '+64': '🇳🇿',
    '+27': '🇿🇦',
  };
  return countryCodeToFlag[countryCode];
}

/// Extrae solo el número sin el código de país
String extractPhoneWithoutCode(String phoneNumber) {
  if (phoneNumber.startsWith('+')) {
    final plusIndex = phoneNumber.indexOf('+');
    final spaceIndex = phoneNumber.indexOf(' ');
    if (spaceIndex > plusIndex) {
      return phoneNumber.substring(spaceIndex + 1);
    } else {
      int i = 1;
      while (i < phoneNumber.length &&
          phoneNumber[i].contains(RegExp(r'[0-9]'))) {
        i++;
      }
      return phoneNumber.substring(i);
    }
  }
  return phoneNumber;
}

/// Formatea el teléfono mostrando código de país y bandera
String formatPhoneWithFlag(String phoneNumber) {
  final countryCode = extractCountryCode(phoneNumber);
  final phoneWithoutCode = extractPhoneWithoutCode(phoneNumber);
  final flag = countryCode != null ? getFlagForCountryCode(countryCode) : null;

  if (flag != null && countryCode != null) {
    return '$flag $countryCode $phoneWithoutCode';
  }
  return phoneNumber;
}

// ── Paleta (idéntica al sistema de diseño) ────────────────────
const _kGold = Color(0xFFD4AF37);
const _kGoldLight = Color(0xFFFFE082);
const _kGoldDeep = Color(0xFF9C7A1A);
const _kBg = Color(0xFF07070F);
const _kSurface = Color(0xFF0F0F1E);
const _kSurfaceCard = Color(0xFF12121F);
const _kBorder = Color(0xFF1E1E3A);
const _kHint = Color(0xFF6B6B8A);

/// Widget para mostrar teléfono con bandera
class PhoneWithFlag extends StatelessWidget {
  final String phoneNumber;
  final TextStyle? textStyle;

  const PhoneWithFlag({super.key, required this.phoneNumber, this.textStyle});

  @override
  Widget build(BuildContext context) {
    final countryCode = extractCountryCode(phoneNumber);
    final phoneWithoutCode = extractPhoneWithoutCode(phoneNumber);
    final flag =
        countryCode != null ? getFlagForCountryCode(countryCode) : null;

    if (flag != null && countryCode != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(flag, style: textStyle),
          const SizedBox(width: 4),
          Text(countryCode, style: textStyle),
          const SizedBox(width: 4),
          Text(phoneWithoutCode, style: textStyle),
        ],
      );
    }
    return Text(phoneNumber, style: textStyle);
  }
}

// ══════════════════════════════════════════════════════════════
//  PAGE PRINCIPAL
// ══════════════════════════════════════════════════════════════
class TiendaDetailPage extends StatefulWidget {
  final int tiendaId;
  final Tienda? tienda;

  const TiendaDetailPage({super.key, required this.tiendaId, this.tienda});

  @override
  State<TiendaDetailPage> createState() => _TiendaDetailPageState();
}

class _TiendaDetailPageState extends State<TiendaDetailPage>
    with TickerProviderStateMixin {
  // ── Controllers ───────────────────────────────────────────
  late final TabController _tabController;
  final _scrollController = ScrollController();

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
  static const double _heroHeight = 280;

  // ── Datos ─────────────────────────────────────────────────
  Map<String, dynamic>? _tiendaData;
  List<Map<String, dynamic>> _productos = [];
  List<Map<String, dynamic>> _horarios = [];
  final AppConfig _appConfig = AppConfig();

  // ── Paginación de productos ──────────────────────────────
  int _productosPage = 1;
  bool _hasMoreProductos = true;
  bool _isLoadingMoreProductos = false;
  static const int _productosLimit = 6;

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
      if (mounted) _heroCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 380), () {
      if (mounted) _contentCtrl.forward();
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

  /// Registrar visita a la tienda
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
        debugPrint(
          'Visita registrada para tienda ${widget.tiendaId}: $totalVisitas',
        );
      }
    } catch (e) {
      debugPrint('Error registrando visita a la tienda: $e');
    }
  }

  void _loadTienda() {
    try {
      final bloc = context.read<TiendaBloc>();
      if (bloc.isClosed) return;

      if (widget.tienda != null) {
        // Transformar URLs de Contabo a Cloudflare R2 antes de asignar
        final logoUrl = _transformUrlToR2(widget.tienda!.logoUrl);

        // Transformar imagen_tienda si existe
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

        // Usar los datos directamente de la tienda recibida con URLs transformadas
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
        // DEBUG: Log para verificar datos de tienda
        debugPrint(
          '🔍 _loadTienda: tienda directa - id=${widget.tienda!.id}, logoUrl=$logoUrl',
        );
        // Cargar productos cuando se pasa la tienda directamente
        bloc.add(
          TiendaProductsRequested(
            tiendaId: widget.tienda!.id,
            limit: _productosLimit,
          ),
        );
        bloc.add(TiendaHorariosRequested(tiendaId: widget.tienda!.id));

        // Registrar visita a la tienda
        _registrarVisitaTienda();
      } else {
        // Cargar tienda por ID desde el router
        debugPrint(
          '🔍 _loadTienda: cargando por ID - tiendaId=${widget.tiendaId}',
        );
        bloc.add(
          TiendaLoadByIdRequested(
            tiendaId: widget.tiendaId,
            forceRefresh: true,
          ),
        );

        // Registrar visita a la tienda
        _registrarVisitaTienda();
      }
    } catch (e) {
      debugPrint('❌ _loadTienda error: $e');
    }
  }

  /// Transformar URL de Contabo a Cloudflare R2
  String? _transformUrlToR2(String? url) {
    if (url == null || url.isEmpty) return url;
    if (!url.contains('contabostorage.com')) return url;

    try {
      if (_appConfig.cloudflareR2PublicUrl.isEmpty) {
        return url;
      }

      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;

      // Buscar el índice de 'paseocomercio' en la ruta
      final paseocomercioIndex = pathSegments.indexWhere(
        (segment) => segment == 'paseocomercio',
      );
      if (paseocomercioIndex == -1 ||
          paseocomercioIndex >= pathSegments.length - 1) {
        return url;
      }

      // Construir ruta relativa después de 'paseocomercio'
      final relativePath = pathSegments
          .sublist(paseocomercioIndex + 1)
          .join('/');

      // Normalizar URL base eliminando barra final si existe
      String baseUrl = _appConfig.cloudflareR2PublicUrl.trim();
      if (baseUrl.endsWith('/')) {
        baseUrl = baseUrl.substring(0, baseUrl.length - 1);
      }

      // Construir URL de R2
      return '$baseUrl/$relativePath';
    } catch (e) {
      debugPrint('❌ Error transformando URL: $e');
      return url;
    }
  }

  /// Cargar más productos (paginación)
  void _loadMoreProductos() {
    if (_isLoadingMoreProductos || !_hasMoreProductos) return;

    final tiendaId = _tiendaData?['id'] as int? ?? widget.tienda?.id;
    if (tiendaId == null) return;

    setState(() {
      _isLoadingMoreProductos = true;
    });

    final nextPage = _productosPage + 1;
    debugPrint('🔍 Cargando más productos - página $nextPage');

    context.read<TiendaBloc>().add(
      TiendaProductsRequested(
        tiendaId: tiendaId,
        page: nextPage,
        limit: _productosLimit,
      ),
    );
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
  void _onShareTienda() {
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
              'Compartir tienda (pendiente)',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
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

  // ── Cuánto ha colapsado el hero (0..1) ────────────────────
  double get _collapseProgress =>
      (_scrollOffset / (_heroHeight - kToolbarHeight)).clamp(0.0, 1.0);

  // ══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return BlocListener<TiendaBloc, TiendaState>(
      listener: (context, state) {
        debugPrint('🔍 BlocListener estado: ${state.runtimeType}');

        // Cuando se carga la tienda por ID (desde el router)
        if (state is TiendaDetailLoaded && _tiendaData == null) {
          _tiendaData = state.tienda;
          final tiendaId = state.tienda['id'] as int?;
          debugPrint(
            '🔍 TiendaDetailLoaded - id=$tiendaId, logoUrl=${state.tienda['logoUrl']}',
          );
          if (tiendaId != null) {
            debugPrint('🔍 Solicitando productos para tienda $tiendaId');
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
        // Actualizar productos cuando se cargan
        if (state is TiendaProductsLoaded) {
          debugPrint(
            '🔍 TiendaProductsLoaded - tiendaId=${state.tiendaId}, productos=${state.productos.length}, hasMore=${state.hasMore}',
          );
          final currentTiendaId = _tiendaData?['id'] ?? widget.tienda?.id;
          debugPrint(
            '🔍 Comparando: state.tiendaId=${state.tiendaId} vs currentTiendaId=$currentTiendaId',
          );
          if (state.tiendaId == currentTiendaId) {
            setState(() {
              // Si es la primera página, reemplazar; si no, acumular
              if (state.currentPage == 1) {
                _productos = state.productos;
              } else {
                _productos = [..._productos, ...state.productos];
              }
              _hasMoreProductos = state.hasMore;
              _productosPage = state.currentPage;
              _isLoadingMoreProductos = false;
              debugPrint(
                '🔍 Productos actualizados: ${_productos.length}, hasMore: $_hasMoreProductos',
              );
            });
          }
        }
        if (state is TiendaHorariosLoaded) {
          debugPrint(
            '🔍 TiendaHorariosLoaded - horarios=${state.horarios.length}',
          );
          setState(() => _horarios = state.horarios);
        }
      },
      child: BlocBuilder<TiendaBloc, TiendaState>(
        builder: (context, state) {
          // Si tenemos tienda directa, mostrar inmediatamente
          if (_tiendaData != null) {
            return _buildPage(context, _tiendaData!);
          }

          // Si está cargando sin tienda, mostrar loading
          if (state is TiendaLoading) {
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

          // Mostrar error si no hay tienda
          if (_tiendaData == null) {
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
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.store_rounded,
                          color: _kGold,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Tienda no encontrada',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        _GoldOutlineButton(
                          label: 'Volver',
                          onTap: () => context.pop(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return _buildPage(context, _tiendaData!);
        },
      ),
    );
  }

  Widget _buildPage(BuildContext context, Map<String, dynamic> tienda) {
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
                (context, _) => [SliverToBoxAdapter(child: _buildHero(tienda))],
            body: Column(
              children: [
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [_buildInfoTab(tienda), _buildProductosTab()],
                  ),
                ),
              ],
            ),
          ),

          // ── AppBar flotante con glassmorphism ──────────────
          SafeArea(child: _buildFloatingAppBar(tienda)),
        ],
      ),
      floatingActionButton: const ProfileFloatingButton(
        hideOrganizacionesOption: true,
      ),
    );
  }

  // ── AppBar glassmorphism ──────────────────────────────────
  Widget _buildFloatingAppBar(Map<String, dynamic> tienda) {
    final opacity = _collapseProgress;
    final nombre = tienda['nombre'] ?? tienda['nombre_tienda'] ?? 'Tienda';
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20 * opacity, sigmaY: 20 * opacity),
        child: AnimatedContainer(
          duration: Duration.zero,
          height: kToolbarHeight,
          decoration: BoxDecoration(
            color: _kSurface.withAlpha((0.85 * opacity * 255).toInt()),
            border: Border(
              bottom: BorderSide(
                color: _kBorder.withAlpha((opacity * 255).toInt()),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 8),
              _GoldIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => context.pop(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AnimatedOpacity(
                  opacity: opacity,
                  duration: Duration.zero,
                  child: Text(
                    nombre,
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
              _GoldIconButton(icon: Icons.share_rounded, onTap: _onShareTienda),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ── Hero expandible ───────────────────────────────────────
  Widget _buildHero(Map<String, dynamic> tienda) {
    // Buscar logo en múltiples campos posibles
    String? imagenPrincipal;

    // Primero buscar en el array imagen_tienda (viene de Supabase con la relación)
    final imagenTiendaData = tienda['imagen_tienda'];
    if (imagenTiendaData != null) {
      if (imagenTiendaData is List && imagenTiendaData.isNotEmpty) {
        // Es un array de imágenes
        final primeraImagen = imagenTiendaData.first;
        if (primeraImagen is Map) {
          imagenPrincipal = primeraImagen['url'] ?? primeraImagen['url_imagen'];
        }
      } else if (imagenTiendaData is String && imagenTiendaData.isNotEmpty) {
        // Es una URL directa
        imagenPrincipal = imagenTiendaData;
      }
    }

    // Si no encontró en imagen_tienda, buscar en otros campos
    if (imagenPrincipal == null || imagenPrincipal.isEmpty) {
      final logoUrl =
          tienda['logoUrl'] ??
          tienda['logo_url'] ??
          tienda['url_logo'] ??
          tienda['logo'] ??
          tienda['imagen'];
      if (logoUrl != null && logoUrl.toString().isNotEmpty) {
        imagenPrincipal = logoUrl.toString();
      }
    }

    debugPrint('🔍 _buildHero - imagenPrincipal: $imagenPrincipal');

    // Si aún no hay imagen, buscar en el array de imágenes general
    if (imagenPrincipal == null || imagenPrincipal.isEmpty) {
      if (tienda['imagenes'] is List &&
          (tienda['imagenes'] as List).isNotEmpty) {
        final imagenes = tienda['imagenes'] as List;
        final principal = imagenes.firstWhere(
          (i) =>
              i is Map &&
              (i['es_principal'] == true || i['tipo_imagen'] == 'principal'),
          orElse: () => imagenes.first,
        );
        if (principal is Map) {
          imagenPrincipal = principal['url'] ?? principal['url_imagen'];
        }
      }
    }

    // Si aún no hay imagen, usar imagen_tienda
    if (imagenPrincipal == null || imagenPrincipal.isEmpty) {
      final imagenTienda = tienda['imagen_tienda'];
      if (imagenTienda != null) {
        if (imagenTienda is String) {
          imagenPrincipal = imagenTienda;
        } else if (imagenTienda is List && imagenTienda.isNotEmpty) {
          final first = imagenTienda.first;
          if (first is Map) {
            imagenPrincipal = first['url'] ?? first['url_imagen'];
          }
        }
      }
    }

    final tieneImagen = imagenPrincipal != null && imagenPrincipal.isNotEmpty;

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
                    // Imagen de fondo o logo
                    if (tieneImagen)
                      CachedNetworkImage(
                        imageUrl: imagenPrincipal!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _buildHeroFallback(tienda),
                      )
                    else
                      _buildHeroFallback(tienda),

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
                            _kGold.withAlpha((0.06 * 255).toInt()),
                            Colors.transparent,
                            _kGoldDeep.withAlpha((0.08 * 255).toInt()),
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
                                color: _kGold.withAlpha((0.15 * 255).toInt()),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _kGold.withAlpha((0.40 * 255).toInt()),
                                  width: 1,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('🏪', style: TextStyle(fontSize: 13)),
                                  SizedBox(width: 6),
                                  Text(
                                    'Tienda',
                                    style: TextStyle(
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
                                tienda['nombre'] ??
                                    tienda['nombre_tienda'] ??
                                    'Tienda',
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
                                  value: '${_productos.length} productos',
                                ),
                                const SizedBox(width: 8),
                                _HeroStatPill(
                                  icon: Icons.visibility_rounded,
                                  value:
                                      '${tienda['total_visitas'] ?? 0} visitas',
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

  Widget _buildHeroFallback(Map<String, dynamic> tienda) {
    // Buscar logo en múltiples campos posibles para el fallback
    final logoUrl =
        tienda['logoUrl'] ??
        tienda['logo_url'] ??
        tienda['url_logo'] ??
        tienda['logo'] ??
        tienda['imagen'] ??
        tienda['imagen_tienda'];

    final tieneLogo = logoUrl != null && logoUrl.toString().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _kGoldDeep.withAlpha((0.3 * 255).toInt()),
            _kBg,
            _kGold.withAlpha((0.2 * 255).toInt()),
          ],
        ),
      ),
      child:
          tieneLogo
              ? CachedNetworkImage(
                imageUrl: logoUrl.toString(),
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _buildHeroIconFallback(tienda),
              )
              : _buildHeroIconFallback(tienda),
    );
  }

  Widget _buildHeroIconFallback(Map<String, dynamic> tienda) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _kGold.withAlpha((0.15 * 255).toInt()),
              border: Border.all(
                color: _kGold.withAlpha((0.4 * 255).toInt()),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _kGold.withAlpha((0.3 * 255).toInt()),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(Icons.store_rounded, size: 40, color: _kGold),
          ),
          const SizedBox(height: 12),
          Text(
            tienda['nombre'] ?? tienda['nombre_tienda'] ?? 'Tienda',
            style: TextStyle(
              color: _kGold.withAlpha((0.8 * 255).toInt()),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── TabBar glassmorphism ──────────────────────────────────
  Widget _buildTabBar() {
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

  // ── Tab: Información ──────────────────────────────────────
  Widget _buildInfoTab(Map<String, dynamic> tienda) {
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
            // ── Descripción ───────────────────────────────
            if (tienda['descripcion'] != null &&
                tienda['descripcion'].toString().isNotEmpty) ...[
              _buildSection(
                title: 'Sobre la tienda',
                icon: Icons.auto_stories_rounded,
                child: Text(
                  tienda['descripcion'].toString(),
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
                  if (tienda['telefono_contacto'] != null ||
                      tienda['telefono'] != null ||
                      tienda['telefono_contacto']?.toString().isNotEmpty ==
                          true) ...[
                    _GoldInfoRow(
                      icon: Icons.phone_rounded,
                      label: 'Teléfono',
                      valueWidget: PhoneWithFlag(
                        phoneNumber:
                            tienda['telefono_contacto']?.toString() ??
                            tienda['telefono']?.toString() ??
                            'No disponible',
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    _GoldDivider(),
                  ],
                  if (tienda['email_contacto'] != null ||
                      tienda['email'] != null ||
                      tienda['email_contacto']?.toString().isNotEmpty ==
                          true) ...[
                    _GoldInfoRow(
                      icon: Icons.alternate_email_rounded,
                      label: 'Correo electrónico',
                      value:
                          tienda['email_contacto']?.toString() ??
                          tienda['email']?.toString() ??
                          'No disponible',
                    ),
                    _GoldDivider(),
                  ],
                  if (tienda['direccion'] != null &&
                      tienda['direccion'].toString().isNotEmpty) ...[
                    _GoldInfoRow(
                      icon: Icons.location_on_rounded,
                      label: 'Dirección',
                      value: tienda['direccion'].toString(),
                    ),
                    _GoldDivider(),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Horarios ──────────────────────────────────
            if (_horarios.isNotEmpty) ...[
              _buildSection(
                title: 'Horarios de atención',
                icon: Icons.schedule_rounded,
                child: Column(
                  children:
                      _horarios.map((horario) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                horario['dia']?.toString() ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                (horario['hora_apertura'] != null &&
                                        horario['hora_cierre'] != null)
                                    ? '${horario['hora_apertura']} - ${horario['hora_cierre']}'
                                    : 'Cerrado',
                                style: TextStyle(
                                  color:
                                      (horario['hora_apertura'] != null)
                                          ? _kGold
                                          : _kHint,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Redes Sociales ─────────────────────────────
            if (tienda['redes_sociales'] != null &&
                (tienda['redes_sociales'] as Map).isNotEmpty) ...[
              _buildSection(
                title: 'Redes sociales',
                icon: Icons.share_rounded,
                child: Column(
                  children: _buildRedesSocialesButtons(
                    tienda['redes_sociales'] as Map<String, dynamic>,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Stats ─────────────────────────────────────
            _buildStatsRow(tienda),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(Map<String, dynamic> tienda) {
    return Row(
      children: [
        Expanded(
          child: _GoldStatCard(
            icon: Icons.visibility_rounded,
            value: tienda['total_visitas'] ?? 0,
            label: 'Visitas',
          ),
        ),
      ],
    );
  }

  /// Construir botones de redes sociales
  List<Widget> _buildRedesSocialesButtons(Map<String, dynamic> redesSociales) {
    final buttons = <Widget>[];

    // Mapeo de redes sociales a sus iconos y colores
    final socialConfig = {
      'facebook': {
        'icon': Icons.facebook_rounded,
        'color': const Color(0xFF1877F2),
      },
      'instagram': {
        'icon': Icons.camera_alt_rounded,
        'color': const Color(0xFFE4405F),
      },
      'twitter': {
        'icon': Icons.alternate_email_rounded,
        'color': const Color(0xFF1DA1F2),
      },
      'x': {
        'icon': Icons.alternate_email_rounded,
        'color': const Color(0xFF000000),
      },
      'tiktok': {
        'icon': Icons.music_note_rounded,
        'color': const Color(0xFF25F4EE),
      },
      'youtube': {
        'icon': Icons.play_circle_rounded,
        'color': const Color(0xFFFF0000),
      },
      'linkedin': {
        'icon': Icons.work_rounded,
        'color': const Color(0xFF0A66C2),
      },
      'whatsapp': {
        'icon': Icons.chat_rounded,
        'color': const Color(0xFF25D366),
      },
      'web': {'icon': Icons.language_rounded, 'color': _kGold},
    };

    for (final entry in redesSociales.entries) {
      final red = entry.key.toLowerCase();
      dynamic valor = entry.value;

      // Extraer URL correctamente dependiendo del tipo de valor
      String? url;
      if (valor is String) {
        // Si es un string que contiene JSON (tiene {), parsearlo
        if (valor.contains('{')) {
          try {
            final parsed = jsonDecode(valor);
            if (parsed is Map) {
              url = parsed['url'] as String?;
            }
          } catch (e) {
            // Si no se puede parsear, usar como URL directa
            url = valor;
          }
        } else {
          url = valor;
        }
      } else if (valor is Map) {
        url = valor['url'] as String?;
      }

      if (url == null || url.isEmpty) continue;

      final config = socialConfig[red];
      if (config == null) continue;

      buttons.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _abrirUrl(url!),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: (config['color'] as Color).withAlpha(
                  (0.15 * 255).toInt(),
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (config['color'] as Color).withAlpha(
                    (0.3 * 255).toInt(),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    config['icon'] as IconData,
                    color: config['color'] as Color,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _formatearNombreRed(red),
                      style: TextStyle(
                        color: (config['color'] as Color),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.open_in_new_rounded,
                    color: (config['color'] as Color).withAlpha(
                      (0.7 * 255).toInt(),
                    ),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return buttons;
  }

  /// Formatear nombre de red social para mostrar
  String _formatearNombreRed(String red) {
    final nombres = {
      'facebook': 'Facebook',
      'instagram': 'Instagram',
      'twitter': 'Twitter',
      'x': 'X (Twitter)',
      'tiktok': 'TikTok',
      'youtube': 'YouTube',
      'linkedin': 'LinkedIn',
      'whatsapp': 'WhatsApp',
      'web': 'Sitio web',
    };
    return nombres[red.toLowerCase()] ?? red;
  }

  /// Abrir URL en navegador
  Future<void> _abrirUrl(String url) async {
    try {
      // Añadir https si no tiene protocolo
      String urlFinal = url;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        urlFinal = 'https://$url';
      }
      final uri = Uri.parse(urlFinal);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error al abrir URL: $e');
    }
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kSurfaceCard.withAlpha((0.6 * 255).toInt()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder.withAlpha((0.5 * 255).toInt())),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: _kGold),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  // ── Tab: Productos ────────────────────────────────────────
  Widget _buildProductosTab() {
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
          _productos.isEmpty
              ? _buildEmptyState(
                icon: Icons.shopping_bag_rounded,
                title: 'Sin productos',
                subtitle: 'Esta tienda no tiene\nproductos disponibles aún',
              )
              : NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification notification) {
                  if (notification is ScrollEndNotification) {
                    final metrics = notification.metrics;
                    if (metrics.pixels >= metrics.maxScrollExtent - 200) {
                      _loadMoreProductos();
                    }
                  }
                  return false;
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
                  itemCount: _productos.length + (_hasMoreProductos ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Si es el último item y hay más productos, mostrar indicador de carga
                    if (index >= _productos.length) {
                      return _buildLoadMoreIndicator();
                    }

                    final producto = _productos[index];
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
                        producto: producto,
                        onTap: () => _onProductoTap(producto),
                      ),
                    );
                  },
                ),
              ),
    );
  }

  // ── Indicador de cargar más productos ──────────────────────
  Widget _buildLoadMoreIndicator() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child:
            _isLoadingMoreProductos
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(_kGold),
                  ),
                )
                : TextButton(
                  onPressed: _loadMoreProductos,
                  child: const Text(
                    'Cargar más',
                    style: TextStyle(color: _kGold),
                  ),
                ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
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
              color: _kGold.withAlpha((0.06 * 255).toInt()),
              border: Border.all(
                color: _kGold.withAlpha((0.22 * 255).toInt()),
                width: 1.5,
              ),
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
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  WIDGETS AUXILIARES
// ══════════════════════════════════════════════════════════════

class _BgPainter extends CustomPainter {
  final double t;
  final math.Random rng = math.Random(42);

  final List<_Particle> particles = [
    _Particle(x: 0.1, y: 0.1, size: 4, speed: 0.3),
    _Particle(x: 0.2, y: 0.8, size: 3, speed: 0.4),
    _Particle(x: 0.3, y: 0.3, size: 5, speed: 0.25),
    _Particle(x: 0.4, y: 0.6, size: 4, speed: 0.35),
    _Particle(x: 0.5, y: 0.2, size: 3, speed: 0.45),
    _Particle(x: 0.6, y: 0.9, size: 5, speed: 0.3),
    _Particle(x: 0.7, y: 0.4, size: 4, speed: 0.4),
    _Particle(x: 0.8, y: 0.7, size: 3, speed: 0.35),
    _Particle(x: 0.9, y: 0.15, size: 4, speed: 0.5),
    _Particle(x: 0.15, y: 0.5, size: 5, speed: 0.28),
    _Particle(x: 0.45, y: 0.85, size: 3, speed: 0.42),
    _Particle(x: 0.75, y: 0.25, size: 4, speed: 0.38),
  ];

  _BgPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = _kGold.withAlpha((0.03 * 255).toInt());

    for (final p in particles) {
      final x = (p.x + t * p.speed * 0.1) * size.width;
      final y = (p.y + (math.sin(t * 2 + p.x * 10) * 0.02)) * size.height;
      canvas.drawCircle(Offset(x, y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(_BgPainter oldDelegate) => t != oldDelegate.t;
}

class _Particle {
  final double x;
  final double y;
  final double size;
  final double speed;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
  });
}

class _HeroStatPill extends StatelessWidget {
  final IconData icon;
  final String value;

  const _HeroStatPill({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _kSurface.withAlpha((0.7 * 255).toInt()),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _kGold),
          const SizedBox(width: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_kGold.withAlpha((0.1 * 255).toInt()), _kSurfaceCard],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _kGold.withAlpha((0.3 * 255).toInt()),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: _kGold, size: 24),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: _kHint,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoldInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Widget? valueWidget;

  const _GoldInfoRow({
    required this.icon,
    required this.label,
    this.value,
    this.valueWidget,
  }) : assert(
         value != null || valueWidget != null,
         'Se debe proporcionar value o valueWidget',
       );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _kGold.withAlpha((0.1 * 255).toInt()),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: _kGold),
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
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                valueWidget ??
                    Text(
                      value ?? '',
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
      ),
    );
  }
}

class _GoldDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(color: _kBorder.withAlpha((0.5 * 255).toInt()), height: 1);
  }
}

class _GoldIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GoldIconButton({required this.icon, required this.onTap});

  @override
  State<_GoldIconButton> createState() => _GoldIconButtonState();
}

class _GoldIconButtonState extends State<_GoldIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController ctrl;
  double scale = 1.0;

  @override
  void initState() {
    super.initState();
    ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => scale = 0.92),
      onTapUp: (_) {
        setState(() => scale = 1.0);
        widget.onTap();
      },
      onTapCancel: () => setState(() => scale = 1.0),
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _kSurface.withAlpha((0.6 * 255).toInt()),
            shape: BoxShape.circle,
            border: Border.all(color: _kBorder),
          ),
          child: Icon(widget.icon, size: 20, color: Colors.white),
        ),
      ),
    );
  }
}

class _AccionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _AccionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  State<_AccionButton> createState() => _AccionButtonState();
}

class _AccionButtonState extends State<_AccionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController ctrl;
  double scale = 1.0;

  @override
  void initState() {
    super.initState();
    ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? _kGold;
    return GestureDetector(
      onTapDown: (_) => setState(() => scale = 0.95),
      onTapUp: (_) {
        setState(() => scale = 1.0);
        widget.onTap();
      },
      onTapCancel: () => setState(() => scale = 1.0),
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withAlpha((0.15 * 255).toInt()),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withAlpha((0.4 * 255).toInt())),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
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

class _GoldOutlineButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _GoldOutlineButton({required this.label, required this.onTap});

  @override
  State<_GoldOutlineButton> createState() => _GoldOutlineButtonState();
}

class _GoldOutlineButtonState extends State<_GoldOutlineButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController ctrl;
  double scale = 1.0;

  @override
  void initState() {
    super.initState();
    ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => scale = 0.95),
      onTapUp: (_) {
        setState(() => scale = 1.0);
        widget.onTap();
      },
      onTapCancel: () => setState(() => scale = 1.0),
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _kGold.withAlpha((0.5 * 255).toInt())),
          ),
          child: Text(
            widget.label,
            style: const TextStyle(
              color: _kGold,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
