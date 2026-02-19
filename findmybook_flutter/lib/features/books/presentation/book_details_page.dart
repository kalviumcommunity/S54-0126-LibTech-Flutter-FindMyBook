import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../borrow/presentation/borrow_providers.dart";
import "../../reservations/presentation/reservations_providers.dart";
import "../../../shared/widgets/error_state.dart";
import "../domain/book.dart";

class BookDetailsPage extends ConsumerWidget {
  final Book book;
  const BookDetailsPage({super.key, required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservationState = ref.watch(reservationControllerProvider);
    final borrowState = ref.watch(borrowControllerProvider);
    final countAsync = ref.watch(reservationCountByBookProvider(book.id));
    final hasReservedAsync = ref.watch(hasActiveReservationProvider(book.id));
    final available = (book.availableCopies - book.reservedCopies) > 0;

    ref.listen<AsyncValue<void>>(reservationControllerProvider, (prev, next) {
      if (!next.isLoading && next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error.toString())),
        );
      } else if (!next.isLoading && prev?.isLoading == true && !next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Reservation created.")),
        );
      }
    });
    ref.listen<AsyncValue<void>>(borrowControllerProvider, (prev, next) {
      if (!next.isLoading && next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error.toString())),
        );
      } else if (!next.isLoading && prev?.isLoading == true && !next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Borrowed successfully.")),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Book Details")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.blueGrey.shade50,
            ),
            child: const Icon(Icons.menu_book_rounded, size: 72),
          ),
          const SizedBox(height: 16),
          Text(book.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text("by ${book.author}", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text(book.category)),
              Chip(
                label: Text(available ? "Available" : "Unavailable"),
                backgroundColor: available ? Colors.green.shade50 : Colors.red.shade50,
              ),
              countAsync.when(
                data: (count) => Chip(label: Text("$count active reservations")),
                loading: () => const Chip(label: Text("...")),
                error: (_, stackTrace) =>
                    const Chip(label: Text("Reservations unavailable")),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildActions(
            context: context,
            ref: ref,
            available: available,
            reservationLoading: reservationState.isLoading,
            borrowLoading: borrowState.isLoading,
            hasReservedAsync: hasReservedAsync,
          ),
        ],
      ),
    );
  }

  Widget _buildActions({
    required BuildContext context,
    required WidgetRef ref,
    required bool available,
    required bool reservationLoading,
    required bool borrowLoading,
    required AsyncValue<bool> hasReservedAsync,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        hasReservedAsync.when(
          data: (hasReserved) => ElevatedButton.icon(
            onPressed: reservationLoading || hasReserved || !available
                ? null
                : () => ref.read(reservationControllerProvider.notifier).reserveBook(
                      bookId: book.id,
                      title: book.title,
                      author: book.author,
                    ),
            icon: reservationLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.bookmark_add_outlined),
            label: Text(
              hasReserved ? "Already Reserved" : "Reserve for 7 days",
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ErrorState(message: error.toString()),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: borrowLoading
              ? null
              : () => ref.read(borrowControllerProvider.notifier).borrow(
                    bookId: book.id,
                    title: book.title,
                    author: book.author,
                  ),
          icon: borrowLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.inventory_2_outlined),
          label: const Text("Borrow now"),
        ),
      ],
    );
  }
}
