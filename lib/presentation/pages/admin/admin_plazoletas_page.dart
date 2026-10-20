import 'package:flutter/material.dart';

import '../../widgets/shared/under_construction_page.dart';

class AdminPlazoletasPage extends StatelessWidget {
  const AdminPlazoletasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const UnderConstructionPage(
      title: 'Plazoletas',
      owner: 'Persona A',
      phase: 'Fase 2',
    );
  }
}
