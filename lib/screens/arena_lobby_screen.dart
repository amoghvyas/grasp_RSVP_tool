import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/arena_model.dart';
import '../providers/arena_provider.dart';
import '../screens/arena_game_screen.dart';
import '../widgets/apple_widgets.dart';

class ArenaLobbyScreen extends StatelessWidget {
  final String roomId;
  const ArenaLobbyScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient Animation (Simplified for now)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark 
                  ? [const Color(0xFF1C1C1E), const Color(0xFF000000)]
                  : [const Color(0xFFF2F2F7), Colors.white],
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(isDark, context),
                  const SizedBox(height: 48),
                  
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Side: Room Info & Invite
                        Expanded(
                          flex: 2,
                          child: _buildRoomInfo(isDark),
                        ),
                        const SizedBox(width: 40),
                        
                        // Right Side: Player List (The "Study Hall")
                        Expanded(
                          flex: 3,
                          child: _buildPlayerList(isDark),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark, BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SCHOLARLY ARENA',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                color: const Color(0xFF0071E3),
              ),
            ),
            Text(
              'Prepare for Critical Competition',
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoomInfo(bool isDark) {
    return AppleCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ROOM ACCESS',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: isDark ? Colors.white24 : Colors.black26),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  roomId.toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Share this code with your study group or classmates. Competition starts when the host triggers the launch.',
            style: TextStyle(fontSize: 14, height: 1.6, color: isDark ? Colors.white54 : Colors.black54),
          ),
          const Spacer(),
          AppleButton(
            label: 'Copy Invitation Link',
            onPressed: () {},
            width: double.infinity,
            isPrimary: false,
          ),
          const SizedBox(height: 12),
          AppleButton(
            label: 'Start Competition',
            onPressed: () => Navigator.pushReplacement(
              context, 
              MaterialPageRoute(builder: (_) => ArenaGameScreen(roomId: roomId))
            ),
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerList(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'STUDY HALL (4)',
              style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: isDark ? Colors.white24 : Colors.black26),
            ),
            const Icon(Icons.group_rounded, size: 16, color: Colors.blue),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: 4,
            itemBuilder: (context, index) {
              final names = ['Quantum Plato', 'Cyber Curie', 'Digital Darwin', 'Neural Newton'];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.01),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.02)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                      child: Text(names[index][0], style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      names[index],
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    const Spacer(),
                    if (index == 0) // Example Host tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                        child: const Text('HOST', style: TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.w800)),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
