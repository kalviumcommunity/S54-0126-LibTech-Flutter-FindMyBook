# Google Maps + Firestore Integration Guide

## 📋 Overview

This document explains the Google Maps SDK integration for the Smart Library Management app, designed specifically for developers transitioning from MERN to Flutter.

## 🏗️ Architecture: MERN → Flutter Translation

### Traditional MERN Stack Approach

```
┌─────────────────────────────────────────────────────┐
│ React Frontend                                      │
│  - Google Maps Component (react-google-maps)        │
│  - Redux Store (user location, libraries)           │
│  - React Router                                      │
└──────────────────┬──────────────────────────────────┘
                   │ (REST API calls)
┌──────────────────▼──────────────────────────────────┐
│ Express Backend                                     │
│  - GET /api/libraries (fetch all)                   │
│  - GET /api/libraries/nearby (geospatial query)     │
│  - PUT /api/libraries/:id (update)                  │
└──────────────────┬──────────────────────────────────┘
                   │ (MongoDB queries)
┌──────────────────▼──────────────────────────────────┐
│ MongoDB + Mongoose                                  │
│  - libraries collection with 2dsphere index         │
│  - Geospatial queries using $near operator         │
│  - GeoJSON format coordinates: [lng, lat]          │
└─────────────────────────────────────────────────────┘
```

### Flutter + Firebase Approach (This Project)

```
┌─────────────────────────────────────────────────────┐
│ Flutter Widget Tree                                 │
│  - LibraryLocationsMapPage (Google Maps)            │
│  - Riverpod Providers (state management)            │
│  - GoRouter/Custom Navigation                       │
└──────────────────┬──────────────────────────────────┘
                   │ (Direct Firestore + Cloud Functions)
┌──────────────────▼──────────────────────────────────┐
│ Firestore + Cloud Functions                        │
│  - getAllLocations() (Firestore query)              │
│  - getNearbyLocations() (Cloud Function)            │
│  - updateLibraryAvailability() (Cloud Function)    │
└──────────────────┬──────────────────────────────────┘
                   │ (Firestore queries with GeoPoint)
┌──────────────────▼──────────────────────────────────┐
│ Firestore Database                                  │
│  - library_locations collection with GeoPoint       │
│  - location field: GeoPoint(lat, lng)               │
│  - Bounding box + Haversine filtering               │
└─────────────────────────────────────────────────────┘
```

## 🔄 Component Mapping

| MERN | Flutter | Purpose |
|------|---------|---------|
| MongoDB `libraries` collection | Firestore `library_locations` collection | Store library data |
| GeoJSON coordinates `[lng, lat]` | Firestore `GeoPoint(lat, lng)` | Store location coordinates |
| Express `GET /api/libraries` | Firestore query via Datasource | Fetch all libraries |
| Express `GET /api/libraries/nearby` | Cloud Function `getNearbyLibraries` | Geospatial search |
| Redux Store | Riverpod StateProvider | Manage selected library/user location |
| React Query `useQuery` | Riverpod FutureProvider | Async data fetching |
| React Modal/Drawer | Flutter BottomSheet | Detail view for selected library |
| react-google-maps library | `google_maps_flutter` package | Render maps and markers |

## 📁 Project Structure

```
lib/src/features/library_locations/
├── models/
│   └── library_location.dart                 (↔ MongoDB document schema)
│
├── domain/                                    (Business Logic Layer)
│   ├── entities/
│   │   └── library_location_entity.dart      (Domain model, independent of DB)
│   ├── repositories/
│   │   └── library_location_repository.dart  (Abstract interface)
│   └── usecases/
│       └── library_location_usecases.dart    (Business operations)
│
├── data/                                      (Data Access Layer)
│   ├── datasources/
│   │   └── firestore_library_location_datasource.dart  (↔ Express API layer)
│   ├── repositories/
│   │   └── library_location_repository_impl.dart       (Repository implementation)
│   └── sample_library_data.dart               (↔ Seed data)
│
└── presentation/                              (UI Layer)
    ├── pages/
    │   └── library_locations_map_page.dart   (Main page)
    ├── widgets/
    │   ├── library_locations_map.dart        (Google Maps widget)
    │   ├── library_location_bottom_sheet.dart (Detail view)
    │   └── library_locations_search_bar.dart  (Search UI)
    └── controllers/
        └── library_locations_providers.dart  (↔ Redux store + selectors)
```

