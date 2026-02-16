import '../entities/library_location_entity.dart';
import '../repositories/library_location_repository.dart';

/// UseCase: Get all library locations
/// 
/// MERN Comparison:
/// - Express controller action → service method
/// - Similar to: @Get('/') async getAll() { return this.libraryService.getAll(); }
class GetAllLibraryLocationsUseCase {
  final LibraryLocationRepository repository;

  GetAllLibraryLocationsUseCase({required this.repository});

  Future<List<LibraryLocationEntity>> call() => repository.getAllLocations();
}

/// UseCase: Get nearby library locations
/// 
/// MERN Comparison:
/// - Express endpoint: @Get('/nearby') getNearby(@Query() lat, lng, radius)
class GetNearbyLibraryLocationsUseCase {
  final LibraryLocationRepository repository;

  GetNearbyLibraryLocationsUseCase({required this.repository});

  Future<List<LibraryLocationEntity>> call({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) =>
      repository.getNearbyLocations(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
      );
}

/// UseCase: Search library locations
/// 
/// MERN Comparison:
/// - Express endpoint: @Get('/search') search(@Query('q') query: string)
class SearchLibraryLocationsUseCase {
  final LibraryLocationRepository repository;

  SearchLibraryLocationsUseCase({required this.repository});

  Future<List<LibraryLocationEntity>> call(String query) =>
      repository.searchLocations(query);
}

/// UseCase: Get library location by ID
/// 
/// MERN Comparison:
/// - Express endpoint: @Get('/:id') getById(@Param('id') id: string)
class GetLibraryLocationByIdUseCase {
  final LibraryLocationRepository repository;

  GetLibraryLocationByIdUseCase({required this.repository});

  Future<LibraryLocationEntity?> call(String id) =>
      repository.getLocationById(id);
}
