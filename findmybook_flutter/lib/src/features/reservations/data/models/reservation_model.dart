import '../../domain/entities/reservation.dart';

/// ReservationModel for Firestore serialization/deserialization
class ReservationModel extends Reservation {
  const ReservationModel({
    required super.id,
    required super.bookId,
    required super.userId,
    required super.bookTitle,
    required super.bookAuthor,
    required super.reservedAt,
    super.expiresAt,
    super.status,
  });

  factory ReservationModel.fromMap(Map<String, dynamic> map, String id) {
    return ReservationModel(
      id: id,
      bookId: map['bookId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      bookTitle: map['bookTitle'] as String? ?? '',
      bookAuthor: map['bookAuthor'] as String? ?? '',
      reservedAt: map['reservedAt'] != null
          ? DateTime.parse(map['reservedAt'] as String)
          : DateTime.now(),
      expiresAt: map['expiresAt'] != null
          ? DateTime.parse(map['expiresAt'] as String)
          : null,
      status: _parseStatus(map['status'] as String? ?? 'active'),
    );
  }

  factory ReservationModel.fromFirestore(
      Map<String, dynamic> data, String id) {
    return ReservationModel.fromMap(data, id);
  }

  Map<String, dynamic> toMap() => {
        'bookId': bookId,
        'userId': userId,
        'bookTitle': bookTitle,
        'bookAuthor': bookAuthor,
        'reservedAt': reservedAt.toIso8601String(),
        'expiresAt': expiresAt?.toIso8601String(),
        'status': status.name,
      };

  static ReservationStatus _parseStatus(String status) {
    return ReservationStatus.values
        .firstWhere((s) => s.name == status, orElse: () => ReservationStatus.active);
  }
}
