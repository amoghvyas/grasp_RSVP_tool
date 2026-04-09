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

/// The input dashboard screen — the first screen users see.
///
/// Features a premium design with:
/// - Animated gradient mesh background with floating orbs
/// - Glassmorphic cards for all UI sections
/// - Staggered entrance animations
/// - Premium typography and spacing
class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _textController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;
  bool _isInstallable = false;
  Timer? _installTimer;

  @override
  void initState() {
    super.initState();
    // Poll for installability every 2 seconds
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
    _installTimer?.cancel();
    super.dispose();
  }

  void _triggerInstall() {
    (web.window as dynamic).promptInstall();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReaderProvider>();
    final state = provider.state;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBackground(
        child: Center(
          child: SingleChildScrollView(
            // Tighter padding on mobile to save space
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth < 600 ? 16 : 24,
              vertical: 48,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: screenWidth > 800 ? 660 : double.infinity,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Hero Header ────────────────────────────────────
                  FadeSlideIn(
                    child: _buildHeader(),
                  ),
                  const SizedBox(height: 48),

                  // ── Text Input Card ────────────────────────────────
                  FadeSlideIn(
                    delayMs: 100,
                    child: GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: _buildTextInput(provider),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── "OR" Divider ───────────────────────────────────
                  FadeSlideIn(
                    delayMs: 150,
                    child: _buildDivider(),
                  ),
                  const SizedBox(height: 20),

                  // ── File Upload Card ───────────────────────────────
                  FadeSlideIn(
                    delayMs: 200,
                    child: GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: _buildFileUpload(provider),
                    ),
                  ),
                  
                  // Permanent Attribution (Visible all the time)
                  const SizedBox(height: 16),
                  FadeSlideIn(
                    delayMs: 250,
                    child: _buildCompactAttribution(),
                  ),
                  
                  // PWA Install Prompt (Mobile & Compatible Browsers)
                  if (_isInstallable) ...[
                    const SizedBox(height: 16),
                    FadeSlideIn(
                      delayMs: 300,
                      child: _buildInstallButton(),
                    ),
                  ],

                  // ── Error Message ──────────────────────────────────
                  if (_errorMessage != null)
                    FadeSlideIn(child: _buildError()),

                  // ── File Info Badge ────────────────────────────────
                  if (state.fileName != null) ...[
                    const SizedBox(height: 16),
                    FadeSlideIn(child: _buildFileBadge(state.fileName!)),
                  ],

                  // ── Content Stats + AI Tools + Start Button ────────
                  if (state.hasContent) ...[
                    const SizedBox(height: 28),
                    FadeSlideIn(
                      delayMs: 100,
                      child: GlassCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                        child: _buildContentSummary(state),
                      ),
                    ),

                    // AI Study Tools panel
                    if (provider.isAiReady) ...[
                      const SizedBox(height: 20),
                      FadeSlideIn(
                        delayMs: 200,
                        child: GlassCard(
                          padding: EdgeInsets.zero,
                          child: const StudyToolsPanel(),
                        ),
                      ),
                    ],

                    const SizedBox(height: 28),
                    FadeSlideIn(
                      delayMs: 300,
                      child: _buildStartButton(provider),
                    ),
                  ],

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

  Widget _buildHeader() {
    return Column(
      children: [
        // Glowing accent dot
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.6),
                blurRadius: 20,
                spreadRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // App title with gradient
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF8B7FFF), Color(0xFF00D9FF), Color(0xFFFF6B9D)],
            stops: [0.0, 0.5, 1.0],
          ).createShader(bounds),
          child: Text(
            'Grasp',
            style: GoogleFonts.inter(
              fontSize: 56,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -2,
              height: 1.0,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),

        // Tagline
        Text(
          'RSVP SPEED READER',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.25),
            letterSpacing: 6,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),

        // Subtitle
        Text(
          'Read faster. Retain more. Ace every exam.',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.45),
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTextInput(ReaderProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.edit_note, size: 16, color: Color(0xFF6C63FF)),
            ),
            const SizedBox(width: 10),
            Text(
              'Paste your text',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
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
            hintText: 'Paste any text here and start speed reading...',
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.04),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
            ),
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
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

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withValues(alpha: 0.08),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Text(
              'OR',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.2),
                letterSpacing: 3,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileUpload(ReaderProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF00D9FF).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.upload_file, size: 16, color: Color(0xFF00D9FF)),
            ),
            const SizedBox(width: 10),
            Text(
              'Upload a file',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Drag-and-drop zone
        SizedBox(
          height: 160,
          child: DropzoneWidget(
            onFileDropped: (bytes, fileName) => _handleFile(provider, bytes, fileName),
            onError: (error) => setState(() => _errorMessage = error),
          ),
        ),
        const SizedBox(height: 16),

        // Browse button
        Center(
          child: _HoverScale(
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : () => _pickFile(provider),
              icon: _isLoading
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.folder_open, size: 16),
              label: Text(
                _isLoading ? 'Processing...' : 'Browse files',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white.withValues(alpha: 0.7),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFF4757).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFF4757).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFFF4757), size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: GoogleFonts.inter(
                color: const Color(0xFFFF4757),
                fontSize: 12,
              ),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _errorMessage = null),
            icon: const Icon(Icons.close, size: 14),
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
        border: Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.description, size: 14, color: Color(0xFF6C63FF)),
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

  Widget _buildContentSummary(state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStat(Icons.format_list_numbered, '${state.totalWords}', 'words'),
        Container(
          width: 1,
          height: 36,
          color: Colors.white.withValues(alpha: 0.05),
        ),
        _buildStat(Icons.timer, state.estimatedTimeFormatted, 'est. time'),
        Container(
          width: 1,
          height: 36,
          color: Colors.white.withValues(alpha: 0.05),
        ),
        _buildStat(Icons.speed, '${state.wpm}', 'WPM'),
      ],
    );
  }

  Widget _buildStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF6C63FF).withValues(alpha: 0.7)),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.25),
            letterSpacing: 1,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStartButton(ReaderProvider provider) {
    return _HoverScale(
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF8B7FFF)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () => provider.startReading(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: EdgeInsets.zero,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.play_arrow_rounded, size: 26),
              const SizedBox(width: 10),
              Text(
                'Start Reading',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
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

  Widget _buildCompactAttribution() {
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Developed by ',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
              Text(
                'Amogh',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.6),
                ),
              ),
              Text(
                ' using ',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF00D9FF), Color(0xFFFF6B9D)],
                ).createShader(bounds),
                child: Text(
                  'Antigravity',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstallButton() {
    return _HoverScale(
      child: InkWell(
        onTap: _triggerInstall,
        borderRadius: BorderRadius.circular(16),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.install_mobile_rounded,
                color: Color(0xFF00D9FF),
                size: 18,
              ),
              const SizedBox(width: 12),
              Text(
                'Install Grasp App',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white12,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A widget that subtly scales up on hover for micro-interaction feedback.
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
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
