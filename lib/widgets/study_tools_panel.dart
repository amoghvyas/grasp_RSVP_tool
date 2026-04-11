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
    _tabController = TabController(length: 3, vsync: this);
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
        Tab(text: 'Viva Q&A'),
        Tab(text: 'MCQ Quiz'),
      ],
    );
  }

  Widget _buildBody(ReaderProvider provider, ReaderState state, bool isDark) {
    switch (_tabController.index) {
      case 0: return _buildSummaryView(provider, state, isDark);
      case 1: return _buildVivaView(provider, state, isDark);
      case 2: return _buildQuizView(provider, state, isDark);
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

  Widget _buildQuizView(ReaderProvider provider, ReaderState state, bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Questions: ${_quizCount.toInt()}', style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38)),
                  Slider(
                    value: _quizCount,
                    min: 3,
                    max: 20,
                    divisions: 17,
                    onChanged: (v) => setState(() => _quizCount = v),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            _buildDifficultyDropdown(isDark),
          ],
        ),
        const SizedBox(height: 20),
        AppleButton(
          label: 'Start MCQ Quiz',
          isLoading: state.isQuizLoading,
          onPressed: () => provider.generateInteractiveQuiz(_quizCount.toInt(), _quizDifficulty),
          width: double.infinity,
        ),
        if (state.quizzes != null) ...[
          const SizedBox(height: 24),
          ...state.quizzes!.asMap().entries.map((e) => _buildQuizCard(e.key, e.value, provider, isDark)),
        ],
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
