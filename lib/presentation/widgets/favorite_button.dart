// lib/presentation/widgets/favorite_button.dart
//
// 🏛️  PLAZA UNIVERSE — Botón de Favorito Reutilizable
// ────────────────────────────────────────────────────────────
//  Características:
//  • Glassmorphism con blur
//  • Animación de scale al presionar
//  • Transición animada entre iconos
//  • Color rojo para activo, gris para inactivo
// ────────────────────────────────────────────────────────────

import 'dart:ui' as ui;
import 'package:flutter/material.dart';

const _kBorder = Color(0xFF1E1E3A);
const _kHint = Color(0xFF6B6B8A);

class FavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback? onTap;
  final double size;

  const FavoriteButton({
    super.key,
    required this.isFavorite,
    this.onTap,
    this.size = 32,
  });

  @override
  State<FavoriteButton> createState() => FavoriteButtonState();
}

class FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late bool _localIsFavorite;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.78,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _localIsFavorite = widget.isFavorite;
  }

  @override
  void didUpdateWidget(FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) {
      _localIsFavorite = widget.isFavorite;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        setState(() {
          _localIsFavorite = !_localIsFavorite;
        });
        _ctrl.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder:
            (_, __) => Transform.scale(
              scale: _scale.value,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      color:
                          _localIsFavorite
                              ? Colors.red.withOpacity(0.8)
                              : Colors.black.withOpacity(0.45),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            _localIsFavorite
                                ? Colors.red.withOpacity(0.8)
                                : _kBorder,
                        width: 1,
                      ),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: Icon(
                        _localIsFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        key: ValueKey(_localIsFavorite),
                        size: widget.size * 0.5,
                        color: _localIsFavorite ? Colors.white : _kHint,
                      ),
                    ),
                  ),
                ),
              ),
            ),
      ),
    );
  }
}
