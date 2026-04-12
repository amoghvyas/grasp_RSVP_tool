import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppleCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final VoidCallback? onTap;
  final Color? color;

  const AppleCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: padding ?? const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color ?? (isDark ? const Color(0xFF161617) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
            width: 1,
          ),
          boxShadow: isDark ? [] : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 40,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: DefaultTextStyle(
            style: GoogleFonts.outfit(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 15,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class AppleButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isPrimary;
  final IconData? icon;
  final double? width;

  const AppleButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isPrimary = true,
    this.icon,
    this.width,
  });

  @override
  State<AppleButton> createState() => _AppleButtonState();
}

class _AppleButtonState extends State<AppleButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF00A2FF) : const Color(0xFF0071E3);
    
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: widget.isLoading || widget.onPressed == null ? null : widget.onPressed,
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            width: widget.width,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: widget.onPressed == null 
                ? (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05))
                : (widget.isPrimary ? primaryColor : (isDark ? Colors.white10 : const Color(0xFFF2F2F7))),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.isLoading)
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: widget.isPrimary ? Colors.white : primaryColor,
                    ),
                  )
                else ...[
                  if (widget.icon != null) ...[
                    Icon(widget.icon, size: 18, color: widget.isPrimary ? Colors.white : primaryColor),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.label,
                    style: GoogleFonts.outfit(
                      color: widget.isPrimary ? Colors.white : (isDark ? Colors.white : primaryColor),
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
