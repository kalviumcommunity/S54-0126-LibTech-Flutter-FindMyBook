import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../auth/presentation/auth_controller.dart";
import "../../../shared/widgets/empty_state.dart";
import "../../../shared/widgets/error_state.dart";
import "../../../shared/widgets/loading_skeleton.dart";
import "../domain/book.dart";
import "books_providers.dart";
import "widgets/book_card.dart";

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _searchController = TextEditingController();
  String _selectedCategory = "All";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Book> _applyFilters(List<Book> books) {
    final query = _searchController.text.trim().toLowerCase();
    return books.where((book) {
      final matchSearch = query.isEmpty ||
          book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query);
      final matchCategory =
          _selectedCategory == "All" || book.category == _selectedCategory;
      return matchSearch && matchCategory;
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(booksStreamProvider);
    final authLoading = ref.watch(authControllerProvider).isLoading;
    final seedState = ref.watch(bookSeedControllerProvider);

    ref.listen<AsyncValue<void>>(bookSeedControllerProvider, (prev, next) {
      if (!next.isLoading && next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error.toString())),
        );
      } else if (!next.isLoading && prev?.isLoading == true && !next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sample books added.")),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("FindMyBook"),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, "/reservations"),
            icon: const Icon(Icons.bookmark_border),
            tooltip: "Reservations",
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, "/borrowed"),
            icon: const Icon(Icons.library_books_outlined),
            tooltip: "Borrowed books",
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, "/maps"),
            icon: const Icon(Icons.map_outlined),
            tooltip: "Libraries map",
          ),
          IconButton(
            onPressed: authLoading
                ? null
                : () => ref.read(authControllerProvider.notifier).signOut(),
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
          ),
        ],
      ),
      body: booksAsync.when(
        data: (books) {
          final categories = {
            "All",
            ...books.map((book) => book.category),
          }.toList(growable: false);
          final filtered = _applyFilters(books);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: "Search by title or author",
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: categories
                            .map(
                              (category) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(category),
                                  selected: _selectedCategory == category,
                                  onSelected: (_) {
                                    setState(() {
                                      _selectedCategory = category;
                                    });
                                  },
                                ),
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: books.isEmpty
                    ? EmptyState(
                        icon: Icons.menu_book_outlined,
                        title: "No books in library",
                        subtitle: "Your Firestore books collection is empty.",
                        action: ElevatedButton.icon(
                          onPressed: seedState.isLoading
                              ? null
                              : () => ref.read(bookSeedControllerProvider.notifier).seed(),
                          icon: seedState.isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.auto_fix_high),
                          label: const Text("Add sample books"),
                        ),
                      )
                    : filtered.isEmpty
                        ? const EmptyState(
                            icon: Icons.search_off,
                            title: "No books found",
                            subtitle: "Try a different keyword or category filter.",
                          )
                        : ListView.builder(
                        itemCount: filtered.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          final book = filtered[index];
                          return BookCard(
                            book: book,
                            onTap: () => Navigator.pushNamed(
                              context,
                              "/book-details",
                              arguments: book,
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const LoadingSkeleton(),
        error: (error, _) => ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(booksStreamProvider),
        ),
      ),
    );
  }
}
