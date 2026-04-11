import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A premium, expandable welcome guide that explains the tool's capability.
///
/// Provides a high-level overview of RSVP science, AI integration,
/// and pro-tips for maximizing academic performance.
class WelcomeGuidePanel extends StatefulWidget {
  const WelcomeGuidePanel({super.key});

  @override
  State<WelcomeGuidePanel> createState() => _WelcomeGuidePanelState();
}

class _WelcomeGuidePanelState extends State<WelcomeGuidePanel> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isExpanded 
              ? const Color(0xFF6C63FF).withValues(alpha: 0.3) 
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // ── Header (Always Visible) ──────────────────────────────────
            InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        size: 20,
                        color: Color(0xFF6C63FF),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Master Your Material with Grasp',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isExpanded 
                                ? 'Expert guide to supercharged learning'
                                : 'How Grasp turns you into a high-speed learner...',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ],
                ),
              ),
            ),

            // ── Expandable Content ───────────────────────────────────────
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(color: Colors.white10, height: 1),
                    const SizedBox(height: 24),
                    
                    _buildSection(
                      icon: Icons.bolt,
                      color: const Color(0xFF6C63FF),
                      title: 'The RSVP High-Speed Edge',
                      content: 'Grasp uses **RSVP (Rapid Serial Visual Presentation)** to eliminate "sub-vocalization" — the silent voice in your head that slows you down. By focusing your gaze on a single point, you bypass traditional reading blocks and process info up to **3-5x faster** with less eye fatigue.',
                    ),
                    const SizedBox(height: 24),
                    
                    _buildSection(
                      icon: Icons.psychology,
                      color: const Color(0xFF00D9FF),
                      title: 'AI-Powered Retention',
                      content: 'Speed is useless without retention. Grasp uses **Gemini AI** to generate structured summaries and viva-style Q&A from your material. Use the **Summary** for a quick refresher and the **Viva Q&A** to test your real understanding before exams.',
                    ),
                    const SizedBox(height: 24),
                    
                    _buildSection(
                      icon: Icons.tips_and_updates,
                      color: const Color(0xFFFF6B9D),
                      title: 'Pro-Tips for Mastery',
                      items: [
                        '**Start Steady**: Begin at 300-400 WPM. Your brain will adapt to the rhythm in minutes, and you can ramp up to 800+ WPM effortlessly.',
                        '**Natural Pacing**: Notice the pauses at commas? That\'s our pacing engine giving your mind micro-moments to process complex ideas.',
                        '**Hinglish Magic**: For intuitive recall, toggle **Hinglish** mode in AI tools. It uses language patterns that often lead to better "survival" memory for Indian students.',
                        '**The "Exam Loop"**: PDF Load → Summary → High-Speed Read → Answer Q&A. Repeat once, and you own the subject.',
                      ],
                    ),
                  ],
                ),
              ),
              crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required Color color,
    required String title,
    String? content,
    List<String>? items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 10),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (content != null)
          _buildRichText(content),
        if (items != null)
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: _buildRichText(item)),
              ],
            ),
          )),
      ],
    );
  }

  Widget _buildRichText(String text) {
    final spans = <TextSpan>[];
    final boldPattern = RegExp(r'\*\*(.+?)\*\*');
    int lastEnd = 0;

    for (final match in boldPattern.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), height: 1.6, fontSize: 13),
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, height: 1.6, fontSize: 13),
      ));
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: TextStyle(color: Colors.white.withValues(alpha: 0.6), height: 1.6, fontSize: 13),
      ));
    }

    return RichText(
      text: TextSpan(children: spans, style: GoogleFonts.inter()),
    );
  }
}
