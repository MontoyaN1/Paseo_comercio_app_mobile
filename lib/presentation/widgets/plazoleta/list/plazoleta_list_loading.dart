// lib/presentation/widgets/plazoleta/plazoleta_list_loading.dart
//
// 🏛️ PLAZA UNIVERSE — Plazoleta List Loading
// ────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

const _kGold = Color(0xFFD4AF37);

class PlazoletaListLoading extends StatelessWidget {
  const PlazoletaListLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: const AlwaysStoppedAnimation(_kGold),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Construyendo el mall…',
              style: TextStyle(
                color: _kGold.withValues(alpha: 0.8),
                fontSize: 13,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
