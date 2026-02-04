/// Loading Feedback Widget - Shows loading state with pulse animation
/// 
/// MERN Comparison:
/// In React:
/// ```js
/// function LoadingFeedback() {
///   return (
///     <motion.div animate={{ scale: [0.95, 1.05] }}>
///       <Spinner />
///       <p>Authenticating...</p>
///     </motion.div>
///   );
/// }
/// ```
/// 
/// In Flutter: AnimatedBuilder with continuous animation repeat

import 'package:flutter/material.dart';
import '../../../core/animations/index.dart';
import '../../../core/theme/index.dart';

class LoadingFeedbackOverlay extends StatefulWidget {
  final String message;
  final VoidCallback? onCancel;

  const LoadingFeedbackOverlay({
    super.key,
    this.message = 'Authenticating...',
    this.onCancel,
  });

  @override
  State<LoadingFeedbackOverlay> createState() => _LoadingFeedbackOverlayState();
}

class _LoadingFeedbackOverlayState extends State<LoadingFeedbackOverlay>
    with TickerProviderStateMixin {
  late AuthAnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AuthAnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _animationController.playLoading();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ============= Loading Spinner with Pulse =============
            AnimatedBuilder(
              animation: _animationController.loadingPulse,
              builder: (context, child) {
                return Transform.scale(
                  scale: _animationController.loadingPulse.value,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Circular progress indicator
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                              strokeWidth: 3,
                            ),
                          ),
                          // Center circle (for modern look)
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            
            // ============= Loading Message =============
            Text(
              widget.message,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            // ============= Sub-message (Tips) =============
            Text(
              'Please wait...',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            
            // ============= Cancel Button (Optional) =============
            if (widget.onCancel != null)
              TextButton.icon(
                onPressed: widget.onCancel,
                icon: const Icon(Icons.close),
                label: const Text('Cancel'),
              ),
          ],
        ),
      ),
    );
  }
}

/// Alternative: Minimal Loading Indicator
/// For use inside buttons or as inline loading state
class MinimalLoadingIndicator extends StatelessWidget {
  final String text;
  final bool isLoading;

  const MinimalLoadingIndicator({
    super.key,
    required this.text,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Text(text),
      ],
    );
  }
}
