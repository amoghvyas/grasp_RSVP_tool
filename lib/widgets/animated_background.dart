import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

/// Animated gradient mesh background with floating orbs.
///
/// Creates a premium, living background with slowly morphing gradient
/// orbs that drift across the screen. Used as the base layer behind
/// all glassmorphic content.
class AnimatedBackground extends StatefulWidget {
  /// The child widget rendered on top of the background.
  final Widget child;

  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;

  @override
  void initState() {
    super.initState();

    // Three controllers at different speeds for organic movement
    _controller1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    _controller2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat(reverse: true);

    _controller3 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF05050A), // Near-black base
      child: Stack(
        children: [
          // ── Animated gradient orbs ──────────────────────────────
          AnimatedBuilder(
            animation: Listenable.merge([_controller1, _controller2, _controller3]),
            builder: (context, _) {
              return CustomPaint(
                painter: _OrbPainter(
                  progress1: _controller1.value,
                  progress2: _controller2.value,
                  progress3: _controller3.value,
                ),
                size: Size.infinite,
              );
            },
          ),

          // ── Noise/grain overlay for premium feel ────────────────
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.15),
            ),
          ),

          // ── Content ────────────────────────────────────────────
          Positioned.fill(child: widget.child),
        ],
      ),
    );
  }
}

/// Custom painter that renders soft, blurred gradient orbs
/// at positions determined by animation progress values.
class _OrbPainter extends CustomPainter {
  final double progress1;
  final double progress2;
  final double progress3;

  _OrbPainter({
    required this.progress1,
    required this.progress2,
    required this.progress3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // ── Orb 1: Purple (primary accent) ───────────────────────
    _drawOrb(
      canvas,
      Offset(
        size.width * (0.2 + 0.3 * sin(progress1 * pi)),
        size.height * (0.15 + 0.25 * cos(progress1 * pi)),
      ),
      size.width * 0.5,
      const Color(0xFF6C63FF).withValues(alpha: 0.12),
    );

    // ── Orb 2: Cyan (secondary accent) ──────────────────────
    _drawOrb(
      canvas,
      Offset(
        size.width * (0.7 + 0.2 * cos(progress2 * pi)),
        size.height * (0.6 + 0.3 * sin(progress2 * pi)),
      ),
      size.width * 0.45,
      const Color(0xFF00D9FF).withValues(alpha: 0.08),
    );

    // ── Orb 3: Magenta (warm accent) ────────────────────────
    _drawOrb(
      canvas,
      Offset(
        size.width * (0.5 + 0.25 * sin(progress3 * pi * 1.5)),
        size.height * (0.8 + 0.15 * cos(progress3 * pi)),
      ),
      size.width * 0.35,
      const Color(0xFFFF6B9D).withValues(alpha: 0.06),
    );
  }

  void _drawOrb(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withValues(alpha: 0)],
        stops: const [0.0, 1.0],
      ).createShader(
        Rect.fromCircle(center: center, radius: radius),
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_OrbPainter oldDelegate) => true;
}

/// A glassmorphic container with frosted glass effect.
///
/// Wraps content in a semi-transparent, blurred container with
/// a subtle border — creating the premium "frosted glass" appearance.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final double opacity;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.blur = 12,
    this.opacity = 0.08,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: opacity),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: -5,
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Animated entrance wrapper that fades + slides content in from below.
class FadeSlideIn extends StatelessWidget {
  final Widget child;
  final int delayMs;
  final double offsetY;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.delayMs = 0,
    this.offsetY = 30,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        // Apply delay by clamping the effective progress
        final delayed = delayMs > 0
            ? ((value - (delayMs / (600 + delayMs))) / (1 - (delayMs / (600 + delayMs)))).clamp(0.0, 1.0)
            : value;

        return Opacity(
          opacity: delayed,
          child: Transform.translate(
            offset: Offset(0, offsetY * (1 - delayed)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
