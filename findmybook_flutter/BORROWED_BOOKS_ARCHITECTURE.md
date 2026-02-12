# My Borrowed Books Feature - Architecture Guide

## 🎯 Overview

The **My Borrowed Books** feature enables users to:
- View currently borrowed books with due dates
- Return books to the library
- Renew borrowed books (extend due dates)
- Browse complete borrowing history with timeline visualization
- See overdue warnings and time remaining tracking

---

## 📐 Architecture Layers

### **1. Domain Layer** (Business Logic)
**Location:** `domain/`

#### Entities
- **`Borrow`** - Core business object representing a book borrowing relationship
  - Properties: `id`, `userId`, `bookId`, `bookTitle`, `bookAuthor`, `borrowedAt`, `dueDate`, `returnedAt`, `status`
  - Methods: `isActive`, `isOverdue`, `daysRemaining`, `copyWith()`

#### Repositories (Interfaces)
- **`BorrowRepository`** - Abstract contract defining all borrow operations
  - Like an Express service interface that defines what operations are available

#### Use Cases
- **`BorrowBook`** - Business logic for borrowing a book
- **`ReturnBook`** - Business logic for returning a book
- **`GetActiveBorrows`** - Fetch currently borrowed books
- **`GetBorrowHistory`** - Fetch complete borrowing history
- **`RenewBorrow`** - Extend due date of a borrowed book

### **2. Data Layer** (Database Access)
**Location:** `data/`

#### Models
- **`BorrowModel`** - DTO that extends `Borrow` entity
  - `fromSnapshot()` - Deserialize from Firestore document (like Mongoose model)
  - `toJson()` - Serialize to Firestore format

#### Datasources
- **`BorrowRemoteDataSource`** (Interface/Abstract)
  - Defines all Firestore operations

- **`BorrowRemoteDataSourceImpl`** (Implementation)
  - Direct Firestore queries and mutations
  - Collections: `borrows`, `books`
  - Operations:
    - Create borrow record with automatic book availability update
    - Mark book as returned with inventory restoration
    - Real-time stream watching (WebSockets equivalent)

#### Repositories
- **`BorrowRepositoryImpl`** - Implementation of `BorrowRepository`
  - Acts as middleman between domain and datasource
  - Handles response transformation and error handling

### **3. Presentation Layer** (UI & State Management)
**Location:** `presentation/`

#### State Management (Riverpod)
- **Dependency Injection Providers**
  - `firestoreProvider` - Firebase instance
  - `borrowRemoteDataSourceProvider` - Datasource
  - `borrowRepositoryProvider` - Repository

- **Use Case Providers**
  - `borrowBookUseCaseProvider`
  - `returnBookUseCaseProvider`
  - `getActiveBorrowsUseCaseProvider`
  - `getBorrowHistoryUseCaseProvider`
  - `renewBorrowUseCaseProvider`

- **Stream Providers** (Real-time updates)
  - `activeborrowsStreamProvider` - Watch active borrows in real-time
  - `borrowHistoryStreamProvider` - Watch history in real-time

- **Future Providers** (One-time calls)
  - `activeborrowsFutureProvider`
  - `borrowHistoryFutureProvider`
  - `borrowLimitProvider`
  - `borrowCountProvider`

- **Action Providers** (Side effects)
  - `borrowBookActionProvider` - Triggers borrow operation
  - `returnBookActionProvider` - Triggers return operation
  - `renewBorrowActionProvider` - Triggers renew operation

#### Pages
- **`MyBorrowedBooksPage`** - Main screen showing active borrows
  - Sorted by: overdue first, then by closest due date
  - Features: Return, Renew buttons, Progress bar, Status badges

- **`BorrowingHistoryPage`** - Timeline view of all borrows
  - Grouped by year
  - Shows complete borrowing history with visual indicators

#### Widgets
- **`BorrowCard`** - Card displaying individual borrow info
  - Book title, author, status badge
  - Borrowed date, due date display
  - Days remaining progress bar
  - Action buttons (Return, Renew)

- **`BorrowTimelineItem`** - Timeline element for history
  - Visual timeline connector
  - Status-colored dot indicators
  - Duration information
  - Date formatting (Today, Yesterday, etc.)

- **`EmptyBorrowState`** - Empty state when no books borrowed

---

## 🔄 MERN Stack Comparison

```
CONCEPT              | FLUTTER/FIREBASE        | MERN STACK
──────────────────────────────────────────────────────────────
Database             | Firestore               | MongoDB
Collection           | borrows                 | borrows collection
Document Schema      | Borrow Entity           | Mongoose Schema
DTO/Serialization    | BorrowModel             | Mongoose Model
API Endpoints        | Firebase Functions      | Express Routes
Business Logic       | Use Cases               | Middleware/Controllers
Service Layer        | Repository Pattern      | Service Classes
State Management     | Riverpod Providers      | Redux/Context + Thunk
Real-time Updates    | Cloud Firestore Streams | WebSocket/Socket.io
Dependency Injection | Provider Pattern        | Constructor Injection
HTTP Client          | Firebase SDK            | Axios/Fetch
Error Handling       | AsyncValue.guard()      | Try-catch + Error middleware
Async Operations     | FutureProvider          | Async/await Functions
```

