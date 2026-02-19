import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../core/firebase/firebase_providers.dart";
import "../../auth/presentation/auth_controller.dart";
import "../data/borrow_repository_impl.dart";
import "../data/borrow_service.dart";
import "../domain/borrow_record.dart";
import "../domain/borrow_repository.dart";

final borrowRepositoryProvider = Provider<BorrowRepository>((ref) {
  return BorrowRepositoryImpl(BorrowService(ref.watch(firestoreProvider)));
});

final userBorrowRecordsProvider = StreamProvider<List<BorrowRecord>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    return const Stream.empty();
  }
  return ref.watch(borrowRepositoryProvider).watchUserBorrows(user.uid);
});

final borrowControllerProvider = StateNotifierProvider<BorrowController, AsyncValue<void>>((ref) {
  return BorrowController(ref: ref, repository: ref.watch(borrowRepositoryProvider));
});

class BorrowController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  final BorrowRepository repository;

  BorrowController({
    required this.ref,
    required this.repository,
  }) : super(const AsyncData(null));

  Future<void> borrow({
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
      await repository.borrowBook(
        userId: user.uid,
        bookId: bookId,
        title: title,
        author: author,
      );
    });
  }

  Future<void> returnBook(String borrowId) async {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) {
      state = AsyncError("Please login first.", StackTrace.current);
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repository.returnBook(
        borrowId: borrowId,
        userId: user.uid,
      );
    });
  }
}
