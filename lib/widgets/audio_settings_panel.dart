import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/reader_provider.dart';
import '../services/focus_service.dart';

/// A UI component to manage ambient study sounds and bimodal reading.
class AudioSettingsPanel extends StatelessWidget {
  const AudioSettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReaderProvider>();
    final state = provider.state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B9D).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.headphones, size: 16, color: Color(0xFFFF6B9D)),
            ),
            const SizedBox(width: 10),
            Text(
              'Study Atmosphere',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Ambient Sound Selection
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: FocusSound.values.map((sound) {
            final isSelected = state.focusSound == sound;
            return InkWell(
              onTap: () => provider.setFocusSound(sound),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? const Color(0xFFFF6B9D).withValues(alpha: 0.1) 
                      : Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected 
                        ? const Color(0xFFFF6B9D).withValues(alpha: 0.4) 
                        : Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) 
                      const Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: Icon(Icons.equalizer, size: 12, color: Color(0xFFFF6B9D)),
                      ),
                    Text(
                      sound.label,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? const Color(0xFFFF6B9D) : Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        
        if (state.focusSound != FocusSound.none) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.volume_down, size: 14, color: Colors.white24),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                  ),
                  child: Slider(
                    value: state.focusVolume,
                    onChanged: (v) => provider.setFocusVolume(v),
                    activeColor: const Color(0xFFFF6B9D).withValues(alpha: 0.5),
                    inactiveColor: Colors.white10,
                  ),
                ),
              ),
              const Icon(Icons.volume_up, size: 14, color: Colors.white24),
            ],
          ),
        ],

        const SizedBox(height: 24),
        const Divider(color: Colors.white10, height: 1),
        const SizedBox(height: 24),

        // Bimodal Reading Toggle
        InkWell(
          onTap: () => provider.toggleTts(!state.isTtsEnabled),
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bimodal Reading (TTS)',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hear and see words simultaneously for 30% better retention.',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: state.isTtsEnabled,
                onChanged: (v) => provider.toggleTts(v),
                activeColor: const Color(0xFFFF6B9D),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
