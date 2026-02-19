class FirestorePaths {
  static const books = "books";
  static const reservations = "reservations";
  static const borrows = "borrows";
  static const libraries = "libraries";

  static String book(String id) => "$books/$id";
  static String reservation(String id) => "$reservations/$id";
  static String borrow(String id) => "$borrows/$id";
  static String library(String id) => "$libraries/$id";
}
