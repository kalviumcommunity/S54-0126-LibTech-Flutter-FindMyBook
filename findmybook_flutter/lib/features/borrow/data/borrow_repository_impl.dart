import "../domain/borrow_record.dart";
import "../domain/borrow_repository.dart";
import "borrow_service.dart";

class BorrowRepositoryImpl implements BorrowRepository {
  final BorrowService _service;
  BorrowRepositoryImpl(this._service);

  @override
  Stream<List<BorrowRecord>> watchUserBorrows(String userId) {
    return _service.watchUserBorrows(userId);
  }

  @override
  Future<void> borrowBook({
    required String userId,
    required String bookId,
    required String title,
    required String author,
  }) {
    return _service.borrowBook(
      userId: userId,
      bookId: bookId,
      title: title,
      author: author,
    );
  }

  @override
  Future<void> returnBook({
    required String borrowId,
    required String userId,
  }) {
    return _service.returnBook(
      borrowId: borrowId,
      userId: userId,
    );
  }
}
