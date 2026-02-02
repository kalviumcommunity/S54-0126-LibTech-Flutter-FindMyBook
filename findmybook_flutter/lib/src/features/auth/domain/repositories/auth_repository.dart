abstract class AuthRepository {
  /// Returns user id string on success.
  Future<String> signIn(String email, String password);

  /// Returns user id string on success.
  Future<String> signUp(String email, String password);
}
