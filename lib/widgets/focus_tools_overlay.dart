import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'apple_widgets.dart';

class FocusToolsOverlay extends StatefulWidget {
  const FocusToolsOverlay({super.key});

  @override
  State<FocusToolsOverlay> createState() => _FocusToolsOverlayState();
}

class _FocusToolsOverlayState extends State<FocusToolsOverlay> with TickerProviderStateMixin {
  late TabController _tabController;
  
  // Pomodoro State
  int _pomodoroSeconds = 25 * 60;
  bool _isPomoRunning = false;
  Timer? _pomoTimer;
  
  // Stopwatch State
  int _stopwatchMillis = 0;
  bool _isStopwatchRunning = false;
  Timer? _stopwatchTimer;
  
  // Custom Timer State
  int _customSeconds = 0;
  bool _isCustomRunning = false;
  Timer? _customTimer;
  final TextEditingController _minsController = TextEditingController(text: '10');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pomoTimer?.cancel();
    _stopwatchTimer?.cancel();
    _customTimer?.cancel();
    _minsController.dispose();
    super.dispose();
  }

  // Logic Helpers
  void _togglePomo() {
    if (_isPomoRunning) {
      _pomoTimer?.cancel();
    } else {
      _pomoTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        setState(() {
          if (_pomodoroSeconds > 0) {
            _pomodoroSeconds--;
          } else {
            _pomoTimer?.cancel();
            _isPomoRunning = false;
          }
        });
      });
    }
    setState(() => _isPomoRunning = !_isPomoRunning);
  }

  void _resetPomo() {
    _pomoTimer?.cancel();
    setState(() {
      _isPomoRunning = false;
      _pomodoroSeconds = 25 * 60;
    });
  }

  void _toggleStopwatch() {
    if (_isStopwatchRunning) {
      _stopwatchTimer?.cancel();
    } else {
      _stopwatchTimer = Timer.periodic(const Duration(milliseconds: 10), (t) {
        setState(() => _stopwatchMillis += 10);
      });
    }
    setState(() => _isStopwatchRunning = !_isStopwatchRunning);
  }

  void _resetStopwatch() {
    _stopwatchTimer?.cancel();
    setState(() {
      _isStopwatchRunning = false;
      _stopwatchMillis = 0;
    });
  }

  void _toggleCustom() {
    if (_isCustomRunning) {
      _customTimer?.cancel();
    } else {
      if (_customSeconds == 0) {
        _customSeconds = (int.tryParse(_minsController.text) ?? 10) * 60;
      }
      _customTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        setState(() {
          if (_customSeconds > 0) {
            _customSeconds--;
          } else {
            _customTimer?.cancel();
            _isCustomRunning = false;
          }
        });
      });
    }
    setState(() => _isCustomRunning = !_isCustomRunning);
  }

  void _resetCustom() {
    _customTimer?.cancel();
    setState(() {
      _isCustomRunning = false;
      _customSeconds = 0;
    });
  }

  String _formatTime(int totalSeconds) {
    final mins = (totalSeconds / 60).floor();
    final secs = totalSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _formatMillis(int ms) {
    final hundreds = (ms / 10).truncate() % 100;
    final totalSeconds = (ms / 1000).truncate();
    final seconds = totalSeconds % 60;
    final minutes = (totalSeconds / 60).truncate();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${hundreds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.5)),
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: AppleCard(
                padding: EdgeInsets.zero,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(isDark),
                    _buildTabSelector(isDark),
                    const Divider(height: 1),
                    SizedBox(
                      height: 300,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildPomodoroTab(isDark),
                          _buildStopwatchTab(isDark),
                          _buildCustomTab(isDark),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'FOCUS TOOLS',
            style: GoogleFonts.outfit(
              fontSize: 12, 
              fontWeight: FontWeight.w800, 
              letterSpacing: 1.5,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector(bool isDark) {
    return TabBar(
      controller: _tabController,
      indicatorColor: isDark ? Colors.white : Colors.black,
      labelColor: isDark ? Colors.white : Colors.black,
      unselectedLabelColor: isDark ? Colors.white30 : Colors.black38,
      dividerColor: Colors.transparent,
      tabs: const [
        Tab(text: 'Pomodoro'),
        Tab(text: 'Stopwatch'),
        Tab(text: 'Timer'),
      ],
    );
  }

  Widget _buildPomodoroTab(bool isDark) {
    return _buildTimerTemplate(
      time: _formatTime(_pomodoroSeconds),
      isRunning: _isPomoRunning,
      onToggle: _togglePomo,
      onReset: _resetPomo,
      isDark: isDark,
      label: '25 min Session',
    );
  }

  Widget _buildStopwatchTab(bool isDark) {
    return _buildTimerTemplate(
      time: _formatMillis(_stopwatchMillis),
      isRunning: _isStopwatchRunning,
      onToggle: _toggleStopwatch,
      onReset: _resetStopwatch,
      isDark: isDark,
      label: 'Precision Tracking',
    );
  }

  Widget _buildCustomTab(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!_isCustomRunning && _customSeconds == 0) ...[
            TextField(
              controller: _minsController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 48, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                hintText: 'MINS',
                border: InputBorder.none,
              ),
            ),
            const Text('Set duration', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ] else ...[
             Text(
              _formatTime(_customSeconds),
              style: GoogleFonts.outfit(fontSize: 64, fontWeight: FontWeight.w600),
            ),
          ],
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppleButton(
                label: _isCustomRunning ? 'Pause' : 'Start',
                onPressed: _toggleCustom,
              ),
              const SizedBox(width: 12),
              AppleButton(
                label: 'Reset',
                isPrimary: false,
                onPressed: _resetCustom,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimerTemplate({
    required String time,
    required bool isRunning,
    required VoidCallback onToggle,
    required VoidCallback onReset,
    required bool isDark,
    required String label,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          time,
          style: GoogleFonts.outfit(
            fontSize: 64, 
            fontWeight: FontWeight.w600,
            letterSpacing: -1,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.white24 : Colors.black26)),
        const SizedBox(height: 48),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppleButton(
              label: isRunning ? 'Pause' : 'Start',
              onPressed: onToggle,
            ),
            const SizedBox(width: 12),
            AppleButton(
              label: 'Reset',
              isPrimary: false,
              onPressed: onReset,
            ),
          ],
        ),
      ],
    );
  }
}
