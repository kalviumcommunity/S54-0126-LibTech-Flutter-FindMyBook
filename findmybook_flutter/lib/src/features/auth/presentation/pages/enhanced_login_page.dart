/// Enhanced Login Page with Auth Feedback Animations
/// 
/// MERN Comparison:
/// In React (with Formik + custom toast):
/// ```js
/// function LoginPage() {
///   const [formik] = useFormik({
///     onSubmit: async (values) => {
///       try {
///         setLoading(true);
///         showLoading('Authenticating...');
///         const result = await signIn(values.email, values.password);
///         showSuccess('Login successful!', { duration: 2000 });
///         navigate('/home');
///       } catch (error) {
///         showError(error.message, { errorCode: error.code });
///       } finally {
///         setLoading(false);
///       }
///     }
///   });
///   return <form onSubmit={formik.handleSubmit}>...</form>;
/// }
/// ```
/// 
/// In Flutter:
/// - We keep the same logic structure for familiarity
/// - Add feedback animations through our new system
/// - Use StreamController to notify the feedback manager
/// - Type-safe error handling with custom exceptions

import 'package:flutter/material.dart';
import '../widgets/index.dart';
import '../../../core/animations/index.dart';
import '../../../core/theme/index.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';

class EnhancedLoginPage extends StatefulWidget {
  const EnhancedLoginPage({super.key});

  @override
  State<EnhancedLoginPage> createState() => _EnhancedLoginPageState();
}

class _EnhancedLoginPageState extends State<EnhancedLoginPage> {
  // ============= Form & State =============
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  late final FocusNode _passFocus;
  bool _loading = false;
  bool _obscurePassword = true;

  // ============= Feedback Stream (for animations) =============
  /// In MERN: This is similar to Redux actions or event emitters
  /// In Flutter: StreamController is the event bus
  late final Stream<AuthFeedbackResult> _feedbackStream =
      Stream.value(AuthFeedbackResult(
        state: AuthFeedbackState.idle,
        message: '',
      )).asBroadcastStream();

  @override
  void initState() {
    super.initState();
    _passFocus = FocusNode();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  // ============= Form Validation =============
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!regex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // ============= Authentication Logic =============
  Future<void> _submit() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Hide keyboard
    FocusScope.of(context).unfocus();

    // Update UI state
    setState(() => _loading = true);

    // Show loading overlay
    AuthFeedbackManager.showLoading(
      context,
      message: 'Signing in...',
      onCancel: () => setState(() => _loading = false),
    );

    try {
      // Create repository & use case (would be injected in production)
      final authRepo = AuthRepositoryImpl();
      final signInUseCase = SignIn(authRepo);

      // Execute authentication
      final userId = await signInUseCase.call(
        _emailCtrl.text.trim(),
        _passCtrl.text,
      );

      if (!mounted) return;

      // Hide loading
      AuthFeedbackManager.dismissAll();

      // Show success
      await AuthFeedbackManager.showSuccess(
        context,
        AuthFeedbackResult.success(
          message: 'Welcome back! Redirecting...',
          data: {'userId': userId},
        ),
      );

      // Navigate to home
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/');
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      // Handle specific Firebase errors
      final message = _parseFirebaseError(e.code);
      AuthFeedbackManager.dismissAll();

      await AuthFeedbackManager.showFailure(
        context,
        AuthFeedbackResult.failure(
          message: message,
          errorCode: e.code,
        ),
      );

      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;

      // Handle generic errors
      AuthFeedbackManager.dismissAll();

      await AuthFeedbackManager.showFailure(
        context,
        AuthFeedbackResult.failure(
          message: 'Something went wrong. Please try again.',
          errorCode: 'UNKNOWN_ERROR',
        ),
      );

      setState(() => _loading = false);
    }
  }

  /// Parse Firebase error codes to user-friendly messages
  /// Similar to error handling middleware in Express
  String _parseFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Email address not found. Please register first.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'too-many-requests':
        return 'Too many failed attempts. Try again later.';
      case 'operation-not-allowed':
        return 'Sign-in is not enabled for this method.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Library'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xl,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ============= Header =============
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Back',
                    style: AppTypography.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to access your library',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // ============= Email Field =============
              TextFormField(
                controller: _emailCtrl,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'name@example.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _passFocus.requestFocus(),
                validator: _validateEmail,
              ),
              const SizedBox(height: AppSpacing.lg),

              // ============= Password Field =============
              TextFormField(
                controller: _passCtrl,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                focusNode: _passFocus,
                onFieldSubmitted: (_) => _loading ? null : _submit(),
                validator: _validatePassword,
              ),
              const SizedBox(height: 12),

              // ============= Forgot Password Link =============
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _loading ? null : () {
                    // TODO: Implement forgot password
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Forgot password feature coming soon'),
                      ),
                    );
                  },
                  child: const Text('Forgot Password?'),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ============= Submit Button =============
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const MinimalLoadingIndicator(
                        text: 'Signing In...',
                        isLoading: true,
                      )
                    : const Text('Sign In'),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ============= Divider =============
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Text(
                      'OR',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // ============= Social Login (Placeholder) =============
              OutlinedButton.icon(
                onPressed: _loading ? null : () {
                  // TODO: Implement Google Sign-In
                  AuthFeedbackManager.showLoading(
                    context,
                    message: 'Signing in with Google...',
                  );
                  Future.delayed(const Duration(seconds: 2), () {
                    AuthFeedbackManager.dismissAll();
                  });
                },
                icon: const Icon(Icons.login),
                label: const Text('Sign in with Google'),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ============= Register Link =============
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () {
                            Navigator.of(context).pushNamed('/register');
                          },
                    child: const Text('Register'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Import this for missing dependency
class FirebaseAuthException implements Exception {
  final String code;
  FirebaseAuthException({required this.code});
}
