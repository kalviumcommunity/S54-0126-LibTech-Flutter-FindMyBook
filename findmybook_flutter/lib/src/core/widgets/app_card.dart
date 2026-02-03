/// App Card Components - Equivalent to: React Card component from UI libraries
/// 
/// MERN Comparison:
/// React: <Card elevation={2}><CardContent>{children}</CardContent></Card>
/// Flutter: AppCard(child: Text('Content'))
///
/// Cards are fundamental building blocks for displaying grouped content.
/// This includes standard cards and specialized book cards.

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Standard app card with consistent styling
/// 
/// Usage:
/// ```dart
/// AppCard(
///   child: Column(
///     children: [
///       Text('Book Title'),
///       Text('Author Name'),
///     ],
///   ),
/// )
/// ```
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double elevation;
  final List<BoxShadow>? customShadow;
  final double? width;
  final double? height;
  final GestureTapCallback? onTap;
  final bool showBorder;
  final double borderWidth;

  const AppCard({
    Key? key,
    required this.child,
    this.padding,
    this.borderRadius = AppSpacing.cardBorderRadius,
    this.backgroundColor,
    this.borderColor,
    this.elevation = 1,
    this.customShadow,
    this.width,
    this.height,
    this.onTap,
    this.showBorder = true,
    this.borderWidth = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder
            ? Border.all(
                color: borderColor ?? AppColors.border,
                width: borderWidth,
              )
            : null,
        boxShadow: customShadow ??
            [
              BoxShadow(
                color: AppColors.dark.withOpacity(0.05 * elevation),
                blurRadius: 4 * elevation,
                offset: Offset(0, 2 * elevation),
              ),
            ],
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}

/// Book card for library display
/// Shows book cover, title, author, and rating
/// 
/// Usage:
/// ```dart
/// BookCard(
///   title: 'The Great Gatsby',
///   author: 'F. Scott Fitzgerald',
///   imageUrl: 'https://...',
///   rating: 4.5,
///   onTap: () => navigateToDetails(),
/// )
/// ```
class BookCard extends StatelessWidget {
  final String title;
  final String author;
  final String? imageUrl;
  final double? rating;
  final int? reviewCount;
  final VoidCallback? onTap;
  final bool isAvailable;
  final String? status;
  final Color? categoryColor;

  const BookCard({
    Key? key,
    required this.title,
    required this.author,
    this.imageUrl,
    this.rating,
    this.reviewCount,
    this.onTap,
    this.isAvailable = true,
    this.status,
    this.categoryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Book Cover Image
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: categoryColor ?? AppColors.bookBluish,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.book,
                                color: AppColors.light,
                                size: 40,
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.book,
                          color: AppColors.light,
                          size: 40,
                        ),
                      ),
              ),
              // Availability badge
              if (!isAvailable)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Unavailable',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Book Title
          Text(
            title,
            style: AppTypography.bookTitle.copyWith(
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: AppSpacing.xs),

          // Author
          Text(
            author,
            style: AppTypography.bookAuthor.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: AppSpacing.sm),

          // Rating & Status Row
          if (rating != null || status != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (rating != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        size: 14,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rating!.toStringAsFixed(1),
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                if (status != null)
                  Text(
                    status!,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

/// User profile card
/// Shows user avatar, name, and role
/// 
/// Usage:
/// ```dart
/// UserCard(
///   name: 'John Doe',
///   role: 'Student',
///   avatarUrl: 'https://...',
/// )
/// ```
class UserCard extends StatelessWidget {
  final String name;
  final String role;
  final String? avatarUrl;
  final VoidCallback? onTap;

  const UserCard({
    Key? key,
    required this.name,
    required this.role,
    this.avatarUrl,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: avatarUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.network(
                      avatarUrl!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: AppTypography.titleLarge.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
          ),

          const SizedBox(width: AppSpacing.lg),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  role,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Stat card - Displays a key metric
/// Useful for dashboard summaries
/// 
/// Usage:
/// ```dart
/// StatCard(
///   label: 'Books Borrowed',
///   value: '24',
///   icon: Icons.library_books,
/// )
/// ```
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  const StatCard({
    Key? key,
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      backgroundColor: AppColors.surfaceVariant,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null)
            Icon(
              icon,
              size: 32,
              color: iconColor ?? AppColors.primary,
            ),
          if (icon != null) const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: AppTypography.displaySmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Action card - Card with action button
/// Useful for feature cards with CTA
/// 
/// Usage:
/// ```dart
/// ActionCard(
///   title: 'New Feature',
///   description: 'Discover recommendations',
///   buttonLabel: 'Learn More',
///   onButtonTap: () => {},
/// )
/// ```
class ActionCard extends StatelessWidget {
  final String title;
  final String? description;
  final String? buttonLabel;
  final VoidCallback? onButtonTap;
  final Color? backgroundColor;
  final IconData? icon;

  const ActionCard({
    Key? key,
    required this.title,
    this.description,
    this.buttonLabel,
    this.onButtonTap,
    this.backgroundColor,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: backgroundColor ?? AppColors.primary.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: AppColors.primary, size: 28),
                const SizedBox(width: AppSpacing.lg),
              ],
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          if (description != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              description!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (buttonLabel != null) ...[
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onButtonTap,
                child: Text(buttonLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
