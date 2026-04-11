import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:csv/csv.dart';
// Note: In Flutter Web, we use anchor trick for downloads which doesn't need path_provider
import 'package:web/web.dart' as web;

import '../models/reader_state.dart';
import '../services/file_parser_service.dart';
import '../services/focus_service.dart';
import '../services/gemini_service.dart';
import '../services/open_router_service.dart';
import '../services/sanitizer_service.dart';
import '../services/tts_service.dart';
import '../services/url_import_service.dart';

/// Central state manager for the RSVP reader.
///
/// Orchestrates the mastering pipeline:
/// 1. Pacing Engine (RSVP)
/// 2. Active Recall (Checkpoints)
/// 3. Persistence (SharedPrefs)
/// 4. Flashcard Export (CSV)
class ReaderProvider extends ChangeNotifier {
  ReaderState _state = const ReaderState();
  SharedPreferences? _prefs;

  /// Current immutable state snapshot.
  ReaderState get state => _state;

  /// Internal timer handle for the pacing engine's word-advance loop.
  Timer? _timer;

  /// Timer for Focus Sprints.
  Timer? _sprintTimer;

  /// Gemini AI service for study tools.
  final GeminiService _geminiService = GeminiService();

  /// Ambient focus sound service.
  final FocusService _focusService = FocusService();

  /// Bimodal TTS reading service.
  final TtsService _ttsService = TtsService();

  /// OpenRouter service for Infinite mode.
  final OpenRouterService _openRouterService = OpenRouterService();

  /// URL content fetcher.
  final UrlImportService _urlService = UrlImportService();

  /// Whether the Gemini service is ready (API key was provided).
  bool get isAiReady => _geminiService.isInitialized;

  ReaderProvider() {
    _loadFromPrefs();
  }

  // ──────────────────────────────────────────────────────────────────
  //  PERSISTENCE
  // ──────────────────────────────────────────────────────────────────

  Future<void> _loadFromPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    final wpm = _prefs!.getInt('rsvp_wpm') ?? 300;
    final fontSize = _prefs!.getDouble('rsvp_fontSize') ?? 48.0;
    
    final focusSoundName = _prefs!.getString('rsvp_focusSound');
    final focusSound = FocusSound.values.firstWhere(
      (e) => e.name == focusSoundName, 
      orElse: () => FocusSound.none,
    );
    final isTtsEnabled = _prefs!.getString('rsvp_ttsEnabled') == 'true';
    
    _state = _state.copyWith(
      wpm: wpm,
      fontSize: fontSize,
      focusSound: focusSound,
      isTtsEnabled: isTtsEnabled,
    );
    
    // Auto-resume audio if it was on
    if (focusSound != FocusSound.none) {
      setFocusSound(focusSound);
    }
    if (isTtsEnabled) {
      toggleTts(true);
    }

