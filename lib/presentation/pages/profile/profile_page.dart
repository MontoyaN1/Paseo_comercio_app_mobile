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

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:paseo_del_comercio/di/service_locator.dart';
import 'package:paseo_del_comercio/core/utils/firebase_auth_service.dart';
import 'package:paseo_del_comercio/core/errors/app_exceptions.dart';
import 'package:paseo_del_comercio/core/utils/result.dart';

// ── Paleta (idéntica al sistema de diseño) ────────────────────
const Color _kGold = Color(0xFFD4AF37);

// Extensión para capitalizar strings
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

const _kGoldLight = Color(0xFFFFE082);
const _kGoldDeep = Color(0xFF9C7A1A);
const _kBg = Color(0xFF07070F);
const _kSurface = Color(0xFF0F0F1E);
const _kSurfaceCard = Color(0xFF12121F);
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
                  painter: _BgPainter(_bgCtrl.value),
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
                        return _buildSignedOutContent(context);
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
                      // Si no hay páginas en la pila, navegar a la página principal (plazoletas)
                      Future.microtask(() => context.go('/plazoletas'));
                    }
                  } catch (e) {
                    // En caso de error, navegar a la raíz
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
                    'Perfil',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              // Placeholder para simetría
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
                _LogoutButton(onLogout: () => _performLogout(context)),
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
    final imageUrl = authService.currentUserImageUrl;
    final displayName = authService.currentUserName;
    final email = authService.currentUserEmail;

    return Column(
      children: [
        // Avatar con anillo dorado animado
        AnimatedBuilder(
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
                          color: _kGold.withOpacity(0.20 * _avatarPulse.value),
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
                          _kGold.withOpacity(0.80),
                          _kGoldLight.withOpacity(0.30),
                          _kGold.withOpacity(0.80),
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
                      color: _kSurface,
                      border: Border.all(color: _kBg, width: 3),
                    ),
                    child: ClipOval(
                      child:
                          imageUrl != null && imageUrl.isNotEmpty
                              ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => _buildAvatarFallback(),
                              )
                              : _buildAvatarFallback(),
                    ),
                  ),
                ],
              ),
        ),

        const SizedBox(height: 18),

        // Nombre
        ShaderMask(
          shaderCallback:
              (b) => const LinearGradient(
                colors: [Colors.white, _kGoldLight],
                stops: [0.5, 1.0],
              ).createShader(b),
          child: Text(
            displayName ?? 'Usuario',
            style: const TextStyle(
              color: Colors.white,
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
          style: TextStyle(color: _kHint, fontSize: 13),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 14),

        // Badge de sesión activa
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green.withOpacity(0.30), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.greenAccent,
                ),
              ),
              const SizedBox(width: 7),
              const Text(
                'Sesión activa',
                style: TextStyle(
                  color: Colors.greenAccent,
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

    return _GlassSection(
      title: 'Información de la cuenta',
      icon: Icons.badge_outlined,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _GoldInfoRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Nombre completo',
                  value: authService.currentUserName ?? 'No disponible',
                ),
              ),
              const SizedBox(width: 8),
              _GoldIconButton(
                icon: Icons.edit_outlined,
                onTap: () => _showEditProfileDialog(context, 'nombre'),
              ),
            ],
          ),
          _SectionDivider(),
          _GoldInfoRow(
            icon: Icons.alternate_email_rounded,
            label: 'Email',
            value: authService.currentUserEmail ?? 'No disponible',
          ),
          _SectionDivider(),
          Row(
            children: [
              Expanded(
                child: _GoldInfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Teléfono',
                  value: authService.currentUserPhoneNumber ?? 'No disponible',
                ),
              ),
              const SizedBox(width: 8),
              _GoldIconButton(
                icon: Icons.edit_outlined,
                onTap: () => _showEditProfileDialog(context, 'telefono'),
              ),
            ],
          ),
          _SectionDivider(),
          _GoldInfoRow(
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
    return _GlassSection(
      title: 'Mi cuenta',
      icon: Icons.dashboard_outlined,
      child: Column(
        children: [
          _ActionTile(
            icon: Icons.favorite_outline_rounded,
            title: 'Favoritos',
            subtitle: 'Tiendas y productos guardados',
            onTap: () {},
          ),
          _SectionDivider(),
          _ActionTile(
            icon: Icons.account_balance_rounded,
            title: 'Organizaciones',
            subtitle: 'Ver y gestionar organizaciones',
            onTap: () => Navigator.of(context).pushNamed('/organizaciones'),
          ),
          _SectionDivider(),
          _ActionTile(
            icon: Icons.history_rounded,
            title: 'Historial',
            subtitle: 'Tu actividad reciente',
            onTap: () {},
          ),
          _SectionDivider(),
          _ActionTile(
            icon: Icons.notifications_outlined,
            title: 'Notificaciones',
            subtitle: 'Configurar preferencias',
            onTap: () {},
          ),
          _SectionDivider(),
          _ActionTile(
            icon: Icons.help_outline_rounded,
            title: 'Ayuda y soporte',
            subtitle: 'Preguntas frecuentes y contacto',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // ── Logout ────────────────────────────────────────────────
  Future<void> _showEditProfileDialog(
    BuildContext context,
    String field,
  ) async {
    final authService = getIt<FirebaseAuthService>();
    final TextEditingController controller = TextEditingController();
    final String currentValue;
    final String label;

    if (field == 'nombre') {
      currentValue = authService.currentUserName ?? '';
      label = 'Nombre completo';
    } else {
      currentValue = authService.currentUserPhoneNumber ?? '';
      label = 'Teléfono';
    }

    controller.text = currentValue;

    final result = await showDialog<String>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            backgroundColor: _kSurface,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: _kBorder, width: 1),
            ),
            title: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _kGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    field == 'nombre'
                        ? Icons.person_outline
                        : Icons.phone_outlined,
                    color: _kGold,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Editar $label',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: label,
                    labelStyle: TextStyle(color: _kHint),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _kBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _kBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _kGold),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                  cursorColor: _kGold,
                  keyboardType:
                      field == 'telefono'
                          ? TextInputType.phone
                          : TextInputType.text,
                  validator:
                      field == 'telefono'
                          ? (value) {
                            if (value == null || value.isEmpty)
                              return 'Ingresa un número de teléfono';
                            if (!RegExp(r'^[0-9]+$').hasMatch(value))
                              return 'Solo se permiten números';
                            return null;
                          }
                          : null,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: _kSurfaceCard,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: _kBorder),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ShimmerButton(
                        label: 'Guardar',
                        onTap: () async {
                          final newValue = controller.text.trim();
                          if (newValue.isNotEmpty && newValue != currentValue) {
                            // Validar teléfono si es necesario
                            if (field == 'telefono' &&
                                !RegExp(r'^[0-9]+$').hasMatch(newValue)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Solo se permiten números en el teléfono',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            // Cerrar diálogo primero con el resultado
                            Navigator.pop(context, newValue);
                          } else {
                            Navigator.of(context, rootNavigator: true).pop();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );

    // Procesar resultado después de cerrar el diálogo
    if (result != null && result.isNotEmpty && result != currentValue) {
      await _updateProfile(field, result);
    }
  }

  Future<void> _updateProfile(String field, String newValue) async {
    BuildContext context = this.context;
    print('_updateProfile: Iniciando actualización de $field a "$newValue"');
    print('_updateProfile: Contexto montado inicialmente: ${context.mounted}');
    // Verificar que el contexto esté montado antes de mostrar el diálogo
    if (!context.mounted) {
      print('_updateProfile: Contexto no montado, abortando actualización');
      return;
    }

    try {
      // Mostrar overlay de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (context) => _LoadingOverlay(),
      );

      // Obtener el servicio de autenticación
      final authService = getIt<FirebaseAuthService>();
      print('_updateProfile: AuthService obtenido');

      // Actualizar el perfil según el campo
      Result<void, Exception> result;
      final String fieldLabel;
      print('_updateProfile: Llamando a updateProfile para $field');
      if (field == 'nombre') {
        result = await authService.updateProfile(nombre: newValue);
        fieldLabel = 'Nombre';
      } else {
        result = await authService.updateProfile(telefono: newValue);
        fieldLabel = 'Teléfono';
      }
      print(
        '_updateProfile: Resultado obtenido: ${result.isSuccess ? "éxito" : "error"}',
      );

      // Cerrar overlay primero, antes de mostrar snackbars
      print(
        '_updateProfile: Intentando cerrar diálogo de carga, contexto montado: ${context.mounted}',
      );
      if (context.mounted) {
        try {
          Navigator.of(context, rootNavigator: true).pop();
          print('_updateProfile: Diálogo de carga cerrado exitosamente');
        } catch (e) {
          print('_updateProfile: Error al cerrar diálogo de carga: $e');
        }
      } else {
        print(
          '_updateProfile: Contexto no montado, no se puede cerrar diálogo',
        );
      }

      // Manejar el resultado con fold para obtener error específico
      result.fold(
        (_) {
          // Éxito
          print(
            '_updateProfile: Operación exitosa, verificando contexto: ${context.mounted}',
          );
          if (context.mounted) {
            try {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: _kGold.withOpacity(0.9),
                  content: Text(
                    '$fieldLabel actualizado correctamente',
                    style: TextStyle(color: Colors.white),
                  ),
                  duration: const Duration(seconds: 3),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
              print('_updateProfile: SnackBar de éxito mostrado');
            } catch (e) {
              print('_updateProfile: Error al mostrar snackbar de éxito: $e');
            }

            // Recargar la página después de un breve delay
            Future.delayed(const Duration(milliseconds: 500), () {
              print(
                '_updateProfile: Recargando página después de delay, contexto montado: ${context.mounted}',
              );
              if (context.mounted) {
                try {
                  setState(() {});
                  print('_updateProfile: Página recargada exitosamente');
                } catch (e) {
                  print('_updateProfile: Error al recargar página: $e');
                }
              }
            });
          } else {
            print(
              '_updateProfile: Contexto no montado después de éxito, no se puede mostrar feedback',
            );
          }
        },
        (error) {
          // Error
          print('_updateProfile: Error recibido: $error');
          print('_updateProfile: StackTrace: ${error.toString()}');
          String errorMessage = 'Error al actualizar $field';
          if (error is AuthException) {
            errorMessage = error.message;
          } else if (error.toString().contains('NOT_FOUND') ||
              error.toString().contains('database does not exist')) {
            errorMessage =
                'Base de datos no configurada. Contacta al administrador.';
          } else if (error.toString().isNotEmpty) {
            errorMessage = 'Error: ${error.toString()}';
          }
          print(
            '_updateProfile: Mostrando mensaje: $errorMessage, contexto montado: ${context.mounted}',
          );
          if (context.mounted) {
            try {
              _showErrorSnackBar(context, errorMessage);
              print('_updateProfile: SnackBar de error mostrado');
            } catch (e) {
              print('_updateProfile: Error al mostrar snackbar de error: $e');
            }
          } else {
            print(
              '_updateProfile: Contexto no montado, no se puede mostrar error al usuario',
            );
          }
        },
      );
    } catch (error) {
      print('_updateProfile: Excepción no manejada: $error');
      print('_updateProfile: StackTrace: ${StackTrace.current}');
      print(
        '_updateProfile: Verificando contexto después de excepción: ${context.mounted}',
      );
      // Intentar cerrar el diálogo de carga si existe
      if (context.mounted) {
        try {
          Navigator.of(context, rootNavigator: true).pop();
          print(
            '_updateProfile: Diálogo de carga cerrado después de excepción',
          );
        } catch (e) {
          print(
            '_updateProfile: Error al cerrar diálogo después de excepción: $e',
          );
        }
      }
      // Mostrar error usando el contexto de la página
      if (context.mounted) {
        try {
          _showErrorSnackBar(
            context,
            'Error al actualizar $field: ${error.toString()}',
          );
          print('_updateProfile: Error mostrado después de excepción');
        } catch (e) {
          print(
            '_updateProfile: Error al mostrar error después de excepción: $e',
          );
        }
      } else {
        print(
          '_updateProfile: Contexto no montado después de excepción, no se puede mostrar error',
        );
      }
    }
  }

  Future<void> _performLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => _LogoutDialog(),
    );
    if (confirm != true) return;

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => const _LoadingOverlay(),
    );

    try {
      final authService = getIt<FirebaseAuthService>();
      final result = await authService.signOut();

      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();

      result.fold(
        (_) {
          if (context.mounted) {
            context.go('/login');
          }
        },
        (error) {
          if (context.mounted) {
            _showErrorSnackBar(context, 'Error al cerrar sesión: $error');
          }
        },
      );
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

  // ── Estado sin sesión ─────────────────────────────────────
  Widget _buildSignedOutContent(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícono grande con glow
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _kGold.withOpacity(0.07),
                border: Border.all(color: _kGold.withOpacity(0.28), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: _kGold.withOpacity(0.10),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                size: 44,
                color: _kGold,
              ),
            ),
            const SizedBox(height: 24),
            ShaderMask(
              shaderCallback:
                  (b) => const LinearGradient(
                    colors: [_kGoldDeep, _kGold, _kGoldLight],
                  ).createShader(b),
              child: const Text(
                'Inicia sesión',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Accede a tus favoritos, historial\ny configuración personal',
              style: TextStyle(color: _kHint, fontSize: 14, height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Botón principal
            _ShimmerButton(
              label: 'INICIAR SESIÓN',
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text(
                'Continuar como invitado',
                style: TextStyle(
                  color: _kGold.withOpacity(0.70),
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                  decorationColor: _kGold.withOpacity(0.35),
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

// ══════════════════════════════════════════════════════════════
//  FONDO ISOMÉTRICO (idéntico al sistema de diseño)
// ══════════════════════════════════════════════════════════════
class _BgPainter extends CustomPainter {
  final double t;
  _BgPainter(this.t);

  static final _rng = math.Random(42);
  static final _particles = List.generate(
    60,
    (i) => [
      _rng.nextDouble(),
      _rng.nextDouble(),
      _rng.nextDouble() * 0.6 + 0.2,
      _rng.nextDouble() * 2.5 + 0.5,
      _rng.nextInt(3).toDouble(),
    ],
  );

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.4),
          radius: 1.0,
          colors: [const Color(0xFF111128), const Color(0xFF09091A), _kBg],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    final beamOp = math.sin(t * math.pi * 2) * 0.04 + 0.08;
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.35, 0)
        ..lineTo(w * 0.65, 0)
        ..lineTo(w * 0.80, h * 0.55)
        ..lineTo(w * 0.20, h * 0.55)
        ..close(),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_kGoldLight.withOpacity(beamOp), Colors.transparent],
        ).createShader(Rect.fromLTWH(0, 0, w, h * 0.55)),
    );

    final tW = w * 0.18;
    final tH = tW * 0.5;
    for (int row = -1; row <= 14; row++) {
      for (int col = -1; col <= 6; col++) {
        final cx = (col - row) * tW / 2 + w * 0.5;
        final cy = (col + row) * tH / 2 - t * tH * 0.5;
        final pulse = math.sin(t * math.pi * 2 + col * 0.4 + row * 0.3) * 0.012;
        final alpha = (0.05 + pulse).clamp(0.0, 0.10);
        final path =
            Path()
              ..moveTo(cx, cy - tH / 2)
              ..lineTo(cx + tW / 2, cy)
              ..lineTo(cx, cy + tH / 2)
              ..lineTo(cx - tW / 2, cy)
              ..close();
        canvas.drawPath(
          path,
          Paint()
            ..color = _kGold.withOpacity(alpha)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.6,
        );
        if (row % 3 == 0) {
          canvas.drawPath(
            path,
            Paint()..color = _kGold.withOpacity(alpha * 0.22),
          );
        }
      }
    }

    const colors = [_kGold, _kGoldLight, Colors.white];
    for (final p in _particles) {
      final phase = (t + p[2]) % 1.0;
      final op = math.sin(phase * math.pi) * 0.28;
      if (op <= 0) continue;
      canvas.drawCircle(
        Offset(p[0] * w, p[1] * h - phase * h * 0.22),
        p[3],
        Paint()
          ..color = colors[p[4].toInt()].withOpacity(op)
          ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, p[3] * 1.2),
      );
    }

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 0.78,
          colors: [Colors.transparent, Colors.black.withOpacity(0.72)],
          stops: const [0.5, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );
  }

  @override
  bool shouldRepaint(_BgPainter o) => o.t != t;
}

// ══════════════════════════════════════════════════════════════
//  SECCIÓN CON GLASSMORPHISM
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
              // Encabezado
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
              // Línea separadora dorada
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

// ══════════════════════════════════════════════════════════════
//  FILA DE INFORMACIÓN
// ══════════════════════════════════════════════════════════════
class _GoldInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _GoldInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
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
                style: const TextStyle(
                  color: _kHint,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
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
//  TILE DE ACCIÓN
// ══════════════════════════════════════════════════════════════
class _ActionTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<_ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<_ActionTile>
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
                      _pressed ? _kGold.withOpacity(0.04) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _kGold.withOpacity(0.08),
                        border: Border.all(
                          color: _kGold.withOpacity(_pressed ? 0.40 : 0.18),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        widget.icon,
                        color: _pressed ? _kGold : _kGold.withOpacity(0.70),
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle,
                            style: const TextStyle(color: _kHint, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: _pressed ? _kGold : _kGold.withOpacity(0.40),
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

// ══════════════════════════════════════════════════════════════
//  BOTÓN LOGOUT (outline rojo con press scale)
// ══════════════════════════════════════════════════════════════
class _LogoutButton extends StatefulWidget {
  final VoidCallback onLogout;
  const _LogoutButton({required this.onLogout});

  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton>
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
      end: 0.96,
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
      onTapDown: (_) {
        _ctrl.forward();
        setState(() => _pressed = true);
      },
      onTapUp: (_) {
        _ctrl.reverse();
        setState(() => _pressed = false);
        widget.onLogout();
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
                duration: const Duration(milliseconds: 150),
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color:
                      _pressed
                          ? Colors.red.withOpacity(0.10)
                          : Colors.red.withOpacity(0.05),
                  border: Border.all(
                    color:
                        _pressed
                            ? Colors.red.withOpacity(0.55)
                            : Colors.red.withOpacity(0.30),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      color: Colors.red[300],
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'CERRAR SESIÓN',
                      style: TextStyle(
                        color: Colors.red[300],
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        letterSpacing: 1.2,
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

// ══════════════════════════════════════════════════════════════
//  LOADING OVERLAY
// ══════════════════════════════════════════════════════════════
class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  SEPARADOR DE SECCIÓN
// ══════════════════════════════════════════════════════════════
class _SectionDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, _kBorder, Colors.transparent],
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
//  BOTÓN SHIMMER (estado sin sesión)
// ══════════════════════════════════════════════════════════════
class _ShimmerButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _ShimmerButton({required this.label, required this.onTap});

  @override
  State<_ShimmerButton> createState() => _ShimmerButtonState();
}

class _ShimmerButtonState extends State<_ShimmerButton>
    with TickerProviderStateMixin {
  late final AnimationController _shimmerCtrl;
  late final AnimationController _pressCtrl;
  late final Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _pressScale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: AnimatedBuilder(
        animation: Listenable.merge([_pressCtrl, _shimmerCtrl]),
        builder:
            (_, __) => Transform.scale(
              scale: _pressScale.value,
              child: Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: _kGold.withOpacity(0.38),
                      blurRadius: 18,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_kGoldDeep, _kGold, _kGoldLight, _kGold],
                            stops: [0.0, 0.35, 0.65, 1.0],
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _shimmerCtrl,
                          builder: (_, __) {
                            final x = _shimmerCtrl.value * 2 - 0.5;
                            return FractionallySizedBox(
                              widthFactor: 0.35,
                              alignment: Alignment(x * 2 - 1, 0),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0),
                                      Colors.white.withOpacity(0.22),
                                      Colors.white.withOpacity(0),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Center(
                        child: Text(
                          widget.label,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      ),
    );
  }
}
