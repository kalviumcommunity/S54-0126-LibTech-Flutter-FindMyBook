import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../core/firebase/firebase_providers.dart";
import "../data/books_repository_impl.dart";
import "../data/books_service.dart";
import "../domain/book.dart";
import "../domain/books_repository.dart";

final booksRepositoryProvider = Provider<BooksRepository>((ref) {
  return BooksRepositoryImpl(BooksService(ref.watch(firestoreProvider)));
});

final booksStreamProvider = StreamProvider<List<Book>>((ref) {
  return ref.watch(booksRepositoryProvider).watchBooks();
});

final booksServiceProvider = Provider<BooksService>((ref) {
  return BooksService(ref.watch(firestoreProvider));
});

final bookSeedControllerProvider =
    StateNotifierProvider<BookSeedController, AsyncValue<void>>((ref) {
  return BookSeedController(ref.watch(booksServiceProvider));
});

class BookSeedController extends StateNotifier<AsyncValue<void>> {
  final BooksService _service;
  BookSeedController(this._service) : super(const AsyncData(null));

  Future<void> seed() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _service.seedSampleBooks();
    });
  }
}
