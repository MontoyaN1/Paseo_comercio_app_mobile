import 'package:flutter/material.dart';

import '../../widgets/shared/under_construction_page.dart';

class AdminPlazoletaFormPage extends StatelessWidget {
  final int? plazoletaId;

  const AdminPlazoletaFormPage({super.key, this.plazoletaId});

  @override
  Widget build(BuildContext context) {
    return UnderConstructionPage(
      title: plazoletaId == null ? 'Nueva plazoleta' : 'Editar plazoleta',
      owner: 'Persona A',
      phase: 'Fase 2',
      detail: plazoletaId == null ? null : 'ID: $plazoletaId',
    );
  }
}
