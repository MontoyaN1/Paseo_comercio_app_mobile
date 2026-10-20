import 'package:flutter/material.dart';

import '../../widgets/shared/under_construction_page.dart';

class VendedorHomePage extends StatelessWidget {
  const VendedorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const UnderConstructionPage(
      title: 'Panel del vendedor',
      owner: 'Persona B',
      phase: 'Fase 3',
    );
  }
}
