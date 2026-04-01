// lib/presentation/widgets/producto/producto_app_bar.dart
//
// 🏛️ FLOATING APP BAR - Producto Detail
// ────────────────────────────────────────────────────────────

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:paseo_del_comercio/presentation/blocs/favorito/favorito_bloc.dart';
import 'package:paseo_del_comercio/presentation/blocs/favorito/favorito_event.dart';
import 'package:paseo_del_comercio/presentation/blocs/favorito/favorito_state.dart';
import 'package:paseo_del_comercio/presentation/widgets/favorite_button.dart';
import 'package:paseo_del_comercio/presentation/widgets/producto/producto_components.dart';

const _kSurface = Color(0xFF0F0F1E);
const _kBorder = Color(0xFF1E1E3A);

class ProductoFloatingAppBar extends StatelessWidget {
  final String title;
  final double collapseProgress;
  final VoidCallback? onShare;
  final int? productoId;

  const ProductoFloatingAppBar({
    super.key,
    required this.title,
    required this.collapseProgress,
    this.onShare,
    this.productoId,
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
              ProductoIconButton(
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
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              ProductoIconButton(
                icon: Icons.share_rounded,
                onTap: onShare ?? () {},
              ),
              const SizedBox(width: 4),
              if (productoId != null)
                BlocBuilder<FavoritoBloc, FavoritoState>(
                  builder: (context, state) {
                    final isFav =
                        state is FavoritosLoaded
                            ? state.isProductoFavorito(productoId!)
                            : false;
                    return FavoriteButton(
                      isFavorite: isFav,
                      onTap: () {
                        context.read<FavoritoBloc>().add(
                          ToggleProductoFavorito(productoId: productoId!),
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
