import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";

import "../../../shared/widgets/empty_state.dart";
import "../../../shared/widgets/error_state.dart";
import "libraries_providers.dart";

class LibrariesMapPage extends ConsumerWidget {
  const LibrariesMapPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final librariesAsync = ref.watch(librariesStreamProvider);
    return Scaffold(
      appBar: AppBar(title: const Text("Libraries Map")),
      body: librariesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(librariesStreamProvider),
        ),
        data: (libraries) {
          if (libraries.isEmpty) {
            return const EmptyState(
              icon: Icons.map_outlined,
              title: "No libraries found",
              subtitle: "Add libraries collection to Firestore to display markers.",
            );
          }

          final markers = libraries
              .where((lib) => lib.latitude != 0 || lib.longitude != 0)
              .map(
                (library) => Marker(
                  markerId: MarkerId(library.id),
                  position: LatLng(library.latitude, library.longitude),
                  infoWindow: InfoWindow(title: library.name),
                  onTap: () => _showLibrarySheet(context, library.name, library.address),
                ),
              )
              .toSet();

          final first = libraries.first;
          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(first.latitude, first.longitude),
              zoom: 12,
            ),
            myLocationButtonEnabled: false,
            markers: markers,
          );
        },
      ),
    );
  }

  void _showLibrarySheet(BuildContext context, String name, String address) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(address),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
