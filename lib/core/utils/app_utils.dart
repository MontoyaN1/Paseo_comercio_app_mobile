// lib/core/utils/app_utils.dart

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_constants.dart';

/// Utilidades generales de la aplicación
class AppUtils {
  // Singleton pattern
  static final AppUtils _instance = AppUtils._internal();
  factory AppUtils() => _instance;
  AppUtils._internal();

  // Formateadores de fecha
  final DateFormat _dateFormat = DateFormat(AppConstants.dateFormatDisplay);
  final DateFormat _dateTimeFormat = DateFormat(
    AppConstants.dateTimeFormatDisplay,
  );
  final DateFormat _timeFormat = DateFormat(AppConstants.timeFormatDisplay);

  /// Formatear fecha para mostrar
  String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// Formatear fecha y hora para mostrar
  String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  /// Formatear hora para mostrar
  String formatTime(DateTime dateTime) {
    return _timeFormat.format(dateTime);
  }

  /// Formatear número con separadores de miles
  String formatNumber(double number, {int decimalDigits = 2}) {
    final formatter = NumberFormat('#,##0.${'0' * decimalDigits}', 'es_ES');
    return formatter.format(number);
  }

  /// Formatear moneda
  String formatCurrency(
    double amount, {
    String symbol = '€',
    int decimalDigits = 2,
  }) {
    final formattedNumber = formatNumber(amount, decimalDigits: decimalDigits);
    return '$formattedNumber $symbol';
  }

  /// Formatear porcentaje
  String formatPercentage(double percentage, {int decimalDigits = 1}) {
    final formatter = NumberFormat('#,##0.${'0' * decimalDigits}', 'es_ES');
    return '${formatter.format(percentage)}%';
  }

