import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String isbn;
  final bool available;
  final DateTime? publishedAt;
  final List<String>? genres;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.available,
    this.publishedAt,
    this.genres,
  });

  factory Book.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>? ?? {};
    return Book(
      id: snap.id,
      title: data['title'] as String? ?? 'Untitled',
      author: data['author'] as String? ?? 'Unknown',
      isbn: data['isbn'] as String? ?? '',
      available: data['available'] as bool? ?? true,
      publishedAt: (data['publishedAt'] is Timestamp)
          ? (data['publishedAt'] as Timestamp).toDate()
          : (data['publishedAt'] is String)
              ? DateTime.tryParse(data['publishedAt'] as String)
              : null,
      genres: (data['genres'] as List<dynamic>?)?.cast<String>(),
    );
  }
}
