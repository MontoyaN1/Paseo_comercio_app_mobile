import 'package:flutter/material.dart';

import '../../widgets/shared/under_construction_page.dart';

class AdminUsuariosPage extends StatelessWidget {
  const AdminUsuariosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const UnderConstructionPage(
      title: 'Usuarios',
      owner: 'Persona A',
      phase: 'Fase 2',
    );
  }
}
