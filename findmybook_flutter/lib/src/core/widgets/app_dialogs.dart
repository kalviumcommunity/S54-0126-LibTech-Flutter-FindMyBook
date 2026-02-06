/// App SnackBars & Dialogs - Equivalent to: React toast/modal libraries
/// 
/// MERN Comparison:
/// React: toast.success('Book added!'), or <Modal open={isOpen}>...</Modal>
/// Flutter: AppSnackbars.show(context, 'Book added!'), or showAppDialog(context, ...)
///
/// These are utility helpers for showing transient messages and dialogs
/// throughout the app with consistent styling.

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_button.dart';

/// Snackbar utilities - Equivalent to toast notifications
abstract class AppSnackbars {
  /// Show success snackbar
  /// 
  /// Usage: AppSnackbars.show(context, 'Success!', type: SnackbarType.success)
  static void show(
    BuildContext context,
    String message, {
    SnackbarType type = SnackbarType.info,
    int durationSeconds = 3,
    SnackBarAction? action,
  }) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            _getIcon(type),
            color: AppColors.white,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: _getBackgroundColor(type),
      duration: Duration(seconds: durationSeconds),
      action: action,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(AppSpacing.lg),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void success(
    BuildContext context,
    String message, {
    int durationSeconds = 3,
  }) {
    show(
      context,
      message,
      type: SnackbarType.success,
      durationSeconds: durationSeconds,
    );
  }

  static void error(
    BuildContext context,
    String message, {
    int durationSeconds = 4,
  }) {
    show(
      context,
      message,
      type: SnackbarType.error,
      durationSeconds: durationSeconds,
    );
  }

  static void warning(
    BuildContext context,
    String message, {
    int durationSeconds = 3,
  }) {
    show(
      context,
      message,
      type: SnackbarType.warning,
      durationSeconds: durationSeconds,
    );
  }

  static void info(
    BuildContext context,
    String message, {
    int durationSeconds = 3,
  }) {
    show(
      context,
      message,
      type: SnackbarType.info,
      durationSeconds: durationSeconds,
    );
  }

  static IconData _getIcon(SnackbarType type) {
    return switch (type) {
      SnackbarType.success => Icons.check_circle,
      SnackbarType.error => Icons.error,
      SnackbarType.warning => Icons.warning,
      SnackbarType.info => Icons.info,
    };
  }

  static Color _getBackgroundColor(SnackbarType type) {
    return switch (type) {
      SnackbarType.success => AppColors.success,
      SnackbarType.error => AppColors.error,
      SnackbarType.warning => AppColors.warning,
      SnackbarType.info => AppColors.primary,
    };
  }
}

enum SnackbarType { success, error, warning, info }

/// Dialog utilities
abstract class AppDialogs {
  /// Show confirmation dialog
  /// 
  /// Usage:
  /// ```dart
  /// final confirmed = await AppDialogs.confirm(
  ///   context,
  ///   title: 'Delete Book?',
  ///   message: 'This cannot be undone.',
  /// );
  /// ```
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDangerous = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelLabel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDangerous ? AppColors.error : AppColors.primary,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Show alert dialog with single button
  /// 
  /// Usage:
  /// ```dart
  /// await AppDialogs.alert(
  ///   context,
  ///   title: 'Error',
  ///   message: 'Failed to load books.',
  /// );
  /// ```
  static Future<void> alert(
    BuildContext context, {
    required String title,
    required String message,
    String buttonLabel = 'OK',
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(buttonLabel),
          ),
        ],
      ),
    );
  }

  /// Show custom dialog with full content control
  /// 
  /// Usage:
  /// ```dart
  /// await AppDialogs.custom(
  ///   context,
  ///   title: 'Filter Books',
  ///   content: MyCustomFilterWidget(),
  ///   actions: [
  ///     AppOutlinedButton(label: 'Cancel'),
  ///     AppButton(label: 'Apply'),
  ///   ],
  /// );
  /// ```
  static Future<void> custom(
    BuildContext context, {
    required String title,
    required Widget content,
    List<Widget>? actions,
    bool dismissible = true,
    double? maxWidth,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: dismissible,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth ?? MediaQuery.of(context).size.width * 0.9,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTypography.titleLarge.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(
                        Icons.close,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                // Content
                content,

                const SizedBox(height: AppSpacing.lg),

                // Actions
                if (actions != null && actions.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      for (int i = 0; i < actions.length; i++) ...[
                        Expanded(
                          child: actions[i],
                        ),
                        if (i < actions.length - 1)
                          const SizedBox(width: AppSpacing.md),
                      ],
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Show bottom sheet dialog
  /// 
  /// Usage:
  /// ```dart
  /// await AppDialogs.bottomSheet(
  ///   context,
  ///   title: 'Sort By',
  ///   content: ListView(children: [...]),
  /// );
  /// ```
  static Future<T?> bottomSheet<T>(
    BuildContext context, {
    required String title,
    required Widget content,
    bool dismissible = true,
  }) async {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: dismissible,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.sm,
            ),
            child: Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Text(
              title,
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // Content
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
              ),
              child: content,
            ),
          ),

          // Bottom padding for safe area
          SizedBox(
            height: MediaQuery.of(context).viewInsets.bottom,
          ),
        ],
      ),
    );
  }

  /// Show loading dialog (non-dismissible by default)
  /// 
  /// Usage:
  /// ```dart
  /// showDialog(
  ///   context: context,
  ///   barrierDismissible: false,
  ///   builder: (context) => AppDialogs.loading(message: 'Loading...'),
  /// );
  /// Navigator.pop(context); // Close when done
  /// ```
  static Widget loading({String message = 'Loading...'}) {
    return AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(width: AppSpacing.lg),
          Text(message),
        ],
      ),
    );
  }
}
