import 'package:flutter/material.dart';
import '../../domain/entities/book.dart';
import '../../data/repositories/book_repository_impl.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = BookRepositoryImpl();

    return Scaffold(
      appBar: AppBar(title: const Text('Smart Library')),
      body: FutureBuilder<List<Book>>(
        future: repo.getBooks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          }
          final books = snapshot.data ?? [];
          if (books.isEmpty) return const Center(child: Text('No books'));
          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, i) {
              final b = books[i];
              return ListTile(
                title: Text(b.title),
                subtitle: Text(b.author),
                leading: CircleAvatar(child: Text(b.title.isNotEmpty ? b.title[0] : '?')),
              );
            },
          );
        },
      ),
    );
  }
}
