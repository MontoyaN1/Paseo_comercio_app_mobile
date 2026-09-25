// lib/presentation/widgets/share_button.dart

import 'package:flutter/material.dart';

import '../../../core/utils/share_service.dart';
import '../../../di/service_locator.dart';

// ── Paleta (idéntica al sistema de diseño) ────────────────────
const Color _kGold = Color(0xFFD4AF37);

// ══════════════════════════════════════════════════════════════
//  BOTÓN COMPARTIR
// ══════════════════════════════════════════════════════════════
class ShareButton extends StatefulWidget {
  final int id;
  final String tipo; // 'tienda', 'producto', 'plazoleta', 'organizacion'
  final String nombre;
  final String? descripcion;
  final double? precio;
  final String? slug; // solo para plazoletas

  const ShareButton({
    super.key,
    required this.id,
    required this.tipo,
    required this.nombre,
    this.descripcion,
    this.precio,
    this.slug,
  });

  @override
  State<ShareButton> createState() => _ShareButtonState();
}

class _ShareButtonState extends State<ShareButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.88,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _onShare() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final shareService = getIt<ShareService>();

      switch (widget.tipo) {
        case 'tienda':
          await shareService.compartirTienda(
            tiendaId: widget.id,
            nombreTienda: widget.nombre,
            descripcion: widget.descripcion,
          );
          break;
        case 'producto':
          await shareService.compartirProducto(
            productoId: widget.id,
            nombreProducto: widget.nombre,
            descripcion: widget.descripcion,
            precio: widget.precio,
          );
          break;
        case 'plazoleta':
          await shareService.compartirPlazoleta(
            slug: widget.slug ?? widget.id.toString(),
            nombrePlazoleta: widget.nombre,
            descripcion: widget.descripcion,
          );
          break;
        case 'organizacion':
          await shareService.compartirOrganizacion(
            organizacionId: widget.id,
            nombreOrganizacion: widget.nombre,
            descripcion: widget.descripcion,
          );
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al compartir: $e'),
            backgroundColor: const Color(0xFF1A0808),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.red.withOpacity(0.35)),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        _onShare();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder:
            (_, __) => Transform.scale(
              scale: _scale.value,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kGold.withOpacity(0.07),
                  border: Border.all(color: _kGold.withOpacity(0.28), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: _kGold.withOpacity(0.08),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child:
                    _isLoading
                        ? const Padding(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(_kGold),
                          ),
                        )
                        : const Icon(
                          Icons.ios_share_rounded,
                          color: _kGold,
                          size: 20,
                        ),
              ),
            ),
      ),
    );
  }
}
