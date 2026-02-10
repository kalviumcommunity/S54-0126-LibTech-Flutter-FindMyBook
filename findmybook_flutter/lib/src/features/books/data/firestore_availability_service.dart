import 'package:cloud_firestore/cloud_firestore.dart';

/// Recomputes/updates the `available` flag on the `books/{id}` document.
///
/// This method is safe to call from client code (transactional) but in
/// production we recommend making this logic server-side (Cloud Function)
/// so clients cannot manipulate availability directly.
class FirestoreAvailabilityService {
  final FirebaseFirestore _firestore;
  FirestoreAvailabilityService([FirebaseFirestore? firestore]) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Looks for active loans for [bookId] and updates `books/{bookId}.available`.
  Future<void> recomputeAvailability(String bookId) async {
    final bookRef = _firestore.collection('books').doc(bookId);
    final loansQuery = _firestore.collection('loans').where('bookId', isEqualTo: bookId).where('returned', isEqualTo: false);

    final snapshot = await loansQuery.get();
    final hasActiveLoans = snapshot.docs.isNotEmpty;

    await _firestore.runTransaction((tx) async {
      tx.update(bookRef, {'available': !hasActiveLoans});
    });
  }
}
