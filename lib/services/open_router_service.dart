import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service to access high-limit free AI models via OpenRouter.
class OpenRouterService {
  String? _apiKey;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// Default free models to rotate through
  final List<String> _freeModels = [
    'google/gemma-2-9b-it:free',
    'meta-llama/llama-3.1-8b-instruct:free',
  ];

  void initialize(String apiKey) {
    if (apiKey.isEmpty) return;
    _apiKey = apiKey;
    _isInitialized = true;
  }

  Future<String> _request(String prompt, {String? systemPrompt}) async {
    if (!_isInitialized) throw Exception('OpenRouter not initialized');

    for (var model in _freeModels) {
      try {
        final response = await http.post(
          Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
            'HTTP-Referer': 'https://grasptool.app',
            'X-Title': 'Grasp RSVP Tool',
            'OR-Logging': 'false', // Privacy: No logging of prompt/response
          },
          body: jsonEncode({
            'model': model,
            'messages': [
              if (systemPrompt != null) {'role': 'system', 'content': systemPrompt},
              {'role': 'user', 'content': prompt},
            ],
            'temperature': 0.7,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data['choices'][0]['message']['content'];
        }
      } catch (e) {
        // Try next model if one fails
        continue;
      }
    }
    throw Exception('All Infinite Mode models are currently busy. Try Gemini or wait a minute.');
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

  Future<RecallResult> generateRecallQuestion(String context) async {
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
      
      return RecallResult(
        question: data['question'],
        options: List<String>.from(data['options']),
        correctIndex: data['correctIndex'],
      );
    } catch (e) {
      // Robust fallback
      return RecallResult(
        question: 'What is the most accurate summary of the text you just read?',
        options: ['The theoretical foundation', 'The practical application', 'The historical context', 'The future implications'],
        correctIndex: 0,
      );
    }
  }
}

class RecallResult {
  final String question;
  final List<String> options;
  final int correctIndex;
  RecallResult({required this.question, required this.options, required this.correctIndex});
}
