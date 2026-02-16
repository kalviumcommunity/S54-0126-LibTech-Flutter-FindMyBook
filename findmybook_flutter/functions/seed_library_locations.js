/**
 * Cloud Function: Seed Library Locations
 * 
 * MERN Comparison:
 * - Express endpoint: POST /api/admin/seed
 * - MongoDB: db.collection('libraries').insertMany([...])
 * 
 * Purpose:
 * - Populate Firestore with sample library locations
 * - Create GeoPoint fields for map-based queries
 * - Initialize default data for development/testing
 * 
 * Deploy: firebase deploy --only functions:seedLibraryLocations
 * Invoke: curl -X POST https://[region]-[project].cloudfunctions.net/seedLibraryLocations
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize Firebase if not already initialized in index.js
if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

const SAMPLE_LIBRARIES = [
  {
    id: 'lib_001',
    name: 'Central Public Library',
    address: '475 Fifth Avenue, New York, NY 10018',
    location: new admin.firestore.GeoPoint(40.7532, -73.9850),
    phone: '+1 (212) 340-0849',
    email: 'contact@centrallibrary.nyc',
    website: 'https://www.nypl.org/locations/branches/schwarzman-building',
    totalBooks: 2500000,
    availableBooks: 1250000,
    openingHours: [
      'Mon-Sat: 9:00 AM - 6:00 PM',
      'Sun: 11:00 AM - 5:00 PM',
    ],
    isOpen: true,
    rating: 4.8,
  },
  {
    id: 'lib_002',
    name: 'Midtown Library',
    address: '529 East 42nd Street, New York, NY 10017',
    location: new admin.firestore.GeoPoint(40.7505, -73.9680),
    phone: '+1 (212) 883-1234',
    email: 'contact@midtownlibrary.nyc',
    website: 'https://www.nypl.org/locations/branches/midtown',
    totalBooks: 1500000,
    availableBooks: 850000,
    openingHours: [
      'Mon-Fri: 10:00 AM - 8:00 PM',
      'Sat: 10:00 AM - 5:00 PM',
      'Sun: Closed',
    ],
    isOpen: true,
    rating: 4.6,
  },
  {
    id: 'lib_003',
    name: 'Downtown Community Library',
    address: '20 West Houston Street, New York, NY 10012',
    location: new admin.firestore.GeoPoint(40.7237, -74.0012),
    phone: '+1 (212) 674-0947',
    email: 'contact@downtownlibrary.nyc',
    website: 'https://www.nypl.org/locations/branches/houston',
    totalBooks: 1200000,
    availableBooks: 600000,
    openingHours: [
      'Mon-Thu: 9:00 AM - 9:00 PM',
      'Fri-Sat: 9:00 AM - 5:00 PM',
      'Sun: 11:00 AM - 5:00 PM',
    ],
    isOpen: true,
    rating: 4.5,
  },
  {
    id: 'lib_004',
    name: 'East Side Library',
    address: '408 East 59th Street, New York, NY 10022',
    location: new admin.firestore.GeoPoint(40.7607, -73.9631),
    phone: '+1 (212) 744-0972',
    email: 'contact@eastlibrary.nyc',
    website: 'https://www.nypl.org/locations/branches/east-side',
    totalBooks: 900000,
    availableBooks: 450000,
    openingHours: [
      'Mon-Sat: 10:00 AM - 6:00 PM',
      'Sun: 1:00 PM - 5:00 PM',
    ],
    isOpen: false,
    rating: 4.3,
  },
  {
    id: 'lib_005',
    name: 'West Village Library',
    address: '93 Horatio Street, New York, NY 10014',
    location: new admin.firestore.GeoPoint(40.7355, -74.0063),
    phone: '+1 (212) 243-6876',
    email: 'contact@westlibrary.nyc',
    website: 'https://www.nypl.org/locations/branches/west-village',
    totalBooks: 800000,
    availableBooks: 400000,
    openingHours: [
      'Mon-Fri: 9:00 AM - 7:00 PM',
      'Sat-Sun: 10:00 AM - 4:00 PM',
    ],
    isOpen: true,
    rating: 4.7,
  },
];

/**
 * HTTP Cloud Function to seed library locations
 * 
 * Request: POST https://[url]/seedLibraryLocations
 * 
 * Response:
 * {
 *   "success": true,
 *   "message": "5 libraries seeded successfully",
 *   "count": 5,
 *   "libraries": [...]
 * }
 */
