// lib/main_supabase.dart
// Archivo simple para probar conexión con backend Supabase
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Obtener URL de Supabase desde múltiples fuentes
String _getSupabaseUrl() {
  // 1. Intentar desde variables de entorno de compilación (primera prioridad)
  final fromCompile = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  if (fromCompile.isNotEmpty) {
    print('⚙️  URL obtenida desde variables de compilación');
    print('   Longitud: ${fromCompile.length} caracteres');
    return fromCompile;
  }

  // 2. Intentar desde archivo .env (si se cargó correctamente)
  try {
    final fromEnv = dotenv.get('SUPABASE_URL', fallback: '');
    if (fromEnv.isNotEmpty) {
      print('📄 URL obtenida desde archivo .env');
      print('   Longitud: ${fromEnv.length} caracteres');
      return fromEnv;
    }
  } catch (e) {
    print('⚠️  No se pudo leer SUPABASE_URL desde dotenv: $e');
    // Continuar con otras fuentes
  }

  print('❌ No se encontró SUPABASE_URL en ninguna fuente');
  return '';
}

/// Obtener clave anónima de Supabase desde múltiples fuentes
String _getSupabaseAnonKey() {
  // 1. Intentar desde variables de entorno de compilación (primera prioridad)
  final fromCompile = String.fromEnvironment(
    'SUPABASE_SERVICE_ROLE_KEY',
    defaultValue: '',
  );
  if (fromCompile.isNotEmpty) {
    print('⚙️  Service Role Key obtenida desde variables de compilación');
    print('   Longitud: ${fromCompile.length} caracteres');
    return fromCompile;
  }

  // 2. Intentar desde archivo .env (si se cargó correctamente)
  try {
    final fromEnv = dotenv.get('SUPABASE_SERVICE_ROLE_KEY', fallback: '');
    if (fromEnv.isNotEmpty) {
      print('📄 Service Role Key obtenida desde archivo .env');
      print('   Longitud: ${fromEnv.length} caracteres');
      return fromEnv;
    }
  } catch (e) {
    print('⚠️  No se pudo leer SUPABASE_SERVICE_ROLE_KEY desde dotenv: $e');
    // Continuar con otras fuentes
  }

  print('❌ No se encontró SUPABASE_SERVICE_ROLE_KEY en ninguna fuente');
  return '';
}

