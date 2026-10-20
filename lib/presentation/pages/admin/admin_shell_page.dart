import 'package:flutter/material.dart';

import '../../widgets/shared/under_construction_page.dart';

class AdminShellPage extends StatelessWidget {
  const AdminShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const UnderConstructionPage(
      title: 'Panel de administración',
      owner: 'Persona A',
      phase: 'Fase 2',
    );
  }
}
