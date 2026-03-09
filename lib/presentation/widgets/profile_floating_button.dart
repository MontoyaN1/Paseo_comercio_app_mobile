// lib/presentation/widgets/profile_floating_button.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../core/routing/app_router.dart';
import '../../di/service_locator.dart';
import '../../core/utils/firebase_auth_service.dart';

/// Botón flotante de perfil reutilizable para la esquina inferior derecha
class ProfileFloatingButton extends StatelessWidget {
  final double bottom;
  final double right;
  final double size;
  final Color backgroundColor;
  final bool hideOrganizacionesOption;
  final bool hidePlazoletasOption;

  const ProfileFloatingButton({
    super.key,
    this.bottom = 24,
    this.right = 24,
    this.size = 56,
    this.backgroundColor = const Color(0xFFD4AF37),
    this.hideOrganizacionesOption = false,
    this.hidePlazoletasOption = false,
  });

  void _showProfileMenu(BuildContext parentContext, User currentUser) {
    showModalBottomSheet(
      context: parentContext,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Información del usuario
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage:
                          currentUser.photoURL != null
                              ? NetworkImage(currentUser.photoURL!)
                              : null,
                      backgroundColor: Colors.grey[700],
                      child:
                          currentUser.photoURL == null
                              ? const Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.white,
                              )
                              : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentUser.displayName ?? 'Usuario',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentUser.email ?? '',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.grey, height: 1),
              // Opción de perfil
              ListTile(
                leading: const Icon(Icons.person, color: Colors.white),
                title: const Text(
                  'Mi perfil',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  AppRouter.router.go('/profile');
                },
              ),
              // Opción de plazoletas
              if (!hidePlazoletasOption)
                ListTile(
                  leading: const Icon(Icons.location_city, color: Colors.white),
                  title: const Text(
                    'Plazoletas',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    AppRouter.router.go('/plazoletas');
                  },
                ),
              // Opción de organizaciones
              if (!hideOrganizacionesOption)
                ListTile(
                  leading: const Icon(Icons.group, color: Colors.white),
                  title: const Text(
                    'Organizaciones',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    AppRouter.router.go('/organizaciones');
                  },
                ),
              // Opción de configuración
              ListTile(
                leading: const Icon(Icons.settings, color: Colors.white),
                title: const Text(
                  'Configuración',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(
                      content: Text('Configuración - En desarrollo'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                },
              ),
              const Divider(color: Colors.grey, height: 1),
              // Opción de cerrar sesión
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Cerrar sesión',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _showLogoutConfirmation(parentContext);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    debugPrint('_showLogoutConfirmation called');
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: const Text(
              'Cerrar sesión',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              '¿Estás seguro de que quieres cerrar sesión?',
              style: TextStyle(color: Colors.grey),
            ),
            actions: [
              TextButton(
                onPressed:
                    () => Navigator.of(context, rootNavigator: true).pop(false),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed:
                    () => Navigator.of(context, rootNavigator: true).pop(true),
                child: const Text(
                  'Cerrar sesión',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (result == true) {
      debugPrint('User confirmed logout');
      await _performLogout(context);
    } else {
      debugPrint('User cancelled logout');
    }
  }

  Future<void> _performLogout(BuildContext context) async {
    debugPrint('_performLogout started');
    // Capturar el contexto antes de operaciones asíncronas
    final logoutContext = context;
    final authService = getIt<FirebaseAuthService>();

    try {
      debugPrint('Showing loading dialog');
      // Mostrar indicador de carga
      showDialog(
        context: logoutContext,
        barrierDismissible: false,
        useRootNavigator: true,
        builder:
            (context) => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
      );

      debugPrint('Calling authService.signOut()');
      // Cerrar sesión usando el servicio de autenticación
      final result = await authService.signOut();

      debugPrint('Closing loading dialog');
      // Cerrar el diálogo de carga
      Navigator.of(logoutContext, rootNavigator: true).pop();

      result.fold(
        (success) {
          debugPrint('authService.signOut completed successfully');
          // Pequeño delay para asegurar que el estado de autenticación se actualice
          Future.delayed(const Duration(milliseconds: 100), () {
            debugPrint('Navigating to /login using AppRouter.router.go');
            // Navegar a la pantalla de login usando el router de la aplicación
            AppRouter.router.go('/login');
            debugPrint('Navigation to /login completed');
          });
        },
        (error) {
          debugPrint('Error during authService.signOut: ${error.toString()}');
          // Mostrar mensaje de error
          ScaffoldMessenger.of(logoutContext).showSnackBar(
            SnackBar(
              content: Text('Error al cerrar sesión: ${error.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        },
      );
    } catch (error) {
      debugPrint('Unexpected error in _performLogout: ${error.toString()}');
      // Intentar cerrar el diálogo de carga si aún está abierto
      try {
        Navigator.of(logoutContext, rootNavigator: true).pop();
      } catch (e) {
        // Ignorar error si el diálogo ya está cerrado
      }
      // Mostrar mensaje de error
      ScaffoldMessenger.of(logoutContext).showSnackBar(
        SnackBar(
          content: Text('Error inesperado: ${error.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
    debugPrint('_performLogout method completed');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final isAuthenticated = snapshot.hasData && snapshot.data != null;
        final currentUser = snapshot.data;

        if (!isAuthenticated || currentUser == null) {
          return FloatingActionButton(
            onPressed: () {
              AppRouter.router.go('/login');
            },
            backgroundColor: backgroundColor,
            child: const Icon(Icons.login, color: Colors.black, size: 28),
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          );
        }

        return FloatingActionButton(
          onPressed: () {
            _showProfileMenu(context, currentUser);
          },
          backgroundColor: backgroundColor,
          child: CircleAvatar(
            radius: 20,
            backgroundImage:
                currentUser.photoURL != null
                    ? NetworkImage(currentUser.photoURL!)
                    : null,
            backgroundColor: Colors.grey[800],
            child:
                currentUser.photoURL == null
                    ? const Icon(Icons.person, size: 24, color: Colors.white)
                    : null,
          ),
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        );
      },
    );
  }
}
