/// Concrete implementation of AuthRepository
/// 
/// This bridges the gap between domain and data layers
/// - Takes remote data source (Firebase)
/// - Converts exceptions to domain exceptions
/// - Converts models to entities
/// - Returns Either<Exception, Entity> for functional error handling
/// 
/// MERN Comparison:
/// - Repository ↔ Express service layer that wraps MongoDB queries
/// - Error handling ↔ try-catch blocks in Express routes

import 'package:fpdart/fpdart.dart';
import 'package:smart_library_app/src/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:smart_library_app/src/features/auth/domain/entities/user_entity.dart';
import 'package:smart_library_app/src/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<AuthException, UserEntity>> signUp({
    required String email,
    required String password,
    required String displayName,
    required String libraryMemberId,
  }) async {
    try {
      final userModel = await remoteDataSource.signUp(
        email: email,
        password: password,
        displayName: displayName,
        libraryMemberId: libraryMemberId,
      );

      // Model → Entity mapping
      return Right(userModel.toEntity());
    } on Exception catch (e) {
      return Left(_mapExceptionToAuthException(e));
    }
  }

  @override
  Future<Either<AuthException, UserEntity>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.signIn(
        email: email,
        password: password,
      );

      return Right(userModel.toEntity());
    } on Exception catch (e) {
      return Left(_mapExceptionToAuthException(e));
    }
  }

  @override
  Future<Either<AuthException, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } on Exception catch (e) {
      return Left(_mapExceptionToAuthException(e));
    }
  }

  @override
  Future<Either<AuthException, UserEntity?>> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      return Right(userModel?.toEntity());
    } on Exception catch (e) {
      return Left(_mapExceptionToAuthException(e));
    }
  }

  @override
  Stream<UserEntity?> streamCurrentUser() {
    return remoteDataSource.streamCurrentUser().map(
      (userModel) => userModel?.toEntity(),
    ).handleError(
      (e) => _mapExceptionToAuthException(e as Exception),
    );
  }

  @override
  Future<Either<AuthException, UserEntity>> updateUserProfile({
    required String userId,
    String? displayName,
    String? photoUrl,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      final userModel = await remoteDataSource.updateUserProfile(
        userId: userId,
        displayName: displayName,
        photoUrl: photoUrl,
        preferences: preferences,
      );

      return Right(userModel.toEntity());
    } on Exception catch (e) {
      return Left(_mapExceptionToAuthException(e));
    }
  }

  @override
  Future<Either<AuthException, void>> requestPasswordReset({
    required String email,
  }) async {
    try {
      await remoteDataSource.requestPasswordReset(email: email);
      return const Right(null);
    } on Exception catch (e) {
      return Left(_mapExceptionToAuthException(e));
    }
  }

  /// Map generic exceptions to typed AuthExceptions
  /// This is our **error normalization** (↔ Express middleware error handling)
  AuthException _mapExceptionToAuthException(Exception exception) {
    final message = exception.toString();

    if (message.contains('email-already-in-use')) {
      return EmailAlreadyExistsException(
        'Email is already registered',
      );
    }

    if (message.contains('user-not-found') ||
        message.contains('User profile not found')) {
      return UserNotFoundException(
        'User not found',
      );
    }

    if (message.contains('wrong-password') ||
        message.contains('invalid-credential')) {
      return InvalidCredentialsException(
        'Invalid email or password',
      );
    }

    if (message.contains('network') || message.contains('connection')) {
      return NetworkException(
        'Network error. Please check your connection.',
      );
    }

    return UnknownAuthException(message);
  }
}
