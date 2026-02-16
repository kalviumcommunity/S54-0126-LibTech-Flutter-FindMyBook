import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/library_location.dart';

/// Firestore Datasource for Library Locations
/// 
/// MERN Comparison:
/// - Replaces Express API routes like GET /api/libraries
/// - Handles MongoDB queries (now Firestore queries)
/// - Example MERN: db.collection('libraries').find({ location: { $near: { $geometry: {...} } } })
/// - Flutter: Uses Firestore built-in geo queries via GeoPoint indexing
abstract class LibraryLocationDataSource {
  Future<List<LibraryLocation>> getAllLocations();
  Future<LibraryLocation?> getLocationById(String id);
  Future<List<LibraryLocation>> getNearbyLocations({
    required double latitude,
    required double longitude,
    required double radiusKm,
  });
  Future<List<LibraryLocation>> searchLocations(String query);
  Future<void> createLocation(LibraryLocation location);
  Future<void> updateLocation(LibraryLocation location);
  Future<void> deleteLocation(String id);
}

/// Implementation of LibraryLocationDataSource
class FirestoreLibraryLocationDataSource implements LibraryLocationDataSource {
  final FirebaseFirestore _firestore;
  static const String _collectionPath = 'library_locations';

  FirestoreLibraryLocationDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get all library locations
  /// 
  /// MERN Equivalent: GET /api/libraries (returns all libraries)
  /// Firestore: collection.get() - no index needed for simple queries
  @override
  Future<List<LibraryLocation>> getAllLocations() async {
    try {
      final snapshot = await _firestore
          .collection(_collectionPath)
          .orderBy('name')
          .get();
      
      return snapshot.docs
          .map((doc) => LibraryLocation.fromSnapshot(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch library locations: $e');
    }
  }

  /// Get single location by ID
  /// 
  /// MERN Equivalent: GET /api/libraries/:id
  @override
  Future<LibraryLocation?> getLocationById(String id) async {
    try {
      final doc = await _firestore
          .collection(_collectionPath)
          .doc(id)
          .get();
      
      if (doc.exists) {
        return LibraryLocation.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch library location: $e');
    }
  }

  /// Get nearby locations using Haversine algorithm
  /// 
  /// MERN Equivalent: 
  /// GET /api/libraries/nearby?lat=40.7&lng=-74.0&radius=5
  /// MongoDB: db.collection('libraries').find({ 
  ///   location: { $near: { $geometry: {...}, $maxDistance: 5000 } } 
  /// })
  /// 
  /// Firestore Note:
  /// - Firestore doesn't support geospatial queries natively like MongoDB
  /// - We use a combined approach:
  ///   1. Get all locations (or use geo-hashing for large datasets)
  ///   2. Filter by bounding box first (approximate)
  ///   3. Calculate exact distance using Haversine
  /// - For production: Use GeoFlutterFire or custom geo-hashing
  @override
  Future<List<LibraryLocation>> getNearbyLocations({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    try {
      // Get approximate bounding box (1 degree ≈ 111 km)
      final latDelta = radiusKm / 111;
      final lngDelta = radiusKm / (111 * (latitude * 3.14159 / 180).cos());

      final snapshot = await _firestore
          .collection(_collectionPath)
          .where('location', isGreaterThanOrEqualTo: 
              GeoPoint(latitude - latDelta, longitude - lngDelta))
          .where('location', isLessThanOrEqualTo:
              GeoPoint(latitude + latDelta, longitude + lngDelta))
          .get();

      // Convert to LibraryLocation objects
      final locations = snapshot.docs
          .map((doc) => LibraryLocation.fromSnapshot(doc))
          .toList();

      // Filter by exact distance using Haversine
      final currentLocation = LibraryLocation(
        id: 'current',
        name: 'Current Location',
        address: '',
        latitude: latitude,
        longitude: longitude,
        phone: '',
        email: '',
        totalBooks: 0,
        availableBooks: 0,
        openingHours: [],
        isOpen: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return locations
          .where((loc) => currentLocation.distanceTo(loc) <= radiusKm)
          .toList()
          ..sort((a, b) => currentLocation.distanceTo(a)
              .compareTo(currentLocation.distanceTo(b)));
    } catch (e) {
      throw Exception('Failed to fetch nearby locations: $e');
    }
  }

  /// Search locations by name or address
  /// 
  /// MERN Equivalent: GET /api/libraries/search?q=central
  /// MongoDB: db.collection('libraries').find({ 
  ///   $or: [{ name: { $regex: 'central', $options: 'i' } }, 
  ///         { address: { $regex: 'central', $options: 'i' } }] 
  /// })
  /// 
  /// Firestore Note:
  /// - Firestore doesn't have regex search for strings
  /// - Solution 1: Use startsWith for prefix search (requires index)
  /// - Solution 2: Use Algolia/Meilisearch for full-text search
  /// - Solution 3: Get all + filter in-memory (shown here for small datasets)
  @override
  Future<List<LibraryLocation>> searchLocations(String query) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionPath)
          .get();

      final lowerQuery = query.toLowerCase();
      
      return snapshot.docs
          .map((doc) => LibraryLocation.fromSnapshot(doc))
          .where((location) =>
              location.name.toLowerCase().contains(lowerQuery) ||
              location.address.toLowerCase().contains(lowerQuery))
          .toList();
    } catch (e) {
      throw Exception('Failed to search library locations: $e');
    }
  }

  /// Create new library location
  /// 
  /// MERN Equivalent: POST /api/libraries
  /// MongoDB: db.collection('libraries').insertOne({ ... })
  @override
  Future<void> createLocation(LibraryLocation location) async {
    try {
      await _firestore
          .collection(_collectionPath)
          .doc(location.id)
          .set(location.toFirestore());
    } catch (e) {
      throw Exception('Failed to create library location: $e');
    }
  }

  /// Update existing library location
  /// 
  /// MERN Equivalent: PUT /api/libraries/:id
  /// MongoDB: db.collection('libraries').updateOne({ _id }, { ... })
  @override
  Future<void> updateLocation(LibraryLocation location) async {
    try {
      await _firestore
          .collection(_collectionPath)
          .doc(location.id)
          .update(location.toFirestore());
    } catch (e) {
      throw Exception('Failed to update library location: $e');
    }
  }

  /// Delete library location
  /// 
  /// MERN Equivalent: DELETE /api/libraries/:id
  /// MongoDB: db.collection('libraries').deleteOne({ _id })
  @override
  Future<void> deleteLocation(String id) async {
    try {
      await _firestore
          .collection(_collectionPath)
          .doc(id)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete library location: $e');
    }
  }
}
