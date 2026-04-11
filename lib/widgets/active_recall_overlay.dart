import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/reader_provider.dart';

/// A premium, focused overlay for Active Recall checkpoints.
class ActiveRecallOverlay extends StatelessWidget {
  const ActiveRecallOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReaderProvider>();
    final state = provider.state;

    // Only show if recall is active
    if (!state.isRecallActive) return const SizedBox.shrink();

    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: (state.recallQuestion == null)
                ? _buildLoading()
                : _buildQuestion(context, provider, state),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(color: Color(0xFF6C63FF)),
        const SizedBox(height: 24),
        Text(
          'Preparing Checkpoint...',
          style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          'Gemini is analyzing what you just read.',
          style: GoogleFonts.inter(color: Colors.white38, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildQuestion(BuildContext context, ReaderProvider provider, state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Badge
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt, size: 14, color: Color(0xFF6C63FF)),
                const SizedBox(width: 8),
                Text(
                  'MASTERY CHECKPOINT',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF6C63FF),
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // The Question
        Text(
          state.recallQuestion!,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Options
        ...List.generate(state.recallOptions.length, (index) {
          return _buildOption(context, provider, state, index);
        }),

        const SizedBox(height: 48),

        // Bottom Action
        if (state.hasAnsweredRecall)
          ElevatedButton(
            onPressed: () => provider.dismissRecall(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              padding: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              'Resume Sprint',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          )
        else
          Center(
            child: Text(
              'Choose the most accurate answer to continue.',
              style: GoogleFonts.inter(color: Colors.white24, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildOption(BuildContext context, ReaderProvider provider, state, int index) {
    final optionText = state.recallOptions[index];
    final isSelected = state.selectedRecallIndex == index;
    final isCorrect = state.recallCorrectIndex == index;
    final showAnswer = state.hasAnsweredRecall;

    Color color = Colors.white.withValues(alpha: 0.05);
    Color borderColor = Colors.white.withValues(alpha: 0.1);
    Color textColor = Colors.white.withValues(alpha: 0.7);

    if (showAnswer) {
      if (isCorrect) {
        color = Colors.green.withValues(alpha: 0.15);
        borderColor = Colors.green.withValues(alpha: 0.4);
        textColor = Colors.greenAccent;
      } else if (isSelected) {
        color = Colors.red.withValues(alpha: 0.15);
        borderColor = Colors.red.withValues(alpha: 0.4);
        textColor = Colors.redAccent;
      }
    } else if (isSelected) {
      color = const Color(0xFF6C63FF).withValues(alpha: 0.1);
      borderColor = const Color(0xFF6C63FF);
      textColor = Colors.white;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: state.hasAnsweredRecall ? null : () => provider.submitRecallAnswer(index),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Text(
                String.fromCharCode(65 + index), // A, B, C, D
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w900,
                  color: textColor.withValues(alpha: 0.5),
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  optionText,
                  style: GoogleFonts.inter(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              if (showAnswer && isCorrect)
                const Icon(Icons.check_circle, color: Colors.greenAccent, size: 20),
              if (showAnswer && isSelected && !isCorrect)
                const Icon(Icons.cancel, color: Colors.redAccent, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
