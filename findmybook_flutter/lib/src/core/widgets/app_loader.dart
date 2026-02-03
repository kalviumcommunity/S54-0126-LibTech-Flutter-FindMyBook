/// App Loaders & Loading States - Equivalent to: React loading spinners + skeletons
/// 
/// MERN Comparison:
/// React: {isLoading ? <Skeleton /> : <Content />}
/// Flutter: isLoading ? AppShimmer() : Content()
///
/// In MERN: Usually use libraries like react-loading-skeleton
/// In Flutter: Use shimmer package for skeleton loading effects
///
/// These components provide consistent loading experiences

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Circular loading indicator with custom color
/// 
/// Usage:
/// ```dart
/// AppLoader()
/// // or
/// AppLoader(color: Colors.green, size: 50)
/// ```
class AppLoader extends StatelessWidget {
  final Color? color;
  final double size;
  final double strokeWidth;

  const AppLoader({
    Key? key,
    this.color,
    this.size = 48,
    this.strokeWidth = 4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.primary,
        ),
      ),
    );
  }
}

/// Skeleton loader for text lines
/// Creates a shimmering effect while loading content
/// 
/// Usage:
/// ```dart
/// AppShimmer(
///   width: double.infinity,
///   height: 16,
/// )
/// ```
class AppShimmer extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final double? margin;

  const AppShimmer({
    Key? key,
    this.width,
    this.height = 16,
    this.borderRadius,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.extraLightGrey,
      highlightColor: AppColors.light,
      child: Container(
        width: width,
        height: height,
        margin: margin != null ? EdgeInsets.all(margin!) : null,
        decoration: BoxDecoration(
          color: AppColors.light,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// Skeleton loader for circular avatars
/// 
/// Usage:
/// ```dart
/// AppShimmerCircle(radius: 24)
/// ```
class AppShimmerCircle extends StatelessWidget {
  final double radius;

  const AppShimmerCircle({
    Key? key,
    this.radius = 24,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.extraLightGrey,
      highlightColor: AppColors.light,
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          color: AppColors.light,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Full card skeleton loader
/// Useful for loading book cards, user cards, etc.
/// 
/// Usage:
/// ```dart
/// AppShimmerCard()
/// ```
class AppShimmerCard extends StatelessWidget {
  final double? width;
  final double? height;

  const AppShimmerCard({
    Key? key,
    this.width,
    this.height = 200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.extraLightGrey,
      highlightColor: AppColors.light,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.light,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              width: width,
              height: height! * 0.5,
              decoration: BoxDecoration(
                color: AppColors.extraLightGrey,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title placeholder
                  Container(
                    width: double.infinity,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.extraLightGrey,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Subtitle placeholder
                  Container(
                    width: width! * 0.6,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.extraLightGrey,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// List skeleton loader
/// Simulates a list of items loading
/// 
/// Usage:
/// ```dart
/// AppShimmerList(itemCount: 5)
/// ```
class AppShimmerList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const AppShimmerList({
    Key? key,
    this.itemCount = 5,
    this.itemHeight = 80,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.lg),
      itemBuilder: (context, index) {
        return AppShimmerCard(height: itemHeight);
      },
    );
  }
}

/// Progress indicator with text
/// Shows loading progress with a message
/// 
/// Usage:
/// ```dart
/// AppProgressIndicator(
///   progress: 0.65,
///   label: 'Loading books...',
/// )
/// ```
class AppProgressIndicator extends StatelessWidget {
  final double progress;
  final String? label;
  final Color? color;

  const AppProgressIndicator({
    Key? key,
    required this.progress,
    this.label,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Text(
              label!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: AppColors.extraLightGrey,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? AppColors.primary,
            ),
          ),
        ),
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
      ],
    );
  }
}

/// Full screen loader overlay
/// Shows centered loader on top of content
/// 
/// Usage:
/// ```dart
/// Stack(
///   children: [
///     YourContent(),
///     if (isLoading) AppFullScreenLoader(),
///   ],
/// )
/// ```
class AppFullScreenLoader extends StatelessWidget {
  final String? message;
  final Color? backgroundColor;

  const AppFullScreenLoader({
    Key? key,
    this.message,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? AppColors.overlay,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLoader(size: 56),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.white,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
