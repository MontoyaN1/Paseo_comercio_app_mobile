// lib/presentation/widgets/plazoleta/plazoleta_list_header.dart
//
// 🏛️ PLAZA UNIVERSE — Plazoleta List Header
// ────────────────────────────────────────────────────────────

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

const _kGold = Color(0xFFD4AF37);
const _kGoldLight = Color(0xFFFFE082);
const _kGoldDeep = Color(0xFF9C7A1A);

class PlazoletaListHeader extends StatelessWidget {
  final int plazoletasCount;
  final VoidCallback onRefresh;

  const PlazoletaListHeader({
    super.key,
    required this.plazoletasCount,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + 10,
              20,
              14,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.surface.withValues(alpha: 0.96),
                  theme.colorScheme.surface.withValues(alpha: 0.0),
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: _kGold.withValues(alpha: 0.18),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback:
                            (b) => const LinearGradient(
                              colors: [
                                Color(0xFF9C7A1A),
                                _kGold,
                                Color(0xFFFFE082),
                                _kGold,
                              ],
                              stops: [0.0, 0.35, 0.65, 1.0],
                            ).createShader(b),
                        child: const Text(
                          'PASEO DEL COMERCIO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: _kGold,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            '$plazoletasCount plazoletas  •  Centro Comercial Virtual',
                            style: TextStyle(
                              color: _kGold.withValues(alpha: 0.65),
                              fontSize: 11,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _HeaderIconButton(
                  icon: Icons.refresh_rounded,
                  onTap: onRefresh,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iconColor = isDark ? _kGold : const Color(0xFFB8860B);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color:
              isDark
                  ? theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.88,
                  )
                  : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: iconColor.withValues(alpha: 0.30)),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
    );
  }
}
