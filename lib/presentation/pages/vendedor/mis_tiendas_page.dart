import 'package:flutter/material.dart';

import '../../widgets/shared/under_construction_page.dart';

class MisTiendasPage extends StatelessWidget {
  const MisTiendasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const UnderConstructionPage(
      title: 'Mis tiendas',
      owner: 'Persona B',
      phase: 'Fase 3',
    );
  }
}
