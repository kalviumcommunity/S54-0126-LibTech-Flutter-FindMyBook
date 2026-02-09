import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/book.dart';

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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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

              return ListTile(
                leading: const Icon(Icons.book_outlined),
                title: Text(book.title),
                subtitle: Text(book.author),
                trailing: Chip(
                  label: Text(book.available ? 'Available' : 'Checked out'),
                  backgroundColor:
                      book.available ? Colors.green[100] : Colors.red[100],
                ),
                onTap: () {
                  // Hook for navigation to detail page
                },
              );
            },
          );
        },
      ),
    );
  }
}
