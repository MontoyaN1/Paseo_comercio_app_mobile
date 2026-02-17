// lib/core/config/clerk_config.dart

import 'package:clerk_flutter/clerk_flutter.dart';

/// Configuración simplificada para Clerk
/// Clerk maneja todo internamente: social logins, temas, etc.
/// Solo necesitamos proporcionar la publishableKey
class ClerkConfig {
  // Singleton pattern
  static final ClerkConfig _instance = ClerkConfig._internal();
  factory ClerkConfig() => _instance;
  ClerkConfig._internal();

  /// Publishable key de Clerk (obligatoria)
  String publishableKey = '';

  /// Configurar Clerk con la publishableKey
  void configure(String key) {
    if (key.isEmpty) {
      throw ArgumentError('Clerk publishableKey no puede estar vacía');
    }
    publishableKey = key;
  }

  /// Obtener configuración de Clerk para la aplicación
  /// Nota: Clerk Flutter SDK maneja la configuración de apariencia
  /// y localización de manera diferente a versiones anteriores
  ClerkAuthConfig get authConfig {
    // Configuración básica con publishableKey
    final config = ClerkAuthConfig(publishableKey: publishableKey);

    // Nota importante:
    // - Los temas (appearance) se configuran en dashboard.clerk.com
    // - La localización se maneja automáticamente basada en el dispositivo
    // - Los social logins se configuran en dashboard.clerk.com

    return config;
  }

  /// Verificar si Clerk está configurado
  bool get isConfigured => publishableKey.isNotEmpty;

  @override
  String toString() {
    return '''
ClerkConfig:
  - Configurado: ${isConfigured ? 'Sí' : 'No'}
  - Publishable Key: ${publishableKey.isNotEmpty ? 'Configurada' : 'Faltante'}
  - Nota: Social logins y temas se configuran en dashboard.clerk.com
''';
  }
}
