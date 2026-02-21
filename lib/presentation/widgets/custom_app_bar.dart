// lib/presentation/widgets/custom_app_bar.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../di/service_locator.dart';
import '../../core/utils/firebase_auth_service.dart';
import '../../core/app/app_config.dart';

/// AppBar personalizado con botón de perfil y funcionalidad de cerrar sesión
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? additionalActions;
  final bool showBackButton;
  final bool showProfileButton;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    super.key,
    this.title,
    this.additionalActions,
    this.showBackButton = false,
    this.showProfileButton = true,
    this.onBackPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final authService = getIt<FirebaseAuthService>();
    final isAuthenticated = authService.isAuthenticated;
    final currentUser = authService.currentUser;

    return AppBar(
      backgroundColor: const Color(0xFF121212),
      elevation: 6,
      centerTitle: true,
      leading:
          showBackButton
              ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: onBackPressed ?? () => context.pop(),
              )
              : null,
      title:
          title != null
              ? Text(
                title!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              )
              : Text(
                AppConfig().appName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
      actions: [
        // Acciones adicionales proporcionadas
        ...?additionalActions,

        // Botón de perfil (solo si está habilitado)
        if (showProfileButton) ...[
          if (isAuthenticated)
            _buildProfileMenu(context, authService, currentUser!)
          else
            _buildLoginButton(context),
        ],
      ],
    );
  }

  /// Construir botón de perfil con menú desplegable
  Widget _buildProfileMenu(
    BuildContext context,
    FirebaseAuthService authService,
    User currentUser,
  ) {
    return PopupMenuButton<String>(
      icon: CircleAvatar(
        radius: 16,
        backgroundImage:
            currentUser.photoURL != null
                ? NetworkImage(currentUser.photoURL!)
                : null,
        backgroundColor: Colors.grey[700],
        child:
            currentUser.photoURL == null
                ? const Icon(Icons.person, size: 18, color: Colors.white)
                : null,
      ),
      color: const Color(0xFF1E1E1E),
      surfaceTintColor: const Color(0xFF1E1E1E),
      onSelected: (value) {
        _handleMenuSelection(context, value, authService);
      },
      itemBuilder: (BuildContext context) {
        return [
          // Información del usuario
          PopupMenuItem<String>(
            value: 'profile',
            enabled: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentUser.displayName ?? 'Usuario',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  currentUser.email ?? '',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const PopupMenuDivider(),
          // Opción de perfil
          const PopupMenuItem<String>(
            value: 'profile_page',
            child: Row(
              children: [
                Icon(Icons.person, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Mi perfil', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          // Opción de configuración
          const PopupMenuItem<String>(
            value: 'settings',
            child: Row(
              children: [
                Icon(Icons.settings, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Configuración', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          const PopupMenuDivider(),
          // Opción de cerrar sesión
          const PopupMenuItem<String>(
            value: 'logout',
            child: Row(
              children: [
                Icon(Icons.logout, color: Colors.red, size: 20),
                SizedBox(width: 8),
                Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ];
      },
    );
  }

  /// Construir botón de iniciar sesión
  Widget _buildLoginButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: TextButton(
        onPressed: () {
          context.go('/login');
        },
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: const Text(
          'Iniciar sesión',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  /// Manejar selección del menú
  void _handleMenuSelection(
    BuildContext context,
    String value,
    FirebaseAuthService authService,
  ) async {
    switch (value) {
      case 'profile_page':
        context.go('/profile');
        break;
      case 'settings':
        // TODO: Implementar página de configuración
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuración - En desarrollo'),
            backgroundColor: Colors.blue,
          ),
        );
        break;
      case 'logout':
        await _showLogoutConfirmation(context, authService);
        break;
    }
  }

  /// Mostrar diálogo de confirmación para cerrar sesión
  Future<void> _showLogoutConfirmation(
    BuildContext context,
    FirebaseAuthService authService,
  ) async {
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
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Cerrar sesión',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (result == true) {
      await _performLogout(context, authService);
    }
  }

  /// Realizar cierre de sesión
  Future<void> _performLogout(
    BuildContext context,
    FirebaseAuthService authService,
  ) async {
    try {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
      );

      // Cerrar sesión
      final result = await authService.signOut();

      // Cerrar diálogo de carga
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      result.fold(
        (success) {
          // Redirigir a login
          if (context.mounted) {
            context.go('/login');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sesión cerrada correctamente'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        (error) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al cerrar sesión: ${error.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      );
    } catch (error) {
      if (context.mounted) {
        // Cerrar diálogo de carga si existe
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// AppBar personalizado para páginas de detalle
class DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool showProfileButton;
  final List<Widget>? actions;

  const DetailAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.showProfileButton = true,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: title,
      showBackButton: showBackButton,
      showProfileButton: showProfileButton,
      additionalActions: actions,
    );
  }
}

/// AppBar personalizado para páginas de lista
class ListAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showSearchButton;
  final bool showProfileButton;
  final VoidCallback? onSearchPressed;
  final List<Widget>? additionalActions;

  const ListAppBar({
    super.key,
    required this.title,
    this.showSearchButton = true,
    this.showProfileButton = true,
    this.onSearchPressed,
    this.additionalActions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[];

    // Agregar botón de búsqueda si está habilitado
    if (showSearchButton) {
      actions.add(
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed:
              onSearchPressed ??
              () {
                // TODO: Implementar búsqueda
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Funcionalidad de búsqueda - En desarrollo'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
        ),
      );
    }

    // Agregar acciones adicionales
    if (additionalActions != null) {
      actions.addAll(additionalActions!);
    }

    return CustomAppBar(
      title: title,
      showProfileButton: showProfileButton,
      additionalActions: actions,
    );
  }
}
