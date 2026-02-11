const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.firestore();

// When a loan is created, mark the book as unavailable.
exports.onLoanCreated = functions.firestore
  .document('loans/{loanId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    if (!data) return null;
    const bookId = data.bookId;
    if (!bookId) return null;

    const bookRef = db.collection('books').doc(bookId);
    return bookRef.update({ available: false }).catch((err) => {
      console.error('Failed to mark book unavailable on loan create', err);
      return null;
    });
  });

// When a loan is updated and marked returned, set book available = true.
exports.onLoanUpdated = functions.firestore
  .document('loans/{loanId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data() || {};
    const after = change.after.data() || {};

    // If returned changed from false -> true, make book available again
    const wasReturned = before.returned === true;
    const isReturned = after.returned === true;
    if (!wasReturned && isReturned && after.bookId) {
      const bookRef = db.collection('books').doc(after.bookId);
      return bookRef.update({ available: true }).catch((err) => {
        console.error('Failed to mark book available on loan return', err);
        return null;
      });
    }

    return null;
  });

/**
 * Atomic Reservation Function
 * 
 * MERN Comparison:
 * - vs Express Middleware: In Express, you'd use a middleware like `authMiddleware` to check JWT.
 *   In Cloud Functions `onCall`, `context.auth` is automatically populated by Firebase.
 * - vs MongoDB Transaction: MongoDB requires a session for transactions. Firestore transactions
 *   are handled via `db.runTransaction`.
 * - Expiry: TTL in MongoDB is often done via TTL indexes. Here we set an `expiresAt` field
 *   which the client or a scheduled function can check.
 */
exports.reserveBook = functions.https.onCall(async (data, context) => {
  // 1. Auth Check (Middleware Equivalent)
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be logged in.');
  }

  const { bookId } = data;
  const userId = context.auth.uid;

  if (!bookId) {
    throw new functions.https.HttpsError('invalid-argument', 'bookId is required.');
  }

  // 2. Atomic Transaction
  try {
    return await db.runTransaction(async (transaction) => {
      const bookRef = db.collection('books').doc(bookId);
      const bookSnap = await transaction.get(bookRef);

      if (!bookSnap.exists) {
        throw new functions.https.HttpsError('not-found', 'Book not found.');
      }

      const bookData = bookSnap.data();
      
      // Atomic availability check
      if (bookData.available === false) {
        throw new functions.https.HttpsError('failed-precondition', 'Book is currently unavailable.');
      }

      // 3. Create Reservation document
      const reservationRef = db.collection('reservations').doc();
      const expiryDate = new Date();
      expiryDate.setHours(expiryDate.getHours() + 24); // 24 hour expiry

      transaction.set(reservationRef, {
        userId,
        bookId,
        status: 'active',
        reservedAt: admin.firestore.FieldValue.serverTimestamp(),
        expiresAt: admin.firestore.Timestamp.fromDate(expiryDate),
      });

      // 4. Mark book as reserved
      transaction.update(bookRef, { 
        available: false,
        currentReservationId: reservationRef.id 
      });

      return { 
        success: true, 
        reservationId: reservationRef.id,
        expiresAt: expiryDate.toISOString() 
      };
    });
  } catch (error) {
    console.error('Reservation failed:', error);
    if (error instanceof functions.https.HttpsError) throw error;
    throw new functions.https.HttpsError('internal', 'An error occurred during reservation.');
  }
});
