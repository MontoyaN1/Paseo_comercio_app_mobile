// lib/main.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';

import 'presentation/blocs/image/image_bloc.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/plazoleta/plazoleta_bloc.dart';
import 'presentation/blocs/tienda/tienda_bloc.dart';
import 'presentation/blocs/producto/producto_bloc.dart';
import 'presentation/blocs/organizacion/organizacion_bloc.dart';

import 'core/utils/firebase_config_loader.dart';

import 'core/routing/app_router.dart';
import 'di/service_locator.dart';
import 'core/app/app_config.dart';

void main() async {
  // Asegurar que Flutter esté inicializado
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print('🚀 Iniciando aplicación Paseo del Comercio...');

    // Cargar variables de entorno
    print('📁 Cargando variables de entorno...');
    await dotenv.load(fileName: '.env');
    print('✅ Variables de entorno cargadas');

    // Inicializar configuración de la aplicación
    print('⚙️ Inicializando configuración de la aplicación...');
    final appConfig = AppConfig();
    await appConfig.initializeFromEnv(dotenv.env);
    print('✅ Configuración de aplicación inicializada');
    print('📊 Estado configuración:');
    print('   - Supabase: ${appConfig.isSupabaseConfigured ? "✅" : "❌"}');
    print('   - Firebase: ${appConfig.isFirebaseConfigured ? "✅" : "❌"}');
    print('   - R2: ${appConfig.isR2Configured ? "✅" : "❌"}');
    print('   - S3: ${appConfig.isS3Configured ? "✅" : "❌"}');

    // Inicializar Firebase desde variables de entorno
    print('🔥 Inicializando Firebase...');
    try {
      final firebaseOptions = FirebaseConfigLoader.loadFromEnv(dotenv.env);
      print('✅ Configuración de Firebase cargada desde variables de entorno');
      print('   - Project ID: ${firebaseOptions.projectId}');
      print(
        '   - API Key presente: ${firebaseOptions.apiKey.isNotEmpty ? "✅" : "❌"}',
      );
      print(
        '   - App ID presente: ${firebaseOptions.appId.isNotEmpty ? "✅" : "❌"}',
      );

      await Firebase.initializeApp(options: firebaseOptions);
      print('✅ Firebase inicializado correctamente');
    } catch (firebaseError) {
      print('❌ Error al inicializar Firebase: $firebaseError');
      rethrow;
    }

    // Inicializar inyección de dependencias
    print('💉 Inicializando inyección de dependencias...');
    await setupServiceLocator(appConfig);
    print('✅ Inyección de dependencias configurada');

    // Ejecutar aplicación
    print('🎬 Ejecutando aplicación...');
    runApp(const PaseoDelComercioApp());
    print('✅ Aplicación en ejecución');
  } catch (e) {
    // Manejar errores de inicialización
    print('❌ ERROR CRÍTICO durante la inicialización: $e');
    print('📋 Stack trace: ${e.toString()}');
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
    print('🏗️ Construyendo widget PaseoDelComercioApp...');

    // Verificar estado de Firebase
    try {
      Firebase.app(); // Esto lanzará excepción si Firebase no está inicializado
      print('✅ Firebase está inicializado en la aplicación');
    } catch (e) {
      print('❌ Firebase NO está inicializado: $e');
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
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: AppConfig().debugMode,
        title: AppConfig().appName,

        // Localización
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

    // Usar la aplicación principal que ya incluye el enrutador
    return const PaseoDelComercioApp();
  }
}
