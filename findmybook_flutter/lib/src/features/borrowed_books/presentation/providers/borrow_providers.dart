import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/borrow_remote_datasource.dart';
import '../data/repositories/borrow_repository_impl.dart';
import '../domain/entities/borrow.dart';
import '../domain/repositories/borrow_repository.dart';
import '../domain/usecases/borrow_usecases.dart';

// ============ Dependencies (like service injection) ============

/// Firestore instance provider
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Remote datasource provider
final borrowRemoteDataSourceProvider =
    Provider<BorrowRemoteDataSource>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return BorrowRemoteDataSourceImpl(firestore);
});

/// Repository provider
final borrowRepositoryProvider = Provider<BorrowRepository>((ref) {
  final dataSource = ref.watch(borrowRemoteDataSourceProvider);
  return BorrowRepositoryImpl(dataSource);
});

// ============ Use Cases (like service methods) ============

final borrowBookUseCaseProvider = Provider((ref) {
  final repository = ref.watch(borrowRepositoryProvider);
  return BorrowBook(repository);
});

final returnBookUseCaseProvider = Provider((ref) {
  final repository = ref.watch(borrowRepositoryProvider);
  return ReturnBook(repository);
});

final getActiveBorrowsUseCaseProvider = Provider((ref) {
  final repository = ref.watch(borrowRepositoryProvider);
  return GetActiveBorrows(repository);
});

final getBorrowHistoryUseCaseProvider = Provider((ref) {
  final repository = ref.watch(borrowRepositoryProvider);
  return GetBorrowHistory(repository);
});

final renewBorrowUseCaseProvider = Provider((ref) {
  final repository = ref.watch(borrowRepositoryProvider);
  return RenewBorrow(repository);
});

// ============ State Notifiers (like Redux reducers/Redux Thunk) ============

/// Manages active borrows state (for currently borrowed books)
class ActiveBorrowsNotifier extends StateNotifier<AsyncValue<List<Borrow>>> {
  final GetActiveBorrows _getActiveBorrows;
  final String _userId;

  ActiveBorrowsNotifier(this._getActiveBorrows, this._userId)
      : super(const AsyncValue.loading());

  Future<void> loadActiveBorrows() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _getActiveBorrows(_userId),
    );
  }

  void refresh() {
    loadActiveBorrows();
  }
}

/// Provider for active borrows notifier
final activeborrowsNotifierProvider = StateNotifierProvider.autoDispose.family<
    ActiveBorrowsNotifier,
    AsyncValue<List<Borrow>>,
    String>((ref, userId) {
  final useCase = ref.watch(getActiveBorrowsUseCaseProvider);
  return ActiveBorrowsNotifier(useCase, userId);
});

// ============ Stream Providers (Real-time data like WebSockets) ============

/// Watch active borrows in real-time (like Socket.io listeners)
final activeborrowsStreamProvider =
    StreamProvider.autoDispose.family<List<Borrow>, String>((ref, userId) {
  final repository = ref.watch(borrowRepositoryProvider);
  return repository.watchActiveBorrowsForUser(userId);
});

/// Watch borrow history in real-time
final borrowHistoryStreamProvider =
    StreamProvider.autoDispose.family<List<Borrow>, String>((ref, userId) {
  final repository = ref.watch(borrowRepositoryProvider);
  return repository.watchBorrowHistoryForUser(userId);
});

// ============ Future Providers (One-time async operations) ============

/// Fetch active borrows
final activeborrowsFutureProvider =
    FutureProvider.autoDispose.family<List<Borrow>, String>((ref, userId) async {
  final repository = ref.watch(borrowRepositoryProvider);
  return repository.getActiveBorrowsForUser(userId);
});

/// Fetch borrow history
final borrowHistoryFutureProvider =
    FutureProvider.autoDispose.family<List<Borrow>, String>((ref, userId) async {
  final repository = ref.watch(borrowRepositoryProvider);
  return repository.getBorrowHistoryForUser(userId);
});

/// Check if user has reached borrow limit
final borrowLimitProvider = FutureProvider.autoDispose
    .family<bool, String>((ref, userId) async {
  final repository = ref.watch(borrowRepositoryProvider);
  return repository.hasReachedBorrowLimit(userId);
});

/// Get total borrow count
final borrowCountProvider =
    FutureProvider.autoDispose.family<int, String>((ref, userId) async {
  final repository = ref.watch(borrowRepositoryProvider);
  return repository.getTotalBorrowCount(userId);
});

// ============ Action Providers (Side effects like API calls) ============

/// Borrow a book
final borrowBookActionProvider = FutureProvider.autoDispose.family<
    Borrow,
    (String userId, String bookId, String bookTitle, String bookAuthor, int
        borrowDays)>((ref, params) async {
  final useCase = ref.watch(borrowBookUseCaseProvider);
  final result = await useCase(
    userId: params.$1,
    bookId: params.$2,
    bookTitle: params.$3,
    bookAuthor: params.$4,
    borrowDays: params.$5,
  );

  // Invalidate active borrows to refresh UI
  ref.invalidate(activeborrowsStreamProvider(params.$1));

  return result;
});

/// Return a book
final returnBookActionProvider =
    FutureProvider.autoDispose.family<Borrow, String>((ref, borrowId) async {
  final useCase = ref.watch(returnBookUseCaseProvider);
  final result = await useCase(borrowId);

  // Invalidate streams to refresh UI
  // Note: We don't know the userId here, so the UI should handle this
  return result;
});

/// Renew a book
final renewBorrowActionProvider = FutureProvider.autoDispose
    .family<Borrow, (String borrowId, int additionalDays)>((ref, params) async {
  final useCase = ref.watch(renewBorrowUseCaseProvider);
  return useCase(borrowId: params.$1, additionalDays: params.$2);
});
