import "package:cloud_firestore/cloud_firestore.dart";
import "package:cloud_functions/cloud_functions.dart";

import "../../../core/constants/firestore_paths.dart";
import "../../../core/errors/app_exception.dart";
import "../domain/reservation.dart";

class ReservationsService {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  ReservationsService(this._firestore, this._functions);

  Stream<List<Reservation>> watchUserReservations(String userId) {
    return _firestore
        .collection(FirestorePaths.reservations)
        .where("userId", isEqualTo: userId)
        .orderBy("reservedAt", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => _fromMap(doc.id, doc.data()))
              .toList(growable: false),
        );
  }

  Stream<int> watchActiveReservationCount(String bookId) {
    return _firestore
        .collection(FirestorePaths.reservations)
        .where("bookId", isEqualTo: bookId)
        .where("status", isEqualTo: "active")
        .snapshots()
        .map((snapshot) {
      final now = DateTime.now();
      return snapshot.docs
          .where((doc) {
            final expiresAt = (doc.data()["expiresAt"] as Timestamp?)?.toDate();
            return expiresAt != null && expiresAt.isAfter(now);
          })
          .length;
    });
  }

  Future<bool> hasActiveReservation({
    required String userId,
    required String bookId,
  }) async {
    final query = await _firestore
        .collection(FirestorePaths.reservations)
        .where("userId", isEqualTo: userId)
        .where("bookId", isEqualTo: bookId)
        .where("status", isEqualTo: "active")
        .limit(1)
        .get();
    if (query.docs.isEmpty) {
      return false;
    }
    final expiresAt = (query.docs.first.data()["expiresAt"] as Timestamp?)?.toDate();
    return expiresAt != null && expiresAt.isAfter(DateTime.now());
  }

  Future<void> reserveBook({
    required String userId,
    required String bookId,
    required String title,
    required String author,
  }) async {
    final callable = _functions.httpsCallable("validateReservation");
    try {
      final response = await callable.call(<String, dynamic>{
        "userId": userId,
        "bookId": bookId,
      });
      final data = response.data as Map<dynamic, dynamic>?;
      if (data != null && data["allowed"] == false) {
        throw AppException(data["reason"]?.toString() ?? "Reservation denied.");
      }
    } on FirebaseFunctionsException catch (e) {
      throw AppException(e.message ?? "Reservation validation failed.");
    }

    final bookRef = _firestore.doc(FirestorePaths.book(bookId));
    final reservationRef = _firestore
        .doc(FirestorePaths.reservation("${userId}_$bookId"));

    await _firestore.runTransaction((transaction) async {
      final bookSnapshot = await transaction.get(bookRef);
      final existingReservation = await transaction.get(reservationRef);
      if (!bookSnapshot.exists) {
        throw const AppException("Book not found.");
      }

      final map = bookSnapshot.data() ?? <String, dynamic>{};
      final availableCopies = (map["availableCopies"] as num?)?.toInt() ?? 0;
      final reservedCopies = (map["reservedCopies"] as num?)?.toInt() ?? 0;
      if ((availableCopies - reservedCopies) <= 0) {
        throw const AppException("No copies available for reservation.");
      }

      if (existingReservation.exists &&
          (existingReservation.data()?["status"] as String?) == "active") {
        throw const AppException("You already have an active reservation.");
      }

      final now = DateTime.now();
      final expiresAt = now.add(const Duration(days: 7));
      transaction.set(reservationRef, <String, dynamic>{
        "bookId": bookId,
        "userId": userId,
        "bookTitle": title,
        "bookAuthor": author,
        "reservedAt": Timestamp.fromDate(now),
        "expiresAt": Timestamp.fromDate(expiresAt),
        "status": "active",
      });
      transaction.update(bookRef, <String, dynamic>{
        "reservedCopies": FieldValue.increment(1),
      });
    });
  }

  Future<void> cancelReservation({
    required String reservationId,
    required String userId,
  }) async {
    final reservationRef = _firestore.doc(FirestorePaths.reservation(reservationId));
    await _firestore.runTransaction((transaction) async {
      final reservationSnapshot = await transaction.get(reservationRef);
      if (!reservationSnapshot.exists) {
        throw const AppException("Reservation not found.");
      }
      final data = reservationSnapshot.data() ?? <String, dynamic>{};
      if ((data["userId"] as String?) != userId) {
        throw const AppException("You can cancel only your reservation.");
      }
      if ((data["status"] as String?) != "active") {
        throw const AppException("Only active reservations can be cancelled.");
      }
      final bookId = data["bookId"] as String? ?? "";
      final bookRef = _firestore.doc(FirestorePaths.book(bookId));
      transaction.update(reservationRef, <String, dynamic>{
        "status": "cancelled",
      });
      transaction.update(bookRef, <String, dynamic>{
        "reservedCopies": FieldValue.increment(-1),
      });
    });
  }

  Reservation _fromMap(String id, Map<String, dynamic> map) {
    final statusValue = map["status"] as String? ?? "active";
    final status = ReservationStatus.values.firstWhere(
      (item) => item.name == statusValue,
      orElse: () => ReservationStatus.active,
    );

    return Reservation(
      id: id,
      bookId: map["bookId"] as String? ?? "",
      userId: map["userId"] as String? ?? "",
      bookTitle: map["bookTitle"] as String? ?? "Unknown",
      bookAuthor: map["bookAuthor"] as String? ?? "Unknown",
      reservedAt: (map["reservedAt"] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (map["expiresAt"] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: status,
    );
  }
}
