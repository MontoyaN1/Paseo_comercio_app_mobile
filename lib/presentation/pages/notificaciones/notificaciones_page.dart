import 'package:flutter/material.dart';

import '../../widgets/shared/under_construction_page.dart';

class NotificacionesPage extends StatelessWidget {
  const NotificacionesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const UnderConstructionPage(
      title: 'Notificaciones',
      owner: 'Persona C',
      phase: 'Fase 4',
    );
  }
}
