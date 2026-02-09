/*
  Seed Firestore with sample book data.

  Usage:
    - Install dependencies: run `npm install firebase-admin` in this folder
    - Ensure credentials: set `GOOGLE_APPLICATION_CREDENTIALS` to a service account JSON
      or run against the emulator by setting `FIRESTORE_EMULATOR_HOST`.
    - Run: `node seed_firestore.js`
*/

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

const samplePath = path.join(__dirname, 'sample_books.json');
const raw = fs.readFileSync(samplePath, 'utf8');
const books = JSON.parse(raw);

function init() {
  try {
    admin.initializeApp();
  } catch (e) {
    // already initialized in some environments
  }

  return admin.firestore();
}

async function seed() {
  const db = init();
  const batch = db.batch();
  const col = db.collection('books');

  books.forEach((b) => {
    const docRef = col.doc();
    const payload = Object.assign({}, b, {
      publishedAt: b.publishedAt ? new Date(b.publishedAt) : null,
    });
    batch.set(docRef, payload);
  });

  await batch.commit();
  console.log(`Seeded ${books.length} books to 'books' collection.`);
  process.exit(0);
}

seed().catch((err) => {
  console.error(err);
  process.exit(1);
});