/// Parsear contenido de archivo .env
Map<String, String> parseEnvString(String content) {
  final Map<String, String> envMap = {};
  final lines = content.split('\n');

  for (final line in lines) {
    final trimmedLine = line.trim();
    // Ignorar líneas vacías y comentarios
    if (trimmedLine.isEmpty || trimmedLine.startsWith('#')) {
      continue;
    }

    // Buscar el primer '=' que no esté entre comillas
    final equalsIndex = trimmedLine.indexOf('=');
    if (equalsIndex <= 0) {
      continue; // Línea inválida
    }

    final key = trimmedLine.substring(0, equalsIndex).trim();
    var value = trimmedLine.substring(equalsIndex + 1).trim();

    // Remover comillas simples o dobles si están presentes
    if ((value.startsWith('"') && value.endsWith('"')) ||
        (value.startsWith("'") && value.endsWith("'"))) {
      value = value.substring(1, value.length - 1);
    }

    if (key.isNotEmpty) {
      envMap[key] = value;
    }
  }

  return envMap;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 Iniciando prueba de backend Supabase...');

  // Cargar variables de entorno desde archivo .env
  bool dotenvLoaded = false;

  try {
    print('📦 Intentando cargar .env desde assets...');
    // Cargar el archivo .env desde assets usando rootBundle
    final envString = await rootBundle.loadString('.env');
    final envMap = parseEnvString(envString);

    // Cargar las variables parseadas en dotenv
    dotenv.env.addAll(envMap);
    dotenvLoaded = true;
    print('✅ Variables de entorno cargadas desde .env (assets)');
    print('📋 Variables cargadas: ${envMap.keys.join(', ')}');
  } catch (e) {
    print('⚠️  No se pudo cargar .env desde assets: $e');

    // Fallback: intentar cargar desde filesystem (para desarrollo)
    try {
      print('📁 Intentando cargar .env desde filesystem...');
      await dotenv.load(fileName: '.env');
      dotenvLoaded = true;
      print('✅ Variables de entorno cargadas desde .env (filesystem)');
    } catch (e2) {
      print('⚠️  Tampoco se pudo cargar .env desde filesystem: $e2');
      print('ℹ️  Continuando con variables de compilación como fallback');
    }
  }

  // Mostrar variables cargadas (si se cargaron)
  if (dotenvLoaded) {
    try {
      final allEnvVars = dotenv.env;
      print(
        '📋 Variables disponibles en dotenv: ${allEnvVars.keys.join(', ')}',
      );
      if (allEnvVars.containsKey('SUPABASE_URL')) {
        final url = dotenv.get('SUPABASE_URL');
        print(
          '📄 SUPABASE_URL cargada: ${url.length > 10 ? '${url.substring(0, 10)}...' : 'DEMASIADO_CORTA'}',
        );
      }
      if (allEnvVars.containsKey('SUPABASE_SERVICE_ROLE_KEY')) {
        final key = dotenv.get('SUPABASE_SERVICE_ROLE_KEY');
        print(
          '📄 SUPABASE_SERVICE_ROLE_KEY cargada: ${key.length > 5 ? '${key.substring(0, 5)}...' : 'DEMASIADO_CORTA'}',
        );
      }
    } catch (e) {
      print('⚠️  No se pudieron leer variables de dotenv: $e');
    }
  }

  // Combinar fuentes de variables: primero dotenv, luego compile-time
  final supabaseUrl = _getSupabaseUrl();
  final supabaseAnonKey = _getSupabaseAnonKey();

  // Depuración: mostrar valores obtenidos
  print(
    '🔍 URL obtenida: ${supabaseUrl.isEmpty ? 'VACÍA' : '${supabaseUrl.length} caracteres'}',
  );
  print(
    '🔍 Service Role Key obtenida: ${supabaseAnonKey.isEmpty ? 'VACÍA' : '${supabaseAnonKey.length} caracteres'}',
  );
  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    print('✅ Credenciales de Supabase obtenidas exitosamente');
  } else {
    print('❌ Falta una o ambas credenciales de Supabase');
    print('');
    print('📝 Soluciones:');
    print(
      '   1. Asegúrate de que el archivo .env exista en la raíz del proyecto',
    );
    print(
      '   2. Verifica que el archivo .env esté incluido en assets en pubspec.yaml',
    );
    print(
      '   3. Agrega las variables SUPABASE_URL y SUPABASE_SERVICE_ROLE_KEY al archivo .env',
    );
    print('   4. O usa variables de compilación:');
    print('      flutter run lib/main_supabase.dart \\');
    print('        --dart-define=SUPABASE_URL=tu_url \\');
    print('        --dart-define=SUPABASE_SERVICE_ROLE_KEY=tu_clave');
    print('');
  }

  bool supabaseInitialized = false;
  String? initializationError;

  // Verificar si las variables están configuradas
  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    print('⚠️  Advertencia: Variables de Supabase no configuradas');
    print('');
    print('   Fuentes disponibles:');
    print('   1. Archivo .env en la raíz del proyecto');
    print('   2. Variables de entorno de compilación (--dart-define)');
    print('');
    print('   Solución 1: Crea/modifica el archivo .env con:');
    print('     SUPABASE_URL=tu_url');
    print('     SUPABASE_SERVICE_ROLE_KEY=tu_clave');
    print('');
    print('   Solución 2: Ejecuta con:');
    print('   flutter run lib/main_supabase.dart \\');
    print('     --dart-define=SUPABASE_URL=tu_url \\');
    print('     --dart-define=SUPABASE_SERVICE_ROLE_KEY=tu_clave');
  } else {
    try {
      print('🔄 Inicializando Supabase...');
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: true,
      );
      supabaseInitialized = true;
      print('✅ Supabase inicializado correctamente');
    } catch (e) {
      initializationError = e.toString();
      print('❌ Error al inicializar Supabase: $e');
    }
  }

  runApp(
    PaseoDelComercioApp(
      supabaseInitialized: supabaseInitialized,
      initializationError: initializationError,
    ),
  );
}

