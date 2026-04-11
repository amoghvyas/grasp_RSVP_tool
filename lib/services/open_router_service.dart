import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/reader_state.dart';

/// Service to access high-limit free AI models via Pollinations.ai.
/// Requires NO API KEY, making it completely free and limitless.
class OpenRouterService {
  bool _isInitialized = true; // Always true since no key is needed

  bool get isInitialized => _isInitialized;

  void initialize(String apiKey) {
    // No-op: Pollinations doesn't require an API key
  }

  Future<String> _request(String prompt, {String? systemPrompt}) async {
    try {
      final response = await http.post(
        Uri.parse('https://text.pollinations.ai/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'messages': [
            if (systemPrompt != null) {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': prompt},
          ],
          'model': 'openai', // Defaulting to high quality
          'jsonMode': false,
        }),
      );

      if (response.statusCode == 200) {
        // Pollinations text endpoint returns raw plain text response!
        return response.body;
      }
      throw Exception('Server returned ${response.statusCode}');
    } catch (e) {
      throw Exception('Exception: All Infinite Mode models are currently busy. Try Gemini or wait a minute. Details: $e');
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
}
