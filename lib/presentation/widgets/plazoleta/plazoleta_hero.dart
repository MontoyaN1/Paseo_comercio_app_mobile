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

import 'plazoleta_components.dart';

const _kGold = Color(0xFFD4AF37);
const _kGoldLight = Color(0xFFFFE082);
const _kGoldDeep = Color(0xFF9C7A1A);
const _kSurface = Color(0xFF0F0F1E);

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
    final imagenPrincipal =
        imagenes.isNotEmpty
            ? imagenes.firstWhere(
              (i) => i.esPrincipal,
              orElse: () => imagenes.first,
            )
            : null;

    final tieneImagen =
        imagenPrincipal != null && _isValidUrl(imagenPrincipal.urlPreferida);

    return SizedBox(
      height: 300,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (tieneImagen)
            CachedNetworkImage(
              imageUrl: imagenPrincipal.urlPreferida,
              fit: BoxFit.cover,
              placeholder: (_, __) => _buildFallback(context),
              errorWidget: (_, __, ___) => _buildFallback(context),
            )
          else
            _buildFallback(context),

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
