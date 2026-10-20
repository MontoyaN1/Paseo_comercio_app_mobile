// lib/core/routing/app_router.dart

import 'dart:async';

import '../../presentation/widgets/shared/custom_app_bar.dart';

import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../utils/auth_state.dart';
import '../../core/utils/firebase_auth_service.dart';
import '../../di/service_locator.dart';
import '../../presentation/pages/splash/splash_page.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/profile/profile_page.dart';
import '../../presentation/pages/tiendas/tienda_detail_page.dart';
import '../../presentation/pages/productos/producto_detail_page.dart';
import '../../presentation/pages/plazoletas/plazoleta_list_page.dart';
import '../../presentation/pages/plazoletas/plazoleta_detail_page.dart';
import '../../presentation/pages/organizaciones/organizacion_list_page.dart';
import '../../presentation/pages/organizaciones/organizacion_detail_page.dart';
import '../../presentation/pages/favoritos/favoritos_page.dart';
import '../../presentation/pages/settings/settings_page.dart';
import '../../presentation/pages/soporte/soporte_page.dart';
import '../../presentation/pages/historial/historial_page.dart';
import '../../presentation/pages/settings/terminos_page.dart';
import '../../presentation/pages/settings/privacidad_page.dart';
import '../../domain/entities/organizacion.dart';
import '../../presentation/pages/admin/admin_shell_page.dart';
import '../../presentation/pages/admin/admin_plazoletas_page.dart';
import '../../presentation/pages/admin/admin_plazoleta_form_page.dart';
import '../../presentation/pages/admin/admin_categorias_page.dart';
import '../../presentation/pages/admin/admin_categoria_form_page.dart';
import '../../presentation/pages/admin/admin_usuarios_page.dart';
import '../../presentation/pages/admin/admin_tiendas_page.dart';
import '../../presentation/pages/admin/admin_organizaciones_page.dart';
import '../../presentation/pages/vendedor/vendedor_home_page.dart';
import '../../presentation/pages/vendedor/mis_tiendas_page.dart';
import '../../presentation/pages/vendedor/tienda_form_page.dart';
import '../../presentation/pages/vendedor/mis_productos_page.dart';
import '../../presentation/pages/vendedor/producto_form_page.dart';
import '../../presentation/pages/vendedor/mi_organizacion_page.dart';
import '../../presentation/pages/vendedor/invitaciones_page.dart';
import '../../presentation/pages/notificaciones/notificaciones_page.dart';

/// Configuración de rutas de la aplicación usando GoRouter
class AppRouter {
  static final _AuthRefreshListenable _refreshListenable =
      _AuthRefreshListenable();

