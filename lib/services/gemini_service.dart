import 'package:google_generative_ai/google_generative_ai.dart';

/// Service for generating AI-powered study materials using the Gemini API.
///
/// Provides two core features:
/// 1. Comprehensive document summaries optimized for exam preparation
/// 2. Viva and exam-style questions with model answers
///
/// Both features support English and Hinglish output modes.
/// Uses Gemini 2.5 Flash by default (free tier, fast, high quality).
class GeminiService {
  GenerativeModel? _model;
  String _apiKey = '';
  bool _isInitialized = false;

  /// Models to try in order — if one hits quota, fall back to the next.
  static const _fallbackModels = [
    'gemini-2.5-flash',
    'gemini-2.5-flash-lite',
    'gemini-1.5-flash',
  ];

  /// Whether the service has been initialized with a valid API key.
  bool get isInitialized => _isInitialized;

  /// Initializes the Gemini model with the provided API key.
  ///
  /// [modelName] defaults to 'gemini-2.5-flash' which is the primary
  /// free-tier model as of April 2026.
  void initialize(String apiKey, {String modelName = 'gemini-2.5-flash'}) {
    if (apiKey.isEmpty) return;
    _apiKey = apiKey;
    _model = GenerativeModel(
      model: modelName,
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.3, // Low temperature for accuracy & consistency
        topP: 0.95,
        maxOutputTokens: 8192,
      ),
    );
    _isInitialized = true;
  }

  // ──────────────────────────────────────────────────────────────────
  //  SUMMARY GENERATION
  // ──────────────────────────────────────────────────────────────────

  /// Generates a structured, exam-optimized summary of the given [text].
  ///
  /// If [hinglish] is true, the summary is written in a Hindi-English mix
  /// that many Indian students find easier to remember and revise from.
  Future<String> generateSummary(String text, {bool hinglish = false}) async {
    _ensureInitialized();

    final language = hinglish
        ? 'Hinglish (a natural mix of Hindi and English, using Roman script for Hindi words — the way Indian students actually talk and study)'
        : 'English';

    final prompt = '''
You are an expert academic tutor who specializes in helping university students prepare for exams. Your summaries are legendary for being complete yet concise, and students who study from them consistently score top marks.

Summarize the following text for a student preparing for viva and written exams.

STRICT REQUIREMENTS:
1. Use clear section headings with ## markdown formatting
2. Highlight ALL important terminologies, key terms, and technical words in **bold** on first use
3. Structure content as concise bullet points — no long paragraphs
4. Include key definitions, formulas, relationships, and processes
5. Add memory aids (mnemonics, analogies, or easy mental models) wherever helpful
6. Maintain logical flow — concepts should build on each other
7. Cover EVERY important point — missing a key concept is unacceptable
8. Keep explanations crisp and exam-answer-ready — a student should be able to directly use these points in an answer
9. At the end, include a "🔑 Key Terms Glossary" section listing all important terms with one-line definitions
10. Language: $language

DO NOT add any preamble like "Here is the summary". Start directly with the content.

TEXT TO SUMMARIZE:
$text
''';

    return _generate(prompt);
  }

  // ──────────────────────────────────────────────────────────────────
  //  VIVA & EXAM QUESTIONS
  // ──────────────────────────────────────────────────────────────────

  /// Generates possible viva and exam questions with model answers.
  ///
  /// Questions cover all key concepts from the text, with a mix of
  /// question types (define, explain, compare, analyze) to prepare
  /// students for any angle an examiner might take.
  Future<String> generateVivaQuestions(String text, {bool hinglish = false}) async {
    _ensureInitialized();

    final language = hinglish
        ? 'Hinglish (a natural mix of Hindi and English, using Roman script for Hindi words — the way Indian students actually talk and study)'
        : 'English';

    final prompt = '''
You are a senior university professor and exam question setter with 20 years of experience. You know exactly what questions examiners ask and the specific points they look for in answers. Generate possible viva and exam questions based on the following text.

STRICT REQUIREMENTS:
1. Generate 15-20 questions that comprehensively cover ALL key concepts
2. Mix of question types:
   - 4-5 "Define" questions (testing terminology knowledge)
   - 4-5 "Explain" questions (testing understanding of processes/concepts)
   - 3-4 "Compare/Differentiate" questions (testing analytical thinking)
   - 2-3 "Why/How" questions (testing deeper understanding)
   - 2-3 "Tricky" questions that examiners commonly use to test real understanding vs rote learning
3. For each question, provide a MODEL ANSWER that:
   - Includes ALL important **terminologies** from the text
   - Is structured in numbered points (not paragraphs) — easy to memorize
   - Is concise but complete — exactly what gets full marks
   - Starts with the most important point first
4. Mark tricky questions with ⚠️ so students pay extra attention
5. Language: $language

FORMAT (use this exact format):

### Q1: [question text]
**A:** 
1. [point 1]
2. [point 2]
...

DO NOT add any preamble. Start directly with Q1.

TEXT:
$text
''';

    return _generate(prompt);
  }

  // ──────────────────────────────────────────────────────────────────
  //  INTERNAL
  // ──────────────────────────────────────────────────────────────────

  /// Sends a prompt to the Gemini API and returns the response text.
  ///
  /// If the current model hits a quota/rate limit, automatically retries
  /// with fallback models before giving up.
  Future<String> _generate(String prompt) async {
    // First, try the currently configured model
    try {
      return await _sendRequest(prompt);
    } on Exception catch (e) {
      // If it's a quota error, try fallback models
      if (_isQuotaError(e)) {
        return _generateWithFallback(prompt);
      }
      rethrow;
    }
  }

  /// Sends the prompt to the currently configured model.
  Future<String> _sendRequest(String prompt) async {
    try {
      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      final text = response.text;
      if (text == null || text.isEmpty) {
        throw Exception('Gemini returned an empty response. Please try again.');
      }
      return text;
    } on GenerativeAIException catch (e) {
      throw Exception('Gemini API error: ${e.message}');
    }
  }

  /// Tries each model in the fallback list until one succeeds.
  Future<String> _generateWithFallback(String prompt) async {
    for (final modelName in _fallbackModels) {
      try {
        // Temporarily switch to the fallback model
        _model = GenerativeModel(
          model: modelName,
          apiKey: _apiKey,
          generationConfig: GenerationConfig(
            temperature: 0.3,
            topP: 0.95,
            maxOutputTokens: 8192,
          ),
        );

        final result = await _sendRequest(prompt);
        // If it worked, keep using this model
        return result;
      } on Exception catch (e) {
        if (!_isQuotaError(e)) rethrow;
        // Quota error on this model too — try next one
        continue;
      }
    }

    throw Exception(
      'All Gemini models are at quota. Please wait a few minutes and try again, '
      'or check your API key at https://aistudio.google.com/apikey',
    );
  }

  /// Returns true if the exception is a quota/rate-limit error.
  bool _isQuotaError(Exception e) {
    final msg = e.toString().toLowerCase();
    return msg.contains('quota') ||
        msg.contains('rate') ||
        msg.contains('limit') ||
        msg.contains('429') ||
        msg.contains('resource_exhausted');
  }

  /// Throws if the service hasn't been initialized with an API key.
  void _ensureInitialized() {
    if (!_isInitialized || _model == null) {
      throw StateError(
        'GeminiService is not initialized. '
        'Provide a Gemini API key via --dart-define=GEMINI_API_KEY=your_key',
      );
    }
  }
}

