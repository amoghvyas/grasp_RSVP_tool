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

  static void _displayFloatingPill(BuildContext context, String message) {
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
    
    // Auto-dismiss after 4 seconds
    Timer(const Duration(seconds: 4), () {
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.message,
                      style: GoogleFonts.outfit(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
