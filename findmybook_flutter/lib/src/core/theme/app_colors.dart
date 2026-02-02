/// App Colors - Equivalent to: Material-UI Color Palette in React
/// 
/// MERN Comparison:
/// In React: const colors = { primary: '#6200EA', secondary: '#03DAC6', ... }
/// In Flutter: Static class with const Color objects, accessed globally
///
/// MongoDB (Firestore): Often stored as hex strings '#6200EA'
/// Flutter: Uses Color class - Color(0xFF6200EA)

import 'package:flutter/material.dart';

abstract class AppColors {
  // ============= Primary Colors =============
  /// Main brand color - Used for CTAs, selected states, primary buttons
  static const Color primary = Color(0xFF6200EA);
  static const Color primaryDark = Color(0xFF3700B3);
  static const Color primaryLight = Color(0xFFBB86FC);

  // ============= Secondary Colors =============
  /// Accent color for highlights, secondary CTAs
  static const Color secondary = Color(0xFF03DAC6);
  static const Color secondaryDark = Color(0xFF018786);
  static const Color secondaryLight = Color(0xFFB2EBF2);

  // ============= Error Colors =============
  static const Color error = Color(0xFFB00020);
  static const Color errorLight = Color(0xFFEF5350);
  static const Color errorBackground = Color(0xFFFDE9E6);

  // ============= Success Colors =============
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successBackground = Color(0xFFC8E6C9);

  // ============= Warning Colors =============
  static const Color warning = Color(0xFFFFC107);
  static const Color warningDark = Color(0xFFFFB300);
  static const Color warningBackground = Color(0xFFFFF3E0);

  // ============= Neutral Colors (Grayscale) =============
  /// Used for text, backgrounds, borders
  static const Color dark = Color(0xFF121212);
  static const Color darkGrey = Color(0xFF424242);
  static const Color grey = Color(0xFF757575);
  static const Color lightGrey = Color(0xFFBDBDBD);
  static const Color extraLightGrey = Color(0xFFE0E0E0);
  static const Color light = Color(0xFFFAFAFA);
  static const Color white = Color(0xFFFFFFFF);

  // ============= Text Colors =============
  /// High emphasis text (primary content)
  static const Color textPrimary = Color(0xFF212121);
  
  /// Medium emphasis text (secondary content, hints)
  static const Color textSecondary = Color(0xFF757575);
  
  /// Low emphasis text (disabled, placeholders)
  static const Color textTertiary = Color(0xFFBDBDBD);
  
  /// Text on dark/colored backgrounds
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ============= Background Colors =============
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  // ============= Border Colors =============
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFFBDBDBD);
  static const Color borderLight = Color(0xFFF0F0F0);

  // ============= Overlay Colors =============
  /// Used for modals, dimming overlays
  static const Color overlay = Color(0x80000000); // 50% black

  // ============= Disabled States =============
  static const Color disabled = Color(0xFFE0E0E0);
  static const Color disabledText = Color(0xFFBDBDBD);

  // ============= Special Library-Related Colors =============
  static const Color bookBluish = Color(0xFF1976D2);
  static const Color bookGreenish = Color(0xFF388E3C);
  static const Color bookPurplish = Color(0xFF7B1FA2);
  static const Color bookOrangish = Color(0xFFF57C00);
}
