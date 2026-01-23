import '../../domain/entities/book.dart';
import '../../domain/repositories/book_repository.dart';
import '../datasources/books_remote_data_source.dart';

class BookRepositoryImpl implements BookRepository {
  final BooksRemoteDataSource remote;

  BookRepositoryImpl({BooksRemoteDataSource? remote}) : remote = remote ?? BooksRemoteDataSource();

  @override
  Future<List<Book>> getBooks() async {
    final models = await remote.fetchBooks();
    return models.map((m) => Book(id: m.id, title: m.title, author: m.author)).toList();
  }
}