## 💾 Data Flow

### 1️⃣ Data Loading Flow

```
LibraryLocationsMapPage
    ↓ ref.watch(allLibraryLocationsProvider)
Riverpod FutureProvider
    ↓ calls usecase
GetAllLibraryLocationsUseCase
    ↓ calls repository.getAllLocations()
LibraryLocationRepository (interface)
    ↓ calls dataSource.getAllLocations()
FirestoreLibraryLocationDataSource
    ↓ Firestore.collection('library_locations').get()
Firebase Firestore
    ↓ returns List<QueryDocumentSnapshot>
LibraryLocation.fromSnapshot()
    ↓ converts to domain entity
LibraryLocationEntity
    ↓ returns to widget
LibraryLocationsMapPage (displays markers)
```

### 2️⃣ Geospatial Search Flow

```
User moves map → onCameraMove()
    ↓
ref.read(userLocationProvider.notifier).state = new location
    ↓
nearbyLocationsProvider watches userLocationProvider
    ↓
GetNearbyLibraryLocationsUseCase.call()
    ↓
Firestore bounding box query + Haversine filter
    ↓
Sorted list of libraries by distance
    ↓
GoogleMap updates with new markers
```

## 🔑 Key Concepts

### Firestore GeoPoint vs MongoDB GeoJSON

**MongoDB (MERN):**
```javascript
// Store as GeoJSON
db.collection('libraries').insertOne({
  name: "Central Library",
  location: {
    type: "Point",
    coordinates: [-73.9850, 40.7532]  // [lng, lat]
  }
});

// Query with $near
db.collection('libraries').find({
  location: {
    $near: {
      $geometry: { type: "Point", coordinates: [userLng, userLat] },
      $maxDistance: 10000  // 10km in meters
    }
  }
});
```

**Firestore (This Project):**
```dart
// Store as GeoPoint
db.collection('library_locations').doc('lib_001').set({
  name: "Central Library",
  location: GeoPoint(40.7532, -73.9850),  // (lat, lng) - DIFFERENT ORDER!
});

// Query with bounding box (Firestore limitation)
db.collection('library_locations')
  .where('location', >=, GeoPoint(latMin, lngMin))
  .where('location', <=, GeoPoint(latMax, lngMax))
  .get();

// Then filter by exact distance using Haversine algorithm
```

⚠️ **Important:** GeoPoint uses `(latitude, longitude)` while GeoJSON uses `[longitude, latitude]`

### Haversine Algorithm

Used to calculate great-circle distance between two points on Earth:

```dart
distance = 2 * R * arcsin(sqrt(a))

where:
  a = sin²(Δlat/2) + cos(lat1) × cos(lat2) × sin²(Δlng/2)
  R = Earth's radius (6371 km)
```

Implemented in `library_location.dart`:
```dart
double distanceTo(LibraryLocation other) {
  const earthRadius = 6371;
  // ... Haversine formula implementation
}
```

## 🚀 Setup Instructions

### 1. Android Configuration (AndroidManifest.xml)

```xml
<manifest>
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
  <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
  
  <application>
    <!-- Google Maps API Key -->
    <meta-data
      android:name="com.google.android.geo.API_KEY"
      android:value="YOUR_GOOGLE_MAPS_API_KEY" />
  </application>
</manifest>
```

### 2. iOS Configuration (Info.plist)

```xml
<dict>
  <key>NSLocationWhenInUseUsageDescription</key>
  <string>We need your location to find nearby libraries</string>
  <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
  <string>We need your location to find nearby libraries</string>
  <key>GMSApiKey</key>
  <string>YOUR_GOOGLE_MAPS_API_KEY</string>
</dict>
```

### 3. Seed Firestore with Sample Data

**Option A: Via Cloud Function**
```bash
curl -X POST https://[region]-[project].cloudfunctions.net/seedLibraryLocations
```

