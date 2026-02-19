import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../core/firebase/firebase_providers.dart";
import "../../auth/presentation/auth_controller.dart";
import "../data/reservations_repository_impl.dart";
import "../data/reservations_service.dart";
import "../domain/reservation.dart";
import "../domain/reservations_repository.dart";

final reservationsRepositoryProvider = Provider<ReservationsRepository>((ref) {
  return ReservationsRepositoryImpl(
    ReservationsService(
      ref.watch(firestoreProvider),
      ref.watch(functionsProvider),
    ),
  );
});

final userReservationsProvider = StreamProvider<List<Reservation>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    return const Stream.empty();
  }
  return ref.watch(reservationsRepositoryProvider).watchUserReservations(user.uid);
});

final reservationCountByBookProvider = StreamProvider.family<int, String>((ref, bookId) {
  return ref.watch(reservationsRepositoryProvider).watchActiveReservationCount(bookId);
});

final hasActiveReservationProvider = FutureProvider.family<bool, String>((ref, bookId) async {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    return false;
  }
  return ref.watch(reservationsRepositoryProvider).hasActiveReservation(
        userId: user.uid,
        bookId: bookId,
      );
});

final reservationControllerProvider =
    StateNotifierProvider<ReservationController, AsyncValue<void>>((ref) {
  return ReservationController(
    repository: ref.watch(reservationsRepositoryProvider),
    ref: ref,
  );
});

class ReservationController extends StateNotifier<AsyncValue<void>> {
  final ReservationsRepository repository;
  final Ref ref;

  ReservationController({
    required this.repository,
    required this.ref,
  }) : super(const AsyncData(null));

  Future<void> reserveBook({
    required String bookId,
    required String title,
    required String author,
  }) async {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) {
      state = AsyncError("Please login first.", StackTrace.current);
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repository.reserveBook(
        userId: user.uid,
        bookId: bookId,
        title: title,
        author: author,
      );
    });
  }

  Future<void> cancelReservation(String reservationId) async {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) {
      state = AsyncError("Please login first.", StackTrace.current);
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repository.cancelReservation(
        reservationId: reservationId,
        userId: user.uid,
      );
    });
  }
}
