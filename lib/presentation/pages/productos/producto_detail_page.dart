// lib/presentation/pages/productos/producto_detail_page.dart
//
// 🏛️  PLAZA UNIVERSE — Detalle de Producto
// ────────────────────────────────────────────────────────────

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:paseo_del_comercio/core/app/app_config.dart';
import 'package:paseo_del_comercio/core/utils/firebase_auth_service.dart';
import 'package:paseo_del_comercio/core/utils/share_service.dart';
import 'package:paseo_del_comercio/data/datasources/remote/supabase_client.dart';
import 'package:paseo_del_comercio/di/service_locator.dart';
import 'package:paseo_del_comercio/presentation/blocs/producto/producto_bloc.dart';
import 'package:paseo_del_comercio/presentation/blocs/favorito/favorito_bloc.dart';
import 'package:paseo_del_comercio/presentation/blocs/favorito/favorito_event.dart';
import 'package:paseo_del_comercio/presentation/blocs/favorito/favorito_state.dart';
import 'package:paseo_del_comercio/presentation/widgets/favorite_button.dart';
import '../../widgets/profile_floating_button.dart';
import '../../widgets/tienda/tienda_card.dart';

/// Extrae el código de país de un número de teléfono
String extractCountryCode(String phoneNumber) {
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
  return '';
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
        countryCode.isNotEmpty ? getFlagForCountryCode(countryCode) : null;

    if (flag != null && countryCode.isNotEmpty) {
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
//  CONSTANTES & COLORES
// ══════════════════════════════════════════════════════════════

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
  // Controladores
  late TabController _tabController;
  late ScrollController _scrollController;
  bool _hasLoaded = false;

  // Animaciones
  late AnimationController _bgCtrl;
  late AnimationController _heroCtrl;
  late AnimationController _contentCtrl;
  late Animation<double> _heroFade;
  late Animation<double> _heroScale;
  late Animation<double> _contentSlide;
  late Animation<double> _contentFade;

  // Datos
  double _scrollOffset = 0;
  static const double _heroHeight = 320.0;

  Map<String, dynamic>? _productoData;
  Map<String, dynamic>? _tiendaData;
  final AppConfig _appConfig = AppConfig();

  // Valoraciones
  List<Map<String, dynamic>> _valoraciones = [];
  bool _valoracionesLoaded = false;

  @override
  void initState() {
    super.initState();

    // Registrar observer para detectar cuando la app vuelve al primer plano
    WidgetsBinding.instance.addObserver(this);

    _tabController = TabController(length: 3, vsync: this);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Fondo continuo
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Hero entrada
    _heroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Contenido entrada
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

    // Iniciar animaciones
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _heroCtrl.forward();
        _contentCtrl.forward();
      }
    });

    // Si tenemos producto directo, cargar inmediatamente
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

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  double get _collapseProgress {
    if (_scrollController.hasClients) {
      return (_scrollOffset / (_heroHeight - kToolbarHeight)).clamp(0.0, 1.0);
    }
    return 0;
  }

  // ══════════════════════════════════════════════════════════════
  //  CARGA DE DATOS
  // ══════════════════════════════════════════════════════════════

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
    // Extraer datos de la tienda del producto
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
      // Si ya tenemos datos de la tienda, no volver a cargar
      if (_tiendaData != null && _tiendaData!['id'] == producto['tienda_id']) {
        return;
      }

      // Cargar datos completos de la tienda desde Supabase
      // Incluir imagen_tienda para obtener las imágenes
      try {
        final supabase = getIt<SupabaseClientService>();
        final tiendaResponse = await supabase.tiendas
            .select('''
                  *,
                  imagen_tienda!left(*)
                ''')
            .eq('id', producto['tienda_id'])
            .limit(1);

        debugPrint('DEBUG: tiendaResponse completo: $tiendaResponse');

        if (tiendaResponse.isNotEmpty) {
          _tiendaData = _transformTiendaUrlsToR2(
            Map<String, dynamic>.from(tiendaResponse.first),
          );
          debugPrint('DEBUG: _tiendaData después de transformar: $_tiendaData');
          if (mounted) {
            setState(() {});
          }
        } else {
          _tiendaData = {'id': producto['tienda_id']};
        }
      } catch (e) {
        debugPrint('Error cargando tienda: $e');
        _tiendaData = {'id': producto['tienda_id']};
      }
    }

    // Registrar vista del producto
    _registrarVistaProducto();

    // registrar visita a la tienda
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
        debugPrint(
          'Vista registrada para producto ${widget.productoId}: $totalVisualizaciones',
        );
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
        debugPrint('Visita registrada para tienda $tiendaId: $totalVisitas');
      }
    } catch (e) {
      debugPrint('Error registrando visita a la tienda: $e');
    }
  }

  Future<void> _loadValoraciones() async {
    debugPrint(
      'DEBUG: Iniciando carga de valoraciones para producto ${widget.productoId}',
    );
    if (_valoracionesLoaded) {
      debugPrint('DEBUG: Valoraciones ya cargadas, omitiendo');
      return;
    }

    try {
      final supabase = getIt<SupabaseClientService>();
      debugPrint('DEBUG: Consultando valoraciones...');

      final response = await supabase.valoraciones
          .select()
          .eq('producto_id', widget.productoId)
          .eq('estado_valoracion', 'publicado')
          .order('fecha_creacion', ascending: false);

      debugPrint('DEBUG: Valoraciones response: $response');

      if (response.isNotEmpty) {
        debugPrint('DEBUG: Hay ${response.length} valoraciones');

        // Cargar datos de usuarios para cada valoración
        final valoracionesConUsuario = <Map<String, dynamic>>[];

        for (final valoracion in response) {
          final usuarioId = valoracion['usuario_id'];
          if (usuarioId != null) {
            try {
              debugPrint('DEBUG: Consultando usuario con ID: $usuarioId');
              final usuarioIdInt =
                  usuarioId is int
                      ? usuarioId
                      : int.tryParse(usuarioId.toString());
              debugPrint('DEBUG: usuarioIdInt: $usuarioIdInt');

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
              } catch (e) {
                debugPrint('DEBUG: Consulta con campos específicos falló: $e');
                try {
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
                } catch (e2) {
                  debugPrint('DEBUG: Consulta sin campos también falló: $e2');
                }
              }

              debugPrint(
                'DEBUG: usuarioId=$usuarioId, usuarioResponse=$usuarioResponse',
              );

              final valoracionConUsuario = Map<String, dynamic>.from(
                valoracion,
              );
              valoracionConUsuario['usuario'] = usuarioResponse;
              valoracionesConUsuario.add(valoracionConUsuario);
            } catch (e) {
              debugPrint('DEBUG: Error cargando usuario: $e');
              valoracionesConUsuario.add(valoracion);
            }
          } else {
            valoracionesConUsuario.add(valoracion);
          }
        }

        // Actualizar estadísticas del producto
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
      debugPrint('Error loading valoraciones: $e');
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

      // Calcular el promedio real desde las valoraciones pasadas
      double promedioCalculado = 0;
      if (totalValoracionesReales > 0) {
        final suma = valoraciones.fold<int>(
          0,
          (sum, v) => sum + ((v['calificacion'] as num?)?.toInt() ?? 0),
        );
        promedioCalculado = suma / totalValoracionesReales;
      }

      // Actualizar si no coinciden
      if (totalEnDB != totalValoracionesReales) {
        await supabase.productos
            .update({
              'total_valoracion': totalValoracionesReales,
              'calificacion_promedio': promedioCalculado,
            })
            .eq('id', widget.productoId);

        debugPrint(
          'Estadísticas actualizadas: total=$totalValoracionesReales, promedio=$promedioCalculado',
        );
      }
    } catch (e) {
      debugPrint('Error actualizando estadísticas: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════
  //  TRANSFORMADORES DE URLs
  // ══════════════════════════════════════════════════════════════

  String? _transformUrlToR2(String? url) {
    if (url == null || url.isEmpty) return url;
    if (!url.contains('contabostorage.com')) return url;

    try {
      if (_appConfig.cloudflareR2PublicUrl.isEmpty) {
        return url;
      }

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

    // Transformar logo
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

    // Transformar imagen_tienda
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

  // ══════════════════════════════════════════════════════════════
  //  ACCIONES
  // ══════════════════════════════════════════════════════════════

  void _onTiendaTap() {
    if (_tiendaData != null) {
      final tiendaId = _tiendaData!['id'];
      if (tiendaId != null) {
        // Navegar directamente a la tienda
        context.push('/tiendas/$tiendaId');
      }
    }
  }

  Future<void> _onShareProducto() async {
    if (_productoData == null) return;

    try {
      final shareService = getIt<ShareService>();
      final nombre =
          _productoData!['nombre_producto'] ??
          _productoData!['nombre'] ??
          'Producto';
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

    // Incrementar contador de clicks en WhatsApp
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

  /// Incrementar contador de clicks en WhatsApp del producto
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
        debugPrint(
          'Click WhatsApp registrado para producto ${widget.productoId}: $totalClicks',
        );
      }
    } catch (e) {
      debugPrint('Error registrando click WhatsApp: $e');
    }
  }

  String _getProductoNombre() {
    return _productoData?['nombre'] ??
        _productoData?['nombre_producto'] ??
        'Producto sin nombre';
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

  // ══════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════

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
          return Scaffold(
            backgroundColor: _kBg,
            body: Stack(
              children: [
                // Fondo animado
                AnimatedBuilder(
                  animation: _bgCtrl,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _BgPainter(t: _bgCtrl.value),
                      size: Size.infinite,
                    );
                  },
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
      backgroundColor: _kBg,
      body: Stack(
        children: [
          // Fondo animado
          AnimatedBuilder(
            animation: _bgCtrl,
            builder:
                (context, child) => CustomPaint(
                  size: size,
                  painter: _BgPainter(t: _bgCtrl.value),
                ),
          ),

          // Contenido scrollable
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
                      _buildInfoTab(producto),
                      _buildTiendaTab(),
                      _buildValoracionesTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // AppBar flotante
          SafeArea(child: _buildFloatingAppBar(producto)),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  WIDGETS
  // ══════════════════════════════════════════════════════════════

  // ── AppBar glassmorphism ─────────────────────────────────────
  Widget _buildFloatingAppBar(Map<String, dynamic> producto) {
    final opacity = _collapseProgress;
    final nombre = _getProductoNombre();
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
              _GoldIconButton(
                icon: Icons.share_rounded,
                onTap: _onShareProducto,
              ),
              const SizedBox(width: 4),
              BlocBuilder<FavoritoBloc, FavoritoState>(
                builder: (context, state) {
                  final isFav =
                      state is FavoritosLoaded
                          ? state.isProductoFavorito(producto['id'] as int)
                          : false;
                  return FavoriteButton(
                    isFavorite: isFav,
                    onTap: () {
                      context.read<FavoritoBloc>().add(
                        ToggleProductoFavorito(
                          productoId: producto['id'] as int,
                        ),
                      );
                    },
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

  // ── Hero expandible ───────────────────────────────────────────
  Widget _buildHero(Map<String, dynamic> producto) {
    final imagenUrl = _getProductImageUrl();
    final tieneImagen = imagenUrl != null && imagenUrl.isNotEmpty;

    return AnimatedBuilder(
      animation: _heroCtrl,
      builder:
          (context, child) => Opacity(
            opacity: _heroFade.value,
            child: Transform.scale(
              scale: _heroScale.value,
              alignment: Alignment.topCenter,
              child: SizedBox(
                height: _heroHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Imagen de fondo
                    if (tieneImagen)
                      CachedNetworkImage(
                        imageUrl: imagenUrl,
                        fit: BoxFit.cover,
                        errorWidget:
                            (context, url, error) =>
                                _buildHeroFallback(producto),
                      )
                    else
                      _buildHeroFallback(producto),

                    // Overlay degradado
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

                    // Overlay dorado
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

                    // Información en la parte inferior
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
                            // Badge
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
                                  Text('📦', style: TextStyle(fontSize: 13)),
                                  SizedBox(width: 6),
                                  Text(
                                    'Producto',
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

                            // Nombre
                            ShaderMask(
                              shaderCallback:
                                  (b) => const LinearGradient(
                                    colors: [Colors.white, _kGoldLight],
                                    stops: [0.6, 1.0],
                                  ).createShader(b),
                              child: Text(
                                _getProductoNombre(),
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

                            // Precio
                            Text(
                              '\$${(_productoData?['precio_base'] ?? 0).toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: _kGold,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
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

  Widget _buildHeroFallback(Map<String, dynamic> producto) {
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
      child: Center(
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
              child: const Icon(
                Icons.inventory_2_rounded,
                size: 40,
                color: _kGold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _getProductoNombre(),
              style: TextStyle(
                color: _kGold.withAlpha((0.8 * 255).toInt()),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── TabBar ───────────────────────────────────────────────────
  Widget _buildTabBar() {
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: _kSurface.withValues(alpha: 0.88),
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

  // ── Tab: Info ────────────────────────────────────────────────
  Widget _buildInfoTab(Map<String, dynamic> producto) {
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
            // Calificación
            _buildSection(
              title: 'Calificación',
              icon: Icons.star_rounded,
              child: Row(
                children: [
                  ...List.generate(5, (index) {
                    final promedio =
                        (_productoData?['calificacion_promedio'] as num?)
                            ?.toDouble() ??
                        0.0;
                    return Icon(
                      index < promedio.round()
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: _kGold,
                      size: 20,
                    );
                  }),
                  const SizedBox(width: 8),
                  Text(
                    '${(_productoData?['calificacion_promedio'] as num?)?.toStringAsFixed(1) ?? '0.0'} (${_productoData?['total_valoracion'] ?? 0} reseñas)',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Stats - estilo tienda_detail_page
            Row(
              children: [
                Expanded(
                  child: _GoldStatCard(
                    icon: Icons.visibility_rounded,
                    value: _productoData?['total_visualizaciones'] ?? 0,
                    label: 'Vistas',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _GoldStatCard(
                    icon: Icons.shopping_bag_rounded,
                    value: _productoData?['cantidad'] ?? 0,
                    label: 'Vendidos',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Descripción
            if (producto['descripcion'] != null &&
                producto['descripcion'].toString().isNotEmpty) ...[
              _buildSection(
                title: 'Descripción',
                icon: Icons.description_outlined,
                child: Text(
                  producto['descripcion'].toString(),
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

            // Estado
            if (producto['estado_producto'] != null)
              _buildSection(
                title: 'Estado',
                icon: Icons.check_circle_outline,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _kGold.withAlpha((0.15 * 255).toInt()),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _kGold.withAlpha((0.40 * 255).toInt()),
                    ),
                  ),
                  child: Text(
                    producto['estado_producto']?.toString().toUpperCase() ?? '',
                    style: const TextStyle(
                      color: _kGold,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Botón WhatsApp
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _enviarWhatsapp,
                icon: const Icon(Icons.chat_rounded),
                label: const Text('Contactar por WhatsApp'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab: Tienda ───────────────────────────────────────────────
  Widget _buildTiendaTab() {
    if (_tiendaData == null) {
      return _buildEmptyState(
        icon: Icons.store_outlined,
        title: 'Tienda no disponible',
        subtitle: 'No se encontró información de la tienda',
      );
    }

    final tienda = _tiendaData!;

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
            // Card de tienda usando TiendaCard
            TiendaCard(
              tienda: tienda,
              onTap: _onTiendaTap,
              showDetails: true,
              showFavoriteButton: true,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ── Tab: Valoraciones ─────────────────────────────────────────
  Widget _buildValoracionesTab() {
    // Cargar valoraciones si no se han cargado
    if (!_valoracionesLoaded) {
      _loadValoraciones();
      return const Center(child: CircularProgressIndicator(color: _kGold));
    }

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
            // Header con promedio
            _buildValoracionesHeader(),
            const SizedBox(height: 16),

            // Botón para agregar reseña
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showAgregarValoracionDialog(),
                icon: const Icon(Icons.rate_review),
                label: const Text('Escribir una reseña'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kGold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Lista de valoraciones o estado vacío
            if (_valoraciones.isEmpty)
              _buildEmptyState(
                icon: Icons.rate_review_outlined,
                title: 'Sin reseñas',
                subtitle:
                    'Sé el primero en dar tu opinión\nsobre este producto',
              )
            else
              ..._valoraciones.map((v) => _buildValoracionCard(v)),
          ],
        ),
      ),
    );
  }

  Widget _buildValoracionesHeader() {
    final promedio = _calificacionPromedio;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kSurfaceCard.withAlpha((0.6 * 255).toInt()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder.withAlpha((0.5 * 255).toInt())),
      ),
      child: Row(
        children: [
          // Promedio grande
          Column(
            children: [
              Text(
                promedio.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: _kGold,
                ),
              ),
              ...List.generate(5, (index) {
                return Icon(
                  index < promedio.round()
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: _kGold,
                  size: 16,
                );
              }),
              const SizedBox(height: 4),
              Text(
                '${_valoraciones.length} reseñas',
                style: const TextStyle(color: _kHint, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(width: 24),
          // Distribución
          Expanded(
            child: Column(
              children: List.generate(5, (estrella) {
                final count =
                    _valoraciones
                        .where(
                          (v) =>
                              (v['calificacion'] as num?)?.round() == estrella,
                        )
                        .length;
                final total = _valoraciones.isEmpty ? 1 : _valoraciones.length;
                final percentage = count / total;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        '$estrella',
                        style: const TextStyle(color: _kHint, fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.star_rounded, color: _kGold, size: 12),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage,
                            backgroundColor: _kBorder,
                            valueColor: const AlwaysStoppedAnimation(_kGold),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$count',
                        style: const TextStyle(color: _kHint, fontSize: 12),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  double get _calificacionPromedio {
    if (_valoraciones.isEmpty) return 0;
    final suma = _valoraciones.fold<double>(
      0,
      (sum, v) => sum + ((v['calificacion'] as num?)?.toDouble() ?? 0),
    );
    return suma / _valoraciones.length;
  }

  Widget _buildValoracionCard(Map<String, dynamic> valoracion) {
    final calificacion = (valoracion['calificacion'] as num?)?.toInt() ?? 0;
    final comentario = valoracion['comentario'] as String?;
    final fecha = valoracion['fecha_creacion'] as String?;

    // Obtener datos del usuario
    final usuario = valoracion['usuario'] as Map<String, dynamic>?;
    final nombreUsuario = usuario?['nombre_completo'] as String? ?? 'Anónimo';
    final avatarUrlRaw = usuario?['avatar_url'] as String?;
    // Transformar URL del avatar a R2 si es necesario
    final avatarUrl = _transformUrlToR2(avatarUrlRaw);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kSurfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: usuario, estrellas y fecha
          Row(
            children: [
              // Avatar
              if (avatarUrl != null && avatarUrl.isNotEmpty)
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(avatarUrl),
                  backgroundColor: _kGold.withAlpha((0.2 * 255).toInt()),
                )
              else
                CircleAvatar(
                  radius: 16,
                  backgroundColor: _kGold.withAlpha((0.2 * 255).toInt()),
                  child: Text(
                    nombreUsuario.isNotEmpty
                        ? nombreUsuario[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: _kGold,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              // Nombre
              Expanded(
                child: Text(
                  nombreUsuario,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              // Estrellas
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < calificacion
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: _kGold,
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Fecha
          if (fecha != null)
            Text(
              _formatFecha(fecha),
              style: const TextStyle(color: _kHint, fontSize: 12),
            ),
          const SizedBox(height: 8),

          // Comentario
          if (comentario != null && comentario.isNotEmpty)
            Text(
              comentario,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
        ],
      ),
    );
  }

  String _formatFecha(String fechaStr) {
    try {
      final fecha = DateTime.parse(fechaStr);
      final now = DateTime.now();
      final diferencia = now.difference(fecha);

      if (diferencia.inDays == 0) {
        return 'Hoy';
      } else if (diferencia.inDays == 1) {
        return 'Ayer';
      } else if (diferencia.inDays < 7) {
        return 'Hace ${diferencia.inDays} días';
      } else if (diferencia.inDays < 30) {
        return 'Hace ${(diferencia.inDays / 7).floor()} semanas';
      } else if (diferencia.inDays < 365) {
        return 'Hace ${(diferencia.inDays / 30).floor()} meses';
      } else {
        return DateFormat('dd MMM yyyy').format(fecha);
      }
    } catch (e) {
      return fechaStr;
    }
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: _kHint),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(color: _kHint),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  WIDGETS AUXILIARES
  // ══════════════════════════════════════════════════════════════

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

  // ── Dialog para agregar valoración ─────────────────────────────
  void _showAgregarValoracionDialog() {
    double calificacion = 5;
    final comentarioController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: _kSurfaceCard,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: _kBorder,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Título
                    const Text(
                      'Escribe tu reseña',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Calificación con estrellas
                    const Text(
                      'Tu calificación',
                      style: TextStyle(color: _kHint, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              calificacion = index + 1.0;
                            });
                          },
                          child: Icon(
                            index < calificacion
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: _kGold,
                            size: 40,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),

                    // Comentario
                    const Text(
                      'Tu opinión (opcional)',
                      style: TextStyle(color: _kHint, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: comentarioController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: '¿Qué te pareció este producto?',
                        hintStyle: const TextStyle(color: _kHint),
                        filled: true,
                        fillColor: _kSurface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: _kBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: _kBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: _kGold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Botón enviar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await _crearValoracion(
                            calificacion,
                            comentarioController.text,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kGold,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Enviar reseña',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _crearValoracion(double calificacion, String comentario) async {
    try {
      final supabase = getIt<SupabaseClientService>();

      // Obtener usuario actual de Firebase
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

      // Buscar usuario en Supabase por firebase_user_id
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

      // Crear la valoración
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

        // Recargar valoraciones
        setState(() {
          _valoracionesLoaded = false;
        });
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
}

// ══════════════════════════════════════════════════════════════
//  WIDGETS AUXILIARES (igual que en tienda_detail_page)
// ══════════════════════════════════════════════════════════════

class _BgPainter extends CustomPainter {
  final double t;
  late final List<_Particle> _particles;

  _BgPainter({required this.t}) {
    _particles = List.generate(15, (_) => _Particle());
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = _kGold.withAlpha((0.03 * 255).toInt());

    for (final p in _particles) {
      final x = size.width * (0.1 + 0.8 * ((p.x + t * p.speed) % 1));
      final y = size.height * (0.1 + 0.8 * ((p.y + t * p.speed * 0.5) % 1));

      canvas.drawCircle(
        Offset(x, y),
        p.size * (1 + 0.3 * math.sin(t * math.pi * 2)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_BgPainter oldDelegate) => t != oldDelegate.t;
}

class _Particle {
  final double x = math.Random().nextDouble();
  final double y = math.Random().nextDouble();
  final double size = 20 + math.Random().nextDouble() * 30;
  final double speed = 0.2 + math.Random().nextDouble() * 0.3;
}

class _GoldStatCard extends StatelessWidget {
  final IconData icon;
  final dynamic value;
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
        color: _kSurfaceCard.withAlpha((0.6 * 255).toInt()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder.withAlpha((0.5 * 255).toInt())),
      ),
      child: Column(
        children: [
          Icon(icon, color: _kGold, size: 24),
          const SizedBox(height: 8),
          Text(
            value?.toString() ?? '0',
            style: const TextStyle(
              color: _kGold,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: _kHint, fontSize: 12)),
        ],
      ),
    );
  }
}

class _GoldIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GoldIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _kSurface.withAlpha((0.5 * 255).toInt()),
            border: Border.all(color: _kBorder),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
