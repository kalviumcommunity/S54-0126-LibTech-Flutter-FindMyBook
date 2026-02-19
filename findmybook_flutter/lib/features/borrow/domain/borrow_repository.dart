import "borrow_record.dart";

abstract class BorrowRepository {
  Stream<List<BorrowRecord>> watchUserBorrows(String userId);
  Future<void> borrowBook({
    required String userId,
    required String bookId,
    required String title,
    required String author,
  });
  Future<void> returnBook({
    required String borrowId,
    required String userId,
  });
}
