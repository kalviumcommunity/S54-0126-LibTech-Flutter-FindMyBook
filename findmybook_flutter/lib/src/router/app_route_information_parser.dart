import 'package:flutter/material.dart';
import 'app_route.dart';

/// Parser for converting URI routes to AppRoute objects
/// This implements the RouteInformationParser interface for Navigator 2.0
class AppRouteInformationParser extends RouteInformationParser<AppRoute> {
  @override
  Future<AppRoute> parseRouteInformation(RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location ?? '/');
    return AppRoute.fromPath(uri.path);
  }

  @override
  RouteInformation? restoreRouteInformation(AppRoute configuration) {
    return RouteInformation(location: configuration.toPath());
  }
}
