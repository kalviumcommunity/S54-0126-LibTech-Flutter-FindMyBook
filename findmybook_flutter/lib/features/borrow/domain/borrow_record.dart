enum BorrowStatus { active, returned, overdue }

class BorrowRecord {
  final String id;
  final String bookId;
  final String userId;
  final String title;
  final String author;
  final DateTime borrowedAt;
  final DateTime dueAt;
  final DateTime? returnedAt;
  final BorrowStatus status;

  const BorrowRecord({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.title,
    required this.author,
    required this.borrowedAt,
    required this.dueAt,
    required this.status,
    this.returnedAt,
  });

  bool get isActive => status == BorrowStatus.active;
  bool get isLate => isActive && DateTime.now().isAfter(dueAt);
}
