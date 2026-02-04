/// Auth Feedback Widget - Unified handler for all feedback states
/// 
/// MERN Comparison:
/// In React, this would be a context provider:
/// ```js
/// function useAuthFeedback() {
///   const [feedback, setFeedback] = useState(null);
///   
///   return (
///     <>
///       {feedback?.state === 'success' && <SuccessFeedback />}
///       {feedback?.state === 'error' && <ErrorFeedback />}
///       {feedback?.state === 'loading' && <LoadingFeedback />}
///     </>
///   );
/// }
/// ```
/// 
/// In Flutter: We use OverlayEntry + Stack to manage multiple overlays

import 'package:flutter/material.dart';
import '../../../core/animations/index.dart';
import 'success_feedback_overlay.dart';
import 'failure_feedback_overlay.dart';
import 'loading_feedback_overlay.dart';

class AuthFeedbackManager {
  static OverlayEntry? _currentOverlay;

  /// Show success feedback with auto-dismiss
  static Future<void> showSuccess(
    BuildContext context,
    AuthFeedbackResult result,
  ) async {
    _clearCurrentOverlay();

    final overlayEntry = OverlayEntry(
      builder: (context) => SuccessFeedbackOverlay(
        result: result,
        onDismiss: () => _clearCurrentOverlay(),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
    _currentOverlay = overlayEntry;
  }

  /// Show failure feedback with auto-dismiss
  static Future<void> showFailure(
    BuildContext context,
    AuthFeedbackResult result,
  ) async {
    _clearCurrentOverlay();

    final overlayEntry = OverlayEntry(
      builder: (context) => FailureFeedbackOverlay(
        result: result,
        onDismiss: () => _clearCurrentOverlay(),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
    _currentOverlay = overlayEntry;
  }

  /// Show loading feedback (must be dismissed manually)
  static void showLoading(
    BuildContext context, {
    String message = 'Authenticating...',
    VoidCallback? onCancel,
  }) {
    _clearCurrentOverlay();

    final overlayEntry = OverlayEntry(
      builder: (context) => LoadingFeedbackOverlay(
        message: message,
        onCancel: onCancel,
      ),
    );

    Overlay.of(context).insert(overlayEntry);
    _currentOverlay = overlayEntry;
  }

  /// Clear current overlay
  static void _clearCurrentOverlay() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }

  /// Dismiss all feedback
  static void dismissAll() {
    _clearCurrentOverlay();
  }
}

/// Convenience widget to integrate feedback into any screen
class AuthFeedbackListener extends StatefulWidget {
  final Widget child;
  final Stream<AuthFeedbackResult>? feedbackStream;

  const AuthFeedbackListener({
    super.key,
    required this.child,
    this.feedbackStream,
  });

  @override
  State<AuthFeedbackListener> createState() => _AuthFeedbackListenerState();
}

class _AuthFeedbackListenerState extends State<AuthFeedbackListener> {
  late StreamSubscription<AuthFeedbackResult>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.feedbackStream?.listen(_handleFeedback);
  }

  void _handleFeedback(AuthFeedbackResult result) {
    switch (result.state) {
      case AuthFeedbackState.success:
        AuthFeedbackManager.showSuccess(context, result);
        break;
      case AuthFeedbackState.failure:
        AuthFeedbackManager.showFailure(context, result);
        break;
      case AuthFeedbackState.loading:
        AuthFeedbackManager.showLoading(
          context,
          message: result.message,
        );
        break;
      case AuthFeedbackState.idle:
        AuthFeedbackManager.dismissAll();
        break;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

extension StreamAuthFeedback on Stream<AuthFeedbackResult> {
  /// Extension method for cleaner syntax
  /// Usage: feedbackStream.buildWithFeedback(child: MyWidget())
  Widget buildWithFeedback({required Widget child}) {
    return AuthFeedbackListener(
      feedbackStream: this,
      child: child,
    );
  }
}
