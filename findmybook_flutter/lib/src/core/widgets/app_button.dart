/// App Button Component - Equivalent to: Shadcn/ui Button in React
/// 
/// MERN Comparison:
/// React: <Button variant="filled" size="md" loading={isLoading}>Click me</Button>
/// Flutter: AppButton(onPressed: () {}, label: 'Click me', isLoading: isLoading)
///
/// This component is the foundation for all CTAs in the app.
/// It handles:
/// - Loading states (shows spinner, disables button)
/// - Consistency across the app (colors, sizes, fonts)
/// - Accessibility (proper semantics, disabled states)

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Filled button with shadow - Primary action button
/// 
/// Usage:
/// ```dart
/// AppButton(
///   onPressed: () => handleSubmit(),
///   label: 'Save Book',
///   isLoading: isSubmitting,
/// )
/// ```
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? textColor;
  final bool fullWidth;
  final double borderRadius;
  final IconData? icon;
  final MainAxisAlignment? mainAxisAlignment;

  const AppButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = AppSpacing.buttonHeight,
    this.backgroundColor,
    this.textColor,
    this.fullWidth = false,
    this.borderRadius = AppSpacing.cardBorderRadius,
    this.icon,
    this.mainAxisAlignment = MainAxisAlignment.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    return SizedBox(
      width: fullWidth ? double.infinity : width,
      height: height,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled
              ? AppColors.disabled
              : (backgroundColor ?? AppColors.primary),
          foregroundColor: isDisabled
              ? AppColors.disabledText
              : (textColor ?? AppColors.white),
          elevation: isDisabled ? 0 : 2,
          disabledElevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              )
            : Row(
                mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      style: AppTypography.labelLarge.copyWith(
                        color: isDisabled
                            ? AppColors.disabledText
                            : (textColor ?? AppColors.white),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Outlined button - Secondary action button
/// 
/// Usage:
/// ```dart
/// AppOutlinedButton(
///   onPressed: () => handleCancel(),
///   label: 'Cancel',
/// )
/// ```
class AppOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double height;
  final Color? borderColor;
  final Color? textColor;
  final bool fullWidth;
  final double borderRadius;
  final IconData? icon;
  final MainAxisAlignment? mainAxisAlignment;
  final double borderWidth;

  const AppOutlinedButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = AppSpacing.buttonHeight,
    this.borderColor,
    this.textColor,
    this.fullWidth = false,
    this.borderRadius = AppSpacing.cardBorderRadius,
    this.icon,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.borderWidth = 1.5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    return SizedBox(
      width: fullWidth ? double.infinity : width,
      height: height,
      child: OutlinedButton(
        onPressed: isDisabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: isDisabled
              ? AppColors.disabledText
              : (textColor ?? AppColors.primary),
          side: BorderSide(
            color: isDisabled
                ? AppColors.disabled
                : (borderColor ?? AppColors.primary),
            width: borderWidth,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: EdgeInsets.zero,
          disabledMouseCursor: MouseCursor.defer,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : Row(
                mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      style: AppTypography.labelLarge.copyWith(
                        color: isDisabled
                            ? AppColors.disabledText
                            : (textColor ?? AppColors.primary),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Text button - Tertiary/minimal action button
/// 
/// Usage:
/// ```dart
/// AppTextButton(
///   onPressed: () => handleForget(),
///   label: 'Forgot password?',
/// )
/// ```
class AppTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? textColor;
  final double fontSize;
  final FontWeight fontWeight;
  final IconData? icon;
  final bool underline;

  const AppTextButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.textColor,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w500,
    this.icon,
    this.underline = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textColor ?? AppColors.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: textColor ?? AppColors.primary,
              decoration: underline ? TextDecoration.underline : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small icon button - For compact icon-only buttons
/// 
/// Usage:
/// ```dart
/// AppIconButton(
///   icon: Icons.search,
///   onPressed: () => showSearch(),
/// )
/// ```
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? iconColor;
  final Color? backgroundColor;
  final double size;
  final double iconSize;
  final String? tooltip;

  const AppIconButton({
    Key? key,
    required this.icon,
    this.onPressed,
    this.iconColor,
    this.backgroundColor,
    this.size = 48,
    this.iconSize = 24,
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: backgroundColor ?? Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(size / 2),
          child: Tooltip(
            message: tooltip ?? '',
            showDuration: const Duration(seconds: 2),
            child: Center(
              child: Icon(
                icon,
                size: iconSize,
                color: iconColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
