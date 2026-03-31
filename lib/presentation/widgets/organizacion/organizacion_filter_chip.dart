// lib/presentation/widgets/organizacion/organizacion_filter_chip.dart
//
// 🏛️ CHIP DE FILTRO DORADO - USA Theme.of(context)
// ────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

const _kGold = Color(0xFFD4AF37);

class OrganizacionFilterChip extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final String? emoji;

  const OrganizacionFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.emoji,
  });

  @override
  State<OrganizacionFilterChip> createState() => _OrganizacionFilterChipState();
}

class _OrganizacionFilterChipState extends State<OrganizacionFilterChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: widget.selected ? 1.0 : 0.0,
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void didUpdateWidget(OrganizacionFilterChip old) {
    super.didUpdateWidget(old);
    if (widget.selected != old.selected) {
      widget.selected ? _ctrl.forward() : _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? _kGold : theme.colorScheme.primary;
    final accentGlow =
        isDark
            ? _kGold.withOpacity(0.14)
            : theme.colorScheme.primary.withOpacity(0.12);

    return GestureDetector(
      onTap: widget.onSelected,
      child: AnimatedBuilder(
        animation: _anim,
        builder:
            (_, __) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Color.lerp(
                  isDark
                      ? Colors.black.withOpacity(0.3)
                      : theme.colorScheme.surfaceContainerHighest.withOpacity(
                        0.6,
                      ),
                  accentGlow,
                  _anim.value,
                ),
                border: Border.all(
                  color:
                      Color.lerp(
                        isDark
                            ? theme.colorScheme.surfaceContainerHighest
                            : theme.colorScheme.outline,
                        accentColor.withOpacity(0.70),
                        _anim.value,
                      )!,
                  width: 1.0 + _anim.value * 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.15 * _anim.value),
                    blurRadius: 8 * _anim.value,
                    spreadRadius: _anim.value,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.emoji != null) ...[
                    Text(widget.emoji!, style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 5),
                  ],
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: Color.lerp(
                        isDark
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.onSurface,
                        accentColor,
                        _anim.value,
                      ),
                      fontSize: 13,
                      fontWeight:
                          widget.selected ? FontWeight.w700 : FontWeight.w400,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}