### **Example: Borrow a Book**

**MERN Stack (Express + MongoDB):**
```javascript
// Express POST /api/borrows
app.post('/api/borrows', auth, async (req, res) => {
  try {
    // Check limit
    const count = await Borrow.countDocuments({ userId, status: 'active' });
    if (count >= 5) throw new Error('Limit reached');
    
    // Create borrow
    const borrow = await Borrow.create({
      userId, bookId, bookTitle, bookAuthor,
      borrowedAt: new Date(),
      dueDate: new Date(Date.now() + 14 * 24 * 60 * 60 * 1000),
      status: 'active'
    });
    
    // Update book availability
    await Book.findByIdAndUpdate(bookId, { available: false });
    
    res.json(borrow);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});
```

**Flutter/Firebase (Our Implementation):**
```dart
// BorrowBook Use Case
class BorrowBook {
  Future<Borrow> call({...}) async {
    // Check limit (business logic)
    final hasLimit = await repository.hasReachedBorrowLimit(userId);
    if (hasLimit) throw Exception('Limit reached');
    
    // Create borrow (datasource handles Firestore + book update)
    return repository.borrowBook(...);
  }
}

// In UI: Riverpod action provider
final result = await ref.read(borrowBookActionProvider(params).future);
```

---

## 📊 Data Flow

### **1. Borrow a Book**
```
UI Button Tap
    ↓
BorrowBook Use Case (check limit)
    ↓
BorrowRepository.borrowBook()
    ↓
BorrowRemoteDataSource.borrowBook()
    ↓
Firestore:
  - Add to 'borrows' collection
  - Update book 'available' = false
    ↓
Return BorrowModel
    ↓
UI Refreshes (invalidate stream)
    ↓
Stream emits new list
    ↓
UI updates Real-time
```

### **2. Real-time Updates**
```
Firestore Change
    ↓
watchActiveBorrowsForUser() Stream
    ↓
StreamProvider emits new value
    ↓
ConsumerWidget observes change
    ↓
UI rebuilds automatically
```

---

## 🔐 Firestore Collections & Indexes

### **`borrows` Collection**
```json
{
  "userId": "user123",
  "bookId": "book456",
  "bookTitle": "Flutter Guide",
  "bookAuthor": "Jane Doe",
  "borrowedAt": Timestamp(2026-02-12),
  "dueDate": Timestamp(2026-02-26),
  "returnedAt": null,
  "status": "active",
  "createdAt": Timestamp(auto),
  "updatedAt": Timestamp(auto)
}
```

**Recommended Indexes:**
- `userId + status + dueDate` (for active borrows query)
- `userId + borrowedAt DESC` (for history query)

### **`books` Collection** (Updated)
```json
{
  "title": "Flutter Guide",
  "available": false,
  "borrowedBy": "user123"  // New field
  // ... other fields
}
```

---

## ⚙️ Integration Steps

### **1. Update Router**
```dart
// In lib/src/router/app_router.dart
GoRoute(
  path: '/borrowed-books',
  builder: (context, state) => MyBorrowedBooksPage(
    userId: currentUserId, // Get from auth provider
  ),
),
GoRoute(
  path: '/borrow-history',
  builder: (context, state) => BorrowingHistoryPage(
    userId: currentUserId,
  ),
),
```

### **2. Add Navigation**
```dart
// In main navigation drawer or app bar
ListTile(
  icon: const Icon(Icons.library_books),
  title: const Text('My Books'),
  onTap: () => context.go('/borrowed-books'),
),
```

### **3. Update Book Detail Page**
Add "Borrow" button that calls:
```dart
ref.read(borrowBookActionProvider((
  userId, bookId, bookTitle, bookAuthor, 14
)).future);
```

---

## 🚀 Production Checklist

- [x] Clean Architecture (Domain/Data/Presentation)
- [x] Repository Pattern (abstraction)
- [x] Use Cases (business logic separation)
- [x] Riverpod (state management)
- [x] Real-time Streams (WebSockets equivalent)
- [x] Error Handling (AsyncValue.guard)
- [x] Firestore Integration
- [x] UI/UX (Timeline, Cards, Progress bars)
- [ ] Unit Tests (Use cases, repositories)
- [ ] Integration Tests (UI with mock Firestore)
- [ ] Cloud Functions (Auto-update overdue status daily)
- [ ] Analytics (Track borrow/return events)

---

## 📝 Key Differences from MERN

1. **No Separate Backend** - Firebase handles DB + Auth + Functions
2. **Real-time by Default** - Firestore Streams vs polling
3. **Type-Safe** - Dart provides compile-time type checking
4. **Hot Reload** - Instant feedback during development
5. **No N+1 Queries** - Firestore structure prevents this naturally

---

## 🎓 Learning Points

- Clean Architecture helps with testability and maintenance
- Repository Pattern decouples business logic from data access
- Riverpod provides reactive state management without boilerplate
- Firestore Streams enable true real-time collaboration
- Timeline UI demonstrates advanced Flutter layout techniques

