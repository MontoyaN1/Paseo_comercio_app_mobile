// lib/presentation/widgets/profile/profile_components.dart
//
// 🏛️ COMPONENTES DE PERFIL - USA Theme.of(context)
// GlassSection, GoldInfoRow, ActionTile, SectionDivider, GoldIconButton
// ────────────────────────────────────────────────────────────

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:paseo_del_comercio/core/utils/phone_utils.dart';
import 'profile_buttons.dart';

const _kGold = Color(0xFFD4AF37);

class ProfileGlassSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const ProfileGlassSection({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? _kGold : theme.colorScheme.primary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.90),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: theme.colorScheme.surfaceContainerHighest,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accentColor.withOpacity(0.10),
                        border: Border.all(
                          color: accentColor.withOpacity(0.28),
                          width: 1,
                        ),
                      ),
                      child: Icon(icon, color: accentColor, size: 15),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: TextStyle(
                        color:
                            isDark ? Colors.white : theme.colorScheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accentColor.withOpacity(0.35), Colors.transparent],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  ESTADO SIN SESIÓN
// ══════════════════════════════════════════════════════════════
class ProfileSignedOutContent extends StatelessWidget {
  final VoidCallback onSignIn;
  final VoidCallback onContinueAsGuest;

  const ProfileSignedOutContent({
    super.key,
    required this.onSignIn,
    required this.onContinueAsGuest,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const kGold = Color(0xFFD4AF37);
    const kGoldLight = Color(0xFFFFE082);
    const kGoldDeep = Color(0xFF9C7A1A);
    final kHint = isDark ? const Color(0xFF6B6B8A) : Colors.grey.shade600;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kGold.withValues(alpha: 0.10),
                border: Border.all(
                  color: kGold.withValues(alpha: 0.35),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: kGold.withValues(alpha: 0.15),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                size: 44,
                color: kGold,
              ),
            ),
            const SizedBox(height: 24),
            ShaderMask(
              shaderCallback:
                  (b) => const LinearGradient(
                    colors: [kGoldDeep, kGold, kGoldLight],
                  ).createShader(b),
              child: Text(
                'Inicia sesión',
                style: TextStyle(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Accede a tus favoritos, historial\ny configuración personal',
              style: TextStyle(color: kHint, fontSize: 14, height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ProfileShimmerButton(label: 'INICIAR SESIÓN', onTap: onSignIn),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: onContinueAsGuest,
              child: Text(
                'Continuar como invitado',
                style: TextStyle(
                  color: kGold.withValues(alpha: 0.80),
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                  decorationColor: kGold.withValues(alpha: 0.40),
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileGoldInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ProfileGoldInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? _kGold : theme.colorScheme.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accentColor.withOpacity(0.08),
          ),
          child: Icon(icon, color: accentColor.withOpacity(0.80), size: 17),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: TextStyle(
                  color: isDark ? Colors.white : theme.colorScheme.onSurface,
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

class ProfileActionTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ProfileActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<ProfileActionTile> createState() => _ProfileActionTileState();
}

class _ProfileActionTileState extends State<ProfileActionTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.97,
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
    final accentColor = isDark ? _kGold : theme.colorScheme.primary;

    return GestureDetector(
      onTapDown: (_) {
        _ctrl.forward();
        setState(() => _pressed = true);
      },
      onTapUp: (_) {
        _ctrl.reverse();
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () {
        _ctrl.reverse();
        setState(() => _pressed = false);
      },
      child: AnimatedBuilder(
        animation: _scale,
        builder:
            (_, __) => Transform.scale(
              scale: _scale.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 130),
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 2,
                ),
                decoration: BoxDecoration(
                  color:
                      _pressed
                          ? accentColor.withOpacity(0.04)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accentColor.withOpacity(0.08),
                        border: Border.all(
                          color: accentColor.withOpacity(
                            _pressed ? 0.40 : 0.18,
                          ),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        widget.icon,
                        color:
                            _pressed
                                ? accentColor
                                : accentColor.withOpacity(0.70),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              color:
                                  isDark
                                      ? Colors.white
                                      : theme.colorScheme.onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle,
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color:
                          _pressed
                              ? accentColor
                              : accentColor.withOpacity(0.40),
                      size: 13,
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }
}

class ProfileSectionDivider extends StatelessWidget {
  const ProfileSectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            theme.colorScheme.surfaceContainerHighest,
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

class ProfileIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const ProfileIconButton({super.key, required this.icon, required this.onTap});

  @override
  State<ProfileIconButton> createState() => _ProfileIconButtonState();
}

class _ProfileIconButtonState extends State<ProfileIconButton>
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
    final accentColor = isDark ? _kGold : theme.colorScheme.primary;

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
                  color: accentColor.withOpacity(0.07),
                  border: Border.all(
                    color: accentColor.withOpacity(0.28),
                    width: 1,
                  ),
                ),
                child: Icon(widget.icon, color: accentColor, size: 18),
              ),
            ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  INFO ROW DE TELÉFONO
// ══════════════════════════════════════════════════════════════
class ProfilePhoneInfoRow extends StatelessWidget {
  final String phoneNumber;

  const ProfilePhoneInfoRow({super.key, required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const kGold = Color(0xFFD4AF37);
    final kHint = isDark ? const Color(0xFF6B6B8A) : const Color(0xFF6B6B8A);

    final countryCode = extractCountryCode(phoneNumber);
    final phoneWithoutCode = extractPhoneWithoutCode(phoneNumber);
    final countryFlag =
        countryCode != null ? getFlagForCountryCode(countryCode) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.phone_outlined, color: kGold, size: 20),
            const SizedBox(width: 12),
            Text('Teléfono', style: TextStyle(color: kHint, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 8),
        if (phoneNumber == 'No disponible')
          Text(
            'No disponible',
            style: TextStyle(
              color:
                  isDark
                      ? Colors.white.withValues(alpha: 0.7)
                      : Colors.black.withValues(alpha: 0.7),
              fontSize: 16,
            ),
          )
        else
          Row(
            children: [
              if (countryCode != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: kGold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: kGold.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (countryFlag != null) ...[
                        Text(countryFlag, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        countryCode,
                        style: const TextStyle(
                          color: kGold,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              if (countryCode != null) const SizedBox(width: 8),
              Expanded(
                child: Text(
                  phoneWithoutCode,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
