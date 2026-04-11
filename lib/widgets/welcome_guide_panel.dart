import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A premium, expandable welcome guide that explains the tool's capability.
///
/// Provides a high-level overview of RSVP science, AI integration,
/// and pro-tips for maximizing academic performance.
class WelcomeGuidePanel extends StatelessWidget {
  const WelcomeGuidePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      height: 140, // fixed height for horizontal scroll
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: [
          _buildFeatureCard(
            Icons.bolt_rounded,
            const Color(0xFF6C63FF),
            'Focus-Flow Reader',
            'Read 5x faster by eliminating sub-vocalization directly into your visual center.',
          ),
          const SizedBox(width: 16),
          _buildFeatureCard(
            Icons.psychology_rounded,
            const Color(0xFF00D9FF),
            'AI-Generated Intelligence',
            'Turbocharged by Groq LPU to instantly create Summaries, Viva Q&A, and Interactive Quizzes.',
          ),
          const SizedBox(width: 16),
          _buildFeatureCard(
            Icons.query_stats_rounded,
            const Color(0xFFFF6B9D),
            'Active Retention Loop',
            'Take auto-generated conceptual quizzes after chunks of reading to force maximum retention.',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, Color color, String title, String subtitle) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 12,
                height: 1.5,
                color: Colors.white.withValues(alpha: 0.45),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
