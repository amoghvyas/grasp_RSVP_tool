import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'providers/reader_provider.dart';
import 'screens/input_screen.dart';
import 'screens/reader_screen.dart';

/// Groq API key injected at build time via:
///   flutter run --dart-define=GROQ_API_KEY=your_key_here
const _groqApiKey = String.fromEnvironment(
  'GROQ_API_KEY',
  defaultValue: '',
);

void main() {
  runApp(const RSVPReaderApp());
}

class RSVPReaderApp extends StatelessWidget {
  const RSVPReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = ReaderProvider();
        // Initialize AI services with Groq Key
        provider.initializeGroq(_groqApiKey);
        return provider;
      },
      child: MaterialApp(
        title: 'Grasp — RSVP Speed Reader',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        home: const _AppShell(),
      ),
    );
  }

  /// Builds the dark, premium theme used throughout the app.
  ThemeData _buildTheme() {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF05050A),
      colorScheme: ColorScheme.dark(
        primary: const Color(0xFF6C63FF),
        secondary: const Color(0xFF00D9FF),
        surface: const Color(0xFF12121A),
        error: const Color(0xFFFF4757),
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: const Color(0xFF6C63FF),
        inactiveTrackColor: Colors.white12,
        thumbColor: const Color(0xFF6C63FF),
        overlayColor: const Color(0xFF6C63FF).withValues(alpha: 0.2),
        valueIndicatorColor: const Color(0xFF6C63FF),
        valueIndicatorTextStyle: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A1A2E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
        ),
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
        contentPadding: const EdgeInsets.all(20),
      ),
    );
  }
}

/// Root widget that switches between InputScreen and ReaderScreen
/// based on the current reading state.
class _AppShell extends StatelessWidget {
  const _AppShell();

  @override
  Widget build(BuildContext context) {
    final isReading = context.select<ReaderProvider, bool>(
      (p) => p.state.isReading,
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: isReading
          ? const ReaderScreen(key: ValueKey('reader'))
          : const InputScreen(key: ValueKey('input')),
    );
  }
}
