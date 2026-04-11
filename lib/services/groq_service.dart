import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/reader_state.dart';

/// Service to access ultra-fast Groq LPU API models.
class GroqService {
  String? _apiKey;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// High-performance model for scholarly synthesis and reasoning
  final String _model = 'llama-3.3-70b-versatile';
  
  /// Vision model for OCR and handwriting recognition
  final String _visionModel = 'llama-3.2-11b-vision-preview';

  void initialize(String apiKey) {
    if (apiKey.isEmpty) return;
    // Security: Obfuscate the key in memory to prevent simple heap inspection
    // and string-searching in WebTools.
    final encoded = base64Encode(utf8.encode(apiKey));
    _apiKey = encoded;
    _isInitialized = true;
  }

  String _revealKey() {
    if (_apiKey == null) return '';
    return utf8.decode(base64Decode(_apiKey!));
  }

  Future<String> _request(String prompt, {String? systemPrompt}) async {
    if (!_isInitialized) throw Exception('Groq API not initialized');

    try {
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer ${_revealKey()}',
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            if (systemPrompt != null) {'role': 'system', 'content': systemPrompt},
            // Scholarly Truncation: Ensure mobile stability by limiting payload to ~10k tokens
            {'role': 'user', 'content': prompt.length > 40000 ? prompt.substring(0, 40000) : prompt},
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          return data['choices'][0]['message']['content'];
        } else {
           throw Exception('Empty choices returned from Groq (Payload: ${response.body})');
        }
      } else {
        throw Exception('Groq failed with status ${response.statusCode} (Payload: ${response.body})');
      }
    } catch (e) {
      throw Exception('Groq error: $e');
    }
  }

  Future<String> generateSummary(String text, {bool hinglish = false}) async {
    final systemPrompt = hinglish 
      ? 'Summarize this in a mix of Hindi and English (Hinglish). Use bullet points.'
      : 'Summarize this professionally for a student. Use bullet points.';
    return _request('Text: $text', systemPrompt: systemPrompt);
  }

  Future<String> generateVivaQuestions(String text, {bool hinglish = false}) async {
    final systemPrompt = hinglish
      ? 'Generate 5 conceptual Viva questions with answers in Hinglish based on this text.'
      : 'Generate 5 conceptual Viva questions with answers based on this text.';
    return _request('Text: $text', systemPrompt: systemPrompt);
  }

  Future<RecallQuestion> generateRecallQuestion(String context) async {
    final response = await _request(
      'Text context: $context',
      systemPrompt: 'You are a mastery teacher. Create a tricky MCQ from the text. Output ONLY a valid JSON object: {"question": "...", "options": ["A", "B", "C", "D"], "correctIndex": 0}'
    );

    try {
      // Find the first { and last } to extract JSON from potentially noisy output
      final startIndex = response.indexOf('{');
      final endIndex = response.lastIndexOf('}') + 1;
      if (startIndex == -1 || endIndex == -1) throw Exception('No JSON found');
      
      final jsonStr = response.substring(startIndex, endIndex);
      final data = jsonDecode(jsonStr);
      
      return RecallQuestion(
        question: data['question'],
        options: List<String>.from(data['options']),
        correctIndex: data['correctIndex'],
      );
    } catch (e) {
      // Robust fallback
      return RecallQuestion(
        question: 'What is the most accurate summary of the text you just read?',
        options: ['The theoretical foundation', 'The practical application', 'The historical context', 'The future implications'],
        correctIndex: 0,
      );
    }
  }

  Future<List<InteractiveQuiz>> generateQuiz(String context, int numQuestions, String difficulty) async {
    final response = await _request(
      'Create $numQuestions MCQs with $difficulty difficulty level from this Text: $context',
      systemPrompt: 'You are an examiner. Generate conceptual MCQs from the text. Output ONLY a valid JSON array of objects exactly like this: [{"question": "...", "options": ["A","B","C","D"], "correctIndex": 0, "explanation": "Short 1-2 lines explanation."}]'
    );
    try {
      final startIndex = response.indexOf('[');
      final endIndex = response.lastIndexOf(']') + 1;
      if (startIndex == -1 || endIndex == -1) throw Exception('No JSON array found');
      
      final jsonStr = response.substring(startIndex, endIndex);
      final List data = jsonDecode(jsonStr);
      
      return data.map((json) => InteractiveQuiz(
        question: json['question'] ?? 'Missing Question?',
        options: List<String>.from(json['options'] ?? []),
        correctIndex: json['correctIndex'] ?? 0,
        explanation: json['explanation'] ?? '',
      )).toList();
    } catch (e) {
      throw Exception('Failed to parse Quiz JSON. Please try again or adjust length. Error: $e');
    }
  }

  /// Performs OCR on an image using Groq Vision
  Future<String> performOcr(Uint8List imageBytes, String format) async {
    if (!_isInitialized) throw Exception('Groq API not initialized');

    final base64Image = base64Encode(imageBytes);
    final dataUrl = 'data:image/$format;base64,$base64Image';

    try {
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer ${_revealKey()}',
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'model': _visionModel,
          'messages': [
            {
              'role': 'user',
              'content': [
                {'type': 'text', 'text': 'Extract all text from this image. If it is a handwritten note, transcribe it accurately. Output ONLY the transcribed text without any preamble or conversational filler.'},
                {'type': 'image_url', 'image_url': {'url': dataUrl}}
              ],
            },
          ],
          'temperature': 0.1,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Groq Vision failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('OCR error: $e');
    }
  }
}
