import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/arena_model.dart';
import '../providers/arena_provider.dart';
import '../screens/arena_result_screen.dart';
import '../widgets/apple_widgets.dart';

class ArenaGameScreen extends StatefulWidget {
  final String roomId;
  const ArenaGameScreen({super.key, required this.roomId});

  @override
  State<ArenaGameScreen> createState() => _ArenaGameScreenState();
}

class _ArenaGameScreenState extends State<ArenaGameScreen> with TickerProviderStateMixin {
  late AnimationController _timerController;
  int _currentQuestionIndex = 0;
  int? _selectedIndex;
  bool _hasAnswered = false;
  final Duration _questionDuration = const Duration(seconds: 15);
  DateTime? _questionStartTime;

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(
      vsync: this,
      duration: _questionDuration,
    );

    _timerController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _handleQuestionTimeout();
      }
    });

    _startQuestion();
  }

  void _startQuestion() {
    setState(() {
      _selectedIndex = null;
      _hasAnswered = false;
      _questionStartTime = DateTime.now();
    });
    _timerController.forward(from: 0);
  }

  void _handleQuestionTimeout() {
    final arena = context.read<ArenaProvider>();
    final room = arena.room;
    if (room == null) return;

    if (_currentQuestionIndex < room.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
      _startQuestion();
    } else {
      _showResults();
    }
  }

  void _submitSelection(int index) {
    if (_hasAnswered) return;

    final arena = context.read<ArenaProvider>();
    final timeTaken = DateTime.now().difference(_questionStartTime!);

    setState(() {
      _selectedIndex = index;
      _hasAnswered = true;
    });

    arena.submitAnswer(_currentQuestionIndex, index, timeTaken);
  }

  void _showResults() {
    final arena = context.read<ArenaProvider>();
    final room = arena.room;
    if (room == null) return;

    // Build the real dynamic results map
    final results = {
      for (var p in room.players) p.name : p.score
    };

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ArenaResultScreen(results: results)),
    );
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  int? _lastSyncedIndex;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final arena = context.watch<ArenaProvider>();
    final room = arena.room;

    if (room == null || room.questions.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // High-Fidelity Sync: Reset state if the question index changes (prevents ghost highlights)
    if (_lastSyncedIndex != _currentQuestionIndex) {
      _lastSyncedIndex = _currentQuestionIndex;
      Future.delayed(Duration.zero, () {
        if (mounted) _startQuestion();
      });
    }

    final question = room.questions[_currentQuestionIndex];

    return Scaffold(
      body: Stack(
        children: [
          CustomPaint(
            painter: GridPainter(isDark: isDark),
            size: Size.infinite,
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    children: [
                      _buildTopBar(isDark, room),
                      const SizedBox(height: 32),
                      _buildQuestionEngine(isDark, question),
                      const SizedBox(height: 32),
                      _buildLiveLeaderboard(isDark, room, arena.myId),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(bool isDark, ArenaRoom room) {
    final sw = MediaQuery.of(context).size.width;
    final isMobile = sw < 600;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('QUESTION ${_currentQuestionIndex + 1} OF ${room.questions.length}', 
                style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: isDark ? Colors.white30 : Colors.black26)),
              const SizedBox(height: 4),
              Text(
                room.documentTitle, 
                style: GoogleFonts.outfit(fontSize: isMobile ? 14 : 18, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: AnimatedBuilder(
                animation: _timerController,
                builder: (context, child) => CircularProgressIndicator(
                  value: 1.0 - _timerController.value,
                  strokeWidth: 4,
                  color: _timerController.value > 0.8 ? Colors.orange : const Color(0xFF0071E3),
                  backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _timerController,
              builder: (context, child) {
                final remaining = (15 * (1.0 - _timerController.value)).ceil();
                return Text('$remaining', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800));
              },
            ),
          ],
        ),
        const SizedBox(width: 12),
        _buildRankBadge(room, isMobile),
      ],
    );
  }

  Widget _buildRankBadge(ArenaRoom room, bool isMobile) {
    final sorted = List<ArenaPlayer>.from(room.players)..sort((a, b) => b.score.compareTo(a.score));
    final myRank = sorted.indexWhere((p) => p.id == context.read<ArenaProvider>().myId) + 1;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0071E3).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0071E3).withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text('RANK', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF0071E3))),
          Text('#$myRank', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900, color: const Color(0xFF0071E3))),
        ],
      ),
    );
  }

  Widget _buildQuestionEngine(bool isDark, dynamic question) {
    return Column(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Text(
            question.question,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w600, height: 1.3),
          ),
        ),
        const SizedBox(height: 60),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: List.generate(question.options.length, (i) => 
            _optionBtn(question.options[i], String.fromCharCode(65 + i), i, isDark, question.correctIndex)
          ),
        ),
      ],
    );
  }

  Widget _optionBtn(String text, String label, int index, bool isDark, int correctIndex) {
    final isSelected = _selectedIndex == index;
    final showResult = _hasAnswered;
    final isCorrect = index == correctIndex;

    Color borderColor = isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05);
    Color bgColor = isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02);
    
    if (showResult) {
      if (isCorrect) {
        borderColor = Colors.greenAccent.withValues(alpha: 0.5);
        bgColor = Colors.green.withValues(alpha: 0.1);
      } else if (isSelected) {
        borderColor = Colors.redAccent.withValues(alpha: 0.5);
        bgColor = Colors.red.withValues(alpha: 0.1);
      }
    } else if (isSelected) {
      borderColor = const Color(0xFF0071E3);
    }

    return GestureDetector(
      onTap: () => _submitSelection(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFF0071E3) : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
              ),
              child: Center(child: Text(label, style: TextStyle(fontWeight: FontWeight.w800, color: isSelected ? Colors.white : null))),
            ),
            const SizedBox(width: 20),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
            if (showResult && isCorrect) const Icon(Icons.check_circle_rounded, color: Colors.greenAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveLeaderboard(bool isDark, ArenaRoom room, String myId) {
    final topPlayers = List<ArenaPlayer>.from(room.players)
      ..sort((a, b) => b.score.compareTo(a.score));
    
    return AppleCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('LIVE PULSE:', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: isDark ? Colors.white30 : Colors.black26)),
            const SizedBox(width: 16),
            for (int i = 0; i < topPlayers.take(3).length; i++) ...[
              if (i > 0) _vDivider(isDark),
              _pulseItem(topPlayers[i].name, '${topPlayers[i].score} pts', i == 0, isDark),
            ],
          ],
        ),
      ),
    );
  }

  Widget _pulseItem(String name, String pts, bool isLead, bool isDark) {
    return Row(
      children: [
        if (isLead) const Icon(Icons.flash_on_rounded, size: 14, color: Colors.orange),
        const SizedBox(width: 6),
        Text(name, style: TextStyle(fontSize: 13, fontWeight: isLead ? FontWeight.w700 : FontWeight.w400)),
        const SizedBox(width: 8),
        Text(pts, style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.black38)),
        const SizedBox(width: 20),
      ],
    );
  }

  Widget _vDivider(bool isDark) => Container(width: 1, height: 20, color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05), margin: const EdgeInsets.only(right: 20));
}

class GridPainter extends CustomPainter {
  final bool isDark;
  GridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.02)
      ..strokeWidth = 1;
      
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
