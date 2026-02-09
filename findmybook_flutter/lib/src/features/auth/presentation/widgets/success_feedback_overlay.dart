/// Success Feedback Widget - Shows checkmark + confetti animation
/// 
/// MERN Comparison:
/// In React:
/// ```js
/// function SuccessFeedback({ visible, message, onComplete }) {
///   const [confetti, setConfetti] = useState([]);
///   
///   useEffect(() => {
///     if (!visible) return;
///     generateConfetti();
///     setTimeout(onComplete, 2000);
///   }, [visible]);
///   
///   return (
///     <motion.div animate={{ scale: [0, 1], opacity: [0, 1] }}>
///       <CheckCircle />
///       {confetti.map(p => <ConfettiParticle key={p.id} {...p} />)}
///     </motion.div>
///   );
/// }
/// ```
/// 
/// In Flutter: We use CustomPaint for confetti + AnimatedBuilder for checkmark
/// More performant because painting is done on a canvas directly

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/animations/index.dart';
import '../../../core/theme/index.dart';

class SuccessFeedbackOverlay extends StatefulWidget {
  final AuthFeedbackResult result;
  final VoidCallback onDismiss;

  const SuccessFeedbackOverlay({
    super.key,
    required this.result,
    required this.onDismiss,
  });

  @override
  State<SuccessFeedbackOverlay> createState() => _SuccessFeedbackOverlayState();
}

class _SuccessFeedbackOverlayState extends State<SuccessFeedbackOverlay>
    with TickerProviderStateMixin {
  late AuthAnimationController _animationController;
  late List<ConfettiParticle> _confettiParticles;

  @override
  void initState() {
    super.initState();
    _animationController = AuthAnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _generateConfetti();
    _startAnimation();
  }

  void _generateConfetti() {
    // Generate 30 confetti particles with random properties
    _confettiParticles = List.generate(
      30,
      (index) => ConfettiParticle.random(index),
    );
  }

  void _startAnimation() async {
    await _animationController.playSuccess();
    // Auto-dismiss after animation completes
    if (mounted) {
      await Future.delayed(widget.result.duration);
      widget.onDismiss();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ============= Confetti Particles =============
            ...List.generate(
              _confettiParticles.length,
              (index) => AnimatedBuilder(
                animation: _animationController.controller,
                builder: (context, child) {
                  final particle = _confettiParticles[index];
                  final progress = _animationController.controller.value;

                  // Simulate falling + rotation
                  final offsetY = particle.startY + 
                      (300 * progress); // Fall 300px
                  final rotation = particle.rotation * progress;
                  final opacity = 1.0 - (progress * 0.5); // Fade out

                  return Positioned(
                    left: particle.startX,
                    top: offsetY,
                    child: Transform.rotate(
                      angle: rotation,
                      child: Opacity(
                        opacity: opacity,
                        child: particle.build(),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ============= Success Checkmark =============
            AnimatedBuilder(
              animation: _animationController.successScale,
              builder: (context, child) {
                return Transform.scale(
                  scale: _animationController.successScale.value,
                  child: Opacity(
                    opacity: _animationController.successFade.value,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.95),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.success.withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                  ),
                );
              },
            ),

            // ============= Success Message =============
            Positioned(
              bottom: 100,
              child: AnimatedOpacity(
                opacity: _animationController.successFade.value,
                duration: const Duration(milliseconds: 300),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Success!',
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 280,
                      child: Text(
                        widget.result.message,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Confetti Particle Model
class ConfettiParticle {
  final double startX;
  final double startY;
  final double rotation;
  final Color color;
  final double size;
  final int index;

  ConfettiParticle({
    required this.startX,
    required this.startY,
    required this.rotation,
    required this.color,
    required this.size,
    required this.index,
  });

  factory ConfettiParticle.random(int index) {
    import 'dart:math' as math;
    
    final random = math.Random(index);
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
    ];

    return ConfettiParticle(
      startX: 50 + random.nextDouble() * 280,
      startY: 50 + random.nextDouble() * 100,
      rotation: random.nextDouble() * 6.28,
      color: colors[random.nextInt(colors.length)],
      size: 4 + random.nextDouble() * 8,
      index: index,
    );
  }

  Widget build() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
