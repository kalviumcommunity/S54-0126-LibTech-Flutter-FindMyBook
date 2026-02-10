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
