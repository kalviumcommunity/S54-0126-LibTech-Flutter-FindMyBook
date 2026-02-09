import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/book.dart';
import 'presentation/book_card.dart';
import 'presentation/book_detail_page.dart';

class BookListPage extends StatelessWidget {
  const BookListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final booksQuery = FirebaseFirestore.instance
        .collection('books')
        .orderBy('title');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: booksQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // While waiting for data, show a list of skeleton cards
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              itemCount: 6,
              itemBuilder: (context, index) => const BookCardSkeletonShimmer(),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No books found'));
          }

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final book = Book.fromSnapshot(doc);

              return BookCard(
                book: book,
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => BookDetailPage(book: book),
                  ));
                },
              );
            },
          );
        },
      ),
    );
  }
}
