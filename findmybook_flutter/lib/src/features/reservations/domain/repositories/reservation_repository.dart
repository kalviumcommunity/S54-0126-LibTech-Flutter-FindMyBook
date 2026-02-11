import '../entities/reservation.dart';

abstract class ReservationRepository {
  /// Reserve a book for current user
  Future<String> reserveBook(
    String userId,
    String bookId,
    String bookTitle,
    String bookAuthor,
  );

  /// Cancel a reservation
  Future<void> cancelReservation(String reservationId);

  /// Get all reservations for current user
  Future<List<Reservation>> getUserReservations(String userId);

  /// Get a single reservation
  Future<Reservation?> getReservation(String reservationId);

  /// Get all reservations for a specific book
  Future<List<Reservation>> getBookReservations(String bookId);

  /// Check if book is already reserved by user
  Future<bool> isBookReservedByUser(String userId, String bookId);

  /// Get reservation count for a book
  Future<int> getReservationCount(String bookId);
}
