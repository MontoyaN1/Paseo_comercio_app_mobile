// lib/presentation/widgets/tienda/tienda_card.dart
//
// 🏛️  PLAZA UNIVERSE — Card de Tienda
// ────────────────────────────────────────────────────────────
//  DISEÑO (idéntico al sistema de diseño Plaza Universe):
//  • Fondo: glassmorphism sobre _kSurfaceCard
//  • Imagen: ocupa toda la card, info superpuesta con overlay
//  • Borde: _kBorder con glow dorado en press
//  • Badge de estado: píldoras glassmorphism coloreadas
//  • Nombre/descripción: sobre degradado oscuro inferior
//  • Rating y visitas: íconos dorados
//  • Micro-animación de escala al presionar
// ────────────────────────────────────────────────────────────

import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/app/app_config.dart';
import '../../../di/service_locator.dart';
import '../../blocs/favorito/favorito_bloc.dart';
import '../../blocs/favorito/favorito_event.dart';
import '../../blocs/favorito/favorito_state.dart';

// ── Paleta (idéntica al sistema de diseño) ────────────────────
const _kGold = Color(0xFFD4AF37);
const _kGoldLight = Color(0xFFFFE082);
const _kBg = Color(0xFF07070F);
const _kSurface = Color(0xFF0F0F1E);
const _kSurfaceCard = Color(0xFF12121F);
const _kBorder = Color(0xFF1E1E3A);
const _kHint = Color(0xFF6B6B8A);

