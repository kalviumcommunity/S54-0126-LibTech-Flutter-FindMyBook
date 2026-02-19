import "package:flutter/material.dart";

class GlobalErrorHandler {
  static void onFlutterError(FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint("FlutterError: ${details.exception}");
    debugPrintStack(stackTrace: details.stack);
  }

  static void onZoneError(Object error, StackTrace stackTrace) {
    debugPrint("ZoneError: $error");
    debugPrintStack(stackTrace: stackTrace);
  }

  static Widget fallbackErrorScreen(Object error) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              "Something went wrong.\n$error",
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
