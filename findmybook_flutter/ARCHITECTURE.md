## Flutter Architecture Guide - Production-Level Design

---

## 📐 Clean Architecture Pattern

We follow **Clean Architecture** with three distinct layers:

```
┌─────────────────────────────────────────────────────┐
│              PRESENTATION LAYER                      │
│  (Pages, Screens, Widgets, State Management)        │
│  Handles: UI rendering, user interaction            │
└─────────────────────────────────────────────────────┘
                        ↕
┌─────────────────────────────────────────────────────┐
│              DOMAIN LAYER                            │
│  (Entities, Use Cases, Repository Interfaces)       │
│  Handles: Business logic, rules, pure functions     │
└─────────────────────────────────────────────────────┘
                        ↕
┌─────────────────────────────────────────────────────┐
│              DATA LAYER                              │
│  (Data Sources, Repositories, Models)               │
│  Handles: Firestore, APIs, caching, persistence    │
└─────────────────────────────────────────────────────┘
```

### Why This Architecture?

| Benefit | Explanation |
|---------|-------------|
| **Testability** | Each layer can be tested independently |
| **Reusability** | Business logic isn't tied to UI |
| **Maintainability** | Clear separation of concerns |
| **Scalability** | Easy to add new features |
| **Team Collaboration** | Teams can work on different layers |

---

## 🏗️ Folder Structure

```
lib/
├── src/
│   ├── core/                          # Shared across entire app
│   │   ├── theme/                     # Design system
│   │   │   ├── app_colors.dart
│   │   │   ├── app_spacing.dart
│   │   │   ├── app_typography.dart
│   │   │   ├── app_theme.dart
│   │   │   └── index.dart
│   │   │
│   │   ├── widgets/                   # Reusable UI components
│   │   │   ├── app_button.dart        # Button variants
│   │   │   ├── app_text_field.dart    # Input variants
│   │   │   ├── app_loader.dart        # Loading states
│   │   │   ├── app_card.dart          # Card components
│   │   │   ├── app_spacing.dart       # Spacing utilities
│   │   │   ├── app_dialogs.dart       # Modals, dialogs
│   │   │   └── index.dart
│   │   │
│   │   └── utils/                     # Helpers, extensions
│   │       ├── validators.dart        # Form validators
│   │       ├── constants.dart         # App-wide constants
│   │       └── extensions.dart        # String, Date extensions
│   │
│   ├── features/                      # Feature modules
│   │   ├── books/                     # Example feature: Books
│   │   │   ├── data/
│   │   │   │   ├── datasources/       # Remote & local sources
│   │   │   │   │   ├── book_remote_datasource.dart
│   │   │   │   │   └── book_local_datasource.dart
│   │   │   │   ├── repositories/      # Repository implementations
│   │   │   │   │   └── book_repository_impl.dart
│   │   │   │   └── models/            # Data models (JSON serializable)
│   │   │   │       ├── book_model.dart
│   │   │   │       └── book_dto.dart
│   │   │   │
│   │   │   ├── domain/
│   │   │   │   ├── entities/          # Core business objects
│   │   │   │   │   └── book.dart
│   │   │   │   ├── repositories/      # Abstract interfaces
│   │   │   │   │   └── book_repository.dart
│   │   │   │   └── usecases/          # Business logic
│   │   │   │       ├── get_books.dart
│   │   │   │       ├── add_book.dart
│   │   │   │       └── delete_book.dart
│   │   │   │
│   │   │   └── presentation/
│   │   │       ├── pages/             # Full screens
│   │   │       │   ├── books_home_page.dart
│   │   │       │   └── book_details_page.dart
│   │   │       ├── widgets/           # Feature-specific widgets
│   │   │       │   ├── book_list_item.dart
│   │   │       │   └── book_filter.dart
│   │   │       └── providers/         # Riverpod state management
│   │   │           ├── book_list_provider.dart
│   │   │           └── book_detail_provider.dart
│   │   │
│   │   ├── auth/                      # Another feature
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── search/
│   │   └── profile/
│   │
│   ├── app.dart                       # Root widget
│   └── main.dart                      # App entry point
│
├── android/                           # Android native code
├── ios/                               # iOS native code
├── web/                               # Web build
├── test/                              # Unit & widget tests
└── pubspec.yaml                       # Dependencies
```

---

## 📊 MERN ↔ Flutter Mapping

### Project Structure