// ══════════════════════════════════════════════════════════════
//  WIDGET PRINCIPAL
// ══════════════════════════════════════════════════════════════
class TiendaCard extends StatefulWidget {
  final Map<String, dynamic> tienda;
  final VoidCallback onTap;
  final bool showDetails;
  final bool showFavoriteButton;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  const TiendaCard({
    super.key,
    required this.tienda,
    required this.onTap,
    this.showDetails = true,
    this.showFavoriteButton = true,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  @override
  State<TiendaCard> createState() => _TiendaCardState();
}

class _TiendaCardState extends State<TiendaCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.965,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _glow = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ── Helpers de datos ──────────────────────────────────────
  String? _getImage() {
    final imagenes = widget.tienda['imagen_tienda'];
    String? rawUrl;

    if (imagenes != null) {
      if (imagenes is List && imagenes.isNotEmpty) {
        for (final imagen in imagenes) {
          if (imagen is Map<String, dynamic>) {
            // Buscar url_large (nuevo formato) o url_imagen (formato anterior)
            final urlLarge = imagen['url_large'] as String?;
            final urlImagen = imagen['url_imagen'] as String?;
            final urlThumb = imagen['url_thumb'] as String?;
            final url = urlLarge ?? urlImagen ?? urlThumb;
            if (url != null && url.isNotEmpty) {
              rawUrl = url;
              break;
            }
          }
        }
        if (rawUrl == null || rawUrl.isEmpty) {
          final p = imagenes[0];
          if (p is Map<String, dynamic>) {
            rawUrl =
                p['url_large'] as String? ??
                p['url_imagen'] as String? ??
                p['url_thumb'] as String?;
          }
        }
      } else if (imagenes is Map<String, dynamic>) {
        rawUrl =
            imagenes['url_large'] as String? ??
            imagenes['url_imagen'] as String? ??
            imagenes['url_thumb'] as String?;
      }
    }

    if (rawUrl == null || rawUrl.isEmpty) {
      final alt =
          widget.tienda['logoUrl'] ??
          widget.tienda['logo_url'] ??
          widget.tienda['url_logo'] ??
          widget.tienda['logo'] ??
          widget.tienda['imagen'];
      if (alt is String && alt.isNotEmpty) rawUrl = alt;
    }

    if ((rawUrl == null || rawUrl.isEmpty) &&
        widget.tienda['imagenes'] is List<dynamic>) {
      final old = widget.tienda['imagenes'] as List<dynamic>;
      if (old.isNotEmpty) {
        final p = old.firstWhere(
          (i) => i is Map<String, dynamic> && i['es_principal'] == true,
          orElse: () => old.first,
        );
        if (p is Map<String, dynamic>) rawUrl = p['url'] as String?;
      }
    }

    if (rawUrl == null || rawUrl.isEmpty) return null;
    if (rawUrl.contains('user_')) return null;
    if (!rawUrl.startsWith('http://') && !rawUrl.startsWith('https://')) {
      return null;
    }
    return _transformContaboUrlToR2(rawUrl);
  }

  String _getNombre() {
    final n =
        widget.tienda['nombre'] ??
        widget.tienda['nombre_tienda'] ??
        widget.tienda['titulo'] ??
        'Tienda';
    final s = n.toString();
    if (s == 'Tienda' || s == 'Tienda sin nombre') {
      final id = widget.tienda['id'] ?? widget.tienda['tienda_id'];
      return id != null ? 'Tienda $id' : 'Tienda';
    }
    return s;
  }

  String _getDescripcion() =>
      widget.tienda['descripcion'] as String? ?? 'Sin descripción disponible';

  String? _getCategoria() {
    final obj = widget.tienda['categoria'];
    if (obj is Map<String, dynamic>) {
      final n = obj['nombre_categoria'] as String?;
      if (n != null && n.isNotEmpty) return n;
    }
    final c =
        widget.tienda['categoria_tienda'] ??
        widget.tienda['tipo'] ??
        widget.tienda['rubro'];
    if (c is String && c.isNotEmpty) return c;
    if (c is Map<String, dynamic>) {
      final n = c['nombre'] ?? c['nombre_categoria'];
      if (n is String && n.isNotEmpty) return n;
    }
    return null;
  }

  double _getRating() =>
      (widget.tienda['promedio_valoracion'] as num?)?.toDouble() ?? 0.0;

  int _getRatingCount() => (widget.tienda['total_valoraciones'] as int?) ?? 0;

  int _getVisitas() => (widget.tienda['total_visitas'] as int?) ?? 0;

  String? _getEstado() => widget.tienda['estado_tienda'] as String?;

  bool _isActiva() {
    final s = _getEstado();
    return s == 'activa' || s == 'abierta';
  }

  String _transformContaboUrlToR2(String url) {
    try {
      if (!url.contains('contabostorage.com')) return url;
      final appConfig = getIt<AppConfig>();
      if (appConfig.cloudflareR2PublicUrl.isEmpty) return url;
      final uri = Uri.parse(url);
      final segs = uri.pathSegments;
      final idx = segs.indexWhere((s) => s == 'paseocomercio');
      if (idx == -1 || idx >= segs.length - 1) return url;
      final rel = segs.sublist(idx + 1).join('/');
      String base = appConfig.cloudflareR2PublicUrl.trim();
      if (base.endsWith('/')) base = base.substring(0, base.length - 1);
      return '$base/$rel';
    } catch (_) {
      return url;
    }
  }

  IconData _getCategoryIcon() {
    final c = (_getCategoria() ?? '').toLowerCase();
    if (c.contains('ropa') || c.contains('moda'))
      return Icons.checkroom_rounded;
    if (c.contains('comida') || c.contains('restaur'))
      return Icons.restaurant_rounded;
    if (c.contains('tecno') || c.contains('electr'))
      return Icons.devices_rounded;
    if (c.contains('belleza') || c.contains('salud')) return Icons.spa_rounded;
    if (c.contains('hogar') || c.contains('decor')) return Icons.chair_rounded;
    if (c.contains('deporte') || c.contains('fit')) return Icons.sports_rounded;
    if (c.contains('libro') || c.contains('papel'))
      return Icons.menu_book_rounded;
    if (c.contains('jugu') || c.contains('niño')) return Icons.toys_rounded;
    if (c.contains('joya') || c.contains('acceso'))
      return Icons.diamond_rounded;
    if (c.contains('zapato') || c.contains('calzado'))
      return Icons.shopping_bag_rounded;
    return Icons.storefront_rounded;
  }

  // ── Estado badge data ─────────────────────────────────────
  _BadgeData _getEstadoBadge() {
    final s = _getEstado();
    if (_isActiva()) {
      return _BadgeData(
        icon: Icons.check_circle_rounded,
        label: 'Abierta',
        color: const Color(0xFF22C55E),
      );
    }
    if (s == 'cerrada') {
      return _BadgeData(
        icon: Icons.block_rounded,
        label: 'Cerrada',
        color: const Color(0xFFEF4444),
      );
    }
    if (s == 'pendiente') {
      return _BadgeData(
        icon: Icons.pending_rounded,
        label: 'Pendiente',
        color: const Color(0xFFF59E0B),
      );
    }
    return _BadgeData(
      icon: Icons.help_outline_rounded,
      label: 'Sin estado',
      color: _kHint,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? _kSurfaceCard : Colors.white;
    final borderColor = isDark ? _kBorder : Colors.grey.shade300;
    final textColor = isDark ? Colors.white : Colors.black;
    final hintColor = isDark ? _kHint : Colors.grey.shade600;
    final shadowColor =
        isDark ? Colors.black.withOpacity(0.50) : Colors.grey.withOpacity(0.30);

    final imageUrl = _getImage();
    final nombre = _getNombre();
    final badge = _getEstadoBadge();
    final categoria = _getCategoria();

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder:
            (_, child) => Transform.scale(
              scale: _scale.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: _kGold.withOpacity(0.04 + _glow.value * 0.12),
                      blurRadius: 18 + _glow.value * 14,
                      spreadRadius: _glow.value * 2,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 14,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: child,
              ),
            ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              decoration: BoxDecoration(
                color: surfaceColor.withOpacity(0.92),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderColor, width: 1),
              ),
              child:
                  widget.showDetails
                      ? _buildFullCard(
                        imageUrl,
                        nombre,
                        badge,
                        categoria,
                        isDark,
                        textColor,
                        hintColor,
                        borderColor,
                      )
                      : _buildCompactCard(imageUrl, nombre, badge, textColor),
            ),
          ),
        ),
      ),
    );
  }

  // ── Tarjeta completa ──────────────────────────────────────
  Widget _buildFullCard(
    String? imageUrl,
    String nombre,
    _BadgeData badge,
    String? categoria,
    bool isDark,
    Color textColor,
    Color hintColor,
    Color borderColor,
  ) {
    final rating = _getRating();
    final ratingCnt = _getRatingCount();
    final visitas = _getVisitas();
    final descripcion = _getDescripcion();
    final bgOverlay = isDark ? _kBg : Colors.grey.shade700;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Zona de imagen ─────────────────────────────────
        SizedBox(
          height: 175,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Imagen / fallback
              _buildImageSection(imageUrl, nombre),

              // Overlay degradado inferior
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        bgOverlay.withOpacity(0.35),
                        bgOverlay.withOpacity(0.80),
                      ],
                      stops: const [0.4, 0.72, 1.0],
                    ),
                  ),
                ),
              ),

              // Badge estado (top-left)
              Positioned(
                top: 10,
                left: 10,
                child: _buildBadge(badge, small: true),
              ),

              // Favorito (top-right)
              if (widget.showFavoriteButton)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Builder(
                    builder: (context) {
                      final tiendaId =
                          int.tryParse(widget.tienda['id']?.toString() ?? '') ??
                          0;
                      return BlocBuilder<FavoritoBloc, FavoritoState>(
                        builder: (context, state) {
                          bool isFav = widget.isFavorite;
                          if (state is FavoritosLoaded && tiendaId > 0) {
                            isFav = state.isTiendaFavorita(tiendaId);
                          }
                          return _FavButton(
                            isFavorite: isFav,
                            onTap: () {
                              if (tiendaId > 0) {
                                getIt<FavoritoBloc>().add(
                                  ToggleTiendaFavorito(tiendaId: tiendaId),
                                );
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
                ),

              // Nombre encima del degradado inferior
              Positioned(
                left: 14,
                right: 14,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (categoria != null && categoria.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _kGold.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _kGold.withOpacity(0.38),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            categoria,
                            style: const TextStyle(
                              color: _kGold,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ShaderMask(
                      shaderCallback:
                          (b) => const LinearGradient(
                            colors: [Colors.white, _kGoldLight],
                            stops: [0.6, 1.0],
                          ).createShader(b),
                      child: Text(
                        nombre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                          height: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 8,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Info inferior ──────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Descripción
              Text(
                descripcion,
                style: TextStyle(
                  color: hintColor,
                  fontSize: 12,
                  height: 1.5,
                  letterSpacing: 0.1,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Separador dorado
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      borderColor,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Stats: rating + visitas + flecha
              Row(
                children: [
                  // Rating
                  _buildRatingMini(rating, ratingCnt, hintColor),
                  const SizedBox(width: 14),
                  // Visitas
                  _buildVisitasMini(visitas, hintColor),
                  const Spacer(),
                  // Etiquetas si existen
                  if (widget.tienda['etiquetas'] != null) ..._buildEtiquetas(),
                  // Flecha
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: _kGold,
                    size: 13,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Tarjeta compacta (fila horizontal) ────────────────────
  Widget _buildCompactCard(
    String? imageUrl,
    String nombre,
    _BadgeData badge,
    Color textColor,
  ) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Logo pequeño
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: _kGold.withOpacity(0.07),
              border: Border.all(color: _kGold.withOpacity(0.24), width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child:
                  imageUrl != null
                      ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder:
                            (_, __) => const Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  valueColor: AlwaysStoppedAnimation(_kGold),
                                ),
                              ),
                            ),
                        errorWidget:
                            (_, __, ___) => Icon(
                              _getCategoryIcon(),
                              color: _kGold.withOpacity(0.55),
                              size: 22,
                            ),
                      )
                      : Icon(
                        _getCategoryIcon(),
                        color: _kGold.withOpacity(0.55),
                        size: 22,
                      ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nombre,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                _buildBadge(badge, small: true),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios_rounded, color: _kGold, size: 13),
        ],
      ),
    );
  }

  // ── Imagen / fallback ─────────────────────────────────────
  Widget _buildImageSection(String? imageUrl, String nombre) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (_, __) => _buildFallback(nombre, loading: true),
        errorWidget: (_, __, ___) => _buildFallback(nombre),
      );
    }
    return _buildFallback(nombre);
  }

  Widget _buildFallback(String nombre, {bool loading = false}) {
    return Container(
      color: _kSurface,
      child: Center(
        child:
            loading
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    valueColor: AlwaysStoppedAnimation(_kGold),
                  ),
                )
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _kGold.withOpacity(0.08),
                        border: Border.all(
                          color: _kGold.withOpacity(0.30),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          _getCategoryIcon(),
                          color: _kGold.withOpacity(0.65),
                          size: 26,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      nombre.isNotEmpty ? nombre[0].toUpperCase() : 'T',
                      style: TextStyle(
                        color: _kGold.withOpacity(0.55),
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  // ── Badge de estado ───────────────────────────────────────
  Widget _buildBadge(_BadgeData data, {bool small = false}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: small ? 8 : 10,
            vertical: small ? 3 : 5,
          ),
          decoration: BoxDecoration(
            color: data.color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: data.color.withOpacity(0.45), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(data.icon, color: data.color, size: small ? 9 : 11),
              const SizedBox(width: 4),
              Text(
                data.label,
                style: TextStyle(
                  color: data.color,
                  fontSize: small ? 9 : 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Rating mini ───────────────────────────────────────────
  Widget _buildRatingMini(double rating, int count, Color hintColor) {
    if (rating == 0) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_border_rounded, size: 16, color: _kGold),
          const SizedBox(width: 4),
          const Text(
            'Sin valorar',
            style: TextStyle(
              fontSize: 12,
              color: _kGold,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 16, color: _kGold),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            color: _kGold,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '($count)',
          style: const TextStyle(
            fontSize: 11,
            color: _kGoldLight,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ── Visitas mini ──────────────────────────────────────────
  Widget _buildVisitasMini(int visitas, Color hintColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.visibility_rounded, size: 15, color: _kGold),
        const SizedBox(width: 4),
        Text(
          '$visitas vistas',
          style: const TextStyle(
            fontSize: 12,
            color: _kGold,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ── Etiquetas ─────────────────────────────────────────────
  List<Widget> _buildEtiquetas() {
    final etiquetas = widget.tienda['etiquetas'] as List<dynamic>?;
    if (etiquetas == null || etiquetas.isEmpty) return [];
    return etiquetas.take(2).map((tag) {
      final nombre = tag['nombre'] as String? ?? tag.toString();
      return Padding(
        padding: const EdgeInsets.only(right: 6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: _kGold.withOpacity(0.07),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _kGold.withOpacity(0.22), width: 1),
          ),
          child: Text(
            nombre,
            style: const TextStyle(
              color: _kGold,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
      );
    }).toList();
  }
}

// ══════════════════════════════════════════════════════════════
//  BOTÓN FAVORITO
// ══════════════════════════════════════════════════════════════
class _FavButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback? onTap;
  const _FavButton({required this.isFavorite, this.onTap});

  @override
  State<_FavButton> createState() => _FavButtonState();
}

class _FavButtonState extends State<_FavButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late bool _localIsFavorite;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.78,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _localIsFavorite = widget.isFavorite;
  }

  @override
  void didUpdateWidget(_FavButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) {
      _localIsFavorite = widget.isFavorite;
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
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        setState(() {
          _localIsFavorite = !_localIsFavorite;
        });
        _ctrl.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder:
            (_, __) => Transform.scale(
              scale: _scale.value,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color:
                          _localIsFavorite
                              ? Colors.red.withOpacity(0.8)
                              : Colors.black.withOpacity(0.45),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            _localIsFavorite
                                ? Colors.red.withOpacity(0.8)
                                : _kBorder,
                        width: 1,
                      ),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: Icon(
                        _localIsFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        key: ValueKey(_localIsFavorite),
                        size: 16,
                        color: _localIsFavorite ? Colors.white : _kHint,
                      ),
                    ),
                  ),
                ),
              ),
            ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  DATA CLASS PARA BADGE
// ══════════════════════════════════════════════════════════════
class _BadgeData {
  final IconData icon;
  final String label;
  final Color color;
  const _BadgeData({
    required this.icon,
    required this.label,
    required this.color,
  });
}
