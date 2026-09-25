// lib/core/theme/app_colors.dart

import 'package:flutter/material.dart';

/// Colores de la aplicación para tema claro y oscuro.
///
/// Los colores de branding (painters, efectos isométricos) permanecen constantes.
/// Solo los colores de UI genéricos cambian con el tema.
abstract class AppColors {
  // ═══════════════════════════════════════════════════════════════════
  // COLORES DE UI GENÉRICOS (Cambian con el tema)
  // ═══════════════════════════════════════════════════════════════════

  // ── Backgrounds ────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0A0A0F);
  static const Color lightBackground = Color(0xFFFAFAFA);

  // ── Superficies ────────────────────────────────────────────────
  static const Color darkSurface = Color(0xFF0F0F1E);
  static const Color lightSurface = Color(0xFFFFFFFF);

  // ── Textos principales ────────────────────────────────────────
  static const Color darkOnSurface = Color(0xFFFFFFFF);
  static const Color lightOnSurface = Color(0xFF1A1A1A);

  // ── Textos secundarios ──────────────────────────────────────────
  static const Color darkOnSurfaceVariant = Color(0xFFB0B0B0);
  static const Color lightOnSurfaceVariant = Color(0xFF4A4A4A);

  // ── Acentos dorados (branding pero ajustables) ───────────────
  static const Color darkGoldAccent = Color(0xFFD4AF37);
  static const Color lightGoldAccent = Color(0xFFC9A227);

  static const Color darkGoldLight = Color(0xFFFFE082);
  static const Color lightGoldLight = Color(0xFFFFD54F);

  static const Color darkGoldDeep = Color(0xFF9C7A1A);
  static const Color lightGoldDeep = Color(0xFF8B6914);

  // ── Bordes ────────────────────────────────────────────────────
  static const Color darkBorder = Color(0xFF1E1E3A);
  static const Color lightBorder = Color(0xFFE0E0E0);

  // ── Errores ──────────────────────────────────────────────────
  static const Color darkError = Color(0xFFCF6679);
  static const Color lightError = Color(0xFFB00020);

  // ── Éxito ────────────────────────────────────────────────────
  static const Color darkSuccess = Color(0xFF4CAF50);
  static const Color lightSuccess = Color(0xFF388E3C);

  // ── Hints y textos deshabilitados ────────────────────────────
  static const Color darkHint = Color(0xFF6B6B8A);
  static const Color lightHint = Color(0xFF757575);

  // ═══════════════════════════════════════════════════════════════════
  // COLORES DE BRANDING (NO cambian con el tema)
  // ═══════════════════════════════════════════════════════════════════

  // ── Neons del mall (son parte del branding visual) ───────────
  static const Color neonBlue = Color(0xFF00C8FF);
  static const Color neonPink = Color(0xFFFF2D78);
  static const Color neonGreen = Color(0xFF00FF9F);
  static const Color neonOrange = Color(0xFFFF8C00);

  // ── Efectos de iluminación ───────────────────────────────────
  static const Color warmLight = Color(0xFFFFE4A0);
  static const Color coolLight = Color(0xFFB0D4FF);
  static const Color skylight = Color(0xFFE8F4FF);

  // ── Gold para branding ──────────────────────────────────────
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldGlow = Color(0xFFFFE082);
  static const Color goldDeep = Color(0xFF9C7A1A);

  // ── Superficie de superficie para cards ─────────────────────
  static const Color darkSurfaceCard = Color(0xFF12121F);
  static const Color lightSurfaceCard = Color(0xFFFFFFFF);

  // ── Hint alternativo ─────────────────────────────────────────
  static const Color darkHintAlt = Color(0xFF8A8AA0);
  static const Color lightHintAlt = Color(0xFF9E9E9E);
}

/// Extensión de ColorScheme para acceder a colores custom de la app.
extension AppColorScheme on ColorScheme {
  Color get goldAccent =>
      brightness == Brightness.dark
          ? AppColors.darkGoldAccent
          : AppColors.lightGoldAccent;

  Color get goldLight =>
      brightness == Brightness.dark
          ? AppColors.darkGoldLight
          : AppColors.lightGoldLight;

  Color get goldDeep =>
      brightness == Brightness.dark
          ? AppColors.darkGoldDeep
          : AppColors.lightGoldDeep;

  Color get surfaceCard =>
      brightness == Brightness.dark
          ? AppColors.darkSurfaceCard
          : AppColors.lightSurfaceCard;

  Color get hintAlt =>
      brightness == Brightness.dark
          ? AppColors.darkHintAlt
          : AppColors.lightHintAlt;

  Color get success =>
      brightness == Brightness.dark
          ? AppColors.darkSuccess
          : AppColors.lightSuccess;
}
