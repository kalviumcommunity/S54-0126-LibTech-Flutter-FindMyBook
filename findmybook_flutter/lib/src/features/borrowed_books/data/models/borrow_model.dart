import 'package:cloud_firestore/cloud_firestore.dart';
import '../entities/borrow.dart';

/// BorrowModel - Data Transfer Object (DTO) (like Mongoose model)
/// Maps Firestore documents to Dart objects
class BorrowModel extends Borrow {
  const BorrowModel({
    required super.id,
    required super.userId,
    required super.bookId,
    required super.bookTitle,
    required super.bookAuthor,
    required super.borrowedAt,
    required super.dueDate,
    super.returnedAt,
    required super.status,
  });

  /// Convert from Firestore document snapshot to BorrowModel
  /// Like deserializing MongoDB document to Mongoose model
  factory BorrowModel.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>? ?? {};
    
    return BorrowModel(
      id: snap.id,
      userId: data['userId'] as String? ?? '',
      bookId: data['bookId'] as String? ?? '',
      bookTitle: data['bookTitle'] as String? ?? 'Untitled',
      bookAuthor: data['bookAuthor'] as String? ?? 'Unknown',
      borrowedAt: _toDateTime(data['borrowedAt']),
      dueDate: _toDateTime(data['dueDate']),
      returnedAt: data['returnedAt'] != null ? _toDateTime(data['returnedAt']) : null,
      status: _parseBorrowStatus(data['status']),
    );
  }

  /// Convert BorrowModel to JSON for Firestore
  /// Like serializing Mongoose model to MongoDB
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'bookAuthor': bookAuthor,
      'borrowedAt': Timestamp.fromDate(borrowedAt),
      'dueDate': Timestamp.fromDate(dueDate),
      'returnedAt': returnedAt != null ? Timestamp.fromDate(returnedAt!) : null,
      'status': status.stringValue,
    };
  }

  /// Convert entity to model
  factory BorrowModel.fromEntity(Borrow borrow) {
    return BorrowModel(
      id: borrow.id,
      userId: borrow.userId,
      bookId: borrow.bookId,
      bookTitle: borrow.bookTitle,
      bookAuthor: borrow.bookAuthor,
      borrowedAt: borrow.borrowedAt,
      dueDate: borrow.dueDate,
      returnedAt: borrow.returnedAt,
      status: borrow.status,
    );
  }
}

/// Helper function to convert Firestore Timestamp to DateTime
DateTime _toDateTime(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  } else if (value is String) {
    return DateTime.tryParse(value) ?? DateTime.now();
  } else if (value is DateTime) {
    return value;
  }
  return DateTime.now();
}

/// Helper function to parse BorrowStatus from string
BorrowStatus _parseBorrowStatus(dynamic value) {
  if (value is String) {
    return BorrowStatus.values.firstWhere(
      (e) => e.stringValue == value,
      orElse: () => BorrowStatus.active,
    );
  }
  return BorrowStatus.active;
}
