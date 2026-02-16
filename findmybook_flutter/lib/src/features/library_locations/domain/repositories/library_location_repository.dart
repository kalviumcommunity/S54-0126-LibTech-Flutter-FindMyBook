import '../entities/library_location_entity.dart';

/// Domain Repository Interface
/// 
/// MERN Comparison:
/// - Abstract interface for data access (Repository Pattern)
/// - Similar to: abstract class ILibraryRepository { getAll(): Promise<ILibrary[]>; ... }
/// - Ensures loose coupling between domain and data layers
abstract class LibraryLocationRepository {
  Future<List<LibraryLocationEntity>> getAllLocations();
  Future<LibraryLocationEntity?> getLocationById(String id);
  Future<List<LibraryLocationEntity>> getNearbyLocations({
    required double latitude,
    required double longitude,
    required double radiusKm,
  });
  Future<List<LibraryLocationEntity>> searchLocations(String query);
  Future<void> createLocation(LibraryLocationEntity location);
  Future<void> updateLocation(LibraryLocationEntity location);
  Future<void> deleteLocation(String id);
}
