import 'package:flutter/material.dart';

class WelcomeGuidePanel extends StatelessWidget {
  const WelcomeGuidePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'GETTING STARTED',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _guideCard(
                'Import',
                'Paste text, upload a PDF, or link an article URL.',
                Icons.add_rounded,
                isDark,
              ),
              const SizedBox(width: 12),
              _guideCard(
                'Calibrate',
                'Adjust your speed. Start at 300 WPM and scale.',
                Icons.speed_rounded,
                isDark,
              ),
              const SizedBox(width: 12),
              _guideCard(
                'Master',
                'Use AI tools to generate MCQs and summaries.',
                Icons.auto_awesome_rounded,
                isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _guideCard(String title, String desc, IconData icon, bool isDark) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.02)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: isDark ? Colors.white38 : Colors.black38),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }
}
