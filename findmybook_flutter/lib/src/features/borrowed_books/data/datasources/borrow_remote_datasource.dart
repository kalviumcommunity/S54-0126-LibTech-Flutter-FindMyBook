import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/borrow_model.dart';
import '../../domain/entities/borrow.dart';

/// Firestore Datasource for borrow operations
/// (Like MongoDB queries in Express routes)
abstract class BorrowRemoteDataSource {
  /// Create a borrow record in Firestore
  Future<BorrowModel> borrowBook({
    required String userId,
    required String bookId,
    required String bookTitle,
    required String bookAuthor,
    required int borrowDays,
  });

  /// Update borrow record to mark as returned
  Future<BorrowModel> returnBook(String borrowId);

  /// Fetch all active borrows for a user
  Future<List<BorrowModel>> getActiveBorrowsForUser(String userId);

  /// Fetch borrow history (all borrows including returned)
  Future<List<BorrowModel>> getBorrowHistoryForUser(String userId);

  /// Fetch a single borrow record
  Future<BorrowModel?> getBorrowById(String borrowId);

  /// Stream of active borrows (real-time)
  Stream<List<BorrowModel>> watchActiveBorrowsForUser(String userId);

  /// Stream of borrow history (real-time)
  Stream<List<BorrowModel>> watchBorrowHistoryForUser(String userId);

  /// Count active borrows for a user
  Future<int> countActiveBorrows(String userId);

  /// Renew a borrowed book (extend due date)
  Future<BorrowModel> renewBorrow({
    required String borrowId,
    required int additionalDays,
  });
}

/// Implementation of BorrowRemoteDataSource using Firebase
class BorrowRemoteDataSourceImpl implements BorrowRemoteDataSource {
  final FirebaseFirestore _firebaseFirestore;

  // Collection references
  static const String _borrowsCollection = 'borrows';
  static const String _booksCollection = 'books';

  BorrowRemoteDataSourceImpl(this._firebaseFirestore);

  @override
  Future<BorrowModel> borrowBook({
    required String userId,
    required String bookId,
    required String bookTitle,
    required String bookAuthor,
    required int borrowDays,
  }) async {
    try {
      final now = DateTime.now();
      final dueDate = now.add(Duration(days: borrowDays));

      final borrowData = {
        'userId': userId,
        'bookId': bookId,
        'bookTitle': bookTitle,
        'bookAuthor': bookAuthor,
        'borrowedAt': Timestamp.fromDate(now),
        'dueDate': Timestamp.fromDate(dueDate),
        'returnedAt': null,
        'status': BorrowStatus.active.stringValue,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add to borrows collection
      final docRef = await _firebaseFirestore
          .collection(_borrowsCollection)
          .add(borrowData);

      // Update book's availability status
      await _firebaseFirestore
          .collection(_booksCollection)
          .doc(bookId)
          .update({
            'available': false,
            'borrowedBy': userId,
          });

      // Fetch and return the created document
      final snapshot = await docRef.get();
      return BorrowModel.fromSnapshot(snapshot);
    } catch (e) {
      throw Exception('Failed to borrow book: $e');
    }
  }

  @override
  Future<BorrowModel> returnBook(String borrowId) async {
    try {
      final now = DateTime.now();

      final borrowRef = _firebaseFirestore
          .collection(_borrowsCollection)
          .doc(borrowId);

      // Get the borrow record to find the book
      final borrowSnap = await borrowRef.get();
      final borrowData = borrowSnap.data();

      if (borrowData == null) {
        throw Exception('Borrow record not found');
      }

      final bookId = borrowData['bookId'] as String;

      // Update borrow record
      await borrowRef.update({
        'returnedAt': Timestamp.fromDate(now),
        'status': BorrowStatus.returned.stringValue,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update book's availability
      await _firebaseFirestore
          .collection(_booksCollection)
          .doc(bookId)
          .update({
            'available': true,
            'borrowedBy': FieldValue.delete(),
          });

      // Fetch and return updated document
      final snapshot = await borrowRef.get();
      return BorrowModel.fromSnapshot(snapshot);
    } catch (e) {
      throw Exception('Failed to return book: $e');
    }
  }

  @override
  Future<List<BorrowModel>> getActiveBorrowsForUser(String userId) async {
    try {
      final snapshot = await _firebaseFirestore
          .collection(_borrowsCollection)
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: BorrowStatus.active.stringValue)
          .orderBy('dueDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => BorrowModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch active borrows: $e');
    }
  }

  @override
  Future<List<BorrowModel>> getBorrowHistoryForUser(String userId) async {
    try {
      final snapshot = await _firebaseFirestore
          .collection(_borrowsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('borrowedAt', descending: true)
          .limit(100) // Limit to prevent huge queries
          .get();

      return snapshot.docs
          .map((doc) => BorrowModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch borrow history: $e');
    }
  }

  @override
  Future<BorrowModel?> getBorrowById(String borrowId) async {
    try {
      final snapshot = await _firebaseFirestore
          .collection(_borrowsCollection)
          .doc(borrowId)
          .get();

      if (!snapshot.exists) return null;
      return BorrowModel.fromSnapshot(snapshot);
    } catch (e) {
      throw Exception('Failed to fetch borrow: $e');
    }
  }

  @override
  Stream<List<BorrowModel>> watchActiveBorrowsForUser(String userId) {
    return _firebaseFirestore
        .collection(_borrowsCollection)
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: BorrowStatus.active.stringValue)
        .orderBy('dueDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => BorrowModel.fromSnapshot(doc)).toList());
  }

  @override
  Stream<List<BorrowModel>> watchBorrowHistoryForUser(String userId) {
    return _firebaseFirestore
        .collection(_borrowsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('borrowedAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => BorrowModel.fromSnapshot(doc)).toList());
  }

  @override
  Future<int> countActiveBorrows(String userId) async {
    try {
      final snapshot = await _firebaseFirestore
          .collection(_borrowsCollection)
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: BorrowStatus.active.stringValue)
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      throw Exception('Failed to count borrows: $e');
    }
  }

  @override
  Future<BorrowModel> renewBorrow({
    required String borrowId,
    required int additionalDays,
  }) async {
    try {
      final borrowRef = _firebaseFirestore
          .collection(_borrowsCollection)
          .doc(borrowId);

      // Get current borrow
      final snapshot = await borrowRef.get();
      final borrowData = snapshot.data();

      if (borrowData == null) {
        throw Exception('Borrow record not found');
      }

      // Calculate new due date
      final currentDueDate = (borrowData['dueDate'] as Timestamp).toDate();
      final newDueDate = currentDueDate.add(Duration(days: additionalDays));

      // Update due date
      await borrowRef.update({
        'dueDate': Timestamp.fromDate(newDueDate),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Fetch and return updated document
      final updatedSnapshot = await borrowRef.get();
      return BorrowModel.fromSnapshot(updatedSnapshot);
    } catch (e) {
      throw Exception('Failed to renew borrow: $e');
    }
  }
}
