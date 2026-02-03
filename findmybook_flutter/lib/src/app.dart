import 'package:flutter/material.dart';
import 'core/theme/index.dart';
import 'features/books/presentation/pages/home_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Library',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      routes: {
        '/': (c) => const HomePage(),
        '/login': (c) => const LoginPage(),
        '/register': (c) => const RegisterPage(),
      },
    );
  }
}
