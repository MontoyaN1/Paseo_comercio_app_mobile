// lib/main_simple.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno
  await dotenv.load(fileName: '.env');

  // Inicializar Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(const PaseoDelComercioApp());
}

class PaseoDelComercioApp extends StatelessWidget {
  const PaseoDelComercioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paseo del Comercio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _tiendas = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarTiendas();
  }

  Future<void> _cargarTiendas() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final response =
          await _supabase
              .from('tienda')
              .select()
              .order('fecha_creacion', ascending: false)
              .limit(10)
              .execute();

      if (response.error != null) {
        throw Exception('Error: ${response.error!.message}');
      }

      final data = response.data as List<dynamic>;
      setState(() {
        _tiendas = data.map((item) => item as Map<String, dynamic>).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _probarConexion() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      // Probar conexión con una consulta simple
      final response =
          await _supabase.from('tienda').select('count').limit(1).execute();

      if (response.error != null) {
        throw Exception('Error de conexión: ${response.error!.message}');
      }

      // Si llegamos aquí, la conexión es exitosa
      setState(() {
        _loading = false;
      });

      // Mostrar mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Conexión con Supabase exitosa'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paseo del Comercio - Backend Test'),
        backgroundColor: const Color(0xFF121212),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarTiendas,
          ),
          IconButton(icon: const Icon(Icons.wifi), onPressed: _probarConexion),
        ],
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 64,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Error de conexión',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
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
              )
              : _tiendas.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.store, size: 64, color: Colors.grey),
                    SizedBox(height: 20),
                    Text(
                      'No hay tiendas disponibles',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _tiendas.length,
                itemBuilder: (context, index) {
                  final tienda = _tiendas[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const Icon(
                        Icons.store,
                        color: Colors.blue,
                        size: 40,
                      ),
                      title: Text(
                        tienda['nombre_tienda'] ?? 'Sin nombre',
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
                              tienda['descripcion']!,
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
                        // Mostrar detalles de la tienda
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: Text(
                                  tienda['nombre_tienda'] ??
                                      'Detalles de tienda',
                                ),
                                content: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('ID: ${tienda['id'] ?? 'N/A'}'),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Propietario ID: ${tienda['id_propietario'] ?? 'N/A'}',
                                      ),
                                      const SizedBox(height: 8),
                                      if (tienda['email_contacto'] != null)
                                        Text(
                                          'Email: ${tienda['email_contacto']}',
                                        ),
                                      if (tienda['telefono_contacto'] != null)
                                        Text(
                                          'Teléfono: ${tienda['telefono_contacto']}',
                                        ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Total visitas: ${tienda['total_visitas'] ?? 0}',
                                      ),
                                      Text(
                                        'Contactos WhatsApp: ${tienda['total_contactos_whatsapp'] ?? 0}',
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Creada: ${tienda['fecha_creacion'] != null ? DateTime.parse(tienda['fecha_creacion']).toLocal().toString() : 'N/A'}',
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
                      },
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _cargarTiendas,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total tiendas: ${_tiendas.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Supabase: ${_error == null ? '✅ Conectado' : '❌ Error'}',
                style: TextStyle(
                  color: _error == null ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Modelo simple de Tienda para referencia futura
class Tienda {
  final int id;
  final String nombreTienda;
  final String? descripcion;
  final int idPropietario;
  final DateTime fechaCreacion;
  final int totalVisitas;

  Tienda({
    required this.id,
    required this.nombreTienda,
    this.descripcion,
    required this.idPropietario,
    required this.fechaCreacion,
    required this.totalVisitas,
  });

  factory Tienda.fromJson(Map<String, dynamic> json) {
    return Tienda(
      id: json['id'] as int,
      nombreTienda: json['nombre_tienda'] as String,
      descripcion: json['descripcion'] as String?,
      idPropietario: json['id_propietario'] as int,
      fechaCreacion: DateTime.parse(json['fecha_creacion'] as String),
      totalVisitas: json['total_visitas'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre_tienda': nombreTienda,
      'descripcion': descripcion,
      'id_propietario': idPropietario,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'total_visitas': totalVisitas,
    };
  }
}
