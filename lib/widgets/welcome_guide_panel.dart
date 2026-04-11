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
      margin: const EdgeInsets.only(bottom: 24),
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
                                ? 'Expert guide to academic mastery'
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
                      title: 'The Focus-Flow Advantage',
                      content: 'Grasp uses **Focus-Flow Reading** to eliminate distractions and "sub-vocalization" — that internal voice which limits your speed. By delivering material directly into your visual focus, you process information up to **5x faster** while maintaining deep engagement with the text.',
                    ),
                    const SizedBox(height: 24),
                    
                    _buildSection(
                      icon: Icons.psychology,
                      color: const Color(0xFF00D9FF),
                      title: 'Evidence-Based Retention',
                      content: 'Speed is empty without mastery. Grasp integrates **Gemini AI** to instantly generate structured summaries and viva-style Q&A. Use the **Summary Engine** to map concepts and **Active Recall** to convert short-term info into permanent exam-ready knowledge.',
                    ),
                    const SizedBox(height: 24),
                    
                    _buildSection(
                      icon: Icons.tips_and_updates,
                      color: const Color(0xFFFF6B9D),
                      title: 'Strategic Mastery Loop',
                      items: [
                        '**Natural Acceleration**: Start at 300 WPM. Your brain will synchronize with the flow in seconds, allowing you to hit 700+ WPM with ease.',
                        '**Passive Listening**: Feeling fatigued? Use the **Listen to Material** button to hear the entire document read aloud at a natural conversational speed.',
                        '**The Exam Protocol**: PDF Upload → AI Summary → Rapid Focus Read → Viva Q&A. Complete this loop twice to own any complex topic.',
                        '**Contextual Pacing**: Our engine automatically pauses at commas and hard stops, giving your mind micro-breaks to digest logic-heavy sentences.',
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
