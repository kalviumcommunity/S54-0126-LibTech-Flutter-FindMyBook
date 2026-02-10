import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/book.dart';

/// Streams a single Book document and maps it to the presentation `Book` model.
final bookStreamProvider = StreamProvider.family<Book, String>((ref, bookId) {
  final doc = FirebaseFirestore.instance.collection('books').doc(bookId);
  return doc.snapshots().map((snap) => Book.fromSnapshot(snap));
});

/// Small action helper that performs transactional checkout/return flows.
class BookActions {
  final Reader read;
  BookActions(this.read);

  /// Checkout: creates a loan document and sets `books/{id}.available = false` atomically.
  Future<void> checkout(String bookId, String userId) async {
    final firestore = FirebaseFirestore.instance;
    final bookRef = firestore.collection('books').doc(bookId);
    final loanRef = firestore.collection('loans').doc();

    await firestore.runTransaction((tx) async {
      final snap = await tx.get(bookRef);
      final available = (snap.data()?['available'] as bool?) ?? true;
      if (!available) throw Exception('Book is not available');

      tx.set(loanRef, {
        'bookId': bookId,
        'userId': userId,
        'checkedOutAt': FieldValue.serverTimestamp(),
        'returned': false,
      });

      tx.update(bookRef, {'available': false});
    });
  }

  /// Return: mark loan returned and set book available.
  Future<void> returnBook(String bookId, String loanId) async {
    final firestore = FirebaseFirestore.instance;
    final bookRef = firestore.collection('books').doc(bookId);
    final loanRef = firestore.collection('loans').doc(loanId);

    await firestore.runTransaction((tx) async {
      tx.update(loanRef, {'returned': true, 'returnedAt': FieldValue.serverTimestamp()});
      tx.update(bookRef, {'available': true});
    });
  }
}

final bookActionsProvider = Provider((ref) => BookActions(ref.read));
