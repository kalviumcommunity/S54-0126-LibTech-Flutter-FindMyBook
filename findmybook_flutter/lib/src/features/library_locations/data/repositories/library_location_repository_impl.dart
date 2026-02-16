import '../../models/library_location.dart';
import '../entities/library_location_entity.dart';
import '../repositories/library_location_repository.dart';
import '../datasources/firestore_library_location_datasource.dart';

/// Implementation of LibraryLocationRepository
/// 
/// MERN Comparison:
/// - Express service layer that calls database layer
/// - Similar to: class LibraryService { constructor(private db: ILibraryRepository) {} }
/// - Translates between Business Logic (Entity) and Data Layer (Model)
class LibraryLocationRepositoryImpl implements LibraryLocationRepository {
  final LibraryLocationDataSource dataSource;

  LibraryLocationRepositoryImpl({required this.dataSource});

  /// Convert model to entity (data → domain)
  LibraryLocationEntity _modelToEntity(LibraryLocation model) =>
      LibraryLocationEntity(
        id: model.id,
        name: model.name,
        address: model.address,
        latitude: model.latitude,
        longitude: model.longitude,
        phone: model.phone,
        email: model.email,
        website: model.website,
        totalBooks: model.totalBooks,
        availableBooks: model.availableBooks,
        openingHours: model.openingHours,
        isOpen: model.isOpen,
        rating: model.rating,
        createdAt: model.createdAt,
        updatedAt: model.updatedAt,
      );

  /// Convert entity to model (domain → data)
  LibraryLocation _entityToModel(LibraryLocationEntity entity) =>
      LibraryLocation(
        id: entity.id,
        name: entity.name,
        address: entity.address,
        latitude: entity.latitude,
        longitude: entity.longitude,
        phone: entity.phone,
        email: entity.email,
        website: entity.website,
        totalBooks: entity.totalBooks,
        availableBooks: entity.availableBooks,
        openingHours: entity.openingHours,
        isOpen: entity.isOpen,
        rating: entity.rating,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );

  @override
  Future<List<LibraryLocationEntity>> getAllLocations() async {
    try {
      final locations = await dataSource.getAllLocations();
      return locations.map(_modelToEntity).toList();
    } catch (e) {
      throw Exception('Failed to get all locations: $e');
    }
  }

  @override
  Future<LibraryLocationEntity?> getLocationById(String id) async {
    try {
      final location = await dataSource.getLocationById(id);
      return location != null ? _modelToEntity(location) : null;
    } catch (e) {
      throw Exception('Failed to get location by id: $e');
    }
  }

  @override
  Future<List<LibraryLocationEntity>> getNearbyLocations({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    try {
      final locations = await dataSource.getNearbyLocations(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
      );
      return locations.map(_modelToEntity).toList();
    } catch (e) {
      throw Exception('Failed to get nearby locations: $e');
    }
  }

  @override
  Future<List<LibraryLocationEntity>> searchLocations(String query) async {
    try {
      final locations = await dataSource.searchLocations(query);
      return locations.map(_modelToEntity).toList();
    } catch (e) {
      throw Exception('Failed to search locations: $e');
    }
  }

  @override
  Future<void> createLocation(LibraryLocationEntity location) async {
    try {
      await dataSource.createLocation(_entityToModel(location));
    } catch (e) {
      throw Exception('Failed to create location: $e');
    }
  }

  @override
  Future<void> updateLocation(LibraryLocationEntity location) async {
    try {
      await dataSource.updateLocation(_entityToModel(location));
    } catch (e) {
      throw Exception('Failed to update location: $e');
    }
  }

  @override
  Future<void> deleteLocation(String id) async {
    try {
      await dataSource.deleteLocation(id);
    } catch (e) {
      throw Exception('Failed to delete location: $e');
    }
  }
}
