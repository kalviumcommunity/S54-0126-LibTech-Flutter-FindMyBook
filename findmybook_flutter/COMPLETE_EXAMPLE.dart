/// COMPLETE EXAMPLE: Login Flow with Auth Animations
/// 
/// This file demonstrates a complete, production-ready login implementation
/// with all animations, error handling, and Firebase integration.
/// 
/// Copy this file as a reference for implementing auth in other pages.

import 'package:flutter/material.dart';
import 'firebase_auth/firebase_auth.dart' as firebase_auth;
import 'src/core/theme/index.dart';
import 'src/core/animations/index.dart';
import 'src/features/auth/presentation/widgets/index.dart';
import 'src/features/auth/data/repositories/auth_repository_with_feedback.dart';

/// ============================================================================
/// PART 1: PAGE STATE WITH ANIMATIONS
/// ============================================================================

class CompleteLoginExample extends StatefulWidget {
  const CompleteLoginExample({super.key});

  @override
  State<CompleteLoginExample> createState() => _CompleteLoginExampleState();
}

class _CompleteLoginExampleState extends State<CompleteLoginExample> {
  // ========== Form Controls ==========
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  late final FocusNode _passFocus;

  // ========== UI State ==========
  bool _loading = false;
  bool _obscurePassword = true;

  // ========== Services ==========
  final _authRepository = AuthRepositoryImpl();
  int _retryCount = 0;
  static const int _maxRetries = 3;

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

  // ========== VALIDATION ==========

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

  // ========== AUTHENTICATION LOGIC ==========

  /// Main login handler with retry logic
  /// 
  /// Flow:
  /// 1. Validate form
  /// 2. Hide keyboard
  /// 3. Show loading feedback
  /// 4. Attempt sign in (with retries)
  /// 5. Handle success or failure
  /// 6. Auto-navigate or show error
  Future<void> _handleLogin() async {
    // Step 1: Validate form
    if (!_formKey.currentState!.validate()) {
      // Form validation failed - user sees inline errors
      return;
    }

    // Step 2: Hide keyboard
    FocusScope.of(context).unfocus();

    // Step 3: Update UI & show loading
    setState(() => _loading = true);
    _retryCount = 0;

    AuthFeedbackManager.showLoading(
      context,
      message: 'Signing in...',
      onCancel: () => setState(() => _loading = false),
    );

    // Step 4: Attempt sign in
    final result = await _signInWithRetry(
      _emailCtrl.text.trim(),
      _passCtrl.text,
    );

    if (!mounted) return;

    // Step 5: Handle result
    _handleAuthResult(result);
  }

  /// Sign in with retry logic
  /// 
  /// If network error occurs, automatically retry up to 3 times
  /// with exponential backoff (1s, 2s, 4s)
  Future<AuthFeedbackResult> _signInWithRetry(
    String email,
    String password,
  ) async {
    for (int attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        // Attempt sign in
        final result = await _authRepository.signIn(email, password);

        // Check if successful
        if (result.isSuccess) {
          return result;
        }

        // Check if retryable error
        if (_isRetryableError(result.errorCode)) {
          _retryCount = attempt + 1;

          // Wait with exponential backoff
          await Future.delayed(Duration(seconds: 1 << attempt));
          continue;
        }

        // Not retryable - return failure
        return result;
      } catch (e) {
        if (attempt == _maxRetries - 1) {
          // Last attempt failed
          return AuthFeedbackResult.failure(
            message: 'Authentication failed after multiple attempts.',
            errorCode: 'MAX_RETRIES_EXCEEDED',
          );
        }

        // Retry
        _retryCount = attempt + 1;
        await Future.delayed(Duration(seconds: 1 << attempt));
      }
    }

