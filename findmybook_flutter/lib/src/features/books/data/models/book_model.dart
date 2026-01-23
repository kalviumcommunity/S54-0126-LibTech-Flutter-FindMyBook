import '../../domain/entities/book.dart';

class BookModel extends Book {
  // Use super-parameters to satisfy the `use_super_parameters` lint.
  const BookModel({required super.id, required super.title, required super.author});

  factory BookModel.fromMap(Map<String, dynamic> map) {
    return BookModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      author: map['author'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {'id': id, 'title': title, 'author': author};
}
