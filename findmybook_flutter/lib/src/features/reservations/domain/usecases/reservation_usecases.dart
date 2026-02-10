import '../../domain/entities/reservation.dart';
import '../../domain/repositories/reservation_repository.dart';

class ReserveBookUsecase {
  final ReservationRepository repository;

  ReserveBookUsecase(this.repository);

  Future<String> call(
    String userId,
    String bookId,
    String bookTitle,
    String bookAuthor,
  ) async {
    // Validation
    if (userId.isEmpty || bookId.isEmpty) {
      throw ArgumentError('User ID and Book ID are required');
    }

    // Check if already reserved
    final isReserved = await repository.isBookReservedByUser(userId, bookId);
    if (isReserved) {
      throw Exception('You have already reserved this book');
    }

    // Create reservation
    return await repository.reserveBook(userId, bookId, bookTitle, bookAuthor);
  }
}

class CancelReservationUsecase {
  final ReservationRepository repository;

  CancelReservationUsecase(this.repository);

  Future<void> call(String reservationId) async {
    if (reservationId.isEmpty) {
      throw ArgumentError('Reservation ID is required');
    }

    // Check if reservation exists
    final reservation = await repository.getReservation(reservationId);
    if (reservation == null) {
      throw Exception('Reservation not found');
    }

    // Cancel it
    return await repository.cancelReservation(reservationId);
  }
}

class GetUserReservationsUsecase {
  final ReservationRepository repository;

  GetUserReservationsUsecase(this.repository);

  Future<List<Reservation>> call(String userId) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID is required');
    }

    return await repository.getUserReservations(userId);
  }
}

class GetReservationCountUsecase {
  final ReservationRepository repository;

  GetReservationCountUsecase(this.repository);

  Future<int> call(String bookId) async {
    if (bookId.isEmpty) {
      throw ArgumentError('Book ID is required');
    }

    return await repository.getReservationCount(bookId);
  }
}