  /// Obtener iniciales de un nombre
  String getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';

    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    } else {
      return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    }
  }

  /// Generar color a partir de una cadena
  Color generateColorFromString(String text) {
    int hash = 0;
    for (int i = 0; i < text.length; i++) {
      hash = text.codeUnitAt(i) + ((hash << 5) - hash);
    }

    final hue = hash % 360;
    return HSLColor.fromAHSL(1.0, hue.toDouble(), 0.7, 0.6).toColor();
  }

  /// Obtener color de contraste (blanco o negro)
  Color getContrastColor(Color backgroundColor) {
    // Calcular luminancia relativa
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Verificar si un email es válido
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Verificar si un teléfono es válido
  bool isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^\+?[0-9]{8,15}$');
    return phoneRegex.hasMatch(phone);
  }

  /// Verificar si una URL es válida
  bool isValidUrl(String url) {
    try {
      Uri.parse(url);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Truncar texto a una longitud máxima
  String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 3)}...';
  }

  /// Capitalizar palabras (primera letra de cada palabra en mayúscula)
  String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map(
          (word) =>
              word.isNotEmpty
                  ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
                  : '',
        )
        .join(' ');
  }

  /// Obtener nombre de archivo desde una URL
  String getFileNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.last : 'archivo';
    } catch (_) {
      return 'archivo';
    }
  }

  /// Obtener extensión de archivo desde una URL
  String getFileExtensionFromUrl(String url) {
    final fileName = getFileNameFromUrl(url);
    final dotIndex = fileName.lastIndexOf('.');
    return dotIndex != -1 && dotIndex < fileName.length - 1
        ? fileName.substring(dotIndex + 1).toLowerCase()
        : '';
  }

  /// Verificar si un archivo es una imagen
  bool isImageFile(String url) {
    final extension = getFileExtensionFromUrl(url);
    const imageExtensions = {'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'svg'};
    return imageExtensions.contains(extension);
  }

  /// Formatear tamaño de archivo
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Copiar texto al portapapeles
  Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  /// Abrir URL en navegador externo
  Future<bool> launchUrlExternal(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Abrir URL en navegador interno (si está disponible)
  Future<bool> launchUrlInternal(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.inAppWebView);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Vibrar el dispositivo
  Future<void> vibrate({int duration = 100}) async {
    // Nota: En iOS, la vibración puede tener restricciones
    // En web, no hay soporte nativo
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        // Para Android
        await SystemChannels.platform.invokeMethod<void>(
          'HapticFeedback.vibrate',
          duration,
        );
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        // Para iOS
        await SystemChannels.platform.invokeMethod<void>(
          'HapticFeedback.impact',
          {'style': 'medium'},
        );
      }
    } catch (_) {
      // Ignorar errores de vibración
    }
  }

  /// Obtener safe area top (altura de la barra de estado)
  double getSafeAreaTop(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  /// Obtener safe area bottom (altura de la barra de navegación)
  double getSafeAreaBottom(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }

  /// Obtener safe area vertical total
  double getSafeAreaVertical(BuildContext context) {
    return getSafeAreaTop(context) + getSafeAreaBottom(context);
  }

  /// Verificar si es tablet
  bool isTablet(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide >= 600;
  }

  /// Verificar si es teléfono
  bool isPhone(BuildContext context) {
    return !isTablet(context);
  }

  /// Obtener orientación actual
  Orientation getOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation;
  }

  /// Verificar si está en modo oscuro
  bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Obtener color primario del tema
  Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).primaryColor;
  }

  /// Obtener color de acento del tema
  Color getAccentColor(BuildContext context) {
    return Theme.of(context).colorScheme.secondary;
  }

  /// Obtener color de fondo del tema
  Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor;
  }

  /// Obtener color de texto del tema
  Color getTextColor(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
  }

  /// Generar ID único
  String generateUniqueId({String prefix = ''}) {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomValue = random.nextInt(1000000);
    final id = '${timestamp}_${randomValue}';
    return prefix.isNotEmpty ? '${prefix}_$id' : id;
  }

  /// Convertir color a hex string
  String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0')}';
  }

  /// Convertir hex string a color
  Color hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  /// Mezclar dos colores
  Color blendColors(Color color1, Color color2, double ratio) {
    final inverseRatio = 1.0 - ratio;
    return Color.fromARGB(
      (color1.a * inverseRatio + color2.a * ratio).round(),
      (color1.r * inverseRatio + color2.r * ratio).round(),
      (color1.g * inverseRatio + color2.g * ratio).round(),
      (color1.b * inverseRatio + color2.b * ratio).round(),
    );
  }

  /// Aplicar opacidad a un color
  Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  /// Aclarar un color
  Color lightenColor(Color color, double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  /// Oscurecer un color
  Color darkenColor(Color color, double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  /// Calcular edad a partir de fecha de nacimiento
  int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// Verificar si una fecha es hoy
  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Verificar si una fecha es ayer
  bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Verificar si una fecha es esta semana
  bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    startOfWeek.copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    return date.isAfter(startOfWeek) && date.isBefore(endOfWeek);
  }

  /// Verificar si una fecha es este mes
  bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  /// Obtener tiempo relativo (ej: "hace 2 horas")
  String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return 'hace $years ${years == 1 ? 'año' : 'años'}';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'hace $months ${months == 1 ? 'mes' : 'meses'}';
    } else if (difference.inDays > 0) {
      return 'hace ${difference.inDays} ${difference.inDays == 1 ? 'día' : 'días'}';
    } else if (difference.inHours > 0) {
      return 'hace ${difference.inHours} ${difference.inHours == 1 ? 'hora' : 'horas'}';
    } else if (difference.inMinutes > 0) {
      return 'hace ${difference.inMinutes} ${difference.inMinutes == 1 ? 'minuto' : 'minutos'}';
    } else {
      return 'hace unos segundos';
    }
  }

  /// Parsear JSON de forma segura
  Map<String, dynamic> parseJson(String jsonString) {
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  /// Parsear JSON de forma segura (con manejo de errores)
  Map<String, dynamic>? parseJsonSafe(String jsonString) {
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Convertir objeto a JSON string
  String toJsonString(Map<String, dynamic> json) {
    return jsonEncode(json);
  }

  /// Ejecutar función con reintentos
  Future<T> executeWithRetry<T>(
    Future<T> Function() function, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        return await function();
      } catch (e) {
        if (i == maxRetries - 1) rethrow;
        await Future.delayed(delay * (i + 1));
      }
    }
    throw Exception('Failed after $maxRetries retries');
  }

  /// Ejecutar función con timeout
  Future<T> executeWithTimeout<T>(
    Future<T> Function() function, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    return await function().timeout(timeout);
  }

  /// Debounce function
  Function() debounce(
    Function func, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    Timer? timer;
    return () {
      timer?.cancel();
      timer = Timer(duration, () {
        func();
      });
    };
  }

  /// Throttle function
  Function() throttle(
    Function func, {
    Duration interval = const Duration(milliseconds: 300),
  }) {
    bool isThrottled = false;

    return () {
      if (isThrottled) return;

      func();
      isThrottled = true;

      Timer(interval, () {
        isThrottled = false;
      });
    };
  }

  /// Obtener plataforma actual
  String getCurrentPlatform() {
    if (kIsWeb) return AppConstants.platformWeb;
    if (io.Platform.isAndroid) return AppConstants.platformAndroid;
    if (io.Platform.isIOS) return AppConstants.platformIOS;
    if (io.Platform.isWindows) return AppConstants.platformWindows;
    if (io.Platform.isLinux) return AppConstants.platformLinux;
    if (io.Platform.isMacOS) return AppConstants.platformMacOS;
    return 'unknown';
  }

  /// Verificar si es Android
  bool get isAndroid => io.Platform.isAndroid;

  /// Verificar si es iOS
  bool get isIOS => io.Platform.isIOS;

  /// Verificar si es Windows
  bool get isWindows => io.Platform.isWindows;

  /// Verificar si es Linux
  bool get isLinux => io.Platform.isLinux;

  /// Verificar si es macOS
  bool get isMacOS => io.Platform.isMacOS;

  /// Verificar si es web
  bool get isWeb => kIsWeb;

  /// Obtener versión de la aplicación
  String get appVersion {
    // Usar package_info_plus para obtener la versión real
    // Por ahora, retornar una constante
    return '1.0.0';
  }

  /// Obtener build number de la aplicación
  String get appBuildNumber {
    // Usar package_info_plus para obtener el build number real
    // Por ahora, retornar una constante
    return '1';
  }

  /// Verificar si es modo debug
  bool get isDebugMode => kDebugMode;

  /// Verificar si es modo release
  bool get isReleaseMode => kReleaseMode;

  /// Verificar si es modo profile
  bool get isProfileMode => kProfileMode;

  /// Obtener información del dispositivo
  Map<String, dynamic> getDeviceInfo() {
    return {
      'platform': getCurrentPlatform(),
      'isAndroid': isAndroid,
      'isIOS': isIOS,
      'isWeb': isWeb,
      'appVersion': appVersion,
      'appBuildNumber': appBuildNumber,
      'debugMode': isDebugMode,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Obtener día de la semana en español
  String getDayOfWeekInSpanish(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'Lunes';
      case DateTime.tuesday:
        return 'Martes';
      case DateTime.wednesday:
        return 'Miércoles';
      case DateTime.thursday:
        return 'Jueves';
      case DateTime.friday:
        return 'Viernes';
      case DateTime.saturday:
        return 'Sábado';
      case DateTime.sunday:
        return 'Domingo';
      default:
        return '';
    }
  }

  /// Obtener mes en español
  String getMonthInSpanish(DateTime date) {
    switch (date.month) {
      case 1:
        return 'Enero';
      case 2:
        return 'Febrero';
      case 3:
        return 'Marzo';
      case 4:
        return 'Abril';
      case 5:
        return 'Mayo';
      case 6:
        return 'Junio';
      case 7:
        return 'Julio';
      case 8:
        return 'Agosto';
      case 9:
        return 'Septiembre';
      case 10:
        return 'Octubre';
      case 11:
        return 'Noviembre';
      case 12:
        return 'Diciembre';
      default:
        return '';
    }
  }

  /// Obtener fecha formateada en español
  String getFormattedDateInSpanish(DateTime date) {
    final dayName = getDayOfWeekInSpanish(date);
    final monthName = getMonthInSpanish(date);
    return '$dayName, ${date.day} de $monthName de ${date.year}';
  }

  /// Calcular distancia entre dos coordenadas (en km)
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Radio de la Tierra en km

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  /// Formatear distancia para mostrar
  String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      final meters = (distanceInKm * 1000).round();
      return '$meters m';
    } else if (distanceInKm < 10) {
      return '${distanceInKm.toStringAsFixed(1)} km';
    } else {
      return '${distanceInKm.round()} km';
    }
  }

  /// Mostrar toast
  void showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  /// Mostrar diálogo de confirmación
  Future<bool?> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
  }) async {
    return await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(cancelText),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(confirmText),
              ),
            ],
          ),
    );
  }

  /// Mostrar diálogo de carga
  void showLoadingDialog(
    BuildContext context, {
    String message = 'Cargando...',
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 16),
                Text(message),
              ],
            ),
          ),
    );
  }

  /// Ocultar diálogo de carga
  void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  /// Ejecutar función con indicador de carga
  Future<T> executeWithLoading<T>(
    BuildContext context,
    Future<T> Function() function, {
    String loadingMessage = 'Cargando...',
  }) async {
    showLoadingDialog(context, message: loadingMessage);
    try {
      final result = await function();
      hideLoadingDialog(context);
      return result;
    } catch (e) {
      hideLoadingDialog(context);
      rethrow;
    }
  }
}
