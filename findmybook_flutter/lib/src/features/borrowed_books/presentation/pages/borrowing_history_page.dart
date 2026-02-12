import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/borrow.dart';
import '../providers/borrow_providers.dart';
import '../widgets/borrow_timeline_item.dart';

/// Borrowing History screen with timeline-style UI
/// Shows all past and present borrows in chronological order
class BorrowingHistoryPage extends ConsumerWidget {
  final String userId;

  const BorrowingHistoryPage({
    required this.userId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the stream of borrow history
    final historyAsync = ref.watch(borrowHistoryStreamProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Borrowing History'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: historyAsync.when(
        // Loading state
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),

        // Error state
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading history',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.refresh(borrowHistoryStreamProvider(userId));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),

        // Success state - display timeline
        data: (history) {
          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No borrowing history yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(borrowHistoryStreamProvider(userId));
            },
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        // Group borrows by year for header
                        final borrow = history[index];
                        final isFirstItem = index == 0;
                        final isNewYear = isFirstItem ||
                            history[index - 1].borrowedAt.year !=
                                borrow.borrowedAt.year;

                        return Column(
                          children: [
                            // Year header
                            if (isNewYear)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 16,
                                  bottom: 8,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    borrow.borrowedAt.year.toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              ),

                            // Timeline item
                            BorrowTimelineItem(
                              borrow: borrow,
                              isFirst: isFirstItem,
                              isLast: index == history.length - 1,
                            ),
                          ],
                        );
                      },
                      childCount: history.length,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Show info dialog
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Timeline'),
        content: const Text(
          'This shows your complete borrowing history including:\n\n'
          '• Currently borrowed books\n'
          '• Returned books\n'
          '• Overdue books\n\n'
          'Use this to track your reading activity and library usage.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
