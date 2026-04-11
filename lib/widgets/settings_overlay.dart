import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/reader_provider.dart';
import 'apple_widgets.dart';

class SettingsOverlay extends StatelessWidget {
  final bool visible;
  const SettingsOverlay({super.key, required this.visible});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        opacity: visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.8),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: AppleCard(
                    padding: EdgeInsets.zero,
                    child: Consumer<ReaderProvider>(
                      builder: (context, provider, _) {
                        final state = provider.state;
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildHeader(isDark),
                            Flexible(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  children: [
                                    _buildSliderSection(
                                      'Reading Speed',
                                      '${state.wpm} WPM',
                                      state.wpm.toDouble(),
                                      100, 1000, 90,
                                      (v) => provider.setWpm(v.round()),
                                      isDark,
                                    ),
                                    const SizedBox(height: 32),
                                    _buildSliderSection(
                                      'Font Size',
                                      '${state.fontSize.round()}px',
                                      state.fontSize,
                                      24, 120, 96,
                                      (v) => provider.setFontSize(v),
                                      isDark,
                                    ),
                                    const SizedBox(height: 32),
                                    _buildStatsBlock(state, isDark),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(height: 1),
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: AppleButton(
                                      label: 'Finish Reading',
                                      isPrimary: false,
                                      onPressed: () => provider.stopReading(),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: AppleButton(
                                      label: 'Resume',
                                      onPressed: () => provider.togglePlayPause(),
                                    ),
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
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Row(
        children: [
          Icon(Icons.tune_rounded, size: 18, color: isDark ? const Color(0xFF00A2FF) : const Color(0xFF0071E3)),
          const SizedBox(width: 12),
          Text(
            'Control Center',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'PAUSED',
              style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSection(String label, String value, double current, double min, double max, int divisions, Function(double) onChanged, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            Text(value, style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF00A2FF) : const Color(0xFF0071E3), fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: current,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildStatsBlock(state, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('Remaining', state.estimatedRemainingTimeFormatted, isDark),
          _statItem('Words Left', '${state.totalWords - state.currentIndex - 1}', isDark),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: isDark ? Colors.white24 : Colors.black26, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
