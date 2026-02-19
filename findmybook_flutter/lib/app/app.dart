import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../core/theme/app_theme.dart";
import "../features/auth/presentation/auth_controller.dart";
import "../features/auth/presentation/login_page.dart";
import "../features/auth/presentation/register_page.dart";
import "../features/books/domain/book.dart";
import "../features/books/presentation/book_details_page.dart";
import "../features/books/presentation/home_page.dart";
import "../features/borrow/presentation/my_borrowed_books_page.dart";
import "../features/maps/presentation/libraries_map_page.dart";
import "../features/reservations/presentation/my_reservations_page.dart";
import "../shared/widgets/error_state.dart";

class LibraryApp extends ConsumerWidget {
  const LibraryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: "FindMyBook",
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case "/register":
            return _page(const RegisterPage());
          case "/home":
            return _page(const HomePage());
          case "/reservations":
            return _page(const MyReservationsPage());
          case "/borrowed":
            return _page(const MyBorrowedBooksPage());
          case "/maps":
            return _page(const LibrariesMapPage());
          case "/book-details":
            final book = settings.arguments;
            if (book is! Book) {
              return _page(
                const Scaffold(
                  body: ErrorState(message: "Invalid book details route."),
                ),
              );
            }
            return _page(BookDetailsPage(book: book));
          case "/":
          default:
            return _page(const _AuthGate());
        }
      },
      initialRoute: "/",
    );
  }

  MaterialPageRoute<void> _page(Widget child) {
    return MaterialPageRoute<void>(builder: (_) => child);
  }
}

class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateChangesProvider);
    return auth.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(body: ErrorState(message: error.toString())),
      data: (user) => user == null ? const LoginPage() : const HomePage(),
    );
  }
}
