import 'package:flutter/material.dart';

void main() {
  runApp(const FindMyBookApp());
}

class FindMyBookApp extends StatelessWidget {
  const FindMyBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FindMyBook',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ResponsiveHomePage(),
    );
  }
}

class Book {
  final String title;
  final String author;
  final String imageUrl;
  final String description;

  const Book({
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.description,
  });
}

final List<Book> sampleBooks = [
  const Book(
    title: 'Flutter Apprentice',
    author: 'Mike Katz',
    imageUrl: 'https://tinyurl.com/flutter-apprentice-cover', // Placeholder
    description: 'Learn to build cross-platform apps with Flutter and Dart.',
  ),
  const Book(
    title: 'Clean Architecture',
    author: 'Robert C. Martin',
    imageUrl: 'https://tinyurl.com/clean-arch-cover', // Placeholder
    description: 'A Craftsman\'s Guide to Software Structure and Design.',
  ),
  const Book(
    title: 'Dart for Absolute Beginners',
    author: 'David Kopec',
    imageUrl: 'https://tinyurl.com/dart-beginners-cover', // Placeholder
    description: 'Get started with the Dart programming language.',
  ),
  const Book(
    title: 'Refactoring',
    author: 'Martin Fowler',
    imageUrl: 'https://tinyurl.com/refactoring-cover', // Placeholder
    description: 'Improving the Design of Existing Code.',
  ),
  const Book(
    title: 'The Pragmatic Programmer',
    author: 'Andrew Hunt',
    imageUrl: 'https://tinyurl.com/pragmatic-prog-cover', // Placeholder
    description: 'Your Journey to Mastery.',
  ),
];

class ResponsiveHomePage extends StatelessWidget {
  const ResponsiveHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Media Query Example:
    // Using MediaQuery to get the screen size for decisions that might not be purely layout driven
    // or to pass down to children. Here we just print it for demo purposes or use it for high-level logic.
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('FindMyBook (${screenSize.width.toInt()}px)'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      // LayoutBuilder Example:
      // This is the core of our responsive logic. It gives us the constraints
      // of the parent widget (in this case, the Scaffold body).
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            // Wide screen (Tablet/Desktop) -> Grid View
            return const BookGrid();
          } else {
            // Narrow screen (Mobile) -> List View
            return const BookList();
          }
        },
      ),
    );
  }
}

class BookList extends StatelessWidget {
  const BookList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: sampleBooks.length,
      itemBuilder: (context, index) {
        return BookCard(book: sampleBooks[index], isCompact: true);
      },
    );
  }
}

class BookGrid extends StatelessWidget {
  const BookGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Display 3 columns on wider screens
        childAspectRatio: 0.8,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      padding: const EdgeInsets.all(10),
      itemCount: sampleBooks.length,
      itemBuilder: (context, index) {
        return BookCard(book: sampleBooks[index], isCompact: false);
      },
    );
  }
}

class BookCard extends StatelessWidget {
  final Book book;
  final bool isCompact;

  const BookCard({
    super.key,
    required this.book,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: isCompact 
          ? _buildHorizontalLayout(context) 
          : _buildVerticalLayout(context),
    );
  }

  // Flexible Application:
  // In the horizontal layout, we handle a Row. We want the image to take fixed space
  // or a portion, and the text to fill the rest.
  Widget _buildHorizontalLayout(BuildContext context) {
    return Row(
      children: [
        // Image acts as a fixed visual anchor
        Container(
          width: 80,
          height: 120,
          color: Colors.grey[300], // Placeholder for actual image
          child: const Icon(Icons.book, size: 40, color: Colors.grey),
        ),
        const SizedBox(width: 10),
        // Expanded forces the Column to take strictly the remaining available space
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                book.title,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                book.author,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              // Flexible allows the description to take space if available, but not force it if empty
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    book.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Expanded here makes the image area fill the vertical space available above text
        Expanded(
          flex: 2,
          child: Container(
            color: Colors.grey[300],
            child: const Icon(Icons.book, size: 60, color: Colors.grey),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                book.title,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(book.author, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              Text(
                book.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}