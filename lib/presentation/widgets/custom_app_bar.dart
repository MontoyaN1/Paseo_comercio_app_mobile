// lib/presentation/widgets/custom_app_bar.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../di/service_locator.dart';
import '../../core/utils/firebase_auth_service.dart';
import '../../core/app/app_config.dart';
import '../blocs/auth/auth_bloc.dart';

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
    final theme = Theme.of(context);

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final authService = getIt<FirebaseAuthService>();
        final isAuthenticated = snapshot.hasData && snapshot.data != null;
        final currentUser = snapshot.data;

        return AppBar(
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
          elevation: 6,
          centerTitle: true,
          leading:
              showBackButton
                  ? IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: theme.colorScheme.onSurface,
                    ),
                    onPressed:
                        onBackPressed ??
                        () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/plazoletas');
                          }
                        },
                  )
                  : null,
          title:
              title != null
                  ? Text(
                    title!,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  )
                  : Text(
                    AppConfig().appName,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
          actions: [
            ...?additionalActions,
            if (showProfileButton) ...[
              if (isAuthenticated && currentUser != null)
                _buildProfileMenu(context, authService, currentUser, theme)
              else
                _buildLoginButton(context, theme),
            ],
          ],
        );
      },
    );
  }

  Widget _buildProfileMenu(
    BuildContext context,
    FirebaseAuthService authService,
    User currentUser,
    ThemeData theme,
  ) {
    return PopupMenuButton<String>(
      icon: CircleAvatar(
        radius: 16,
        backgroundImage:
            currentUser.photoURL != null
                ? NetworkImage(currentUser.photoURL!)
                : null,
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        child:
            currentUser.photoURL == null
                ? Icon(
                  Icons.person,
                  size: 18,
                  color: theme.colorScheme.onSurface,
                )
                : null,
      ),
      color: theme.colorScheme.surface,
      surfaceTintColor: theme.colorScheme.surface,
      onSelected: (value) {
        _handleMenuSelection(context, value, authService);
      },
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem<String>(
            value: 'profile',
            enabled: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentUser.displayName ?? 'Usuario',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  currentUser.email ?? '',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          PopupMenuDivider(),
          PopupMenuItem<String>(
            value: 'profile_page',
            child: Row(
              children: [
                Icon(
                  Icons.person,
                  color: theme.colorScheme.onSurface,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Mi perfil',
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'settings',
            child: Row(
              children: [
                Icon(
                  Icons.settings,
                  color: theme.colorScheme.onSurface,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Configuración',
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
              ],
            ),
          ),
          PopupMenuDivider(),
          PopupMenuItem<String>(
            value: 'logout',
            child: Row(
              children: [
                Icon(Icons.logout, color: theme.colorScheme.error, size: 20),
                SizedBox(width: 8),
                Text(
                  'Cerrar sesión',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ],
            ),
          ),
        ];
      },
    );
  }

  Widget _buildLoginButton(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: TextButton(
        onPressed: () {
          context.go('/login');
        },
        style: TextButton.styleFrom(
          foregroundColor: theme.colorScheme.onSurface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: Text(
          'Iniciar sesión',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  void _handleMenuSelection(
    BuildContext context,
    String value,
    FirebaseAuthService authService,
  ) async {
    switch (value) {
      case 'profile_page':
        context.push('/profile');
        break;
      case 'settings':
        context.push('/settings');
        break;
      case 'logout':
        Future.microtask(() {
          _showLogoutConfirmation(context, authService);
        });
        break;
    }
  }

  Future<void> _showLogoutConfirmation(
    BuildContext context,
    FirebaseAuthService authService,
  ) async {
    final theme = Theme.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: theme.colorScheme.surface,
            title: Text(
              'Cerrar sesión',
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
            content: Text(
              '¿Estás seguro de que quieres cerrar sesión?',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Cerrar sesión',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            ],
          ),
    );

    if (result == true) {
      await _performLogout(context, authService);
    }
  }

  Future<void> _performLogout(
    BuildContext context,
    FirebaseAuthService authService,
  ) async {
    final authBloc = getIt<AuthBloc>();
    final theme = Theme.of(context);

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            ),
      );

      authBloc.add(const AuthSignOutRequested());

      await for (final state in authBloc.stream) {
        if (context.mounted) {
          Navigator.of(context).pop();
        }

        if (state is AuthUnauthenticated) {
          if (context.mounted) {
            await Future.delayed(const Duration(milliseconds: 300));
            if (context.mounted) {
              context.go('/login');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Sesión cerrada correctamente'),
                  backgroundColor: theme.colorScheme.primary,
                ),
              );
            }
          }
          break;
        } else if (state is AuthError) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al cerrar sesión: ${state.message}'),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
          break;
        }
      }
    } catch (error) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: ${error.toString()}'),
            backgroundColor: theme.colorScheme.error,
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
    final theme = Theme.of(context);
    final actions = <Widget>[];

    if (showSearchButton) {
      actions.add(
        IconButton(
          icon: Icon(Icons.search, color: theme.colorScheme.onSurface),
          onPressed:
              onSearchPressed ??
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Funcionalidad de búsqueda - En desarrollo',
                    ),
                    backgroundColor: theme.colorScheme.primary,
                  ),
                );
              },
        ),
      );
    }

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
