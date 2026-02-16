import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/datasources/firestore_library_location_datasource.dart';
import '../data/repositories/library_location_repository_impl.dart';
import '../domain/repositories/library_location_repository.dart';
import '../domain/usecases/library_location_usecases.dart';

/// MERN Comparison:
/// - Riverpod Providers ↔ Redux Store + Selectors
/// - Similar to: const libraryLocations = useSelector(state => state.libraries);
/// - Or: const { data } = useQuery('libraries', fetchLibraries);
///
/// Key Riverpod Concepts:
/// - Provider: read-only state
/// - StateProvider: mutable state
/// - FutureProvider: for async operations (like React Query)
/// - StateNotifierProvider: for complex state management

// ============================================================================
// Data Layer Providers
// ============================================================================

/// Firestore instance provider
final firestoreProvider = Provider((ref) => FirebaseFirestore.instance);

/// LibraryLocation DataSource provider
final libraryLocationDataSourceProvider = Provider((ref) {
  final firestore = ref.watch(firestoreProvider);
  return FirestoreLibraryLocationDataSource(firestore: firestore);
});

/// LibraryLocation Repository provider
final libraryLocationRepositoryProvider = Provider<LibraryLocationRepository>((ref) {
  final dataSource = ref.watch(libraryLocationDataSourceProvider);
  return LibraryLocationRepositoryImpl(dataSource: dataSource);
});

// ============================================================================
// UseCase Providers
// ============================================================================

final getAllLocationsUseCaseProvider = Provider((ref) {
  final repository = ref.watch(libraryLocationRepositoryProvider);
  return GetAllLibraryLocationsUseCase(repository: repository);
});

final getNearbyLocationsUseCaseProvider = Provider((ref) {
  final repository = ref.watch(libraryLocationRepositoryProvider);
  return GetNearbyLibraryLocationsUseCase(repository: repository);
});

final searchLocationsUseCaseProvider = Provider((ref) {
  final repository = ref.watch(libraryLocationRepositoryProvider);
  return SearchLibraryLocationsUseCase(repository: repository);
});

final getLocationByIdUseCaseProvider = Provider((ref) {
  final repository = ref.watch(libraryLocationRepositoryProvider);
  return GetLibraryLocationByIdUseCase(repository: repository);
});

// ============================================================================
// Data Providers (State Management)
// ============================================================================

/// Fetch all library locations
/// 
/// MERN Equivalent: useQuery('getAllLibraries', fetchLibraries)
/// Automatically refetches, caches, and handles loading/error states
final allLibraryLocationsProvider = FutureProvider((ref) async {
  final useCase = ref.watch(getAllLocationsUseCaseProvider);
  return useCase();
});

/// Search query state
/// 
/// MERN Equivalent: useState<string>(searchQuery)
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Search results based on query
/// 
/// MERN Equivalent: useMemo(() => filterLibraries(allLibraries, query), [allLibraries, query])
final searchResultsProvider = FutureProvider((ref) async {
  final query = ref.watch(searchQueryProvider);
  
  if (query.isEmpty) {
    return <Object>[]; // Return empty list if no query
  }
  
  final useCase = ref.watch(searchLocationsUseCaseProvider);
  return useCase(query);
});

/// User's current location state
/// 
/// MERN Equivalent: useState<{ lat: number; lng: number } | null>(null)
final userLocationProvider = StateProvider<({double lat, double lng})?>((ref) => null);

/// Nearby locations based on user's current position
/// 
/// MERN Equivalent: useMemo with useEffect to refetch when location changes
final nearbyLocationsProvider = FutureProvider((ref) async {
  final userLocation = ref.watch(userLocationProvider);
  
  if (userLocation == null) {
    return <Object>[]; // Return empty if no location
  }
  
  final useCase = ref.watch(getNearbyLocationsUseCaseProvider);
  return useCase(
    latitude: userLocation.lat,
    longitude: userLocation.lng,
    radiusKm: 10, // Default to 10 km radius
  );
});

/// Selected library location for detail view
/// 
/// MERN Equivalent: useState<ILibrary | null>(selectedLibrary)
final selectedLocationProvider = StateProvider<String?>((ref) => null);

/// Get details of selected library
/// 
/// MERN Equivalent: const selectedLibraryDetails = useMemo(() => allLibraries.find(lib => lib.id === selectedId), [selectedId])
final selectedLocationDetailsProvider = FutureProvider((ref) async {
  final selectedId = ref.watch(selectedLocationProvider);
  
  if (selectedId == null) {
    return null;
  }
  
  final useCase = ref.watch(getLocationByIdUseCaseProvider);
  return useCase(selectedId);
});

/// Radius filter for nearby search (in km)
/// 
/// MERN Equivalent: useState<number>(searchRadius)
final searchRadiusProvider = StateProvider<double>((ref) => 10);

/// Filtered nearby locations based on user's preferred radius
/// 
/// MERN Equivalent: useMemo(() => nearbyLocations.filter(loc => distance <= radius), [nearbyLocations, radius])
final filteredNearbyLocationsProvider = FutureProvider((ref) async {
  final userLocation = ref.watch(userLocationProvider);
  final radius = ref.watch(searchRadiusProvider);
  
  if (userLocation == null) {
    return <Object>[];
  }
  
  final useCase = ref.watch(getNearbyLocationsUseCaseProvider);
  return useCase(
    latitude: userLocation.lat,
    longitude: userLocation.lng,
    radiusKm: radius,
  );
});