class PaseoDelComercioApp extends StatelessWidget {
  final bool supabaseInitialized;
  final String? initializationError;

  const PaseoDelComercioApp({
    super.key,
    required this.supabaseInitialized,
    this.initializationError,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Backend Supabase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      ),
      home: HomePage(
        supabaseInitialized: supabaseInitialized,
        initializationError: initializationError,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final bool supabaseInitialized;
  final String? initializationError;

  const HomePage({
    super.key,
    required this.supabaseInitialized,
    this.initializationError,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SupabaseClient? _supabase;
  List<Map<String, dynamic>> _tiendas = [];
  bool _loading = true;
  String? _error;
  bool _supabaseConfigured = false;
  int _currentPage = 1;
  int _itemsPerPage = 20;
  bool _hasMoreItems = true;

  @override
  void initState() {
    super.initState();
    _initializeSupabase(cargarTiendas: true);
  }

  void _initializeSupabase({bool cargarTiendas = true}) {
    try {
      _supabase = Supabase.instance.client;
      _supabaseConfigured = widget.supabaseInitialized;

      if (widget.initializationError != null) {
        _error = 'Error de inicialización: ${widget.initializationError}';
        _supabaseConfigured = false;
      }
    } catch (e) {
      _supabaseConfigured = false;
      _error = 'Error al obtener cliente Supabase: $e';
    }

    if (_supabaseConfigured && cargarTiendas) {
      // Cargar tiendas automáticamente
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _cargarTiendas();
      });
    } else {
      _loading = false;
    }
  }

  Future<void> _cargarTiendas({bool resetPagination = true}) async {
    if (!_supabaseConfigured || _supabase == null) {
      setState(() {
        _error =
            widget.initializationError ??
            'Supabase no está configurado. Verifica las variables de entorno.';
        _loading = false;
      });
      return;
    }

    if (resetPagination) {
      _currentPage = 1;
      _hasMoreItems = true;
    }

    print('🔄=== NUEVA CONSULTA DE TIENDAS (Página $_currentPage) ===');
    print('📡 Usando cliente: ${_supabase != null ? "OK" : "NULL"}');

    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      print('🔄 Ejecutando consulta de tiendas...');

      // Calcular rango para paginación
      final from = (_currentPage - 1) * _itemsPerPage;
      final to = from + _itemsPerPage - 1;

      // Consulta con paginación
      print('🔍 Consulta con paginación (${from}-${to})...');
      final response = await _supabase!
          .from('tienda')
          .select()
          .order('fecha_creacion', ascending: false)
          .range(from, to)
          .timeout(const Duration(seconds: 15));

      print(
        '📊 Resultado consulta: ${response is List ? response.length : response.runtimeType} elementos',
      );

      // Manejar respuesta
      List<dynamic> data = [];
      if (response is List) {
        data = response;
        // Verificar si hay más elementos
        if (data.length < _itemsPerPage) {
          _hasMoreItems = false;
          print('📊 Última página alcanzada');
        } else {
          _hasMoreItems = true;
        }
      }

      print('✅ Consulta completada, procesando respuesta...');
      print('📊 Datos obtenidos: ${data.length} elementos');

      if (data.isEmpty && _currentPage == 1) {
        print('⚠️  La consulta devolvió 0 resultados');
        print('🔍 Verificando posibles causas:');
        print('   1. Políticas RLS bloquean acceso anónimo');
        print('   2. La tabla está vacía');
        print('   3. Schema diferente (¿está en "public.tienda"?)');
      }

      final newTiendas =
          data.map((item) {
            try {
              return item as Map<String, dynamic>;
            } catch (e) {
              print('⚠️  Error al castear item a Map: $e');
              print('📊 Item tipo: ${item.runtimeType}');
              print('📊 Item valor: $item');
              return <String, dynamic>{};
            }
          }).toList();

      setState(() {
        if (resetPagination) {
          _tiendas = newTiendas;
        } else {
          _tiendas.addAll(newTiendas);
        }
        _loading = false;
      });

      print('✅ Tiendas cargadas: ${_tiendas.length}');
      if (_tiendas.isEmpty && _currentPage == 1) {
        print('ℹ️  La consulta no devolvió tiendas, verifica:');
        print('   1. Que la tabla "tienda" existe en Supabase');
        print('   2. Que hay registros en la tabla');
        print('   3. Que las políticas RLS permiten acceso anónimo');
      }
    } catch (e) {
      print('❌ Error al cargar tiendas: $e');
      setState(() {
        _error = 'Error al cargar tiendas: $e';
        _loading = false;
        _supabaseConfigured = false;
      });
    }
  }

  Future<void> _cargarMasTiendas() async {
    if (!_loading && _hasMoreItems) {
      _currentPage++;
      await _cargarTiendas(resetPagination: false);
    }
  }

  Future<void> _probarConexion() async {
    if (!_supabaseConfigured || _supabase == null) {
      setState(() {
        _error = 'Supabase no está configurado.';
      });
      return;
    }

    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      await _supabase!
          .from('tienda')
          .select('count')
          .limit(1)
          .timeout(const Duration(seconds: 10));

      setState(() {
        _loading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Conexión con Supabase exitosa'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Error de conexión: $e';
        _loading = false;
        _supabaseConfigured = false;
      });
    }
  }

