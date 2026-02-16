/// DomainEntity for LibraryLocation
/// 
/// MERN Comparison:
/// - TypeScript interface for API responses
/// - Business logic layer (independent of Firestore)
/// - Similar to: interface ILibrary { id: string; name: string; ... }
class LibraryLocationEntity {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final String email;
  final String? website;
  final int totalBooks;
  final int availableBooks;
  final List<String> openingHours;
  final bool isOpen;
  final double? rating;
  final DateTime createdAt;
  final DateTime updatedAt;

  LibraryLocationEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.email,
    this.website,
    required this.totalBooks,
    required this.availableBooks,
    required this.openingHours,
    required this.isOpen,
    this.rating,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibraryLocationEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
