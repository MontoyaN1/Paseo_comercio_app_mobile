// lib/core/utils/connectivity_service.dart

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../errors/app_exceptions.dart';

/// Estados de conectividad
enum ConnectionStatus { connected, disconnected, checking }

/// Servicio para manejar la conectividad de red
class ConnectivityService {
  // Singleton pattern
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<ConnectionStatus> _statusController =
      StreamController<ConnectionStatus>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  ConnectionStatus _currentStatus = ConnectionStatus.checking;
  Timer? _checkTimer;

  /// Obtener stream de cambios de estado
  Stream<ConnectionStatus> get onStatusChanged => _statusController.stream;

  /// Obtener estado actual
  ConnectionStatus get currentStatus => _currentStatus;

  /// Verificar si hay conexión
  bool get isConnected => _currentStatus == ConnectionStatus.connected;

  /// Check if there is connection (async version)
  Future<bool> hasConnection() async => isConnected;

  /// Verificar si está desconectado
  bool get isDisconnected => _currentStatus == ConnectionStatus.disconnected;

  /// Inicializar servicio
  Future<void> initialize() async {
    // Verificar estado inicial
    await _checkConnectivity();

    // Suscribirse a cambios de conectividad
    _subscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) => _handleConnectivityChange(results),
    );

    // Iniciar verificación periódica (cada 30 segundos)
    _startPeriodicCheck();
  }

  /// Verificar conectividad actual
  Future<void> checkConnectivity() async {
    await _checkConnectivity();
  }

  /// Detener servicio
  Future<void> dispose() async {
    await _subscription?.cancel();
    _checkTimer?.cancel();
    await _statusController.close();
  }

  /// Verificar conectividad con timeout
  Future<bool> checkConnectivityWithTimeout({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      final results = await _connectivity.checkConnectivity().timeout(timeout);
      return _isResultConnected(results);
    } catch (_) {
      return false;
    }
  }

  /// Verificar tipo de conexión
  Future<List<ConnectivityResult>> getConnectionType() async {
    return await _connectivity.checkConnectivity();
  }

  /// Verificar si es WiFi
  Future<bool> isWifiConnected() async {
    final results = await _connectivity.checkConnectivity();
    return results.contains(ConnectivityResult.wifi);
  }

  /// Verificar si es móvil
  Future<bool> isMobileConnected() async {
    final results = await _connectivity.checkConnectivity();
    return results.contains(ConnectivityResult.mobile);
  }

  /// Verificar si es Ethernet
  Future<bool> isEthernetConnected() async {
    final results = await _connectivity.checkConnectivity();
    return results.contains(ConnectivityResult.ethernet);
  }

  /// Verificar si está en modo avión
  Future<bool> isAirplaneMode() async {
    final results = await _connectivity.checkConnectivity();
    return results.contains(ConnectivityResult.none) || results.isEmpty;
  }

  /// Obtener nombre del tipo de conexión
  Future<String> getConnectionTypeName() async {
    final results = await _connectivity.checkConnectivity();
    return _getConnectionTypeName(results);
  }

  /// Esperar por conexión
  Future<void> waitForConnection({
    Duration timeout = const Duration(seconds: 30),
    Duration checkInterval = const Duration(seconds: 1),
  }) async {
    final completer = Completer<void>();
    final timer = Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.completeError(
          TimeoutException(message: 'Tiempo de espera agotado para conexión'),
        );
      }
    });

    final subscription = onStatusChanged.listen((status) {
      if (status == ConnectionStatus.connected && !completer.isCompleted) {
        timer.cancel();
        completer.complete();
      }
    });

    // Verificar si ya está conectado
    if (isConnected && !completer.isCompleted) {
      timer.cancel();
      completer.complete();
    }

    try {
      await completer.future;
    } finally {
      await subscription.cancel();
    }
  }

  /// Verificar conectividad y actualizar estado
  Future<void> _checkConnectivity() async {
    try {
      _updateStatus(ConnectionStatus.checking);

      final results = await _connectivity.checkConnectivity();
      final connected = _isResultConnected(results);

      _updateStatus(
        connected ? ConnectionStatus.connected : ConnectionStatus.disconnected,
      );

      // Estado actual actualizado
    } catch (error) {
      // Error al verificar conectividad
      _updateStatus(ConnectionStatus.disconnected);
    }
  }

  /// Manejar cambio de conectividad
  Future<void> _handleConnectivityChange(
    List<ConnectivityResult> results,
  ) async {
    // Cambio de conectividad detectado

    // Verificar conectividad real (no solo el tipo de conexión)
    await _checkConnectivity();
  }

  /// Actualizar estado y notificar a los listeners
  void _updateStatus(ConnectionStatus newStatus) {
    if (_currentStatus != newStatus) {
      _currentStatus = newStatus;
      _statusController.add(newStatus);

      // Estado de conectividad cambiado
    }
  }

  /// Iniciar verificación periódica
  void _startPeriodicCheck() {
    _checkTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      await _checkConnectivity();
    });
  }

  /// Verificar si el resultado de conectividad indica conexión
  bool _isResultConnected(List<ConnectivityResult> results) {
    return !results.contains(ConnectivityResult.none) && results.isNotEmpty;
  }

  /// Obtener nombre legible del tipo de conexión
  String _getConnectionTypeName(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return 'Sin conexión';
    }

    // Priorizar tipos de conexión en orden específico
    if (results.contains(ConnectivityResult.wifi)) {
      return 'WiFi';
    } else if (results.contains(ConnectivityResult.mobile)) {
      return 'Móvil';
    } else if (results.contains(ConnectivityResult.ethernet)) {
      return 'Ethernet';
    } else if (results.contains(ConnectivityResult.vpn)) {
      return 'VPN';
    } else if (results.contains(ConnectivityResult.bluetooth)) {
      return 'Bluetooth';
    } else {
      return 'Otro';
    }
  }
}

