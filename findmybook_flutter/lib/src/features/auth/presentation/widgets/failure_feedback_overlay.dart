/// Failure Feedback Widget - Shows error with shake animation
/// 
/// MERN Comparison:
/// In React:
/// ```js
/// function ErrorFeedback({ visible, message }) {
///   return (
///     <motion.div 
///       animate={{ x: [0, -10, 10, 0] }}
///       transition={{ duration: 0.5 }}
///     >
///       <AlertCircle />
///       <p>{message}</p>
///     </motion.div>
///   );
/// }
/// ```
/// 
/// In Flutter: Transform.translate with animation for shake effect
/// Plus SlideTransition for the slide-in from top

import 'package:flutter/material.dart';
import '../../../core/animations/index.dart';
import '../../../core/theme/index.dart';

class FailureFeedbackOverlay extends StatefulWidget {
  final AuthFeedbackResult result;
  final VoidCallback onDismiss;

  const FailureFeedbackOverlay({
    super.key,
    required this.result,
    required this.onDismiss,
  });

  @override
  State<FailureFeedbackOverlay> createState() => _FailureFeedbackOverlayState();
}

class _FailureFeedbackOverlayState extends State<FailureFeedbackOverlay>
    with TickerProviderStateMixin {
  late AuthAnimationController _animationController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AuthAnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Slide-in animation from top
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );

    _startAnimation();
  }

  void _startAnimation() async {
    // Slide in
    await _slideController.forward();
    
    // Play shake animation
    await _animationController.playError();
    
    // Auto-dismiss after duration
    if (mounted) {
      await Future.delayed(widget.result.duration);
      await _slideController.reverse();
      widget.onDismiss();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AnimatedBuilder(
            animation: _animationController.shakeOffset,
            builder: (context, child) {
              return Transform.translate(
                offset: _animationController.shakeOffset.value * 15,
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.95),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.error.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Error Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Error Message
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Error',
                          style: AppTypography.labelLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.result.message,
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Dismiss Button
                  GestureDetector(
                    onTap: widget.onDismiss,
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white.withOpacity(0.7),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Alternative: Error Snackbar using SnackBar widget
/// More material-design aligned but less customizable
class ErrorSnackBar {
  static void show(
    BuildContext context,
    String message, {
    String? errorCode,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Colors.white.withOpacity(0.9),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Error',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (errorCode != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Code: $errorCode',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        elevation: 10,
        duration: duration,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }
}
