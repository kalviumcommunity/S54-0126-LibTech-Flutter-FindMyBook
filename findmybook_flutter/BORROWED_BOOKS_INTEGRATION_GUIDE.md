# My Borrowed Books - Quick Integration Guide

## 🚀 Quick Start

This guide shows how to integrate the Borrowed Books feature into your app in 5 minutes.

---

## Step 1: Update Firestore Security Rules

Add these rules to allow users to read/write their own borrow records:

```javascript
// firestore.rules
match /borrows/{borrowId} {
  allow read: if request.auth.uid == resource.data.userId || request.auth.uid == get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
  allow create: if request.auth.uid == request.resource.data.userId && 
                   request.resource.data.status == 'active';
  allow update: if request.auth.uid == resource.data.userId && 
                   (request.resource.data.status in ['returned', 'active']);
  allow delete: if false; // Prevent deletion for audit trail
}
```

---

## Step 2: Add Navigation Routes

**File:** `lib/src/router/app_router.dart`

```dart
import 'package:go_router/go_router.dart';
import '../features/borrowed_books/borrowed_books_feature.dart';

final appRouter = GoRouter(
  routes: [
    // ... existing routes ...
    
    GoRoute(
      path: '/borrowed-books',
      builder: (context, state) {
        final userId = ref.read(currentUserProvider).value?.uid ?? '';
        return MyBorrowedBooksPage(userId: userId);
      },
    ),
    
    GoRoute(
      path: '/borrowing-history',
      builder: (context, state) {
        final userId = ref.read(currentUserProvider).value?.uid ?? '';
        return BorrowingHistoryPage(userId: userId);
      },
    ),
  ],
);
```

---

## Step 3: Add Navigation Menu Items

**File:** `lib/src/features/home/presentation/widgets/app_drawer.dart` (or similar)

```dart
ListTile(
  leading: const Icon(Icons.library_books),
  title: const Text('My Borrowed Books'),
  onTap: () {
    Navigator.pop(context); // Close drawer
    context.go('/borrowed-books');
  },
),

ListTile(
  leading: const Icon(Icons.history),
  title: const Text('Borrowing History'),
  onTap: () {
    Navigator.pop(context);
    context.go('/borrowing-history');
  },
),
```

---

## Step 4: Add "Borrow" Button to Book Detail Page

**File:** `lib/src/features/books/presentation/pages/book_detail_page.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../borrowed_books/borrowed_books_feature.dart';

class BookDetailPage extends ConsumerWidget {
  final Book book;

  const BookDetailPage({required this.book, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      // ... existing UI ...
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _handleBorrowBook(context, ref),
        icon: const Icon(Icons.book_outlined),
        label: const Text('Borrow Book'),
      ),
    );
  }

  Future<void> _handleBorrowBook(BuildContext context, WidgetRef ref) async {
    try {
      final userId = ref.read(authProvider).currentUser?.uid;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in first')),
        );
        return;
      }

      // Call borrow action
      final borrow = await ref.read(
        borrowBookActionProvider((
          userId,
          book.id,
          book.title,
          book.author,
          14, // 14 days borrow period
        )).future,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully borrowed "${book.title}"'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'View',
              onPressed: () => context.go('/borrowed-books'),
            ),
          ),
        );

        // Optional: Navigate back
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
```

---

## Step 5: Update Book Model to Track Availability

**File:** `lib/src/features/books/models/book.dart`

```dart
class Book {
  // ... existing fields ...
  final bool available;
  final String? borrowedBy; // New field

  Book({
    // ... existing params ...
    required this.available,
    this.borrowedBy,
  });

  factory Book.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>? ?? {};
    return Book(
      // ... existing mappings ...
      available: data['available'] as bool? ?? true,
      borrowedBy: data['borrowedBy'] as String?,
    );
  }
}
```

---

## Step 6: Display Borrowed Status on Book List

**File:** `lib/src/features/books/presentation/widgets/book_card.dart`

```dart
// Add this to your book card
if (!book.available)
  Positioned(
    top: 8,
    right: 8,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'Borrowed',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ),
```

---

## 📊 Architecture Diagram

