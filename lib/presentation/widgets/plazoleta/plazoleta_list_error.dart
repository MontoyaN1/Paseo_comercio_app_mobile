// lib/presentation/widgets/plazoleta/plazoleta_list_error.dart
//
// 🏛️ PLAZA UNIVERSE — Plazoleta List Error
// ────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

const _kGold = Color(0xFFD4AF37);
const _kGoldGlow = Color(0xFFFFE082);
const _kGoldDeep = Color(0xFF9C7A1A);

class PlazoletaListError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const PlazoletaListError({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              color: theme.colorScheme.error.withValues(alpha: 0.6),
              size: 54,
            ),
            const SizedBox(height: 14),
            Text(
              message.isNotEmpty ? message : 'Error de conexión',
              style: const TextStyle(color: Colors.white60, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_kGoldDeep, _kGold, _kGoldGlow],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'Reintentar',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
