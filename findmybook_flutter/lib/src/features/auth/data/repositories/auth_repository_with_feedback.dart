/// Auth Repository with Feedback Integration
/// 
/// MERN Comparison:
/// In Express:
/// ```js
/// router.post('/auth/login', async (req, res) => {
///   try {
///     const user = await User.findOne({ email: req.body.email });
///     if (!user) return res.status(404).json({ error: 'User not found' });
///     
///     const validPassword = await bcrypt.compare(req.body.password, user.password);
///     if (!validPassword) return res.status(400).json({ error: 'Invalid password' });
///     
///     const token = jwt.sign({ userId: user._id }, SECRET);
///     return res.json({ success: true, token });
///   } catch (error) {
///     return res.status(500).json({ error: error.message });
///   }
/// });
/// ```
/// 
/// In Flutter with Firebase:
/// ```dart
/// // Same logic, but using Firebase SDK
/// class AuthRepositoryImpl implements AuthRepository {
///   Future<AuthFeedbackResult> signIn(String email, String password) async {
///     try {
///       final userCredential = await FirebaseAuth.instance
///         .signInWithEmailAndPassword(email: email, password: password);
///       
///       final user = userCredential.user;
///       if (user == null) {
///         return AuthFeedbackResult.failure(message: 'User not found');
///       }
///       
///       // Optionally, fetch additional user data from Firestore
///       final userDoc = await FirebaseFirestore.instance
///         .collection('users')
///         .doc(user.uid)
///         .get();
///       
///       return AuthFeedbackResult.success(
///         message: 'Login successful',
///         data: { 'user': userDoc.data() },
///       );
///     } on FirebaseAuthException catch (e) {
///       return AuthFeedbackResult.failure(
///         message: _parseError(e.code),
///         errorCode: e.code,
///       );
///     }
///   }
/// }
/// ```

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../core/animations/index.dart';

// ============= Domain Layer (Business Logic) =============

/// Abstract repository (contract/interface)
/// Similar to TypeScript interfaces or abstract classes in Express
abstract class AuthRepository {
  Future<AuthFeedbackResult> signIn(String email, String password);
  Future<AuthFeedbackResult> signUp(String email, String password, String name);
  Future<AuthFeedbackResult> signOut();
  Future<AuthFeedbackResult> resetPassword(String email);
  Stream<AuthFeedbackResult> get authStateChanges;
}

// ============= Data Layer (Firebase Implementation) =============

