/// Service Locator setup using GetIt
/// 
/// This is our **Dependency Injection container** (↔ React Context/Redux store)
/// 
/// MERN Comparison:
/// - GetIt ↔ Express middleware initialization
/// - Registering singletons ↔ Creating Express app instances
/// - Lazy singletons ↔ Lazy loading modules in Express

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:smart_library_app/src/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:smart_library_app/src/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:smart_library_app/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:smart_library_app/src/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:smart_library_app/src/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:smart_library_app/src/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:smart_library_app/src/features/books/data/datasources/books_remote_datasource.dart';
import 'package:smart_library_app/src/features/books/data/repositories/books_repository_impl.dart';
import 'package:smart_library_app/src/features/books/domain/repositories/books_repository.dart';
import 'package:smart_library_app/src/features/books/domain/usecases/get_books_usecase.dart';
import 'package:smart_library_app/src/features/books/domain/usecases/search_books_usecase.dart';
import 'package:smart_library_app/src/features/borrowed_books/data/datasources/borrowed_books_datasource.dart';
import 'package:smart_library_app/src/features/borrowed_books/data/repositories/borrowed_books_repository_impl.dart';
import 'package:smart_library_app/src/features/borrowed_books/domain/repositories/borrowed_books_repository.dart';
import 'package:smart_library_app/src/features/borrowed_books/domain/usecases/get_borrowed_books_usecase.dart';
import 'package:smart_library_app/src/features/reservations/data/datasources/reservations_datasource.dart';
import 'package:smart_library_app/src/features/reservations/data/repositories/reservations_repository_impl.dart';
import 'package:smart_library_app/src/features/reservations/domain/repositories/reservations_repository.dart';
import 'package:smart_library_app/src/features/reservations/domain/usecases/reserve_book_usecase.dart';

final getIt = GetIt.instance;

/// Setup the service locator with all dependencies
/// Call this in main() before running the app
Future<void> setupServiceLocator() async {
  // ============================================================================
  // Firebase instances (Singletons - shared across entire app)
  // ============================================================================
  
  getIt.registerSingleton<FirebaseAuth>(
    FirebaseAuth.instance,
  );

  getIt.registerSingleton<FirebaseFirestore>(
    FirebaseFirestore.instance,
  );

  // ============================================================================
  // Authentication Feature
  // ============================================================================

  // Remote data source (Firebase Auth + Firestore)
  getIt.registerSingleton<AuthRemoteDataSource>(
    AuthRemoteDataSourceImpl(
      firebaseAuth: getIt<FirebaseAuth>(),
      firestore: getIt<FirebaseFirestore>(),
    ),
  );

  // Repository implementation
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
    ),
  );

  // Use cases (Lazy - only created when needed)
  getIt.registerLazySingleton<SignUpUseCase>(
    () => SignUpUseCase(repository: getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<SignInUseCase>(
    () => SignInUseCase(repository: getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<SignOutUseCase>(
    () => SignOutUseCase(repository: getIt<AuthRepository>()),
  );

  // ============================================================================
  // Books Feature
  // ============================================================================

  getIt.registerSingleton<BooksRemoteDataSource>(
    BooksRemoteDataSourceImpl(
      firestore: getIt<FirebaseFirestore>(),
    ),
  );

  getIt.registerSingleton<BooksRepository>(
    BooksRepositoryImpl(
      remoteDataSource: getIt<BooksRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<GetBooksUseCase>(
    () => GetBooksUseCase(repository: getIt<BooksRepository>()),
  );

  getIt.registerLazySingleton<SearchBooksUseCase>(
    () => SearchBooksUseCase(repository: getIt<BooksRepository>()),
  );

  // ============================================================================
  // Borrowed Books Feature
  // ============================================================================

  getIt.registerSingleton<BorrowedBooksRemoteDataSource>(
    BorrowedBooksRemoteDataSourceImpl(
      firestore: getIt<FirebaseFirestore>(),
    ),
  );

  getIt.registerSingleton<BorrowedBooksRepository>(
    BorrowedBooksRepositoryImpl(
      remoteDataSource: getIt<BorrowedBooksRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<GetBorrowedBooksUseCase>(
    () => GetBorrowedBooksUseCase(repository: getIt<BorrowedBooksRepository>()),
  );

  // ============================================================================
  // Reservations Feature
  // ============================================================================

  getIt.registerSingleton<ReservationsRemoteDataSource>(
    ReservationsRemoteDataSourceImpl(
      firestore: getIt<FirebaseFirestore>(),
    ),
  );

  getIt.registerSingleton<ReservationsRepository>(
    ReservationsRepositoryImpl(
      remoteDataSource: getIt<ReservationsRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<ReserveBookUseCase>(
    () => ReserveBookUseCase(repository: getIt<ReservationsRepository>()),
  );
}
