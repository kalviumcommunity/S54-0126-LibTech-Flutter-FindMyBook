/// Abstract data source for authentication
/// 
/// Defines contract for Firebase Auth operations
/// (↔ MongoDB operations in Express models/controllers)

import 'package:smart_library_app/src/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  /// Sign up with email and password
  /// Throws exception on failure
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String displayName,
    required String libraryMemberId,
  });

  /// Sign in with email and password
  Future<UserModel> signIn({
    required String email,
    required String password,
  });

  /// Sign out current user
  Future<void> signOut();

  /// Get current user
  Future<UserModel?> getCurrentUser();

  /// Watch current user as stream (Firestore real-time listener)
  /// 
  /// This emits whenever Firestore user document changes
  /// (↔ WebSocket event emission in Express)
  Stream<UserModel?> streamCurrentUser();

  /// Update user profile in Firestore
  Future<UserModel> updateUserProfile({
    required String userId,
    String? displayName,
    String? photoUrl,
    Map<String, dynamic>? preferences,
  });

  /// Request password reset email
  Future<void> requestPasswordReset({
    required String email,
  });
}
