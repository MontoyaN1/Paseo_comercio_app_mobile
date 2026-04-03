// lib/presentation/widgets/tienda/tienda_app_bar.dart
//
// 🏛️ FLOATING APP BAR - Tienda Detail
// ────────────────────────────────────────────────────────────

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:paseo_del_comercio/presentation/blocs/favorito/favorito_bloc.dart';
import 'package:paseo_del_comercio/presentation/blocs/favorito/favorito_event.dart';
import 'package:paseo_del_comercio/presentation/blocs/favorito/favorito_state.dart';
import 'package:paseo_del_comercio/presentation/widgets/shared/favorite_button.dart';
import 'package:paseo_del_comercio/presentation/widgets/tienda/tienda_components.dart';

const _kSurface = Color(0xFF0F0F1E);
const _kBorder = Color(0xFF1E1E3A);

class TiendaFloatingAppBar extends StatelessWidget {
  final String title;
  final double collapseProgress;
  final VoidCallback? onBack;
  final VoidCallback? onShare;
  final int? tiendaId;

  const TiendaFloatingAppBar({
    super.key,
    required this.title,
    required this.collapseProgress,
    this.onBack,
    this.onShare,
    this.tiendaId,
  });

  @override
  Widget build(BuildContext context) {
    final opacity = collapseProgress.clamp(0.0, 1.0);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor =
        isDark
            ? _kSurface.withValues(alpha: 0.85 * opacity)
            : Colors.white.withValues(alpha: 0.85 * opacity);
    final borderColor =
        isDark
            ? _kBorder.withValues(alpha: opacity)
            : Colors.grey.shade400.withValues(alpha: opacity);
    final textColor = isDark ? Colors.white : Colors.black87;

    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20 * opacity, sigmaY: 20 * opacity),
        child: AnimatedContainer(
          duration: Duration.zero,
          height: kToolbarHeight,
          decoration: BoxDecoration(
            color: bgColor,
            border: Border(bottom: BorderSide(color: borderColor, width: 1)),
          ),
          child: Row(
            children: [
              const SizedBox(width: 8),
              TiendaIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    Future.microtask(() => context.go('/plazoletas'));
                  }
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AnimatedOpacity(
                  opacity: opacity,
                  duration: Duration.zero,
                  child: Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              TiendaIconButton(
                icon: Icons.share_rounded,
                onTap: onShare ?? () {},
              ),
              const SizedBox(width: 4),
              if (tiendaId != null)
                BlocBuilder<FavoritoBloc, FavoritoState>(
                  builder: (context, state) {
                    final isFav =
                        state is FavoritosLoaded
                            ? state.isTiendaFavorita(tiendaId!)
                            : false;
                    return FavoriteButton(
                      isFavorite: isFav,
                      onTap: () {
                        context.read<FavoritoBloc>().add(
                          ToggleTiendaFavorito(tiendaId: tiendaId!),
                        );
                      },
                    );
                  },
                ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}
