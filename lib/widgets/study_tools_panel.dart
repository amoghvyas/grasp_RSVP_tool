import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/reader_state.dart';
import '../providers/reader_provider.dart';
import 'apple_widgets.dart';

class StudyToolsPanel extends StatefulWidget {
  const StudyToolsPanel({super.key});

  @override
  State<StudyToolsPanel> createState() => _StudyToolsPanelState();
}

class _StudyToolsPanelState extends State<StudyToolsPanel> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _summaryHinglish = false;
  bool _vivaHinglish = false;
  double _quizCount = 5;
  String _quizDifficulty = 'Moderate';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppleCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(isDark),
          const Divider(height: 1),
          _buildTabs(isDark),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(24),
            child: _buildBody(provider, state, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(Icons.auto_awesome_rounded, size: 20, color: isDark ? const Color(0xFF00A2FF) : const Color(0xFF0071E3)),
          const SizedBox(width: 12),
          Text(
            'SCHOLARLY AI ENGINE',
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(bool isDark) {
    return TabBar(
      controller: _tabController,
      onTap: (_) => setState(() {}),
      indicatorColor: isDark ? const Color(0xFF00A2FF) : const Color(0xFF0071E3),
      indicatorWeight: 3,
      labelColor: isDark ? Colors.white : Colors.black,
      unselectedLabelColor: isDark ? Colors.white30 : Colors.black26,
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      tabs: const [
        Tab(text: 'Summary'),
        Tab(text: 'Viva'),
        Tab(text: 'MCQ'),
        Tab(text: 'Recap'),
      ],
    );
  }

  Widget _buildBody(ReaderProvider provider, ReaderState state, bool isDark) {
    switch (_tabController.index) {
      case 2: return _buildQuizView(provider, state, isDark);
      case 3: return _buildRecapSettingsView(provider, state, isDark);
      default: return const SizedBox();
    }
  }

  Widget _buildSummaryView(ReaderProvider provider, ReaderState state, bool isDark) {
    return Column(
      children: [
        _buildActionHeader(
          'Summarize content for deep mastery.',
          _summaryHinglish,
          (v) => setState(() => _summaryHinglish = v),
          isDark,
        ),
        const SizedBox(height: 20),
        AppleButton(
          label: 'Generate Academic Summary',
          isLoading: state.isSummaryLoading,
          onPressed: () => provider.generateSummary(hinglish: _summaryHinglish),
          width: double.infinity,
        ),
        if (state.summary != null) ...[
          const SizedBox(height: 24),
          _buildContentCard(state.summary!, isDark),
        ],
      ],
    );
  }

  Widget _buildVivaView(ReaderProvider provider, ReaderState state, bool isDark) {
    return Column(
      children: [
        _buildActionHeader(
          'Prepare for oral exams and deeper intuition.',
          _vivaHinglish,
          (v) => setState(() => _vivaHinglish = v),
          isDark,
        ),
        const SizedBox(height: 20),
        AppleButton(
          label: 'Generate Viva Practice',
          isLoading: state.isVivaLoading,
          onPressed: () => provider.generateVivaQuestions(hinglish: _vivaHinglish),
          width: double.infinity,
        ),
        if (state.vivaQuestions != null) ...[
          const SizedBox(height: 24),
          _buildContentCard(state.vivaQuestions!, isDark),
        ],
      ],
    );
  }

  Widget _buildRecapSettingsView(ReaderProvider provider, ReaderState state, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CALIBRATE RECALL INTENSITY',
          style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: isDark ? Colors.white30 : Colors.black26),
        ),
        const SizedBox(height: 20),
        
        // Intensity Selector
        _buildRecapOption(
          label: 'Mastery Checkpoints',
          currentValue: state.recallCount.toString(),
          options: ['3', '5', '10'],
          onSelected: (val) => provider.updateRecallSettings(count: int.parse(val)),
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _buildRecapOption(
          label: 'Scholarly Depth',
          currentValue: state.recallDifficulty,
          options: ['Recall', 'Intermediate', 'Analysis'],
          onSelected: (val) => provider.updateRecallSettings(difficulty: val),
          isDark: isDark,
        ),
        
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (isDark ? const Color(0xFF00A2FF) : const Color(0xFF0071E3)).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: (isDark ? const Color(0xFF00A2FF) : const Color(0xFF0071E3)).withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Icon(Icons.tips_and_updates_rounded, size: 16, color: isDark ? const Color(0xFF00A2FF) : const Color(0xFF0071E3)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Grasp will now generate ${state.recallCount} checkpoints with ${state.recallDifficulty} depth across your text.',
                  style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecapOption({
    required String label,
    required String currentValue,
    required List<String> options,
    required Function(String) onSelected,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Row(
          children: options.map((opt) {
            final isSelected = currentValue == opt;
            return Expanded(
              child: GestureDetector(
                onTap: () => onSelected(opt),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected 
                      ? (isDark ? const Color(0xFF00A2FF) : const Color(0xFF0071E3)) 
                      : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.02)),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isSelected ? Colors.transparent : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.03))),
                  ),
                  child: Center(
                    child: Text(
                      opt,
                      style: TextStyle(
                        fontSize: 12, 
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : (isDark ? Colors.white54 : Colors.black54),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionHeader(String subtitle, bool val, Function(bool) onChanged, bool isDark) {
    return Row(
      children: [
        Expanded(child: Text(subtitle, style: TextStyle(fontSize: 13, color: isDark ? Colors.white38 : Colors.black38))),
        const SizedBox(width: 8),
        Text('Hinglish', style: TextStyle(fontSize: 11, color: isDark ? Colors.white24 : Colors.black26)),
        Switch.adaptive(value: val, onChanged: onChanged),
      ],
    );
  }

  Widget _buildDifficultyDropdown(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: _quizDifficulty,
        underline: const SizedBox(),
        items: ['Easy', 'Moderate', 'Hard'].map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 12)))).toList(),
        onChanged: (v) => setState(() => _quizDifficulty = v!),
      ),
    );
  }

  Widget _buildContentCard(String content, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: SelectableText(
        content,
        style: TextStyle(height: 1.6, fontSize: 14, color: isDark ? Colors.white70 : Colors.black87),
      ),
    );
  }

  Widget _buildQuizCard(int idx, InteractiveQuiz quiz, ReaderProvider provider, bool isDark) {
    final hasAnswered = quiz.selectedIndex != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Q${idx + 1}. ${quiz.question}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 16),
          ...quiz.options.asMap().entries.map((o) {
            final isSelected = quiz.selectedIndex == o.key;
            final isCorrect = quiz.correctIndex == o.key;
            Color color = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03);
            if (hasAnswered) {
              if (isCorrect) color = Colors.green.withValues(alpha: 0.1);
              else if (isSelected) color = Colors.red.withValues(alpha: 0.1);
            }
            return GestureDetector(
              onTap: () => hasAnswered ? null : provider.answerInteractiveQuiz(idx, o.key),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? (isDark ? Colors.white24 : Colors.black26) : Colors.transparent)),
                child: Row(
                  children: [
                    Expanded(child: Text(o.value, style: const TextStyle(fontSize: 13))),
                    if (hasAnswered && isCorrect) const Icon(Icons.check_circle, size: 16, color: Colors.green),
                  ],
                ),
              ),
            );
          }),
          if (hasAnswered) ...[
            const SizedBox(height: 8),
            Text('💡 ${quiz.explanation}', style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38, height: 1.4)),
          ],
        ],
      ),
    );
  }
}
