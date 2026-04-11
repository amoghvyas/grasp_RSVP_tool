import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/reader_provider.dart';

/// Translucent glassmorphic overlay shown when the RSVP reader is paused.
class SettingsOverlay extends StatelessWidget {
  final bool visible;
  const SettingsOverlay({super.key, required this.visible});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        opacity: visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        child: Container(
          color: Colors.black.withValues(alpha: 0.72),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  width: 440,
                  constraints: const BoxConstraints(maxHeight: 620),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF1A1A30).withValues(alpha: 0.92),
                        const Color(0xFF0F0F1E).withValues(alpha: 0.92),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C63FF).withValues(alpha: 0.12),
                        blurRadius: 50,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Consumer<ReaderProvider>(
                    builder: (context, provider, _) {
                      final state = provider.state;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ── Header ───────────────────────────────────
                          Container(
                            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.tune_rounded,
                                      size: 16, color: Color(0xFF6C63FF)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Reading Settings',
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF6B9D).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: const Color(0xFFFF6B9D)
                                            .withValues(alpha: 0.25)),
                                  ),
                                  child: Text(
                                    '⏸ PAUSED',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFFFF6B9D),
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ── Scrollable body ───────────────────────────
                          Flexible(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSlider(
                                    context: context,
                                    icon: Icons.speed_rounded,
                                    label: 'Reading Speed',
                                    valueLabel: '${state.wpm} WPM',
                                    hint: _wpmHint(state.wpm),
                                    accentColor: const Color(0xFF6C63FF),
                                    slider: Slider(
                                      value: state.wpm.toDouble(),
                                      min: 100,
                                      max: 1000,
                                      divisions: 90,
                                      label: '${state.wpm} WPM',
                                      onChanged: (v) => provider.setWpm(v.round()),
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  _buildSlider(
                                    context: context,
                                    icon: Icons.text_fields_rounded,
                                    label: 'Font Size',
                                    valueLabel: '${state.fontSize.round()}px',
                                    accentColor: const Color(0xFF00D9FF),
                                    slider: Slider(
                                      value: state.fontSize,
                                      min: 24,
                                      max: 120,
                                      divisions: 96,
                                      label: '${state.fontSize.round()}px',
                                      onChanged: (v) => provider.setFontSize(v),
                                    ),
                                  ),

                                  const SizedBox(height: 20),
                                  const Divider(color: Colors.white10, height: 1),
                                  const SizedBox(height: 20),

                                  // Progress card
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.03),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.06)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildMiniStat('Progress',
                                            '${state.currentIndex + 1} / ${state.totalWords}'),
                                        Container(
                                            width: 1,
                                            height: 36,
                                            color: Colors.white10),
                                        _buildMiniStat('Remaining',
                                            _formatRemaining(state)),
                                        Container(
                                            width: 1,
                                            height: 36,
                                            color: Colors.white10),
                                        _buildMiniStat(
                                            'Speed', '${state.wpm} WPM'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // ── Footer buttons ────────────────────────────
                          Container(
                            padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.06)),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => provider.stopReading(),
                                        icon: const Icon(Icons.arrow_back_rounded,
                                            size: 16),
                                        label: const Text('Exit'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor:
                                              Colors.white.withValues(alpha: 0.6),
                                          side: BorderSide(
                                              color: Colors.white.withValues(
                                                  alpha: 0.12)),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 14),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF6C63FF),
                                                Color(0xFF8B7FFF)
                                              ]),
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF6C63FF)
                                                  .withValues(alpha: 0.35),
                                              blurRadius: 16,
                                              spreadRadius: -4,
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton.icon(
                                          onPressed: () => provider.play(),
                                          icon: const Icon(Icons.play_arrow_rounded,
                                              size: 20),
                                          label: const Text('Resume'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 14),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                            elevation: 0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Tap anywhere to resume  ·  Double-tap left side to rewind 10 words',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
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
        ),
      ),
    );
  }

  Widget _buildSlider({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String valueLabel,
    required Widget slider,
    required Color accentColor,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: accentColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                valueLabel,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: accentColor,
            inactiveTrackColor: accentColor.withValues(alpha: 0.1),
            thumbColor: accentColor,
            overlayColor: accentColor.withValues(alpha: 0.12),
          ),
          child: slider,
        ),
        if (hint != null)
          Padding(
            padding: const EdgeInsets.only(left: 24, top: 0),
            child: Text(
              hint,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.28),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.35),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  String _wpmHint(int wpm) {
    if (wpm < 200) return 'Slow & thoughtful — great for dense technical texts';
    if (wpm < 350) return 'Average reading speed — comfortable and natural';
    if (wpm < 500) return 'Above average — focused reader territory';
    if (wpm < 700) return 'Fast — power reader level';
    return 'Blazing fast — elite speed reader';
  }

  String _formatRemaining(state) {
    final remaining = state.totalWords - state.currentIndex;
    final seconds = (remaining / state.wpm * 60).round();
    if (seconds < 60) return '${seconds}s';
    return '${seconds ~/ 60}m ${seconds % 60}s';
  }
}
