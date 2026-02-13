/// Abstract repository for authentication operations
/// 
/// This defines the **contract** that data layer implementations must follow
/// (↔ Express service interfaces or MongoDB repository patterns)
/// 
/// MERN Comparison:
/// - Repository interface ↔ Express service class public methods
/// - Either<L, R> ↔ {success, error} response pattern
/// - throw Exception ↔ Express error middleware

import 'package:fpdart/fpdart.dart';
import 'package:smart_library_app/src/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  /// Sign up with email and password
  /// 
  /// Returns Either<AuthException, UserEntity>
  /// - Left(error): Authentication failed
  /// - Right(user): Successfully created user
  Future<Either<AuthException, UserEntity>> signUp({
    required String email,
    required String password,
    required String displayName,
    required String libraryMemberId,
  });

  /// Sign in with email and password
  Future<Either<AuthException, UserEntity>> signIn({
    required String email,
    required String password,
  });

  /// Sign out current user
  Future<Either<AuthException, void>> signOut();

  /// Get current authenticated user
  /// 
  /// Returns null if no user is signed in
  Future<Either<AuthException, UserEntity?>> getCurrentUser();

  /// Watch current user as a stream (for real-time updates)
  /// 
  /// This is **Firestore listener** equivalent to **Redux subscription**
  /// Returns Stream<UserEntity?> that emits whenever user data changes
  Stream<UserEntity?> streamCurrentUser();

  /// Update user profile
  Future<Either<AuthException, UserEntity>> updateUserProfile({
    required String userId,
    String? displayName,
    String? photoUrl,
    Map<String, dynamic>? preferences,
  });

  /// Request password reset email
  Future<Either<AuthException, void>> requestPasswordReset({
    required String email,
  });
}

/// Base exception for authentication errors
sealed class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}

/// User not found exception
class UserNotFoundException extends AuthException {
  UserNotFoundException(super.message);
}

/// Invalid credentials exception
class InvalidCredentialsException extends AuthException {
  InvalidCredentialsException(super.message);
}

/// Email already exists exception
class EmailAlreadyExistsException extends AuthException {
  EmailAlreadyExistsException(super.message);
}

/// Network error exception
class NetworkException extends AuthException {
  NetworkException(super.message);
}

/// Unknown error exception
class UnknownAuthException extends AuthException {
  UnknownAuthException(super.message);
}
