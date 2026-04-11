import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

/// Animated gradient mesh background with floating orbs.
class AnimatedBackground extends StatefulWidget {
  final Widget child;
  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _c1;
  late AnimationController _c2;
  late AnimationController _c3;
  late AnimationController _c4;

  @override
  void initState() {
    super.initState();
    _c1 = AnimationController(vsync: this, duration: const Duration(seconds: 14))..repeat(reverse: true);
    _c2 = AnimationController(vsync: this, duration: const Duration(seconds: 19))..repeat(reverse: true);
    _c3 = AnimationController(vsync: this, duration: const Duration(seconds: 16))..repeat(reverse: true);
    _c4 = AnimationController(vsync: this, duration: const Duration(seconds: 22))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c1.dispose(); _c2.dispose(); _c3.dispose(); _c4.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF04040D),
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([_c1, _c2, _c3, _c4]),
            builder: (_, __) => CustomPaint(
              painter: _OrbPainter(
                p1: _c1.value, p2: _c2.value, p3: _c3.value, p4: _c4.value,
              ),
              size: Size.infinite,
            ),
          ),
          // Noise overlay
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.12)),
          ),
          Positioned.fill(child: widget.child),
        ],
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  final double p1, p2, p3, p4;
  const _OrbPainter({required this.p1, required this.p2, required this.p3, required this.p4});

  @override
  void paint(Canvas canvas, Size size) {
    _drawOrb(canvas,
      Offset(size.width * (0.15 + 0.3 * sin(p1 * pi)), size.height * (0.1 + 0.28 * cos(p1 * pi))),
      size.width * 0.55, const Color(0xFF6C63FF), 0.11);

    _drawOrb(canvas,
      Offset(size.width * (0.72 + 0.18 * cos(p2 * pi)), size.height * (0.62 + 0.28 * sin(p2 * pi))),
      size.width * 0.48, const Color(0xFF00D9FF), 0.07);

    _drawOrb(canvas,
      Offset(size.width * (0.48 + 0.22 * sin(p3 * pi * 1.4)), size.height * (0.82 + 0.12 * cos(p3 * pi))),
      size.width * 0.38, const Color(0xFFFF6B9D), 0.06);

    _drawOrb(canvas,
      Offset(size.width * (0.9 + 0.08 * cos(p4 * pi)), size.height * (0.22 + 0.16 * sin(p4 * pi))),
      size.width * 0.3, const Color(0xFF8B7FFF), 0.07);
  }

  void _drawOrb(Canvas canvas, Offset center, double radius, Color color, double alpha) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color.withValues(alpha: alpha), color.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 70);
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_OrbPainter o) => true;
}

// ═══════════════════════════════════════════════════════════════════
//  GLASS CARD
// ═══════════════════════════════════════════════════════════════════

/// Premium glassmorphic container.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final double opacity;
  final Color? accentBorderColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.blur = 14,
    this.opacity = 0.07,
    this.accentBorderColor,
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
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: opacity + 0.02),
                  Colors.white.withValues(alpha: opacity - 0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: accentBorderColor ?? Colors.white.withValues(alpha: 0.1),
                width: accentBorderColor != null ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 24,
                  spreadRadius: -4,
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

// ═══════════════════════════════════════════════════════════════════
//  FADE-SLIDE ENTRANCE
// ═══════════════════════════════════════════════════════════════════

/// Animated entrance: fades + slides in from below.
class FadeSlideIn extends StatelessWidget {
  final Widget child;
  final int delayMs;
  final double offsetY;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.delayMs = 0,
    this.offsetY = 24,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 700 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final delayed = delayMs > 0
            ? ((value - (delayMs / (700 + delayMs))) / (1 - (delayMs / (700 + delayMs))))
                .clamp(0.0, 1.0)
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
