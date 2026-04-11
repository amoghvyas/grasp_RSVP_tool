import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/reader_provider.dart';
import 'apple_widgets.dart';

class ActiveRecallOverlay extends StatelessWidget {
  const ActiveRecallOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReaderProvider>();
    final state = provider.state;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!state.isRecallActive) return const SizedBox.shrink();

    return Material(
      color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.95),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: state.recallQuestion == null
                  ? _buildLoading(isDark)
                  : _buildQuestion(context, provider, state, isDark),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading(bool isDark) {
    return Column(
      children: [
        const CircularProgressIndicator(strokeWidth: 2),
        const SizedBox(height: 32),
        Text(
          'Preparing Checkpoint',
          style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Text(
          'Synthesizing what you just read...',
          style: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
        ),
      ],
    );
  }

  Widget _buildQuestion(BuildContext context, ReaderProvider provider, state, bool isDark) {
    return Column(
      children: [
        AppleCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ACTIVE RECALL',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: isDark ? Colors.white24 : Colors.black26),
              ),
              const SizedBox(height: 20),
              Text(
                state.recallQuestion!,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, height: 1.4),
              ),
              const SizedBox(height: 32),
              ...state.recallOptions!.asMap().entries.map((entry) {
                final idx = entry.key;
                final opt = entry.value;
                final isSelected = state.recallSelectedIndex == idx;
                final isCorrect = state.recallCorrectIndex == idx;
                final showResult = state.recallSelectedIndex != null;

                Color color = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03);
                if (showResult) {
                  if (isCorrect) color = Colors.green.withValues(alpha: 0.1);
                  else if (isSelected) color = Colors.red.withValues(alpha: 0.1);
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppleCard(
                    padding: const EdgeInsets.all(16),
                    onTap: showResult ? null : () => provider.submitRecallAnswer(idx),
                    child: Row(
                      children: [
                        Expanded(child: Text(opt, style: const TextStyle(fontSize: 14))),
                        if (showResult && isCorrect) const Icon(Icons.check_circle_rounded, size: 16, color: Colors.green),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        if (state.recallSelectedIndex != null) ...[
          const SizedBox(height: 32),
          AppleButton(
            label: 'Continue Reading',
            onPressed: () => provider.dismissRecall(),
            width: double.infinity,
          ),
        ],
      ],
    );
  }
}
