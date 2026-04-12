import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScholarlyLoaderOverlay extends StatelessWidget {
  final String message;
  
  const ScholarlyLoaderOverlay({super.key, this.message = 'Constructing Scholarly Arena...'});

  static void show(BuildContext context, {String message = 'Constructing Scholarly Arena...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ScholarlyLoaderOverlay(message: message),
    );
  }

  static void hide(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0071E3)),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                message,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'AI is generating high-fidelity questions...',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
