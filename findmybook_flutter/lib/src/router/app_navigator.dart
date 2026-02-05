import 'package:flutter/material.dart';
import 'app_route.dart';
import 'app_router_delegate.dart';

/// Provides convenient methods for navigating throughout the app
/// This is a service class that wraps the AppRouterDelegate
class AppNavigator {
  static AppRouterDelegate? _delegate;

  /// Initialize the navigator with the router delegate
  static void init(AppRouterDelegate delegate) {
    _delegate = delegate;
  }

  /// Get the current router delegate
  static AppRouterDelegate get delegate {
    if (_delegate == null) {
      throw Exception('AppNavigator not initialized. Call AppNavigator.init() first.');
    }
    return _delegate!;
  }

  /// Navigate to the login page
  static void toLogin() {
    delegate.clearAndPush(const AppRoute(type: AppRouteType.login, path: '/login'));
  }

  /// Navigate to the register page
  static void toRegister() {
    delegate.push(const AppRoute(type: AppRouteType.register, path: '/register'));
  }

  /// Navigate to the home page
  static void toHome() {
    delegate.clearAndPush(const AppRoute(type: AppRouteType.home, path: '/home'));
  }

  /// Pop the current page
  static void pop({dynamic result}) {
    if (delegate.navigatorKey.currentState != null) {
      delegate.navigatorKey.currentState!.pop(result);
    } else {
      delegate.pop();
    }
  }

  /// Check if we can pop
  static bool canPop() {
    return delegate.routeStack.length > 1;
  }

  /// Get the current route
  static AppRoute get currentRoute => delegate.currentRoute;

  /// Get the route stack
  static List<AppRoute> get routeStack => delegate.routeStack;
}
