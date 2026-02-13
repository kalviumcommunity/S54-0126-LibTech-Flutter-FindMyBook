/// Sign out use case
/// 
/// Encapsulates the business logic for signing out

import 'package:fpdart/fpdart.dart';
import 'package:smart_library_app/src/features/auth/domain/repositories/auth_repository.dart';

class SignOutUseCase {
  final AuthRepository repository;

  SignOutUseCase({required this.repository});

  /// Execute sign out
  Future<Either<AuthException, void>> call() async {
    return repository.signOut();
  }
}
