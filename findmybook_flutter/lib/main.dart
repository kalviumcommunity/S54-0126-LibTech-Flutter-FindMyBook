import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'src/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FirebaseInitApp());
}

/// Lightweight bootstrap that initializes Firebase then shows the real `App`.
class FirebaseInitApp extends StatelessWidget {
  const FirebaseInitApp({super.key});

  Future<FirebaseApp> _initializeFirebase() async {
    return Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseApp>(
      future: _initializeFirebase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator())));
        }

        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 48),
                    const SizedBox(height: 12),
                    const Text('Firebase connection failed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(snapshot.error.toString()),
                  ],
                ),
              ),
            ),
          );
        }

        return const App();
      },
    );
  }
}