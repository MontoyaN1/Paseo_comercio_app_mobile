import 'package:flutter/material.dart';

import '../../widgets/shared/under_construction_page.dart';

class MiOrganizacionPage extends StatelessWidget {
  const MiOrganizacionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const UnderConstructionPage(
      title: 'Mi organización',
      owner: 'Persona C',
      phase: 'Fase 5',
    );
  }
}
