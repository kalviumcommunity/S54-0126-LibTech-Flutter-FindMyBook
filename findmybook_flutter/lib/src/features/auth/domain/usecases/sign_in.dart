import '../repositories/auth_repository.dart';

class SignIn {
  final AuthRepository repository;
  SignIn(this.repository);

  Future<String> call(String email, String password) async {
    return repository.signIn(email, password);
  }
}
