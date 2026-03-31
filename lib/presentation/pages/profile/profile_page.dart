// lib/presentation/pages/profile/profile_page.dart

//
// 🏛️  PLAZA UNIVERSE — Perfil de Usuario
// ────────────────────────────────────────────────────────────
//  DISEÑO:
//  • Fondo: partículas isométricas flotantes (mismo que login)
//  • Hero del avatar: anillo dorado con glow + nombre animado
//  • Secciones: glassmorphism con encabezado dorado
//  • Action tiles: filas elegantes sobre oscuro con flecha dorada
//  • Botón logout: outline rojo con press scale
//  • Diálogos: coherentes con el sistema de diseño
//  • Estado sin sesión: pantalla de invitación elegante
// ────────────────────────────────────────────────────────────

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:paseo_del_comercio/di/service_locator.dart';
import 'package:paseo_del_comercio/core/utils/firebase_auth_service.dart';
import 'package:paseo_del_comercio/presentation/providers/avatar_provider.dart';
import 'package:paseo_del_comercio/presentation/blocs/auth/auth_bloc.dart';
import 'package:paseo_del_comercio/core/errors/app_exceptions.dart';
import 'package:paseo_del_comercio/data/datasources/remote/supabase_client.dart';
import 'package:paseo_del_comercio/presentation/widgets/profile/profile_bg_painter.dart';
import 'package:paseo_del_comercio/presentation/widgets/profile/profile_components.dart';
import 'package:paseo_del_comercio/presentation/widgets/profile/profile_edit_dialog.dart';
import 'package:paseo_del_comercio/presentation/widgets/profile/profile_buttons.dart';

// ── Paleta (idéntica al sistema de diseño) ────────────────────
const Color _kGold = Color(0xFFD4AF37);
const _kGoldLight = Color(0xFFFFE082);
const _kGoldDeep = Color(0xFF9C7A1A);
const _kBg = Color(0xFF07070F);
const _kSurface = Color(0xFF0F0F1E);
const _kBorder = Color(0xFF1E1E3A);
const _kHint = Color(0xFF6B6B8A);

