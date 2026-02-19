import "package:firebase_auth/firebase_auth.dart";

abstract class AuthRepository {
  Stream<User?> authChanges();
  User? get currentUser;
  Future<String> signIn(String email, String password);
  Future<String> signUp(String email, String password);
  Future<void> signOut();
}
