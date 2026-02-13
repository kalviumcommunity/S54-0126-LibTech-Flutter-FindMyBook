/// Cloud Functions for Smart Library Backend
/// 
/// This file contains JavaScript (Node.js) examples of Cloud Functions
/// that run on Firebase backend (↔ Express.js routes + controllers)
/// 
/// Deploy these using: firebase deploy --only functions
/// 
/// MERN Comparison:
/// - Cloud Function ↔ Express route handler
/// - Firestore trigger ↔ MongoDB change streams + webhooks
/// - onCall() ↔ Express POST/GET route
/// - imports from 'firebase-functions' ↔ Express middleware stack

/**
 * FILE: functions/index.js
 * 
 * To use these functions:
 * 1. Create a Node.js project in functions/
 * 2. Run: npm install firebase-functions firebase-admin
 * 3. Add these functions to index.js
 * 4. Deploy: firebase deploy --only functions
 */

// ============================================================================
// 1. Restrict File Read/Write (Security Rule - NOT a Cloud Function)
// ============================================================================

/**
 * Firestore Security Rule (in firestore.rules):
 * 
 * rules_version = '2';
 * service cloud.firestore {
 *   match /databases/{database}/documents {
 *     // Users can only read/write their own data
 *     match /users/{userId} {
 *       allow read, write: if request.auth.uid == userId;
 *     }
 *     
 *     // Public books collection (read-only for users)
 *     match /books/{document=**} {
 *       allow read: if request.auth != null;
 *       allow write: if request.auth.token.role == 'admin';
 *     }
 *     
 *     // Borrowed books - users can only see their own
 *     match /users/{userId}/borrowedBooks/{document=**} {
 *       allow read, create, update, delete: if request.auth.uid == userId;
 *     }
 *   }
 * }
 */

// ============================================================================
// 2. Callable Cloud Function - Borrow Book
// ============================================================================

/**
 * MERN Equivalent:
 * 
 * Express Route:
 * POST /api/books/:bookId/borrow
 * 
 * async function borrowBook(req, res) {
 *   const { bookId } = req.params;
 *   const userId = req.user.id; // From auth middleware
 *   
 *   try {
 *     // Check if book is available
 *     const book = await Book.findById(bookId);
 *     if (!book.available) {
 *       return res.status(409).json({
 *         error: 'Book unavailable',
 *         message: 'Book has been reserved or borrowed'
 *       });
 *     }
 *     
 *     // Create borrow record
 *     const borrow = await Borrow.create({
 *       userId,
 *       bookId,
 *       borrowDate: new Date(),
 *       dueDate: new Date(Date.now() + 14 * 24 * 60 * 60 * 1000)
 *     });
 *     
 *     // Update book availability
 *     await Book.updateOne(
 *       { _id: bookId },
 *       { available: false, borrowedBy: userId }
 *     );
 *     
 *     res.json({
 *       success: true,
 *       borrowRecord: borrow
 *     });
 *   } catch (error) {
 *     res.status(500).json({ error: error.message });
 *   }
 * }
 */

/**
 * Firebase Cloud Function Equivalent:
 * 
 * const functions = require('firebase-functions');
 * const admin = require('firebase-admin');
 * 
 * const db = admin.firestore();
 * 
 * exports.borrowBook = functions.https.onCall(async (data, context) => {
 *   // Security: Check if user is authenticated
 *   if (!context.auth) {
 *     throw new functions.https.HttpsError(
 *       'unauthenticated',
 *       'User must be logged in'
 *     );
 *   }
 *   
 *   const { bookId } = data;
 *   const userId = context.auth.uid;
 *   
 *   try {
 *     // Firestore Optimization: Use transaction for atomic operation
 *     // ↔ MongoDB transaction (4.0+)
 *     const result = await db.runTransaction(async (transaction) => {
 *       // Step 1: Check if book is available
 *       const bookRef = db.collection('books').doc(bookId);
 *       const bookDoc = await transaction.get(bookRef);
 *       
 *       if (!bookDoc.exists) {
 *         throw new functions.https.HttpsError(
 *           'not-found',
 *           'Book not found'
 *         );
 *       }
 *       
 *       const book = bookDoc.data();
 *       if (!book.available || book.borrowedBy) {
 *         throw new functions.https.HttpsError(
 *           'unavailable',
 *           'Book is not available for borrowing'
 *         );
 *       }
 *       
 *       // Step 2: Create borrow record
 *       // Firestore Strategy: Store in user subdocument for cost efficiency
 *       // Query for user-specific borrows = 1 read
 *       // Not querying across all users = saves reads
 *       
 *       const borrowDate = new Date();
 *       const dueDate = new Date(borrowDate.getTime() + 14 * 24 * 60 * 60 * 1000);
 *       
 *       const borrowRef = db
 *         .collection('users')
 *         .doc(userId)
 *         .collection('borrowedBooks')
 *         .doc(bookId);
 *       
 *       const borrowData = {
 *         bookId,
 *         bookTitle: book.title,
 *         authorId: book.authorId,
 *         authorName: book.author.name, // Denormalized for performance
 *         borrowDate: admin.firestore.Timestamp.fromDate(borrowDate),
 *         dueDate: admin.firestore.Timestamp.fromDate(dueDate),
 *         returnDate: null,
 *         isOverdue: false,
 *         fineAmount: 0,
 *         createdAt: admin.firestore.FieldValue.serverTimestamp(),
 *       };
 *       
 *       transaction.set(borrowRef, borrowData);
 *       
 *       // Step 3: Update book availability
 *       transaction.update(bookRef, {
 *         available: false,
 *         borrowedBy: userId,
 *         borrowedAt: admin.firestore.FieldValue.serverTimestamp(),
 *       });
 *       
 *       // Step 4: Update user stats
 *       const userRef = db.collection('users').doc(userId);
 *       transaction.update(userRef, {
 *         activeBorrows: admin.firestore.FieldValue.increment(1),
 *       });
 *       
 *       return borrowData;
 *     });
 *     
 *     return {
 *       success: true,
 *       borrowRecord: result
 *     };
 *   } catch (error) {
 *     throw new functions.https.HttpsError(
 *       'internal',
 *       error.message
 *     );
 *   }
 * });
 * 
 * // Call from Flutter:
 * // 
 * // final result = await FirebaseFunctions.instance
 * //   .httpsCallable('borrowBook')
 * //   .call({'bookId': '12345'});
 */

