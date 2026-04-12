import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GreetingNotification {
  static void showMSTGreeting(BuildContext context) {
    final now = DateTime.now();
    // Strictly trigger only on April 12, 2026
    if (now.year == 2026 && now.month == 4 && now.day == 12) {
      _displayFloatingPill(context, "🍀 Good luck with MST-1, MediCaps Scholars!");
    }
  }

  static void showFeatureAnnouncement(BuildContext context) {
    _displayFloatingPill(
      context, 
      "🚀 New: User-suggested Recap Intensity is live! (Special thanks to the anonymous scholar for the idea)",
      duration: const Duration(seconds: 8),
    );
  }

  static void _displayFloatingPill(BuildContext context, String message, {Duration duration = const Duration(seconds: 4)}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        child: _AnimatedPill(
          message: message,
          onDismiss: () => entry.remove(),
        ),
      ),
    );

    overlay.insert(entry);
    
    // Auto-dismiss after specified duration
    Timer(duration, () {
      if (entry.mounted) entry.remove();
    });
  }
}

class _AnimatedPill extends StatefulWidget {
  final String message;
  final VoidCallback onDismiss;

  const _AnimatedPill({required this.message, required this.onDismiss});

  @override
  State<_AnimatedPill> createState() => _AnimatedPillState();
}

class _AnimatedPillState extends State<_AnimatedPill> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<double>(begin: -80.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Opacity(
        opacity: _opacityAnimation.value,
        child: Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: child,
        ),
      ),
      child: IgnorePointer(
        ignoring: true, // Crucial: Allows clicks to pass through to the UI below
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 80),
                    child: Text(
                      widget.message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
