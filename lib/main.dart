// lib/main.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'presentation/blocs/image/image_bloc.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/plazoleta/plazoleta_bloc.dart';
import 'presentation/blocs/tienda/tienda_bloc.dart';
import 'presentation/blocs/producto/producto_bloc.dart';
import 'presentation/blocs/organizacion/organizacion_bloc.dart';
import 'presentation/blocs/favorito/favorito_bloc.dart';
import 'presentation/providers/theme_provider.dart';

import 'core/utils/firebase_config_loader.dart';

import 'core/routing/app_router.dart';
import 'di/service_locator.dart';
import 'core/app/app_config.dart';
import 'core/theme/app_theme.dart';

void main() async {
  // Asegurar que Flutter esté inicializado
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Cargar variables de entorno
    await dotenv.load(fileName: '.env');

    // Inicializar configuración de la aplicación
    final appConfig = AppConfig();
    await appConfig.initializeFromEnv(dotenv.env);

    // Inicializar Firebase desde variables de entorno
    try {
      final firebaseOptions = FirebaseConfigLoader.loadFromEnv(dotenv.env);
      await Firebase.initializeApp(options: firebaseOptions);
    } catch (firebaseError) {
      rethrow;
    }

    // Inicializar inyección de dependencias
    await setupServiceLocator(appConfig);

    // Inicializar ThemeProvider
    final themeProvider = ThemeProvider();
    await themeProvider.initialize();

    // Ejecutar aplicación
    runApp(
      ChangeNotifierProvider<ThemeProvider>.value(
        value: themeProvider,
        child: const PaseoDelComercioApp(),
      ),
    );
  } catch (e) {
    // Manejar errores de inicialización
    runApp(
      MaterialApp(
        home: Scaffold(
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
                    'Detalles: $e',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Recargar la aplicación
                      main();
                    },
                    child: const Text('Reintentar'),
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

class PaseoDelComercioApp extends StatelessWidget {
  const PaseoDelComercioApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Verificar estado de Firebase
    try {
      Firebase.app(); // Esto lanzará excepción si Firebase no está inicializado
    } catch (e) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 64),
                const SizedBox(height: 20),
                const Text(
                  'Error de Firebase',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Firebase no se inicializó correctamente',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Recargar la aplicación
                    main();
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: getIt<AuthBloc>()),
        BlocProvider<PlazoletaBloc>.value(value: getIt<PlazoletaBloc>()),
        BlocProvider<TiendaBloc>.value(value: getIt<TiendaBloc>()),
        BlocProvider<ProductoBloc>.value(value: getIt<ProductoBloc>()),
        BlocProvider<ImageBloc>.value(value: getIt<ImageBloc>()),
        BlocProvider<OrganizacionBloc>.value(value: getIt<OrganizacionBloc>()),
        BlocProvider<FavoritoBloc>.value(value: getIt<FavoritoBloc>()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: AppConfig().appName,
            locale: const Locale('es', 'ES'),
            routerConfig: AppRouter.router,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
          );
        },
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

    // Usar la aplicación principal que ya incluye el enrutador
    return const PaseoDelComercioApp();
  }
}
