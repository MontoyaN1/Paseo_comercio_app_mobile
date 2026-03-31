// lib/presentation/pages/settings/settings_page.dart

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../di/service_locator.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../../core/app/app_config.dart';
import '../../providers/theme_provider.dart';

// ── Paleta (idéntica al sistema de diseño) ────────────────────
const Color _kGold = Color(0xFFD4AF37);
const Color _kGoldLight = Color(0xFFFFE082);
const Color _kGoldDeep = Color(0xFF9C7A1A);
const Color _kBg = Color(0xFF07070F);
const Color _kSurface = Color(0xFF0F0F1E);
const Color _kSurfaceCard = Color(0xFF12121F);
const Color _kBorder = Color(0xFF1E1E3A);
const Color _kHint = Color(0xFF6B6B8A);

// ══════════════════════════════════════════════════════════════
//  PÁGINA DE CONFIGURACIÓN
// ══════════════════════════════════════════════════════════════
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                    children: [
                      const SizedBox(height: 20),
                      _buildPreferencesSection(context),
                      const SizedBox(height: 16),
                      _buildAboutSection(context),
                      const SizedBox(height: 16),
                      _buildAccountSection(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── AppBar glassmorphism ──────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: kToolbarHeight,
          decoration: BoxDecoration(
            color: _kSurface.withOpacity(0.82),
            border: Border(bottom: BorderSide(color: _kBorder, width: 1)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _GoldIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () {
                  try {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      Future.microtask(() => context.go('/plazoletas'));
                    }
                  } catch (e) {
                    Future.microtask(() => context.go('/'));
                  }
                },
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ShaderMask(
                  shaderCallback:
                      (b) => const LinearGradient(
                        colors: [_kGoldDeep, _kGold, _kGoldLight],
                      ).createShader(b),
                  child: const Text(
                    'Configuración',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 38),
            ],
          ),
        ),
      ),
    );
  }

  // ── Sección de Preferencias ──────────────────────────────
  Widget _buildPreferencesSection(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return _GlassSection(
          title: 'Preferencias',
          icon: Icons.tune_rounded,
          child: Column(
            children: [
              _SettingsTile(
                icon: Icons.dark_mode_outlined,
                title: 'Tema oscuro',
                subtitle: themeProvider.isDarkMode ? 'Activado' : 'Desactivado',
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (_) => themeProvider.toggleTheme(),
                  activeColor: _kGold,
                  inactiveThumbColor: _kHint,
                  inactiveTrackColor: _kBorder,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Sección de Acerca ─────────────────────────────────────
  Widget _buildAboutSection(BuildContext context) {
    final appConfig = AppConfig();
    return _GlassSection(
      title: 'Acerca de',
      icon: Icons.info_outline_rounded,
      child: Column(
        children: [
          _SettingsTile(
            icon: Icons.business_rounded,
            title: appConfig.companyName,
            subtitle: 'Versión ${appConfig.appVersion}',
            trailing: const Icon(
              Icons.arrow_forward_ios_rounded,
              color: _kHint,
              size: 14,
            ),
            onTap: () => context.push('/soporte'),
          ),
          const _SectionDivider(),
          _SettingsTile(
            icon: Icons.description_outlined,
            title: 'Términos y condiciones',
            subtitle: 'Lee nuestros términos',
            trailing: const Icon(
              Icons.arrow_forward_ios_rounded,
              color: _kHint,
              size: 14,
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Términos en desarrollo'),
                  backgroundColor: _kSurface,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: _kBorder),
                  ),
                ),
              );
            },
          ),
          const _SectionDivider(),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Política de privacidad',
            subtitle: 'Cómo protegemos tus datos',
            trailing: const Icon(
              Icons.arrow_forward_ios_rounded,
              color: _kHint,
              size: 14,
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Política de privacidad en desarrollo'),
                  backgroundColor: _kSurface,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: _kBorder),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Sección de Cuenta ─────────────────────────────────────
  Widget _buildAccountSection(BuildContext context) {
    return _GlassSection(
      title: 'Cuenta',
      icon: Icons.account_circle_outlined,
      child: _SettingsTile(
        icon: Icons.logout_rounded,
        title: 'Cerrar sesión',
        subtitle: 'Salir de tu cuenta',
        isDestructive: true,
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.red,
          size: 14,
        ),
        onTap: () => _showLogoutConfirmation(context),
      ),
    );
  }

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _LogoutDialog(),
    );
    if (result == true) {
      if (!context.mounted) return;
      await _performLogout(context);
    }
  }

  Future<void> _performLogout(BuildContext context) async {
    final authBloc = getIt<AuthBloc>();
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        builder:
            (_) => Container(
              color: Colors.black.withOpacity(0.55),
              child: const Center(
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(_kGold),
                  ),
                ),
              ),
            ),
      );

      authBloc.add(const AuthSignOutRequested());

      await for (final state in authBloc.stream) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context, rootNavigator: true).pop();
          await Future.delayed(const Duration(milliseconds: 300));
          if (context.mounted) {
            context.push('/login');
          }
          break;
        } else if (state is AuthError) {
          Navigator.of(context, rootNavigator: true).pop();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color(0xFF1A0808),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.red.withOpacity(0.35)),
                ),
                content: Text(
                  'Error al cerrar sesión: ${state.message}',
                  style: TextStyle(color: Colors.red[200], fontSize: 13),
                ),
              ),
            );
          }
          break;
        }
      }
    } catch (error) {
      Navigator.of(context, rootNavigator: true).pop();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1A0808),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.red.withOpacity(0.35)),
            ),
            content: Text(
              'Error inesperado: $error',
              style: TextStyle(color: Colors.red[200], fontSize: 13),
            ),
          ),
        );
      }
    }
  }
}

