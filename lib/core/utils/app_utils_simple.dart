// lib/core/utils/app_utils_simple.dart
// Versión simplificada temporal para resolver problemas de compilación

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Utilidades generales para la aplicación
class AppUtilsSimple {
  // Singleton pattern
  static final AppUtilsSimple _instance = AppUtilsSimple._internal();
  factory AppUtilsSimple() => _instance;
  AppUtilsSimple._internal();

  /// Verificar si un email es válido
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Verificar si un teléfono es válido
  bool isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
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

  /// Formatear número con separadores de miles
  String formatNumber(num number, {int decimalDigits = 0}) {
    final formatter = NumberFormat.decimalPatternDigits(
      locale: 'es_ES',
      decimalDigits: decimalDigits,
    );
    return formatter.format(number);
  }

  /// Formatear moneda
  String formatCurrency(
    num amount, {
    String symbol = '€',
    int decimalDigits = 2,
  }) {
    final formattedNumber = formatNumber(amount, decimalDigits: decimalDigits);
    return '$formattedNumber $symbol';
  }

  /// Formatear fecha
  String formatDate(DateTime date, {String format = 'dd/MM/yyyy'}) {
    final formatter = DateFormat(format, 'es_ES');
    return formatter.format(date);
  }

  /// Formatear fecha y hora
  String formatDateTime(
    DateTime dateTime, {
    String format = 'dd/MM/yyyy HH:mm',
  }) {
    final formatter = DateFormat(format, 'es_ES');
    return formatter.format(dateTime);
  }

  /// Capitalizar palabras
  String capitalizeWords(String text) {
    if (text.isEmpty) return text;

    final words = text.split(' ');
    final capitalizedWords =
        words.map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        }).toList();

    return capitalizedWords.join(' ');
  }

  /// Truncar texto
  String truncateText(
    String text, {
    int maxLength = 100,
    String ellipsis = '...',
  }) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}$ellipsis';
  }

  /// Obtener iniciales de un nombre
  String getInitials(String name, {int maxInitials = 2}) {
    if (name.isEmpty) return '';

    final words = name.split(' ');
    final initials = words
        .take(maxInitials)
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase();
        })
        .join('');

    return initials;
  }

  /// Calcular edad a partir de fecha de nacimiento
  int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;

    // Ajustar si aún no ha pasado el cumpleaños este año
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
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Verificar si una fecha es este mes
  bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  /// Copiar texto al portapapeles
  Future<void> copyToClipboard(String text, {BuildContext? context}) async {
    await Clipboard.setData(ClipboardData(text: text));

    if (context != null && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Copiado al portapapeles')));
    }
  }

  /// Vibrar el dispositivo (solo móvil)
  Future<void> vibrate({int milliseconds = 100}) async {
    // Nota: En una implementación real, usaríamos el paquete vibration
    // Por ahora, es solo un placeholder
  }

  /// Función debounce
  Function() debounce(
    Function func, {
    Duration delay = const Duration(milliseconds: 300),
  }) {
    Timer? timer;

    return () {
      timer?.cancel();
      timer = Timer(delay, () {
        func();
      });
    };
  }

  /// Función throttle
  Function() throttle(
    Function func, {
    Duration delay = const Duration(milliseconds: 300),
  }) {
    bool isThrottled = false;

    return () {
      if (!isThrottled) {
        isThrottled = true;
        func();

        Timer(delay, () {
          isThrottled = false;
        });
      }
    };
  }

  /// Generar ID único
  String generateUniqueId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomNum = random.nextInt(1000000);
    return '${timestamp}_$randomNum';
  }

  /// Convertir color hexadecimal a Color
  Color hexToColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');

    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }

    return Color(int.parse(hexColor, radix: 16));
  }

  /// Obtener color contrastante (blanco o negro)
  Color getContrastColor(Color backgroundColor) {
    // Calcular luminosidad relativa
    final luminance =
        (0.299 * backgroundColor.red +
            0.587 * backgroundColor.green +
            0.114 * backgroundColor.blue) /
        255;

    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Formatear duración
  String formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  /// Obtener nombre del mes
  String getMonthName(int month, {bool short = false}) {
    final months =
        short
            ? [
              'Ene',
              'Feb',
              'Mar',
              'Abr',
              'May',
              'Jun',
              'Jul',
              'Ago',
              'Sep',
              'Oct',
              'Nov',
              'Dic',
            ]
            : [
              'Enero',
              'Febrero',
              'Marzo',
              'Abril',
              'Mayo',
              'Junio',
              'Julio',
              'Agosto',
              'Septiembre',
              'Octubre',
              'Noviembre',
              'Diciembre',
            ];

    return months[month - 1];
  }

  /// Obtener nombre del día de la semana
  String getWeekdayName(int weekday, {bool short = false}) {
    final days =
        short
            ? ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb']
            : [
              'Domingo',
              'Lunes',
              'Martes',
              'Miércoles',
              'Jueves',
              'Viernes',
              'Sábado',
            ];

    return days[weekday - 1];
  }

  /// Validar contraseña
  bool isValidPassword(String password) {
    // Al menos 8 caracteres, una mayúscula, una minúscula y un número
    final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$');
    return passwordRegex.hasMatch(password);
  }

  /// Obtener diferencia de tiempo en texto amigable
  String getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'hace unos segundos';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return 'hace ${minutes} ${minutes == 1 ? 'minuto' : 'minutos'}';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return 'hace ${hours} ${hours == 1 ? 'hora' : 'horas'}';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return 'hace ${days} ${days == 1 ? 'día' : 'días'}';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'hace ${weeks} ${weeks == 1 ? 'semana' : 'semanas'}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'hace ${months} ${months == 1 ? 'mes' : 'meses'}';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'hace ${years} ${years == 1 ? 'año' : 'años'}';
    }
  }

  /// Mostrar diálogo de confirmación
  Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Aceptar',
    String cancelText = 'Cancelar',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(cancelText),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(confirmText),
              ),
            ],
          ),
    );

    return result ?? false;
  }

  /// Mostrar snackbar
  void showSnackBar(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    Color backgroundColor = Colors.black87,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: backgroundColor,
      ),
    );
  }

  /// Obtener altura del teclado
  double getKeyboardHeight(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final viewInsets = mediaQuery.viewInsets.bottom;
    return viewInsets > 0 ? viewInsets : 0;
  }

  /// Verificar si el teclado está visible
  bool isKeyboardVisible(BuildContext context) {
    return getKeyboardHeight(context) > 0;
  }

  /// Ocultar teclado
  void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Verificar modo oscuro
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

  /// Verificar si es un dispositivo móvil
  bool isMobile(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width < 600;
  }

  /// Verificar si es una tablet
  bool isTablet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width >= 600 && size.width < 1200;
  }

  /// Verificar si es un escritorio
  bool isDesktop(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width >= 1200;
  }

  /// Obtener orientación del dispositivo
  Orientation getOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation;
  }

  /// Verificar si está en orientación portrait
  bool isPortrait(BuildContext context) {
    return getOrientation(context) == Orientation.portrait;
  }

  /// Verificar si está en orientación landscape
  bool isLandscape(BuildContext context) {
    return getOrientation(context) == Orientation.landscape;
  }
}
