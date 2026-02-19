// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:clerk_flutter/generated/clerk_sdk_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/app/app_config.dart';
import 'core/routing/app_router.dart';
import 'di/service_locator.dart';
import 'presentation/pages/auth/login_page.dart';

void main() async {
  // Asegurar que Flutter esté inicializado
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Cargar variables de entorno
    await dotenv.load(fileName: '.env');

    // Inicializar configuración de la aplicación
    final appConfig = AppConfig();
    await appConfig.initializeFromEnv(dotenv.env);

    // Inicializar inyección de dependencias
    await setupServiceLocator(appConfig);

    // Ejecutar aplicación
    runApp(const PaseoDelComercioApp());
  } catch (e) {
    // Manejar errores de inicialización
    print('Error durante la inicialización: $e');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'Error de inicialización: $e',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}

class PaseoDelComercioApp extends StatelessWidget {
  const PaseoDelComercioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ClerkAuth(
      config: ClerkAuthConfig(publishableKey: AppConfig().clerkPublishableKey),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: AppConfig().debugMode,
        title: AppConfig().appName,

        // Localización
        localizationsDelegates: ClerkSdkLocalizations.localizationsDelegates,
        supportedLocales: ClerkSdkLocalizations.supportedLocales,
        locale: const Locale('es', 'ES'),

        // Tema
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Inter',
          scaffoldBackgroundColor: const Color(0xFFF8F9FA),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF121212),
            elevation: 4,
            centerTitle: true,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
            ),
            displayMedium: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              fontFamily: 'Inter',
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              fontFamily: 'Inter',
            ),
          ),
        ),

        // Router configuration
        routerConfig: AppRouter.router,
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Inicializar servicios necesarios
      await getIt.allReady();

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 20),
                const Text(
                  'Error de inicialización',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _initializeApp,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                'Inicializando ${AppConfig().appName}...',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return ClerkAuthBuilder(
      signedOutBuilder: (context, state) => LoginPage(),
      signedInBuilder: (context, state) => const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 6,
        title: Text(
          AppConfig().appName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          ClerkAuthBuilder(
            signedInBuilder: (context, state) {
              final user = ClerkAuth.of(context).user;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    // Navegar a perfil usando GoRouter
                    context.go('/profile');
                  },
                  child: CircleAvatar(
                    radius: 18,
                    backgroundImage:
                        (user?.imageUrl != null && user!.imageUrl!.isNotEmpty)
                            ? NetworkImage(user.imageUrl!)
                            : null,
                    child:
                        (user?.imageUrl == null || user!.imageUrl!.isEmpty)
                            ? const Icon(Icons.person)
                            : null,
                  ),
                ),
              );
            },
            signedOutBuilder: (context, state) {
              return TextButton(
                onPressed: () {
                  // Navegar a login usando GoRouter
                  context.go('/login');
                },
                child: const Text(
                  'Iniciar sesión',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront, size: 64, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'Bienvenido al Centro Comercial Virtual',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Explora tiendas, productos y mucho más',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Tiendas'),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categorías',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          // Navegación entre páginas usando GoRouter
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/tiendas');
              break;
            case 2:
              context.go('/productos');
              break;
            case 3:
              context.go('/profile');
              break;
          }
        },
      ),
    );
  }
}
