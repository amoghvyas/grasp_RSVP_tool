import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../models/reader_state.dart';
import '../services/file_parser_service.dart';
import '../services/gemini_service.dart';
import '../services/sanitizer_service.dart';

/// Central state manager for the RSVP reader.
///
/// Uses [ChangeNotifier] for lightweight, Provider-based reactivity.
/// Orchestrates the sanitization pipeline, pacing engine, AI study tools,
/// and all user interactions (play/pause, rewind, settings).
class ReaderProvider extends ChangeNotifier {
  ReaderState _state = const ReaderState();

  /// Current immutable state snapshot.
  ReaderState get state => _state;

  /// Internal timer handle for the pacing engine's word-advance loop.
  Timer? _timer;

  /// Gemini AI service for study tools.
  final GeminiService _geminiService = GeminiService();

  /// Whether the Gemini service is ready (API key was provided).
  bool get isAiReady => _geminiService.isInitialized;

  // ──────────────────────────────────────────────────────────────────
  //  AI INITIALIZATION
  // ──────────────────────────────────────────────────────────────────

  /// Initializes the Gemini service with the provided API key.
  /// Called once at app startup from main.dart.
  void initializeAi(String apiKey) {
    _geminiService.initialize(apiKey);
  }

  // ──────────────────────────────────────────────────────────────────
  //  TEXT LOADING
  // ──────────────────────────────────────────────────────────────────

  /// Loads raw pasted text through the sanitization pipeline.
  void loadText(String rawText) {
    final words = SanitizerService.sanitize(rawText);
    _state = _state.copyWith(
      words: words,
      rawText: rawText,
      currentIndex: 0,
      isPlaying: false,
      fileName: null,
      // Clear previous AI content when new text is loaded
      clearSummary: true,
      clearVivaQuestions: true,
      clearAiError: true,
    );
    notifyListeners();
  }

