import 'package:flutter/material.dart';

import '../../widgets/shared/under_construction_page.dart';

class MisProductosPage extends StatelessWidget {
  const MisProductosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const UnderConstructionPage(
      title: 'Mis productos',
      owner: 'Persona B',
      phase: 'Fase 3',
    );
  }
}
