/// Sample library locations data for Firestore seeding
/// 
/// MERN Comparison:
/// - Seed file for MongoDB database
/// - Similar to: db/seeds/libraries.seed.ts
/// - Format: Firestore-compatible JSON with GeoPoint as { latitude, longitude }
const Map<String, dynamic> SAMPLE_LIBRARIES = {
  'lib_001': {
    'name': 'Central Public Library',
    'address': '475 Fifth Avenue, New York, NY 10018',
    'location': {
      'latitude': 40.7532,
      'longitude': -73.9850,
    },
    'phone': '+1 (212) 340-0849',
    'email': 'contact@centrallibrary.nyc',
    'website': 'https://www.nypl.org/locations/branches/schwarzman-building',
    'totalBooks': 2500000,
    'availableBooks': 1250000,
    'openingHours': [
      'Mon-Sat: 9:00 AM - 6:00 PM',
      'Sun: 11:00 AM - 5:00 PM',
    ],
    'isOpen': true,
    'rating': 4.8,
  },
  'lib_002': {
    'name': 'Midtown Library',
    'address': '529 East 42nd Street, New York, NY 10017',
    'location': {
      'latitude': 40.7505,
      'longitude': -73.9680,
    },
    'phone': '+1 (212) 883-1234',
    'email': 'contact@midtownlibrary.nyc',
    'website': 'https://www.nypl.org/locations/branches/midtown',
    'totalBooks': 1500000,
    'availableBooks': 850000,
    'openingHours': [
      'Mon-Fri: 10:00 AM - 8:00 PM',
      'Sat: 10:00 AM - 5:00 PM',
      'Sun: Closed',
    ],
    'isOpen': true,
    'rating': 4.6,
  },
  'lib_003': {
    'name': 'Downtown Community Library',
    'address': '20 West Houston Street, New York, NY 10012',
    'location': {
      'latitude': 40.7237,
      'longitude': -74.0012,
    },
    'phone': '+1 (212) 674-0947',
    'email': 'contact@downtownlibrary.nyc',
    'website': 'https://www.nypl.org/locations/branches/houston',
    'totalBooks': 1200000,
    'availableBooks': 600000,
    'openingHours': [
      'Mon-Thu: 9:00 AM - 9:00 PM',
      'Fri-Sat: 9:00 AM - 5:00 PM',
      'Sun: 11:00 AM - 5:00 PM',
    ],
    'isOpen': true,
    'rating': 4.5,
  },
  'lib_004': {
    'name': 'East Side Library',
    'address': '408 East 59th Street, New York, NY 10022',
    'location': {
      'latitude': 40.7607,
      'longitude': -73.9631,
    },
    'phone': '+1 (212) 744-0972',
    'email': 'contact@eastlibrary.nyc',
    'website': 'https://www.nypl.org/locations/branches/east-side',
    'totalBooks': 900000,
    'availableBooks': 450000,
    'openingHours': [
      'Mon-Sat: 10:00 AM - 6:00 PM',
      'Sun: 1:00 PM - 5:00 PM',
    ],
    'isOpen': false,
    'rating': 4.3,
  },
  'lib_005': {
    'name': 'West Village Library',
    'address': '93 Horatio Street, New York, NY 10014',
    'location': {
      'latitude': 40.7355,
      'longitude': -74.0063,
    },
    'phone': '+1 (212) 243-6876',
    'email': 'contact@westlibrary.nyc',
    'website': 'https://www.nypl.org/locations/branches/west-village',
    'totalBooks': 800000,
    'availableBooks': 400000,
    'openingHours': [
      'Mon-Fri: 9:00 AM - 7:00 PM',
      'Sat-Sun: 10:00 AM - 4:00 PM',
    ],
    'isOpen': true,
    'rating': 4.7,
  },
};

/// Helper function to get sample library data
/// Returns data formatted for Firestore (with Timestamp objects in real app)
Map<String, dynamic> getSampleLibraryData(String libraryKey) {
  final data = SAMPLE_LIBRARIES[libraryKey];
  if (data == null) return {};

  return {
    ...data,
    'createdAt': DateTime.now().toIso8601String(),
    'updatedAt': DateTime.now().toIso8601String(),
  };
}

/// Get all sample libraries as list
List<Map<String, dynamic>> getAllSampleLibraries() {
  return SAMPLE_LIBRARIES.entries
      .map((entry) => {
        'id': entry.key,
        ...entry.value,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      })
      .toList();
}
