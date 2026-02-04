/// Auth Feedback Models - Define states for authentication feedback
/// 
/// MERN Comparison:
/// In React: type AuthState = 'idle' | 'loading' | 'success' | 'error'
/// In Flutter: We use enums + sealed classes for type-safety and exhaustive checking
///
/// Benefits:
/// - No null pointer exceptions
/// - Compiler enforces handling all states
/// - Better IDE autocomplete
/// - Clear data contracts

enum AuthFeedbackState {
  /// Initial state - nothing happened yet
  idle,
  
  /// User clicked login/register, waiting for Firebase
  loading,
  
  /// Authentication successful
  success,
  
  /// Authentication failed
  failure,
}

enum AuthFeedbackAnimation {
  /// Checkmark with scale-in animation
  successCheck,
  
  /// Confetti particles falling
  confetti,
  
  /// Shake animation for error
  shake,
  
  /// Pulse animation for loading
  pulse,
}

/// Represents the complete auth feedback result
/// 
/// Think of this as the Response object in Express:
/// ```js
/// res.status(200).json({
///   success: true,
///   message: "Login successful",
///   data: { userId: "123" }
/// })
/// ```
/// 
/// In Flutter, we wrap everything in a strongly-typed class
class AuthFeedbackResult {
  final AuthFeedbackState state;
  final String message;
  final String? errorCode;
  final dynamic data;
  final Duration duration;
  
  const AuthFeedbackResult({
    required this.state,
    required this.message,
    this.errorCode,
    this.data,
    this.duration = const Duration(milliseconds: 2500),
  });
  
  /// Convenience factory for success state
  factory AuthFeedbackResult.success({
    required String message,
    required dynamic data,
  }) {
    return AuthFeedbackResult(
      state: AuthFeedbackState.success,
      message: message,
      data: data,
      duration: const Duration(milliseconds: 2500),
    );
  }
  
  /// Convenience factory for failure state
  factory AuthFeedbackResult.failure({
    required String message,
    String? errorCode,
  }) {
    return AuthFeedbackResult(
      state: AuthFeedbackState.failure,
      message: message,
      errorCode: errorCode,
      duration: const Duration(milliseconds: 3000),
    );
  }
  
  /// Convenience factory for loading state
  factory AuthFeedbackResult.loading({
    required String message,
  }) {
    return AuthFeedbackResult(
      state: AuthFeedbackState.loading,
      message: message,
      duration: const Duration(seconds: 30),
    );
  }
  
  bool get isSuccess => state == AuthFeedbackState.success;
  bool get isFailure => state == AuthFeedbackState.failure;
  bool get isLoading => state == AuthFeedbackState.loading;
  bool get isIdle => state == AuthFeedbackState.idle;
}
