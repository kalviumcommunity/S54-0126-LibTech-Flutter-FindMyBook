class Book {
  final String id;
  final String title;
  final String author;
  final String category;
  final int totalCopies;
  final int availableCopies;
  final int reservedCopies;
  final String? coverUrl;
  final String? libraryId;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.totalCopies,
    required this.availableCopies,
    required this.reservedCopies,
    this.coverUrl,
    this.libraryId,
  });

  bool get isAvailable => (availableCopies - reservedCopies) > 0;
}
