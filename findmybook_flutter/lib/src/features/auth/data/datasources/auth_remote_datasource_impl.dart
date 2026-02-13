/// Implementation of auth data source with Firebase Auth + Firestore
/// 
/// MERN Comparison:
/// - This class ↔ MongoDB connection + Firebase Realtime Database queries
/// - signUp/signIn ↔ bcrypt password handling + DB insert
/// - Firestore listener ↔ MongoDB change streams (MongoDB 3.6+)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_library_app/src/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:smart_library_app/src/features/auth/data/models/user_model.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  /// Firestore path constants (optimize reads with collection naming)
  static const String _usersCollection = 'users';
  static const String _userEmailIndex = 'email';
  static const String _userCreatedAtIndex = 'createdAt';

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String displayName,
    required String libraryMemberId,
  }) async {
    try {
      // Step 1: Create Firebase Auth user (↔ bcrypt + store in MongoDB)
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;
      final now = DateTime.now();

      // Step 2: Create user document in Firestore
      // This denormalization strategy avoids N+1 queries (↔ MongoDB joins)
      final userModel = UserModel(
        id: uid,
        email: email,
        displayName: displayName,
        photoUrl: null,
        libraryMemberId: libraryMemberId,
        role: 'USER',
        createdAt: now,
        updatedAt: now,
        hasCompletedOnboarding: false,
        preferredLanguage: 'en',
        preferences: {
          'emailNotifications': true,
          'theme': 'light',
        },
      );

      // Firestore Optimization: Single write operation (Batch write possible)
      await firestore.collection(_usersCollection).doc(uid).set(
            userModel.toFirestore(),
          );

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw Exception('Auth error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Step 1: Authenticate with Firebase Auth
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Step 2: Fetch user document from Firestore
      // Optimization: Cache this in local storage to reduce reads on app restart
      final userDoc = await firestore
          .collection(_usersCollection)
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('User profile not found in database');
      }

      return UserModel.fromDocument(userDoc);
    } on FirebaseAuthException catch (e) {
      throw Exception('Sign in failed: ${e.message}');
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final authUser = firebaseAuth.currentUser;
      if (authUser == null) return null;

      final userDoc = await firestore
          .collection(_usersCollection)
          .doc(authUser.uid)
          .get();

      if (!userDoc.exists) return null;

      return UserModel.fromDocument(userDoc);
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  @override
  Stream<UserModel?> streamCurrentUser() {
    // Get current Firebase Auth user
    final authUser = firebaseAuth.currentUser;
    if (authUser == null) {
      return Stream.value(null);
    }

    // Return Firestore listener stream
    // This is the **real-time update mechanism** (↔ MongoDB change streams or WebSocket)
    // 
    // Firestore Cost Optimization:
    // - Each listener = 1 read per snap, then 1 read per write to the document
    // - If you have 10 users listening to same doc = 1 read per write (batch optimized)
    // - WebSocket would require 10 separate connections
    return firestore
        .collection(_usersCollection)
        .doc(authUser.uid)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      return UserModel.fromDocument(snapshot);
    }).handleError((e) {
      print('Error streaming current user: $e');
      return null;
    });
  }

  @override
  Future<UserModel> updateUserProfile({
    required String userId,
    String? displayName,
    String? photoUrl,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      // Build update payload (only include non-null values)
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (displayName != null) updateData['displayName'] = displayName;
      if (photoUrl != null) updateData['photoUrl'] = photoUrl;
      if (preferences != null) updateData['preferences'] = preferences;

      // Atomic update (↔ MongoDB updateOne)
      await firestore
          .collection(_usersCollection)
          .doc(userId)
          .update(updateData);

      // Return updated user
      final updatedDoc = await firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();

      return UserModel.fromDocument(updatedDoc);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  @override
  Future<void> requestPasswordReset({
    required String email,
  }) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Failed to send reset email: $e');
    }
  }
}
