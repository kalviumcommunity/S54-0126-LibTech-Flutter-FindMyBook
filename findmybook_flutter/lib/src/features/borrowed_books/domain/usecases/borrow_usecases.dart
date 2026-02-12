import '../entities/borrow.dart';
import '../repositories/borrow_repository.dart';

/// Use case: Borrow a book (like an Express POST /api/borrows endpoint)
class BorrowBook {
  final BorrowRepository repository;

  BorrowBook(this.repository);

  Future<Borrow> call({
    required String userId,
    required String bookId,
    required String bookTitle,
    required String bookAuthor,
    required int borrowDays,
  }) async {
    // Business logic: Check borrow limit
    final hasReachedLimit = await repository.hasReachedBorrowLimit(userId);
    if (hasReachedLimit) {
      throw Exception('You have reached the maximum borrow limit (5 books)');
    }

    // Call repository to create borrow record in Firestore
    return repository.borrowBook(
      userId: userId,
      bookId: bookId,
      bookTitle: bookTitle,
      bookAuthor: bookAuthor,
      borrowDays: borrowDays,
    );
  }
}

/// Use case: Return a borrowed book
class ReturnBook {
  final BorrowRepository repository;

  ReturnBook(this.repository);

  Future<Borrow> call(String borrowId) async {
    // Verify the borrow exists
    final borrow = await repository.getBorrowById(borrowId);
    if (borrow == null) {
      throw Exception('Borrow record not found');
    }

    if (borrow.returnedAt != null) {
      throw Exception('Book has already been returned');
    }

    // Call repository to update borrow record in Firestore
    return repository.returnBook(borrowId: borrowId);
  }
}

/// Use case: Get active borrows for user
class GetActiveBorrows {
  final BorrowRepository repository;

  GetActiveBorrows(this.repository);

  Future<List<Borrow>> call(String userId) {
    return repository.getActiveBorrowsForUser(userId);
  }
}

/// Use case: Get borrow history for user
class GetBorrowHistory {
  final BorrowRepository repository;

  GetBorrowHistory(this.repository);

  Future<List<Borrow>> call(String userId) {
    return repository.getBorrowHistoryForUser(userId);
  }
}

/// Use case: Renew a borrowed book
class RenewBorrow {
  final BorrowRepository repository;

  RenewBorrow(this.repository);

  Future<Borrow> call({
    required String borrowId,
    required int additionalDays,
  }) async {
    final borrow = await repository.getBorrowById(borrowId);
    if (borrow == null) {
      throw Exception('Borrow record not found');
    }

    if (borrow.returnedAt != null) {
      throw Exception('Cannot renew a returned book');
    }

    return repository.renewBorrow(
      borrowId: borrowId,
      additionalDays: additionalDays,
    );
  }
}
