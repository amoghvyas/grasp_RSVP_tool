import 'package:flutter_tts/flutter_tts.dart';

/// Service to handle synchronized Text-to-Speech reading.
class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _isEnabled = false;

  bool get isEnabled => _isEnabled;

  TtsService() {
    _init();
  }

  Future<void> _init() async {
    await _tts.setLanguage("en-US");
    await _tts.setPitch(1.0);
    // Set speech rate lower for clearer individual words in RSVP
    await _tts.setSpeechRate(0.5); 
  }

  void toggle(bool value) {
    _isEnabled = value;
    if (!value) _tts.stop();
  }

  Future<void> speakWord(String word) async {
    if (!_isEnabled || word.isEmpty) return;
    await _tts.speak(word);
  }

  void stop() {
    _tts.stop();
  }
}
