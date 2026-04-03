// lib/presentation/widgets/plazoleta/plazoleta_detail_panel.dart
//
// 🏛️  PLAZA UNIVERSE v4 — Detail Panel para Plazoleta
// ────────────────────────────────────────────────────────────
//  Extraído de plazoleta_list_page.dart
//  USA Theme.of(context) para colores de UI genéricos
// ────────────────────────────────────────────────────────────

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../domain/entities/plazoleta.dart';
import '../../../../domain/entities/enums.dart';
import '../../../blocs/plazoleta/plazoleta_state.dart';
import '../../mall/mall_world_painter.dart';

class PlazoletaDetailPanel extends StatelessWidget {
  final PlazaDetail plaza;
  final PlazoletaLoaded state;
  final VoidCallback onClose;
  final VoidCallback onEnter;

  const PlazoletaDetailPanel({
    super.key,
    required this.plaza,
    required this.state,
    required this.onClose,
    required this.onEnter,
  });

  Color _uiAccent(BuildContext context, Color acc) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) return acc;
    return Color.lerp(acc, Colors.black, 0.35)!;
  }

  Color _btnTextColor(BuildContext context, Color acc) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) return Colors.black;
    final luminance = acc.computeLuminance();
    return luminance > 0.5 ? const Color(0xFF1A1A1A) : Colors.white;
  }

  String? _imgUrl() {
    final d = plaza.data;
    if (d == null) return null;
    if (state.imagenesPlazoleta != null) {
      for (final img in state.imagenesPlazoleta!) {
        if (img.entidadRelacionadaId == d.id && img.esPrincipal) {
          return img.urlPreferida;
        }
      }
      for (final img in state.imagenesPlazoleta!) {
        if (img.entidadRelacionadaId == d.id) return img.urlPreferida;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final acc = plaza.accent;
    final uiAcc = _uiAccent(context, acc);
    final d = plaza.data;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          height: 240,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.surface.withValues(alpha: 0.97),
                theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.97,
                ),
              ],
            ),
            border: Border(
              top: BorderSide(color: uiAcc.withValues(alpha: 0.50), width: 1.5),
            ),
            boxShadow: [
              BoxShadow(
                color: uiAcc.withValues(alpha: 0.10),
                blurRadius: 32,
                offset: const Offset(0, -12),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: 12,
                right: 14,
                child: GestureDetector(
                  onTap: onClose,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.08,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.18,
                        ),
                      ),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.54,
                      ),
                      size: 16,
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 14),
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: uiAcc.withValues(alpha: 0.50),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child:
                          d == null
                              ? _soon(context, acc, uiAcc)
                              : _detail(context, d, acc, uiAcc, _imgUrl()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detail(
    BuildContext context,
    Plazoleta d,
    Color acc,
    Color uiAcc,
    String? imgUrl,
  ) {
    final theme = Theme.of(context);
    const imgSize = 110.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: imgSize,
          height: imgSize,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                border: Border.all(
                  color: uiAcc.withValues(alpha: 0.40),
                  width: 1.2,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child:
                  imgUrl != null
                      ? CachedNetworkImage(
                        imageUrl: imgUrl,
                        fit: BoxFit.cover,
                        errorWidget:
                            (_, __, ___) =>
                                _imgPlaceholder(context, acc, uiAcc),
                      )
                      : _imgPlaceholder(context, acc, uiAcc),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: SizedBox(
            height: imgSize,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _chipLabel(
                          context,
                          'Plaza ${plaza.index + 1}',
                          acc,
                          uiAcc,
                        ),
                        const SizedBox(width: 6),
                        if (d.tipoUbicacion == TipoUbicacion.zonaComida)
                          _iconBadge(Icons.restaurant_outlined, uiAcc),
                        if (d.tipoUbicacion ==
                            TipoUbicacion.estacionamiento) ...[
                          const SizedBox(width: 4),
                          _iconBadge(Icons.local_parking, uiAcc),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      d.nombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    if ((d.descripcion ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 10,
                            color: uiAcc.withValues(alpha: 0.75),
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              d.descripcion ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.48),
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                GestureDetector(
                  onTap: onEnter,
                  child: Container(
                    height: 38,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [acc, Color.lerp(acc, Colors.white, 0.22)!],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: uiAcc.withValues(alpha: 0.38),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Entrar a la plaza',
                          style: TextStyle(
                            color: _btnTextColor(context, acc),
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: _btnTextColor(context, acc),
                          size: 15,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _chipLabel(BuildContext context, String text, Color acc, Color uiAcc) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: uiAcc.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: uiAcc.withValues(alpha: 0.45)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: uiAcc,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _iconBadge(IconData icon, Color uiAcc) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: uiAcc.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: uiAcc.withValues(alpha: 0.32)),
      ),
      child: Icon(icon, size: 13, color: uiAcc),
    );
  }

  Widget _soon(BuildContext context, Color acc, Color uiAcc) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.park_outlined,
            size: 44,
            color: uiAcc.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 10),
          Text(
            'PRÓXIMAMENTE',
            style: TextStyle(
              color: uiAcc.withValues(alpha: 0.6),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Este espacio pronto estará disponible',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _imgPlaceholder(BuildContext context, Color acc, Color uiAcc) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.park_outlined,
          color: uiAcc.withValues(alpha: 0.5),
          size: 32,
        ),
      ),
    );
  }
}

class PlazaDetail {
  final MallSlot slot;
  final Plazoleta? data;
  final Color accent;
  final int index;
  final int seed;

  const PlazaDetail({
    required this.slot,
    this.data,
    required this.accent,
    required this.index,
    required this.seed,
  });
}
