// lib/presentation/widgets/profile_floating_button.dart
//
// 🏛️  PLAZA UNIVERSE — Botón Maestro de Navegación
// ────────────────────────────────────────────────────────────
//  DISEÑO:
//  • FAB: anillo dorado pulsante + avatar/inicial + glow
//  • Bottom sheet: glassmorphism oscuro con header de usuario
//  • Opciones: tiles con ícono en círculo dorado + press scale
//  • Logout: fila roja con diálogo coherente con el sistema
//  • Animación de apertura: slide-up suave del sheet
// ────────────────────────────────────────────────────────────

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../di/service_locator.dart';
import '../providers/avatar_provider.dart';
import '../blocs/auth/auth_bloc.dart';

// ── Paleta (idéntica al sistema de diseño) ────────────────────
const _kGold = Color(0xFFD4AF37);
const _kGoldLight = Color(0xFFFFE082);
const _kGoldDeep = Color(0xFF9C7A1A);
const _kBg = Color(0xFF07070F);
const _kSurface = Color(0xFF0F0F1E);
const _kBorder = Color(0xFF1E1E3A);
const _kHint = Color(0xFF6B6B8A);

// ══════════════════════════════════════════════════════════════
//  BOTÓN FLOTANTE PRINCIPAL
// ══════════════════════════════════════════════════════════════
class ProfileFloatingButton extends StatefulWidget {
  final bool hideOrganizacionesOption;
  final bool hidePlazoletasOption;

  const ProfileFloatingButton({
    super.key,
    this.hideOrganizacionesOption = false,
    this.hidePlazoletasOption = false,
  });

  @override
  State<ProfileFloatingButton> createState() => _ProfileFloatingButtonState();
}

