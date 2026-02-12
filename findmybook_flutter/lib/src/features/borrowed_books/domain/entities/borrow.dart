/// Borrow Entity - Core business logic (like MongoDB schema structure)
/// Represents the borrowing relationship between a user and a book
class Borrow {
  final String id;
  final String userId;
  final String bookId;
  final String bookTitle;
  final String bookAuthor;
  final DateTime borrowedAt;
  final DateTime dueDate;
  final DateTime? returnedAt;
  final BorrowStatus status;

  const Borrow({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.bookTitle,
    required this.bookAuthor,
    required this.borrowedAt,
    required this.dueDate,
    this.returnedAt,
    required this.status,
  });

  /// Check if this borrow is currently active (not returned yet)
  bool get isActive => returnedAt == null && status == BorrowStatus.active;

  /// Check if this book is overdue
  bool get isOverdue => 
      returnedAt == null && 
      DateTime.now().isAfter(dueDate) && 
      status == BorrowStatus.active;

  /// Days remaining until due date (negative if overdue)
  int get daysRemaining => dueDate.difference(DateTime.now()).inDays;

  /// Copy with method for immutability
  Borrow copyWith({
    String? id,
    String? userId,
    String? bookId,
    String? bookTitle,
    String? bookAuthor,
    DateTime? borrowedAt,
    DateTime? dueDate,
    DateTime? returnedAt,
    BorrowStatus? status,
  }) {
    return Borrow(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bookId: bookId ?? this.bookId,
      bookTitle: bookTitle ?? this.bookTitle,
      bookAuthor: bookAuthor ?? this.bookAuthor,
      borrowedAt: borrowedAt ?? this.borrowedAt,
      dueDate: dueDate ?? this.dueDate,
      returnedAt: returnedAt ?? this.returnedAt,
      status: status ?? this.status,
    );
  }

  @override
  String toString() =>
      'Borrow(id: $id, bookTitle: $bookTitle, status: $status, isOverdue: $isOverdue)';
}

/// Enum for borrow status (like status field in MongoDB documents)
enum BorrowStatus {
  active,     // Currently borrowed
  returned,   // Successfully returned
  overdue,    // Not returned by due date
}

extension BorrowStatusX on BorrowStatus {
  String get displayName {
    switch (this) {
      case BorrowStatus.active:
        return 'Active';
      case BorrowStatus.returned:
        return 'Returned';
      case BorrowStatus.overdue:
        return 'Overdue';
    }
  }

  String get stringValue => toString().split('.').last;
}
