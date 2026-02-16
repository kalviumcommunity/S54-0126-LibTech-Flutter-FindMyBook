import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/library_location_entity.dart';
import '../../models/library_location.dart';

/// Google Maps Widget with Library Markers
/// 
/// MERN Comparison:
/// - React component rendering Google Maps with custom markers
/// - Similar to: <GoogleMap center={userLocation} markers={libraries.map(...)} />
/// - Uses google_maps_flutter_android/ios platform channels
class LibraryLocationsMap extends ConsumerStatefulWidget {
  final List<LibraryLocationEntity> locations;
  final LibraryLocationEntity? selectedLocation;
  final Function(LibraryLocationEntity) onMarkerTap;
  final Function(({double lat, double lng})?) onLocationChanged;
  final bool showUserLocation;

  const LibraryLocationsMap({
    Key? key,
    required this.locations,
    this.selectedLocation,
    required this.onMarkerTap,
    required this.onLocationChanged,
    this.showUserLocation = true,
  }) : super(key: key);

  @override
  ConsumerState<LibraryLocationsMap> createState() =>
      _LibraryLocationsMapState();
}

class _LibraryLocationsMapState extends ConsumerState<LibraryLocationsMap> {
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  late CameraPosition _initialCameraPosition;

  @override
  void initState() {
    super.initState();
    _initializeMapMarkers();
    
    // Default center (San Francisco) - replace with user's actual location
    _initialCameraPosition = const CameraPosition(
      target: LatLng(37.7749, -122.4194),
      zoom: 12,
    );
  }

  @override
  void didUpdateWidget(LibraryLocationsMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.locations != widget.locations ||
        oldWidget.selectedLocation != widget.selectedLocation) {
      _initializeMapMarkers();
    }
  }

  /// Initialize markers for all library locations
  void _initializeMapMarkers() {
    _markers.clear();
    
    for (final location in widget.locations) {
      final isSelected = widget.selectedLocation?.id == location.id;
      
      _markers.add(
        Marker(
          markerId: MarkerId(location.id),
          position: LatLng(location.latitude, location.longitude),
          infoWindow: InfoWindow(
            title: location.name,
            snippet: '${location.availableBooks} books available',
            onTap: () => widget.onMarkerTap(location),
          ),
          // Highlight selected marker with different color
          icon: isSelected
              ? BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen,
                )
              : BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue,
                ),
          onMarkerTap: () => widget.onMarkerTap(location),
        ),
      );
    }

    // Add search radius circle if user location is available
    if (widget.locations.isNotEmpty) {
      final firstLocation = widget.locations.first;
      _circles.add(
        Circle(
          circleId: const CircleId('search_radius'),
          center: LatLng(firstLocation.latitude, firstLocation.longitude),
          radius: 10000, // 10 km radius
          fillColor: Colors.blue.withOpacity(0.1),
          strokeColor: Colors.blue.withOpacity(0.5),
          strokeWidth: 2,
        ),
      );
    }

    setState(() {});
  }

  /// Animate camera to selected location
  void _animateToLocation(LibraryLocationEntity location) {
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(location.latitude, location.longitude),
          zoom: 15,
        ),
      ),
    );
  }

  /// On camera movement, update user location
  void _onCameraMove(CameraPosition position) {
    widget.onLocationChanged((
      lat: position.target.latitude,
      lng: position.target.longitude,
    ));
  }

  @override
  Widget build(BuildContext context) {
    // Animate to selected location when it changes
    if (widget.selectedLocation != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _animateToLocation(widget.selectedLocation!);
      });
    }

    return GoogleMap(
      onMapCreated: (controller) => _mapController = controller,
      initialCameraPosition: _initialCameraPosition,
      markers: _markers,
      circles: _circles,
      onCameraMove: _onCameraMove,
      myLocationEnabled: widget.showUserLocation,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: true,
      mapToolbarEnabled: true,
      compassEnabled: true,
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
