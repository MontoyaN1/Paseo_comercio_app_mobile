import 'package:flutter/material.dart';

import '../../widgets/shared/under_construction_page.dart';

class AdminCategoriaFormPage extends StatelessWidget {
  final int? categoriaId;

  const AdminCategoriaFormPage({super.key, this.categoriaId});

  @override
  Widget build(BuildContext context) {
    return UnderConstructionPage(
      title: categoriaId == null ? 'Nueva categoría' : 'Editar categoría',
      owner: 'Persona A',
      phase: 'Fase 2',
      detail: categoriaId == null ? null : 'ID: $categoriaId',
    );
  }
}
