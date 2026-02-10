import '../../domain/entities/reservation.dart';
import '../../domain/repositories/reservation_repository.dart';
import '../datasources/reservations_remote_data_source.dart';
import '../models/reservation_model.dart';

class ReservationRepositoryImpl implements ReservationRepository {
  final ReservationsRemoteDataSource _remoteDataSource;

  ReservationRepositoryImpl(this._remoteDataSource);

  @override
  Future<String> reserveBook(
    String userId,
    String bookId,
    String bookTitle,
    String bookAuthor,
  ) async {
    return _remoteDataSource.reserveBook(
      userId,
      bookId,
      bookTitle,
      bookAuthor,
    );
  }

  @override
  Future<void> cancelReservation(String reservationId) async {
    return _remoteDataSource.cancelReservation(reservationId);
  }

  @override
  Future<List<Reservation>> getUserReservations(String userId) async {
    final models = await _remoteDataSource.getUserReservations(userId);
    return models.cast<Reservation>();
  }

  @override
  Future<Reservation?> getReservation(String reservationId) async {
    return await _remoteDataSource.getReservation(reservationId);
  }

  @override
  Future<List<Reservation>> getBookReservations(String bookId) async {
    final models = await _remoteDataSource.getBookReservations(bookId);
    return models.cast<Reservation>();
  }

  @override
  Future<bool> isBookReservedByUser(String userId, String bookId) async {
    return await _remoteDataSource.isBookReservedByUser(userId, bookId);
  }

  @override
  Future<int> getReservationCount(String bookId) async {
    return await _remoteDataSource.getReservationCount(bookId);
  }
}
