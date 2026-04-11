import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/reader_state.dart';
import '../providers/reader_provider.dart';
import '../widgets/active_recall_overlay.dart';
import '../widgets/animated_background.dart';
import '../widgets/settings_overlay.dart';
import '../widgets/word_display.dart';

/// The full-screen RSVP reading canvas.
///
/// Premium reading experience with:
/// - Pure black background for zero distraction
/// - Smooth word transitions with animated opacity
/// - Gradient progress bar with glow effect
/// - Gesture-based controls covering the entire screen
class ReaderScreen extends StatelessWidget {
  const ReaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReaderProvider>(
      builder: (context, provider, _) {
        final state = provider.state;
        final screenWidth = MediaQuery.of(context).size.width;

        return Scaffold(
          backgroundColor: const Color(0xFF020204),
          body: Stack(
            children: [
              // ── Subtle ambient glow behind the word ─────────────────
              if (state.isPlaying)
                Center(
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF6C63FF).withValues(alpha: 0.03),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

              // ── Main tap area (play/pause) ──────────────────────────
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
                      // ── RSVP Display ─────────────────────────────────────
                      _buildReaderContent(state),

                      // ── Main reading area ──────────────────────────
                      Expanded(
                        child: Center(
                          child: state.hasContent
                              ? AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 80),
                                  transitionBuilder: (child, animation) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
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

                      // ── Bottom progress bar ────────────────────────
                      _buildProgressBar(state),
                    ],
                  ),
                ),
              ),

              // ── Top Bar (Sprint Info) ─────────────────────────────
              _buildTopBar(provider, state),

              // ── Play/Pause indicator ───────────────────────────────
              if (!state.isPlaying && state.hasContent)
                Positioned(
                  bottom: 56,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: AnimatedOpacity(
                      opacity: 0.3,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.pause_rounded,
                          size: 24,
                          color: Colors.white24,
                        ),
                      ),
                    ),
                  ),
                ),

              // ── Settings overlay (shown when paused) ───────────────
              Positioned.fill(
                child: SettingsOverlay(visible: !state.isPlaying),
              ),
              
              // ── Active Recall Overlay ──────────────────────────────
              const ActiveRecallOverlay(),
            ],
          ),
        );
      },
    );
  }

  /// Top bar with word counter and WPM badge.
  Widget _buildTopBar(ReaderProvider provider, ReaderState state) {
    if (!state.isSprintActive) {
      return Positioned(
        top: 24,
        right: 24,
        child: _buildSprintLauncher(provider),
      );
    }

    return Positioned(
      top: 24,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.timer, size: 14, color: Color(0xFF6C63FF)),
              const SizedBox(width: 10),
              Text(
                'SPRINT: ${state.sprintTimeFormatted}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: () => provider.stopSprint(),
                icon: const Icon(Icons.close, size: 14, color: Colors.white24),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSprintLauncher(ReaderProvider provider) {
    return PopupMenuButton<int>(
      onSelected: (mins) => provider.startSprint(mins),
      offset: const Offset(0, 48),
      color: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 15, child: Text('15 Min Sprint')),
        const PopupMenuItem(value: 25, child: Text('25 Min Sprint')),
        const PopupMenuItem(value: 50, child: Text('50 Min Sprint (Deep Work)')),
      ],
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: const Icon(Icons.timer_outlined, size: 20, color: Colors.white54),
      ),
    );
  }

  Widget _buildReaderContent(ReaderState state) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Word counter
            Text(
              '${state.currentIndex + 1} / ${state.totalWords}',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.15),
                letterSpacing: 1.5,
              ),
            ),
            // WPM badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.04),
                ),
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
          ],
        ),
      ),
    );
  }

  /// Bottom gradient progress bar with glow effect.
  Widget _buildProgressBar(ReaderState state) {
    return Container(
      height: 3,
      margin: const EdgeInsets.only(bottom: 28, left: 24, right: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Stack(
              children: [
                // Track
                Container(
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Animated progress fill with glow
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: constraints.maxWidth * state.progress,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF00D9FF)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