/// Helper para manejar operaciones con verificación de conectividad
class ConnectivityHelper {
  /// Ejecutar función solo si hay conexión
  static Future<T?> executeIfConnected<T>(
    Future<T> Function() function, {
    T? defaultValue,
    bool throwIfDisconnected = false,
  }) async {
    final connectivity = ConnectivityService();
    final isConnected = connectivity.isConnected;

    if (!isConnected) {
      if (throwIfDisconnected) {
        throw NetworkException(message: 'No hay conexión a internet');
      }
      return defaultValue;
    }

    return await function();
  }

  /// Ejecutar función con reintentos en caso de pérdida de conexión
  static Future<T> executeWithConnectionRetry<T>(
    Future<T> Function() function, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
    Duration connectionTimeout = const Duration(seconds: 30),
  }) async {
    final connectivity = ConnectivityService();
    int attempts = 0;

    while (attempts < maxRetries) {
      attempts++;

      try {
        // Esperar por conexión si es necesario
        if (!connectivity.isConnected) {
          await connectivity.waitForConnection(timeout: connectionTimeout);
        }

        // Ejecutar función
        return await function();
      } catch (error) {
        // Verificar si es error de conexión
        if (error is TimeoutException ||
            error is NetworkException ||
            error.toString().contains('No hay conexión')) {
          if (attempts >= maxRetries) {
            rethrow;
          }

          // Esperar antes de reintentar
          await Future.delayed(retryDelay * attempts);
          continue;
        }

        // Otro tipo de error, relanzar
        rethrow;
      }
    }

    throw NetworkException(message: 'Máximo de reintentos alcanzado');
  }

  /// Verificar conectividad antes de operación crítica
  static Future<void> ensureConnection({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final connectivity = ConnectivityService();

    if (!connectivity.isConnected) {
      await connectivity.waitForConnection(timeout: timeout);
    }
  }

  /// Obtener información detallada de la conexión
  static Future<Map<String, dynamic>> getConnectionInfo() async {
    final connectivity = ConnectivityService();
    final connectionType = await connectivity.getConnectionType();
    final connectionTypeName = await connectivity.getConnectionTypeName();

    return {
      'status': connectivity.currentStatus.name,
      'isConnected': connectivity.isConnected,
      'connectionType': connectionType.join(', '),
      'connectionTypeName': connectionTypeName,
      'isWifi': connectionType.contains(ConnectivityResult.wifi),
      'isMobile': connectionType.contains(ConnectivityResult.mobile),
      'isEthernet': connectionType.contains(ConnectivityResult.ethernet),
      'isAirplaneMode':
          connectionType.contains(ConnectivityResult.none) ||
          connectionType.isEmpty,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

/// Mixin para agregar funcionalidad de conectividad a cualquier clase
mixin ConnectivityMixin {
  final ConnectivityService _connectivity = ConnectivityService();

  /// Verificar si hay conexión
  bool get isConnected => _connectivity.isConnected;

  /// Obtener stream de cambios de estado
  Stream<ConnectionStatus> get onConnectivityChanged =>
      _connectivity.onStatusChanged;

  /// Ejecutar función solo si hay conexión
  Future<T?> executeIfConnected<T>(
    Future<T> Function() function, {
    T? defaultValue,
  }) async {
    return ConnectivityHelper.executeIfConnected(
      function,
      defaultValue: defaultValue,
    );
  }

  /// Esperar por conexión
  Future<void> waitForConnection({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    await _connectivity.waitForConnection(timeout: timeout);
  }
}
