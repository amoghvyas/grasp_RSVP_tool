import 'package:flutter_tts/flutter_tts.dart';

/// Service to handle Text-to-Speech reading of uploaded materials.
class TtsService {
  final FlutterTts _tts = FlutterTts();

  TtsService() {
    _init();
  }

  Future<void> _init() async {
    await _tts.setLanguage("en-US");
    await _tts.setPitch(1.0);
    // Setting speech rate to a normal, conversational speed
    await _tts.setSpeechRate(0.5); 
  }

  Future<void> speakFullText(String text) async {
    if (text.isEmpty) return;
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}
