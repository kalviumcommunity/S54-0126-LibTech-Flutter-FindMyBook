import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/borrow.dart';
import '../providers/borrow_providers.dart';
import '../widgets/borrow_card.dart';
import '../widgets/empty_borrow_state.dart';

/// My Borrowed Books screen
/// Shows currently borrowed books with return information
class MyBorrowedBooksPage extends ConsumerWidget {
  final String userId;

  const MyBorrowedBooksPage({
    required this.userId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the real-time stream of active borrows
    final borrowsAsync = ref.watch(activeborrowsStreamProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Borrowed Books'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Invalidate to refresh
              ref.refresh(activeborrowsStreamProvider(userId));
            },
          ),
        ],
      ),
      body: borrowsAsync.when(
        // Loading state (like React's loading skeleton)
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),

        // Error state (like React error boundary)
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading borrowed books',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.refresh(activeborrowsStreamProvider(userId));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),

        // Success state - display borrowed books
        data: (borrows) {
          if (borrows.isEmpty) {
            return EmptyBorrowState(
              onBrowseBooks: () {
                Navigator.of(context).pushNamed('/home');
              },
            );
          }

          // Sort by due date - overdue first, then by closest due date
          final sortedBorrows = _sortBorrows(borrows);

          return RefreshIndicator(
            onRefresh: () async {
              // Invalidate to refresh
              ref.refresh(activeborrowsStreamProvider(userId));
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              itemCount: sortedBorrows.length,
              itemBuilder: (context, index) {
                final borrow = sortedBorrows[index];
                return BorrowCard(
                  borrow: borrow,
                  userId: userId,
                  onReturn: () => _handleReturn(context, ref, borrow),
                  onRenew: () => _handleRenew(context, ref, borrow),
                );
              },
            ),
          );
        },
      ),
    );
  }

  /// Sort borrows: overdue first, then by closest due date
  List<Borrow> _sortBorrows(List<Borrow> borrows) {
    final result = [...borrows];
    result.sort((a, b) {
      // Sort overdue first
      if (a.isOverdue && !b.isOverdue) return -1;
      if (!a.isOverdue && b.isOverdue) return 1;

      // Then by due date (closest first)
      return a.dueDate.compareTo(b.dueDate);
    });
    return result;
  }

  /// Handle return book action
  Future<void> _handleReturn(
    BuildContext context,
    WidgetRef ref,
    Borrow borrow,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Return Book'),
        content: Text(
          'Are you sure you want to return "${borrow.bookTitle}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Return'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Call the return book action provider
      await ref.read(returnBookActionProvider(borrow.id).future);

      // Invalidate to refresh
      ref.refresh(activeborrowsStreamProvider(userId));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully returned "${borrow.bookTitle}"'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Handle renew book action
  Future<void> _handleRenew(
    BuildContext context,
    WidgetRef ref,
    Borrow borrow,
  ) async {
    final additionalDays = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Renew Book'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Renew "${borrow.bookTitle}" for how many days?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            const Text('Default: 14 days'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 14),
            child: const Text('Renew for 14 days'),
          ),
        ],
      ),
    );

    if (additionalDays == null) return;

    try {
      await ref.read(
        renewBorrowActionProvider((borrow.id, additionalDays)).future,
      );

      // Invalidate to refresh
      ref.refresh(activeborrowsStreamProvider(userId));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully renewed "${borrow.bookTitle}" for $additionalDays days',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
