import 'package:flutter/material.dart';

import '../../widgets/shared/under_construction_page.dart';

class InvitacionesPage extends StatelessWidget {
  const InvitacionesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const UnderConstructionPage(
      title: 'Invitaciones',
      owner: 'Persona C',
      phase: 'Fase 5',
    );
  }
}
