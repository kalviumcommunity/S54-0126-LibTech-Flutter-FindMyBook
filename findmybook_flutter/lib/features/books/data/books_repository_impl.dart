import "../domain/book.dart";
import "../domain/books_repository.dart";
import "books_service.dart";

class BooksRepositoryImpl implements BooksRepository {
  final BooksService _service;
  BooksRepositoryImpl(this._service);

  @override
  Stream<List<Book>> watchBooks() => _service.watchBooks();

  @override
  Future<Book?> getBookById(String id) => _service.getBookById(id);
}
