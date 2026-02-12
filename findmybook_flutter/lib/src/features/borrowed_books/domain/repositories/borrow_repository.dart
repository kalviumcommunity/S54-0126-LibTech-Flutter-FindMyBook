import '../entities/borrow.dart';

/// Repository interface for borrow operations (like Express service interface)
/// This abstracts Firestore operations behind a contract
abstract class BorrowRepository {
  /// Borrow a book by creating a borrow record
  /// Returns the created borrow record
  Future<Borrow> borrowBook({
    required String userId,
    required String bookId,
    required String bookTitle,
    required String bookAuthor,
    required int borrowDays,
  });

  /// Return a borrowed book
  /// Updates the borrow record with return date and status
  Future<Borrow> returnBook({
    required String borrowId,
  });

  /// Get all borrowed books for a user (active borrows only)
  Future<List<Borrow>> getActiveBorrowsForUser(String userId);

  /// Get all borrow history for a user (including returned)
  Future<List<Borrow>> getBorrowHistoryForUser(String userId);

  /// Get a specific borrow by ID
  Future<Borrow?> getBorrowById(String borrowId);

  /// Stream of active borrows for a user (real-time updates)
  Stream<List<Borrow>> watchActiveBorrowsForUser(String userId);

  /// Stream of borrow history for a user (real-time updates)
  Stream<List<Borrow>> watchBorrowHistoryForUser(String userId);

  /// Check if user has reached borrow limit
  Future<bool> hasReachedBorrowLimit(String userId, {int maxBorrows = 5});

  /// Get total borrow count for a user
  Future<int> getTotalBorrowCount(String userId);

  /// Renew a borrowed book (extend due date)
  Future<Borrow> renewBorrow({
    required String borrowId,
    required int additionalDays,
  });
}
