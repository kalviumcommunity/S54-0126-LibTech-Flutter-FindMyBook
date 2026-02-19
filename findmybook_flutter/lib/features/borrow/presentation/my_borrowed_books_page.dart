import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../shared/widgets/empty_state.dart";
import "../../../shared/widgets/error_state.dart";
import "../../../shared/widgets/loading_skeleton.dart";
import "../domain/borrow_record.dart";
import "borrow_providers.dart";

class MyBorrowedBooksPage extends ConsumerWidget {
  const MyBorrowedBooksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(userBorrowRecordsProvider);
    final actionState = ref.watch(borrowControllerProvider);

    ref.listen<AsyncValue<void>>(borrowControllerProvider, (previous, next) {
      if (!next.isLoading && next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error.toString())),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Borrowed Books")),
      body: recordsAsync.when(
        loading: () => const LoadingSkeleton(itemCount: 4),
        error: (error, _) => ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(userBorrowRecordsProvider),
        ),
        data: (records) {
          if (records.isEmpty) {
            return const EmptyState(
              icon: Icons.library_books_outlined,
              title: "No active borrows",
              subtitle: "Borrowed books and due dates appear here.",
            );
          }

          return ListView.builder(
            itemCount: records.length,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemBuilder: (context, index) {
              final record = records[index];
              return Card(
                child: ListTile(
                  title: Text(record.title),
                  subtitle: Text(
                    "${record.author}\nDue: ${record.dueAt.toLocal().toString().split(" ").first}",
                  ),
                  isThreeLine: true,
                  trailing: record.isActive
                      ? FilledButton.tonal(
                          onPressed: actionState.isLoading
                              ? null
                              : () => ref
                                  .read(borrowControllerProvider.notifier)
                                  .returnBook(record.id),
                          child: const Text("Return"),
                        )
                      : _status(record),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: actionState.isLoading
          ? const Padding(
              padding: EdgeInsets.all(10),
              child: LinearProgressIndicator(),
            )
          : null,
    );
  }

  Widget _status(BorrowRecord record) {
    switch (record.status) {
      case BorrowStatus.returned:
        return const Chip(label: Text("Returned"));
      case BorrowStatus.overdue:
        return const Chip(label: Text("Overdue"));
      case BorrowStatus.active:
        return const Chip(label: Text("Active"));
    }
  }
}
