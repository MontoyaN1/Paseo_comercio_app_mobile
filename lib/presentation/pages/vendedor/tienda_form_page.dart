import 'package:flutter/material.dart';

import '../../widgets/shared/under_construction_page.dart';

class TiendaFormPage extends StatelessWidget {
  final int? tiendaId;

  const TiendaFormPage({super.key, this.tiendaId});

  @override
  Widget build(BuildContext context) {
    return UnderConstructionPage(
      title: tiendaId == null ? 'Nueva tienda' : 'Editar tienda',
      owner: 'Persona B',
      phase: 'Fase 3',
      detail: tiendaId == null ? null : 'ID: $tiendaId',
    );
  }
}
