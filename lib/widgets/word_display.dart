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
    if (word.isEmpty) return const SizedBox.shrink();
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Find the ORP (Optimal Recognition Point)
    // Professional RSVP logic for ORP:
    final int orpIdx = _calculateOrpIndex(word);
    
    final prefix = word.substring(0, orpIdx);
    final orpChar = word[orpIdx];
    final suffix = word.substring(orpIdx + 1);

    final baseStyle = GoogleFonts.outfit(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: isDark ? Colors.white : Colors.black,
      letterSpacing: -0.5,
    );

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        // Prefix: aligned to the right of the left half
        Expanded(
          child: Text(
            prefix,
            style: baseStyle,
            textAlign: TextAlign.end,
          ),
        ),
        // ORP Character: The strictly centered focus point
        Text(
          orpChar,
          style: baseStyle.copyWith(color: const Color(0xFFFF3B30)), // Academic Red
          textAlign: TextAlign.center,
        ),
        // Suffix: aligned to the left of the right half
        Expanded(
          child: Text(
            suffix,
            style: baseStyle,
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }

  int _calculateOrpIndex(String word) {
    final length = word.length;
    if (length == 0) return 0;
    if (length <= 1) return 0;
    if (length <= 5) return 1;
    if (length <= 9) return 2;
    if (length <= 13) return 3;
    return 4;
  }
}