// ══════════════════════════════════════════════════════════════
//  PAGE PRINCIPAL
// ══════════════════════════════════════════════════════════════
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  // ── Animaciones ───────────────────────────────────────────
  late final AnimationController _bgCtrl;
  late final AnimationController _heroCtrl;
  late final AnimationController _contentCtrl;
  late final AnimationController _avatarPulseCtrl;

  late final Animation<double> _heroFade;
  late final Animation<double> _heroSlide;
  late final Animation<double> _contentFade;
  late final Animation<double> _contentSlide;
  late final Animation<double> _avatarPulse;

  @override
  void initState() {
    super.initState();

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _avatarPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _avatarPulse = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _avatarPulseCtrl, curve: Curves.easeInOut),
    );

    _heroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _heroFade = CurvedAnimation(
      parent: _heroCtrl,
      curve: const Interval(0.0, 0.65),
    );
    _heroSlide = Tween<double>(
      begin: -30,
      end: 0,
    ).animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutCubic));

    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _contentFade = CurvedAnimation(
      parent: _contentCtrl,
      curve: const Interval(0.0, 0.7),
    );
    _contentSlide = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutCubic),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      _heroCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 350), () {
      _contentCtrl.forward();
    });
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _heroCtrl.dispose();
    _contentCtrl.dispose();
    _avatarPulseCtrl.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          // ── Fondo animado ──────────────────────────────────
          AnimatedBuilder(
            animation: _bgCtrl,
            builder:
                (_, __) => CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: ProfileBgPainter(
                    _bgCtrl.value,
                    Theme.of(context).brightness,
                  ),
                ),
          ),

          // ── Contenido ─────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: StreamBuilder<User?>(
                    stream: FirebaseAuth.instance.authStateChanges(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: SizedBox(
                            width: 36,
                            height: 36,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(_kGold),
                            ),
                          ),
                        );
                      }
                      final user = snapshot.data;
                      if (user != null) {
                        return _buildProfileContent(context, user);
                      } else {
                        return ProfileSignedOutContent(
                          onSignIn: () => Navigator.pop(context),
                          onContinueAsGuest: () => Navigator.pop(context),
                        );
                      }
                    },
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark
            ? _kSurface.withValues(alpha: 0.82)
            : Colors.white.withValues(alpha: 0.90);
    final borderColor = isDark ? _kBorder : Colors.grey.shade300;
    final textColor = isDark ? Colors.white : Colors.black87;

    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: kToolbarHeight,
          decoration: BoxDecoration(
            color: surfaceColor,
            border: Border(bottom: BorderSide(color: borderColor, width: 1)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              ProfileIconButton(
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
                  child: Text(
                    'Perfil',
                    style: TextStyle(
                      color: textColor,
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

  // ── Perfil con sesión activa ──────────────────────────────
  Widget _buildProfileContent(BuildContext context, User user) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      child: Column(
        children: [
          const SizedBox(height: 32),

          // ── Avatar + nombre ──────────────────────────────
          AnimatedBuilder(
            animation: _heroCtrl,
            builder:
                (_, child) => Opacity(
                  opacity: _heroFade.value.clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, _heroSlide.value),
                    child: child,
                  ),
                ),
            child: _buildAvatarHero(),
          ),

          const SizedBox(height: 32),

          // ── Secciones ────────────────────────────────────
          AnimatedBuilder(
            animation: _contentCtrl,
            builder:
                (_, child) => Opacity(
                  opacity: _contentFade.value.clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, _contentSlide.value),
                    child: child,
                  ),
                ),
            child: Column(
              children: [
                _buildInfoSection(),
                const SizedBox(height: 16),
                _buildActionsSection(context),
                const SizedBox(height: 28),
                ProfileLogoutButton(onLogout: () => _performLogout(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero del Avatar ───────────────────────────────────────
  Widget _buildAvatarHero() {
    final authService = getIt<FirebaseAuthService>();
    final avatarProvider = getIt<AvatarProvider>();
    final displayName = authService.currentUserName;
    final email = authService.currentUserEmail;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Avatar con anillo dorado animado y botón de edición
        GestureDetector(
          onTap: _showAvatarOptions,
          child: AnimatedBuilder(
            animation: _avatarPulse,
            builder:
                (_, child) => Stack(
                  alignment: Alignment.center,
                  children: [
                    // Anillo de glow exterior pulsante
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _kGold.withValues(
                              alpha: 0.20 * _avatarPulse.value,
                            ),
                            blurRadius: 30 * _avatarPulse.value,
                            spreadRadius: 6 * _avatarPulse.value,
                          ),
                        ],
                      ),
                    ),
                    // Anillo dorado exterior
                    Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            _kGold.withValues(alpha: 0.80),
                            _kGoldLight.withValues(alpha: 0.30),
                            _kGold.withValues(alpha: 0.80),
                          ],
                        ),
                      ),
                    ),
                    // Avatar interior
                    Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? _kSurface : Colors.grey.shade200,
                        border: Border.all(
                          color: isDark ? _kBg : Colors.grey.shade400,
                          width: 3,
                        ),
                      ),
                      child: ClipOval(
                        child: ListenableBuilder(
                          listenable: avatarProvider,
                          builder: (context, _) {
                            final imageUrl = avatarProvider.avatarUrl;
                            final updateCount = avatarProvider.updateCount;
                            if (imageUrl != null && imageUrl.isNotEmpty) {
                              return Image.network(
                                imageUrl,
                                key: ValueKey(
                                  'avatar_${imageUrl}_$updateCount',
                                ),
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => _buildAvatarFallback(),
                              );
                            }
                            return _buildAvatarFallback();
                          },
                        ),
                      ),
                    ),
                    // Botón de edición de avatar
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _kGold,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? _kBg : Colors.white,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
          ),
        ),

        const SizedBox(height: 18),

        // Nombre con degradado dorado
        ShaderMask(
          shaderCallback:
              (b) => const LinearGradient(
                colors: [_kGoldDeep, _kGold, _kGoldLight],
              ).createShader(b),
          child: Text(
            displayName ?? 'Usuario',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 6),

        // Email
        Text(
          email ?? '',
          style: TextStyle(
            color: isDark ? _kHint : Colors.grey.shade600,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 14),

        // Badge de sesión activa
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color:
                isDark
                    ? Colors.green.withValues(alpha: 0.15)
                    : Colors.green.shade100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  isDark
                      ? Colors.green.withValues(alpha: 0.40)
                      : Colors.green.shade400,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? Colors.greenAccent : Colors.green.shade700,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                'Sesión activa',
                style: TextStyle(
                  color: isDark ? Colors.greenAccent : Colors.green.shade800,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Opciones para cambiar avatar ─────────────────────────────────
  void _showAvatarOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? _kSurface : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? _kHint : Colors.grey.shade600;

    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Cambiar foto de perfil',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _kGold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.camera_alt, color: _kGold),
                    ),
                    title: Text(
                      'Tomar foto',
                      style: TextStyle(color: textColor),
                    ),
                    subtitle: Text(
                      'Usar la cámara',
                      style: TextStyle(color: hintColor),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _cambiarAvatar(ImageSource.camera);
                    },
                  ),
                  ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _kGold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.photo_library, color: _kGold),
                    ),
                    title: Text(
                      'Elegir de galería',
                      style: TextStyle(color: textColor),
                    ),
                    subtitle: Text(
                      'Seleccionar una imagen',
                      style: TextStyle(color: hintColor),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _cambiarAvatar(ImageSource.gallery);
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
    );
  }

  // ── Cambiar avatar ─────────────────────────────────────────────
  Future<void> _cambiarAvatar(ImageSource source) async {
    try {
      final picker = ImagePicker();

      // Seleccionar imagen
      final XFile? imagen = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (imagen == null) return;

      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) =>
                const Center(child: CircularProgressIndicator(color: _kGold)),
      );

      // Obtener datos del usuario
      final authService = getIt<FirebaseAuthService>();
      final supabase = getIt<SupabaseClientService>();
      final firebaseUser = authService.currentUser;

      if (firebaseUser == null) {
        Navigator.pop(context);
        _mostrarError('No hay sesión activa');
        return;
      }

      // Obtener usuario de Supabase
      final usuario = await supabase.getUsuarioByFirebaseId(firebaseUser.uid);

      if (usuario == null) {
        Navigator.pop(context);
        _mostrarError('Usuario no encontrado');
        return;
      }

      final usuarioId = usuario['id'] as int;
      final oldAvatarUrl = usuario['avatar_url'] as String?;

      // Leer imagen
      final bytes = await imagen.readAsBytes();

      // Actualizar avatar
      final result = await authService.actualizarAvatarUsuario(
        imageData: bytes,
        usuarioId: usuarioId,
        firebaseUserId: firebaseUser.uid,
        oldAvatarUrl: oldAvatarUrl,
      );

      Navigator.pop(context);

      // Manejar resultado sin await dentro de fold
      if (result.isSuccess) {
        // Actualizar el perfil local
        await authService.reloadUserProfile();
        // El AvatarProvider ya fue notificado en actualizarAvatarUsuario
        _mostrarSuccess('Foto de perfil actualizada');
      } else {
        _mostrarError('Error al actualizar: ${result.errorOrNull}');
      }
    } catch (e) {
      _mostrarError('Error: $e');
    }
  }

  // ── Mostrar mensaje de éxito ─────────────────────────────────
  void _mostrarSuccess(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.green),
    );
  }

  // ── Mostrar mensaje de error ─────────────────────────────────
  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
  }

  Widget _buildAvatarFallback() {
    final authService = getIt<FirebaseAuthService>();
    final displayName = authService.currentUserName;
    final initials =
        (displayName?.isNotEmpty == true) ? displayName![0].toUpperCase() : '?';
    return Container(
      color: _kGold.withOpacity(0.10),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: _kGold,
            fontSize: 38,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ── Sección de información ────────────────────────────────
  Widget _buildInfoSection() {
    final authService = getIt<FirebaseAuthService>();
    final registrationDate = authService.registrationDate;
    final fechaCreacion =
        registrationDate != null
            ? '${registrationDate.day}/${registrationDate.month}/${registrationDate.year}'
            : 'No disponible';

    return ProfileGlassSection(
      title: 'Información de la cuenta',
      icon: Icons.badge_outlined,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ProfileGoldInfoRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Nombre completo',
                  value: authService.currentUserName ?? 'No disponible',
                ),
              ),
              const SizedBox(width: 8),
              ProfileIconButton(
                icon: Icons.edit_outlined,
                onTap: () => _showEditProfileDialog(context, 'nombre'),
              ),
            ],
          ),
          ProfileSectionDivider(),
          ProfileGoldInfoRow(
            icon: Icons.alternate_email_rounded,
            label: 'Email',
            value: authService.currentUserEmail ?? 'No disponible',
          ),
          ProfileSectionDivider(),
          Row(
            children: [
              Expanded(
                child: ProfilePhoneInfoRow(
                  phoneNumber:
                      authService.currentUserPhoneNumber ?? 'No disponible',
                ),
              ),
              const SizedBox(width: 8),
              ProfileIconButton(
                icon: Icons.edit_outlined,
                onTap: () => _showEditProfileDialog(context, 'telefono'),
              ),
            ],
          ),
          ProfileSectionDivider(),
          ProfileGoldInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Miembro desde',
            value: fechaCreacion,
          ),
        ],
      ),
    );
  }

  // ── Sección de acciones ───────────────────────────────────
  Widget _buildActionsSection(BuildContext context) {
    return ProfileGlassSection(
      title: 'Mi cuenta',
      icon: Icons.dashboard_outlined,
      child: Column(
        children: [
          ProfileActionTile(
            icon: Icons.favorite_outline_rounded,
            title: 'Favoritos',
            subtitle: 'Tiendas y productos guardados',
            onTap: () => context.push('/favoritos'),
          ),
          ProfileSectionDivider(),
          // ⚠️ HISTORIAL - POSTERGADO
          // ProfileActionTile(
          //   icon: Icons.history_rounded,
          //   title: 'Historial',
          //   subtitle: 'Tu actividad reciente',
          //   onTap: () => context.push('/historial'),
          // ),
          // ProfileSectionDivider(),
          ProfileSectionDivider(),
          ProfileActionTile(
            icon: Icons.help_outline_rounded,
            title: 'Ayuda y soporte',
            subtitle: 'Preguntas frecuentes y contacto',
            onTap: () => context.push('/soporte'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditProfileDialog(
    BuildContext context,
    String field,
  ) async {
    final authService = getIt<FirebaseAuthService>();
    final currentValue =
        field == 'nombre'
            ? authService.currentUserName ?? ''
            : authService.currentUserPhoneNumber ?? '';

    final result = await showDialog<String>(
      context: context,
      builder:
          (_) => ProfileEditDialog(
            field: field,
            currentValue: currentValue,
            label: field == 'nombre' ? 'Nombre completo' : 'Teléfono',
            onSave: (f, v) async {
              await authService.updateProfile(nombre: v, telefono: v);
            },
          ),
    );

    if (result != null && result.isNotEmpty && result != currentValue) {
      await _updateProfile(field, result);
    }
  }

  Future<void> _updateProfile(String field, String newValue) async {
    if (!context.mounted) return;

    final authService = getIt<FirebaseAuthService>();
    final fieldLabel = field == 'nombre' ? 'Nombre' : 'Teléfono';

    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => const ProfileLoadingOverlay(),
    );

    try {
      final result = await authService.updateProfile(
        nombre: field == 'nombre' ? newValue : null,
        telefono: field == 'telefono' ? newValue : null,
      );

      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      result.fold(
        (_) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: _kGold.withValues(alpha: 0.9),
                content: Text('$fieldLabel actualizado correctamente'),
                duration: const Duration(seconds: 3),
              ),
            );
            setState(() {});
          }
        },
        (error) {
          String msg = 'Error al actualizar $field';
          if (error is AuthException) {
            msg = error.message;
          }
          if (context.mounted) {
            _showErrorSnackBar(context, msg);
          }
        },
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        _showErrorSnackBar(context, 'Error: $e');
      }
    }
  }

  Future<void> _performLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => ProfileLogoutDialog(),
    );
    if (confirm != true) return;

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => const ProfileLoadingOverlay(),
    );

    try {
      final authBloc = getIt<AuthBloc>();
      authBloc.add(const AuthSignOutRequested());

      // Wait for state change to AuthUnauthenticated
      await for (final state in authBloc.stream) {
        if (state is AuthUnauthenticated) {
          if (context.mounted) {
            Navigator.of(context, rootNavigator: true).pop();
            // Small delay to ensure Firebase auth state is fully updated
            await Future.delayed(const Duration(milliseconds: 300));
            if (context.mounted) {
              context.go('/login');
            }
          }
          break;
        } else if (state is AuthError) {
          if (context.mounted) {
            Navigator.of(context, rootNavigator: true).pop();
            _showErrorSnackBar(
              context,
              'Error al cerrar sesión: ${state.message}',
            );
          }
          break;
        }
      }
    } catch (error) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      if (context.mounted) {
        _showErrorSnackBar(context, 'Error inesperado: $error');
      }
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
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
            Icon(Icons.error_outline_rounded, color: Colors.red[300], size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Colors.red[300], fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
