import "reservation.dart";

abstract class ReservationsRepository {
  Stream<List<Reservation>> watchUserReservations(String userId);
  Stream<int> watchActiveReservationCount(String bookId);
  Future<bool> hasActiveReservation({
    required String userId,
    required String bookId,
  });
  Future<void> reserveBook({
    required String userId,
    required String bookId,
    required String title,
    required String author,
  });
  Future<void> cancelReservation({
    required String reservationId,
    required String userId,
  });
}