// ══════════════════════════════════════════════════════════════
//  WIDGETS AUXILIARES
// ══════════════════════════════════════════════════════════════

class _GlassSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _GlassSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            color: _kSurfaceCard.withOpacity(0.90),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _kBorder, width: 1),
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
                        color: _kGold.withOpacity(0.10),
                        border: Border.all(
                          color: _kGold.withOpacity(0.28),
                          width: 1,
                        ),
                      ),
                      child: Icon(icon, color: _kGold, size: 15),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
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
                    colors: [_kGold.withOpacity(0.35), Colors.transparent],
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

class _SettingsTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  State<_SettingsTile> createState() => _SettingsTileState();
}

class _SettingsTileState extends State<_SettingsTile>
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
    final iconColor = widget.isDestructive ? Colors.red[300]! : _kGold;
    final textColor = widget.isDestructive ? Colors.red[300]! : Colors.white;

    return GestureDetector(
      onTapDown: (_) {
        _ctrl.forward();
        setState(() => _pressed = true);
      },
      onTapUp: (_) {
        _ctrl.reverse();
        setState(() => _pressed = false);
        widget.onTap?.call();
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
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color:
                      _pressed
                          ? (widget.isDestructive
                              ? Colors.red.withOpacity(0.05)
                              : _kGold.withOpacity(0.05))
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: iconColor.withOpacity(0.10),
                        border: Border.all(
                          color: iconColor.withOpacity(_pressed ? 0.38 : 0.18),
                          width: 1,
                        ),
                      ),
                      child: Icon(widget.icon, color: iconColor, size: 18),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle,
                            style: TextStyle(
                              color:
                                  widget.isDestructive
                                      ? Colors.red[200]?.withOpacity(0.70)
                                      : _kHint,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.trailing != null) widget.trailing!,
                  ],
                ),
              ),
            ),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            _kBorder.withOpacity(0.5),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  BOTÓN ÍCONO DORADO
// ══════════════════════════════════════════════════════════════
class _GoldIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GoldIconButton({required this.icon, required this.onTap});

  @override
  State<_GoldIconButton> createState() => _GoldIconButtonState();
}

class _GoldIconButtonState extends State<_GoldIconButton>
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
                  color: _kGold.withOpacity(0.07),
                  border: Border.all(color: _kGold.withOpacity(0.28), width: 1),
                ),
                child: Icon(widget.icon, color: _kGold, size: 18),
              ),
            ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  DIÁLOGO DE CONFIRMACIÓN LOGOUT
// ══════════════════════════════════════════════════════════════
class _LogoutDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: _kSurface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: _kBorder, width: 1),
      ),
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withOpacity(0.10),
              border: Border.all(color: Colors.red.withOpacity(0.30), width: 1),
            ),
            child: Icon(Icons.logout_rounded, color: Colors.red[300], size: 16),
          ),
          const SizedBox(width: 12),
          const Text(
            'Cerrar sesión',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      content: const Text(
        '¿Estás seguro de que quieres cerrar sesión?',
        style: TextStyle(color: _kHint, fontSize: 14, height: 1.5),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: _kHint, fontWeight: FontWeight.w500),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            'Cerrar sesión',
            style: TextStyle(
              color: Colors.red[300],
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
