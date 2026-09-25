// lib/presentation/widgets/organizacion/organizacion_card.dart
//
// 🏛️ CARD DE ORGANIZACIÓN - glassmorphism + glow dorado
// USA Theme.of(context) para colores de UI genéricos
// ────────────────────────────────────────────────────────────

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../domain/entities/organizacion.dart';
import '../../../../domain/entities/enums.dart';
import '../../../../core/theme/app_colors.dart';

const _kGold = Color(0xFFD4AF37);

class OrganizacionCard extends StatefulWidget {
  final Organizacion organizacion;
  final VoidCallback onTap;
  final String Function(TipoOrganizacion) getDescripcionTipo;
  final Color Function(String) getColorFromHex;

  const OrganizacionCard({
    super.key,
    required this.organizacion,
    required this.onTap,
    required this.getDescripcionTipo,
    required this.getColorFromHex,
  });

  @override
  State<OrganizacionCard> createState() => _OrganizacionCardState();
}

class _OrganizacionCardState extends State<OrganizacionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hoverCtrl;
  late final Animation<double> _hoverAnim;

  @override
  void initState() {
    super.initState();
    _hoverCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _hoverAnim = CurvedAnimation(parent: _hoverCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _hoverCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final org = widget.organizacion;
    final typeColor = widget.getColorFromHex(org.colorTipo);

    return GestureDetector(
      onTapDown: (_) => _hoverCtrl.forward(),
      onTapUp: (_) {
        _hoverCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _hoverCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _hoverAnim,
        builder:
            (_, child) => Transform.scale(
              scale: 1.0 - (_hoverAnim.value * 0.015),
              child: Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: _kGold.withOpacity(0.05 + _hoverAnim.value * 0.12),
                      blurRadius: 20 + _hoverAnim.value * 16,
                      spreadRadius: _hoverAnim.value * 2,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.45),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: child,
              ),
            ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceCard.withOpacity(0.90),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: theme.colorScheme.surfaceContainerHighest,
                  width: 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 3,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          _kGold.withOpacity(0.7),
                          typeColor.withOpacity(0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: typeColor.withOpacity(0.08),
                                border: Border.all(
                                  color: _kGold.withOpacity(0.30),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _kGold.withOpacity(0.10),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child:
                                    org.logoUrlPrincipal != null
                                        ? CachedNetworkImage(
                                          imageUrl: org.logoUrlPrincipal!,
                                          width: 58,
                                          height: 58,
                                          fit: BoxFit.cover,
                                          errorWidget:
                                              (_, __, ___) => Center(
                                                child: Text(
                                                  org.iconoTipo,
                                                  style: const TextStyle(
                                                    fontSize: 26,
                                                  ),
                                                ),
                                              ),
                                        )
                                        : Center(
                                          child: Text(
                                            org.iconoTipo,
                                            style: const TextStyle(
                                              fontSize: 26,
                                            ),
                                          ),
                                        ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    org.nombreParaMostrar,
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    org.descripcion ?? 'Sin descripción',
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 10),
                                  TypeBadge(
                                    label: widget.getDescripcionTipo(org.tipo),
                                    color: typeColor,
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: _kGold,
                                size: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                theme.colorScheme.surfaceContainerHighest,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GoldStatItem(
                              icon: Icons.store_rounded,
                              value: org.totalTiendas ?? 0,
                              label: 'Tiendas',
                            ),
                            Container(
                              width: 1,
                              height: 28,
                              color: theme.colorScheme.surfaceContainerHighest,
                            ),
                            GoldStatItem(
                              icon: Icons.people_alt_rounded,
                              value: org.totalMiembros ?? 0,
                              label: 'Miembros',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TypeBadge extends StatelessWidget {
  final String label;
  final Color color;

  const TypeBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _kGold.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kGold.withOpacity(0.30), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: _kGold,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class GoldStatItem extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;

  const GoldStatItem({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: _kGold.withOpacity(0.75)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value.toString(),
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 11,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
