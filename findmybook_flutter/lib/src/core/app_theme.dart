import 'package:flutter/material.dart';
import 'design_system.dart';

/// App theme mapping tokens from `design_system.dart` into Flutter's ThemeData

final ColorScheme _appColorScheme = ColorScheme.fromSeed(
  seedColor: AppColors.primary,
  primary: AppColors.primary,
  secondary: AppColors.secondary,
  background: AppColors.background,
  surface: AppColors.surface,
  error: AppColors.error,
  brightness: Brightness.light,
  onBackground: AppColors.textPrimary,
  onSurface: AppColors.textPrimary,
  onPrimary: Colors.white,
  onSecondary: Colors.black,
  onError: Colors.white,
);

final ThemeData appTheme = ThemeData.from(colorScheme: _appColorScheme, textTheme: AppTypography.toTextTheme()).copyWith(
  useMaterial3: true,
  // App bar
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.primary,
    elevation: 2,
    foregroundColor: Colors.white,
    titleTextStyle: AppTypography.h4.copyWith(color: Colors.white),
    iconTheme: const IconThemeData(color: Colors.white),
  ),
  // Buttons
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      textStyle: AppTypography.button,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.border),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
  ),

  cardTheme: CardThemeData(
    color: AppColors.surface,
    elevation: 1,
    margin: EdgeInsets.symmetric(vertical: AppSpacing.sm),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  elevatedButtonColor: AppColors.primary,

  dividerColor: AppColors.border,
  shadowColor: AppColors.shadow,
);