```
MERN Project:
├── frontend/
│   ├── src/
│   │   ├── components/        ↔ Flutter: lib/src/core/widgets/
│   │   ├── pages/            ↔ Flutter: lib/src/features/*/presentation/pages/
│   │   ├── redux/            ↔ Flutter: lib/src/features/*/presentation/providers/
│   │   └── services/         ↔ Flutter: lib/src/features/*/domain/usecases/
│   └── package.json          ↔ Flutter: pubspec.yaml
│
└── backend/
    ├── routes/               ↔ Flutter: (Firebase handles routing)
    ├── controllers/          ↔ Flutter: lib/src/features/*/domain/usecases/
    ├── models/               ↔ Flutter: lib/src/features/*/domain/entities/
    └── middlewares/          ↔ Flutter: lib/src/core/ (global utils)
```

### State Management

| MERN | Flutter |
|------|---------|
| Redux Store | Riverpod StateNotifier |
| Redux Actions | Riverpod methods |
| Redux Reducers | Riverpod state updates |
| Redux Thunks (async) | Riverpod AsyncNotifier |
| Selectors | Riverpod providers with family |

**Example:**

```javascript
// MERN Redux Thunk
const fetchBooks = () => async (dispatch) => {
  dispatch({ type: 'LOADING' });
  try {
    const data = await fetch('/api/books').then(r => r.json());
    dispatch({ type: 'SET_BOOKS', payload: data });
  } catch (error) {
    dispatch({ type: 'ERROR', payload: error });
  }
};
```

```dart
// Flutter Riverpod
final booksProvider = FutureProvider<List<Book>>((ref) async {
  final repo = ref.watch(bookRepositoryProvider);
  return await repo.getBooks();
});
```

---

## 🔄 Data Flow

### Firebase (Firestore) ↔ React Redux

```
┌──────────────────────────────────────────────┐
│  UI (React Component)                        │
└──────────────────────────────────────────────┘
           ↓ (dispatch action)
┌──────────────────────────────────────────────┐
│  Redux Thunk (Side Effects)                  │
│  - Fetch from API/Firebase                   │
│  - Transform data                            │
└──────────────────────────────────────────────┘
           ↓ (dispatch success)
┌──────────────────────────────────────────────┐
│  Redux Reducer (Update Store)                │
└──────────────────────────────────────────────┘
           ↓ (subscribe)
┌──────────────────────────────────────────────┐
│  UI (React Component Re-renders)             │
└──────────────────────────────────────────────┘
```

```
┌──────────────────────────────────────────────┐
│  UI (Flutter Widget)                         │
└──────────────────────────────────────────────┘
           ↓ (watch provider)
┌──────────────────────────────────────────────┐
│  Riverpod FutureProvider                     │
│  - Fetch from Firestore                      │
│  - Cache automatically                       │
└──────────────────────────────────────────────┘
           ↓ (return Future<List<Book>>)
┌──────────────────────────────────────────────┐
│  Riverpod State (Immutable)                  │
└──────────────────────────────────────────────┘
           ↓ (rebuild)
┌──────────────────────────────────────────────┐
│  UI (Flutter Widget Re-renders)              │
└──────────────────────────────────────────────┘
```

---

## 📦 Data Models

### How to create models for Firestore

**MERN (TypeScript):**
```typescript
// User.ts
interface User {
  id: string;
  email: string;
  name: string;
  role: 'student' | 'librarian';
  createdAt: Date;
}

// With MongoDB ODM (Mongoose):
const userSchema = new Schema({
  email: { type: String, required: true },
  name: String,
  role: { type: String, enum: ['student', 'librarian'] },
  createdAt: { type: Date, default: Date.now },
});
```

**Flutter (Dart):**
```dart
// Domain Entity (Business logic)
class User {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
  });
}

// Data Model (Firebase serialization)
class UserModel extends User {
  UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.role,
    required super.createdAt,
  });

  // From Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'],
      name: data['name'],
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == data['role'],
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'role': role.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

enum UserRole { student, librarian }
```

---

## 🔐 Dependency Injection

**Flutter uses Riverpod for DI:**

```dart
// Provide repositories
final bookRepositoryProvider = Provider((ref) {
  final firestore = ref.watch(firestoreProvider);
  return BookRepositoryImpl(firestore);
});

// Provide use cases
final getBooksUseCaseProvider = Provider((ref) {
  final repo = ref.watch(bookRepositoryProvider);
  return GetBooksUseCase(repo);
});

// Use in UI
final booksProvider = FutureProvider((ref) {
  final useCase = ref.watch(getBooksUseCaseProvider);
  return useCase.call();
});
```

