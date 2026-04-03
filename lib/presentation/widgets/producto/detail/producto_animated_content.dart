// lib/presentation/widgets/producto/producto_animated_content.dart
//
// 🏛️ PLAZA UNIVERSE — Producto Animated Content Wrapper
// ────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

class ProductoAnimatedContent extends StatelessWidget {
  final Animation<double> contentFade;
  final Animation<double> contentSlide;
  final Widget child;

  const ProductoAnimatedContent({
    super.key,
    required this.contentFade,
    required this.contentSlide,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([contentFade, contentSlide]),
      builder:
          (_, child) => Opacity(
            opacity: contentFade.value.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, contentSlide.value),
              child: child,
            ),
          ),
      child: child,
    );
  }
}
