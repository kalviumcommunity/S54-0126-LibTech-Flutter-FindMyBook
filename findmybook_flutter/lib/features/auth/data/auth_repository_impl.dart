import "package:firebase_auth/firebase_auth.dart";

import "../../../core/errors/app_exception.dart";
import "../domain/auth_repository.dart";
import "auth_service.dart";

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _service;
  AuthRepositoryImpl(this._service);

  @override
  Stream<User?> authChanges() => _service.authChanges();

  @override
  User? get currentUser => _service.currentUser;

  @override
  Future<String> signIn(String email, String password) async {
    try {
      return await _service.signIn(email, password);
    } on FirebaseAuthException catch (e) {
      throw AppException(e.message ?? "Unable to sign in.");
    }
  }

  @override
  Future<String> signUp(String email, String password) async {
    try {
      return await _service.signUp(email, password);
    } on FirebaseAuthException catch (e) {
      throw AppException(e.message ?? "Unable to register.");
    }
  }

  @override
  Future<void> signOut() async {
    await _service.signOut();
  }
}
