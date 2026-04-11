import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/reader_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/settings_overlay.dart';
import '../widgets/word_display.dart';
import '../widgets/active_recall_overlay.dart';

class ReaderScreen extends StatelessWidget {
  const ReaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReaderProvider>(
      builder: (context, provider, _) {
        final state = provider.state;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFFBFBFD),
          body: Stack(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => provider.togglePlayPause(),
                onDoubleTapDown: (details) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  if (details.localPosition.dx < screenWidth / 2) {
                    provider.rewind(10);
                  }
                },
                child: SizedBox.expand(
                  child: Column(
                    children: [
                      _buildTopBar(context, provider, state, isDark),
                      Expanded(
                        child: Center(
                          child: state.hasContent
                              ? AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 75),
                                  transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                                  child: WordDisplay(
                                    key: ValueKey(state.currentIndex),
                                    word: state.currentWord,
                                    fontSize: state.fontSize,
                                  ),
                                )
                              : Text(
                                  'NO CONTENT LOADED',
                                  style: GoogleFonts.outfit(
                                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 2,
                                  ),
                                ),
                        ),
                      ),
                      _buildProgressBar(state, isDark),
                    ],
                  ),
                ),
              ),

              if (!state.isPlaying && state.hasContent && !state.isRecallActive)
                _buildPausedOverlay(isDark),

              Positioned.fill(
                child: SettingsOverlay(visible: !state.isPlaying && !state.isRecallActive),
              ),
              const ActiveRecallOverlay(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context, ReaderProvider provider, state, bool isDark) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${state.currentIndex + 1}  /  ${state.totalWords}',
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.2),
                letterSpacing: 1.5,
              ),
            ),
            Row(
              children: [
                _buildThemeToggle(context, isDark),
                const SizedBox(width: 16),
                _buildWpmBadge(state, isDark),
                const SizedBox(width: 16),
                _buildSprintControls(provider, state, isDark),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWpmBadge(state, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${state.wpm} WPM',
        style: GoogleFonts.outfit(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _buildSprintControls(ReaderProvider provider, state, bool isDark) {
    if (state.isSprintActive) {
      return GestureDetector(
        onTap: () => provider.stopSprint(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: (isDark ? const Color(0xFF00A2FF) : const Color(0xFF0071E3)).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: (isDark ? const Color(0xFF00A2FF) : const Color(0xFF0071E3)).withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.timer_rounded, size: 12, color: isDark ? const Color(0xFF00A2FF) : const Color(0xFF0071E3)),
              const SizedBox(width: 8),
              Text(
                state.sprintTimeFormatted,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.close_rounded, size: 10, color: Colors.white24),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        _sprintBtn(provider, 15, isDark),
        const SizedBox(width: 8),
        _sprintBtn(provider, 25, isDark),
        const SizedBox(width: 8),
        _sprintBtn(provider, 50, isDark),
      ],
    );
  }

  Widget _sprintBtn(ReaderProvider provider, int mins, bool isDark) {
    return GestureDetector(
      onTap: () => provider.startSprint(mins),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '${mins}m',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.2),
          ),
        ),
      ),
    );
  }

  Widget _buildPausedOverlay(bool isDark) {
    return Positioned(
      bottom: 100,
      left: 0,
      right: 0,
      child: Center(
        child: Column(
          children: [
            Icon(Icons.pause_circle_filled_rounded, size: 48, color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05)),
            const SizedBox(height: 12),
            Text(
              'PAUSED',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () => context.read<ThemeProvider>().toggle(),
      child: Icon(
        isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
        size: 18,
        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.2),
      ),
    );
  }

  Widget _buildProgressBar(state, bool isDark) {
    final progress = state.progress;
    return Container(
      height: 2,
      width: double.infinity,
      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(color: isDark ? const Color(0xFF00A2FF) : const Color(0xFF0071E3)),
      ),
    );
  }
}
