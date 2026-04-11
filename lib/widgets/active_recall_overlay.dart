import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/reader_provider.dart';

/// Full-screen Active Recall mastery checkpoint overlay.
class ActiveRecallOverlay extends StatelessWidget {
  const ActiveRecallOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReaderProvider>();
    final state = provider.state;

    if (!state.isRecallActive) return const SizedBox.shrink();

    return Material(
      color: Colors.black.withValues(alpha: 0.88),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.06),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: state.recallQuestion == null
                    ? _buildLoading(key: const ValueKey('loading'))
                    : _buildQuestion(
                        context, provider, state, key: const ValueKey('question')),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Loading ──────────────────────────────────────────────────────────

  Widget _buildLoading({Key? key}) {
    return Column(
      key: key,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: const RadialGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF3D357A)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.5),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Preparing Checkpoint',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Gemini is analyzing what you just read...',
          style: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ── Question ─────────────────────────────────────────────────────────

  Widget _buildQuestion(BuildContext context, ReaderProvider provider, state, {Key? key}) {
    return Column(
      key: key,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Badge
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6C63FF).withValues(alpha: 0.3),
                  const Color(0xFF00D9FF).withValues(alpha: 0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt_rounded, size: 14, color: Color(0xFF8B7FFF)),
                const SizedBox(width: 7),
                Text(
                  'MASTERY CHECKPOINT',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF8B7FFF),
                    letterSpacing: 2.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),

        // Question
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, Color(0xFFD0CCFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            state.recallQuestion!,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.35,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 32),

        // Options
        ...List.generate(state.recallOptions.length, (i) {
          return _buildOption(context, provider, state, i);
        }),

        const SizedBox(height: 28),

        // Bottom action
        if (state.hasAnsweredRecall)
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF8B7FFF)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: -4,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => provider.dismissRecall(),
              icon: const Icon(Icons.play_arrow_rounded, size: 20),
              label: Text(
                'Resume Reading',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            ),
          )
        else
          Center(
            child: Text(
              'Select the most accurate answer to continue',
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

    Color bgColor = Colors.white.withValues(alpha: 0.04);
    Color borderColor = Colors.white.withValues(alpha: 0.08);
    Color textColor = Colors.white.withValues(alpha: 0.75);
    Color letterColor = Colors.white.withValues(alpha: 0.3);

    if (showAnswer) {
      if (isCorrect) {
        bgColor = Colors.green.withValues(alpha: 0.12);
        borderColor = Colors.green.withValues(alpha: 0.5);
        textColor = const Color(0xFF69F0AE);
        letterColor = const Color(0xFF69F0AE).withValues(alpha: 0.6);
      } else if (isSelected) {
        bgColor = const Color(0xFFFF4757).withValues(alpha: 0.1);
        borderColor = const Color(0xFFFF4757).withValues(alpha: 0.4);
        textColor = const Color(0xFFFF6B81);
        letterColor = const Color(0xFFFF6B81).withValues(alpha: 0.6);
      }
    } else if (isSelected) {
      bgColor = const Color(0xFF6C63FF).withValues(alpha: 0.15);
      borderColor = const Color(0xFF6C63FF).withValues(alpha: 0.5);
      textColor = Colors.white;
      letterColor = const Color(0xFF8B7FFF);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: state.hasAnsweredRecall ? null : () => provider.submitRecallAnswer(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: letterColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: letterColor.withValues(alpha: 0.4)),
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w800,
                      color: letterColor,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  optionText,
                  style: GoogleFonts.inter(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
              if (showAnswer && isCorrect)
                const Icon(Icons.check_circle_rounded, color: Color(0xFF69F0AE), size: 20),
              if (showAnswer && isSelected && !isCorrect)
                const Icon(Icons.cancel_rounded, color: Color(0xFFFF6B81), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
