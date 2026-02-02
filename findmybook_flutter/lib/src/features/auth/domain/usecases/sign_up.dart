import '../repositories/auth_repository.dart';

class SignUp {
  final AuthRepository repository;
  SignUp(this.repository);

  Future<String> call(String email, String password) async {
    return repository.signUp(email, password);
  }
}
