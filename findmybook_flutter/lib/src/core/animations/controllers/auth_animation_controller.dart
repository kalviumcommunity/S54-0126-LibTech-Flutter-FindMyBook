/// AuthAnimationController - Unified controller for all auth animations
/// 
/// MERN Comparison:
/// In React with framer-motion:
/// ```js
/// const controls = useAnimation();
/// controls.start({ opacity: 1, y: 0 });
/// ```
/// 
/// In Flutter:
/// We create a wrapper around AnimationController that manages multiple Tweens
/// This is similar to creating a custom hook for animation logic
/// 
/// Benefits:
/// - Single source of truth for animation state
/// - Easy to test (just provide a TickerProvider)
/// - Reusable across widgets
/// - Handles lifecycle properly (dispose)

import 'package:flutter/material.dart';

class AuthAnimationController {
  final AnimationController controller;
  
  /// Animation for success checkmark (scale in + fade)
  late Animation<double> successScale;
  late Animation<double> successFade;
  
  /// Animation for shake (for error state)
  late Animation<Offset> shakeOffset;
  
  /// Animation for loading pulse
  late Animation<double> loadingPulse;
  
  /// Animation for success confetti
  late Animation<double> confettiOpacity;
  late Animation<double> confettiRotation;
  
  /// Animation for button scale (interactive feedback)
  late Animation<double> buttonScale;

  AuthAnimationController({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 600),
  }) : controller = AnimationController(
    duration: duration,
    vsync: vsync,
  ) {
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // ============= Success Checkmark Animation =============
    // Scale from 0 to 1 (appears from center)
    successScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.elasticOut,
      ),
    );

    // Fade in simultaneously
    successFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // ============= Shake Animation (Error) =============
    // Horizontal shake: -15, 0, 15, 0, -10, 0, 10, 0, -5, 0
    shakeOffset = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-0.05, 0),
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(-0.05, 0),
          end: const Offset(0.05, 0),
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(0.05, 0),
          end: const Offset(-0.03, 0),
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(-0.03, 0),
          end: Offset.zero,
        ),
        weight: 1,
      ),
    ]).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );

    // ============= Loading Pulse Animation =============
    // Continuously scale between 0.95 and 1.0
    loadingPulse = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );

    // ============= Confetti Animation =============
    // Fade out after appearing
    confettiOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    // Rotation for confetti particles
    confettiRotation = Tween<double>(begin: 0.0, end: 6.28).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.linear,
      ),
    );

    // ============= Button Scale Animation =============
    // For button press feedback
    buttonScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  /// Play success animation (checkmark + confetti)
  /// Duration: ~2 seconds
  Future<void> playSuccess() async {
    await controller.forward();
    await Future.delayed(const Duration(milliseconds: 1000));
    await controller.reverse();
  }

  /// Play error animation (shake + fade)
  /// Duration: ~500ms
  Future<void> playError() async {
    controller.duration = const Duration(milliseconds: 500);
    await controller.forward();
    controller.reset();
    controller.duration = const Duration(milliseconds: 600);
  }

  /// Play loading animation (pulse, continuous)
  /// Must be stopped manually
  void playLoading() {
    controller.duration = const Duration(milliseconds: 1500);
    controller.repeat(reverse: true);
  }

  /// Stop all animations
  void stop() {
    controller.stop();
  }

  /// Reset controller to initial state
  void reset() {
    controller.reset();
  }

  /// Cleanup resources (required for StatefulWidget)
  void dispose() {
    controller.dispose();
  }
}
