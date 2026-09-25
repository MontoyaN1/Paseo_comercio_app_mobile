// lib/core/utils/firebase_config_loader.dart

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Cargador de configuración de Firebase desde variables de entorno
class FirebaseConfigLoader {
  /// Cargar opciones de Firebase desde variables de entorno
  static FirebaseOptions loadFromEnv(Map<String, String> env) {
    // Obtener valores del entorno
    final webApiKey = env['FIREBASE_WEB_API_KEY'] ?? '';
    final androidApiKey = env['FIREBASE_ANDROID_API_KEY'] ?? '';
    final iosApiKey = env['FIREBASE_IOS_API_KEY'] ?? '';
    final webAppId = env['FIREBASE_WEB_APP_ID'] ?? '';
    final androidAppId = env['FIREBASE_ANDROID_APP_ID'] ?? '';
    final iosAppId = env['FIREBASE_IOS_APP_ID'] ?? '';
    final messagingSenderId = env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';
    final projectId = env['FIREBASE_PROJECT_ID'] ?? '';
    final authDomain = env['FIREBASE_AUTH_DOMAIN'] ?? '';
    final storageBucket = env['FIREBASE_STORAGE_BUCKET'] ?? '';
    final iosClientId = env['FIREBASE_IOS_CLIENT_ID'] ?? '';
    final iosBundleId = env['FIREBASE_IOS_BUNDLE_ID'] ?? '';
    final androidClientId = env['FIREBASE_ANDROID_CLIENT_ID'] ?? '';

    // Validar configuración mínima
    _validateConfig(
      webApiKey: webApiKey,
      androidApiKey: androidApiKey,
      iosApiKey: iosApiKey,
      webAppId: webAppId,
      androidAppId: androidAppId,
      iosAppId: iosAppId,
      projectId: projectId,
    );

    // Determinar plataforma actual y devolver configuración apropiada
    if (kIsWeb) {
      return _createWebOptions(
        apiKey: webApiKey,
        appId: webAppId,
        messagingSenderId: messagingSenderId,
        projectId: projectId,
        authDomain: authDomain,
        storageBucket: storageBucket,
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _createAndroidOptions(
          apiKey: androidApiKey,
          appId: androidAppId,
          messagingSenderId: messagingSenderId,
          projectId: projectId,
          storageBucket: storageBucket,
          androidClientId: androidClientId,
        );
      case TargetPlatform.iOS:
        return _createIosOptions(
          apiKey: iosApiKey,
          appId: iosAppId,
          messagingSenderId: messagingSenderId,
          projectId: projectId,
          storageBucket: storageBucket,
          iosClientId: iosClientId,
          iosBundleId: iosBundleId,
        );
      case TargetPlatform.macOS:
        return _createMacosOptions(
          apiKey: iosApiKey,
          appId: iosAppId,
          messagingSenderId: messagingSenderId,
          projectId: projectId,
          storageBucket: storageBucket,
          iosClientId: iosClientId,
          iosBundleId: iosBundleId,
        );
      case TargetPlatform.windows:
        return _createWindowsOptions(
          apiKey: webApiKey,
          appId: webAppId,
          messagingSenderId: messagingSenderId,
          projectId: projectId,
          authDomain: authDomain,
          storageBucket: storageBucket,
        );
      case TargetPlatform.linux:
        throw UnsupportedError('Firebase no está configurado para Linux');
      default:
        throw UnsupportedError(
          'Plataforma no soportada: $defaultTargetPlatform',
        );
    }
  }

  /// Validar configuración mínima requerida
  static void _validateConfig({
    required String webApiKey,
    required String androidApiKey,
    required String iosApiKey,
    required String webAppId,
    required String androidAppId,
    required String iosAppId,
    required String projectId,
  }) {
    final errors = <String>[];

    // Validar API Keys
    if (webApiKey.isEmpty) errors.add('FIREBASE_WEB_API_KEY es requerida');
    if (androidApiKey.isEmpty)
      errors.add('FIREBASE_ANDROID_API_KEY es requerida');
    if (iosApiKey.isEmpty) errors.add('FIREBASE_IOS_API_KEY es requerida');

    // Validar App IDs
    if (webAppId.isEmpty) errors.add('FIREBASE_WEB_APP_ID es requerido');
    if (androidAppId.isEmpty)
      errors.add('FIREBASE_ANDROID_APP_ID es requerido');
    if (iosAppId.isEmpty) errors.add('FIREBASE_IOS_APP_ID es requerido');

    // Validar Project ID
    if (projectId.isEmpty) errors.add('FIREBASE_PROJECT_ID es requerido');

    if (errors.isNotEmpty) {
      throw FirebaseConfigException(
        'Configuración de Firebase incompleta:\n${errors.join('\n')}',
      );
    }
  }

  /// Crear opciones para Web
  static FirebaseOptions _createWebOptions({
    required String apiKey,
    required String appId,
    required String messagingSenderId,
    required String projectId,
    required String authDomain,
    required String storageBucket,
  }) {
    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
      authDomain:
          authDomain.isNotEmpty ? authDomain : '$projectId.firebaseapp.com',
      storageBucket:
          storageBucket.isNotEmpty
              ? storageBucket
              : '$projectId.firebasestorage.app',
    );
  }

