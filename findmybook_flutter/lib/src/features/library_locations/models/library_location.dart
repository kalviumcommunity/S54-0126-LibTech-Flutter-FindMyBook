import 'package:cloud_firestore/cloud_firestore.dart';

/// LibraryLocation Model
/// 
/// MERN Comparison:
/// - MongoDB document with embedded geoPoint field
/// - Similar to: { _id, name, address, location: { type: "Point", coordinates: [lng, lat] }, ... }
/// - Firestore automatically indexes geo queries
class LibraryLocation {
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

  LibraryLocation({
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

  /// Factory constructor to create from Firestore DocumentSnapshot
  /// Handles GeoPoint conversion (Firestore native type)
  factory LibraryLocation.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>? ?? {};
    
    // Extract GeoPoint from Firestore
    final geoPoint = data['location'] as GeoPoint?;
    final latitude = geoPoint?.latitude ?? 0.0;
    final longitude = geoPoint?.longitude ?? 0.0;

    return LibraryLocation(
      id: snap.id,
      name: data['name'] as String? ?? 'Unknown Library',
      address: data['address'] as String? ?? 'No address',
      latitude: latitude,
      longitude: longitude,
      phone: data['phone'] as String? ?? '+1-000-0000',
      email: data['email'] as String? ?? 'contact@library.local',
      website: data['website'] as String?,
      totalBooks: data['totalBooks'] as int? ?? 0,
      availableBooks: data['availableBooks'] as int? ?? 0,
      openingHours: (data['openingHours'] as List<dynamic>?)
          ?.cast<String>() ?? ['9:00 AM - 5:00 PM'],
      isOpen: data['isOpen'] as bool? ?? true,
      rating: (data['rating'] as num?)?.toDouble(),
      createdAt: (data['createdAt'] is Timestamp)
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: (data['updatedAt'] is Timestamp)
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Convert to Firestore-compatible Map
  /// Uses GeoPoint for location field (enables geo-queries)
  Map<String, dynamic> toFirestore() => {
    'name': name,
    'address': address,
    'location': GeoPoint(latitude, longitude), // Firestore GeoPoint type
    'phone': phone,
    'email': email,
    'website': website,
    'totalBooks': totalBooks,
    'availableBooks': availableBooks,
    'openingHours': openingHours,
    'isOpen': isOpen,
    'rating': rating,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  /// Calculate distance to another library using Haversine formula
  /// Returns distance in kilometers
  double distanceTo(LibraryLocation other) {
    const earthRadius = 6371; // km
    
    final dLat = _toRad(other.latitude - latitude);
    final dLng = _toRad(other.longitude - longitude);
    
    final a = (1 - (dLat / 2).cos()) / 2 +
        latitude.toRad().cos() *
            other.latitude.toRad().cos() *
            (1 - (dLng / 2).cos()) / 2;
    
    final c = 2 * (a.sqrt()).atan2((1 - a).sqrt());
    return earthRadius * c;
  }

  static double _toRad(double degrees) => degrees * (3.14159265359 / 180);

  @override
  String toString() => 'LibraryLocation(id: $id, name: $name, lat: $latitude, lng: $longitude)';
}

extension RadianConversion on double {
  double toRad() => this * (3.14159265359 / 180);
}
