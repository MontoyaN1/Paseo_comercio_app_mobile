import 'package:flutter/material.dart';
import 'package:clerk_flutter/clerk_flutter.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 6,
        title: const Text(
          'Login',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: ClerkAuthBuilder(
          signedOutBuilder: (context, state) {
            return const Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: ClerkAuthentication(),
              ),
            );
          },
          signedInBuilder: (context, state) {
            // ✅ Cuando ya está logeado, volver automáticamente al Home
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pop(context);
            });

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