**Option B: Via Firebase Console**
1. Go to Firestore → Collections → library_locations
2. Add documents manually with GeoPoint fields

**Option C: Via Dart**
```dart
// In your app initialization
final dataSource = FirestoreLibraryLocationDataSource();
final sampleData = getSampleLibraryData('lib_001');
await dataSource.createLocation(LibraryLocation(
  id: 'lib_001',
  // ... other fields
  latitude: 40.7532,
  longitude: -73.9850,
));
```

### 4. Deploy Cloud Functions

```bash
cd functions
npm install
firebase deploy --only functions
```

## 📱 Usage Examples

### Navigate to Map Page

```dart
AppNavigator.to(const AppRoute(
  type: AppRouteType.libraryLocationsMap,
  path: '/library-locations',
));
```

### Filter Nearby Libraries (10km radius)

```dart
final nearby = await ref.read(getNearbyLocationsUseCaseProvider).call(
  latitude: 40.7532,
  longitude: -73.9850,
  radiusKm: 10,
);
```

### Search Libraries by Name

```dart
ref.read(searchQueryProvider.notifier).state = 'central';
final results = ref.watch(searchResultsProvider);
```

### Update Selected Library Availability

```dart
await FirebaseFirestore.instance
  .collection('library_locations')
  .doc('lib_001')
  .update({'availableBooks': 500});
```

## 🔍 Debugging Tips

### Check Firestore GeoPoint Format

```dart
// Print GeoPoint data
final doc = await FirebaseFirestore.instance
  .collection('library_locations')
  .doc('lib_001')
  .get();
  
final geoPoint = doc.data()?['location'] as GeoPoint?;
print('Lat: ${geoPoint?.latitude}, Lng: ${geoPoint?.longitude}');
```

### Test Nearby Search

```dart
// Manually test distance calculation
final lib1 = LibraryLocation(
  id: '1',
  latitude: 40.7532,
  longitude: -73.9850,
  // ...
);

final lib2 = LibraryLocation(
  id: '2',
  latitude: 40.7505,
  longitude: -73.9680,
  // ...
);

final distance = lib1.distanceTo(lib2);
print('Distance: ${distance.toStringAsFixed(2)} km');
```

## 🎯 Performance Optimization

### 1. Pagination for Large Datasets

```dart
// Fetch first page
final snapshot = await db.collection('library_locations')
  .orderBy('name')
  .limit(20)
  .get();

// Next page (use lastDocument.documentID)
final nextPage = await db.collection('library_locations')
  .orderBy('name')
  .startAfterDocument(lastDocument)
  .limit(20)
  .get();
```

### 2. Geospatial Indexing

For production with many libraries, use GeoFlutterFire:
```dart
import 'package:geo_flutter_fire/geo_flutter_fire.dart';

final geofire = GeoFlutterFire();
final geoCollection = geofire.collection(
  collectionRef: FirebaseFirestore.instance.collection('library_locations')
);

final nearby = await geoCollection.withinRadius(
  center: GeoFirePoint(40.7532, -73.9850),
  radiusInKilometers: 10,
);
```

### 3. Caching with Riverpod

Providers automatically cache data. Force refresh:
```dart
ref.refresh(allLibraryLocationsProvider);
```

## 📚 Additional Resources

- **Google Maps Flutter**: [pub.dev/packages/google_maps_flutter](https://pub.dev/packages/google_maps_flutter)
- **Firestore**: [firebase.google.com/docs/firestore](https://firebase.google.com/docs/firestore)
- **Riverpod**: [riverpod.dev](https://riverpod.dev)
- **Firebase Cloud Functions**: [firebase.google.com/docs/functions](https://firebase.google.com/docs/functions)
- **Geo-Spatial Queries**: [firebase.google.com/docs/firestore/solutions/geoqueries](https://firebase.google.com/docs/firestore/solutions/geoqueries)

## 🤝 Contributing

When extending this feature:

1. Keep domain layer independent of Firestore
2. Update both Android and iOS configurations
3. Test geospatial queries with multiple points
4. Update this guide with new features
5. Add unit/integration tests for new usecases

---

Created: 2026-02-16
Last Updated: 2026-02-16
