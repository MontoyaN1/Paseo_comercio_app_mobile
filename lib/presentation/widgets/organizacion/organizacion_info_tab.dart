// lib/presentation/widgets/organizacion/organizacion_info_tab.dart
//
// 🏛️ PLAZA UNIVERSE — Organizacion Info Tab
// ────────────────────────────────────────────────────────────
//  INFO TAB - USA TEMA
// ────────────────────────────────────────────────────────────

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:paseo_del_comercio/domain/entities/organizacion.dart';

import 'organizacion_components.dart';

const _kGold = Color(0xFFD4AF37);
const _kSurfaceCard = Color(0xFF12121F);
const _kBorder = Color(0xFF1E1E3A);
const _kHint = Color(0xFF6B6B8A);

class OrganizacionSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const OrganizacionSection({
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

class OrganizacionStatsRow extends StatelessWidget {
  final Organizacion organizacion;

  const OrganizacionStatsRow({super.key, required this.organizacion});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OrganizacionStatCard(
            icon: Icons.store_rounded,
            value: organizacion.totalTiendas ?? 0,
            label: 'Tiendas',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OrganizacionStatCard(
            icon: Icons.people_alt_rounded,
            value: organizacion.totalMiembros ?? 0,
            label: 'Miembros',
          ),
        ),
      ],
    );
  }
}

class OrganizacionInfoTab extends StatelessWidget {
  final Organizacion organizacion;
  final Animation<double>? contentFade;
  final Animation<double>? contentSlide;

  const OrganizacionInfoTab({
    super.key,
    required this.organizacion,
    this.contentFade,
    this.contentSlide,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hintColor = isDark ? _kHint : Colors.grey.shade600;

    Widget content = SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OrganizacionStatsRow(organizacion: organizacion),
          const SizedBox(height: 20),
          if (organizacion.descripcion != null &&
              organizacion.descripcion!.isNotEmpty) ...[
            OrganizacionSection(
              title: 'Sobre la organización',
              icon: Icons.auto_stories_rounded,
              child: Text(
                organizacion.descripcion!,
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
          OrganizacionSection(
            title: 'Información de contacto',
            icon: Icons.contact_page_outlined,
            child: Column(
              children: [
                OrganizacionGoldInfoRow(
                  icon: Icons.alternate_email_rounded,
                  label: 'Email del anfitrión',
                  value: organizacion.emailAnfitrion,
                ),
                const OrganizacionGoldDivider(),
                OrganizacionGoldInfoRow(
                  icon: Icons.schedule_rounded,
                  label: 'Miembro desde',
                  value: organizacion.tiempoDesdeCreacion,
                ),
              ],
            ),
          ),
        ],
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
