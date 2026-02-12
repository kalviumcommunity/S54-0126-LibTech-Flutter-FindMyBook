import '../datasources/borrow_remote_datasource.dart';
import '../models/borrow_model.dart';
import '../../domain/entities/borrow.dart';
import '../../domain/repositories/borrow_repository.dart';

/// Repository implementation (like Express service layer)
/// Acts as a middleman between datasource and domain
class BorrowRepositoryImpl implements BorrowRepository {
  final BorrowRemoteDataSource remoteDataSource;

  BorrowRepositoryImpl(this.remoteDataSource);

  @override
  Future<Borrow> borrowBook({
    required String userId,
    required String bookId,
    required String bookTitle,
    required String bookAuthor,
    required int borrowDays,
  }) async {
    final result = await remoteDataSource.borrowBook(
      userId: userId,
      bookId: bookId,
      bookTitle: bookTitle,
      bookAuthor: bookAuthor,
      borrowDays: borrowDays,
    );
    return result;
  }

  @override
  Future<Borrow> returnBook({required String borrowId}) async {
    final result = await remoteDataSource.returnBook(borrowId);
    return result;
  }

  @override
  Future<List<Borrow>> getActiveBorrowsForUser(String userId) async {
    final result = await remoteDataSource.getActiveBorrowsForUser(userId);
    return result;
  }

  @override
  Future<List<Borrow>> getBorrowHistoryForUser(String userId) async {
    final result = await remoteDataSource.getBorrowHistoryForUser(userId);
    return result;
  }

  @override
  Future<Borrow?> getBorrowById(String borrowId) async {
    final result = await remoteDataSource.getBorrowById(borrowId);
    return result;
  }

  @override
  Stream<List<Borrow>> watchActiveBorrowsForUser(String userId) {
    return remoteDataSource.watchActiveBorrowsForUser(userId);
  }

  @override
  Stream<List<Borrow>> watchBorrowHistoryForUser(String userId) {
    return remoteDataSource.watchBorrowHistoryForUser(userId);
  }

  @override
  Future<bool> hasReachedBorrowLimit(String userId, {int maxBorrows = 5}) async {
    final count = await remoteDataSource.countActiveBorrows(userId);
    return count >= maxBorrows;
  }

  @override
  Future<int> getTotalBorrowCount(String userId) async {
    final result = await remoteDataSource.countActiveBorrows(userId);
    return result;
  }

  @override
  Future<Borrow> renewBorrow({
    required String borrowId,
    required int additionalDays,
  }) async {
    final result = await remoteDataSource.renewBorrow(
      borrowId: borrowId,
      additionalDays: additionalDays,
    );
    return result;
  }
}