  /// Crear opciones para Android
  static FirebaseOptions _createAndroidOptions({
    required String apiKey,
    required String appId,
    required String messagingSenderId,
    required String projectId,
    required String storageBucket,
    required String androidClientId,
  }) {
    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
      storageBucket:
          storageBucket.isNotEmpty
              ? storageBucket
              : '$projectId.firebasestorage.app',
    );
  }

  /// Crear opciones para iOS
  static FirebaseOptions _createIosOptions({
    required String apiKey,
    required String appId,
    required String messagingSenderId,
    required String projectId,
    required String storageBucket,
    required String iosClientId,
    required String iosBundleId,
  }) {
    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
      storageBucket:
          storageBucket.isNotEmpty
              ? storageBucket
              : '$projectId.firebasestorage.app',
      iosClientId: iosClientId,
      iosBundleId: iosBundleId,
    );
  }

  /// Crear opciones para macOS
  static FirebaseOptions _createMacosOptions({
    required String apiKey,
    required String appId,
    required String messagingSenderId,
    required String projectId,
    required String storageBucket,
    required String iosClientId,
    required String iosBundleId,
  }) {
    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
      storageBucket:
          storageBucket.isNotEmpty
              ? storageBucket
              : '$projectId.firebasestorage.app',
      iosClientId: iosClientId,
      iosBundleId: iosBundleId,
    );
  }

  /// Crear opciones para Windows
  static FirebaseOptions _createWindowsOptions({
    required String apiKey,
    required String appId,
    required String messagingSenderId,
    required String projectId,
    required String authDomain,
    required String storageBucket,
  }) {
    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
      authDomain:
          authDomain.isNotEmpty ? authDomain : '$projectId.firebaseapp.com',
      storageBucket:
          storageBucket.isNotEmpty
              ? storageBucket
              : '$projectId.firebasestorage.app',
    );
  }

  /// Obtener lista de variables de entorno requeridas
  static Map<String, String> get requiredEnvVariables {
    return {
      // API Keys (una por plataforma)
      'FIREBASE_WEB_API_KEY': 'API Key para Web',
      'FIREBASE_ANDROID_API_KEY': 'API Key para Android',
      'FIREBASE_IOS_API_KEY': 'API Key para iOS',

      // App IDs (uno por plataforma)
      'FIREBASE_WEB_APP_ID': 'App ID para Web',
      'FIREBASE_ANDROID_APP_ID': 'App ID para Android',
      'FIREBASE_IOS_APP_ID': 'App ID para iOS',

      // Configuración común
      'FIREBASE_MESSAGING_SENDER_ID': 'Messaging Sender ID',
      'FIREBASE_PROJECT_ID': 'Project ID',

      // Configuración opcional
      'FIREBASE_AUTH_DOMAIN': 'Auth Domain (opcional)',
      'FIREBASE_STORAGE_BUCKET': 'Storage Bucket (opcional)',
      'FIREBASE_IOS_CLIENT_ID': 'iOS Client ID (opcional)',
      'FIREBASE_IOS_BUNDLE_ID': 'iOS Bundle ID (opcional)',
      'FIREBASE_ANDROID_CLIENT_ID':
          'Android Client ID (opcional - para Google Sign-In)',
    };
  }

  /// Generar contenido para archivo .env.example
  static String generateEnvExample() {
    final buffer =
        StringBuffer()
          ..writeln('# Firebase Configuration')
          ..writeln('# ======================')
          ..writeln('# Obtén estas credenciales desde Firebase Console')
          ..writeln('# https://console.firebase.google.com/')
          ..writeln()
          ..writeln('# API Keys (REQUIRED - una por plataforma)')
          ..writeln(
            '# En Firebase Console: Configuración del proyecto > Tus aplicaciones',
          )
          ..writeln('# Copia las "apiKey" de cada plataforma');

    // API Keys
    buffer
      ..writeln('FIREBASE_WEB_API_KEY=')
      ..writeln('FIREBASE_ANDROID_API_KEY=')
      ..writeln('FIREBASE_IOS_API_KEY=')
      ..writeln();

    // App IDs
    buffer
      ..writeln('# App IDs (REQUIRED - uno por plataforma)')
      ..writeln(
        '# En Firebase Console: Configuración del proyecto > Tus aplicaciones',
      )
      ..writeln('# Copia los "appId" de cada plataforma')
      ..writeln('FIREBASE_WEB_APP_ID=')
      ..writeln('FIREBASE_ANDROID_APP_ID=')
      ..writeln('FIREBASE_IOS_APP_ID=')
      ..writeln();

    // Configuración común
    buffer
      ..writeln('# Configuración común (REQUIRED)')
      ..writeln('# En Firebase Console: Configuración del proyecto')
      ..writeln('FIREBASE_MESSAGING_SENDER_ID=')
      ..writeln('FIREBASE_PROJECT_ID=')
      ..writeln();

    // Configuración opcional
    buffer
      ..writeln('# Configuración opcional')
      ..writeln('# Si no se proporcionan, se generarán automáticamente')
      ..writeln('FIREBASE_AUTH_DOMAIN=')
      ..writeln('FIREBASE_STORAGE_BUCKET=')
      ..writeln('FIREBASE_IOS_CLIENT_ID=')
      ..writeln('FIREBASE_IOS_BUNDLE_ID=')
      ..writeln('FIREBASE_ANDROID_CLIENT_ID=');

    return buffer.toString();
  }

  /// Verificar si la configuración está completa
  static bool isConfigComplete(Map<String, String> env) {
    try {
      loadFromEnv(env);
      return true;
    } catch (_) {
      return false;
    }
  }
}

/// Excepción para errores de configuración de Firebase
class FirebaseConfigException implements Exception {
  final String message;

  FirebaseConfigException(this.message);

  @override
  String toString() => 'FirebaseConfigException: $message';
}
