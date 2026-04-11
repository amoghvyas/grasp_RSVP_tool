import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WordDisplay extends StatelessWidget {
  final String word;
  final double fontSize;

  const WordDisplay({
    super.key,
    required this.word,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Find the ORP (Optimal Recognition Point)
    // Usually the middle or slightly left of middle
    final int orpIdx = (word.length / 2).floor();
    
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: word.substring(0, orpIdx)),
          TextSpan(
            text: word.isNotEmpty ? word[orpIdx] : '',
            style: const TextStyle(color: Color(0xFFFF3B30)), // Apple Red for ORP focus
          ),
          if (word.length > orpIdx + 1)
            TextSpan(text: word.substring(orpIdx + 1)),
        ],
      ),
      style: GoogleFonts.outfit(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : Colors.black,
        letterSpacing: -0.5,
      ),
      textAlign: TextAlign.center,
    );
  }
}
