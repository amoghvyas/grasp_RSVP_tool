import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/reader_provider.dart';

/// A tabbed toolbox panel providing AI-powered study tools.
///
/// Features two tabs:
/// - **Summary**: Generates a structured, exam-optimized summary
/// - **Viva & Exam Q&A**: Generates questions with model answers
///
/// Each tab has an English/Hinglish language toggle. Content is generated
/// on-demand via the Gemini API and displayed with styled formatting.
class StudyToolsPanel extends StatefulWidget {
  const StudyToolsPanel({super.key});

  @override
  State<StudyToolsPanel> createState() => _StudyToolsPanelState();
}

class _StudyToolsPanelState extends State<StudyToolsPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  /// Language mode per tab: false = English, true = Hinglish
  bool _summaryHinglish = false;
  bool _vivaHinglish = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReaderProvider>();
    final state = provider.state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Header with icon and title ─────────────────────────────
        _buildPanelHeader(),

        // ── Tab bar ───────────────────────────────────────────────
        _buildTabBar(),

        // ── Tab content ───────────────────────────────────────────
        SizedBox(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _buildTabContent(provider, state),
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  PANEL STRUCTURE
  // ════════════════════════════════════════════════════════════════════

  Widget _buildPanelHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF00D9FF)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Text(
            'AI Study Tools',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF00D9FF).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Gemini',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF00D9FF),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (_) => setState(() {}),
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
          ),
        ),
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withValues(alpha: 0.4),
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.summarize, size: 16),
                SizedBox(width: 6),
                Text('Summary'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.quiz, size: 16),
                SizedBox(width: 6),
                Text('Viva & Exam Q&A'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(ReaderProvider provider, state) {
    final tabIndex = _tabController.index;

    if (tabIndex == 0) {
      return _buildSummaryTab(provider, state);
    } else {
      return _buildVivaTab(provider, state);
    }
  }

  // ════════════════════════════════════════════════════════════════════
  //  SUMMARY TAB
  // ════════════════════════════════════════════════════════════════════

  Widget _buildSummaryTab(ReaderProvider provider, state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Language toggle + Generate button row
          _buildControlRow(
            isHinglish: _summaryHinglish,
            onLanguageChanged: (v) => setState(() => _summaryHinglish = v),
            onGenerate: () => provider.generateSummary(hinglish: _summaryHinglish),
            isLoading: state.isSummaryLoading,
            hasContent: state.summary != null,
          ),
          const SizedBox(height: 12),

          // Error display
          if (state.aiError != null && !state.isVivaLoading)
            _buildAiError(state.aiError!),

          // Loading state
          if (state.isSummaryLoading) _buildLoadingIndicator('Generating summary...'),

          // Summary content
          if (state.summary != null && !state.isSummaryLoading)
            _buildContentCard(state.summary!, 'Summary'),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  VIVA TAB
  // ════════════════════════════════════════════════════════════════════

  Widget _buildVivaTab(ReaderProvider provider, state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Language toggle + Generate button row
          _buildControlRow(
            isHinglish: _vivaHinglish,
            onLanguageChanged: (v) => setState(() => _vivaHinglish = v),
            onGenerate: () => provider.generateVivaQuestions(hinglish: _vivaHinglish),
            isLoading: state.isVivaLoading,
            hasContent: state.vivaQuestions != null,
          ),
          const SizedBox(height: 12),

          // Error display
          if (state.aiError != null && !state.isSummaryLoading)
            _buildAiError(state.aiError!),

          // Loading state
          if (state.isVivaLoading) _buildLoadingIndicator('Generating questions...'),

          // Viva content
          if (state.vivaQuestions != null && !state.isVivaLoading)
            _buildContentCard(state.vivaQuestions!, 'Q&A'),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  SHARED COMPONENTS
  // ════════════════════════════════════════════════════════════════════

  /// Builds the control row with language toggle and generate button.
  Widget _buildControlRow({
    required bool isHinglish,
    required ValueChanged<bool> onLanguageChanged,
    required VoidCallback onGenerate,
    required bool isLoading,
    required bool hasContent,
  }) {
    final provider = context.read<ReaderProvider>();

    return Row(
      children: [
        // Language toggle
        _buildLanguageToggle(isHinglish, onLanguageChanged),
        const Spacer(),

        // Generate / Regenerate button
        if (!isLoading)
          SizedBox(
            height: 36,
            child: ElevatedButton.icon(
              onPressed: provider.isAiReady ? onGenerate : null,
              icon: Icon(
                hasContent ? Icons.refresh : Icons.auto_awesome,
                size: 16,
              ),
              label: Text(
                hasContent ? 'Regenerate' : 'Generate',
                style: const TextStyle(fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ),
      ],
    );
  }

  /// Segmented language toggle: English / Hinglish
  Widget _buildLanguageToggle(bool isHinglish, ValueChanged<bool> onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(
            label: '🇬🇧 English',
            isSelected: !isHinglish,
            onTap: () => onChanged(false),
          ),
          _buildToggleButton(
            label: '🇮🇳 Hinglish',
            isSelected: isHinglish,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6C63FF).withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.3))
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }

  /// Loading indicator with animated dots.
  Widget _buildLoadingIndicator(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'This may take a few seconds...',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.25),
            ),
          ),
        ],
      ),
    );
  }

  /// Card displaying the AI-generated content with copy button.
  Widget _buildContentCard(String content, String type) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Copy & actions toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(
                  type == 'Summary' ? Icons.summarize : Icons.quiz,
                  size: 14,
                  color: const Color(0xFF6C63FF),
                ),
                const SizedBox(width: 6),
                Text(
                  type == 'Summary' ? 'Generated Summary' : 'Generated Q&A',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.4),
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                // Copy button
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: content));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$type copied to clipboard!'),
                        backgroundColor: const Color(0xFF6C63FF),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 16),
                  color: Colors.white.withValues(alpha: 0.4),
                  tooltip: 'Copy to clipboard',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ),

          // Content body with styled text
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 500),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildStyledContent(content),
            ),
          ),
        ],
      ),
    );
  }

  /// Renders markdown-like content with bold formatting.
  ///
  /// Handles:
  /// - **bold text** → rendered in white with bold weight
  /// - ### headings → rendered larger with the accent color
  /// - Regular text → rendered in muted white
  Widget _buildStyledContent(String content) {
    final lines = content.split('\n');
    final widgets = <Widget>[];

    for (final line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      // Heading detection (## or ###)
      if (line.startsWith('### ') || line.startsWith('## ')) {
        final headingText = line.replaceFirst(RegExp(r'^#{2,3}\s*'), '');
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 6),
            child: Text(
              headingText,
              style: GoogleFonts.inter(
                fontSize: line.startsWith('## ') ? 16 : 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF6C63FF),
              ),
            ),
          ),
        );
        continue;
      }

      // Regular text with **bold** support
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: _buildRichLine(line),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  /// Parses a line for **bold** markers and builds a RichText widget.
  Widget _buildRichLine(String line) {
    final spans = <TextSpan>[];
    final boldPattern = RegExp(r'\*\*(.+?)\*\*');
    int lastEnd = 0;

    for (final match in boldPattern.allMatches(line)) {
      // Text before the bold marker
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: line.substring(lastEnd, match.start),
          style: _normalTextStyle,
        ));
      }
      // Bold text
      spans.add(TextSpan(
        text: match.group(1),
        style: _boldTextStyle,
      ));
      lastEnd = match.end;
    }

    // Text after the last bold marker
    if (lastEnd < line.length) {
      spans.add(TextSpan(
        text: line.substring(lastEnd),
        style: _normalTextStyle,
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  /// Error display for AI failures.
  Widget _buildAiError(String error) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFF4757).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFF4757).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFFF4757), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFFFF4757),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  TEXT STYLES
  // ════════════════════════════════════════════════════════════════════

  TextStyle get _normalTextStyle => GoogleFonts.inter(
        fontSize: 13,
        height: 1.7,
        color: Colors.white.withValues(alpha: 0.7),
      );

  TextStyle get _boldTextStyle => GoogleFonts.inter(
        fontSize: 13,
        height: 1.7,
        fontWeight: FontWeight.w700,
        color: Colors.white.withValues(alpha: 0.95),
      );
}
