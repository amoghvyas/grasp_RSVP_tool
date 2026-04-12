import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'apple_widgets.dart';

class ArenaRulesModal extends StatelessWidget {
  final VoidCallback onAccept;
  const ArenaRulesModal({super.key, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: AppleCard(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.gavel_rounded, color: Color(0xFF0071E3), size: 24),
                  const SizedBox(width: 16),
                  Text(
                    'ARENA PROTOCOLS',
                    style: GoogleFonts.outfit(
                      fontSize: 12, 
                      fontWeight: FontWeight.w800, 
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _ruleItem(
                'High-Stakes Integrity',
                'The Scholarly Arena monitors for robotic behavior. Attempting to answer analytical questions under 800ms will result in disqualification.',
                Icons.security_rounded,
                isDark,
              ),
              const SizedBox(height: 24),
              _ruleItem(
                'Meritorious Scoring',
                'Scores are calculated based on both accuracy and analytical speed. Early correct responses earn the highest scholarship points.',
                Icons.trending_up_rounded,
                isDark,
              ),
              const SizedBox(height: 24),
              _ruleItem(
                'Scholarly Identity',
                'Your nickname must remain professional. The AI Guardian filters all entries to maintain academic prestige.',
                Icons.psychology_rounded,
                isDark,
              ),
              const SizedBox(height: 48),
              AppleButton(
                label: 'Agree & Enter Arena',
                onPressed: onAccept,
                width: double.infinity,
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'By entering, you commit to competitive excellence.',
                  style: TextStyle(fontSize: 10, color: isDark ? Colors.white24 : Colors.black26),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ruleItem(String title, String desc, IconData icon, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: isDark ? Colors.white30 : Colors.black38),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 6),
              Text(
                desc,
                style: TextStyle(fontSize: 13, height: 1.5, color: isDark ? Colors.white54 : Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
