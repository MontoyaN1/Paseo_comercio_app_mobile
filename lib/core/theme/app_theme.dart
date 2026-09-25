// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

/// Tema de la aplicación con soporte para modo claro y oscuro.
///
/// Los painters isométricos (mall, login) mantienen sus colores de branding
/// y no son afectados por el tema.
abstract class AppTheme {
  // ═══════════════════════════════════════════════════════════════════
  // TEMA OSCURO (Default)
  // ═══════════════════════════════════════════════════════════════════

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.darkSurface,
      primary: AppColors.darkGoldAccent,
      secondary: AppColors.darkGoldLight,
      tertiary: AppColors.darkGoldDeep,
      error: AppColors.darkError,
      onSurface: AppColors.darkOnSurface,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onError: Colors.black,
      surfaceContainerHighest: AppColors.darkBorder,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: AppColors.darkOnSurface,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkSurfaceCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.darkBorder, width: 1),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.darkBorder,
      thickness: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.darkGoldAccent,
          width: 1.5,
        ),
      ),
      hintStyle: const TextStyle(color: AppColors.darkHint),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkGoldAccent,
        foregroundColor: Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.darkGoldAccent,
        side: const BorderSide(color: AppColors.darkGoldAccent),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.darkGoldAccent),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.darkGoldAccent,
      foregroundColor: Colors.black,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.darkSurface,
      contentTextStyle: const TextStyle(color: AppColors.darkOnSurface),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.darkBorder),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: AppColors.darkGoldAccent,
      unselectedItemColor: AppColors.darkHint,
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.darkGoldAccent,
      unselectedLabelColor: AppColors.darkHint,
      indicatorColor: AppColors.darkGoldAccent,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedColor: AppColors.darkGoldAccent.withOpacity(0.2),
      labelStyle: const TextStyle(color: AppColors.darkOnSurface),
      side: const BorderSide(color: AppColors.darkBorder),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: AppColors.darkGoldAccent,
      textColor: AppColors.darkOnSurface,
    ),
    iconTheme: const IconThemeData(color: AppColors.darkGoldAccent),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColors.darkOnSurface),
      displayMedium: TextStyle(color: AppColors.darkOnSurface),
      displaySmall: TextStyle(color: AppColors.darkOnSurface),
      headlineLarge: TextStyle(color: AppColors.darkOnSurface),
      headlineMedium: TextStyle(color: AppColors.darkOnSurface),
      headlineSmall: TextStyle(color: AppColors.darkOnSurface),
      titleLarge: TextStyle(color: AppColors.darkOnSurface),
      titleMedium: TextStyle(color: AppColors.darkOnSurface),
      titleSmall: TextStyle(color: AppColors.darkOnSurface),
      bodyLarge: TextStyle(color: AppColors.darkOnSurface),
      bodyMedium: TextStyle(color: AppColors.darkOnSurface),
      bodySmall: TextStyle(color: AppColors.darkHint),
      labelLarge: TextStyle(color: AppColors.darkOnSurface),
      labelMedium: TextStyle(color: AppColors.darkOnSurface),
      labelSmall: TextStyle(color: AppColors.darkHint),
    ),
  );

  // ═══════════════════════════════════════════════════════════════════
  // TEMA CLARO
  // ═══════════════════════════════════════════════════════════════════

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      surface: AppColors.lightSurface,
      primary: AppColors.lightGoldAccent,
      secondary: AppColors.lightGoldLight,
      tertiary: AppColors.lightGoldDeep,
      error: AppColors.lightError,
      onSurface: AppColors.lightOnSurface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onError: Colors.white,
      surfaceContainerHighest: AppColors.lightBorder,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightSurface,
      foregroundColor: AppColors.lightOnSurface,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
    cardTheme: CardThemeData(
      color: AppColors.lightSurfaceCard,
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.lightBorder, width: 1),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.lightBorder,
      thickness: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightSurface.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.lightGoldAccent,
          width: 1.5,
        ),
      ),
      hintStyle: const TextStyle(color: AppColors.lightHint),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightGoldAccent,
        foregroundColor: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.lightGoldAccent,
        side: const BorderSide(color: AppColors.lightGoldAccent),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.lightGoldAccent),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.lightGoldAccent,
      foregroundColor: Colors.white,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.lightSurface,
      contentTextStyle: const TextStyle(color: AppColors.lightOnSurface),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.lightBorder),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightSurface,
      selectedItemColor: AppColors.lightGoldAccent,
      unselectedItemColor: AppColors.lightHint,
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.lightGoldAccent,
      unselectedLabelColor: AppColors.lightHint,
      indicatorColor: AppColors.lightGoldAccent,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.lightSurface,
      selectedColor: AppColors.lightGoldAccent.withOpacity(0.2),
      labelStyle: const TextStyle(color: AppColors.lightOnSurface),
      side: const BorderSide(color: AppColors.lightBorder),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.lightSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: AppColors.lightGoldAccent,
      textColor: AppColors.lightOnSurface,
    ),
    iconTheme: const IconThemeData(color: AppColors.lightGoldAccent),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColors.lightOnSurface),
      displayMedium: TextStyle(color: AppColors.lightOnSurface),
      displaySmall: TextStyle(color: AppColors.lightOnSurface),
      headlineLarge: TextStyle(color: AppColors.lightOnSurface),
      headlineMedium: TextStyle(color: AppColors.lightOnSurface),
      headlineSmall: TextStyle(color: AppColors.lightOnSurface),
      titleLarge: TextStyle(color: AppColors.lightOnSurface),
      titleMedium: TextStyle(color: AppColors.lightOnSurface),
      titleSmall: TextStyle(color: AppColors.lightOnSurface),
      bodyLarge: TextStyle(color: AppColors.lightOnSurface),
      bodyMedium: TextStyle(color: AppColors.lightOnSurface),
      bodySmall: TextStyle(color: AppColors.lightHint),
      labelLarge: TextStyle(color: AppColors.lightOnSurface),
      labelMedium: TextStyle(color: AppColors.lightOnSurface),
      labelSmall: TextStyle(color: AppColors.lightHint),
    ),
  );
}
