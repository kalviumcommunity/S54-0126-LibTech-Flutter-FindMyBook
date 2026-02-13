/// Sign up use case
/// 
/// Encapsulates the business logic for user registration
/// 
/// MERN Comparison:
/// - UseCase ↔ Express route controller + service layer
/// - call() method ↔ Async controller function
/// - Returns Either<Exception, Success> ↔ res.json({success, data, error})

import 'package:fpdart/fpdart.dart';
import 'package:smart_library_app/src/features/auth/domain/entities/user_entity.dart';
import 'package:smart_library_app/src/features/auth/domain/repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase({required this.repository});

  /// Execute sign up with email, password, and user details
  /// 
  /// Validates input and delegates to repository
  /// Returns Either with error on left, UserEntity on right
  Future<Either<AuthException, UserEntity>> call({
    required String email,
    required String password,
    required String displayName,
    required String libraryMemberId,
  }) async {
    // Basic validation
    if (email.isEmpty || !email.contains('@')) {
      return Left(
        InvalidCredentialsException('Invalid email format'),
      );
    }

    if (password.isEmpty || password.length < 6) {
      return Left(
        InvalidCredentialsException('Password must be at least 6 characters'),
      );
    }

    if (displayName.isEmpty) {
      return Left(
        InvalidCredentialsException('Display name cannot be empty'),
      );
    }

    if (libraryMemberId.isEmpty) {
      return Left(
        InvalidCredentialsException('Library member ID is required'),
      );
    }

    // Delegate to repository
    return repository.signUp(
      email: email,
      password: password,
      displayName: displayName,
      libraryMemberId: libraryMemberId,
    );
  }
}
