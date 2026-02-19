import "package:cloud_firestore/cloud_firestore.dart";

import "../../../core/constants/firestore_paths.dart";
import "../../../core/errors/app_exception.dart";
import "../../borrow/domain/borrow_record.dart";

class BorrowService {
  final FirebaseFirestore _firestore;
  BorrowService(this._firestore);

  Stream<List<BorrowRecord>> watchUserBorrows(String userId) {
    return _firestore
        .collection(FirestorePaths.borrows)
        .where("userId", isEqualTo: userId)
        .orderBy("borrowedAt", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => _fromMap(doc.id, doc.data()))
              .toList(growable: false),
        );
  }

  Future<void> borrowBook({
    required String userId,
    required String bookId,
    required String title,
    required String author,
  }) async {
    final bookRef = _firestore.doc(FirestorePaths.book(bookId));
    final activeBorrowRef = _firestore.doc(FirestorePaths.borrow("${userId}_$bookId"));

    await _firestore.runTransaction((transaction) async {
      final bookSnapshot = await transaction.get(bookRef);
      final activeBorrowSnapshot = await transaction.get(activeBorrowRef);
      if (!bookSnapshot.exists) {
        throw const AppException("Book not found.");
      }
      final bookData = bookSnapshot.data() ?? <String, dynamic>{};
      final availableCopies = (bookData["availableCopies"] as num?)?.toInt() ?? 0;
      final reservedCopies = (bookData["reservedCopies"] as num?)?.toInt() ?? 0;

      if (activeBorrowSnapshot.exists &&
          (activeBorrowSnapshot.data()?["status"] as String?) == "active") {
        throw const AppException("You already borrowed this book.");
      }

      final reservationRef = _firestore.doc(FirestorePaths.reservation("${userId}_$bookId"));
      final reservationSnapshot = await transaction.get(reservationRef);

      if (reservationSnapshot.exists &&
          (reservationSnapshot.data()?["status"] as String?) == "active") {
        final reservationDoc = reservationRef;
        transaction.update(reservationDoc, {"status": "completed"});
        transaction.update(bookRef, {"reservedCopies": FieldValue.increment(-1)});
      } else {
        if ((availableCopies - reservedCopies) <= 0) {
          throw const AppException("No available copies to borrow.");
        }
        transaction.update(bookRef, {"availableCopies": FieldValue.increment(-1)});
      }

      final now = DateTime.now();
      final dueAt = now.add(const Duration(days: 14));
      transaction.set(activeBorrowRef, {
        "bookId": bookId,
        "userId": userId,
        "title": title,
        "author": author,
        "borrowedAt": Timestamp.fromDate(now),
        "dueAt": Timestamp.fromDate(dueAt),
        "returnedAt": null,
        "status": "active",
      });
    });
  }

  Future<void> returnBook({
    required String borrowId,
    required String userId,
  }) async {
    final borrowRef = _firestore.doc(FirestorePaths.borrow(borrowId));
    await _firestore.runTransaction((transaction) async {
      final borrowSnapshot = await transaction.get(borrowRef);
      if (!borrowSnapshot.exists) {
        throw const AppException("Borrow record not found.");
      }
      final borrowData = borrowSnapshot.data() ?? <String, dynamic>{};
      if ((borrowData["userId"] as String?) != userId) {
        throw const AppException("Unauthorized action.");
      }
      if ((borrowData["status"] as String?) != "active") {
        throw const AppException("Book already returned.");
      }
      final bookId = borrowData["bookId"] as String? ?? "";
      final bookRef = _firestore.doc(FirestorePaths.book(bookId));
      transaction.update(borrowRef, {
        "status": "returned",
        "returnedAt": Timestamp.now(),
      });
      transaction.update(bookRef, {
        "availableCopies": FieldValue.increment(1),
      });
    });
  }

  BorrowRecord _fromMap(String id, Map<String, dynamic> map) {
    final statusRaw = map["status"] as String? ?? "active";
    final status = BorrowStatus.values.firstWhere(
      (item) => item.name == statusRaw,
      orElse: () => BorrowStatus.active,
    );
    return BorrowRecord(
      id: id,
      bookId: map["bookId"] as String? ?? "",
      userId: map["userId"] as String? ?? "",
      title: map["title"] as String? ?? "Unknown",
      author: map["author"] as String? ?? "Unknown",
      borrowedAt: (map["borrowedAt"] as Timestamp?)?.toDate() ?? DateTime.now(),
      dueAt: (map["dueAt"] as Timestamp?)?.toDate() ?? DateTime.now(),
      returnedAt: (map["returnedAt"] as Timestamp?)?.toDate(),
      status: status,
    );
  }
}
