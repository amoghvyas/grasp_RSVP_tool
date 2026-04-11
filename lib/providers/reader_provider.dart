import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:csv/csv.dart';

import '../models/reader_state.dart';
import '../services/file_parser_service.dart';
import '../services/focus_service.dart';
import '../services/gemini_service.dart';
import '../services/groq_service.dart';
import '../services/sanitizer_service.dart';
import '../services/tts_service.dart';
import '../services/url_import_service.dart';

// Conditional import: dart:html on web, stub on other platforms
import 'download_stub.dart'
    if (dart.library.html) 'download_html.dart';

/// Central state manager for the RSVP reader.
class ReaderProvider extends ChangeNotifier {
  ReaderState _state = const ReaderState();
  ReaderState get state => _state;

  // ── Services ──────────────────────────────────────────────────
  final GeminiService _geminiService = GeminiService();
  final FocusService _focusService = FocusService();
  final TtsService _ttsService = TtsService();
  final GroqService _groqService = GroqService();
  final UrlImportService _urlService = UrlImportService();

  Timer? _timer;
  Timer? _sprintTimer;

  ReaderProvider() {
    _loadFromPrefs();
  }

  // ── LOADING DATA ──────────────────────────────────────────────

  /// Legacy alias used by InputScreen
  void loadText(String text) => loadFromText(text);

  Future<void> loadFromText(String text, {String? fileName}) async {
    // SanitizerService.sanitize is static — returns List<String>
    final words = SanitizerService.sanitize(text);
    _state = _state.copyWith(
      rawText: text,
      words: words,
      fileName: fileName,
      currentIndex: 0,
      clearSummary: true,
      clearVivaQuestions: true,
      clearRecall: true,
    );
    notifyListeners();
  }

