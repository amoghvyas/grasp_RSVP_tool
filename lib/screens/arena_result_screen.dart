import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/apple_widgets.dart';

class ArenaResultScreen extends StatelessWidget {
  final Map<String, int> results; // Name: Points
  const ArenaResultScreen({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sortedResults = results.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    
    return Scaffold(
      body: Stack(
        children: [
          // Background "Glory" Glow
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0071E3).withValues(alpha: 0.05),
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  _buildHeader(isDark),
                  const SizedBox(height: 60),
                  
                  // The Academic Podium
                  _buildPodium(sortedResults, isDark),
                  const SizedBox(height: 60),
                  
                  // The Scholarly Certificate (The "Shareable" Moment)
                  _buildCertificateOfMastery(sortedResults.first.key, sortedResults.first.value, isDark),
                  
                  const SizedBox(height: 60),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 600;
                      return Column(
                        children: [
                          AppleButton(
                            label: 'Download Certificate',
                            onPressed: () {},
                            icon: Icons.download_rounded,
                            width: isMobile ? double.infinity : null,
                          ),
                          const SizedBox(height: 16),
                          AppleButton(
                            label: 'Return to Home',
                            onPressed: () => Navigator.pop(context),
                            isPrimary: false,
                            width: isMobile ? double.infinity : null,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      children: [
        Text(
          'COMPETITION CONCLUDED',
          style: GoogleFonts.outfit(
            fontSize: 12, 
            fontWeight: FontWeight.w800, 
            letterSpacing: 3,
            color: const Color(0xFF0071E3),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Mastery Acknowledged.',
          style: GoogleFonts.outfit(fontSize: 40, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildPodium(List<MapEntry<String, int>> results, bool isDark) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 800),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (results.length > 1) _podiumBar(results[1].key, results[1].value, 120, '#2', isDark),
          _podiumBar(results[0].key, results[0].value, 200, '#1', isDark, isWinner: true),
          if (results.length > 2) _podiumBar(results[2].key, results[2].value, 80, '#3', isDark),
        ],
      ),
    );
  }

  Widget _podiumBar(String name, int pts, double height, String rank, bool isDark, {bool isWinner = false}) {
    return Expanded(
      child: Column(
        children: [
          Text(name, style: TextStyle(fontWeight: isWinner ? FontWeight.w800 : FontWeight.w600, fontSize: isWinner ? 18 : 14)),
          const SizedBox(height: 8),
          Text('$pts pts', style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 12)),
          const SizedBox(height: 20),
          Container(
            height: height,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              gradient: isWinner 
                ? const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0071E3), Color(0xFF00A2FF)])
                : LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05), isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.01)]),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Center(
              child: Text(
                rank,
                style: GoogleFonts.outfit(
                  fontSize: 24, 
                  fontWeight: FontWeight.w900, 
                  color: isWinner ? Colors.white : (isDark ? Colors.white24 : Colors.black12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateOfMastery(String name, int score, bool isDark) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C20) : Colors.white,
          borderRadius: BorderRadius.circular(4), // Slab look
          border: Border.all(color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05), width: 12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          children: [
            const Icon(Icons.school_rounded, color: Color(0xFF0071E3), size: 48),
            const SizedBox(height: 32),
            Text(
              'CERTIFICATE OF SCHOLARLY MASTERY',
              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 4),
            ),
            const SizedBox(height: 24),
            const Divider(thickness: 1, indent: 100, endIndent: 100),
            const SizedBox(height: 32),
            Text(
              'This acknowledges that',
              style: TextStyle(fontStyle: FontStyle.italic, color: isDark ? Colors.white54 : Colors.black54),
            ),
            const SizedBox(height: 8),
            Text(
              name.toUpperCase(),
              style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'has achieved a score of $score in the Scholarly Arena',
              style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('VALIDATION ID: ${_generateValidationId()}', style: GoogleFonts.outfit(fontSize: 8, color: const Color(0xFF0071E3), fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('Grasp Scholarly v1.0', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16)),
                    Text('Groq-Accelerated LPU Performance', style: TextStyle(fontSize: 9, color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.6))),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF0071E3), width: 1),
                  ),
                  child: const Icon(Icons.verified_outlined, color: Color(0xFF0071E3)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _generateValidationId() {
    return 'SCH-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
  }
}
