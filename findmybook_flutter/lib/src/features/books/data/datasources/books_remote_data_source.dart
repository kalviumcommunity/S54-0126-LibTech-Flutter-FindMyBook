import '../models/book_model.dart';

/// Placeholder remote data source. Replace with Firestore implementation later.
class BooksRemoteDataSource {
  Future<List<BookModel>> fetchBooks() async {
    // Simulated network / Firestore call
    await Future.delayed(const Duration(milliseconds: 250));
    return const [
      BookModel(id: '1', title: 'Clean Architecture', author: 'Robert C. Martin'),
      BookModel(id: '2', title: 'Flutter in Action', author: 'Eric Windmill'),
      BookModel(id: '3', title: 'Design Patterns', author: 'Gamma et al.'),
    ];
  }
}