  Future<void> _verificarTablaTienda() async {
    if (!_supabaseConfigured || _supabase == null) {
      print('❌ Supabase no está configurado para verificación');
      return;
    }

    print('🔍=== PRUEBA RLS Y ESQUEMA DETALLADA ===');

    try {
      print('🔍 Iniciando verificación detallada de tabla tienda...');

      // Mostrar información básica de conexión
      print(
        '📡 Estado de Supabase: ${_supabase != null ? "Conectado" : "No conectado"}',
      );
      print('📡 Configuración Supabase: $_supabaseConfigured');
      print(
        '📡 Error de inicialización: ${widget.initializationError ?? "Ninguno"}',
      );

      // Verificar URL (HTTP vs HTTPS)
      final url = dotenv.get('SUPABASE_URL', fallback: '');
      final supabaseAnonKey = dotenv.get(
        'SUPABASE_SERVICE_ROLE_KEY',
        fallback: '',
      );

      // 0. Mostrar credenciales (parcialmente)
      print('🔑 URL Supabase: ${url.substring(0, min(30, url.length))}...');
      print('🔑 Service Role Key length: ${supabaseAnonKey.length}');

      // 1. Verificar si la tabla existe con una consulta simple
      print('📊 Verificando existencia de tabla...');
      if (url.isNotEmpty) {
        if (url.startsWith('http://')) {
          print(
            '⚠️  URL usa HTTP (no seguro). Supabase en producción requiere HTTPS.',
          );
        } else if (url.startsWith('https://')) {
          print('✅ URL usa HTTPS (seguro)');
        }
      }
      final countResponse = await _supabase!
          .from('tienda')
          .select('count')
          .limit(1)
          .timeout(const Duration(seconds: 10));

      print('📊 Respuesta de count: ${countResponse.runtimeType}');
      print('📊 Contenido de count: $countResponse');

      // 2. Obtener estructura de la tabla (primer registro)
      print('📊 Obteniendo estructura de tabla...');
      final estructuraResponse = await _supabase!
          .from('tienda')
          .select()
          .limit(1)
          .timeout(const Duration(seconds: 10));

      print('📊 Respuesta de estructura: ${estructuraResponse.runtimeType}');
      if (estructuraResponse is List && estructuraResponse.isNotEmpty) {
        print('📊 Primer registro: ${estructuraResponse.first}');
        print(
          '📊 Campos disponibles: ${(estructuraResponse.first as Map).keys.join(', ')}',
        );

        // Verificar si hay columnas esperadas
        final primerRegistro = estructuraResponse.first as Map<String, dynamic>;
        final columnasEsperadas = ['id', 'nombre_tienda', 'fecha_creacion'];
        for (var columna in columnasEsperadas) {
          if (primerRegistro.containsKey(columna)) {
            print('✅ Columna "$columna" encontrada');
          } else {
            print('⚠️  Columna "$columna" NO encontrada en la tabla');
          }
        }
      }

      // 3. Obtener total de registros
      print('📊 Obteniendo total de registros...');
      final allResponse = await _supabase!
          .from('tienda')
          .select()
          .timeout(const Duration(seconds: 15));

      if (allResponse is List) {
        print('✅ Total de registros en tabla tienda: ${allResponse.length}');
        if (allResponse.isNotEmpty) {
          print('📊 Ejemplo de registro completo:');
          for (var i = 0; i < min(3, allResponse.length); i++) {
            print('   [$i] ${allResponse[i]}');
          }
        }
      } else {
        print('⚠️  Respuesta inesperada: ${allResponse.runtimeType}');
      }

      // 4. Verificar políticas RLS
      print('📊 Sugerencia: Verifica las políticas RLS en Supabase Dashboard');

      // Verificación adicional de políticas RLS
      print('🔍 Probando consulta con diferentes métodos...');
      try {
        // Método 1: Consulta simple sin orden ni límite
        final simpleResponse = await _supabase!
            .from('tienda')
            .select('*')
            .timeout(const Duration(seconds: 5));
        print(
          '📊 Consulta simple (select *): ${simpleResponse is List ? simpleResponse.length : 'tipo: ${simpleResponse.runtimeType}'} registros',
        );

        // Método 2: Consulta con solo ID
        final idResponse = await _supabase!
            .from('tienda')
            .select('id')
            .timeout(const Duration(seconds: 5));
        print(
          '📊 Consulta solo ID: ${idResponse is List ? idResponse.length : 'tipo: ${idResponse.runtimeType}'} registros',
        );

        // Método 3: Consulta count() como función
        final countFuncResponse = await _supabase!
            .rpc('count_tiendas', params: {})
            .timeout(const Duration(seconds: 5));
        print('📊 Función RPC count_tiendas: $countFuncResponse');
      } catch (e) {
        print('⚠️  Error en consultas adicionales: $e');
        if (e.toString().contains('permission denied')) {
          print('🔒 CONFIRMADO: Problema de políticas RLS (permiso denegado)');
          print('💡 Solución inmediata: En Supabase Dashboard, ve a:');
          print('   Authentication > Policies > Create policy');
          print('   Para la tabla "tienda", crea una política que permita:');
          print('   - Operation: SELECT');
          print('   - Expression: true (para todos)');
          print('   - Name: Allow anonymous select');
        }
      }
      print('📊   - Ve a Authentication > Policies');
      print(
        '📊   - Asegúrate de que hay políticas para SELECT en tabla tienda',
      );
      print('📊   - Para desarrollo, puedes deshabilitar RLS temporalmente');

      // Prueba específica: ¿Hay políticas RLS habilitadas?
      print('🔍 Prueba RLS: Consultando información_schema.table_privileges');
      try {
        final rlsCheck = await _supabase!
            .from('information_schema.table_privileges')
            .select('*')
            .eq('table_schema', 'public')
            .eq('table_name', 'tienda')
            .limit(5)
            .timeout(const Duration(seconds: 5));
        print(
          '📊 Privilegios de tabla: ${rlsCheck is List ? rlsCheck.length : "error"} registros',
        );
      } catch (e) {
        print('⚠️  No se pudo verificar privilegios: $e');
      }

      // Intentar con service_role key si está disponible
      final serviceRoleKey = dotenv.get(
        'SUPABASE_SERVICE_ROLE_KEY',
        fallback: '',
      );
      if (serviceRoleKey.isNotEmpty) {
        print('🔑 Intentando con clave de service_role (ignora RLS)...');
        try {
          // Crear cliente temporal con service_role
          final tempClient = SupabaseClient(
            dotenv.get('SUPABASE_URL'),
            serviceRoleKey,
          );
          final tempResponse = await tempClient
              .from('tienda')
              .select('count')
              .limit(1)
              .timeout(const Duration(seconds: 5));
          print('📊 Service_role count: $tempResponse');
          if (tempResponse is List &&
              tempResponse.isNotEmpty &&
              (tempResponse.first as Map)['count'] > 0) {
            print(
              '✅ CONFIRMADO: El problema es RLS. Con service_role sí hay datos.',
            );
          }
        } catch (e) {
          print('⚠️  Error con service_role: $e');
        }
      } else {
        print('🔑 Clave SUPABASE_SERVICE_ROLE_KEY no encontrada en .env');
      }

      // Prueba final: ¿Puede ser problema de timeout o red?
      print('🔍 Prueba de conexión directa con SupabaseClient...');
      try {
        final directClient = SupabaseClient(
          dotenv.get('SUPABASE_URL'),
          dotenv.get('SUPABASE_SERVICE_ROLE_KEY'),
        );
        final directResult = await directClient
            .from('tienda')
            .select('id')
            .limit(2)
            .timeout(const Duration(seconds: 10));
        print(
          '📊 Conexión directa resultado: ${directResult is List ? directResult.length : directResult.runtimeType}',
        );
        if (directResult is List) {
          print('📊 Datos directos: $directResult');
        }
      } catch (e) {
        print('❌ Error en conexión directa: $e');
      }

      print('✅=== FIN PRUEBA RLS Y ESQUEMA ===');
    } catch (e) {
      print('❌ Error en verificación de tabla: $e');
      print('📊 Stack trace: ${e.toString()}');

      if (e.toString().contains('permission denied')) {
        print('⚠️  Posible problema de políticas RLS (Row Level Security)');
        print(
          'ℹ️  Solución: Ve a Supabase Dashboard > Authentication > Policies',
        );
        print('ℹ️  Crea una política que permita SELECT a usuarios anónimos');
      }

      if (e.toString().contains('relation') &&
          e.toString().contains('does not exist')) {
        print('⚠️  La tabla "tienda" no existe en la base de datos');
        print('ℹ️  Solución: Crea la tabla en Supabase SQL Editor');
      }
    }
  }

