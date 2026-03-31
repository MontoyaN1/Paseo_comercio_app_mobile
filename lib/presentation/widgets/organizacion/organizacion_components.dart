// lib/presentation/widgets/organizacion/organizacion_components.dart
//
// 🏛️ COMPONENTES AUXILIARES - USA Theme.of(context)
// ────────────────────────────────────────────────────────────

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