    return AuthFeedbackResult.failure(
      message: 'Could not connect. Please check your network.',
      errorCode: 'NETWORK_ERROR',
    );
  }

  /// Check if error is retryable (network error)
  bool _isRetryableError(String? errorCode) {
    return errorCode == 'network-request-failed' ||
        errorCode == 'NETWORK_ERROR' ||
        errorCode == null; // Unknown error might be network
  }

  /// Handle authentication result
  /// 
  /// Shows appropriate feedback and navigates on success
  Future<void> _handleAuthResult(AuthFeedbackResult result) async {
    AuthFeedbackManager.dismissAll();

    if (result.isSuccess) {
      // Success flow
      await AuthFeedbackManager.showSuccess(
        context,
        AuthFeedbackResult.success(
          message: 'Welcome! Redirecting...',
          data: result.data,
        ),
      );

      // Wait for animation, then navigate
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(
          '/',
          arguments: result.data,
        );
      }
    } else {
      // Failure flow
      await AuthFeedbackManager.showFailure(
        context,
        result,
      );

      setState(() => _loading = false);

      // Allow user to see the error and retry
      _focusFirstErrorField();
    }
  }

  /// Focus the email field for user to correct and retry
  void _focusFirstErrorField() {
    if (_validateEmail(_emailCtrl.text) != null) {
      FocusScope.of(context).requestFocus(FocusNode());
    } else if (_validatePassword(_passCtrl.text) != null) {
      _passFocus.requestFocus();
    }
  }

  // ========== PASSWORD RESET ==========

  /// Handle forgot password tap
  Future<void> _handleForgotPassword() async {
    final email = _emailCtrl.text.trim();

    if (email.isEmpty) {
      ErrorSnackBar.show(
        context,
        'Please enter your email first',
      );
      return;
    }

    AuthFeedbackManager.showLoading(
      context,
      message: 'Sending reset email...',
    );

    final result = await _authRepository.resetPassword(email);

    if (!mounted) return;

    AuthFeedbackManager.dismissAll();

    if (result.isSuccess) {
      await AuthFeedbackManager.showSuccess(
        context,
        AuthFeedbackResult.success(
          message: 'Check your email for password reset link',
          data: null,
        ),
      );
    } else {
      await AuthFeedbackManager.showFailure(
        context,
        result,
      );
    }
  }

  // ========== SOCIAL LOGIN (PLACEHOLDER) ==========

  /// Handle Google sign-in
  /// 
  /// Note: This is a placeholder. Implement actual Google sign-in:
  /// 1. Add google_sign_in package
  /// 2. Add GoogleSignInButton
  /// 3. Handle authentication
  /// 4. Show feedback
  Future<void> _handleGoogleSignIn() async {
    AuthFeedbackManager.showLoading(
      context,
      message: 'Signing in with Google...',
    );

    // TODO: Implement actual Google sign-in
    // For now, simulate with delay
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    AuthFeedbackManager.dismissAll();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Google sign-in coming soon')),
    );
  }

  // ========== UI BUILDER ==========

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Library'),
        centerTitle: true,
        elevation: 0,
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
              // ==================== HEADER ====================
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Back',
                    style: AppTypography.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
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

              // ==================== EMAIL FIELD ====================
              TextFormField(
                controller: _emailCtrl,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'name@example.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: _emailCtrl.text.isNotEmpty
                      ? Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                        )
                      : null,
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onChanged: (value) {
                  setState(() {}); // Update suffix icon
                },
                onFieldSubmitted: (_) => _passFocus.requestFocus(),
                validator: _validateEmail,
              ),
              const SizedBox(height: AppSpacing.lg),

              // ==================== PASSWORD FIELD ====================
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
                onFieldSubmitted: (_) => _loading ? null : _handleLogin(),
                validator: _validatePassword,
              ),
              const SizedBox(height: 12),

              // ==================== FORGOT PASSWORD ====================
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _loading ? null : _handleForgotPassword,
                  child: const Text('Forgot Password?'),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ==================== SIGN IN BUTTON ====================
              ElevatedButton(
                onPressed: _loading ? null : _handleLogin,
                child: _loading
                    ? const MinimalLoadingIndicator(
                        text: 'Signing In...',
                        isLoading: true,
                      )
                    : const Text('Sign In'),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ==================== DIVIDER ====================
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

              // ==================== SOCIAL LOGIN ====================
              OutlinedButton.icon(
                onPressed: _loading ? null : _handleGoogleSignIn,
                icon: const Icon(Icons.login),
                label: const Text('Sign in with Google'),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ==================== REGISTER LINK ====================
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

// ============================================================================
// PART 2: REGISTER PAGE EXAMPLE
// ============================================================================

/// Apply the same pattern to RegisterPage:
/// 
/// class CompleteRegisterExample extends StatefulWidget {
///   @override
///   State<CompleteRegisterExample> createState() => 
///     _CompleteRegisterExampleState();
/// }
/// 
/// class _CompleteRegisterExampleState extends State<CompleteRegisterExample> {
///   final _authRepository = AuthRepositoryImpl();
///   
///   Future<void> _handleRegister(
///     String email, 
///     String password, 
///     String name,
///   ) async {
///     AuthFeedbackManager.showLoading(context, message: 'Creating account...');
///     
///     final result = await _authRepository.signUp(email, password, name);
///     
///     if (!mounted) return;
///     
///     AuthFeedbackManager.dismissAll();
///     
///     if (result.isSuccess) {
///       await AuthFeedbackManager.showSuccess(context, result);
///       if (mounted) Navigator.of(context).pushReplacementNamed('/');
///     } else {
///       await AuthFeedbackManager.showFailure(context, result);
///     }
///   }
/// }

// ============================================================================
// PART 3: OTHER FLOWS USING THE SAME PATTERN
// ============================================================================

/// PASSWORD RESET FLOW
Future<void> passwordResetFlow(
  BuildContext context,
  AuthRepositoryImpl authRepository,
) async {
  final email = 'user@example.com'; // Get from dialog

  AuthFeedbackManager.showLoading(
    context,
    message: 'Sending reset email...',
  );

  final result = await authRepository.resetPassword(email);

  if (!context.mounted) return;

  AuthFeedbackManager.dismissAll();

  if (result.isSuccess) {
    await AuthFeedbackManager.showSuccess(context, result);
  } else {
    await AuthFeedbackManager.showFailure(context, result);
  }
}

/// LOGOUT FLOW
Future<void> logoutFlow(
  BuildContext context,
  AuthRepositoryImpl authRepository,
) async {
  AuthFeedbackManager.showLoading(context, message: 'Signing out...');

  final result = await authRepository.signOut();

  if (!context.mounted) return;

  AuthFeedbackManager.dismissAll();

  if (result.isSuccess) {
    await AuthFeedbackManager.showSuccess(context, result);
    Navigator.of(context).pushReplacementNamed('/login');
  } else {
    await AuthFeedbackManager.showFailure(context, result);
  }
}

// ============================================================================
// KEY TAKEAWAYS
// ============================================================================

/// PATTERN CHECKLIST:
/// 
/// ✅ Form Validation
///    - Validate before showing loading
///    - Show inline errors on fields
///    - Don't show loading for validation errors
/// 
/// ✅ Loading State
///    - Always show feedback to user
///    - Disable buttons during loading
///    - Allow cancel if appropriate
/// 
/// ✅ Error Handling
///    - Parse Firebase errors to user messages
///    - Show specific error codes for debugging
///    - Allow user to retry
/// 
/// ✅ Success Flow
///    - Show success animation
///    - Wait for animation to complete
///    - Navigate with result data
/// 
/// ✅ Resource Management
///    - Check `if (mounted)` before setState
///    - Dispose controllers in dispose()
///    - Clear overlays before showing new ones
/// 
/// ✅ User Experience
///    - Provide visual feedback for all actions
///    - Handle edge cases (network errors, etc.)
///    - Support retry logic
///    - Auto-dismiss overlays after appropriate duration
