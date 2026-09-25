// lib/presentation/widgets/producto/producto_loading_error.dart
//
// 🏛️ PLAZA UNIVERSE — Producto Loading/Error State
// ────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

const _kGold = Color(0xFFD4AF37);
const _kHint = Color(0xFF6B6B8A);

class ProductoLoadingError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ProductoLoadingError({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: _kGold),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: _kHint)),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: const Text('Reintentar', style: TextStyle(color: _kGold)),
            ),
          ],
        ],
      ),
    );
  }
}
