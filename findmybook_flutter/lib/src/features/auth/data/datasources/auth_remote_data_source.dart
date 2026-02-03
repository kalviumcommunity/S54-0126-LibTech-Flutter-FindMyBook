import 'package:firebase_auth/firebase_auth.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _auth;
  AuthRemoteDataSource({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  Future<String> signIn(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final uid = cred.user?.uid;
      if (uid == null) throw Exception('Failed to obtain user id');
      return uid;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? e.code);
    }
  }

  Future<String> signUp(String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final uid = cred.user?.uid;
      if (uid == null) throw Exception('Failed to obtain user id');
      return uid;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? e.code);
    }
  }
}
