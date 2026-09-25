// lib/presentation/widgets/tienda/tienda_components.dart
//
// 🏛️ COMPONENTES DE TIENDA - USA Theme.of(context)
// ────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:paseo_del_comercio/core/utils/phone_utils.dart';

const _kGold = Color(0xFFD4AF37);

class TiendaHeroStatPill extends StatelessWidget {
  final IconData icon;
  final String value;

  const TiendaHeroStatPill({
    super.key,
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark
            ? const Color(0xFF0F0F1E).withValues(alpha: 0.85)
            : Colors.white.withValues(alpha: 0.90);
    final borderColor = isDark ? const Color(0xFF1E1E3A) : Colors.grey.shade300;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _kGold),
          const SizedBox(width: 5),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class TiendaGoldStatCard extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;

  const TiendaGoldStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? const Color(0xFF6B6B8A) : Colors.grey.shade600;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _kGold.withValues(alpha: 0.12),
            isDark ? const Color(0xFF12121F) : Colors.grey.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kGold.withValues(alpha: 0.30), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: _kGold, size: 24),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: TextStyle(
              color: textColor,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: hintColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class TiendaGoldInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Widget? valueWidget;
  final Widget? trailing;

  const TiendaGoldInfoRow({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.valueWidget,
    this.trailing,
  }) : assert(value != null || valueWidget != null);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? const Color(0xFF6B6B8A) : Colors.grey.shade600;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _kGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: _kGold),
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
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                valueWidget ??
                    Text(
                      value ?? '',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}

class TiendaPhoneInfo extends StatelessWidget {
  final String phoneNumber;

  const TiendaPhoneInfo({super.key, required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    final countryCode = extractCountryCode(phoneNumber);
    final phoneWithoutCode = extractPhoneWithoutCode(phoneNumber);
    final flag =
        countryCode != null ? getFlagForCountryCode(countryCode) : null;

    if (flag != null && countryCode != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(flag, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Text(countryCode, style: TextStyle(color: textColor, fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            phoneWithoutCode,
            style: TextStyle(color: textColor, fontSize: 14),
          ),
        ],
      );
    }
    return Text(phoneNumber, style: TextStyle(color: textColor, fontSize: 14));
  }
}

class TiendaGoldDivider extends StatelessWidget {
  const TiendaGoldDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? const Color(0xFF1E1E3A) : Colors.grey.shade300;

    return Divider(color: color.withValues(alpha: 0.6), height: 1);
  }
}

class TiendaIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const TiendaIconButton({super.key, required this.icon, required this.onTap});

  @override
  State<TiendaIconButton> createState() => _TiendaIconButtonState();
}

class _TiendaIconButtonState extends State<TiendaIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark
            ? const Color(0xFF0F0F1E).withValues(alpha: 0.80)
            : Colors.white.withValues(alpha: 0.80);
    final borderColor = isDark ? const Color(0xFF1E1E3A) : Colors.grey.shade300;

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.92),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: surfaceColor,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor),
          ),
          child: Icon(widget.icon, size: 20, color: _kGold),
        ),
      ),
    );
  }
}

class TiendaActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const TiendaActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<TiendaActionButton> createState() => _TiendaActionButtonState();
}

class _TiendaActionButtonState extends State<TiendaActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: _kGold.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _kGold.withValues(alpha: 0.40)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 18, color: _kGold),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: const TextStyle(
                  color: _kGold,
                  fontSize: 14,
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

class TiendaOutlineButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const TiendaOutlineButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  State<TiendaOutlineButton> createState() => _TiendaOutlineButtonState();
}

class _TiendaOutlineButtonState extends State<TiendaOutlineButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _kGold.withValues(alpha: 0.50)),
          ),
          child: Text(
            widget.label,
            style: const TextStyle(
              color: _kGold,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
