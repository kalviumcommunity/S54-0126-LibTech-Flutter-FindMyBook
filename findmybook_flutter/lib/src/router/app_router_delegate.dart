import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/books/presentation/pages/home_page.dart';
import 'app_route.dart';

/// Delegate for managing app navigation using Navigator 2.0
/// This class is responsible for building the navigation stack
class AppRouterDelegate extends RouterDelegate<AppRoute>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoute> {
  /// The navigation key for the Navigator widget
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  AppRouterDelegate() {
    _initAuthState();
  }

  /// Stack of routes to maintain navigation history
  final List<AppRoute> _routeStack = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final StreamSubscription<User?> _authSub;

  /// Getter for the current route
  AppRoute get currentRoute => _routeStack.last;

  /// Get the current route stack
  List<AppRoute> get routeStack => List.unmodifiable(_routeStack);

  /// Push a new route onto the stack
  void push(AppRoute route) {
    _routeStack.add(route);
    notifyListeners();
  }

  /// Initialize authentication state and listener
  void _initAuthState() {
    // set initial stack based on current user
    final user = _auth.currentUser;
    if (user != null) {
      _routeStack.clear();
      _routeStack.add(const AppRoute(type: AppRouteType.home, path: '/home'));
    } else {
      _routeStack.clear();
      _routeStack.add(const AppRoute(type: AppRouteType.login, path: '/login'));
    }

    // listen for auth changes and update navigation accordingly
    _authSub = _auth.authStateChanges().listen((u) {
      if (u == null) {
        // signed out -> go to login
        clearAndPush(const AppRoute(type: AppRouteType.login, path: '/login'));
      } else {
        // signed in -> go to home
        clearAndPush(const AppRoute(type: AppRouteType.home, path: '/home'));
      }
    });
  }

  /// Pop the current route from the stack
  bool pop() {
    if (_routeStack.length > 1) {
      _routeStack.removeLast();
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Pop until we reach a route of the specified type
  void popUntil(AppRouteType routeType) {
    while (_routeStack.length > 1 && _routeStack.last.type != routeType) {
      _routeStack.removeLast();
    }
    notifyListeners();
  }

  /// Replace the current route with a new one
  void replace(AppRoute route) {
    if (_routeStack.isNotEmpty) {
      _routeStack.removeLast();
    }
    _routeStack.add(route);
    notifyListeners();
  }

  /// Clear the entire stack and set a new route
  void clearAndPush(AppRoute route) {
    print('clearAndPush called with route: $route');
    _routeStack.clear();
    _routeStack.add(route);
    print('Route stack after clearAndPush: $_routeStack');
    notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        for (final route in _routeStack)
          _buildPage(route),
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }
        pop();
        return true;
      },
    );
  }

  /// Build a page for the given route
  Page<void> _buildPage(AppRoute route) {
    switch (route.type) {
      case AppRouteType.login:
        return MaterialPage<void>(
          key: ValueKey<AppRoute>(route),
          child: const LoginPage(),
        );

      case AppRouteType.register:
        return MaterialPage<void>(
          key: ValueKey<AppRoute>(route),
          child: const RegisterPage(),
        );

      case AppRouteType.home:
        return MaterialPage<void>(
          key: ValueKey<AppRoute>(route),
          child: const HomePage(),
        );

      case AppRouteType.unknown:
        return MaterialPage<void>(
          key: ValueKey<AppRoute>(route),
          child: Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(
              child: Text('Page not found'),
            ),
          ),
        );
    }
  }

  @override
  Future<void> setNewRoutePath(AppRoute configuration) async {
    _routeStack.clear();
    _routeStack.add(configuration);
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }
}