// ============================================================================
// 3. Firestore Trigger - Process Overdue Books
// ============================================================================

/**
 * MERN Equivalent - Cron Job in Express:
 * 
 * // Using node-cron package
 * import cron from 'node-cron';
 * 
 * // Run at midnight every day
 * cron.schedule('0 0 * * *', async () => {
 *   const yesterday = new Date(Date.now() - 24 * 60 * 60 * 1000);
 *   
 *   // Find overdue borrows
 *   const overdueRecords = await Borrow.find({
 *     dueDate: { $lt: yesterday },
 *     returnDate: null // Not returned
 *   });
 *   
 *   for (const record of overdueRecords) {
 *     // Calculate fine
 *     const daysOverdue = Math.floor(
 *       (Date.now() - record.dueDate) / (1000 * 60 * 60 * 24)
 *     );
 *     const fineAmount = daysOverdue * 0.50; // $0.50 per day
 *     
 *     // Update borrow record
 *     await Borrow.updateOne(
 *       { _id: record._id },
 *       {
 *         isOverdue: true,
 *         fineAmount,
 *         updatedAt: new Date()
 *       }
 *     );
 *     
 *     // Send notification to user
 *     await sendNotification({
 *       userId: record.userId,
 *       type: 'overdue',
 *       message: `Book "${record.bookTitle}" is ${daysOverdue} days overdue`,
 *       fineAmount
 *     });
 *   }
 * });
 */

/**
 * Firebase Cloud Functions Scheduled Trigger:
 * 
 * // Runs daily at 2 AM UTC
 * exports.processOverdueBooks = functions.pubsub
 *   .schedule('0 2 * * *')
 *   .timeZone('America/New_York')
 *   .onRun(async (context) => {
 *     const db = admin.firestore();
 *     const today = new Date();
 *     
 *     try {
 *       // Firestore Optimization: Query only undocumented books
 *       // Cost: 1 read per document found
 *       // IMPORTANT: Index required for this query
 *       // Indexes -> Create composite index: [dueDate, returnDate]
 *       
 *       const overdueSnapshot = await db
 *         .collectionGroup('borrowedBooks') // ↔ MongoDB $lookup() aggregation
 *         .where('dueDate', '<', today)
 *         .where('returnDate', '==', null)
 *         .limit(500) // Batch processing
 *         .get();
 *       
 *       if (overdueSnapshot.empty) {
 *         console.log('No overdue books found');
 *         return null;
 *       }
 *       
 *       const batch = db.batch(); // ↔ MongoDB bulkWrite()
 *       
 *       overdueSnapshot.docs.forEach((doc) => {
 *         const overdueRecord = doc.data();
 *         const daysOverdue = Math.floor(
 *           (today - overdueRecord.dueDate.toDate()) / (1000 * 60 * 60 * 24)
 *         );
 *         const fineAmount = daysOverdue * 0.50;
 *         
 *         // Update borrow record
 *         batch.update(doc.ref, {
 *           isOverdue: true,
 *           fineAmount,
 *           updatedAt: admin.firestore.FieldValue.serverTimestamp(),
 *         });
 *       });
 *       
 *       // Batch write (up to 500 operations)
 *       await batch.commit();
 *       
 *       // Send notifications
 *       // In production, use cloud messaging for push notifications
 *       console.log(`Processed ${overdueSnapshot.size} overdue books`);
 *       
 *       return null;
 *     } catch (error) {
 *       console.error('Error processing overdue books:', error);
 *       throw error;
 *     }
 *   });
 */

