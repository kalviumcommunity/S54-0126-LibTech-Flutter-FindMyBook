## Smart Library Management App - Component Architecture Guide

Welcome to production-level Flutter development! This guide explains our reusable component system with MERN/React comparisons.

---

## 📚 Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Theme System](#theme-system)
3. [Component Library](#component-library)
4. [MERN Comparisons](#mern-comparisons)
5. [Usage Examples](#usage-examples)
6. [Best Practices](#best-practices)

---

## Architecture Overview

### Folder Structure

```
lib/
├── src/
│   ├── core/
│   │   ├── theme/                    # Design tokens & theme
│   │   │   ├── app_colors.dart
│   │   │   ├── app_spacing.dart
│   │   │   ├── app_typography.dart
│   │   │   ├── app_theme.dart
│   │   │   └── index.dart
│   │   ├── widgets/                  # Reusable UI components
│   │   │   ├── app_button.dart
│   │   │   ├── app_text_field.dart
│   │   │   ├── app_loader.dart
│   │   │   ├── app_card.dart
│   │   │   ├── app_spacing.dart
│   │   │   ├── app_dialogs.dart
│   │   │   └── index.dart
│   │   └── ...
│   ├── features/
│   │   ├── books/                    # Feature modules
│   │   │   ├── data/                 # Data layer (Firestore/API)
│   │   │   ├── domain/               # Business logic
│   │   │   └── presentation/         # UI (Pages, Screens)
│   │   └── ...
│   └── app.dart
└── main.dart
```

### Layer Responsibilities

| Layer | Flutter | MERN Equivalent | Purpose |
|-------|---------|------------------|---------|
| **Presentation** | Screens, Widgets, State | React Components | Display UI, handle user input |
| **Domain** | Use Cases, Entities | Redux Actions, Thunks | Business logic, rules |
| **Data** | Repositories, Data Sources | API Services, Redux | Fetch/store data |
| **Core** | Widgets, Theme, Utils | Common utilities | Shared across all features |

---

## Theme System

### `AppColors` - Global Color Palette

**MERN Comparison:**
```javascript
// React/Material-UI
const theme = createTheme({
  palette: {
    primary: { main: '#6200EA' },
    secondary: { main: '#03DAC6' },
  }
});

// Usage: theme.palette.primary.main
```

**Flutter Implementation:**
```dart
import 'package:smart_library_app/src/core/theme/index.dart';

// Usage: AppColors.primary
Container(
  color: AppColors.primary,  // #6200EA
  child: Text(
    'Hello',
    style: TextStyle(color: AppColors.textOnPrimary),
  ),
)
```

**Color Categories:**

| Category | Colors | Usage |
|----------|--------|-------|
| **Primary** | `primary`, `primaryDark`, `primaryLight` | Brand color, CTAs |
| **Secondary** | `secondary`, `secondaryDark`, `secondaryLight` | Accents, highlights |
| **States** | `error`, `success`, `warning` | Status indicators |
| **Text** | `textPrimary`, `textSecondary`, `textTertiary` | Text hierarchy |
| **Backgrounds** | `background`, `surface`, `surfaceVariant` | Page/component backgrounds |

---

### `AppSpacing` - Consistent Spacing Scale

**MERN Comparison:**
```css
/* Tailwind CSS */
.p-4 { padding: 1rem; }     /* 16px */
.mb-6 { margin-bottom: 1.5rem; } /* 24px */

/* Flutter */
AppSpacing.lg   // 16.0
AppSpacing.xl   // 24.0
```

**Spacing Scale:**

```dart
AppSpacing.xs      // 4.0   - Micro spacing
AppSpacing.sm      // 8.0   - Small components
AppSpacing.md      // 12.0  - Between elements
AppSpacing.lg      // 16.0  - Standard padding (default)
AppSpacing.xl      // 24.0  - Section spacing
AppSpacing.xxl     // 32.0  - Page-level spacing
```

---

### `AppTypography` - Text Styles

**MERN Comparison:**
```javascript
// Material-UI Typography
<Typography variant="h1">Headline 1</Typography>
<Typography variant="body2">Body text</Typography>

// Flutter
Text('Headline 1', style: AppTypography.displayLarge)
Text('Body text', style: AppTypography.bodySmall)
```

**Hierarchy:**

```dart
// Display (largest)
AppTypography.displayLarge   // 57px - Hero sections
AppTypography.displayMedium  // 45px
AppTypography.displaySmall   // 36px

// Headline (page titles)
AppTypography.headlineLarge  // 32px
AppTypography.headlineMedium // 28px
AppTypography.headlineSmall  // 24px

// Title (section headers)
AppTypography.titleLarge     // 22px
AppTypography.titleMedium    // 16px
AppTypography.titleSmall     // 14px

// Body (main content)
AppTypography.bodyLarge      // 16px - Main paragraphs
AppTypography.bodyMedium     // 14px
AppTypography.bodySmall      // 12px - Secondary text

// Label (buttons, chips)
AppTypography.labelLarge     // 14px - Button text
AppTypography.labelMedium    // 12px
AppTypography.labelSmall     // 11px
```

---

### `AppTheme` - Complete Theme Configuration

Applies all colors, typography, and spacing to Material Design components.

```dart
MaterialApp(
  theme: AppTheme.lightTheme,      // All our customizations applied
  darkTheme: AppTheme.darkTheme,   // For future dark mode
  home: MyApp(),
)
```

---

## Component Library

### 1. Button Components

#### `AppButton` - Filled Primary Button

**MERN Comparison:**
```jsx
// React
<Button variant="contained" loading={isLoading}>
  Save
</Button>

// Flutter
AppButton(
  onPressed: () => save(),
  label: 'Save',
  isLoading: isLoading,
)
```

**Features:**
- ✅ Loading state (shows spinner, disables)
- ✅ Disabled state
- ✅ Custom colors
- ✅ Icon support
- ✅ Full width option

**Example:**
```dart
AppButton(
  onPressed: () => handleSubmit(),
  label: 'Add to Library',
  isLoading: isSubmitting,
  backgroundColor: AppColors.success,
  icon: Icons.add,
  fullWidth: true,
)
```

---

#### `AppOutlinedButton` - Secondary Button

```dart
AppOutlinedButton(
  onPressed: () => handleCancel(),
  label: 'Cancel',
  textColor: AppColors.primary,
)
```

---

#### `AppTextButton` - Minimal/Link Button

```dart
AppTextButton(
  onPressed: () => showPasswordReset(),
  label: 'Forgot password?',
  underline: true,
)
```

---

#### `AppIconButton` - Icon-Only Button

```dart
AppIconButton(
  icon: Icons.search,
  onPressed: () => openSearch(),
  tooltip: 'Search',
)
```

---

### 2. Text Input Components

#### `AppTextField` - Standard Text Input

**MERN Comparison:**
```jsx
// React with React Hook Form
<Controller
  name="title"
  control={control}
  rules={{ required: 'Title required' }}
  render={({ field, fieldState }) => (
    <TextField
      {...field}
      error={!!fieldState.error}
      helperText={fieldState.error?.message}
    />
  )}
/>

// Flutter
AppTextField(
  controller: titleController,
  label: 'Title',
  validator: (value) {
    if (value?.isEmpty ?? true) return 'Title required';
    return null;
  },
)
```

**Features:**
- ✅ Built-in validation
- ✅ Error messages
- ✅ Keyboard types
- ✅ Prefix/suffix icons
- ✅ Max length with counter
- ✅ Read-only mode

**Example:**
```dart
AppTextField(
  controller: bookTitleCtrl,
  label: 'Book Title',
  hint: 'Enter the title',
  keyboardType: TextInputType.text,
  maxLength: 100,
  showCounter: true,
  prefixIcon: Icons.book,
  validator: (value) {
    if (value?.isEmpty ?? true) return 'Title is required';
    if (value!.length < 3) return 'Minimum 3 characters';
    return null;
  },
  onChanged: (value) => setState(() => _title = value),
)
```

---

#### `AppPasswordField` - Password Input with Toggle

```dart
AppPasswordField(
  controller: passwordCtrl,
  label: 'Password',
  validator: (value) {
    if (value?.isEmpty ?? true) return 'Required';
    if (value!.length < 8) return 'Min 8 chars';
    return null;
  },
)
// Shows eye icon to toggle visibility
```

---

#### `AppSearchField` - Search with Clear Button

```dart
AppSearchField(
  controller: searchCtrl,
  hint: 'Search books...',
  onChanged: (query) => setState(() => _query = query),
  onClear: () => searchCtrl.clear(),
)
```

---

#### `AppDropdownField` - Select/Dropdown

```dart
AppDropdownField<String>(
  label: 'Genre',
  items: ['Fiction', 'Science', 'History'],
  value: selectedGenre,
  itemLabel: (item) => item,
  onChanged: (value) => setState(() => selectedGenre = value),
  hint: 'Select a genre',
)
```

---

### 3. Loader Components

#### `AppLoader` - Spinner

```dart
// Basic
AppLoader()

// Custom
AppLoader(
  color: AppColors.success,
  size: 56,
  strokeWidth: 3,
)
```

---

#### `AppShimmer` - Skeleton Text Loader

**MERN Comparison:**
```jsx
// React
import Skeleton from 'react-loading-skeleton';
{isLoading ? <Skeleton height={20} /> : <Text>{title}</Text>}

// Flutter
isLoading ? AppShimmer(height: 20) : Text(title)
```

```dart
// Single line
AppShimmer(width: double.infinity, height: 16)

// Circle (avatar)
AppShimmerCircle(radius: 24)

// Full card
AppShimmerCard(height: 200)

// List of items
AppShimmerList(itemCount: 5, itemHeight: 80)
```

---

#### `AppFullScreenLoader` - Overlay Loader

```dart
Stack(
  children: [
    YourContent(),
    if (isLoading) 
      AppFullScreenLoader(message: 'Loading books...'),
  ],
)
```

---

### 4. Card Components

#### `AppCard` - Base Card

**MERN Comparison:**
```jsx
// React
<Card elevation={2}>
  <CardContent>{children}</CardContent>
</Card>

// Flutter
AppCard(
  child: Text('Content'),
  elevation: 2,
)
```

```dart
AppCard(
  child: Column(
    children: [
      Text('Title'),
      Text('Subtitle'),
    ],
  ),
  borderRadius: 12,
  elevation: 1,
  padding: EdgeInsets.all(16),
  onTap: () => handleCardTap(),
)
```

---

#### `BookCard` - Specialized Book Card

Displays book cover, title, author, rating.

```dart
BookCard(
  title: 'The Great Gatsby',
  author: 'F. Scott Fitzgerald',
  imageUrl: 'https://images.example.com/gatsby.jpg',
  rating: 4.5,
  reviewCount: 1200,
  isAvailable: true,
  categoryColor: AppColors.bookBluish,
  onTap: () => navigateToDetails(),
)
```

---

#### `UserCard` - User Profile Card

```dart
UserCard(
  name: 'John Doe',
  role: 'Student',
  avatarUrl: 'https://example.com/avatar.jpg',
  onTap: () => showProfile(),
)
```

---

#### `StatCard` - Metric Card

```dart
StatCard(
  label: 'Books Borrowed',
  value: '24',
  icon: Icons.library_books,
  iconColor: AppColors.primary,
)
```

---

### 5. Spacing Components

#### `AppGap` - Vertical Spacing with Multiple Children

**MERN Comparison:**
```jsx
// React - CSS Gap
<div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
  <div>Item 1</div>
  <div>Item 2</div>
</div>

// Flutter
AppGap(
  gap: 16,
  children: [Text('Item 1'), Text('Item 2')],
)
```

```dart
AppGap(
  gap: AppSpacing.lg,
  children: [
    Text('Book Title'),
    Text('Author Name'),
    AppButton(label: 'Add'),
  ],
)
```

---

#### `AppHorizontalGap` - Horizontal Spacing

```dart
AppHorizontalGap(
  gap: AppSpacing.md,
  children: [
    Icon(Icons.star),
    Text('4.5'),
  ],
)
```

---

#### `AppPadding` - Padding Wrapper

```dart
AppPadding(
  all: AppSpacing.lg,
  child: Text('Content'),
)

// Or specific sides
AppPadding(
  horizontal: AppSpacing.lg,
  vertical: AppSpacing.md,
  child: Text('Content'),
)
```

---

### 6. Dialog Components

#### Snackbars (Toast Notifications)

**MERN Comparison:**
```javascript
// React with React-Toastify
import { toast } from 'react-toastify';
toast.success('Book added!');
toast.error('Failed to load');

// Flutter
AppSnackbars.success(context, 'Book added!');
AppSnackbars.error(context, 'Failed to load');
```

```dart
// Success
AppSnackbars.success(context, 'Book added successfully!');

// Error
AppSnackbars.error(context, 'Failed to load books');

// Warning
AppSnackbars.warning(context, 'This book is not available');

// Info
AppSnackbars.info(context, 'New recommendations available');

// Custom
AppSnackbars.show(
  context,
  'Custom message',
  type: SnackbarType.info,
  durationSeconds: 5,
)
```

---

#### Confirmation Dialog

```dart
final confirmed = await AppDialogs.confirm(
  context,
  title: 'Delete Book?',
  message: 'This action cannot be undone.',
  confirmLabel: 'Delete',
  cancelLabel: 'Keep',
  isDangerous: true,
);

if (confirmed) {
  // Handle deletion
}
```

---

#### Alert Dialog

```dart
await AppDialogs.alert(
  context,
  title: 'Error',
  message: 'Failed to add book. Please try again.',
  buttonLabel: 'OK',
);
```

---

#### Custom Dialog

```dart
await AppDialogs.custom(
  context,
  title: 'Filter Books',
  content: MyFilterWidget(),
  actions: [
    AppOutlinedButton(label: 'Cancel'),
    AppButton(label: 'Apply'),
  ],
);
```

---

#### Bottom Sheet Dialog

```dart
await AppDialogs.bottomSheet(
  context,
  title: 'Sort Options',
  content: ListView(
    children: [
      ListTile(title: Text('By Title')),
      ListTile(title: Text('By Author')),
      ListTile(title: Text('By Rating')),
    ],
  ),
);
```

---

## MERN Comparisons

### State Management

| Concept | MERN | Flutter |
|---------|------|---------|
| **Global State** | Redux / Context API | Riverpod / Provider |
| **Local State** | useState | StatefulWidget / setState |
| **Side Effects** | Redux Thunks | Riverpod AsyncNotifier |
| **Caching** | Redux cache | Riverpod caching |

---

### Data Fetching

| MERN | Flutter |
|------|---------|
| `fetch()` / Axios | `Dio` / `http` package |
| Express API | Cloud Functions / Firestore |
| MongoDB | Firestore (document database) |
| REST endpoints | `collection('users').get()` |

---

### Component Props vs Widget Parameters

```jsx
// React
function BookCard({ title, author, image, rating, onTap }) {
  return <div onClick={onTap}>...</div>;
}

// Flutter
class BookCard extends StatelessWidget {
  final String title;
  final String author;
  final String? image;
  final double? rating;
  final VoidCallback? onTap;
  
  const BookCard({
    required this.title,
    required this.author,
    ...
  });
}
```

---

### Firestore vs MongoDB

```javascript
// MongoDB via Express
router.get('/books/:id', async (req, res) => {
  const book = await Book.findById(req.params.id);
  res.json(book);
});

// Firestore
final doc = await FirebaseFirestore.instance
  .collection('books')
  .doc(bookId)
  .get();
final book = Book.fromFirestore(doc);
```

---

## Usage Examples

### Complete Example: Add Book Form

**React Version:**
```jsx
function AddBookForm() {
  const [title, setTitle] = useState('');
  const [author, setAuthor] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  async function handleSubmit(e) {
    e.preventDefault();
    setLoading(true);
    try {
      await fetch('/api/books', {
        method: 'POST',
        body: JSON.stringify({ title, author }),
      });
      toast.success('Book added!');
    } catch (err) {
      setError(err.message);
      toast.error(err.message);
    } finally {
      setLoading(false);
    }
  }

  return (
    <form onSubmit={handleSubmit}>
      <TextField
        label="Title"
        value={title}
        onChange={(e) => setTitle(e.target.value)}
      />
      <TextField
        label="Author"
        value={author}
        onChange={(e) => setAuthor(e.target.value)}
      />
      {error && <Alert severity="error">{error}</Alert>}
      <Button type="submit" loading={loading}>
        Add Book
      </Button>
    </form>
  );
}
```

**Flutter Version:**
```dart
class AddBookPage extends StatefulWidget {
  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final titleCtrl = TextEditingController();
  final authorCtrl = TextEditingController();
  bool isLoading = false;
  String? error;

  @override
  void dispose() {
    titleCtrl.dispose();
    authorCtrl.dispose();
    super.dispose();
  }

  Future<void> handleSubmit() async {
    setState(() => isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('books').add({
        'title': titleCtrl.text,
        'author': authorCtrl.text,
        'createdAt': Timestamp.now(),
      });
      
      if (mounted) {
        AppSnackbars.success(context, 'Book added!');
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => error = e.toString());
      if (mounted) {
        AppSnackbars.error(context, error!);
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Book')),
      body: AppPadding(
        all: AppSpacing.lg,
        child: AppGap(
          gap: AppSpacing.lg,
          children: [
            AppTextField(
              controller: titleCtrl,
              label: 'Book Title',
              hint: 'Enter title',
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Required';
                return null;
              },
            ),
            AppTextField(
              controller: authorCtrl,
              label: 'Author',
              hint: 'Enter author name',
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Required';
                return null;
              },
            ),
            AppButton(
              onPressed: handleSubmit,
              label: 'Add Book',
              isLoading: isLoading,
              fullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Best Practices

### 1. Always Use Named Parameters

```dart
// ✅ Good
AppButton(
  onPressed: () => save(),
  label: 'Save',
  isLoading: isSaving,
)

// ❌ Avoid
AppButton(() => save(), 'Save', false)
```

---

### 2. Use Theme Constants

```dart
// ✅ Good
Padding(
  padding: const EdgeInsets.all(AppSpacing.lg),
  child: child,
)

// ❌ Avoid
Padding(
  padding: const EdgeInsets.all(16.0),
  child: child,
)
```

---

### 3. Create Component Wrappers for Features

```dart
// In features/books/presentation/widgets/
class BookSearchBar extends StatelessWidget {
  final void Function(String)? onSearch;
  
  const BookSearchBar({this.onSearch});

  @override
  Widget build(BuildContext context) {
    return AppSearchField(
      hint: 'Search library...',
      onChanged: onSearch,
    );
  }
}
```

---

### 4. Dispose Resources Properly

```dart
class BookDetailsPage extends StatefulWidget {
  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  late ScrollController _scrollCtrl;
  late TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController();
    _searchCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => // ...
}
```

---

### 5. Consistent Naming Conventions

```dart
// Components: AppXxxxx
AppButton
AppTextField
AppCard

// Pages/Screens: XxxxxPage or XxxxxScreen
BookDetailsPage
SearchResultsPage

// Controllers: xxxController
titleController
emailController

// State variables: _xxx or xxx
_isLoading
_selectedGenre
```

---

## Next Steps

1. **Run pub get** - Install dependencies:
   ```bash
   flutter pub get
   ```

2. **Check your app compiles**:
   ```bash
   flutter analyze
   ```

3. **Use components in features** - See `features/books/` for implementation examples

4. **Extend components** - Add more variants based on feature needs

---

## Resources

- 📱 [Flutter Official Docs](https://flutter.dev/docs)
- 🎨 [Material Design 3](https://m3.material.io/)
- 🔥 [Firebase Documentation](https://firebase.google.com/docs/flutter/setup)
- 📦 [Pub.dev Packages](https://pub.dev)

---

**Remember:** Clean architecture isn't about perfection—it's about maintainability, testability, and team velocity! 🚀
