// lib/presentation/widgets/producto/producto_hero.dart
//
// 🏛️ HERO SECTION - Producto Detail
// ────────────────────────────────────────────────────────────

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

const _kGold = Color(0xFFD4AF37);
const _kGoldLight = Color(0xFFFFE082);
const _kGoldDeep = Color(0xFF9C7A1A);
const _kBg = Color(0xFF07070F);

class ProductoHero extends StatelessWidget {
  final String? imageUrl;
  final String productName;
  final double? precio;
  final Animation<double> heroFade;
  final Animation<double> heroScale;

  const ProductoHero({
    super.key,
    this.imageUrl,
    required this.productName,
    this.precio,
    required this.heroFade,
    required this.heroScale,
  });

  bool get _hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  String _formatPrice(double precio) {
    if (precio >= 1000) {
      final precioInt = precio.round();
      final miles = (precioInt / 1000).floor();
      final resto = precioInt % 1000;
      return '\$$miles.${resto.toString().padLeft(3, '0')}';
    }
    return '\$${precio.round()}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: heroFade,
      builder:
          (context, child) => Opacity(
            opacity: heroFade.value,
            child: Transform.scale(
              scale: heroScale.value,
              alignment: Alignment.topCenter,
              child: SizedBox(
                height: 320,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (_hasImage)
                      CachedNetworkImage(
                        imageUrl: imageUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => _buildFallback(),
                      )
                    else
                      _buildFallback(),
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
                            ShaderMask(
                              shaderCallback:
                                  (b) => const LinearGradient(
                                    colors: [Colors.white, _kGoldLight],
                                    stops: [0.6, 1.0],
                                  ).createShader(b),
                              child: Text(
                                productName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            if (precio != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                _formatPrice(precio!),
                                style: const TextStyle(
                                  color: _kGold,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
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

  Widget _buildFallback() {
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
      child: Center(
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
              child: const Icon(
                Icons.inventory_2_rounded,
                size: 40,
                color: _kGold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              productName,
              style: TextStyle(
                color: _kGold.withValues(alpha: 0.8),
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
}
