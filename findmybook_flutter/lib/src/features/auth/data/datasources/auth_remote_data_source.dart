class AuthRemoteDataSource {
  /// Simulated remote sign-in. Replace with Firebase Auth logic.
  Future<String> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!email.contains('@')) throw Exception('Invalid email');
    if (password.length < 6) throw Exception('Password too short');
    return 'user_${email.hashCode}';
  }

  Future<String> signUp(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (!email.contains('@')) throw Exception('Invalid email');
    if (password.length < 6) throw Exception('Password too short');
    return 'newuser_${email.hashCode}';
  }
}
