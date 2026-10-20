import 'package:flutter/material.dart';

import '../../widgets/shared/under_construction_page.dart';

class AdminCategoriasPage extends StatelessWidget {
  const AdminCategoriasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const UnderConstructionPage(
      title: 'Categorías',
      owner: 'Persona A',
      phase: 'Fase 2',
    );
  }
}