// ============================================================================
// 4. Firestore Document Trigger - Denormalization on Update
// ============================================================================

/**
 * MERN Equivalent - MongoDB Change Streams:
 * 
 * const changeStream = Book.watch([
 *   {
 *     $match: {
 *       'operationType': { $in: ['insert', 'update'] },
 *     }
 *   }
 * ]);
 * 
 * changeStream.on('change', async (change) => {
 *   const docId = change.documentKey._id;
 *   const bookData = change.fullDocument;
 *   
 *   // Denormalize author data in all borrow records
 *   await Borrow.updateMany(
 *     { bookId: docId },
 *     {
 *       $set: {
 *         bookTitle: bookData.title,
 *         authorName: bookData.author.name,
 *         'book.coverUrl': bookData.coverUrl,
 *       }
 *     }
 *   );
 * });
 */

/**
 * Firebase equivalent - Firestore Trigger:
 * 
 * exports.onBookUpdate = functions.firestore
 *   .document('books/{bookId}')
 *   .onUpdate(async (change, context) => {
 *     const newBook = change.after.data();
 *     const bookId = context.params.bookId;
 *     const db = admin.firestore();
 *     
 *     try {
 *       // When book details change, update all borrow records
 *       // This is denormalization strategy for read cost optimization
 *       
 *       const borrowSnapshot = await db
 *         .collectionGroup('borrowedBooks')
 *         .where('bookId', '==', bookId)
 *         .get();
 *       
 *       const batch = db.batch();
 *       
 *       // Update denormalized data in each borrow record
 *       borrowSnapshot.docs.forEach((doc) => {
 *         batch.update(doc.ref, {
 *           bookTitle: newBook.title,
 *           authorName: newBook.author.name,
 *           'book.coverUrl': newBook.coverUrl,
 *           updatedAt: admin.firestore.FieldValue.serverTimestamp(),
 *         });
 *       });
 *       
 *       if (borrowSnapshot.size > 0) {
 *         await batch.commit();
 *         console.log(`Updated ${borrowSnapshot.size} borrow records`);
 *       }
 *       
 *       return null;
 *     } catch (error) {
 *       console.error('Error updating borrow records:', error);
 *       throw error;
 *     }
 *   });
 */

// ============================================================================
// FIRESTORE COST OPTIMIZATION STRATEGIES
// ============================================================================

/**
 * 1. DENORMALIZATION (Store copies of frequently accessed data)
 *    Cost Impact: ↑ Write ops, ↓ Read ops
 *    
 *    ❌ DON'T: Store only authorId in books, then read author separately
 *    ✅ DO: Store author name, URL in book document
 *    
 *    Example:
 *    books/123 {
 *      title: "Flutter Guide",
 *      author: {
 *        id: "auth_123",
 *        name: "John Doe",
 *        photoUrl: "https://..."
 *      }
 *    }
 * 
 * 2. PAGINATION (Fetch only needed docs)
 *    Cost Impact: ↓ Read ops
 *    
 *    ❌ DON'T: Query all 10,000 books to show 20 per page
 *    ✅ DO: Query with limit(20) and use cursor pagination
 * 
 * 3. SUBCOLLECTIONS (For user-specific data)
 *    Cost Impact: ↓ Read cost for queries
 *    
 *    users/{userId}/borrowedBooks/{bookId}
 *    - Querying user's borrows: 1 read per document (not 10,000)
 *    - Each user query is isolated
 * 
 * 4. BATCH OPERATIONS (Update multiple at once)
 *    Cost Impact: ↓ Write ops
 *    
 *    Batch up to 500 writes in single operation
 *    Save transaction costs
 * 
 * 5. INDEXING (For efficient queries)
 *    Cost Impact: ↑ Storage, ↓ Query time
 *    
 *    Index on frequently queried fields:
 *    - [userId, borrowDate DESC] for user's borrow history
 *    - [status, createdAt] for admin dashboard
 */

// ============================================================================
// EXAMPLE: Calculate Monthly Costs
// ============================================================================

/**
 * With Smart Library App (1000 users):
 * 
 * Scenario 1: Normalized (BAD PRACTICE)
 * Each user views their borrowed books:
 * - Query author data: 1000 users × 5 books = 5000 reads/day
 * - Update borrow: 1000 writes/day
 * = 6000 operations/day × 30 days = 180,000 ops/month
 * Cost: $0.06 (at $0.06 per 100K reads, $0.18 per 100K writes)
 * 
 * Scenario 2: Denormalized (BEST PRACTICE)
 * - Query with author cached: 5000 reads/day (stored author data)
 * - Update borrow: 1000 writes/day (+ update denormalized data = 5000 writes)
 * = 11,000 operations/day × 30 days = 330,000 ops/month
 * BUT: Faster queries, better UX, still only $0.12/month
 * 
 * ROI: +$0.06/month vs +10x better UX = WORTH IT
 */