  static final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/',
    refreshListenable: _refreshListenable,
    redirect: _redirect,
    routes: [
      // Ruta raíz - pantalla de splash
      GoRoute(
        path: '/',
        name: 'splash',
        pageBuilder:
            (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: const SplashPage(),
            ),
      ),

      // Ruta de splash explícita
      GoRoute(
        path: '/splash',
        name: 'splash_explicit',
        pageBuilder:
            (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: const SplashPage(),
            ),
      ),

      // Autenticación
      GoRoute(
        path: '/login',
        name: 'login',
        redirect: (context, state) {
          // Si estamos en proceso de logout, permitir acceso a login
          try {
            final authService = getIt<FirebaseAuthService>();
            if (authService.isSigningOut) {
              return null;
            }
          } catch (_) {
            // Si el servicio no está disponible, continuar con la verificación normal
          }

          final auth = FirebaseAuth.instance;
          final user = auth.currentUser;

          // Si el usuario ya está autenticado, redirigir a plazoletas
          if (user != null) {
            return '/plazoletas';
          }

          // Permitir acceso a login
          return null;
        },
        pageBuilder:
            (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: const LoginPage(),
            ),
      ),

      // Perfil de usuario (protegida)
      GoRoute(
        path: '/profile',
        name: 'profile',
        redirect: (context, state) {
          final auth = FirebaseAuth.instance;
          final user = auth.currentUser;

          // Si el usuario no está autenticado, redirigir a login
          if (user == null) {
            return '/login';
          }

          // Permitir acceso al perfil
          return null;
        },
        pageBuilder:
            (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: const ProfilePage(),
            ),
      ),

      // Favoritos (protegida)
      GoRoute(
        path: '/favoritos',
        name: 'favoritos',
        redirect: (context, state) {
          final auth = FirebaseAuth.instance;
          final user = auth.currentUser;

          // Si el usuario no está autenticado, redirigir a login
          if (user == null) {
            return '/login';
          }

          return null;
        },
        pageBuilder:
            (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: const FavoritosPage(),
            ),
      ),

      // Historial (protegida)
      GoRoute(
        path: '/historial',
        name: 'historial',
        redirect: (context, state) {
          final auth = FirebaseAuth.instance;
          final user = auth.currentUser;

          // Si el usuario no está autenticado, redirigir a login
          if (user == null) {
            return '/login';
          }

          return null;
        },
        pageBuilder:
            (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: const HistorialPage(),
            ),
      ),

      // Configuración (protegida)
      GoRoute(
        path: '/settings',
        name: 'settings',
        redirect: (context, state) {
          final auth = FirebaseAuth.instance;
          final user = auth.currentUser;

          // Si el usuario no está autenticado, redirigir a login
          if (user == null) {
            return '/login';
          }

          return null;
        },
        pageBuilder:
            (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: const SettingsPage(),
            ),
      ),

      // Términos y condiciones (protegida)
      GoRoute(
        path: '/terminos',
        name: 'terminos',
        redirect: (context, state) {
          final auth = FirebaseAuth.instance;
          final user = auth.currentUser;

          if (user == null) {
            return '/login';
          }

          return null;
        },
        pageBuilder:
            (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: const TerminosPage(),
            ),
      ),

      // Política de privacidad (protegida)
      GoRoute(
        path: '/privacidad',
        name: 'privacidad',
        redirect: (context, state) {
          final auth = FirebaseAuth.instance;
          final user = auth.currentUser;

          if (user == null) {
            return '/login';
          }

          return null;
        },
        pageBuilder:
            (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: const PrivacidadPage(),
            ),
      ),

      // Soporte (protegida)
      GoRoute(
        path: '/soporte',
        name: 'soporte',
        redirect: (context, state) {
          final auth = FirebaseAuth.instance;
          final user = auth.currentUser;

          // Si el usuario no está autenticado, redirigir a login
          if (user == null) {
            return '/login';
          }

          return null;
        },
        pageBuilder:
            (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: const SoportePage(),
            ),
      ),

      // Plazoletas (protegida)
      GoRoute(
        path: '/plazoletas',
        name: 'plazoletas',
        redirect: (context, state) {
          final auth = FirebaseAuth.instance;
          final user = auth.currentUser;

          // Si el usuario no está autenticado, redirigir a login
          if (user == null) {
            return '/login';
          }

          // Permitir acceso a plazoletas
          return null;
        },
        pageBuilder:
            (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: const PlazoletaListPage(),
            ),
      ),

      // Detalle de plazoleta (protegida)
      GoRoute(
        path: '/plazoletas/:id',
        name: 'plazoleta_detail',
        redirect: (context, state) {
          final auth = FirebaseAuth.instance;
          final user = auth.currentUser;

          // Si el usuario no está autenticado, redirigir a login
          if (user == null) {
            return '/login';
          }

          // Permitir acceso al detalle de plazoleta
          return null;
        },
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final plazoletaId = int.tryParse(id) ?? 0;
          return MaterialPage<void>(
            key: ValueKey('plazoleta_detail_$plazoletaId'),
            child: PlazoletaDetailPage(plazoletaId: plazoletaId),
          );
        },
      ),

      // Ruta legacy de plazoleta (para deep links de ShareService - usa slug)
      GoRoute(
        path: '/plazoleta/:slug',
        name: 'plazoleta_detail_legacy',
        redirect: (context, state) {
          final auth = FirebaseAuth.instance;
          final user = auth.currentUser;

          if (user == null) {
            return '/login';
          }

          return null;
        },
        pageBuilder: (context, state) {
          final slug = state.pathParameters['slug'] ?? '';
          debugPrint('🔄 ROUTER: /plazoleta/:slug pageBuilder - slug=$slug');
          return MaterialPage<void>(
            key: ValueKey('plazoleta_detail_slug_$slug'),
            child: PlazoletaDetailPage(plazoletaId: 0, slug: slug),
          );
        },
      ),

