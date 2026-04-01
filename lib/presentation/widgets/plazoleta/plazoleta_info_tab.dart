// lib/presentation/widgets/plazoleta/plazoleta_info_tab.dart
//
// 🏛️ PLAZA UNIVERSE — Plazoleta Info Tab
// ────────────────────────────────────────────────────────────
//  INFO TAB - USA TEMA
// ────────────────────────────────────────────────────────────

import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:paseo_del_comercio/domain/entities/plazoleta.dart';
import 'package:paseo_del_comercio/domain/entities/imagen_base.dart';

import 'plazoleta_components.dart';

const _kGold = Color(0xFFD4AF37);
const _kSurface = Color(0xFF0F0F1E);
const _kSurfaceCard = Color(0xFF12121F);
const _kBorder = Color(0xFF1E1E3A);
const _kHint = Color(0xFF6B6B8A);

// ══════════════════════════════════════════════════════════════
//  SECTION BUILDER
// ══════════════════════════════════════════════════════════════
class PlazoletaSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const PlazoletaSection({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? _kSurfaceCard : Colors.white;
    final borderColor = isDark ? _kBorder : Colors.grey.shade300;
    final textColor = isDark ? Colors.white : Colors.black;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: surfaceColor.withOpacity(0.90),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _kGold.withOpacity(0.10),
                        border: Border.all(
                          color: _kGold.withOpacity(0.30),
                          width: 1,
                        ),
                      ),
                      child: Icon(icon, color: _kGold, size: 15),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_kGold.withOpacity(0.30), Colors.transparent],
                  ),
                ),
              ),
              Padding(padding: const EdgeInsets.all(16), child: child),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  INFO TAB
// ══════════════════════════════════════════════════════════════
class PlazoletaInfoTab extends StatelessWidget {
  final Plazoleta plazoleta;
  final List<ImagenBase> imagenes;
  final Animation<double>? contentFade;
  final Animation<double>? contentSlide;
  final Future<void> Function() onRefresh;

  const PlazoletaInfoTab({
    super.key,
    required this.plazoleta,
    required this.imagenes,
    required this.onRefresh,
    this.contentFade,
    this.contentSlide,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hintColor = isDark ? _kHint : Colors.grey.shade600;

    Widget content = RefreshIndicator(
      color: _kGold,
      backgroundColor: isDark ? _kSurface : Colors.white,
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imagenes.isNotEmpty) ...[
              PlazoletaSection(
                title: 'Galería',
                icon: Icons.photo_library_rounded,
                child: SizedBox(
                  height: 130,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: imagenes.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, i) {
                      final img = imagenes[i];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          children: [
                            CachedNetworkImage(
                              imageUrl: img.urlPreferida,
                              width: 160,
                              height: 130,
                              fit: BoxFit.cover,
                              placeholder:
                                  (_, __) => Container(
                                    width: 160,
                                    color: _kSurface,
                                    child: const Center(
                                      child: SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1.5,
                                          valueColor: AlwaysStoppedAnimation(
                                            _kGold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              errorWidget:
                                  (_, __, ___) => Container(
                                    width: 160,
                                    color: _kSurface,
                                    child: Icon(
                                      Icons.broken_image_rounded,
                                      color: _kGold.withOpacity(0.4),
                                      size: 28,
                                    ),
                                  ),
                            ),
                            if (img.esPrincipal)
                              Positioned(
                                top: 6,
                                left: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _kGold.withOpacity(0.85),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Principal',
                                    style: TextStyle(
                                      color: _kSurface,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (plazoleta.descripcion != null &&
                plazoleta.descripcion!.isNotEmpty) ...[
              PlazoletaSection(
                title: 'Sobre la plazoleta',
                icon: Icons.auto_stories_rounded,
                child: Text(
                  plazoleta.descripcion!,
                  style: TextStyle(
                    color: hintColor,
                    fontSize: 14,
                    height: 1.65,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            PlazoletaSection(
              title: 'Información general',
              icon: Icons.info_outline_rounded,
              child: Column(
                children: [
                  PlazoletaGoldInfoRow(
                    icon: Icons.category_rounded,
                    label: 'Tipo de ubicación',
                    value: plazoleta.tipoUbicacionTexto,
                  ),
                  const PlazoletaGoldDivider(),
                  PlazoletaGoldInfoRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Fecha de creación',
                    value: plazoleta.fechaCreacionFormateada,
                  ),
                  if (plazoleta.esReciente) ...[
                    const PlazoletaGoldDivider(),
                    const PlazoletaGoldInfoRow(
                      icon: Icons.fiber_new_rounded,
                      label: 'Estado',
                      value: 'Nueva',
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (contentFade != null || contentSlide != null) {
      content = AnimatedBuilder(
        animation: Listenable.merge(
          [contentFade, contentSlide].whereType<Animation>().toList(),
        ),
        builder:
            (_, child) => Opacity(
              opacity: contentFade?.value.clamp(0.0, 1.0) ?? 1.0,
              child: Transform.translate(
                offset: Offset(0, contentSlide?.value ?? 0),
                child: child,
              ),
            ),
        child: content,
      );
    }

    return content;
  }
}
