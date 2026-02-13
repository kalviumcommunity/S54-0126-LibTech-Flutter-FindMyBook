/// Subtle animations for UI updates
/// 
/// MERN Comparison:
/// - Flutter animations ↔ CSS transitions + React Framer Motion
/// - AnimatedBuilder ↔ requestAnimationFrame loop
/// - Curves.easeOut ↔ CSS easing functions
/// - 
/// Best Practices:
/// - Keep animations under 600ms (perceived as instant)
/// - Use meaningful animations (fade in new data, slide from top)
/// - Avoid animation on every frame (use debounce)

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

/// Fade and slide animation for incoming data
/// 
/// Use when:
/// - Real-time Firestore update comes in (new book borrowed, reservation made)
/// - User data changes in stream
/// - Live notifications appear
/// 
/// ↔ CSS: @keyframes slideInFade { from { opacity: 0; transform: translateY(10px); } ... }
class FadeSlideAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final VoidCallback? onAnimationComplete;

  const FadeSlideAnimation({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOut,
    this.onAnimationComplete,
  }) : super(key: key);

  @override
  State<FadeSlideAnimation> createState() => _FadeSlideAnimationState();
}

class _FadeSlideAnimationState extends State<FadeSlideAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Slide from top to bottom
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    // Fade from 0.5 to 1
    _fadeAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    _controller.forward().then((_) {
      widget.onAnimationComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Scale animation for emphasis (when data changes)
/// 
/// Use when:
/// - Book availability changes
/// - User profile photo updates
/// - Important status changes
///
/// ↔ CSS: transform: scale(1)
class ScalePulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;

  const ScalePulseAnimation({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.minScale = 0.95,
    this.maxScale = 1.05,
  }) : super(key: key);

  @override
  State<ScalePulseAnimation> createState() => _ScalePulseAnimationState();
}

class _ScalePulseAnimationState extends State<ScalePulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward().then((_) {
      _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}

/// Notification badge with animation
/// 
/// Use for: Real-time notifications, unread counts, alerts
class AnimatedNotificationBadge extends StatefulWidget {
  final int count;
  final Color color;
  final Duration duration;

  const AnimatedNotificationBadge({
    Key? key,
    required this.count,
    this.color = Colors.red,
    this.duration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  State<AnimatedNotificationBadge> createState() =>
      _AnimatedNotificationBadgeState();
}

class _AnimatedNotificationBadgeState extends State<AnimatedNotificationBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation =
        Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation =
        Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedNotificationBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.count != widget.count) {
      // Reset animation when count changes
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
          ),
          child: Text(
            '${widget.count}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

/// Shared axis transition (similar to Google Material 3)
/// 
/// Use when navigating between screens
/// Coordinates X, Y, or Z axis for smooth transitions
class SharedAxisTransitionExample extends StatelessWidget {
  final Widget child;
  final SharedAxisTransitionType transitionType;

  const SharedAxisTransitionExample({
    Key? key,
    required this.child,
    this.transitionType = SharedAxisTransitionType.horizontal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageTransitionSwitcher(
      transitionBuilder: (child, animation, secondaryAnimation) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: transitionType,
          child: child,
        );
      },
      child: child,
    );
  }
}

/// Real-time update indicator (pulsing dot)
/// 
/// Use for: Live data syncing status
class RealtimeIndicator extends StatefulWidget {
  final Color activeColor;
  final Color inactiveColor;
  final Duration duration;

  const RealtimeIndicator({
    Key? key,
    this.activeColor = Colors.green,
    this.inactiveColor = Colors.grey,
    this.duration = const Duration(milliseconds: 1000),
  }) : super(key: key);

  @override
  State<RealtimeIndicator> createState() => _RealtimeIndicatorState();
}

class _RealtimeIndicatorState extends State<RealtimeIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: widget.activeColor,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Animated list for borrowed books with staggered animation
/// 
/// Use for: Showing lists of items with staggered entry animation
class StaggeredListAnimation extends StatefulWidget {
  final List<Widget> children;
  final Duration staggerDelay;
  final Duration itemDuration;

  const StaggeredListAnimation({
    Key? key,
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 100),
    this.itemDuration = const Duration(milliseconds: 500),
  }) : super(key: key);

  @override
  State<StaggeredListAnimation> createState() => _StaggeredListAnimationState();
}

class _StaggeredListAnimationState extends State<StaggeredListAnimation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _controllers = List<AnimationController>.generate(
      widget.children.length,
      (index) {
        final controller = AnimationController(
          duration: widget.itemDuration,
          vsync: this,
        );

        // Stagger: delay each item by index * staggerDelay
        Future.delayed(
          widget.staggerDelay * index,
          () => controller.forward(),
        );

        return controller;
      },
    );

    _animations = _controllers
        .map((controller) =>
            Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(parent: controller, curve: Curves.easeOut),
            ))
        .toList();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        widget.children.length,
        (index) => FadeTransition(
          opacity: _animations[index],
          child: SlideTransition(
            position: _animations[index].drive(
              Tween<Offset>(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ),
            ),
            child: widget.children[index],
          ),
        ),
      ),
    );
  }
}
