# Navigator 2.0 Implementation Guide

This document explains how to use the Navigator 2.0 navigation system implemented in this app.

## Overview

The navigation system is built using Flutter's **Navigator 2.0** (also known as "Declarative Navigation"). This provides:

- **Declarative routing**: Routes are part of the widget tree
- **Deep linking support**: URLs map directly to app screens
- **Better state management**: Navigation state is centralized
- **Web support**: Works seamlessly with web navigation

## Architecture Components

### 1. **AppRoute** (`app_route.dart`)
Represents a single route in the application with:
- `type`: The kind of route (login, register, home)
- `path`: The string path of the route
- `id`: Optional parameter for passing data

### 2. **AppRouteInformationParser** (`app_route_information_parser.dart`)
Converts between:
- URL paths → AppRoute objects (for deep linking)
- AppRoute objects → URL paths (for browser history)

### 3. **AppRouterDelegate** (`app_router_delegate.dart`)
Manages:
- Navigation stack (list of pages)
- Building the Navigator widget
- Handling navigation operations (push, pop, replace)

### 4. **AppNavigator** (`app_navigator.dart`)
Provides convenient static methods for navigation from anywhere in your app.

## Usage Examples

### Basic Navigation

```dart
// Navigate to login page
AppNavigator.toLogin();

// Navigate to register page
AppNavigator.toRegister();

// Navigate to home page
AppNavigator.toHome();

// Pop the current page
AppNavigator.pop();
```

### Advanced Navigation

```dart
// Push a custom route
AppNavigator.delegate.push(
  const AppRoute(type: AppRouteType.home, path: '/home'),
);

// Replace current route
AppNavigator.delegate.replace(
  const AppRoute(type: AppRouteType.login, path: '/login'),
);

// Clear stack and push new route
AppNavigator.delegate.clearAndPush(
  const AppRoute(type: AppRouteType.home, path: '/home'),
);

// Pop until a specific route type
AppNavigator.delegate.popUntil(AppRouteType.home);

// Check current route
if (AppNavigator.currentRoute.type == AppRouteType.home) {
  print('Currently on home page');
}

// Check if we can pop
if (AppNavigator.canPop()) {
  AppNavigator.pop();
}
```

## Using in Your Pages

### Example: Login Page Navigation

```dart
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              // After successful login
              AppNavigator.toHome();
            },
            child: const Text('Login'),
          ),
          TextButton(
            onPressed: () {
              AppNavigator.toRegister();
            },
            child: const Text('Go to Register'),
          ),
        ],
      ),
    );
  }
}
```

### Example: Home Page with Back Button

```dart
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        leading: AppNavigator.canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => AppNavigator.pop(),
              )
            : null,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            AppNavigator.toLogin();
          },
          child: const Text('Logout'),
        ),
      ),
    );
  }
}
```

## Adding New Routes

To add a new route to your app:

### 1. Update `AppRouteType` enum in `app_route.dart`

```dart
enum AppRouteType {
  login,
  register,
  home,
  bookDetails,  // NEW
  unknown,
}
```

### 2. Update `AppRoute.fromPath()` in `app_route.dart`

```dart
if (pathWithoutLeadingSlash.startsWith('book-details')) {
  final id = Uri.parse(path).queryParameters['id'];
  return AppRoute(
    type: AppRouteType.bookDetails,
    path: '/book-details',
    id: id,
  );
}
```

### 3. Update `AppRouterDelegate._buildPage()` in `app_router_delegate.dart`

```dart
case AppRouteType.bookDetails:
  return MaterialPage<void>(
    key: ValueKey<AppRoute>(route),
    child: BookDetailsPage(bookId: route.id),
  );
```

### 4. Add navigation method to `AppNavigator` in `app_navigator.dart`

```dart
static void toBookDetails(String bookId) {
  delegate.push(
    AppRoute(
      type: AppRouteType.bookDetails,
      path: '/book-details',
      id: bookId,
    ),
  );
}
```

### 5. Use in your code

```dart
// Navigate to book details
AppNavigator.toBookDetails('book-123');
```

## Benefits of Navigator 2.0

1. **Declarative**: Routes are part of the widget tree
2. **Type-safe**: Compile-time checking of navigation
3. **Deep linking**: URLs automatically map to screens
4. **State preservation**: Back button works correctly
5. **Browser history**: Web apps maintain proper history
6. **Testable**: Easy to test navigation logic

## Testing Navigation

```dart
void main() {
  testWidgets('Navigation test', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    
    // Verify we start on login page
    expect(find.byType(LoginPage), findsOneWidget);
    
    // Navigate to register
    AppNavigator.toRegister();
    await tester.pumpAndSettle();
    
    // Verify we're on register page
    expect(find.byType(RegisterPage), findsOneWidget);
  });
}
```

## Common Patterns

### Authentication Flow
```dart
// After login succeeds
AppNavigator.toHome();

// On logout
AppNavigator.toLogin();
```

### Nested Navigation
```dart
// You can maintain multiple navigation stacks
AppNavigator.delegate.push(route1);
AppNavigator.delegate.push(route2);

// Pop back through them
AppNavigator.pop(); // Goes to route1
AppNavigator.pop(); // Goes to previous screen
```

### Conditional Navigation
```dart
if (isLoggedIn) {
  AppNavigator.toHome();
} else {
  AppNavigator.toLogin();
}
```

## Troubleshooting

### Navigator not initialized
**Error**: "AppNavigator not initialized"
**Solution**: Ensure `AppNavigator.init(_routerDelegate)` is called in your App's initState

### Routes not appearing
**Error**: Pages don't show up
**Solution**: Make sure the route type is handled in `AppRouterDelegate._buildPage()`

### Deep linking not working
**Solution**: Verify your route parsing logic in `AppRoute.fromPath()` matches your route structure
