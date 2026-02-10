/// App Theme Configuration - Equivalent to: Material-UI theme object
/// 
/// MERN Comparison:
/// In React: export const theme = createTheme({ palette: { primary: { main: '#6200EA' } }, ... })
/// In Flutter: Returns a complete ThemeData object that's applied globally to the app
///
/// This centralizes all theme decisions:
/// - Component styles (buttons, inputs, etc.)
/// - Color scheme
/// - Typography
/// - Shadows and elevations
/// - Border radius defaults

import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

abstract class AppTheme {
  /// Build the complete light theme for the app
  /// Applied via: MaterialApp(theme: AppTheme.lightTheme)
  static ThemeData get lightTheme {
    return ThemeData(
      // ============= Color Scheme =============
      useMaterial3: true, // Use Material Design 3
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.secondaryDark,
        error: AppColors.error,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
      ),

      // ============= Scaffold Background =============
      scaffoldBackgroundColor: AppColors.background,

      // ============= App Bar Theme =============
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        centerTitle: false,
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        toolbarHeight: 56,
      ),

      // ============= Elevated Button Theme (Filled Button) =============
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
          ),
          textStyle: AppTypography.labelLarge.copyWith(
            color: AppColors.white,
          ),
        ),
      ),

      // ============= Outlined Button Theme =============
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
          side: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
          ),
          textStyle: AppTypography.labelLarge.copyWith(
            color: AppColors.primary,
          ),
        ),
      ),

      // ============= Text Button Theme =============
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // ============= Input Decoration Theme =============
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.light,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textPrimary,
        ),
        errorStyle: AppTypography.labelSmall.copyWith(
          color: AppColors.error,
        ),
      ),

      // ============= Card Theme =============
      cardTheme: CardTheme      git add -A
      git commit -m "feat: improve book card UI and add loading skeletons
      
      - Create BookCard presentation widget with rich metadata (genres, year, availability)
      - Add BookCardSkeleton and Shimmer for polished loading states
      - Create BookDetailPage with full book information display
      - Wire navigation from book list to detail page
      - Replace simple ListTile with reusable card component
      - Upgrade Firebase, Riverpod, and GoRouter dependencies"
      git push origin ui-book-skeleton(
        color: AppColors.surface,
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
          side: const BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),

      // ============= Dialog Theme =============
      dialogTheme: DialogThemeData (
        backgroundColor: AppColors.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
        ),
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColors.textPrimary,
        ),
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),

      // ============= Chip Theme =============
      chipTheme: ChipThemeData(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        labelStyle: AppTypography.labelSmall.copyWith(
          color: AppColors.textPrimary,
        ),
        secondaryLabelStyle: AppTypography.labelSmall.copyWith(
          color: AppColors.textOnPrimary,
        ),
        brightness: Brightness.light,
        backgroundColor: AppColors.light,
        secondaryBackgroundColor: AppColors.primary,
        selectedColor: AppColors.primary,
        disabledColor: AppColors.disabled,
      ),

      // ============= FloatingActionButton Theme =============
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 6,
        hoverElevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // ============= Bottom Navigation Theme =============
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        elevation: 8,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: AppTypography.labelSmall,
        unselectedLabelStyle: AppTypography.labelSmall,
      ),

      // ============= SnackBar Theme =============
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.dark,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 6,
      ),

      // ============= Progress Indicator Theme =============
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearMinHeight: 4,
        circularTrackColor: AppColors.extraLightGrey,
        refreshBackgroundColor: AppColors.surface,
      ),

      // ============= Divider Theme =============
      dividerTheme: DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: AppSpacing.lg,
      ),

      // ============= Icon Theme =============
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: 24,
      ),

      // ============= Text Themes =============
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge.copyWith(color: AppColors.textPrimary),
        displayMedium: AppTypography.displayMedium.copyWith(color: AppColors.textPrimary),
        displaySmall: AppTypography.displaySmall.copyWith(color: AppColors.textPrimary),
        headlineLarge: AppTypography.headlineLarge.copyWith(color: AppColors.textPrimary),
        headlineMedium: AppTypography.headlineMedium.copyWith(color: AppColors.textPrimary),
        headlineSmall: AppTypography.headlineSmall.copyWith(color: AppColors.textPrimary),
        titleLarge: AppTypography.titleLarge.copyWith(color: AppColors.textPrimary),
        titleMedium: AppTypography.titleMedium.copyWith(color: AppColors.textSecondary),
        titleSmall: AppTypography.titleSmall.copyWith(color: AppColors.textPrimary),
        bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
        bodyMedium: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        bodySmall: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
        labelLarge: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary),
        labelMedium: AppTypography.labelMedium.copyWith(color: AppColors.textPrimary),
        labelSmall: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
      ),

      // ============= Overall Typography =============
      fontFamily: 'Roboto', // Default Flutter font, can customize
    );
  }

  /// Build dark theme (optional, for future implementation)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryLight,
        brightness: Brightness.dark,
        primary: AppColors.primaryLight,
        secondary: AppColors.secondary,
        error: AppColors.errorLight,
        surface: AppColors.dark,
      ),
      scaffoldBackgroundColor: AppColors.dark,
      // ... similar customization for dark theme
    );
  }
}