class _ProfileFloatingButtonState extends State<ProfileFloatingButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Abre el bottom sheet de navegación ────────────────────
  void _openMenu(BuildContext context, User user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (_) => _ProfileSheet(
            user: user,
            hideOrganizacionesOption: widget.hideOrganizacionesOption,
            hidePlazoletasOption: widget.hidePlazoletasOption,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final isAuth = user != null;

        return AnimatedBuilder(
          animation: _pulseAnim,
          builder:
              (_, child) => Stack(
                alignment: Alignment.center,
                children: [
                  // Anillo de glow exterior pulsante
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _kGold.withOpacity(0.28 * _pulseAnim.value),
                          blurRadius: 22 * _pulseAnim.value,
                          spreadRadius: 4 * _pulseAnim.value,
                        ),
                      ],
                    ),
                  ),
                  child!,
                ],
              ),
          child: GestureDetector(
            onTap: () {
              if (isAuth) {
                _openMenu(context, user);
              } else {
                context.push('/login');
              }
            },
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const SweepGradient(
                  colors: [_kGoldDeep, _kGold, _kGoldLight, _kGold, _kGoldDeep],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.50),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(2.5),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kBg,
                ),
                padding: const EdgeInsets.all(2),
                child: ClipOval(
                  child: isAuth ? _buildUserAvatar(user) : _buildLoginIcon(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserAvatar(User user) {
    final avatarProvider = getIt<AvatarProvider>();

    return ListenableBuilder(
      listenable: avatarProvider,
      builder: (context, _) {
        final imageUrl = avatarProvider.avatarUrl;
        final updateCount = avatarProvider.updateCount;

        if (imageUrl != null && imageUrl.isNotEmpty) {
          return Image.network(
            imageUrl,
            key: ValueKey('avatar_${imageUrl}_$updateCount'),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildInitialAvatar(user),
          );
        }
        return _buildInitialAvatar(user);
      },
    );
  }

  Widget _buildInitialAvatar(User user) {
    final initial =
        (user.displayName?.isNotEmpty == true)
            ? user.displayName![0].toUpperCase()
            : (user.email?.isNotEmpty == true)
            ? user.email![0].toUpperCase()
            : '?';
    return Container(
      color: _kGold.withOpacity(0.10),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: _kGold,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginIcon() {
    return Container(
      color: _kGold.withOpacity(0.08),
      child: const Center(
        child: Icon(Icons.login_rounded, color: _kGold, size: 22),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  BOTTOM SHEET DE PERFIL Y NAVEGACIÓN
// ══════════════════════════════════════════════════════════════
class _ProfileSheet extends StatefulWidget {
  final User user;
  final bool hideOrganizacionesOption;
  final bool hidePlazoletasOption;

  const _ProfileSheet({
    required this.user,
    required this.hideOrganizacionesOption,
    required this.hidePlazoletasOption,
  });

  @override
  State<_ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends State<_ProfileSheet> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: _kSurface.withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(top: BorderSide(color: _kBorder, width: 1)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Pill handle ────────────────────────────────
                const SizedBox(height: 12),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _kBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Header de usuario ──────────────────────────
                _buildUserHeader(context),

                const SizedBox(height: 16),

                // ── Separador dorado ───────────────────────────
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        _kGold.withOpacity(0.35),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // ── Opciones de navegación ─────────────────────
                _SheetTile(
                  icon: Icons.person_outline_rounded,
                  label: 'Mi perfil',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/profile');
                  },
                ),
                if (!widget.hidePlazoletasOption)
                  _SheetTile(
                    icon: Icons.location_city_rounded,
                    label: 'Plazoletas',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/plazoletas');
                    },
                  ),
                if (!widget.hideOrganizacionesOption)
                  _SheetTile(
                    icon: Icons.account_balance_rounded,
                    label: 'Organizaciones',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/organizaciones');
                    },
                  ),
                _SheetTile(
                  icon: Icons.settings_outlined,
                  label: 'Configuración',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: _kSurface,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: _kBorder),
                        ),
                        content: const Row(
                          children: [
                            Icon(
                              Icons.settings_outlined,
                              color: _kGold,
                              size: 16,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Configuración — En desarrollo',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // ── Separador rojo ─────────────────────────────
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.red.withOpacity(0.20),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                // ── Logout ─────────────────────────────────────
                _SheetTile(
                  icon: Icons.logout_rounded,
                  label: 'Cerrar sesión',
                  isDestructive: true,
                  onTap: () => _showLogoutConfirmationWithOverlay(context),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header con avatar y datos ─────────────────────────────
  Widget _buildUserHeader(BuildContext context) {
    final avatarProvider = getIt<AvatarProvider>();
    final initial =
        (widget.user.displayName?.isNotEmpty == true)
            ? widget.user.displayName![0].toUpperCase()
            : (widget.user.email?.isNotEmpty == true)
            ? widget.user.email![0].toUpperCase()
            : '?';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Avatar con anillo dorado
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const SweepGradient(
                colors: [_kGoldDeep, _kGold, _kGoldLight, _kGold, _kGoldDeep],
              ),
              boxShadow: [
                BoxShadow(
                  color: _kGold.withOpacity(0.22),
                  blurRadius: 14,
                  spreadRadius: 2,
                ),
              ],
            ),
            padding: const EdgeInsets.all(2),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: _kBg,
              ),
              padding: const EdgeInsets.all(2),
              child: ClipOval(
                child: ListenableBuilder(
                  listenable: avatarProvider,
                  builder: (context, _) {
                    final imageUrl = avatarProvider.avatarUrl;
                    final updateCount = avatarProvider.updateCount;
                    if (imageUrl != null && imageUrl.isNotEmpty) {
                      return Image.network(
                        imageUrl,
                        key: ValueKey('avatar_${imageUrl}_$updateCount'),
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => _buildInitialWidget(initial),
                      );
                    }
                    return _buildInitialWidget(initial);
                  },
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Nombre y email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback:
                      (b) => const LinearGradient(
                        colors: [Colors.white, _kGoldLight],
                        stops: [0.5, 1.0],
                      ).createShader(b),
                  child: Text(
                    widget.user.displayName ?? 'Usuario',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.user.email ?? '',
                  style: const TextStyle(
                    color: _kHint,
                    fontSize: 12,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Badge sesión activa
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.green.withOpacity(0.28),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.greenAccent,
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'Activo',
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialWidget(String initial) {
    return Container(
      color: _kGold.withOpacity(0.10),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: _kGold,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Future<void> _showLogoutConfirmationWithOverlay(BuildContext context) async {
    // Obtener el overlay del root navigator ANTES de cerrar el BottomSheet
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    final overlayContext = rootNavigator.overlay?.context;

    if (overlayContext == null || !overlayContext.mounted) {
      // Fallback: usar el contexto actual
      _showLogoutConfirmationFallback(context);
      return;
    }

    // Cerrar el BottomSheet primero
    Navigator.of(context).pop();

    // Usar Future.microtask para asegurar que el BottomSheet se haya cerrado
    Future.microtask(() async {
      if (!overlayContext.mounted) {
        _showLogoutConfirmationFallback(context);
        return;
      }

      // Mostrar diálogo de confirmación usando el overlay context
      final result = await showDialog<bool>(
        context: overlayContext,
        useRootNavigator: true,
        barrierDismissible: true,
        builder: (dialogContext) => _buildLogoutDialog(dialogContext),
      );

      if (result == true && overlayContext.mounted) {
        // Realizar logout
        await _performLogout(overlayContext);
      }
    });
  }

  void _showLogoutConfirmationFallback(BuildContext context) {
    // Cerrar el BottomSheet
    Navigator.of(context).pop();

    // Mostrar diálogo directamente usando el contexto después de un delay
    Future.microtask(() async {
      final result = await showDialog<bool>(
        context: context,
        useRootNavigator: true,
        barrierDismissible: true,
        builder: (dialogContext) => _buildLogoutDialog(dialogContext),
      );

      if (result == true && context.mounted) {
        await _performLogout(context);
      }
    });
  }

  Widget _buildLogoutDialog(BuildContext dialogContext) {
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
          onPressed:
              () => Navigator.of(dialogContext, rootNavigator: true).pop(false),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: _kHint, fontWeight: FontWeight.w500),
          ),
        ),
        TextButton(
          onPressed:
              () => Navigator.of(dialogContext, rootNavigator: true).pop(true),
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

      // Wait for state change to AuthUnauthenticated
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
                content: Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: Colors.red[300],
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Error al cerrar sesión: ${state.message}',
                        style: TextStyle(color: Colors.red[200], fontSize: 13),
                      ),
                    ),
                  ],
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
            content: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: Colors.red[300],
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Error inesperado: $error',
                    style: TextStyle(color: Colors.red[200], fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
  }
}

// ══════════════════════════════════════════════════════════════
//  TILE DEL BOTTOM SHEET CON PRESS SCALE
// ══════════════════════════════════════════════════════════════
class _SheetTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SheetTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  State<_SheetTile> createState() => _SheetTileState();
}

class _SheetTileState extends State<_SheetTile>
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
    final bgColor =
        widget.isDestructive
            ? Colors.red.withOpacity(0.05)
            : _kGold.withOpacity(0.05);
    final borderColor =
        widget.isDestructive
            ? Colors.red.withOpacity(0.20)
            : _kGold.withOpacity(0.15);

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
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _pressed ? bgColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _pressed ? borderColor : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Ícono en círculo
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: iconColor.withOpacity(0.09),
                        border: Border.all(
                          color: iconColor.withOpacity(_pressed ? 0.38 : 0.18),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        widget.icon,
                        color: iconColor.withOpacity(_pressed ? 1.0 : 0.75),
                        size: 18,
                      ),
                    ),

                    const SizedBox(width: 14),

                    // Label
                    Expanded(
                      child: Text(
                        widget.label,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),

                    // Flecha (solo en opciones normales)
                    if (!widget.isDestructive)
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: _kGold.withOpacity(_pressed ? 0.70 : 0.28),
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
