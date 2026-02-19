import "package:flutter/material.dart";

import "../../domain/book.dart";

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final available = book.isAvailable;
    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: CircleAvatar(
          child: Text(
            book.title.isNotEmpty ? book.title[0].toUpperCase() : "B",
          ),
        ),
        title: Text(
          book.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          "${book.author} • ${book.category}",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              available ? "Available" : "Unavailable",
              style: TextStyle(
                color: available ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              "${book.availableCopies - book.reservedCopies} left",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
