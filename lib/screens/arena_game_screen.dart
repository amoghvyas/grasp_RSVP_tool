import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/arena_model.dart';
import '../models/reader_state.dart';
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

  void _startQuestionLoop() {
    _timerController.forward(from: 0);
  }

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );
    _timerController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_currentQuestionIndex < 9) {
          setState(() {
            _currentQuestionIndex++;
          });
          _startQuestionLoop();
        } else {
          // Finish Game
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ArenaResultScreen(results: {
              'Quantum Plato': 840,
              'You': 720,
              'Digital Darwin': 690,
              'Neural Newton': 540,
            })),
          );
        }
      }
    });
    _startQuestionLoop();
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Minimalist Grid Background (The "Laboratory" feel)
          CustomPaint(
            painter: GridPainter(isDark: isDark),
            size: Size.infinite,
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
              child: Column(
                children: [
                   _buildTopBar(isDark),
                   const Spacer(flex: 1),
                   _buildQuestionEngine(isDark),
                   const Spacer(flex: 2),
                   _buildLiveLeaderboard(isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('QUESTION ${_currentQuestionIndex + 1} OF 10', 
              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: isDark ? Colors.white30 : Colors.black26)),
            const SizedBox(height: 4),
            Text('Neuro-Cognitive Patterns', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
        
        // Circular Timer Component
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: AnimatedBuilder(
                animation: _timerController,
                builder: (context, child) => CircularProgressIndicator(
                  value: 1.0 - _timerController.value,
                  strokeWidth: 6,
                  color: _timerController.value > 0.8 ? Colors.orange : const Color(0xFF0071E3),
                  backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _timerController,
              builder: (context, child) {
                final remaining = (15 * (1.0 - _timerController.value)).ceil();
                return Text(
                  '$remaining',
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800),
                );
              },
            ),
          ],
        ),

        // Live Rank Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF0071E3).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF0071E3).withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Text('RANK', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF0071E3))),
              Text('#2', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900, color: const Color(0xFF0071E3))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionEngine(bool isDark) {
    return Column(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Text(
            'In the context of the study, what is the primary neurotransmitter responsible for long-term potentiation during RSVP reading?',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w600, height: 1.3),
          ),
        ),
        const SizedBox(height: 60),
        
        // Multi-column Option Layout
        Wrap(
          spacing: 20,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: [
            _optionBtn('Glutamate', 'A', isDark),
            _optionBtn('Dopamine', 'B', isDark),
            _optionBtn('GABA', 'C', isDark),
            _optionBtn('Acetylcholine', 'D', isDark),
          ],
        ),
      ],
    );
  }

  Widget _optionBtn(String text, String key, bool isDark) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
              ),
              child: Center(child: Text(key, style: const TextStyle(fontWeight: FontWeight.w800))),
            ),
            const SizedBox(width: 20),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveLeaderboard(bool isDark) {
    return AppleCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('LIVE PULSE:', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, color: isDark ? Colors.white30 : Colors.black26)),
          const SizedBox(width: 20),
          _pulseItem('Quantum Plato', '840 pts', true, isDark),
          _vDivider(isDark),
          _pulseItem('You', '720 pts', false, isDark),
          _vDivider(isDark),
          _pulseItem('Digital Darwin', '690 pts', false, isDark),
        ],
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
