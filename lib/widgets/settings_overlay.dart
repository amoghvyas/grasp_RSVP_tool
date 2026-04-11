import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/reader_provider.dart';
import 'audio_settings_panel.dart';

/// Translucent overlay shown when the RSVP reader is paused.
///
/// Provides real-time sliders for:
/// - WPM (Words Per Minute) adjustment: 100–1000
/// - Font size adjustment: 24–120
///
/// Also includes an exit button to return to the input dashboard.
/// Fades in/out using [AnimatedOpacity].
class SettingsOverlay extends StatelessWidget {
  /// Whether the overlay should be visible.
  final bool visible;

  const SettingsOverlay({
    super.key,
    required this.visible,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        opacity: visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Container(
          color: Colors.black.withValues(alpha: 0.75),
          child: Center(
            child: Container(
              width: 420,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                    blurRadius: 40,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Consumer<ReaderProvider>(
                builder: (context, provider, _) {
                  final state = provider.state;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header ────────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Settings',
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'PAUSED',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF6C63FF),
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Scrollable content
                      Flexible(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(right: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildWpmSection(state, provider),
                              const SizedBox(height: 24),
                              _buildFontSizeSection(state, provider),
                              const SizedBox(height: 24),
                              const Divider(color: Colors.white10, height: 1),
                              const SizedBox(height: 24),
                              const AudioSettingsPanel(),
                              const SizedBox(height: 24),
                              const Divider(color: Colors.white10, height: 1),
                              const SizedBox(height: 24),
                              _buildProgressSection(state),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ── Controls ──────────────────────────────────
                      Row(
                        children: [
                          // Exit button
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => provider.stopReading(),
                              icon: const Icon(Icons.arrow_back, size: 18),
                              label: const Text('Exit'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white70,
                                side: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.15),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Resume button
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: () => provider.play(),
                              icon: const Icon(Icons.play_arrow, size: 20),
                              label: const Text('Resume'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ── Hints ─────────────────────────────────────
                      Center(
                        child: Text(
                          'Tap anywhere to resume  •  Double-tap left to rewind',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWpmSection(state, provider) {
    return _buildSliderSection(
      icon: Icons.speed,
      label: 'Reading Speed',
      value: '${state.wpm} WPM',
      slider: Slider(
        value: state.wpm.toDouble(),
        min: 100,
        max: 1000,
        divisions: 90,
        label: '${state.wpm} WPM',
        onChanged: (v) => provider.setWpm(v.round()),
      ),
      hint: _getWpmHint(state.wpm),
    );
  }

  Widget _buildFontSizeSection(state, provider) {
    return _buildSliderSection(
      icon: Icons.text_fields,
      label: 'Font Size',
      value: '${state.fontSize.round()}px',
      slider: Slider(
        value: state.fontSize,
        min: 24,
        max: 120,
        divisions: 96,
        label: '${state.fontSize.round()}px',
        onChanged: (v) => provider.setFontSize(v),
      ),
    );
  }

  Widget _buildProgressSection(state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStat(
            'Progress',
            '${state.currentIndex + 1} / ${state.totalWords}',
          ),
          _buildStat(
            'Remaining',
             _formatRemaining(state),
          ),
        ],
      ),
    );
  }

  /// Builds a labeled slider section with an icon, label, current value, and hint.
  Widget _buildSliderSection({
    required IconData icon,
    required String label,
    required String value,
    required Widget slider,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF6C63FF)),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6C63FF),
                ),
              ),
            ),
          ],
        ),
        slider,
        if (hint != null)
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(
              hint,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
          ),
      ],
    );
  }

  /// Builds a small stat column (label + value).
  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.4),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  /// Returns a human-readable description of the current WPM level.
  String _getWpmHint(int wpm) {
    if (wpm < 200) return 'Slow and steady — great for complex texts';
    if (wpm < 350) return 'Average reading speed';
    if (wpm < 500) return 'Above average — focused reading';
    if (wpm < 700) return 'Fast — power reader territory';
    return 'Blazing fast — for the speed reading pros';
  }

  /// Formats the remaining reading time.
  String _formatRemaining(state) {
    final remaining = state.totalWords - state.currentIndex;
    final seconds = (remaining / state.wpm * 60).round();
    if (seconds < 60) return '${seconds}s';
    return '${seconds ~/ 60}m ${seconds % 60}s';
  }
}
