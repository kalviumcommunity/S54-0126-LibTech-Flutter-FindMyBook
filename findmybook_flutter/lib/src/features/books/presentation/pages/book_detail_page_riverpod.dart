import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/book_detail_controller.dart';
import '../book_status_badge.dart';
import '../../models/book.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_colors.dart';

class BookDetailPageRiverpod extends ConsumerWidget {
  final String bookId;
  const BookDetailPageRiverpod({Key? key, required this.bookId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncBook = ref.watch(bookStreamProvider(bookId));

    return Scaffold(
      appBar: AppBar(title: const Text('Book')),
      body: asyncBook.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (Book book) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(
                child: Container(
                  width: 160,
                  height: 220,
                  decoration: BoxDecoration(
                    color: AppColors.extraLightGrey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(book.title.isNotEmpty ? book.title[0].toUpperCase() : '?', style: AppTypography.displaySmall.copyWith(color: AppColors.textSecondary)),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(book.title, style: AppTypography.headlineMedium.copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: AppSpacing.sm),
              Text('by ${book.author}', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.md),
              Row(children: [BookStatusBadge(available: book.available), const SizedBox(width: AppSpacing.md), if (book.publishedAt != null) Text('${book.publishedAt!.year}', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary))]),
              const SizedBox(height: AppSpacing.lg),
              Text('Details', style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: AppSpacing.sm),
              Text('ISBN: ${book.isbn}', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: () async {
                  final actions = ref.read(bookActionsProvider);
                  try {
                    if (book.available) {
                      // NOTE: use authenticated user id in production
                      await actions.checkout(book.id, 'demo-user');
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Checked out')));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Book not available')));
                    }
                  } catch (err) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $err')));
                  }
                },
                child: Text(book.available ? 'Checkout' : 'Request'),
              ),
            ]),
          );
        },
      ),
    );
  }
}
