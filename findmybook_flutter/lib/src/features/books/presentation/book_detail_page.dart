import 'package:flutter/material.dart';

import '../models/book.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class BookDetailPage extends StatelessWidget {
  final Book book;
  const BookDetailPage({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover / placeholder
            Center(
              child: Container(
                width: 160,
                height: 220,
                decoration: BoxDecoration(
                  color: AppColors.extraLightGrey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    book.title.isNotEmpty ? book.title[0].toUpperCase() : '?',
                    style: AppTypography.displaySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            Text(book.title, style: AppTypography.headlineMedium.copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: AppSpacing.sm),
            Text('by ${book.author}', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),

            const SizedBox(height: AppSpacing.md),

            Row(
              children: [
                Chip(
                  label: Text(book.available ? 'Available' : 'Checked out'),
                  backgroundColor: book.available ? AppColors.success : AppColors.errorLight,
                ),
                const SizedBox(width: AppSpacing.md),
                if (book.publishedAt != null)
                  Text('${book.publishedAt!.year}', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            if (book.genres != null && book.genres!.isNotEmpty) ...[
              Text('Genres', style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: AppSpacing.sm),
              Wrap(spacing: 8, children: book.genres!.map((g) => Chip(label: Text(g))).toList()),
              const SizedBox(height: AppSpacing.lg),
            ],

            Text('Details', style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: AppSpacing.sm),
            Text('ISBN: ${book.isbn}', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.sm),
            if (book.publishedAt != null)
              Text('Published: ${book.publishedAt!.toLocal().toIso8601String().split('T').first}', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),

            const SizedBox(height: AppSpacing.lg),

            ElevatedButton(
              onPressed: () {
                // TODO: implement checkout/reserve flow
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Action not implemented')));
              },
              child: const Text('Reserve / Checkout'),
            ),
          ],
        ),
      ),
    );
  }
}
