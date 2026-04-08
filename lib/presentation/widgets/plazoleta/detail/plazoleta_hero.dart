// lib/presentation/widgets/plazoleta/plazoleta_hero.dart
//
// 🏛️ PLAZA UNIVERSE — Plazoleta Hero
// ────────────────────────────────────────────────────────────
//  HERO SECTION - USA TEMA
// ────────────────────────────────────────────────────────────

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:paseo_del_comercio/domain/entities/plazoleta.dart';
import 'package:paseo_del_comercio/domain/entities/producto.dart';
import 'package:paseo_del_comercio/domain/entities/tienda.dart';
import 'package:paseo_del_comercio/domain/entities/imagen_base.dart';

import '../plazoleta_components.dart';

const _kGold = Color(0xFFD4AF37);
const _kGoldLight = Color(0xFFFFE082);
const _kGoldDeep = Color(0xFF9C7A1A);
const _kSurface = Color(0xFF0F0F1E);

class _ShimmerLoading extends StatefulWidget {
  const _ShimmerLoading();

  @override
  State<_ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<_ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value;
        final opacity = (value < 0.5) ? value * 2 : (1 - value) * 2;
        return Container(
          color: isDark ? const Color(0xFF1A1A2E) : Colors.grey.shade300,
          child: Center(
            child: Opacity(
              opacity: 0.3 + opacity * 0.5,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? _kGold.withOpacity(0.2)
                      : Colors.white,
                  border: Border.all(
                    color: _kGold,
                    width: 2.5,
                  ),
                ),
                child: const Center(
                  child: Text('🏛️', style: TextStyle(fontSize: 48)),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class PlazoletaHero extends StatelessWidget {
  final Plazoleta plazoleta;
  final List<ImagenBase> imagenes;
  final List<Producto> productos;
  final List<Tienda> tiendas;

  const PlazoletaHero({
    super.key,
    required this.plazoleta,
    required this.imagenes,
    required this.productos,
    required this.tiendas,
  });

  String _emojiForTipo(Plazoleta p) {
    if (p.esPlazoletaPrincipal) return '🏛️';
    if (p.esAreaSecundaria) return '🚶';
    if (p.esEntradaSalida) return '🚪';
    return '📍';
  }

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagenDetalle =
        imagenes.isNotEmpty
            ? imagenes.firstWhere(
              (i) => i.tipoImagen.value == 'detalle',
              orElse: () => imagenes.firstWhere(
                (i) => i.esPrincipal,
                orElse: () => imagenes.first,
              ),
            )
            : null;

    final tieneImagen =
        imagenDetalle != null && _isValidUrl(imagenDetalle.urlPreferida);

    return SizedBox(
      height: 300,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (tieneImagen)
            CachedNetworkImage(
              imageUrl: imagenDetalle.urlPreferida,
              fit: BoxFit.cover,
              placeholder: (_, __) => const _ShimmerLoading(),
              errorWidget: (_, __, ___) => _buildFallback(context),
              memCacheWidth: 800,
            )
          else
            const _ShimmerLoading(),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xCC07070F),
                  const Color(0x3307070F),
                  const Color(0xFF07070F),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),

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
                  Row(
                    children: [
                      PlazoletaHeroStatPill(
                        icon: Icons.shopping_bag_rounded,
                        value: '${productos.length} productos',
                      ),
                      const SizedBox(width: 8),
                      PlazoletaHeroStatPill(
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
    );
  }

  Widget _buildFallback(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? _kSurface : Colors.grey.shade200,
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
}
