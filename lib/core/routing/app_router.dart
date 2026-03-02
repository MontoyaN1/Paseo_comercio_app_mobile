// lib/core/routing/app_router.dart

import '../../presentation/widgets/custom_app_bar.dart';

import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../presentation/pages/splash/splash_page.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/profile/profile_page.dart';
import '../../presentation/pages/tiendas/tienda_list_page.dart';
import '../../presentation/pages/productos/producto_list_page.dart';
import '../../presentation/pages/plazoletas/plazoleta_list_page.dart';
import '../../presentation/pages/plazoletas/plazoleta_detail_page.dart';

/// Configuración de rutas de la aplicación usando GoRouter
class AppRouter {
  static final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/',
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
            key: state.pageKey,
            child: PlazoletaDetailPage(plazoletaId: plazoletaId),
          );
        },
      ),

      // Tiendas (protegida)
      GoRoute(
        path: '/tiendas',
        name: 'tiendas',
        redirect: (context, state) {
          final auth = FirebaseAuth.instance;
          final user = auth.currentUser;

          // Si el usuario no está autenticado, redirigir a login
          if (user == null) {
            return '/login';
          }

          // Permitir acceso a tiendas
          return null;
        },
        pageBuilder:
            (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: const TiendaListPage(),
            ),
      ),

      // Detalle de tienda (placeholder - por implementar)
      GoRoute(
        path: '/tiendas/:id',
        name: 'tienda_detail',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return MaterialPage<void>(
            key: state.pageKey,
            child: Scaffold(
              appBar: AppBar(title: Text('Tienda $id')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Detalle de Tienda $id'),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => context.go('/tiendas'),
                      child: const Text('Volver a Tiendas'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),

      // Productos (protegida)
      GoRoute(
        path: '/productos',
        name: 'productos',
        redirect: (context, state) {
          final auth = FirebaseAuth.instance;
          final user = auth.currentUser;

          // Si el usuario no está autenticado, redirigir a login
          if (user == null) {
            return '/login';
          }

          // Permitir acceso a productos
          return null;
        },
        pageBuilder:
            (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: const ProductoListPage(),
            ),
      ),

      // Detalle de producto (placeholder - por implementar)
      GoRoute(
        path: '/productos/:id',
        name: 'producto_detail',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return MaterialPage<void>(
            key: state.pageKey,
            child: Scaffold(
              appBar: AppBar(title: Text('Producto $id')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Detalle de Producto $id'),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => context.go('/productos'),
                      child: const Text('Volver a Productos'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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

    // Redirecciones
    redirect: (context, state) {
      // TODO: Implementar lógica de redirección basada en autenticación
      // Por ejemplo:
      // - Si el usuario no está autenticado y trata de acceder a rutas protegidas
      // - Si el usuario está autenticado y trata de acceder a login/register

      return null; // No redirigir
    },

    // Observador de rutas
    observers: [
      // TODO: Agregar observadores para analytics o logging
    ],
  );

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
