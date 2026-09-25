// lib/presentation/widgets/plazoleta/plazoleta_components.dart
//
// 🏛️ PLAZA UNIVERSE — Plazoleta Shared Components
// ────────────────────────────────────────────────────────────
//  COMPONENTES COMPARTIDOS - USA TEMA
//  Stat pills, info rows, dividers, botones
// ────────────────────────────────────────────────────────────

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

// ── Paleta branding ─────────────────────────────────────────
const _kGold = Color(0xFFD4AF37);

// ══════════════════════════════════════════════════════════════
//  PÍLDORA DE STAT EN EL HERO
// ══════════════════════════════════════════════════════════════
class PlazoletaHeroStatPill extends StatelessWidget {
  final IconData icon;
  final String value;

  const PlazoletaHeroStatPill({
    super.key,
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color:
                isDark
                    ? Colors.black.withOpacity(0.50)
                    : Colors.white.withOpacity(0.80),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _kGold.withOpacity(0.40), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: _kGold, size: 14),
              const SizedBox(width: 5),
              Text(
                value,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  FILA DE INFORMACIÓN CON ÍCONO DORADO
// ══════════════════════════════════════════════════════════════
class PlazoletaGoldInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const PlazoletaGoldInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hintColor = isDark ? const Color(0xFF6B6B8A) : Colors.grey.shade600;
    final textColor = isDark ? Colors.white : Colors.black;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _kGold.withOpacity(0.08),
          ),
          child: Icon(icon, color: _kGold.withOpacity(0.80), size: 17),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: hintColor,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  DIVISOR GRADIENTE DORADO
// ══════════════════════════════════════════════════════════════
class PlazoletaGoldDivider extends StatelessWidget {
  const PlazoletaGoldDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? const Color(0xFF1E1E3A) : Colors.grey.shade300;

    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, borderColor, Colors.transparent],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  BOTÓN ÍCONO DORADO
// ══════════════════════════════════════════════════════════════
class PlazoletaIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const PlazoletaIconButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  State<PlazoletaIconButton> createState() => _PlazoletaIconButtonState();
}

class _PlazoletaIconButtonState extends State<PlazoletaIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder:
            (_, __) => Transform.scale(
              scale: _scale.value,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      isDark
                          ? _kGold.withOpacity(0.15)
                          : _kGold.withOpacity(0.12),
                  border: Border.all(
                    color:
                        isDark
                            ? _kGold.withOpacity(0.50)
                            : _kGold.withOpacity(0.40),
                    width: 1,
                  ),
                ),
                child: Icon(
                  widget.icon,
                  color: isDark ? _kGold : _kGold,
                  size: 20,
                ),
              ),
            ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  BOTÓN OUTLINE DORADO
// ══════════════════════════════════════════════════════════════
class PlazoletaOutlineButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const PlazoletaOutlineButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  State<PlazoletaOutlineButton> createState() => _PlazoletaOutlineButtonState();
}

class _PlazoletaOutlineButtonState extends State<PlazoletaOutlineButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.94,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder:
            (_, __) => Transform.scale(
              scale: _scale.value,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? _kGold.withOpacity(0.12)
                          : _kGold.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color:
                        isDark
                            ? _kGold.withOpacity(0.60)
                            : _kGold.withOpacity(0.50),
                    width: 1,
                  ),
                ),
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    color: _kGold,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
      ),
    );
  }
}
