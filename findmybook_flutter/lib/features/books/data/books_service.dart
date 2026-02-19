import "package:cloud_firestore/cloud_firestore.dart";

import "../../../core/constants/firestore_paths.dart";
import "../domain/book.dart";

class BooksService {
  final FirebaseFirestore _firestore;
  BooksService(this._firestore);

  Stream<List<Book>> watchBooks() {
    return _firestore
        .collection(FirestorePaths.books)
        .orderBy("title")
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => _fromMap(doc.id, doc.data()))
              .toList(growable: false),
        );
  }

  Future<Book?> getBookById(String id) async {
    final doc = await _firestore.doc(FirestorePaths.book(id)).get();
    if (!doc.exists) {
      return null;
    }
    return _fromMap(doc.id, doc.data() ?? <String, dynamic>{});
  }

  Future<void> seedSampleBooks() async {
    final booksCollection = _firestore.collection(FirestorePaths.books);
    final existing = await booksCollection.limit(1).get();
    if (existing.docs.isNotEmpty) {
      return;
    }

    final batch = _firestore.batch();
    final samples = <Map<String, dynamic>>[
      {
        "title": "Clean Architecture",
        "author": "Robert C. Martin",
        "category": "Software",
        "totalCopies": 4,
        "availableCopies": 4,
        "reservedCopies": 0,
      },
      {
        "title": "Flutter in Action",
        "author": "Eric Windmill",
        "category": "Mobile",
        "totalCopies": 3,
        "availableCopies": 3,
        "reservedCopies": 0,
      },
      {
        "title": "Atomic Habits",
        "author": "James Clear",
        "category": "Self Help",
        "totalCopies": 5,
        "availableCopies": 5,
        "reservedCopies": 0,
      },
      {
        "title": "Design Patterns",
        "author": "Gang of Four",
        "category": "Software",
        "totalCopies": 2,
        "availableCopies": 2,
        "reservedCopies": 0,
      },
    ];

    for (final sample in samples) {
      final doc = booksCollection.doc();
      batch.set(doc, sample);
    }
    await batch.commit();
  }

  Book _fromMap(String id, Map<String, dynamic> map) {
    final totalCopies = (map["totalCopies"] as num?)?.toInt() ?? 1;
    final availableCopies = (map["availableCopies"] as num?)?.toInt() ?? totalCopies;
    final reservedCopies = (map["reservedCopies"] as num?)?.toInt() ?? 0;
    return Book(
      id: id,
      title: (map["title"] as String?)?.trim().isNotEmpty == true
          ? (map["title"] as String).trim()
          : "Untitled",
      author: (map["author"] as String?)?.trim().isNotEmpty == true
          ? (map["author"] as String).trim()
          : "Unknown Author",
      category: (map["category"] as String?)?.trim().isNotEmpty == true
          ? (map["category"] as String).trim()
          : "General",
      totalCopies: totalCopies,
      availableCopies: availableCopies,
      reservedCopies: reservedCopies,
      coverUrl: map["coverUrl"] as String?,
      libraryId: map["libraryId"] as String?,
    );
  }
}
