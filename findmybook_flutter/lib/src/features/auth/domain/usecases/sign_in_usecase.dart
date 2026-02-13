/// Sign in use case
/// 
/// Encapsulates the business logic for user authentication

import 'package:fpdart/fpdart.dart';
import 'package:smart_library_app/src/features/auth/domain/entities/user_entity.dart';
import 'package:smart_library_app/src/features/auth/domain/repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository repository;

  SignInUseCase({required this.repository});

  /// Execute sign in with email and password
  Future<Either<AuthException, UserEntity>> call({
    required String email,
    required String password,
  }) async {
    // Basic validation
    if (email.isEmpty || !email.contains('@')) {
      return Left(
        InvalidCredentialsException('Invalid email format'),
      );
    }

    if (password.isEmpty) {
      return Left(
        InvalidCredentialsException('Password is required'),
      );
    }

    // Delegate to repository
    return repository.signIn(
      email: email,
      password: password,
    );
  }
}