  Future<void> loadFile(dynamic bytes, String fileName) async {
    try {
      // FileParserService.parseFile is static
      final content = FileParserService.parseFile(bytes, fileName);
      await loadFromText(content, fileName: fileName);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loadFromUrl(String url) async {
    // UrlImportService uses instance method fetchUrlContent
    final text = await _urlService.fetchUrlContent(url);
    await loadFromText(text, fileName: 'Web Content');
  }

  // ── AI STUDY TOOLS ─────────────────────────────────────────────

  void updateApiKey(String key) {
    if (_state.aiProvider == AiProvider.gemini) {
      _geminiService.initialize(key);
    } else {
      _groqService.initialize(key);
    }
    // Recheck initialization status
    notifyListeners();
  }

  Future<void> generateSummary({bool hinglish = false}) async {
    if (_state.rawText.isEmpty) return;
    _state = _state.copyWith(isSummaryLoading: true, clearAiError: true);
    notifyListeners();
    try {
      String summary;
      if (_state.aiProvider == AiProvider.gemini) {
        summary = await _geminiService.generateSummary(_state.rawText, hinglish: hinglish);
      } else {
        try {
          summary = await _groqService.generateSummary(_state.rawText, hinglish: hinglish);
        } catch (e) {
          // Fallback to Gemini if Groq experiences network/CORS issues or limits
          summary = await _geminiService.generateSummary(_state.rawText, hinglish: hinglish);
        }
      }
      _state = _state.copyWith(summary: summary, isSummaryLoading: false);
    } catch (e) {
      _state = _state.copyWith(
        isSummaryLoading: false,
        aiError: e.toString().replaceAll('Exception: ', ''),
      );
    }
    notifyListeners();
  }

  Future<void> generateVivaQuestions({bool hinglish = false}) async {
    if (_state.rawText.isEmpty) return;
    _state = _state.copyWith(isVivaLoading: true, clearAiError: true);
    notifyListeners();
    try {
      String questions;
      if (_state.aiProvider == AiProvider.gemini) {
        questions = await _geminiService.generateVivaQuestions(_state.rawText, hinglish: hinglish);
      } else {
        try {
          questions = await _groqService.generateVivaQuestions(_state.rawText, hinglish: hinglish);
        } catch (e) {
          questions = await _geminiService.generateVivaQuestions(_state.rawText, hinglish: hinglish);
        }
      }
      _state = _state.copyWith(vivaQuestions: questions, isVivaLoading: false);
    } catch (e) {
      _state = _state.copyWith(
        isVivaLoading: false,
        aiError: e.toString().replaceAll('Exception: ', ''),
      );
    }
    notifyListeners();
  }

  void exportToFlashcards() {
    if (_state.vivaQuestions == null) return;
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
    if (kIsWeb) {
      downloadCsv(csvData, 'Grasp_Flashcards_${_state.fileName ?? "Pasted"}.csv');
    }
  }

  // ── ACTIVE RECALL ──────────────────────────────────────────────

  Future<void> _triggerActiveRecall() async {
    pause();
    _state = _state.copyWith(isRecallActive: true, clearRecall: true);
    notifyListeners();
    try {
      final start = (_state.currentIndex - 300).clamp(0, _state.totalWords);
      final contextText = _state.words.sublist(start, _state.currentIndex).join(' ');
      
      RecallQuestion recall;
      if (_state.aiProvider == AiProvider.gemini) {
        recall = await _geminiService.generateRecallQuestion(contextText);
      } else {
        try {
          recall = await _groqService.generateRecallQuestion(contextText);
        } catch (e) {
          recall = await _geminiService.generateRecallQuestion(contextText);
        }
      }
      
      _state = _state.copyWith(
        recallQuestion: recall.question,
        recallOptions: recall.options,
        recallCorrectIndex: recall.correctIndex,
      );
    } catch (e) {
      // Fallback handled in services
    }
    notifyListeners();
  }

  void submitRecallAnswer(int index) {
    _state = _state.copyWith(hasAnsweredRecall: true, selectedRecallIndex: index);
    notifyListeners();
  }

  void dismissRecall() {
    _state = _state.copyWith(clearRecall: true, isRecallActive: false);
    notifyListeners();
    play();
  }

  // ── PACING ENGINE ──────────────────────────────────────────────

  void play() {
    if (!_state.hasContent || _state.isRecallActive) return;
    if (_state.currentIndex >= _state.totalWords) _state = _state.copyWith(currentIndex: 0);
    _state = _state.copyWith(isPlaying: true);
    notifyListeners();
    _scheduleNextWord();
  }

  void pause() {
    _cancelTimer();
    _state = _state.copyWith(isPlaying: false);
    notifyListeners();
  }

  void togglePlayPause() => _state.isPlaying ? pause() : play();

  void rewind([int count = 10]) {
    _state = _state.copyWith(
      currentIndex: (_state.currentIndex - count).clamp(0, _state.totalWords - 1),
    );
    notifyListeners();
  }

  void reset() {
    _cancelTimer();
    _state = _state.copyWith(currentIndex: 0, isPlaying: false);
    notifyListeners();
  }

  void startReading() {
    _state = _state.copyWith(isReading: true, currentIndex: 0, isPlaying: false);
    notifyListeners();
  }

  void stopReading() {
    _cancelTimer();
    _state = _state.copyWith(isReading: false, isPlaying: false);
    notifyListeners();
  }

  void _scheduleNextWord() {
    _cancelTimer();
    if (!_state.isPlaying || _state.isRecallActive) return;
    if (_state.currentIndex >= _state.totalWords) {
      pause();
      return;
    }
    if (_state.currentIndex > 0 &&
        _state.currentIndex % _state.recallInterval == 0 &&
        !_state.isRecallActive) {
      _triggerActiveRecall();
      return;
    }
    _timer = Timer(Duration(milliseconds: _calculateDelay()), () {
      if (!_state.isPlaying) return;
      final nextIndex = _state.currentIndex + 1;
      if (nextIndex >= _state.totalWords) {
        _state = _state.copyWith(isPlaying: false);
      } else {
        _state = _state.copyWith(currentIndex: nextIndex);
        if (_state.isListening && _state.currentIndex == 0) {
          // If listening is toggled on during RSVP flow, it operates independently,
          // but we no longer trigger word-by-word TTS sync since speech speeds are different.
        }
        _scheduleNextWord();
      }
      notifyListeners();
    });
  }

  int _calculateDelay() {
    final baseDelay = (60000 / _state.wpm).round();
    final word = _state.currentWord;
    if (word.isEmpty) return baseDelay;
    final lastChar = word[word.length - 1];
    if (lastChar == ',') return baseDelay + 150;
    if (RegExp(r'[.?!]').hasMatch(lastChar)) return baseDelay + 400;
    if (RegExp(r'[;:]').hasMatch(lastChar)) return baseDelay + 200;
    return baseDelay;
  }

  // ── UTILS ─────────────────────────────────────────────────────

  void setWpm(int v) {
    _state = _state.copyWith(wpm: v.clamp(100, 1000));
    _savePref('rsvp_wpm', _state.wpm);
    notifyListeners();
  }

  void setFontSize(double v) {
    _state = _state.copyWith(fontSize: v.clamp(24.0, 120.0));
    _savePref('rsvp_fontSize', _state.fontSize.toInt());
    notifyListeners();
  }

  Future<void> setFocusSound(FocusSound s) async {
    await _focusService.setSound(s);
    _state = _state.copyWith(focusSound: s);
    _savePref('rsvp_focusSound', s.name);
    notifyListeners();
  }

  void setFocusVolume(double volume) {
    _focusService.setVolume(volume);
    _state = _state.copyWith(focusVolume: volume);
    notifyListeners();
  }

  void toggleListening() {
    if (_state.rawText.isEmpty) return;

    final newState = !_state.isListening;
    if (newState) {
      _ttsService.speakFullText(_state.rawText);
    } else {
      _ttsService.stop();
    }
    
    _state = _state.copyWith(isListening: newState);
    notifyListeners();
  }

  void startSprint(int mins) {
    _sprintTimer?.cancel();
    _state = _state.copyWith(isSprintActive: true, sprintTimeRemaining: mins * 60);
    _sprintTimer = Timer.periodic(const Duration(seconds: 1), (t) => _tickSprint());
    notifyListeners();
  }

  void stopSprint() {
    _sprintTimer?.cancel();
    _state = _state.copyWith(isSprintActive: false);
    notifyListeners();
  }

  void _tickSprint() {
    if (_state.sprintTimeRemaining <= 0) {
      stopSprint();
      pause();
    } else {
      _state = _state.copyWith(sprintTimeRemaining: _state.sprintTimeRemaining - 1);
      notifyListeners();
    }
  }

  void setAiProvider(AiProvider p) {
    _state = _state.copyWith(aiProvider: p);
    _savePref('rsvp_aiProvider', p.name);
    notifyListeners();
  }

  void initializeAiKeys(String geminiKey, String groqKey) {
    if (geminiKey.isNotEmpty) _geminiService.initialize(geminiKey);
    if (groqKey.isNotEmpty) _groqService.initialize(groqKey);
    notifyListeners();
  }

  bool get isAiReady => _geminiService.isInitialized || _groqService.isInitialized;

  // ── PERSISTENCE ───────────────────────────────────────────────

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final wpm = prefs.getInt('rsvp_wpm') ?? 300;
    final fontSize = (prefs.getInt('rsvp_fontSize') ?? 48).toDouble();
    final focusSoundName = prefs.getString('rsvp_focusSound') ?? FocusSound.none.name;
    final ttsEnabled = (prefs.getInt('rsvp_ttsEnabled') ?? 0) == 1;
    final aiProviderName = prefs.getString('rsvp_aiProvider') ?? AiProvider.gemini.name;

    final focusSound = FocusSound.values.firstWhere(
      (s) => s.name == focusSoundName,
      orElse: () => FocusSound.none,
    );
    final aiProvider = AiProvider.values.firstWhere(
      (p) => p.name == aiProviderName,
      orElse: () => AiProvider.gemini,
    );

    _state = _state.copyWith(
      wpm: wpm,
      fontSize: fontSize,
      focusSound: focusSound,
      aiProvider: aiProvider,
    );
    notifyListeners();
  }

  Future<void> _savePref(String key, dynamic val) async {
    final prefs = await SharedPreferences.getInstance();
    if (val is int) await prefs.setInt(key, val);
    else if (val is String) await prefs.setString(key, val);
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _cancelTimer();
    _sprintTimer?.cancel();
    super.dispose();
  }
}