  void _verificarConfiguracion() {
    _initializeSupabase(cargarTiendas: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Backend Supabase'),
        backgroundColor: const Color(0xFF121212),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarTiendas,
            tooltip: 'Recargar tiendas',
          ),
          IconButton(
            icon: const Icon(Icons.wifi),
            onPressed: _probarConexion,
            tooltip: 'Probar conexión',
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: _verificarTablaTienda,
            tooltip: 'Verificar tabla',
          ),
        ],
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? _buildErrorScreen()
              : !_supabaseConfigured
              ? _buildConfigScreen()
              : _tiendas.isEmpty
              ? _buildEmptyScreen()
              : _buildTiendasList(),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _verificarTablaTienda,
            backgroundColor: Colors.orange,
            mini: true,
            child: const Icon(Icons.bug_report, color: Colors.white, size: 20),
            tooltip: 'Verificar tabla tienda',
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _cargarTiendas,
            backgroundColor: Colors.blue,
            tooltip: 'Recargar tiendas',
            child: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildErrorScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 20),
            const Text(
              'Error de conexión',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _cargarTiendas,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.settings, size: 64, color: Colors.orange),
            const SizedBox(height: 20),
            const Text(
              'Configuración requerida',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Para ejecutar esta aplicación, necesitas configurar Supabase:',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: const Text(
                'flutter run lib/main_supabase.dart \\\n'
                '  --dart-define=SUPABASE_URL=tu_url \\\n'
                '  --dart-define=SUPABASE_SERVICE_ROLE_KEY=tu_clave\n\n'
                'Reemplaza "tu_url" y "tu_clave" con tus\n'
                'credenciales de Supabase (usando SERVICE_ROLE_KEY).',
                style: TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verificarConfiguracion,
              child: const Text('Verificar configuración'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.store, size: 64, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'No hay tiendas disponibles',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 10),
          Text(
            _supabaseConfigured
                ? 'La tabla "tienda" está vacía'
                : 'Supabase no configurado',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTiendasList() {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo is ScrollEndNotification &&
            scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
            !_loading &&
            _hasMoreItems) {
          _cargarMasTiendas();
          return true;
        }
        return false;
      },
      child: ListView.builder(
        itemCount: _tiendas.length + (_hasMoreItems ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _tiendas.length) {
            // Mostrar indicador de carga al final
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child:
                    _loading
                        ? const CircularProgressIndicator()
                        : _hasMoreItems
                        ? ElevatedButton(
                          onPressed: _cargarMasTiendas,
                          child: const Text('Cargar más tiendas'),
                        )
                        : const Text(
                          'No hay más tiendas',
                          style: TextStyle(color: Colors.grey),
                        ),
              ),
            );
          }

          final tienda = _tiendas[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.store, color: Colors.blue, size: 40),
              title: Text(
                tienda['nombre_tienda']?.toString() ?? 'Sin nombre',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (tienda['descripcion'] != null)
                    Text(
                      tienda['descripcion']!.toString(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.visibility,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${tienda['total_visitas'] ?? 0} visitas',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _mostrarDetallesTienda(tienda);
              },
            ),
          );
        },
      ),
    );
  }

  void _mostrarDetallesTienda(Map<String, dynamic> tienda) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              tienda['nombre_tienda']?.toString() ?? 'Detalles de tienda',
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('ID: ${tienda['id'] ?? 'N/A'}'),
                  const SizedBox(height: 8),
                  Text('Propietario ID: ${tienda['id_propietario'] ?? 'N/A'}'),
                  const SizedBox(height: 8),
                  if (tienda['email_contacto'] != null)
                    Text('Email: ${tienda['email_contacto']}'),
                  if (tienda['telefono_contacto'] != null)
                    Text('Teléfono: ${tienda['telefono_contacto']}'),
                  const SizedBox(height: 8),
                  Text('Total visitas: ${tienda['total_visitas'] ?? 0}'),
                  Text(
                    'Contactos WhatsApp: ${tienda['total_contactos_whatsapp'] ?? 0}',
                  ),
                  const SizedBox(height: 8),
                  if (tienda['fecha_creacion'] != null)
                    Text(
                      'Creada: ${DateTime.parse(tienda['fecha_creacion'].toString()).toLocal().toString()}',
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          ),
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tiendas: ${_tiendas.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (_hasMoreItems && _tiendas.isNotEmpty)
                  Text(
                    'Página $_currentPage',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
            Row(
              children: [
                Icon(
                  _supabaseConfigured && _error == null
                      ? Icons.check_circle
                      : Icons.error,
                  color:
                      _supabaseConfigured && _error == null
                          ? Colors.green
                          : Colors.orange,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  _supabaseConfigured
                      ? (_error == null ? 'Conectado' : 'Error')
                      : 'Configurar',
                  style: TextStyle(
                    color:
                        _supabaseConfigured
                            ? (_error == null ? Colors.green : Colors.orange)
                            : Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
