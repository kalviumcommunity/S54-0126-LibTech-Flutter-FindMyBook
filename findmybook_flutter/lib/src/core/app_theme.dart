import 'package:flutter/material.dart';
import 'design_system.dart';

/// App theme mapping tokens from `design_system.dart` into Flutter's ThemeData

final ThemeData appTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.background,
  backgroundColor: AppColors.background,
  canvasColor: AppColors.surface,
  errorColor: AppColors.error,
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.secondary,
    onSecondary: Colors.black,
    error: AppColors.error,
    onError: Colors.white,
    background: AppColors.background,
    onBackground: AppColors.textPrimary,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
  ),
  // App bar
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.primary,
    elevation: 2,
    foregroundColor: Colors.white,
    titleTextStyle: AppTypography.h4.copyWith(color: Colors.white),
    iconTheme: IconThemeData(color: Colors.white),
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
  textTheme: AppTypography.toTextTheme(),
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
  cardTheme: CardTheme(
    color: AppColors.surface,
    elevation: 1,
    margin: EdgeInsets.symmetric(vertical: AppSpacing.sm),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  elevatedButtonColor: AppColors.primary,
  dividerColor: AppColors.border,
  shadowColor: AppColors.shadow,
);