      // Detalle de tienda
      GoRoute(
        path: '/tiendas/:id',
        name: 'tienda_detail',
        pageBuilder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return MaterialPage<void>(
            key: state.pageKey,
            child: TiendaDetailPage(tiendaId: id),
          );
        },
      ),

      // Ruta legacy de tienda (para deep links de ShareService)
      GoRoute(
        path: '/store/:id',
        name: 'tienda_detail_legacy',
        pageBuilder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return MaterialPage<void>(
            key: state.pageKey,
            child: TiendaDetailPage(tiendaId: id),
          );
        },
      ),

      // Lista de organizaciones
      GoRoute(
        path: '/organizaciones',
        name: 'organizaciones',
        redirect: (context, state) {
          final auth = FirebaseAuth.instance;
          final user = auth.currentUser;

          // Si el usuario no está autenticado, redirigir a login
          if (user == null) {
            return '/login';
          }

          // Permitir acceso a organizaciones
          return null;
        },
        pageBuilder:
            (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: const OrganizacionListPage(),
            ),
      ),

      // Detalle de organización
      GoRoute(
        path: '/organizaciones/:id',
        name: 'organizacion_detail',
        redirect: (context, state) {
          final auth = FirebaseAuth.instance;
          final user = auth.currentUser;

          // Si el usuario no está autenticado, redirigir a login
          if (user == null) {
            return '/login';
          }

          // Permitir acceso a detalle de organización
          return null;
        },
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final organizacionId = int.tryParse(id) ?? 0;

          // Obtener organización de los argumentos si está disponible
          final organizacion = state.extra as Organizacion?;

          return MaterialPage<void>(
            key: state.pageKey,
            child: OrganizacionDetailPage(
              organizacionId: organizacionId,
              organizacion: organizacion,
            ),
          );
        },
      ),

      // Ruta legacy de organización (para deep links de ShareService)
      GoRoute(
        path: '/organizacion/:id',
        name: 'organizacion_detail_legacy',
        redirect: (context, state) {
          final auth = FirebaseAuth.instance;
          final user = auth.currentUser;

          if (user == null) {
            return '/login';
          }

          return null;
        },
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final organizacionId = int.tryParse(id) ?? 0;
          final organizacion = state.extra as Organizacion?;

          return MaterialPage<void>(
            key: state.pageKey,
            child: OrganizacionDetailPage(
              organizacionId: organizacionId,
              organizacion: organizacion,
            ),
          );
        },
      ),

      // Detalle de producto
      GoRoute(
        path: '/productos/:id',
        name: 'producto_detail',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final productoId = int.tryParse(id) ?? 0;
          final producto = state.extra as Map<String, dynamic>?;
          return MaterialPage<void>(
            key: state.pageKey,
            child: ProductoDetailPage(
              productoId: productoId,
              producto: producto,
            ),
          );
        },
      ),

      // Ruta legacy de producto (para deep links de ShareService)
      GoRoute(
        path: '/producto/:id',
        name: 'producto_detail_legacy',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final productoId = int.tryParse(id) ?? 0;
          final producto = state.extra as Map<String, dynamic>?;
          return MaterialPage<void>(
            key: state.pageKey,
            child: ProductoDetailPage(
              productoId: productoId,
              producto: producto,
            ),
          );
        },
      ),

      // Administración
      GoRoute(
        path: '/admin',
        name: 'admin',
        pageBuilder:
            (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: const AdminShellPage(),
            ),
      ),

      GoRoute(
        path: '/admin/plazoletas',
        name: 'admin_plazoletas',
        pageBuilder:
            (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: const AdminPlazoletasPage(),
            ),
      ),

      GoRoute(
        path: '/admin/plazoletas/nueva',
        name: 'admin_plazoleta_nueva',
        pageBuilder:
            (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: const AdminPlazoletaFormPage(),
            ),
      ),

      GoRoute(
        path: '/admin/plazoletas/:id/editar',
        name: 'admin_plazoleta_editar',
        pageBuilder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          return MaterialPage<void>(
            key: state.pageKey,
            child: AdminPlazoletaFormPage(plazoletaId: id),
          );
        },
      ),

      GoRoute(
        path: '/admin/categorias',
        name: 'admin_categorias',
        pageBuilder:
            (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: const AdminCategoriasPage(),
            ),
      ),

      GoRoute(
        path: '/admin/categorias/nueva',
        name: 'admin_categoria_nueva',
        pageBuilder:
            (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: const AdminCategoriaFormPage(),
            ),
      ),

      GoRoute(
        path: '/admin/categorias/:id/editar',
        name: 'admin_categoria_editar',
        pageBuilder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          return MaterialPage<void>(
            key: state.pageKey,
            child: AdminCategoriaFormPage(categoriaId: id),
          );
        },
      ),

      GoRoute(
        path: '/admin/usuarios',
        name: 'admin_usuarios',
        pageBuilder:
            (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: const AdminUsuariosPage(),
            ),
      ),

      GoRoute(
        path: '/admin/tiendas',
        name: 'admin_tiendas',
        pageBuilder:
            (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: const AdminTiendasPage(),
            ),
      ),

      GoRoute(
        path: '/admin/organizaciones',
        name: 'admin_organizaciones',
        pageBuilder:
            (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: const AdminOrganizacionesPage(),
            ),
      ),

      // Panel del vendedor
      GoRoute(
        path: '/vendedor',
        name: 'vendedor',
        pageBuilder:
            (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: const VendedorHomePage(),
            ),
      ),

      GoRoute(
        path: '/vendedor/tiendas',
        name: 'vendedor_tiendas',
        pageBuilder:
            (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: const MisTiendasPage(),
            ),
      ),

      GoRoute(
        path: '/vendedor/tiendas/nueva',
        name: 'vendedor_tienda_nueva',
        pageBuilder:
            (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: const TiendaFormPage(),
            ),
      ),

      GoRoute(
        path: '/vendedor/tiendas/:id/editar',
        name: 'vendedor_tienda_editar',
        pageBuilder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          return MaterialPage<void>(
            key: state.pageKey,
            child: TiendaFormPage(tiendaId: id),
          );
        },
      ),

      GoRoute(
        path: '/vendedor/productos',
        name: 'vendedor_productos',
        pageBuilder:
            (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: const MisProductosPage(),
            ),
      ),

      GoRoute(
        path: '/vendedor/productos/nuevo',
        name: 'vendedor_producto_nuevo',
        pageBuilder:
            (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: const ProductoFormPage(),
            ),
      ),

      GoRoute(
        path: '/vendedor/productos/:id/editar',
        name: 'vendedor_producto_editar',
        pageBuilder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          return MaterialPage<void>(
            key: state.pageKey,
            child: ProductoFormPage(productoId: id),
          );
        },
      ),

      GoRoute(
        path: '/vendedor/organizacion',
        name: 'vendedor_organizacion',
        pageBuilder:
            (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: const MiOrganizacionPage(),
            ),
      ),

      GoRoute(
        path: '/vendedor/invitaciones',
        name: 'vendedor_invitaciones',
        pageBuilder:
            (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: const InvitacionesPage(),
            ),
      ),

      // Notificaciones
      GoRoute(
        path: '/notificaciones',
        name: 'notificaciones',
        pageBuilder:
            (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: const NotificacionesPage(),
            ),
      ),

      // Ruta de error 404
      GoRoute(
        path: '/error',
        name: 'error',
        pageBuilder:
            (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: Scaffold(
                appBar: const CustomAppBar(
                  title: 'Error',
                  showProfileButton: false,
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Página no encontrada',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        state.uri.toString(),
                        style: const TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => context.go('/'),
                        child: const Text('Ir al Inicio'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      ),
    ],

    // Manejo de errores
    errorPageBuilder:
        (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: Scaffold(
            appBar: const CustomAppBar(
              title: 'Error',
              showProfileButton: false,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 20),
                  const Text(
                    'Ha ocurrido un error',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    state.error?.toString() ?? 'Error desconocido',
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Ir al Inicio'),
                  ),
                ],
              ),
            ),
          ),
        ),

    // Observador de rutas
    observers: [
      // TODO: Agregar observadores para analytics o logging
    ],
  );

  static int? _currentRoleId() {
    try {
      return getIt<FirebaseAuthService>().currentRoleId;
    } catch (_) {
      return null;
    }
  }

  static String _homeForRole(int roleId) {
    switch (roleId) {
      case 1:
        return '/admin';
      case 2:
        return '/vendedor';
      default:
        return '/plazoletas';
    }
  }

  static String? _redirect(BuildContext context, GoRouterState state) {
    final location = state.uri.path;

    try {
      if (getIt<FirebaseAuthService>().isSigningOut) {
        return null;
      }
    } catch (_) {}

    final user = FirebaseAuth.instance.currentUser;
    final isPublic =
        location == '/' ||
        location == '/splash' ||
        location == '/login' ||
        location == '/error';

    if (user == null) {
      return isPublic ? null : '/login';
    }

    final roleId = _currentRoleId();

    if (roleId == null) {
      if (location == '/' || location == '/splash') {
        return null;
      }
      return '/splash';
    }

    final home = _homeForRole(roleId);

    if (location == '/' || location == '/splash' || location == '/login') {
      return home;
    }

    if (roleId == 1) {
      if (location == '/error') return null;
      if (!location.startsWith('/admin')) return '/admin';
      return null;
    }

    if (location.startsWith('/admin')) return home;
    if (location.startsWith('/vendedor') && roleId != 2) return home;

    return null;
  }

  /// Método auxiliar para navegar a una ruta
  static void go(BuildContext context, String location, {Object? extra}) {
    context.go(location, extra: extra);
  }

  /// Método auxiliar para navegar a una ruta nombrada
  static void goNamed(
    BuildContext context,
    String name, {
    Map<String, String> params = const {},
    Map<String, dynamic> queryParams = const {},
    Object? extra,
  }) {
    context.goNamed(
      name,
      pathParameters: params,
      queryParameters: queryParams,
      extra: extra,
    );
  }

  /// Método auxiliar para push a una ruta
  static Future<T?> push<T>(
    BuildContext context,
    String location, {
    Object? extra,
  }) {
    return context.push<T>(location, extra: extra);
  }

  /// Método auxiliar para push a una ruta nombrada
  static Future<T?> pushNamed<T>(
    BuildContext context,
    String name, {
    Map<String, String> params = const {},
    Map<String, dynamic> queryParams = const {},
    Object? extra,
  }) {
    return context.pushNamed<T>(
      name,
      pathParameters: params,
      queryParameters: queryParams,
      extra: extra,
    );
  }

  /// Método auxiliar para pop
  static void pop(BuildContext context, [dynamic result]) {
    context.pop(result);
  }

  /// Verificar si se puede pop
  static bool canPop(BuildContext context) {
    return context.canPop();
  }

  /// Obtener la ruta actual
  static String currentLocation(BuildContext context) {
    return GoRouterState.of(context).uri.toString();
  }

  /// Obtener parámetros de la ruta actual
  static Map<String, String> currentParams(BuildContext context) {
    return GoRouterState.of(context).pathParameters;
  }

  /// Obtener parámetros de query de la ruta actual
  static Map<String, String> currentQueryParams(BuildContext context) {
    return GoRouterState.of(context).uri.queryParameters;
  }

  /// Obtener extra de la ruta actual
  static Object? currentExtra(BuildContext context) {
    return GoRouterState.of(context).extra;
  }
}

class _AuthRefreshListenable extends ChangeNotifier {
  StreamSubscription<AuthState>? _authSubscription;
  StreamSubscription<void>? _profileSubscription;

  _AuthRefreshListenable() {
    try {
      final auth = getIt<FirebaseAuthService>();
      _authSubscription = auth.onAuthStateChanged.listen((_) {
        notifyListeners();
      });
      _profileSubscription = auth.onProfileChanged.listen((_) {
        notifyListeners();
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _profileSubscription?.cancel();
    super.dispose();
  }
}
