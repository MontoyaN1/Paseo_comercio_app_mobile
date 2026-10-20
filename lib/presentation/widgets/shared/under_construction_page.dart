import 'package:flutter/material.dart';

class UnderConstructionPage extends StatelessWidget {
  final String title;
  final String owner;
  final String phase;
  final String? detail;

  const UnderConstructionPage({
    super.key,
    required this.title,
    required this.owner,
    required this.phase,
    this.detail,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.construction_rounded,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              if (detail != null) ...[
                const SizedBox(height: 8),
                Text(detail!, textAlign: TextAlign.center),
              ],
              const SizedBox(height: 16),
              Text('Responsable: $owner', textAlign: TextAlign.center),
              Text('Fase: $phase', textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
