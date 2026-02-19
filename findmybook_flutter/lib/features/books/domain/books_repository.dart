import "book.dart";

abstract class BooksRepository {
  Stream<List<Book>> watchBooks();
  Future<Book?> getBookById(String id);
}