  /// Parses a file's bytes, extracts text, and sanitizes it.
  ///
  /// Throws if the file format is unsupported or parsing fails.
  void loadFile(Uint8List bytes, String fileName) {
    try {
      final rawText = FileParserService.parseFile(bytes, fileName);
      final words = SanitizerService.sanitize(rawText);
      _state = _state.copyWith(
        words: words,
        rawText: rawText,
        currentIndex: 0,
        isPlaying: false,
        fileName: fileName,
        // Clear previous AI content when new file is loaded
        clearSummary: true,
        clearVivaQuestions: true,
        clearAiError: true,
      );
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // ──────────────────────────────────────────────────────────────────
  //  AI STUDY TOOLS
  // ──────────────────────────────────────────────────────────────────

  /// Generates an AI-powered summary of the loaded text.
  ///
  /// If [hinglish] is true, the summary will be in Hindi-English mix.
  Future<void> generateSummary({bool hinglish = false}) async {
    if (_state.rawText.isEmpty) return;

    _state = _state.copyWith(
      isSummaryLoading: true,
      clearAiError: true,
      clearSummary: true,
    );
    notifyListeners();

    try {
      final summary = await _geminiService.generateSummary(
        _state.rawText,
        hinglish: hinglish,
      );
      _state = _state.copyWith(
        summary: summary,
        isSummaryLoading: false,
      );
    } catch (e) {
      _state = _state.copyWith(
        aiError: e.toString().replaceFirst('Exception: ', ''),
        isSummaryLoading: false,
      );
    }
    notifyListeners();
  }

  /// Generates AI-powered viva and exam questions with answers.
  ///
  /// If [hinglish] is true, the Q&A will be in Hindi-English mix.
  Future<void> generateVivaQuestions({bool hinglish = false}) async {
    if (_state.rawText.isEmpty) return;

    _state = _state.copyWith(
      isVivaLoading: true,
      clearAiError: true,
      clearVivaQuestions: true,
    );
    notifyListeners();

    try {
      final questions = await _geminiService.generateVivaQuestions(
        _state.rawText,
        hinglish: hinglish,
      );
      _state = _state.copyWith(
        vivaQuestions: questions,
        isVivaLoading: false,
      );
    } catch (e) {
      _state = _state.copyWith(
        aiError: e.toString().replaceFirst('Exception: ', ''),
        isVivaLoading: false,
      );
    }
    notifyListeners();
  }

  /// Clears all AI-generated content.
  void clearAiContent() {
    _state = _state.copyWith(
      clearSummary: true,
      clearVivaQuestions: true,
      clearAiError: true,
    );
    notifyListeners();
  }

  // ──────────────────────────────────────────────────────────────────
  //  READING MODE
  // ──────────────────────────────────────────────────────────────────

  /// Enters reading mode (transitions to the RSVP canvas).
  void startReading() {
    _state = _state.copyWith(
      isReading: true,
      currentIndex: 0,
      isPlaying: false,
    );
    notifyListeners();
  }

  /// Exits reading mode and returns to the input dashboard.
  void stopReading() {
    _cancelTimer();
    _state = _state.copyWith(
      isReading: false,
      isPlaying: false,
    );
    notifyListeners();
  }

  // ──────────────────────────────────────────────────────────────────
  //  PLAYBACK CONTROLS
  // ──────────────────────────────────────────────────────────────────

  /// Starts or resumes word advancement.
  void play() {
    if (!_state.hasContent) return;
    if (_state.currentIndex >= _state.totalWords) {
      _state = _state.copyWith(currentIndex: 0);
    }
    _state = _state.copyWith(isPlaying: true);
    notifyListeners();
    _scheduleNextWord();
  }

  /// Pauses word advancement.
  void pause() {
    _cancelTimer();
    _state = _state.copyWith(isPlaying: false);
    notifyListeners();
  }

  /// Toggles between play and pause.
  void togglePlayPause() {
    if (_state.isPlaying) {
      pause();
    } else {
      play();
    }
  }

  /// Jumps back [count] words (default 10), clamped to 0.
  void rewind([int count = 10]) {
    final newIndex = (_state.currentIndex - count).clamp(0, _state.totalWords - 1);
    _state = _state.copyWith(currentIndex: newIndex);
    notifyListeners();
  }

  // ──────────────────────────────────────────────────────────────────
  //  SETTINGS
  // ──────────────────────────────────────────────────────────────────

  /// Updates the reading speed. Range: 100–1000 WPM.
  void setWpm(int value) {
    _state = _state.copyWith(wpm: value.clamp(100, 1000));
    notifyListeners();
  }

  /// Updates the display font size. Range: 24–120 logical pixels.
  void setFontSize(double value) {
    _state = _state.copyWith(fontSize: value.clamp(24.0, 120.0));
    notifyListeners();
  }

  // ──────────────────────────────────────────────────────────────────
  //  PACING ENGINE
  // ──────────────────────────────────────────────────────────────────

  int _calculateDelay() {
    final baseDelay = (60000 / _state.wpm).round();
    final word = _state.currentWord;

    if (word.isEmpty) return baseDelay;

    final lastChar = word[word.length - 1];

    if (lastChar == ',') return baseDelay + 150;
    if (lastChar == '.' || lastChar == '?' || lastChar == '!') {
      return baseDelay + 400;
    }
    if (lastChar == ';' || lastChar == ':') return baseDelay + 200;

    return baseDelay;
  }

  void _scheduleNextWord() {
    _cancelTimer();

    if (!_state.isPlaying) return;
    if (_state.currentIndex >= _state.totalWords) {
      pause();
      return;
    }

    final delay = _calculateDelay();
    _timer = Timer(Duration(milliseconds: delay), () {
      if (!_state.isPlaying) return;

      final nextIndex = _state.currentIndex + 1;
      if (nextIndex >= _state.totalWords) {
        _state = _state.copyWith(isPlaying: false);
        notifyListeners();
        return;
      }

      _state = _state.copyWith(currentIndex: nextIndex);
      notifyListeners();
      _scheduleNextWord();
    });
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// Clears all state and returns to a fresh initial state.
  void reset() {
    _cancelTimer();
    _state = const ReaderState();
    notifyListeners();
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }
}