```
┌─────────────────────────────────────┐
│         UI Layer (Widgets)          │
├─────────────────────────────────────┤
│  MyBorrowedBooksPage               │
│  BorrowingHistoryPage              │
│  BorrowCard / Timeline Items       │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│  Riverpod Providers (State Mgmt)    │
├─────────────────────────────────────┤
│  activeborrowsStreamProvider        │
│  borrowBookActionProvider          │
│  returnBookActionProvider          │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│  Domain Layer (Business Logic)     │
├─────────────────────────────────────┤
│  Borrow Entity                      │
│  BorrowRepository (Interface)       │
│  Use Cases (Borrow, Return, Renew) │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│  Data Layer (Database Access)       │
├─────────────────────────────────────┤
│  BorrowRepositoryImpl                │
│  BorrowRemoteDataSourceImpl          │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│      Firestore Collections          │
├─────────────────────────────────────┤
│  /borrows/{id}                      │
│  /books/{id}                        │
└─────────────────────────────────────┘
```

---

## 🧪 Testing Integration

### Test Borrow Flow:
1. Navigate to Book Detail page
2. Click "Borrow Book" button
3. Check "My Borrowed Books" page - should see book in list
4. Verify due date is 14 days from today
5. Test "Return" button - should remove from active list

### Test Return Flow:
1. From "My Borrowed Books", click "Return"
2. Confirm in dialog
3. Check "Borrowing History" - should show as returned
4. Verify book is available again

### Test Renewal Flow:
1. Click "Renew" on an active borrow
2. Confirm renewal period (default 14 days)
3. Verify new due date is extended

---

## 🔧 Customization

### Change Borrow Period (Default 14 days)
**File:** `lib/src/features/books/presentation/pages/book_detail_page.dart`

```dart
// Change this value:
borrowDays: 14, // ← Modify this

// Or make it user-selectable:
final borrowDays = await showDialog<int>(
  context: context,
  builder: (context) => SimpleDialog(
    title: const Text('Select Borrow Period'),
    children: [
      SimpleDialogOption(
        onPressed: () => Navigator.pop(context, 7),
        child: const Text('7 days'),
      ),
      SimpleDialogOption(
        onPressed: () => Navigator.pop(context, 14),
        child: const Text('14 days'),
      ),
      SimpleDialogOption(
        onPressed: () => Navigator.pop(context, 21),
        child: const Text('21 days'),
      ),
    ],
  ),
) ?? 14;
```

### Change Borrow Limit (Default 5 books)
**File:** `lib/src/features/borrowed_books/domain/usecases/borrow_usecases.dart`

```dart
// Update the BorrowBook use case:
final hasReachedLimit = await repository.hasReachedBorrowLimit(
  userId,
  maxBorrows: 10, // ← Change from 5 to 10
);
```

---

## 📱 Firestore Indexes

Create these composite indexes for optimal query performance:

1. **Collection:** `borrows`
   - Fields: `userId` (Ascending), `status` (Ascending), `dueDate` (Descending)
   - Use case: Getting active borrows sorted by due date

2. **Collection:** `borrows`
   - Fields: `userId` (Ascending), `borrowedAt` (Descending)
   - Use case: Getting borrow history

---

## ✅ Checklist Before Going to Production

- [ ] Firestore Security Rules updated
- [ ] Navigation routes added
- [ ] Book detail page has "Borrow" button
- [ ] My Borrowed Books page linked in navigation
- [ ] User can successfully borrow a book
- [ ] Real-time updates work (try multiple devices)
- [ ] Return/Renew functionality tested
- [ ] Timeline history UI displays correctly
- [ ] Overdue warnings trigger correctly
- [ ] Error handling tested (quota, permissions, etc.)
- [ ] Firestore indexes created
- [ ] Cloud Functions for notifications (if needed)

---

## 🐛 Troubleshooting

**Issue:** "Borrow button not appearing"
- Check: Is current user authenticated?
- Check: Is book.available == true?

**Issue:** "Changes not appearing in real-time"
- Check: Are Firestore indexes created?
- Check: Are Riverpod providers being watched?

**Issue:** "Permission denied error"
- Check: Firestore security rules
- Check: User ID is correctly passed

---

## 📞 Support

For questions, refer to:
- [BORROWED_BOOKS_ARCHITECTURE.md](./BORROWED_BOOKS_ARCHITECTURE.md) - Full architecture
- [Official Flutter Riverpod Docs](https://riverpod.dev)
- [Firestore Documentation](https://firebase.google.com/docs/firestore)

