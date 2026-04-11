import 'dart:async';
import 'package:web/web.dart' as web;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/reader_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/apple_widgets.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(32, 16, 32, 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 5, decoration: BoxDecoration(color: isDark ? Colors.white12 : Colors.black12, borderRadius: BorderRadius.circular(5))),
            const SizedBox(height: 32),
            Text('Install Grasp', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Add to home screen for the full scholarship experience.', style: TextStyle(color: isDark ? Colors.white60 : Colors.black54), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            AppleButton(label: 'Got it', onPressed: () => Navigator.pop(context), width: double.infinity),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReaderProvider>();
    final state = provider.state;
    final sw = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: sw < 600 ? 20 : 40, vertical: 60),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: sw > 900 ? 800 : double.infinity),
              child: Column(
                children: [
                  _buildHeader(isDark),
                  const SizedBox(height: 60),
                  const WelcomeGuidePanel(),
                  const SizedBox(height: 48),
                  
                  AppleCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _buildTabSwitcher(isDark),
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: _buildInputArea(provider, state, isDark),
                        ),
                      ],
                    ),
                  ),
                  
                  if (state.hasContent) ...[
                    const SizedBox(height: 32),
                    AppleCard(
                      child: Row(
                        children: [
                          Expanded(child: _buildContentStats(state, isDark)),
                          const SizedBox(width: 24),
                          AppleButton(
                            label: 'Start Reading',
                            onPressed: () => provider.startReading(),
                            icon: Icons.play_arrow_rounded,
                          ),
                        ],
                      ),
                    ),
                    if (provider.isAiReady) ...[
                      const SizedBox(height: 24),
                      const StudyToolsPanel(),
                    ],
                  ],
                  
                  const SizedBox(height: 80),
                  _buildFooter(isDark),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _buildThemeToggle(isDark),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      children: [
        Text(
          'Grasp',
          style: GoogleFonts.outfit(
            fontSize: 56,
            fontWeight: FontWeight.w700,
            letterSpacing: -2,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'The scholarly RSVP tool for high-speed absorption.',
          style: TextStyle(
            fontSize: 18,
            color: isDark ? Colors.white60 : Colors.black45,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTabSwitcher(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          _tabItem(0, 'Paste Text', Icons.text_fields_rounded),
          _tabItem(1, 'Upload File', Icons.file_present_rounded),
          _tabItem(2, 'Import URL', Icons.link_rounded),
        ],
      ),
    );
  }

  Widget _tabItem(int index, String label, IconData icon) {
    final isSelected = _inputTab == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _inputTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, size: 18, color: isSelected ? (isDark ? Colors.white : Colors.black) : (isDark ? Colors.white30 : Colors.black26)),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? (isDark ? Colors.white : Colors.black) : (isDark ? Colors.white30 : Colors.black26),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(ReaderProvider provider, state, bool isDark) {
    if (_inputTab == 0) {
      return Column(
        children: [
          TextField(
            controller: _textController,
            maxLines: 8,
            decoration: const InputDecoration(hintText: 'Paste your research paper, article or notes here...'),
          ),
          const SizedBox(height: 24),
          AppleButton(
            label: 'Load Content',
            onPressed: () => provider.loadText(_textController.text),
            width: double.infinity,
          ),
        ],
      );
    }
    if (_inputTab == 1) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05), width: 2),
        ),
        child: DropzoneWidget(
          onFilesDropped: (files) => provider.loadFile(files.first),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_upload_outlined, size: 48, color: isDark ? Colors.white24 : Colors.black12),
                const SizedBox(height: 16),
                Text('Drag and drop PDF or text file', style: TextStyle(color: isDark ? Colors.white38 : Colors.black26)),
                const SizedBox(height: 24),
                AppleButton(
                  label: 'Browse Files',
                  isPrimary: false,
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles();
                    if (result != null) provider.loadFile(result.files.first);
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Column(
      children: [
        TextField(
          controller: _urlController,
          decoration: const InputDecoration(hintText: 'https://example.com/article'),
        ),
        const SizedBox(height: 24),
        AppleButton(
          label: 'Import Article',
          isLoading: _isLoading,
          onPressed: () async {
            setState(() => _isLoading = true);
            try {
              await provider.loadUrl(_urlController.text);
            } catch (e) {
              setState(() => _errorMessage = e.toString());
            } finally {
              setState(() => _isLoading = false);
            }
          },
          width: double.infinity,
        ),
      ],
    );
  }

  Widget _buildContentStats(state, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(state.fileName ?? 'Pasted Content', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        const SizedBox(height: 4),
        Text(
          '${state.totalWords} words • ~${state.estimatedTimeFormatted} read',
          style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildFooter(bool isDark) {
    return Column(
      children: [
        Text(
          'Built by Amogh 🤝',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white24 : Colors.black12,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 24),
        if (_isInstallable)
          AppleButton(
            label: 'Install App',
            isPrimary: false,
            onPressed: _triggerInstall,
          ),
      ],
    );
  }

  Widget _buildThemeToggle(bool isDark) {
    return FloatingActionButton(
      onPressed: () => context.read<ThemeProvider>().toggle(),
      backgroundColor: isDark ? Colors.white : Colors.black,
      child: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: isDark ? Colors.black : Colors.white),
    );
  }
}
