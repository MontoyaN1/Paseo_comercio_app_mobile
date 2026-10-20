import 'package:flutter/material.dart';

import '../../widgets/shared/under_construction_page.dart';

class AdminOrganizacionesPage extends StatelessWidget {
  const AdminOrganizacionesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const UnderConstructionPage(
      title: 'Organizaciones',
      owner: 'Persona A',
      phase: 'Fase 2',
    );
  }
}
