import 'package:flutter/material.dart';

/// Design tokens: colors, typography, spacing
/// This file contains the single source of truth for visual values.
/// Keep values small, semantic, and framework-agnostic where possible.

class AppColors {
  // Primary brand
  static const Color primary = Color(0xFF0A73FF); // Blue 600
  static const Color primaryVariant = Color(0xFF0059D6);

  // Secondary / accent
  static const Color secondary = Color(0xFFFFC107); // Amber

  // Background / surface
  static const Color background = Color(0xFFF7F9FC);
  static const Color surface = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF0F1724);
  static const Color textSecondary = Color(0xFF6B7280);

  // Semantic
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color border = Color(0xFFE6E9EE);

  // Shadows / overlays
  static const Color shadow = Color.fromRGBO(15, 23, 36, 0.08);
}

class AppSpacing {
  // Base spacing scale (8pt grid)
  static const double base = 8.0;
  static const double xs = base * 0.5; // 4
  static const double sm = base; // 8
  static const double md = base * 2; // 16
  static const double lg = base * 3; // 24
  static const double xl = base * 5; // 40

  // Helpful helpers
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
}

class AppTypography {
  // Note: For production add a packaged font (e.g. Inter, Poppins) and set fontFamily.
  // Here we use system fallbacks to avoid changing pubspec.yaml.
  static const String fontFamily = 'Roboto';

  static TextStyle _h(double size, [double height = 1.2, FontWeight weight = FontWeight.w700]) =>
      TextStyle(fontFamily: fontFamily, fontSize: size, height: height, fontWeight: weight, color: AppColors.textPrimary);

  static TextStyle _b(double size, [double height = 1.3, FontWeight weight = FontWeight.w400]) =>
      TextStyle(fontFamily: fontFamily, fontSize: size, height: height, fontWeight: weight, color: AppColors.textPrimary);

  // Headings
  static final TextStyle h1 = _h(28);
  static final TextStyle h2 = _h(22);
  static final TextStyle h3 = _h(18);
  static final TextStyle h4 = _h(16);

  // Body
  static final TextStyle bodyLarge = _b(16);
  static final TextStyle body = _b(14);
  static final TextStyle bodySmall = _b(12, 1.2);

  // UI elements
  static final TextStyle button = _b(14, 1.1, FontWeight.w600).copyWith(color: Colors.white);
  static final TextStyle caption = _b(12, 1.0, FontWeight.w500).copyWith(color: AppColors.textSecondary);

  static TextTheme toTextTheme() {
    return TextTheme(
      headlineLarge: h1,
      headlineMedium: h2,
      headlineSmall: h3,
      titleLarge: h4,
      bodyLarge: bodyLarge,
      bodyMedium: body,
      bodySmall: bodySmall,
      labelLarge: button,
      labelSmall: caption,
    );
  }
}
