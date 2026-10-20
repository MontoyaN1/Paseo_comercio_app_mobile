import 'package:flutter/material.dart';

import '../../widgets/shared/under_construction_page.dart';

class AdminTiendasPage extends StatelessWidget {
  const AdminTiendasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const UnderConstructionPage(
      title: 'Tiendas',
      owner: 'Persona A',
      phase: 'Fase 2',
    );
  }
}
