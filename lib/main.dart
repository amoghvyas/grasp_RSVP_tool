import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'providers/reader_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/input_screen.dart';
import 'screens/reader_screen.dart';

const _groqApiKey = String.fromEnvironment('GROQ_API_KEY', defaultValue: '');

void main() {
  runApp(const RSVPReaderApp());
}

class RSVPReaderApp extends StatelessWidget {
  const RSVPReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final provider = ReaderProvider();
            provider.initializeGroq(_groqApiKey);
            return provider;
          },
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) {
          return MaterialApp(
            title: 'Grasp — RSVP Speed Reader',
            debugShowCheckedModeBanner: false,
            themeMode: theme.themeMode,
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            home: const _AppShell(),
          );
        },
      ),
    );
  }

  ThemeData _buildLightTheme() {
    final base = ThemeData.light();
    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFFFBFBFD),
      colorScheme: ColorScheme.light(
        primary: const Color(0xFF0071E3), // Apple Blue
        secondary: const Color(0xFF1D1D1F),
        surface: Colors.white,
        onSurface: const Color(0xFF1D1D1F),
        error: const Color(0xFFFF3B30),
      ),
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme).apply(
        bodyColor: const Color(0xFF1D1D1F),
        displayColor: const Color(0xFF1D1D1F),
      ),
      dividerTheme: DividerThemeData(color: Colors.black.withValues(alpha: 0.05), thickness: 1),
      inputDecorationTheme: _inputTheme(isDark: false),
      appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0),
    );
  }

  ThemeData _buildDarkTheme() {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF000000),
      colorScheme: ColorScheme.dark(
        primary: const Color(0xFF00A2FF),
        secondary: const Color(0xFF86868B),
        surface: const Color(0xFF161617),
        onSurface: const Color(0xFFF5F5F7),
        error: const Color(0xFFFF453A),
      ),
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme).apply(
        bodyColor: const Color(0xFFF5F5F7),
        displayColor: const Color(0xFFF5F5F7),
      ),
      dividerTheme: DividerThemeData(color: Colors.white.withValues(alpha: 0.05), thickness: 1),
      inputDecorationTheme: _inputTheme(isDark: true),
      appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0),
    );
  }

  InputDecorationTheme _inputTheme({required bool isDark}) {
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1);
    final fillColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7);
    
    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      hintStyle: TextStyle(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.3), fontSize: 15),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: isDark ? const Color(0xFF00A2FF) : const Color(0xFF0071E3), width: 1.5),
      ),
    );
  }
}

class _AppShell extends StatelessWidget {
  const _AppShell();

  @override
  Widget build(BuildContext context) {
    final isReading = context.select<ReaderProvider, bool>((p) => p.state.isReading);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.easeOutExpo,
      switchOutCurve: Curves.easeInExpo,
      transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
      child: isReading ? const ReaderScreen(key: ValueKey('r')) : const InputScreen(key: ValueKey('i')),
    );
  }
}
