import 'package:flutter/material.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:clerk_flutter/generated/clerk_sdk_localizations.dart';
import 'package:paseo_del_comercio/perfil.dart';

import 'login.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  static const String publishableKey =
      'pk_test_YXdhaXRlZC1zaGVlcGRvZy0xNS5jbGVyay5hY2NvdW50cy5kZXYk';

  @override
  Widget build(BuildContext context) {
    return ClerkAuth(
      config: ClerkAuthConfig(
        publishableKey: publishableKey,
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,

        // ✅ Localización de Clerk (para poder poner español si quieres)
        localizationsDelegates: ClerkSdkLocalizations.localizationsDelegates,
        supportedLocales: ClerkSdkLocalizations.supportedLocales,
        // locale: const Locale('es'), // descomenta si quieres forzar español

        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212), // negro amistoso
        elevation: 6,
        title: const Text(
          'Paseo del Comercio',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // ✅ Cambia según autenticación
          ClerkAuthBuilder(
            signedOutBuilder: (context, state) {
              return TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                child: const Text(
                  'Logeate',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
           signedInBuilder: (context, state) {
  final user = ClerkAuth.of(context).user;

  return Padding(
    padding: const EdgeInsets.only(right: 12),
    child: GestureDetector(
      onTap: () {
        // Aquí puedes navegar a una pantalla con el ClerkUserButton completo
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ProfilePage(),
          ),
        );
      },
      child: CircleAvatar(
        radius: 18,
        backgroundImage: (user?.imageUrl != null && user!.imageUrl!.isNotEmpty)
            ? NetworkImage(user.imageUrl!)
            : null,
        child: (user?.imageUrl == null || user!.imageUrl!.isEmpty)
            ? const Icon(Icons.person)
            : null,
      ),
    ),
  );
},


          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Bienvenido',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