exports.seedLibraryLocations = functions
  .region('us-central1')
  .https.onRequest(async (request, response) => {
    // Enable CORS
    response.set('Access-Control-Allow-Origin', '*');
    response.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
    response.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');

    // Handle CORS preflight
    if (request.method === 'OPTIONS') {
      response.status(200).send('');
      return;
    }

    // Only allow POST requests
    if (request.method !== 'POST') {
      response.status(405).json({ error: 'Method Not Allowed. Use POST.' });
      return;
    }

    try {
      console.log('Starting library locations seeding...');

      // Clear existing data (optional - remove for production)
      const existingDocs = await db.collection('library_locations').get();
      for (const doc of existingDocs.docs) {
        await doc.ref.delete();
      }
      console.log(`Deleted ${existingDocs.docs.length} existing libraries`);

      // Add new sample data with timestamps
      const now = admin.firestore.Timestamp.now();
      const batch = db.batch();

      for (const library of SAMPLE_LIBRARIES) {
        const docRef = db.collection('library_locations').doc(library.id);
        batch.set(docRef, {
          ...library,
          createdAt: now,
          updatedAt: now,
        });
      }

      // Commit batch write
      await batch.commit();
      console.log(`Successfully seeded ${SAMPLE_LIBRARIES.length} libraries`);

      response.status(200).json({
        success: true,
        message: `${SAMPLE_LIBRARIES.length} libraries seeded successfully`,
        count: SAMPLE_LIBRARIES.length,
        libraries: SAMPLE_LIBRARIES.map(lib => ({
          id: lib.id,
          name: lib.name,
          address: lib.address,
        })),
      });
    } catch (error) {
      console.error('Error seeding libraries:', error);
      response.status(500).json({
        success: false,
        error: error.message,
      });
    }
  });

/**
 * Update library availability (simulated)
 * 
 * MERN Comparison:
 * - Express endpoint: PUT /api/libraries/:id
 * - MongoDB: db.collection('libraries').updateOne({ _id }, { ... })
 */
exports.updateLibraryAvailability = functions
  .region('us-central1')
  .https.onRequest(async (request, response) => {
    response.set('Access-Control-Allow-Origin', '*');

    const { libraryId, availableBooks } = request.body;

    if (!libraryId || availableBooks === undefined) {
      response.status(400).json({
        error: 'Missing required fields: libraryId, availableBooks',
      });
      return;
    }

    try {
      await db.collection('library_locations').doc(libraryId).update({
        availableBooks: availableBooks,
        updatedAt: admin.firestore.Timestamp.now(),
      });

      response.status(200).json({
        success: true,
        message: `Library ${libraryId} updated`,
      });
    } catch (error) {
      response.status(500).json({
        success: false,
        error: error.message,
      });
    }
  });

/**
 * Get nearby libraries (Firestore geospatial query)
 * 
 * MERN Comparison:
 * - Express endpoint: GET /api/libraries/nearby?lat=40.7&lng=-74.0&radius=5
 * - MongoDB: db.collection('libraries').find({ location: { $near: {...} } })
 */
exports.getNearbyLibraries = functions
  .region('us-central1')
  .https.onRequest(async (request, response) => {
    response.set('Access-Control-Allow-Origin', '*');

    const { latitude, longitude, radiusKm } = request.query;

    if (!latitude || !longitude || !radiusKm) {
      response.status(400).json({
        error: 'Missing parameters: latitude, longitude, radiusKm',
      });
      return;
    }

    try {
      const lat = parseFloat(latitude);
      const lng = parseFloat(longitude);
      const radius = parseFloat(radiusKm);

      // Approximate bounding box query
      // Note: Firestore doesn't have native geo-distance queries
      // For production: use GeoFlutterFire or Algolia
      const latDelta = radius / 111;
      const lngDelta = radius / (111 * Math.cos((lat * Math.PI) / 180));

      const query = await db
        .collection('library_locations')
        .where(
          'location',
          '>=',
          new admin.firestore.GeoPoint(lat - latDelta, lng - lngDelta)
        )
        .where(
          'location',
          '<=',
          new admin.firestore.GeoPoint(lat + latDelta, lng + lngDelta)
        )
        .get();

      const libraries = query.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
      }));

      response.status(200).json({
        success: true,
        count: libraries.length,
        libraries: libraries,
      });
    } catch (error) {
      response.status(500).json({
        success: false,
        error: error.message,
      });
    }
  });
