import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/arena_provider.dart';
import '../providers/reader_provider.dart';
import '../screens/arena_lobby_screen.dart';
import '../services/groq_service.dart';
import 'apple_widgets.dart';
import 'arena_rules_modal.dart';

class ArenaEntranceWidget extends StatelessWidget {
  const ArenaEntranceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final reader = context.watch<ReaderProvider>();
    final arena = context.watch<ArenaProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0071E3).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF0071E3).withValues(alpha: 0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0071E3).withValues(alpha: 0.05),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Row(
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
                      const SizedBox(width: 8),
                      _buildShimmerBadge(),
                    ],
                  ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _ArenaSmallCard(
                  title: 'Host Arena',
                  subtitle: 'Challenge your group using this document.',
                  icon: Icons.hub_rounded,
                  onPressed: reader.state.hasContent 
                    ? () => _showRules(context, () async {
                      final groq = context.read<ReaderProvider>().groq;
                      final id = await arena.hostCompetition(
                        reader.state.fileName ?? 'Pasted Content', 
                        reader.state.fullText,
                        groq
                      );
                       if (context.mounted) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => ArenaLobbyScreen(roomId: id)));
                      }
                    })
                    : null,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _ArenaSmallCard(
                  title: 'Join Arena',
                  subtitle: 'Enter a code to compete with others.',
                  icon: Icons.sports_esports_rounded,
                  onPressed: () => _showRules(context, () => _showJoinDialog(context)),
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF0071E3),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'NEW',
        style: GoogleFonts.outfit(
          fontSize: 8,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }

  void _showRules(BuildContext context, VoidCallback onAccept) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ArenaRulesModal(
        onAccept: () {
          Navigator.pop(context);
          onAccept();
        },
      ),
    );
  }

  void _showJoinDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _JoinArenaDialog(),
    );
  }
}

class _ArenaSmallCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isDark;

  const _ArenaSmallCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onPressed,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onPressed == null ? 0.5 : 1,
      child: AppleCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF0071E3), size: 28),
            const SizedBox(height: 16),
            Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54),
            ),
            const SizedBox(height: 24),
            AppleButton(
              label: onPressed == null ? 'Load Document First' : 'Enter',
              onPressed: onPressed,
              width: double.infinity,
              isPrimary: onPressed != null,
            ),
          ],
        ),
      ),
    );
  }
}

class _JoinArenaDialog extends StatefulWidget {
  const _JoinArenaDialog();

  @override
  State<_JoinArenaDialog> createState() => _JoinArenaDialogState();
}

class _JoinArenaDialogState extends State<_JoinArenaDialog> {
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final arena = context.read<ArenaProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: AppleCard(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Join Scholarly Arena', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 32),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'Scholarly Alias (e.g., Quantum Plato)'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _codeController,
                maxLength: 6,
                style: GoogleFonts.outfit(letterSpacing: 4, fontWeight: FontWeight.w800),
                decoration: const InputDecoration(
                  hintText: 'ROOM CODE',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 32),
              AppleButton(
                label: 'Join Competition',
                onPressed: () async {
                  await arena.joinCompetition(_codeController.text, _nameController.text);
                  if (context.mounted && arena.error == null) {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ArenaLobbyScreen(roomId: _codeController.text)));
                  }
                },
                width: double.infinity,
              ),
              if (arena.error != null) ...[
                const SizedBox(height: 16),
                Text(arena.error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
