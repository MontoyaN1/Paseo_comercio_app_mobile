import 'package:flutter/material.dart';

import '../../widgets/shared/under_construction_page.dart';

class ProductoFormPage extends StatelessWidget {
  final int? productoId;
  final int? tiendaId;

  const ProductoFormPage({super.key, this.productoId, this.tiendaId});

  @override
  Widget build(BuildContext context) {
    return UnderConstructionPage(
      title: productoId == null ? 'Nuevo producto' : 'Editar producto',
      owner: 'Persona B',
      phase: 'Fase 3',
      detail:
          productoId != null
              ? 'ID: $productoId'
              : tiendaId != null
              ? 'Tienda: $tiendaId'
              : null,
    );
  }
}
