import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/arena_provider.dart';
import '../providers/reader_provider.dart';
import '../widgets/apple_widgets.dart';
import 'arena_lobby_screen.dart';

class ArenaInitScreen extends StatefulWidget {
  final String title;
  final String content;
  final String hostName;

  const ArenaInitScreen({super.key, required this.title, required this.content, required this.hostName});

  @override
  State<ArenaInitScreen> createState() => _ArenaInitScreenState();
}

class _ArenaInitScreenState extends State<ArenaInitScreen> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  String _status = 'Synthesizing knowledge...';
  String? _error;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    
    _startInitialization();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _startInitialization() async {
    final arena = context.read<ArenaProvider>();
    final groq = context.read<ReaderProvider>().groq;

    try {
      // Direct Optimistic Handshake with increased regional tolerance
      final id = await arena.hostCompetitionOptimistic(widget.title, widget.content, groq, widget.hostName).timeout(const Duration(seconds: 30));
      
      if (mounted) {
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (_) => ArenaLobbyScreen(roomId: id)),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isDark),
                const SizedBox(height: 60),
                Expanded(
                  child: _error != null ? _buildErrorState(isDark) : _buildSkeleton(isDark),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Constructing Arena',
          style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1),
        ),
        const SizedBox(height: 8),
        Text(
          _error != null ? 'Handshake Interrupted' : _status,
          style: TextStyle(color: isDark ? Colors.white60 : Colors.black45, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildSkeleton(bool isDark) {
    return Column(
      children: [
        _skeletonLine(width: 300, height: 24),
        const SizedBox(height: 48),
        _skeletonCard(height: 120, label: 'Room Metadata'),
        const SizedBox(height: 24),
        _skeletonCard(height: 200, label: 'AI Question Package'),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _skeletonCard(height: 100, label: 'Host Engine')),
            const SizedBox(width: 20),
            Expanded(child: _skeletonCard(height: 100, label: 'Regional Relay')),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: AppleCard(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
            const SizedBox(height: 24),
            Text('Scholarly Handshake Failed', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: isDark ? Colors.white60 : Colors.black54)),
            const SizedBox(height: 32),
            AppleButton(
              label: 'Retry Construction', 
              onPressed: () {
                setState(() => _error = null);
                _startInitialization();
              },
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _skeletonLine({required double width, required double height}) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(height / 2),
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                Colors.transparent,
              ],
              stops: const [0, 0.5, 1],
              begin: Alignment(-1 + _shimmerController.value * 3, 0),
              end: Alignment(1 + _shimmerController.value * 3, 0),
            ),
          ),
        );
      },
    );
  }

  Widget _skeletonCard({required double height, required String label}) {
    return AppleCard(
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          children: [
            _skeletonLine(width: double.infinity, height: height),
            Center(
              child: Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
