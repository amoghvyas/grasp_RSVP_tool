import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/orp_service.dart';

/// The core RSVP word display widget.
///
/// Renders a single word with the Optimal Recognition Point (ORP) character
/// highlighted in red and perfectly centered on the screen horizontally.
/// The rest of the word extends to the left and right of the ORP character.
///
/// A thin red vertical guide line marks the fixation point, helping the
/// reader's eyes stay locked on the center.
class WordDisplay extends StatelessWidget {
  /// The word to display.
  final String word;

  /// Font size in logical pixels.
  final double fontSize;

  const WordDisplay({
    super.key,
    required this.word,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    if (word.isEmpty) {
      return const SizedBox.shrink();
    }

    final segments = OrpService.splitWord(word);
    final textStyle = GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      letterSpacing: 2.0,
      height: 1.2,
    );

    // Style for the non-ORP characters (white)
    final normalStyle = textStyle.copyWith(color: Colors.white);
    // Style for the ORP character (vivid red)
    final orpStyle = textStyle.copyWith(
      color: const Color(0xFFFF3B3B),
      fontWeight: FontWeight.w700,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Fixation guide (thin red line above the word) ──────────
        Container(
          width: 2,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFFFF3B3B).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(height: 8),

        // ── The word itself, ORP-aligned to center ─────────────────
        // We use a Row with a layout trick: the "before" text is
        // right-aligned in a container that extends leftward, and
        // the "after" text is left-aligned extending rightward.
        // The ORP character sits at the exact center.
        _buildAlignedWord(segments, normalStyle, orpStyle),

        const SizedBox(height: 8),
        // ── Fixation guide (thin red line below the word) ──────────
        Container(
          width: 2,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFFFF3B3B).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }

  /// Builds the three-segment word display where the ORP character
  /// is anchored at center.
  ///
  /// Layout strategy:
  /// - Left half: A right-aligned container holding the "before" text
  /// - Center: The ORP character
  /// - Right half: A left-aligned container holding the "after" text
  ///
  /// Both halves have equal width so the ORP stays dead-center.
  Widget _buildAlignedWord(
    WordSegments segments,
    TextStyle normalStyle,
    TextStyle orpStyle,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        // ── Left half: "before" text, right-aligned ──────────────
        SizedBox(
          width: fontSize * 4, // Generous width for long left segments
          child: Text(
            segments.before,
            style: normalStyle,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.clip,
          ),
        ),

        // ── Center: ORP character ───────────────────────────────
        Text(
          segments.orp,
          style: orpStyle,
        ),

        // ── Right half: "after" text, left-aligned ──────────────
        SizedBox(
          width: fontSize * 4,
          child: Text(
            segments.after,
            style: normalStyle,
            textAlign: TextAlign.left,
            maxLines: 1,
            overflow: TextOverflow.clip,
          ),
        ),
      ],
    );
  }
}
