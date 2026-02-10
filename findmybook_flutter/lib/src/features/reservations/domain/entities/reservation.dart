/// Reservation entity representing a user's book reservation
class Reservation {
  final String id;
  final String bookId;
  final String userId;
  final String bookTitle;
  final String bookAuthor;
  final DateTime reservedAt;
  final DateTime? expiresAt; // Reservation expires after 7 days
  final ReservationStatus status;

  const Reservation({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.bookTitle,
    required this.bookAuthor,
    required this.reservedAt,
    this.expiresAt,
    this.status = ReservationStatus.active,
  });

  /// Check if reservation is still valid
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  /// Days remaining until expiration
  int? get daysRemaining {
    if (expiresAt == null || isExpired) return null;
    return expiresAt!.difference(DateTime.now()).inDays;
  }

  /// User-friendly status text
  String get statusText {
    switch (status) {
      case ReservationStatus.active:
        return 'Reserved';
      case ReservationStatus.ready:
        return 'Ready for Pickup';
      case ReservationStatus.cancelled:
        return 'Cancelled';
      case ReservationStatus.completed:
        return 'Completed';
    }
  }
}

enum ReservationStatus {
  active,
  ready,
  cancelled,
  completed,
}
