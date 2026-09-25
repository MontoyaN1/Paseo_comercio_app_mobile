// lib/presentation/widgets/organizacion/organizacion_components.dart
//
// 🏛️ COMPONENTES AUXILIARES - USA Theme.of(context)
// ────────────────────────────────────────────────────────────

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

const _kGold = Color(0xFFD4AF37);

class OrganizacionIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const OrganizacionIconButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  State<OrganizacionIconButton> createState() => _OrganizacionIconButtonState();
}

class _OrganizacionIconButtonState extends State<OrganizacionIconButton>
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      isDark
                          ? _kGold.withOpacity(0.07)
                          : theme.colorScheme.primary.withOpacity(0.10),
                  border: Border.all(
                    color:
                        isDark
                            ? _kGold.withOpacity(0.28)
                            : theme.colorScheme.primary.withOpacity(0.30),
                    width: 1,
                  ),
                ),
                child: Icon(
                  widget.icon,
                  color: isDark ? _kGold : theme.colorScheme.primary,
                  size: 20,
                ),
              ),
            ),
      ),
    );
  }
}

class OrganizacionOutlineButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const OrganizacionOutlineButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  State<OrganizacionOutlineButton> createState() =>
      _OrganizacionOutlineButtonState();
}

class _OrganizacionOutlineButtonState extends State<OrganizacionOutlineButton>
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
      end: 0.95,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  horizontal: 28,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _kGold.withOpacity(0.55),
                    width: 1.5,
                  ),
                  color: _kGold.withOpacity(0.06),
                ),
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    color: _kGold,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
      ),
    );
  }
}

class OrganizacionLoader extends StatelessWidget {
  const OrganizacionLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SizedBox(
        width: 36,
        height: 36,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(
            theme.brightness == Brightness.dark
                ? _kGold
                : theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

class OrganizacionHeroStatPill extends StatelessWidget {
  final IconData icon;
  final String value;

  const OrganizacionHeroStatPill({
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
                    ? Colors.black.withOpacity(0.40)
                    : Colors.white.withOpacity(0.70),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _kGold.withOpacity(0.30), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: _kGold, size: 13),
              const SizedBox(width: 5),
              Text(
                value,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
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

class OrganizacionGoldInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const OrganizacionGoldInfoRow({
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

class OrganizacionGoldDivider extends StatelessWidget {
  const OrganizacionGoldDivider({super.key});

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

class OrganizacionStatCard extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;

  const OrganizacionStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF12121F) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E1E3A) : Colors.grey.shade300;
    final hintColor = isDark ? const Color(0xFF6B6B8A) : Colors.grey.shade600;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          decoration: BoxDecoration(
            color: surfaceColor.withOpacity(0.90),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: _kGold.withOpacity(0.06),
                blurRadius: 16,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kGold.withOpacity(0.10),
                  border: Border.all(color: _kGold.withOpacity(0.28), width: 1),
                ),
                child: Icon(icon, color: _kGold, size: 18),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback:
                        (b) => const LinearGradient(
                          colors: [_kGold, Color(0xFFFFE082)],
                        ).createShader(b),
                    child: Text(
                      value.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      color: hintColor,
                      fontSize: 12,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
