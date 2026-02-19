# FindMyBook Flutter

Production-style Smart Library app built with Flutter + Firebase.

## Refactored Architecture

```
lib/
  app/
  core/
    constants/
    errors/
    firebase/
    theme/
  features/
    auth/
    books/
    reservations/
    borrow/
    maps/
  shared/
    widgets/
```

- UI widgets do not call Firebase directly.
- Repositories + services isolate data access.
- Riverpod handles async state and stream lifecycle.
- Firestore transactions enforce reservation/borrow consistency.

## Firebase Collections

- `books`: `title`, `author`, `category`, `totalCopies`, `availableCopies`, `reservedCopies`, `libraryId`
- `reservations`: `bookId`, `userId`, `bookTitle`, `bookAuthor`, `reservedAt`, `expiresAt`, `status`
- `borrows`: `bookId`, `userId`, `title`, `author`, `borrowedAt`, `dueAt`, `returnedAt`, `status`
- `libraries`: `name`, `address`, `lat`, `lng`

## Required Cloud Function

Create HTTPS callable function `validateReservation` that returns:

```json
{ "allowed": true, "reason": "" }
```

If `allowed` is `false`, reservation is blocked before transaction write.

## Security and Indexing

- Firestore rules: `firestore.rules`
- Firestore indexes: `firestore.indexes.json`
- Deploy with:
  - `firebase deploy --only firestore:rules`
  - `firebase deploy --only firestore:indexes`

## Google Maps Setup

Android manifest is configured with placeholder key:

```kts
manifestPlaceholders["MAPS_API_KEY"] = "YOUR_KEY"
```

Provide actual key in `android/gradle.properties`:

```properties
MAPS_API_KEY=YOUR_KEY
```

## Run

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```
