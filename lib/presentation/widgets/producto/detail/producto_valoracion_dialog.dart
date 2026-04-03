// lib/presentation/widgets/producto/producto_valoracion_dialog.dart
//
// 🏛️ VALORACION DIALOG - Producto Detail
// ────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

const _kGold = Color(0xFFD4AF37);

class ProductoValoracionDialog extends StatefulWidget {
  final void Function(double calificacion, String comentario) onSubmit;

  const ProductoValoracionDialog({super.key, required this.onSubmit});

  @override
  State<ProductoValoracionDialog> createState() =>
      _ProductoValoracionDialogState();
}

class _ProductoValoracionDialogState extends State<ProductoValoracionDialog> {
  double _calificacion = 5;
  final _comentarioController = TextEditingController();

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final hintColor = isDark ? const Color(0xFF6B6B8A) : Colors.grey;
    final surfaceColor = isDark ? const Color(0xFF12121F) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E1E3A) : Colors.grey.shade300;
    final surfaceInputColor =
        isDark ? const Color(0xFF0F0F1E) : Colors.grey.shade100;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Escribe tu reseña',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Tu calificación',
              style: TextStyle(color: hintColor, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _calificacion = index + 1.0;
                    });
                  },
                  child: Icon(
                    index < _calificacion
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: _kGold,
                    size: 40,
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            Text(
              'Tu opinión (opcional)',
              style: TextStyle(color: hintColor, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _comentarioController,
              maxLines: 3,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: '¿Qué te pareció este producto?',
                hintStyle: TextStyle(color: hintColor),
                filled: true,
                fillColor: surfaceInputColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _kGold),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onSubmit(_calificacion, _comentarioController.text);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kGold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Enviar reseña',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

void showProductoValoracionDialog(
  BuildContext context, {
  required void Function(double calificacion, String comentario) onSubmit,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return ProductoValoracionDialog(onSubmit: onSubmit);
    },
  );
}
