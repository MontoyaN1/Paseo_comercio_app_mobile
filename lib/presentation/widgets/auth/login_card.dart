// lib/presentation/widgets/auth/login_card.dart
//
// 🏛️ CARD DE LOGIN SOCIAL - USA Theme.of(context)
// ────────────────────────────────────────────────────────────

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

const _kGold = Color(0xFFD4AF37);

class LoginCard extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onGoogle;
  final VoidCallback onMicrosoft;

  const LoginCard({
    super.key,
    required this.isLoading,
    this.errorMessage,
    required this.onGoogle,
    required this.onMicrosoft,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? _kGold : theme.colorScheme.primary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.88),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.colorScheme.surfaceContainerHighest,
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.55 : 0.15),
                blurRadius: 40,
                spreadRadius: 4,
              ),
              BoxShadow(
                color: accentColor.withOpacity(isDark ? 0.06 : 0.08),
                blurRadius: 60,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child:
                    errorMessage != null
                        ? Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.error.withOpacity(0.25),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                color: theme.colorScheme.error,
                                size: 16,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  errorMessage!,
                                  style: TextStyle(
                                    color: theme.colorScheme.error,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                        : const SizedBox.shrink(),
              ),
              Text(
                'Bienvenido',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Selecciona un método para continuar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 13,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 28),
              LoginSocialButton(
                isLoading: isLoading,
                onTap: onGoogle,
                icon: Icons.g_mobiledata_rounded,
                label: 'Google',
              ),
              const SizedBox(height: 14),
              LoginMicrosoftButton(isLoading: isLoading, onTap: onMicrosoft),
              const SizedBox(height: 20),
              Text(
                'Al continuar, aceptas nuestros\nTérminos y Condiciones',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                  fontSize: 11,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginSocialButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onTap;
  final IconData icon;
  final IconData? iconFallback;
  final String label;

  const LoginSocialButton({
    super.key,
    required this.isLoading,
    required this.onTap,
    required this.icon,
    this.iconFallback,
    required this.label,
  });

  @override
  State<LoginSocialButton> createState() => _LoginSocialButtonState();
}

class _LoginSocialButtonState extends State<LoginSocialButton>
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? _kGold : theme.colorScheme.primary;

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        if (!widget.isLoading) widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder:
            (_, __) => Transform.scale(
              scale: _scale.value,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? const Color(0xFF0E0E1E)
                          : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: accentColor.withOpacity(0.3 + (_ctrl.value * 0.4)),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(
                        0.08 + (_ctrl.value * 0.12),
                      ),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.isLoading)
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(accentColor),
                        ),
                      )
                    else
                      Icon(
                        Icons.g_mobiledata_rounded,
                        color: accentColor,
                        size: 24,
                      ),
                    const SizedBox(width: 14),
                    Text(
                      widget.label,
                      style: TextStyle(
                        color:
                            isDark
                                ? Colors.white70
                                : theme.colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }
}

class LoginMicrosoftButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const LoginMicrosoftButton({
    super.key,
    required this.isLoading,
    required this.onTap,
  });

  @override
  State<LoginMicrosoftButton> createState() => _LoginMicrosoftButtonState();
}

class _LoginMicrosoftButtonState extends State<LoginMicrosoftButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
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
        animation: _ctrl,
        builder:
            (_, __) => Transform.scale(
              scale: _scale.value,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? const Color(0xFF0E0E1E)
                          : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: accentColor.withOpacity(0.3 + (_ctrl.value * 0.4)),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(
                        0.08 + (_ctrl.value * 0.12),
                      ),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.isLoading)
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(accentColor),
                        ),
                      )
                    else
                      Icon(Icons.window_rounded, color: accentColor, size: 24),
                    const SizedBox(width: 14),
                    Text(
                      'Microsoft',
                      style: TextStyle(
                        color:
                            isDark
                                ? Colors.white.withOpacity(0.9)
                                : theme.colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }
}

class LoginLoader extends StatelessWidget {
  const LoginLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? _kGold : theme.colorScheme.primary;

    return Container(
      color: theme.colorScheme.surface,
      child: Center(
        child: SizedBox(
          width: 44,
          height: 44,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(accentColor),
          ),
        ),
      ),
    );
  }
}
