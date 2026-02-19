enum ReservationStatus { active, cancelled, completed, expired }

class Reservation {
  final String id;
  final String bookId;
  final String userId;
  final String bookTitle;
  final String bookAuthor;
  final DateTime reservedAt;
  final DateTime expiresAt;
  final ReservationStatus status;

  const Reservation({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.bookTitle,
    required this.bookAuthor,
    required this.reservedAt,
    required this.expiresAt,
    required this.status,
  });

  bool get isActive => status == ReservationStatus.active;
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  int get daysRemaining => expiresAt.difference(DateTime.now()).inDays;
}
