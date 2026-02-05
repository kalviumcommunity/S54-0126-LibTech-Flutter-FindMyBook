import 'package:flutter/material.dart';
import 'router/router.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AppRouterDelegate _routerDelegate;
  late final AppRouteInformationParser _routeInformationParser;

  @override
  void initState() {
    super.initState();
    _routerDelegate = AppRouterDelegate();
    _routeInformationParser = AppRouteInformationParser();
    
    // Initialize the AppNavigator service
    AppNavigator.init(_routerDelegate);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Smart Library',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      routerDelegate: _routerDelegate,
      routeInformationParser: _routeInformationParser,
      routeInformationProvider: PlatformRouteInformationProvider(
        initialRouteInformation: const RouteInformation(location: '/login'),
      ),
    );
  }
}
