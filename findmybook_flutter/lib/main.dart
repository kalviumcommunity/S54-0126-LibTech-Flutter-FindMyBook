import "dart:async";

import "package:firebase_core/firebase_core.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "app/app.dart";
import "core/errors/global_error_handler.dart";
import "firebase_options.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = GlobalErrorHandler.onFlutterError;

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runZonedGuarded(
    () => runApp(const ProviderScope(child: LibraryApp())),
    GlobalErrorHandler.onZoneError,
  );
}