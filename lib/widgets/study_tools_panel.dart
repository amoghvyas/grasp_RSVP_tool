import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/reader_state.dart';
import '../providers/reader_provider.dart';

/// A premium, tabbed AI study toolbox panel.
///
/// Tabs:
///  - Summary (exam-optimized, supports English/Hinglish)
///  - Viva & Exam Q&A (with Anki CSV export)
///
/// Also features the AI Engine Switcher (Gemini ↔ OpenRouter Infinite Mode).
class StudyToolsPanel extends StatefulWidget {
  const StudyToolsPanel({super.key});

  @override
  State<StudyToolsPanel> createState() => _StudyToolsPanelState();
}

class _StudyToolsPanelState extends State<StudyToolsPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _summaryHinglish = false;
  bool _vivaHinglish = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ════════════════════════════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReaderProvider>();
    final state = provider.state;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.06),
            Colors.white.withValues(alpha: 0.02),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPanelHeader(state),
          _buildTabBar(),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: provider.isAiReady
                ? Column(children: [
                    _buildEngineSwitcher(provider, state),
                    _buildTabContent(provider, state),
                  ])
                : _buildApiKeySetup(provider),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  PANEL HEADER
  // ════════════════════════════════════════════════════════════════════

  Widget _buildPanelHeader(ReaderState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF00D9FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(11),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: const Icon(Icons.auto_awesome, size: 17, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Study Tools',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Powered by Gemini · Unlimited via OpenRouter',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.35),
                  ),
                ),
              ],
            ),
          ),
          // Provider badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: state.aiProvider == AiProvider.gemini
                  ? const Color(0xFF00D9FF).withValues(alpha: 0.1)
                  : const Color(0xFFFF6B9D).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: state.aiProvider == AiProvider.gemini
                    ? const Color(0xFF00D9FF).withValues(alpha: 0.3)
                    : const Color(0xFFFF6B9D).withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              state.aiProvider == AiProvider.gemini ? '⚡ Gemini' : '∞ Infinite',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: state.aiProvider == AiProvider.gemini
                    ? const Color(0xFF00D9FF)
                    : const Color(0xFFFF6B9D),
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  ENGINE SWITCHER
  // ════════════════════════════════════════════════════════════════════

  Widget _buildEngineSwitcher(ReaderProvider provider, ReaderState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            _buildEngineOption(
              label: 'Gemini',
              subtitle: 'Standard · Free tier',
              icon: Icons.auto_awesome,
              accentColor: const Color(0xFF00D9FF),
              isSelected: state.aiProvider == AiProvider.gemini,
              onTap: () => provider.setAiProvider(AiProvider.gemini),
            ),
            _buildEngineOption(
              label: 'OpenRouter',
              subtitle: 'Infinite · No limits',
              icon: Icons.all_inclusive,
              accentColor: const Color(0xFFFF6B9D),
              isSelected: state.aiProvider == AiProvider.openRouter,
              onTap: () => provider.setAiProvider(AiProvider.openRouter),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngineOption({
    required String label,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? accentColor.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: isSelected ? accentColor.withValues(alpha: 0.35) : Colors.transparent,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 13, color: isSelected ? accentColor : Colors.white24),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : Colors.white38,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: isSelected ? accentColor.withValues(alpha: 0.8) : Colors.white12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  TAB BAR
  // ════════════════════════════════════════════════════════════════════

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (_) => setState(() {}),
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF8B7FFF)],
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
              blurRadius: 8,
              spreadRadius: -2,
            ),
          ],
        ),
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withValues(alpha: 0.4),
        labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.summarize_rounded, size: 15),
                SizedBox(width: 6),
                Text('Summary'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.quiz_rounded, size: 15),
                SizedBox(width: 6),
                Text('Viva & Q&A'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  TAB CONTENT ROUTER
  // ════════════════════════════════════════════════════════════════════

  Widget _buildTabContent(ReaderProvider provider, ReaderState state) {
    return _tabController.index == 0
        ? _buildSummaryTab(provider, state)
        : _buildVivaTab(provider, state);
  }

  // ════════════════════════════════════════════════════════════════════
  //  SUMMARY TAB
  // ════════════════════════════════════════════════════════════════════

  Widget _buildSummaryTab(ReaderProvider provider, ReaderState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildControlRow(
            isHinglish: _summaryHinglish,
            onLanguageChanged: (v) => setState(() => _summaryHinglish = v),
            onGenerate: () => provider.generateSummary(hinglish: _summaryHinglish),
            isLoading: state.isSummaryLoading,
            hasContent: state.summary != null,
          ),
          const SizedBox(height: 12),
          if (state.aiError != null && !state.isVivaLoading) _buildAiError(state.aiError!),
          if (state.isSummaryLoading) _buildLoadingIndicator('Generating summary...', null, null),
          if (state.summary != null && !state.isSummaryLoading)
            _buildContentCard(state.summary!, 'Summary', provider, state),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  VIVA TAB
  // ════════════════════════════════════════════════════════════════════

  Widget _buildVivaTab(ReaderProvider provider, ReaderState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildControlRow(
            isHinglish: _vivaHinglish,
            onLanguageChanged: (v) => setState(() => _vivaHinglish = v),
            onGenerate: () => provider.generateVivaQuestions(hinglish: _vivaHinglish),
            isLoading: state.isVivaLoading,
            hasContent: state.vivaQuestions != null,
          ),
          const SizedBox(height: 12),
          if (state.aiError != null && !state.isSummaryLoading) _buildAiError(state.aiError!),
          if (state.isVivaLoading) _buildLoadingIndicator('Generating questions...', provider, state),
          if (state.vivaQuestions != null && !state.isVivaLoading)
            _buildContentCard(state.vivaQuestions!, 'Q&A', provider, state),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  SHARED COMPONENTS
  // ════════════════════════════════════════════════════════════════════

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
        _buildLanguageToggle(isHinglish, onLanguageChanged),
        const Spacer(),
        if (!isLoading)
          SizedBox(
            height: 36,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: provider.isAiReady
                    ? const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF8B7FFF)])
                    : null,
                color: provider.isAiReady ? null : Colors.white12,
                borderRadius: BorderRadius.circular(10),
                boxShadow: provider.isAiReady
                    ? [
                        BoxShadow(
                          color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                          blurRadius: 10,
                          spreadRadius: -2,
                        )
                      ]
                    : null,
              ),
              child: ElevatedButton.icon(
                onPressed: provider.isAiReady ? onGenerate : null,
                icon: Icon(hasContent ? Icons.refresh_rounded : Icons.auto_awesome, size: 15),
                label: Text(hasContent ? 'Regenerate' : 'Generate',
                    style: const TextStyle(fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ),
          ),
      ],
    );
  }

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
          _buildToggleChip(label: '🇬🇧 EN', isSelected: !isHinglish, onTap: () => onChanged(false)),
          _buildToggleChip(label: '🇮🇳 HI', isSelected: isHinglish, onTap: () => onChanged(true)),
        ],
      ),
    );
  }

  Widget _buildToggleChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6C63FF).withValues(alpha: 0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.4))
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(String message, ReaderProvider? provider, ReaderState? state) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
              backgroundColor: const Color(0xFF6C63FF).withValues(alpha: 0.1),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 4),
          Text(
            'This may take a few seconds...',
            style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.2)),
          ),
          // Show export button if viva is done
          if (provider != null && state != null && state.vivaQuestions != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => provider.exportToFlashcards(),
              icon: const Icon(Icons.download_rounded, size: 15),
              label: const Text('Save as Flashcards (Anki/CSV)'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF00D9FF),
                side: BorderSide(color: const Color(0xFF00D9FF).withValues(alpha: 0.3)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContentCard(
      String content, String type, ReaderProvider provider, ReaderState state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
            ),
            child: Row(
              children: [
                Icon(
                  type == 'Summary' ? Icons.summarize_rounded : Icons.quiz_rounded,
                  size: 13,
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
                // Export button (only in Q&A tab)
                if (type == 'Q&A')
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: _ActionChip(
                      icon: Icons.download_rounded,
                      label: 'Anki CSV',
                      color: const Color(0xFF00D9FF),
                      onTap: () => provider.exportToFlashcards(),
                    ),
                  ),
                // Copy button
                _ActionChip(
                  icon: Icons.copy_rounded,
                  label: 'Copy',
                  color: Colors.white54,
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: content));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$type copied!',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                        backgroundColor: const Color(0xFF6C63FF),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        duration: const Duration(seconds: 2),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Content
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildStyledContent(content),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyledContent(String content) {
    final lines = content.split('\n');
    final widgets = <Widget>[];

    for (final line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 6));
        continue;
      }
      if (line.startsWith('### ') || line.startsWith('## ')) {
        final headingText = line.replaceFirst(RegExp(r'^#{2,3}\s*'), '');
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 6),
            child: Text(
              headingText,
              style: GoogleFonts.inter(
                fontSize: line.startsWith('## ') ? 15 : 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF8B7FFF),
                letterSpacing: -0.2,
              ),
            ),
          ),
        );
        continue;
      }
      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: _buildRichLine(line),
      ));
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: widgets);
  }

  Widget _buildRichLine(String line) {
    final spans = <TextSpan>[];
    final boldPattern = RegExp(r'\*\*(.+?)\*\*');
    int lastEnd = 0;

    for (final match in boldPattern.allMatches(line)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: line.substring(lastEnd, match.start), style: _normalStyle));
      }
      spans.add(TextSpan(text: match.group(1), style: _boldStyle));
      lastEnd = match.end;
    }
    if (lastEnd < line.length) {
      spans.add(TextSpan(text: line.substring(lastEnd), style: _normalStyle));
    }

    return RichText(text: TextSpan(children: spans));
  }

  Widget _buildAiError(String error) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFF4757).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF4757).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFFF4757), size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              error,
              style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFFF4757)),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  API KEY SETUP
  // ════════════════════════════════════════════════════════════════════

  Widget _buildApiKeySetup(ReaderProvider provider) {
    final controller = TextEditingController();
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.vpn_key_rounded, color: Color(0xFF6C63FF), size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                'Connect Your AI Key',
                style: GoogleFonts.inter(
                    fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Paste your free Gemini API key to unlock Summary, Viva Q&A, and Active Recall. Stored only in your browser.',
            style: GoogleFonts.inter(
                fontSize: 12, color: Colors.white.withValues(alpha: 0.45), height: 1.6),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: controller,
            obscureText: true,
            style: const TextStyle(fontSize: 13, color: Colors.white),
            decoration: InputDecoration(
              hintText: 'AIza...',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: IconButton(
                icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF6C63FF)),
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    provider.updateApiKey(controller.text.trim());
                  }
                },
              ),
            ),
            onSubmitted: (val) {
              if (val.trim().isNotEmpty) provider.updateApiKey(val.trim());
            },
          ),
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: () => launchUrl(Uri.parse('https://aistudio.google.com/apikey')),
            icon: const Icon(Icons.open_in_new_rounded, size: 13),
            label: const Text('Get a free key at Google AI Studio →'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF00D9FF),
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  STYLES
  // ════════════════════════════════════════════════════════════════════

  TextStyle get _normalStyle => GoogleFonts.inter(
        fontSize: 13,
        height: 1.75,
        color: Colors.white.withValues(alpha: 0.65),
      );

  TextStyle get _boldStyle => GoogleFonts.inter(
        fontSize: 13,
        height: 1.75,
        fontWeight: FontWeight.w700,
        color: Colors.white.withValues(alpha: 0.95),
      );
}

// ── Small reusable action chip ──────────────────────────────────────────
class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
