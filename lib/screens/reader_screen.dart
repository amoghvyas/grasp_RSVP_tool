import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/reader_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/settings_overlay.dart';
import '../widgets/word_display.dart';
import '../widgets/active_recall_overlay.dart';

/// The full-screen RSVP reading canvas — distraction-free reading mode.
class ReaderScreen extends StatelessWidget {
  const ReaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReaderProvider>(
      builder: (context, provider, _) {
        final state = provider.state;
        final screenWidth = MediaQuery.of(context).size.width;

        return Scaffold(
          backgroundColor: const Color(0xFF020208),
          body: Stack(
            children: [
              // ── Subtle ambient glow ────────────────────────────────
              if (state.isPlaying)
                Center(
                  child: Container(
                    width: 360,
                    height: 360,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF6C63FF).withValues(alpha: 0.04),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

              // ── Main tap zone ──────────────────────────────────────
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => provider.togglePlayPause(),
                onDoubleTapDown: (details) {
                  if (details.localPosition.dx < screenWidth / 2) {
                    provider.rewind(10);
                  }
                },
                onDoubleTap: () {},
                child: SizedBox.expand(
                  child: Column(
                    children: [
                      // ── Top stats bar ────────────────────────────
                      _buildTopBar(context, provider, state),

                      // ── Word display ─────────────────────────────
                      Expanded(
                        child: Center(
                          child: state.hasContent
                              ? AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 75),
                                  transitionBuilder: (child, animation) =>
                                      FadeTransition(opacity: animation, child: child),
                                  child: WordDisplay(
                                    key: ValueKey(state.currentIndex),
                                    word: state.currentWord,
                                    fontSize: state.fontSize,
                                  ),
                                )
                              : Text(
                                  'No text loaded',
                                  style: GoogleFonts.inter(
                                    color: Colors.white12,
                                    fontSize: 18,
                                  ),
                                ),
                        ),
                      ),

                      // ── Progress bar ─────────────────────────────
                      _buildProgressBar(state),
                    ],
                  ),
                ),
              ),

              // ── Paused hint ────────────────────────────────────────
              if (!state.isPlaying && state.hasContent && !state.isRecallActive)
                Positioned(
                  bottom: 60,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: AnimatedOpacity(
                      opacity: 0.35,
                      duration: const Duration(milliseconds: 400),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                            ),
                            child: const Icon(Icons.pause_rounded, size: 22, color: Colors.white54),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to resume',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.white24,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // ── Settings overlay ────────────────────────────────────
              Positioned.fill(
                child: SettingsOverlay(visible: !state.isPlaying && !state.isRecallActive),
              ),

              // ── Active recall overlay ───────────────────────────────
              const ActiveRecallOverlay(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context, ReaderProvider provider, state) {
    if (state.isSprintActive) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_rounded, size: 14, color: Color(0xFF6C63FF)),
                    const SizedBox(width: 8),
                    Text(
                      'SPRINT  ${state.sprintTimeFormatted}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => provider.stopSprint(),
                      child: const Icon(Icons.close_rounded, size: 14, color: Colors.white30),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Word counter
            Text(
              '${state.currentIndex + 1} / ${state.totalWords}',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.14),
                letterSpacing: 1.5,
              ),
            ),
            // WPM + Sprint launcher
            Row(
              children: [
                _buildThemeToggle(),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Text(
                    '${state.wpm} WPM',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.2),
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildSprintLauncher(provider),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSprintLauncher(ReaderProvider provider) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _sprintChip(provider, 15, Icons.bolt_rounded, '15m'),
        const SizedBox(width: 8),
        _sprintChip(provider, 25, Icons.local_fire_department_rounded, '25m'),
        const SizedBox(width: 8),
        _sprintChip(provider, 50, Icons.psychology_rounded, '50m'),
      ],
    );
  }

  Widget _sprintChip(ReaderProvider provider, int mins, IconData icon, String label) {
    return GestureDetector(
      onTap: () => provider.startSprint(mins),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 12, color: const Color(0xFF6C63FF)),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeToggle() {
    return Consumer<ThemeProvider>(
      builder: (context, theme, _) {
        return GestureDetector(
          onTap: () => theme.toggle(),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Icon(
              theme.isDarkMode ? Icons.nightlight_round : Icons.wb_sunny_rounded,
              size: 14,
              color: theme.isDarkMode ? const Color(0xFF6C63FF) : Colors.amber,
            ),
          ),
        );
      },
    );
  }


  Widget _buildProgressBar(state) {
    return Container(
      height: 3,
      margin: const EdgeInsets.only(bottom: 24, left: 0, right: 0),
      child: LayoutBuilder(
        builder: (context, constraints) => ClipRRect(
          child: Stack(
            children: [
              Container(
                width: constraints.maxWidth,
                color: Colors.white.withValues(alpha: 0.04),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 130),
                width: constraints.maxWidth * state.progress,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF00D9FF)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withValues(alpha: 0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
