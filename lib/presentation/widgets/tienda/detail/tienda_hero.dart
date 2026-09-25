// lib/presentation/widgets/tienda/tienda_hero.dart
//
// 🏛️ HERO SECTION - Tienda Detail
// ────────────────────────────────────────────────────────────

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

const _kGold = Color(0xFFD4AF37);
const _kGoldLight = Color(0xFFFFE082);
const _kGoldDeep = Color(0xFF9C7A1A);
const _kBg = Color(0xFF07070F);

class TiendaHeroStatPill extends StatelessWidget {
  final IconData icon;
  final String value;

  const TiendaHeroStatPill({
    super.key,
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark
            ? const Color(0xFF0F0F1E).withValues(alpha: 0.70)
            : Colors.white.withValues(alpha: 0.80);
    final borderColor = isDark ? const Color(0xFF1E1E3A) : Colors.grey.shade300;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _kGold),
          const SizedBox(width: 5),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class TiendaHero extends StatelessWidget {
  final Map<String, dynamic> tienda;
  final Animation<double> heroFade;
  final Animation<double> heroScale;
  final int productosCount;
  final Widget? fallbackChild;

  const TiendaHero({
    super.key,
    required this.tienda,
    required this.heroFade,
    required this.heroScale,
    required this.productosCount,
    this.fallbackChild,
  });

  String? _getImagenPrincipal() {
    String? imagenPrincipal;

    final imagenTiendaData = tienda['imagen_tienda'];
    if (imagenTiendaData != null) {
      if (imagenTiendaData is List && imagenTiendaData.isNotEmpty) {
        final primeraImagen = imagenTiendaData.first;
        if (primeraImagen is Map) {
          imagenPrincipal = primeraImagen['url'] ?? primeraImagen['url_imagen'];
        }
      } else if (imagenTiendaData is String && imagenTiendaData.isNotEmpty) {
        imagenPrincipal = imagenTiendaData;
      }
    }

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

    return imagenPrincipal;
  }

  @override
  Widget build(BuildContext context) {
    final imagenPrincipal = _getImagenPrincipal();
    final tieneImagen = imagenPrincipal != null && imagenPrincipal.isNotEmpty;

    return Opacity(
      opacity: heroFade.value,
      child: Transform.scale(
        scale: heroScale.value,
        alignment: Alignment.topCenter,
        child: SizedBox(
          height: 280,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (tieneImagen)
                CachedNetworkImage(
                  imageUrl: imagenPrincipal,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => _buildFallback(context),
                )
              else
                _buildFallback(context),
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
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _kGold.withValues(alpha: 0.06),
                      Colors.transparent,
                      _kGoldDeep.withValues(alpha: 0.08),
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
                          color: _kGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _kGold.withValues(alpha: 0.40),
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
                      Row(
                        children: [
                          TiendaHeroStatPill(
                            icon: Icons.shopping_bag_rounded,
                            value: '$productosCount productos',
                          ),
                          const SizedBox(width: 8),
                          TiendaHeroStatPill(
                            icon: Icons.visibility_rounded,
                            value: '${tienda['total_visitas'] ?? 0} visitas',
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
    );
  }

  Widget _buildFallback(BuildContext context) {
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
            _kGoldDeep.withValues(alpha: 0.3),
            _kBg,
            _kGold.withValues(alpha: 0.2),
          ],
        ),
      ),
      child:
          tieneLogo
              ? CachedNetworkImage(
                imageUrl: logoUrl.toString(),
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _buildIconFallback(),
              )
              : _buildIconFallback(),
    );
  }

  Widget _buildIconFallback() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _kGold.withValues(alpha: 0.15),
              border: Border.all(
                color: _kGold.withValues(alpha: 0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _kGold.withValues(alpha: 0.3),
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
              color: _kGold.withValues(alpha: 0.8),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
