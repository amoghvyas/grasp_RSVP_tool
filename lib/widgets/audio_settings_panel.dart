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
        // Bimodal Reading Toggle
        InkWell(
          onTap: () => provider.toggleTts(!state.isTtsEnabled),
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B9D).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.psychology_rounded, size: 20, color: Color(0xFFFF6B9D)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bimodal Reading (TTS)',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Hear and see words simultaneously for 30% better retention.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.4),
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