class AuthRepositoryImpl implements AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Sign in with email and password
  /// 
  /// Firebase Error Codes:
  /// - user-not-found: No user with this email
  /// - wrong-password: Password doesn't match
  /// - too-many-requests: Too many failed login attempts
  /// - user-disabled: User account has been disabled
  @override
  Future<AuthFeedbackResult> signIn(String email, String password) async {
    try {
      // Validate inputs
      if (email.isEmpty || password.isEmpty) {
        return AuthFeedbackResult.failure(
          message: 'Email and password are required',
          errorCode: 'EMPTY_FIELDS',
        );
      }

      // Attempt Firebase authentication
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return AuthFeedbackResult.failure(
          message: 'Authentication failed. Please try again.',
          errorCode: 'USER_NULL',
        );
      }

      // Fetch user profile from Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      // Return success with user data
      return AuthFeedbackResult.success(
        message: 'Login successful!',
        data: {
          'userId': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'profile': userDoc.data(),
        },
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      // Handle Firebase-specific errors
      return AuthFeedbackResult.failure(
        message: _parseFirebaseAuthError(e.code),
        errorCode: e.code,
      );
    } on FirebaseException catch (e) {
      // Handle Firestore errors
      return AuthFeedbackResult.failure(
        message: 'Failed to load user profile. Please try again.',
        errorCode: e.code,
      );
    } catch (e) {
      // Handle unexpected errors
      return AuthFeedbackResult.failure(
        message: 'An unexpected error occurred. Please try again.',
        errorCode: 'UNKNOWN_ERROR',
      );
    }
  }

  /// Sign up with email, password, and name
  @override
  Future<AuthFeedbackResult> signUp(
    String email,
    String password,
    String name,
  ) async {
    try {
      // Validate inputs
      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        return AuthFeedbackResult.failure(
          message: 'Please fill in all fields',
          errorCode: 'EMPTY_FIELDS',
        );
      }

      if (password.length < 6) {
        return AuthFeedbackResult.failure(
          message: 'Password must be at least 6 characters',
          errorCode: 'WEAK_PASSWORD',
        );
      }

      // Create user account
      final userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return AuthFeedbackResult.failure(
          message: 'Registration failed. Please try again.',
          errorCode: 'USER_CREATION_FAILED',
        );
      }

      // Update user profile with display name
      await user.updateDisplayName(name);

      // Create user document in Firestore
      /// Similar to MongoDB:
      /// db.users.insertOne({
      ///   _id: new ObjectId(userId),
      ///   email: email,
      ///   name: name,
      ///   createdAt: new Date(),
      ///   preferences: { theme: 'light', language: 'en' }
      /// })
      await _firestore.collection('users').doc(user.uid).set({
        'email': email,
        'displayName': name,
        'createdAt': FieldValue.serverTimestamp(),
        'preferences': {
          'theme': 'light',
          'language': 'en',
        },
        'libraryFavorites': [],
      });

      // Send email verification
      await user.sendEmailVerification();

      return AuthFeedbackResult.success(
        message: 'Account created! Check your email to verify.',
        data: {
          'userId': user.uid,
          'email': user.email,
          'displayName': user.displayName,
        },
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      return AuthFeedbackResult.failure(
        message: _parseFirebaseAuthError(e.code),
        errorCode: e.code,
      );
    } catch (e) {
      return AuthFeedbackResult.failure(
        message: 'Unexpected error during registration.',
        errorCode: 'UNKNOWN_ERROR',
      );
    }
  }

  /// Sign out the current user
  @override
  Future<AuthFeedbackResult> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return AuthFeedbackResult.success(
        message: 'Signed out successfully',
        data: null,
      );
    } catch (e) {
      return AuthFeedbackResult.failure(
        message: 'Error signing out',
        errorCode: 'SIGN_OUT_FAILED',
      );
    }
  }

  /// Send password reset email
  @override
  Future<AuthFeedbackResult> resetPassword(String email) async {
    try {
      if (email.isEmpty) {
        return AuthFeedbackResult.failure(
          message: 'Please enter your email',
          errorCode: 'EMPTY_EMAIL',
        );
      }

      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return AuthFeedbackResult.success(
        message: 'Password reset link sent to your email',
        data: null,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      return AuthFeedbackResult.failure(
        message: _parseFirebaseAuthError(e.code),
        errorCode: e.code,
      );
    } catch (e) {
      return AuthFeedbackResult.failure(
        message: 'Error sending password reset email',
        errorCode: 'RESET_FAILED',
      );
    }
  }

  /// Stream of authentication state changes
  /// Similar to Express event emitters or Redux subscriptions
  /// 
  /// In MERN:
  /// ```js
  /// useEffect(() => {
  ///   const unsubscribe = onAuthStateChanged((user) => {
  ///     if (user) dispatch(setUser(user));
  ///     else dispatch(clearUser());
  ///   });
  ///   return unsubscribe;
  /// }, []);
  /// ```
  @override
  Stream<AuthFeedbackResult> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user != null) {
        return AuthFeedbackResult.success(
          message: 'User authenticated',
          data: {'user': user},
        );
      } else {
        return AuthFeedbackResult(
          state: AuthFeedbackState.idle,
          message: 'User not authenticated',
        );
      }
    });
  }

  /// Parse Firebase authentication error codes to user-friendly messages
  /// 
  /// Equivalent to Express error handler middleware:
  /// ```js
  /// function handleAuthError(code) {
  ///   const errors = {
  ///     'user-not-found': 'No user with this email',
  ///     'wrong-password': 'Incorrect password',
  ///     'weak-password': 'Password too weak'
  ///   };
  ///   return errors[code] || 'Authentication failed';
  /// }
  /// ```
  String _parseFirebaseAuthError(String code) {
    switch (code) {
      // Sign In Errors
      case 'user-not-found':
        return 'Email address not found. Please register first.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';

      // Sign Up Errors
      case 'email-already-in-use':
        return 'Email already registered. Try signing in instead.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';

      // General Errors
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'too-many-requests':
        return 'Too many failed attempts. Try again later.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';

      // Password Reset
      case 'firebase_auth/user-not-found':
        return 'No account found with this email.';

      // Default
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}

// ============= Usage Example in Page =============

/// How to use the repository in a page/widget
/// ```dart
/// class LoginPage extends StatefulWidget {
///   @override
///   State<LoginPage> createState() => _LoginPageState();
/// }
///
/// class _LoginPageState extends State<LoginPage> {
///   final _authRepo = AuthRepositoryImpl();
///
///   Future<void> _handleLogin(String email, String password) async {
///     // Show loading feedback
///     AuthFeedbackManager.showLoading(
///       context,
///       message: 'Signing in...',
///     );
///
///     // Call repository
///     final result = await _authRepo.signIn(email, password);
///
///     if (!mounted) return;
///
///     // Handle result
///     AuthFeedbackManager.dismissAll();
///
///     if (result.isSuccess) {
///       await AuthFeedbackManager.showSuccess(context, result);
///       // Navigate
///       Navigator.of(context).pushReplacementNamed('/home');
///     } else {
///       await AuthFeedbackManager.showFailure(context, result);
///     }
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return ElevatedButton(
///       onPressed: () => _handleLogin('user@example.com', 'password123'),
///       child: const Text('Sign In'),
///     );
///   }
/// }
/// ```
