import 'package:flutter/material.dart';

import '../models/book.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;

  const BookCard({Key? key, required this.book, this.onTap}) : super(key: key);

  String _titleInitials(String title) {
    final parts = title.split(' ');
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail / avatar
              Container(
                width: 64,
                height: 92,
                decoration: BoxDecoration(
                  color: AppColors.extraLightGrey,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    _titleInitials(book.title),
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      book.author,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Genres and meta
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (book.genres != null && book.genres!.isNotEmpty)
                          for (var i = 0; i < book.genres!.length && i < 3; i++)
                            Chip(
                              label: Text(book.genres![i]),
                              backgroundColor: AppColors.light,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                        if (book.publishedAt != null)
                          Chip(
                            label: Text('${book.publishedAt!.year}'),
                            backgroundColor: AppColors.light,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Availability + chevron
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    label: Text(book.available ? 'Available' : 'Checked out'),
                    backgroundColor: book.available ? AppColors.success : AppColors.errorLight,
                    labelStyle: AppTypography.labelSmall.copyWith(
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Simple shimmer implementation for skeletons
class Shimmer extends StatefulWidget {
  final Widget child;

  const Shimmer({Key? key, required this.child}) : super(key: key);

  @override
  _ShimmerState createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (rect) {
            final gradient = LinearGradient(
              colors: [
                AppColors.extraLightGrey.withOpacity(0.9),
                AppColors.light.withOpacity(0.6),
                AppColors.extraLightGrey.withOpacity(0.9),
              ],
              stops: const [0.1, 0.5, 0.9],
              begin: Alignment(-1 - _controller.value * 2, 0),
              end: Alignment(1 + _controller.value * 2, 0),
            );
            return gradient.createShader(rect);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

class BookCardSkeleton extends StatelessWidget {
  const BookCardSkeleton({Key? key}) : super(key: key);

  Widget _rect({double? width, double? height, BorderRadius? radius}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.extraLightGrey,
        borderRadius: radius ?? BorderRadius.circular(4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            _rect(width: 64, height: 92, radius: BorderRadius.circular(6)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _rect(width: double.infinity, height: 18),
                  const SizedBox(height: 8),
                  _rect(width: 150, height: 14),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _rect(width: 80, height: 28, radius: BorderRadius.circular(16)),
                      const SizedBox(width: 8),
                      _rect(width: 48, height: 28, radius: BorderRadius.circular(16)),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              children: [
                _rect(width: 88, height: 28, radius: BorderRadius.circular(16)),
                const SizedBox(height: 8),
                _rect(width: 24, height: 24, radius: BorderRadius.circular(12)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// Combined skeleton with shimmer
class BookCardSkeletonShimmer extends StatelessWidget {
  const BookCardSkeletonShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: const BookCardSkeleton(),
    );
  }
}
