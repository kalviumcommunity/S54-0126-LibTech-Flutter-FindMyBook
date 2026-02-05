/// Enum representing all available routes in the application
enum AppRouteType {
  login,
  register,
  home,
  unknown,
}

/// Immutable class representing an app route
class AppRoute {
  final AppRouteType type;
  final String path;
  final String? id;

  const AppRoute({
    required this.type,
    required this.path,
    this.id,
  });

  /// Factory constructor to parse route from path
  factory AppRoute.fromPath(String path) {
    // Remove leading slash if present
    final pathWithoutLeadingSlash = path.startsWith('/') ? path.substring(1) : path;

    if (pathWithoutLeadingSlash.isEmpty || pathWithoutLeadingSlash == 'home') {
      return const AppRoute(
        type: AppRouteType.home,
        path: '/home',
      );
    }

    if (pathWithoutLeadingSlash.startsWith('login')) {
      return const AppRoute(
        type: AppRouteType.login,
        path: '/login',
      );
    }

    if (pathWithoutLeadingSlash.startsWith('register')) {
      return const AppRoute(
        type: AppRouteType.register,
        path: '/register',
      );
    }

    // Unknown route
    return AppRoute(
      type: AppRouteType.unknown,
      path: path,
    );
  }

  /// Convert route to path string
  String toPath() => path;

  @override
  String toString() => 'AppRoute(type: $type, path: $path, id: $id)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppRoute &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          path == other.path &&
          id == other.id;

  @override
  int get hashCode => type.hashCode ^ path.hashCode ^ id.hashCode;
}
