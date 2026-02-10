import '../models/reservation_model.dart';
import '../../domain/entities/reservation.dart';

/// Mock remote data source for reservations
/// 
/// Production: Replace with Firestore implementation
/// Collections structure:
/// ```
/// reservations/
///   {reservationId} -> {
///     bookId: string
///     userId: string
///     bookTitle: string
///     bookAuthor: string
///     reservedAt: timestamp
///     expiresAt: timestamp (7 days from now)
///     status: 'active' | 'ready' | 'cancelled' | 'completed'
///   }
/// ```
/// 
/// Indexes needed:
/// - Collection: reservations, Fields: userId, reservedAt (Descending)
/// - Collection: reservations, Fields: bookId, status
class ReservationsRemoteDataSource {
  /// Mock storage for testing
  static final Map<String, ReservationModel> _mockStore = {
    'res-1': ReservationModel(
      id: 'res-1',
      bookId: '1',
      userId: 'user123',
      bookTitle: 'Clean Architecture',
      bookAuthor: 'Robert C. Martin',
      reservedAt: DateTime.now().subtract(const Duration(days: 2)),
      expiresAt: DateTime.now().add(const Duration(days: 5)),
      status: ReservationStatus.active,
    ),
  };

  Future<String> reserveBook(
    String userId,
    String bookId,
    String bookTitle,
    String bookAuthor,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock check: Can't reserve if already reserved by user
    if (_mockStore.values.any((r) =>
        r.userId == userId &&
        r.bookId == bookId &&
        r.status == ReservationStatus.active)) {
      throw Exception('You have already reserved this book');
    }

    // Create new reservation (expires in 7 days)
    final reservationId = 'res-${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now();
    final expiresAt = now.add(const Duration(days: 7));

    final reservation = ReservationModel(
      id: reservationId,
      bookId: bookId,
      userId: userId,
      bookTitle: bookTitle,
      bookAuthor: bookAuthor,
      reservedAt: now,
      expiresAt: expiresAt,
      status: ReservationStatus.active,
    );

    _mockStore[reservationId] = reservation;
    return reservationId;
  }

  Future<void> cancelReservation(String reservationId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (_mockStore.containsKey(reservationId)) {
      final reservation = _mockStore[reservationId]!;
      _mockStore[reservationId] = ReservationModel(
        id: reservation.id,
        bookId: reservation.bookId,
        userId: reservation.userId,
        bookTitle: reservation.bookTitle,
        bookAuthor: reservation.bookAuthor,
        reservedAt: reservation.reservedAt,
        expiresAt: reservation.expiresAt,
        status: ReservationStatus.cancelled,
      );
    }
  }

  Future<List<ReservationModel>> getUserReservations(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockStore.values
        .where((r) => r.userId == userId)
        .toList()
        .cast<ReservationModel>();
  }

  Future<ReservationModel?> getReservation(String reservationId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockStore[reservationId];
  }

  Future<List<ReservationModel>> getBookReservations(String bookId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockStore.values
        .where((r) => r.bookId == bookId && r.status != ReservationStatus.cancelled)
        .toList()
        .cast<ReservationModel>();
  }

  Future<bool> isBookReservedByUser(String userId, String bookId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockStore.values.any((r) =>
        r.userId == userId &&
        r.bookId == bookId &&
        r.status == ReservationStatus.active &&
        !r.isExpired);
  }

  Future<int> getReservationCount(String bookId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockStore.values
        .where((r) =>
            r.bookId == bookId &&
            r.status == ReservationStatus.active &&
            !r.isExpired)
        .length;
  }
}