**Equivalent to MERN:**
```typescript
// Dependency Container (like InversifyJS)
const container = new Container();
container.bind<IBookService>(TYPES.BookService).to(BookService);
container.bind<IBookRepository>(TYPES.BookRepository).to(BookRepository);

// Or using React Context
const ServiceContext = React.createContext({ bookService: new BookService() });
```

---

## 🧪 Testing Architecture

```
test/
├── unit/                          # Business logic tests
│   ├── features/
│   │   └── books/
│   │       ├── domain/
│   │       │   └── usecases/book_usecase_test.dart
│   │       └── data/
│   │           └── repositories/book_repository_test.dart
│   └── core/
│       └── validators_test.dart
│
└── widget/                        # UI component tests
    └── features/
        └── books/
            └── presentation/
                └── pages/book_page_test.dart
```

**Example Test:**
```dart
void main() {
  group('GetBooksUseCase', () {
    late MockBookRepository mockRepo;
    late GetBooksUseCase useCase;

    setUp(() {
      mockRepo = MockBookRepository();
      useCase = GetBooksUseCase(mockRepo);
    });

    test('should return list of books from repository', () async {
      // Arrange
      final books = [
        Book(id: '1', title: 'Book 1'),
        Book(id: '2', title: 'Book 2'),
      ];
      when(mockRepo.getBooks()).thenAnswer((_) async => books);

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, books);
      verify(mockRepo.getBooks()).called(1);
    });
  });
}
```

---

## 🚀 Deployment & Release

### Version Management
```yaml
# pubspec.yaml
version: 1.0.0+1
# Format: major.minor.patch+buildNumber
```

### Building for Production

**Android:**
```bash
flutter build apk --release
# Creates: build/app/outputs/flutter-app.apk
```

**iOS:**
```bash
flutter build ios --release
# Creates: build/ios/iphoneos/Runner.app
```

**Web:**
```bash
flutter build web --release
# Creates: build/web/ (static files)
```

---

## 📱 Best Practices

### 1. **Use Constants**
```dart
// ✅ Good
const appTitle = 'Smart Library';
const maxRetries = 3;

// ❌ Avoid
String appTitle = 'Smart Library';
```

### 2. **Null Safety**
```dart
// ✅ Good
String? name;        // Nullable
String title = 'x';  // Non-nullable (required)

// ❌ Avoid
String? name = '';   // Should be null if not provided
```

### 3. **Use Value Objects for Complex Data**
```dart
// ✅ Good
class Email {
  final String value;
  
  Email(this.value) {
    if (!_isValid(value)) throw InvalidEmailException();
  }
}

// Use in domain
class User {
  final Email email;
  User(this.email);
}

// ❌ Avoid
class User {
  final String email;
  User(this.email);
}
```

### 4. **Resource Management**
```dart
// ✅ Good
@override
void dispose() {
  controller.dispose();
  listener?.cancel();
  super.dispose();
}

// ❌ Avoid (memory leaks)
// Forgetting to dispose controllers
```

### 5. **Error Handling**
```dart
// ✅ Good
try {
  final books = await repo.getBooks();
  return books;
} on FirebaseException catch (e) {
  throw BookRepositoryException(e.message);
} catch (e) {
  throw UnexpectedException('Unknown error');
}

// Use custom exceptions
class BookException implements Exception {
  final String message;
  BookException(this.message);
  
  @override
  String toString() => message;
}
```

---

## 🔗 Key Principles

| Principle | Meaning | Example |
|-----------|---------|---------|
| **SOLID** | Single Responsibility, Open/Closed, Liskov, Interface Segregation, Dependency Inversion | Each class has one job |
| **DRY** | Don't Repeat Yourself | Use reusable components |
| **KISS** | Keep It Simple, Stupid | Avoid over-engineering |
| **Immutability** | Once created, data doesn't change | Use `final` keyword |
| **Composition** | Build complex from simple | Combine small widgets |

---

## 📚 Further Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Clean Code in Dart](https://dartpad.dev)
- [Riverpod Documentation](https://riverpod.dev)
- [Firebase for Flutter](https://firebase.google.com/docs/flutter/setup)
- [Material Design 3](https://m3.material.io/)

---

## 🎯 Next Steps

1. ✅ Core components built
2. ⏭️ Implement feature modules using this architecture
3. ⏭️ Set up Riverpod providers for state management
4. ⏭️ Connect to Firebase
5. ⏭️ Write unit tests
6. ⏭️ Deploy to production

Good luck building your production-level Flutter app! 🚀
