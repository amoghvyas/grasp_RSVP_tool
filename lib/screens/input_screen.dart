import 'dart:async';
import 'package:web/web.dart' as web;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/reader_provider.dart';
import '../widgets/animated_background.dart';
import '../widgets/dropzone_widget.dart';
import '../widgets/study_tools_panel.dart';
import '../widgets/welcome_guide_panel.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _textController = TextEditingController();
  final _urlController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;
  bool _isInstallable = false;
  Timer? _installTimer;
  int _inputTab = 0; // 0=Paste, 1=File, 2=URL

  @override
  void initState() {
    super.initState();
    _installTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      final isInstallable = (web.window as dynamic).isPWAInstallable == true;
      if (isInstallable != _isInstallable) {
        setState(() => _isInstallable = isInstallable);
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _urlController.dispose();
    _installTimer?.cancel();
    super.dispose();
  }

  void _triggerInstall() {
    if (_isInstallable) {
      (web.window as dynamic).promptInstall();
    } else {
      _showInstallInstructions();
    }
  }

  void _showInstallInstructions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF12121E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 28),
            ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                colors: [Color(0xFF8B7FFF), Color(0xFF00D9FF)],
              ).createShader(b),
              child: Text(
                'Install Grasp',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Add to your home screen for the full app experience',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.4),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            _buildInstallStep('1', Icons.ios_share_rounded, 'Tap the Share button',
                'Look for the share icon in your browser toolbar'),
            _buildInstallStep('2', Icons.add_box_rounded, 'Add to Home Screen',
                'Select "Add to Home Screen" from the menu'),
            _buildInstallStep('3', Icons.rocket_launch_rounded, 'Launch Grasp',
                'It will appear as a native app on your device!'),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text('Got it!',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstallStep(String step, IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.25)),
            ),
            child: Center(
              child: Icon(icon, size: 16, color: const Color(0xFF6C63FF)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReaderProvider>();
    final state = provider.state;
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: sw < 600 ? 16 : 24,
              vertical: 56,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: sw > 800 ? 660 : double.infinity,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Hero ─────────────────────────────────────────
                  FadeSlideIn(child: _buildHero()),
                  const SizedBox(height: 40),

                  // ── Feature pills ────────────────────────────────
                  FadeSlideIn(delayMs: 40, child: _buildFeaturePills()),
                  const SizedBox(height: 32),

                  // ── Welcome guide ───────────────────────────────
                  FadeSlideIn(delayMs: 60, child: const WelcomeGuidePanel()),
                  const SizedBox(height: 20),

                  // ── Tabbed input (Paste / File / URL) ───────────
                  FadeSlideIn(
                    delayMs: 100,
                    child: GlassCard(
                      padding: EdgeInsets.zero,
                      child: _buildTabbedInput(provider),
                    ),
                  ),

                  // ── Install ─────────────────────────────────────
                  const SizedBox(height: 16),
                  FadeSlideIn(delayMs: 120, child: _buildInstallButton()),

                  // ── Error ───────────────────────────────────────
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    FadeSlideIn(child: _buildError()),
                  ],

                  // ── File badge ──────────────────────────────────
                  if (state.fileName != null) ...[
                    const SizedBox(height: 16),
                    FadeSlideIn(child: _buildFileBadge(state.fileName!)),
                  ],

                  // ── Content loaded section ──────────────────────
                  if (state.hasContent) ...[
                    const SizedBox(height: 28),
                    FadeSlideIn(
                      delayMs: 80,
                      child: GlassCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 20),
                        accentBorderColor:
                            const Color(0xFF6C63FF).withValues(alpha: 0.25),
                        child: _buildContentStats(state),
                      ),
                    ),

                    // AI Tools
                    if (provider.isAiReady) ...[
                      const SizedBox(height: 16),
                      FadeSlideIn(
                        delayMs: 160,
                        child: const StudyToolsPanel(),
                      ),
                    ],

                    const SizedBox(height: 28),
                    FadeSlideIn(
                      delayMs: 280,
                      child: _buildStartButton(provider),
                    ),
                  ],

                  const SizedBox(height: 60),
                  _buildFooter(),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  UI BUILDERS
  // ════════════════════════════════════════════════════════════════════

  Widget _buildHero() {
    return Column(
      children: [
        // Pulsing glow dot
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.4, end: 1.0),
          duration: const Duration(milliseconds: 1800),
          builder: (_, v, __) => Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withValues(alpha: v * 0.8),
                  blurRadius: 28,
                  spreadRadius: 4,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),

        // Logo with multi-color gradient
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF8B7FFF), Color(0xFF00D9FF), Color(0xFFFF6B9D)],
            stops: [0.0, 0.5, 1.0],
          ).createShader(bounds),
          child: Text(
            'Grasp',
            style: GoogleFonts.inter(
              fontSize: 64,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -3,
              height: 1.0,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),

        Text(
          'ACADEMIC MASTERY ENGINE',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Colors.white.withValues(alpha: 0.3),
            letterSpacing: 4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),

        Text(
          'Read faster. Absorb deeper. Ace every exam.',
          style: GoogleFonts.inter(
            fontSize: 17,
            color: Colors.white.withValues(alpha: 0.5),
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeaturePills() {
    const features = [
      (Icons.bolt_rounded, '3-5× Speed', Color(0xFF6C63FF)),
      (Icons.auto_awesome_rounded, 'AI Summaries', Color(0xFF00D9FF)),
      (Icons.quiz_rounded, 'Viva Q&A', Color(0xFFFF6B9D)),
      (Icons.all_inclusive_rounded, 'Unlimited Mode', Color(0xFF8B7FFF)),
      (Icons.psychology_rounded, 'Active Recall', Color(0xFFFFB830)),
    ];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: features.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (icon, label, color) = features[i];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 13, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabbedInput(ReaderProvider provider) {
    return Column(
      children: [
        // Tab Switcher
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.02),
            border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
          ),
          child: Row(
            children: [
              _buildInputTab(0, 'Paste Text', Icons.edit_note_rounded, const Color(0xFF8B7FFF)),
              _buildInputTab(1, 'Upload File', Icons.upload_file_rounded, const Color(0xFF00D9FF)),
              _buildInputTab(2, 'Import URL', Icons.public_rounded, const Color(0xFFFF6B9D)),
            ],
          ),
        ),
        
        // Tab Body
        Padding(
          padding: const EdgeInsets.all(24),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _inputTab == 0
                ? _buildTextInput(provider)
                : _inputTab == 1
                    ? _buildFileUpload(provider)
                    : _buildUrlImport(provider),
          ),
        ),
      ],
    );
  }

  Widget _buildInputTab(int index, String label, IconData icon, Color color) {
    final isSelected = _inputTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _inputTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color.withValues(alpha: 0.3) : Colors.transparent,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: isSelected ? color : Colors.white.withValues(alpha: 0.3)),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(IconData icon, String label, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 15, color: color),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildTextInput(ReaderProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(Icons.edit_note_rounded, 'Paste your text', const Color(0xFF8B7FFF)),
        const SizedBox(height: 16),
        TextField(
          controller: _textController,
          maxLines: 8,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.85),
            height: 1.7,
          ),
          decoration: InputDecoration(
            hintText: 'Paste any text here — lecture notes, articles, chapters...',
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.04),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
            ),
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.18)),
            contentPadding: const EdgeInsets.all(18),
          ),
          onChanged: (value) {
            if (value.trim().isNotEmpty) {
              provider.loadText(value);
              setState(() => _errorMessage = null);
            }
          },
        ),
      ],
    );
  }

  Widget _buildFileUpload(ReaderProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(Icons.upload_file_rounded, 'Upload a file (PDF, DOCX, TXT)',
            const Color(0xFF00D9FF)),
        const SizedBox(height: 16),
        SizedBox(
          height: 150,
          child: DropzoneWidget(
            onFileDropped: (bytes, fileName) => _handleFile(provider, bytes, fileName),
            onError: (error) => setState(() => _errorMessage = error),
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: _HoverScale(
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : () => _pickFile(provider),
              icon: _isLoading
                  ? const SizedBox(
                      width: 13,
                      height: 13,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.folder_open_rounded, size: 15),
              label: Text(
                _isLoading ? 'Processing...' : 'Browse files',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white.withValues(alpha: 0.65),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUrlImport(ReaderProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(
            Icons.public_rounded, 'Read from URL', const Color(0xFFFF6B9D)),
        const SizedBox(height: 16),
        TextField(
          controller: _urlController,
          style: const TextStyle(fontSize: 13, color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Paste any article, Wikipedia link, or research URL...',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
            suffixIcon: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.bolt_rounded, color: Color(0xFFFF6B9D)),
                    onPressed: () => _handleUrlFetch(provider),
                  ),
          ),
          onSubmitted: (_) => _handleUrlFetch(provider),
        ),
        const SizedBox(height: 8),
        Text(
          'Powers through Wikipedia, blogs, Medium, and research articles.',
          style: GoogleFonts.inter(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.25),
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFF4757).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFF4757).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFFF4757), size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(_errorMessage!,
                style: GoogleFonts.inter(color: const Color(0xFFFF4757), fontSize: 12)),
          ),
          IconButton(
            onPressed: () => setState(() => _errorMessage = null),
            icon: const Icon(Icons.close_rounded, size: 14),
            color: Colors.white24,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildFileBadge(String fileName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF6C63FF).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.description_rounded, size: 14, color: Color(0xFF6C63FF)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              fileName,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6C63FF),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentStats(state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStat(Icons.format_list_numbered_rounded, '${state.totalWords}', 'words'),
        _buildStatDivider(),
        _buildStat(Icons.timer_rounded, state.estimatedTimeFormatted, 'est. time'),
        _buildStatDivider(),
        _buildStat(Icons.speed_rounded, '${state.wpm}', 'WPM'),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(width: 1, height: 36, color: Colors.white.withValues(alpha: 0.06));
  }

  Widget _buildStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF6C63FF).withValues(alpha: 0.8)),
        const SizedBox(height: 8),
        ShaderMask(
          shaderCallback: (b) => const LinearGradient(
            colors: [Color(0xFF8B7FFF), Color(0xFF00D9FF)],
          ).createShader(b),
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.25),
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStartButton(ReaderProvider provider) {
    return _HoverScale(
      child: Container(
        height: 62,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF8B7FFF), Color(0xFF00D9FF)],
            stops: [0.0, 0.5, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.45),
              blurRadius: 30,
              offset: const Offset(0, 10),
              spreadRadius: -6,
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () => provider.startReading(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            padding: EdgeInsets.zero,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.play_arrow_rounded, size: 28),
              const SizedBox(width: 10),
              Text(
                'Start Reading',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstallButton() {
    return Center(
      child: _HoverScale(
        child: GestureDetector(
          onTap: _triggerInstall,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_to_home_screen_rounded,
                    color: Color(0xFF00D9FF), size: 16),
                const SizedBox(width: 10),
                Text(
                  'Install Grasp as App',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Container(
          height: 1,
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Colors.white.withValues(alpha: 0.06),
                Colors.transparent,
              ],
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withValues(alpha: 0.6),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Crafted with ❤️ by Amogh · Powered by Antigravity',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.22),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  FILE HANDLING
  // ════════════════════════════════════════════════════════════════════

  Future<void> _pickFile(ReaderProvider provider) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'docx', 'pdf'],
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          _handleFile(provider, file.bytes!, file.name);
        } else {
          setState(() => _errorMessage = 'Could not read file data.');
        }
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error picking file: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleFile(ReaderProvider provider, dynamic bytes, String fileName) {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      provider.loadFile(bytes, fileName);
      _textController.clear();
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleUrlFetch(ReaderProvider provider) async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await provider.loadFromUrl(url);
      _urlController.clear();
      _textController.clear();
    } catch (e) {
      setState(() => _errorMessage = 'Could not fetch content. Some sites may be protected.');
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

// ── Hover scale micro-interaction ────────────────────────────────────
class _HoverScale extends StatefulWidget {
  final Widget child;
  const _HoverScale({required this.child});

  @override
  State<_HoverScale> createState() => _HoverScaleState();
}

class _HoverScaleState extends State<_HoverScale> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        scale: _hovering ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
