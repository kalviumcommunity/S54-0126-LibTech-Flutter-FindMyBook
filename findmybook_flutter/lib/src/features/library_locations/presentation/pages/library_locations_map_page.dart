import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/library_location_entity.dart';
import '../controllers/library_locations_providers.dart';
import '../widgets/library_locations_map.dart';
import '../widgets/library_location_bottom_sheet.dart';
import '../widgets/library_locations_search_bar.dart';

/// Main Library Locations Map Page
/// 
/// MERN Comparison:
/// - React main page component combining Map, Sidebar, and Modal
/// - Similar to: <MapPage><Map /><Sidebar /><DetailModal /></MapPage>
class LibraryLocationsMapPage extends ConsumerStatefulWidget {
  const LibraryLocationsMapPage({Key? key}) : super(key: key);

  @override
  ConsumerState<LibraryLocationsMapPage> createState() =>
      _LibraryLocationsMapPageState();
}

class _LibraryLocationsMapPageState
    extends ConsumerState<LibraryLocationsMapPage> {
  /// Handle marker tap
  void _onMarkerTap(LibraryLocationEntity location) {
    ref.read(selectedLocationProvider.notifier).state = location.id;
  }

  /// Handle map camera movement
  void _onLocationChanged(({double lat, double lng})? location) {
    if (location != null) {
      ref.read(userLocationProvider.notifier).state = location;
    }
  }

  /// Handle navigate button tap
  void _onNavigate(LibraryLocationEntity location) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigate to ${location.name}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Close bottom sheet
  void _closeBottomSheet() {
    ref.read(selectedLocationProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    // Watch all necessary state
    final allLocations = ref.watch(allLibraryLocationsProvider);
    final searchResults = ref.watch(searchResultsProvider);
    final selectedId = ref.watch(selectedLocationProvider);
    final selectedDetails = ref.watch(selectedLocationDetailsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find My Library'),
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: allLocations.when(
        // Loading state
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),

        // Error state
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: ${error.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(allLibraryLocationsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),

        // Success state
        data: (locations) {
          // Determine which locations to display (all or search results)
          final displayLocations = ref.watch(searchQueryProvider).isEmpty
              ? locations
              : searchResults.when(
            data: (results) => results,
            loading: () => locations,
            error: (_, __) => locations,
          );

          return Stack(
            children: [
              // Google Maps Background
              LibraryLocationsMap(
                locations: displayLocations,
                selectedLocation: selectedDetails,
                onMarkerTap: _onMarkerTap,
                onLocationChanged: _onLocationChanged,
                showUserLocation: true,
              ),

              // Search Bar at top
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LibraryLocationsSearchBar(
                  onSearchChanged: (_) {
                    // Perform search - the provider already updates
                  },
                ),
              ),

              // Results Counter (when searching)
              if (ref.watch(searchQueryProvider).isNotEmpty)
                Positioned(
                  bottom: 20 + 350, // Above bottom sheet or map bottom
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Text(
                      'Found ${displayLocations.length} libraries',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

              // Bottom Sheet (Library Details)
              LibraryLocationBottomSheet(
                location: selectedDetails,
                onClose: _closeBottomSheet,
                onNavigate: _onNavigate,
              ),
            ],
          );
        },
      ),
    );
  }
}
