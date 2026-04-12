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
    final arena = context.watch<ArenaProvider>();
    final room = arena.room;

    // Safety: If room is not loaded yet, show a scholarly loader
    if (room == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text('Entering the Study Hall...', style: GoogleFonts.outfit(fontSize: 18, color: isDark ? Colors.white60 : Colors.black45)),
            ],
          ),
        ),
      );
    }

    final isHost = arena.myId == room.hostId;

    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      body: Stack(
        children: [
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(isDark, context, room, arena),
                  const SizedBox(height: 32),
                  
                  if (isMobile) ...[
                    _buildRoomInfo(isDark, context, arena, room, isHost),
                    const SizedBox(height: 32),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 500),
                      child: _buildPlayerList(isDark, room, arena.myId),
                    ),
                  ] else ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildRoomInfo(isDark, context, arena, room, isHost),
                        ),
                        const SizedBox(width: 40),
                        Expanded(
                          flex: 3,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 600),
                            child: _buildPlayerList(isDark, room, arena.myId),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark, BuildContext context, ArenaRoom room, ArenaProvider arena) {
    final isHost = arena.myId == room.hostId;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Row(
      children: [
        IconButton(
          onPressed: () {
            arena.leaveArena();
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SCHOLARLY ARENA',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: const Color(0xFF0071E3),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      room.documentTitle,
                      style: GoogleFonts.outfit(
                        fontSize: isMobile ? 24 : 32,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isHost)
                    IconButton(
                      onPressed: () => _showEditTitleDialog(context, arena, room.documentTitle),
                      icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF0071E3)),
                    ),
                ],
              ),
              if (room.questions.isEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.amber))),
                      const SizedBox(width: 12),
                      Text(
                        'AI is synthesizing your competition package...',
                        style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.amber[800]),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _showEditTitleDialog(BuildContext context, ArenaProvider arena, String currentTitle) {
    final controller = TextEditingController(text: currentTitle);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Topic', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter a scholarly topic name'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              arena.updateRoomTopic(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomInfo(bool isDark, BuildContext context, ArenaProvider arena, ArenaRoom room, bool isHost) {
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
                  room.id.toUpperCase(),
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
            isHost 
              ? 'As the host, you control the launch sequence. Wait for your study group to join the hall.'
              : 'Waiting for the host to trigger the competition. Prepare your focus.',
            style: TextStyle(fontSize: 14, height: 1.6, color: isDark ? Colors.white54 : Colors.black54),
          ),
          const Spacer(),
          AppleButton(
            label: 'Copy Invitation Link',
            onPressed: () {}, // Implementation placeholder
            width: double.infinity,
            isPrimary: false,
          ),
          const SizedBox(height: 12),
          AppleButton(
            label: isHost ? (room.questions.isEmpty ? 'Preparing Questions...' : 'Start Competition') : 'Waiting for Launch...',
            onPressed: isHost && room.players.length > 0 && room.questions.isNotEmpty
              ? () {
                  arena.startCompetition();
                  Navigator.pushReplacement(
                    context, 
                    MaterialPageRoute(builder: (_) => ArenaGameScreen(roomId: room.id))
                  );
                }
              : null,
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerList(bool isDark, ArenaRoom room, String myId) {
    final players = room.players;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'STUDY HALL (${players.length})',
              style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: isDark ? Colors.white24 : Colors.black26),
            ),
            const Icon(Icons.group_rounded, size: 16, color: Colors.blue),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: players.length,
            itemBuilder: (context, index) {
              final player = players[index];
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
                      child: Text(player.name[0].toUpperCase(), style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      player.id == myId ? '${player.name} (You)' : player.name,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    const Spacer(),
                    if (player.id == room.hostId)
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
