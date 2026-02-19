import "../domain/reservation.dart";
import "../domain/reservations_repository.dart";
import "reservations_service.dart";

class ReservationsRepositoryImpl implements ReservationsRepository {
  final ReservationsService _service;
  ReservationsRepositoryImpl(this._service);

  @override
  Stream<List<Reservation>> watchUserReservations(String userId) {
    return _service.watchUserReservations(userId);
  }

  @override
  Stream<int> watchActiveReservationCount(String bookId) {
    return _service.watchActiveReservationCount(bookId);
  }

  @override
  Future<bool> hasActiveReservation({
    required String userId,
    required String bookId,
  }) {
    return _service.hasActiveReservation(userId: userId, bookId: bookId);
  }

  @override
  Future<void> reserveBook({
    required String userId,
    required String bookId,
    required String title,
    required String author,
  }) {
    return _service.reserveBook(
      userId: userId,
      bookId: bookId,
      title: title,
      author: author,
    );
  }

  @override
  Future<void> cancelReservation({
    required String reservationId,
    required String userId,
  }) {
    return _service.cancelReservation(
      reservationId: reservationId,
      userId: userId,
    );
  }
}