    notifyListeners();
  }

  void _savePref(String key, dynamic value) {
    if (_prefs == null) return;
    if (value is int) _prefs!.setInt(key, value);
    if (value is double) _prefs!.setDouble(key, value);
    if (value is String) _prefs!.setString(key, value);
  }

  // ──────────────────────────────────────────────────────────────────
  //  AI INITIALIZATION
  // ──────────────────────────────────────────────────────────────────

  /// Initializes the Gemini service with the provided API key.
  void initializeAi(String apiKey) {
    _geminiService.initialize(apiKey);
  }

  /// Re-initializes Gemini with a new API key (e.g. entered manually).
  void updateApiKey(String apiKey) {
    _geminiService.initialize(apiKey);
    _openRouterService.initialize(apiKey); // Try same key for OR if compatible
    notifyListeners();
  }

  void updateOpenRouterKey(String apiKey) {
    _openRouterService.initialize(apiKey);
    notifyListeners();
  }

  void setAiProvider(AiProvider provider) {
    _state = _state.copyWith(aiProvider: provider);
    _savePref('ai_provider', provider.name);
    notifyListeners();
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
      clearSummary: true,
      clearVivaQuestions: true,
      clearAiError: true,
      clearRecall: true,
    );
    notifyListeners();
  }

  /// Parses a file's bytes, extracts text, and sanitizes it.
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
        clearSummary: true,
        clearVivaQuestions: true,
        clearAiError: true,
        clearRecall: true,
      );
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches context from a URL and loads it.
  Future<void> loadFromUrl(String url) async {
    try {
      final rawText = await _urlService.fetchUrlContent(url);
      final words = SanitizerService.sanitize(rawText);
      
      final Uri uri = Uri.parse(url);
      final domain = uri.host.replaceFirst('www.', '');

      _state = _state.copyWith(
        words: words,
        rawText: rawText,
        currentIndex: 0,
        isPlaying: false,
        fileName: 'Web: $domain',
        clearSummary: true,
        clearVivaQuestions: true,
        clearAiError: true,
        clearRecall: true,
      );
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // ──────────────────────────────────────────────────────────────────
  //  AI STUDY TOOLS & EXPORT
  // ──────────────────────────────────────────────────────────────────

  Future<void> generateSummary({bool hinglish = false}) async {
    if (_state.rawText.isEmpty) return;

    _state = _state.copyWith(
      isSummaryLoading: true,
      clearAiError: true,
      clearSummary: true,
    );
    notifyListeners();

    try {
      final summary = _state.aiProvider == AiProvider.gemini
          ? await _geminiService.generateSummary(_state.rawText, hinglish: hinglish)
          : await _openRouterService.generateSummary(_state.rawText, hinglish: hinglish);
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

  Future<void> generateVivaQuestions({bool hinglish = false}) async {
    if (_state.rawText.isEmpty) return;

    _state = _state.copyWith(
      isVivaLoading: true,
      clearAiError: true,
      clearVivaQuestions: true,
    );
    notifyListeners();

    try {
      final questions = _state.aiProvider == AiProvider.gemini
          ? await _geminiService.generateVivaQuestions(_state.rawText, hinglish: hinglish)
          : await _openRouterService.generateVivaQuestions(_state.rawText, hinglish: hinglish);
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

  /// Exports Viva questions to a CSV file compatible with Anki/Quizlet.
  void exportToFlashcards() {
    if (_state.vivaQuestions == null) return;
    
    // Simple parsing of our custom Viva format: ### Q[n]: [Q] **A:** [A...]
    final rows = <List<String>>[['Question', 'Answer']];
    final sections = _state.vivaQuestions!.split('### Q');
    
    for (var i = 1; i < sections.length; i++) {
        final part = sections[i];
        final qAndA = part.split('**A:**');
        if (qAndA.length >= 2) {
            final question = qAndA[0].replaceFirst(RegExp(r'^\d+:\s*'), '').trim();
            final answer = qAndA[1].trim();
            rows.add([question, answer]);
        }
    }
    
    final csvData = const ListToCsvConverter().convert(rows);
    final bytes = utf8.encode(csvData);
    final blob = web.Blob([bytes.toJS].toJS, web.BlobPropertyBag(type: 'text/csv'));
    final url = web.URL.createObjectURL(blob);
    
    final anchor = web.HTMLAnchorElement()
      ..href = url
      ..download = 'Grasp_Flashcards_${_state.fileName ?? "Pasted"}.csv';
    anchor.click();
    web.URL.revokeObjectURL(url);
  }

  // ──────────────────────────────────────────────────────────────────
  //  ACTIVE RECALL (MASTERY CHECKPOINTS)
  // ──────────────────────────────────────────────────────────────────

  Future<void> _triggerActiveRecall() async {
    if (_state.rawText.isEmpty || !isAiReady) return;

    pause(); // Stop the engine while testing
    _state = _state.copyWith(isRecallActive: true);
    notifyListeners();

    try {
      // Use local context (words around the current index) for the question
      final start = (_state.currentIndex - 300).clamp(0, _state.totalWords);
      final contextText = _state.words.sublist(start, _state.currentIndex).join(' ');
      
      final recall = _state.aiProvider == AiProvider.gemini
          ? await _geminiService.generateRecallQuestion(contextText)
          : await _openRouterService.generateRecallQuestion(contextText);
      
      _state = _state.copyWith(
        recallQuestion: recall.question,
        recallOptions: recall.options,
        recallCorrectIndex: recall.correctIndex,
      );
    } catch (e) {
      _state = _state.copyWith(isRecallActive: false);
    }
    notifyListeners();
  }

  void submitRecallAnswer(int index) {
    _state = _state.copyWith(
      hasAnsweredRecall: true,
      selectedRecallIndex: index,
    );
    notifyListeners();
  }

  void dismissRecall() {
    _state = _state.copyWith(clearRecall: true, isRecallActive: false);
    notifyListeners();
    play(); // Resume reading
  }

  // ──────────────────────────────────────────────────────────────────
  //  PLAYBACK CONTROLS
  // ──────────────────────────────────────────────────────────────────

  void play() {
    if (!_state.hasContent || _state.isRecallActive) return;
    if (_state.currentIndex >= _state.totalWords) {
      _state = _state.copyWith(currentIndex: 0);
    }
    _state = _state.copyWith(isPlaying: true);
    notifyListeners();
    _scheduleNextWord();
  }

  void pause() {
    _cancelTimer();
    _state = _state.copyWith(isPlaying: false);
    notifyListeners();
  }

  void togglePlayPause() {
    if (_state.isPlaying) {
      pause();
    } else {
      play();
    }
  }

  void rewind([int count = 10]) {
    final newIndex = (_state.currentIndex - count).clamp(0, _state.totalWords - 1);
    _state = _state.copyWith(currentIndex: newIndex);
    notifyListeners();
  }

  void reset() {
    _cancelTimer();
    _state = _state.copyWith(
      currentIndex: 0,
      isPlaying: false,
    );
    notifyListeners();
  }
  
  void startReading() {
    _state = _state.copyWith(
      isReading: true,
      currentIndex: 0,
      isPlaying: false,
    );
    notifyListeners();
  }

  void stopReading() {
    _cancelTimer();
    _state = _state.copyWith(isReading: false, isPlaying: false);
    notifyListeners();
  }

  void setWpm(int value) {
    final val = value.clamp(100, 1000);
    _state = _state.copyWith(wpm: val);
    _savePref('rsvp_wpm', val);
    notifyListeners();
  }

  void setFontSize(double value) {
    final val = value.clamp(24.0, 120.0);
    _state = _state.copyWith(fontSize: val);
    _savePref('rsvp_fontSize', val);
    notifyListeners();
  }

  // ── AUDIO CONTROLS ───────────────────────────────────────────────

  Future<void> setFocusSound(FocusSound sound) async {
    await _focusService.setSound(sound);
    _state = _state.copyWith(focusSound: sound);
    _savePref('rsvp_focusSound', sound.name);
    notifyListeners();
  }

  void setFocusVolume(double volume) {
    _focusService.setVolume(volume);
    _state = _state.copyWith(focusVolume: volume);
    notifyListeners();
  }

  void toggleTts(bool enabled) {
    _ttsService.toggle(enabled);
    _state = _state.copyWith(isTtsEnabled: enabled);
    _savePref('rsvp_ttsEnabled', enabled ? 'true' : 'false');
    notifyListeners();
  }

  // ── SPRINT CONTROLS ──────────────────────────────────────────────

  void startSprint(int minutes) {
    _sprintTimer?.cancel();
    _state = _state.copyWith(
      isSprintActive: true,
      sprintTimeRemaining: minutes * 60,
    );
    notifyListeners();
    
    _sprintTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _tickSprint();
    });
  }

  void stopSprint() {
    _sprintTimer?.cancel();
    _state = _state.copyWith(isSprintActive: false);
    notifyListeners();
  }

  void _tickSprint() {
    if (_state.sprintTimeRemaining <= 0) {
      _sprintTimer?.cancel();
      pause(); // Pause reading when sprint finishes
      _state = _state.copyWith(isSprintActive: false);
      notifyListeners();
      return;
    }

    _state = _state.copyWith(
      sprintTimeRemaining: _state.sprintTimeRemaining - 1,
    );
    notifyListeners();
  }

  // ──────────────────────────────────────────────────────────────────
  //  PACING ENGINE & CHECKPOINTS
  // ──────────────────────────────────────────────────────────────────

  void _scheduleNextWord() {
    _cancelTimer();

    if (!_state.isPlaying || _state.isRecallActive) return;
    if (_state.currentIndex >= _state.totalWords) {
      pause();
      return;
    }

    // Check for Active Recall checkpoint
    if (_state.currentIndex > 0 && 
        _state.currentIndex % _state.recallInterval == 0 && 
        !_state.isRecallActive) {
      _triggerActiveRecall();
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

      // Bimodal sync
      if (_state.isTtsEnabled) {
        _ttsService.speakWord(_state.currentWord);
      }

      _scheduleNextWord();
    });
  }

  int _calculateDelay() {
    final baseDelay = (60000 / _state.wpm).round();
    final word = _state.currentWord;
    if (word.isEmpty) return baseDelay;
    final lastChar = word[word.length - 1];
    if (lastChar == ',') return baseDelay + 150;
    if (lastChar == '.' || lastChar == '?' || lastChar == '!') return baseDelay + 400;
    if (lastChar == ';' || lastChar == ':') return baseDelay + 200;
    return baseDelay;
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }
}
