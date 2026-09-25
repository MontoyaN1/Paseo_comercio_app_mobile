// lib/presentation/widgets/producto/producto_valoraciones_tab.dart
//
// 🏛️ VALORACIONES TAB - Producto Detail
// ────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const _kGold = Color(0xFFD4AF37);
const _kHint = Color(0xFF6B6B8A);
const _kSurfaceCard = Color(0xFF12121F);
const _kBorder = Color(0xFF1E1E3A);

class ProductoValoracionesTab extends StatefulWidget {
  final List<Map<String, dynamic>> valoraciones;
  final bool isLoading;
  final VoidCallback? onLoad;
  final VoidCallback? onAddValoracion;

  const ProductoValoracionesTab({
    super.key,
    required this.valoraciones,
    this.isLoading = false,
    this.onLoad,
    this.onAddValoracion,
  });

  @override
  State<ProductoValoracionesTab> createState() =>
      _ProductoValoracionesTabState();
}

class _ProductoValoracionesTabState extends State<ProductoValoracionesTab> {
  @override
  void initState() {
    super.initState();
    if (widget.isLoading && widget.onLoad != null) {
      widget.onLoad!();
    }
  }

  @override
  void didUpdateWidget(ProductoValoracionesTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading && widget.onLoad != null) {
      widget.onLoad!();
    }
  }

  double get _calificacionPromedio {
    if (widget.valoraciones.isEmpty) return 0;
    final suma = widget.valoraciones.fold<double>(
      0,
      (sum, v) => sum + ((v['calificacion'] as num?)?.toDouble() ?? 0),
    );
    return suma / widget.valoraciones.length;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return Center(child: CircularProgressIndicator(color: _kGold));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context: context),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: widget.onAddValoracion,
              icon: const Icon(Icons.rate_review),
              label: const Text('Escribir una reseña'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kGold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (widget.valoraciones.isEmpty)
            _buildEmptyState(context: context)
          else
            ...widget.valoraciones.map((v) => _ValoracionCard(valoracion: v)),
        ],
      ),
    );
  }

  Widget _buildHeader({required BuildContext context}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg =
        isDark
            ? _kSurfaceCard.withValues(alpha: 0.6)
            : Colors.white.withValues(alpha: 0.9);
    final cardBorder = isDark ? _kBorder : Colors.grey.shade300;
    final hintColor = isDark ? _kHint : Colors.grey.shade600;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                _calificacionPromedio.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: _kGold,
                ),
              ),
              ...List.generate(5, (index) {
                return Icon(
                  index < _calificacionPromedio.round()
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: _kGold,
                  size: 16,
                );
              }),
              const SizedBox(height: 4),
              Text(
                '${widget.valoraciones.length} reseñas',
                style: TextStyle(color: hintColor, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              children: List.generate(5, (estrella) {
                final count =
                    widget.valoraciones
                        .where(
                          (v) =>
                              (v['calificacion'] as num?)?.round() == estrella,
                        )
                        .length;
                final total =
                    widget.valoraciones.isEmpty
                        ? 1
                        : widget.valoraciones.length;
                final percentage = count / total;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        '$estrella',
                        style: TextStyle(color: hintColor, fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.star_rounded, color: _kGold, size: 12),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage,
                            backgroundColor: cardBorder,
                            valueColor: const AlwaysStoppedAnimation(_kGold),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$count',
                        style: TextStyle(color: hintColor, fontSize: 12),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({required BuildContext context}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hintColor = isDark ? _kHint : Colors.grey.shade600;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review_outlined, size: 64, color: hintColor),
            const SizedBox(height: 16),
            Text(
              'Sin reseñas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sé el primero en dar tu opinión\nsobre este producto',
              style: TextStyle(color: hintColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ValoracionCard extends StatelessWidget {
  final Map<String, dynamic> valoracion;

  const _ValoracionCard({required this.valoracion});

  String _formatFecha(String fechaStr) {
    try {
      final fecha = DateTime.parse(fechaStr);
      final now = DateTime.now();
      final diferencia = now.difference(fecha);

      if (diferencia.inDays == 0) return 'hoy';
      if (diferencia.inDays == 1) return 'ayer';
      if (diferencia.inDays < 7) return 'hace ${diferencia.inDays} días';
      if (diferencia.inDays < 30)
        return 'hace ${(diferencia.inDays / 7).floor()} semanas';
      if (diferencia.inDays < 365)
        return 'hace ${(diferencia.inDays / 30).floor()} meses';
      return DateFormat('dd MMM yyyy').format(fecha);
    } catch (e) {
      return fechaStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? _kSurfaceCard : Colors.white;
    final cardBorder = isDark ? _kBorder : Colors.grey.shade300;
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? _kHint : Colors.grey.shade600;

    final calificacion = (valoracion['calificacion'] as num?)?.toInt() ?? 0;
    final comentario = valoracion['comentario'] as String?;
    final fecha = valoracion['fecha_creacion'] as String?;
    final usuario = valoracion['usuario'] as Map<String, dynamic>?;
    final nombreUsuario = usuario?['nombre_completo'] as String? ?? 'Anónimo';
    final avatarUrl = usuario?['avatar_url'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: _kGold.withValues(alpha: 0.2),
                backgroundImage:
                    (avatarUrl != null && avatarUrl.isNotEmpty)
                        ? NetworkImage(avatarUrl)
                        : null,
                child:
                    (avatarUrl == null || avatarUrl.isEmpty)
                        ? Text(
                          nombreUsuario.isNotEmpty
                              ? nombreUsuario[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            color: _kGold,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        )
                        : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  nombreUsuario,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < calificacion
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: _kGold,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          if (fecha != null) ...[
            const SizedBox(height: 8),
            Text(
              _formatFecha(fecha),
              style: TextStyle(color: hintColor, fontSize: 12),
            ),
          ],
          if (comentario != null && comentario.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              comentario,
              style: TextStyle(
                color: hintColor.withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
