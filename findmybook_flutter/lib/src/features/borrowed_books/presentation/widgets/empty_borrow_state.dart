import 'package:flutter/material.dart';

/// Empty state widget - displayed when no borrowed books
class EmptyBorrowState extends StatelessWidget {
  final VoidCallback onBrowseBooks;

  const EmptyBorrowState({
    required this.onBrowseBooks,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty state icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.library_books,
                size: 50,
                color: Colors.blue.shade600,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'No Books Borrowed',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              'Start exploring our library and borrow books to see them here.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Browse books button
            ElevatedButton.icon(
              onPressed: onBrowseBooks,
              icon: const Icon(Icons.explore),
              label: const Text('Browse Books'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
