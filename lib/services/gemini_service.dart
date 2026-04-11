import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/reader_state.dart';

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

  /// Models to try in order — if one hits quota or is unavailable, fall back to the next.
  static const _fallbackModels = [
    'gemini-1.5-flash', // Primary free-tier choice
    'gemini-2.0-flash', // Next-gen fast model
    'gemini-1.5-pro',   // High-quality fallback
  ];

  /// Whether the service has been initialized with a valid API key.
  bool get isInitialized => _isInitialized;

  /// Initializes the Gemini model with the provided API key.
  ///
  /// [modelName] defaults to 'gemini-1.5-flash' which is the primary
  /// free-tier model.
  void initialize(String apiKey, {String modelName = 'gemini-1.5-flash'}) {
    if (apiKey.isEmpty) {
      _isInitialized = false;
      return;
    }
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
You are an expert academic tutor. Summarize the following text for a student preparing for exams. 

STRICT REQUIREMENTS:
1. BE EXTREMELY CONCISE. The final summary must be under 150 words.
2. Use exactly 3-4 section headings with ## markdown formatting.
3. Highlight only the most CRITICAL technical terms in **bold**.
4. Use short, punchy bullet points.
5. Language: $language

DO NOT add any preamble. Start directly with the summary content.

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
  //  ACTIVE RECALL (CHECKPOINTS)
  // ──────────────────────────────────────────────────────────────────

  /// Generates a single tricky multiple-choice question based on the [text].
  ///
  /// Forces a specific format: Question | Option1 | Option2 | Option3 | Option4 | CorrectIndex (0-3)
  Future<RecallQuestion> generateRecallQuestion(String text) async {
    _ensureInitialized();

    final prompt = '''
You are a master educator testing a student's retention after speed-reading the following text.
Generate exactly ONE high-quality multiple-choice question.

STRICT REQUIREMENTS:
1. The question must test for a CRITICAL fact or concept from the text.
2. Provide exactly 4 options.
3. One option must be correct; three must be plausible but incorrect "distractors".
4. Output must be in this EXACT format (no preamble, no markdown):
QUESTION_START|Question Text|Option A|Option B|Option C|Option D|CorrectIndex(0-3)|QUESTION_END

TEXT:
$text
''';

    final response = await _generate(prompt);
    return _parseRecallQuestion(response);
  }

  RecallQuestion _parseRecallQuestion(String rawResponse) {
    try {
      final parts = rawResponse.split('|');
      if (parts.length < 7) throw Exception('Invalid format');
      
      return RecallQuestion(
        question: parts[1],
        options: [parts[2], parts[3], parts[4], parts[5]],
        correctIndex: int.parse(parts[6].replaceAll(RegExp(r'[^0-9]'), '')),
      );
    } catch (e) {
      // Fallback if parsing fails
      return RecallQuestion(
        question: 'What is the main topic of the text just read?',
        options: ['General Concept', 'Specific Detail', 'Technical Term', 'Introduction'],
        correctIndex: 0,
      );
    }
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
      // If it's a quota or model availability error, try fallback models
      if (_isFallbackWorthy(e)) {
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
      throw Exception(_getFriendlyErrorMessage(e.message));
    } catch (e) {
      throw Exception(_getFriendlyErrorMessage(e.toString()));
    }
  }

  /// Maps technical Gemini errors to simple, sweet messages.
  String _getFriendlyErrorMessage(String technicalError) {
    final msg = technicalError.toLowerCase();
    
    if (msg.contains('quota') || msg.contains('429')) {
      return 'Oops! Our AI is a bit busy right now. Please try again in 10-20 seconds!';
    }
    
    if (msg.contains('overloaded') || msg.contains('service unavailable') || msg.contains('503')) {
      return 'Oops! The server is a bit overcrowded at the moment. Please wait a few seconds and try again.';
    }

    if (msg.contains('invalid api key')) {
      return 'API Key issue detected. Please check your settings.';
    }

    return 'Oops! Something went wrong with the AI. Let\'s try that again in a moment.';
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
      'The Gemini API is currently unavailable or all models are at quota. '
      'Please check your API key at https://aistudio.google.com/apikey and try again later.',
    );
  }

  /// Returns true if the exception is worth trying a fallback model.
  bool _isFallbackWorthy(Exception e) {
    final msg = e.toString().toLowerCase();
    // Catch quota errors
    if (_isQuotaError(e)) return true;
    
    // Catch model naming/availability errors
    return msg.contains('not found') || 
           msg.contains('model') || 
           msg.contains('invalid') ||
           msg.contains('unavailable');
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

/// RecallQuestion is now defined in reader_state.dart to avoid duplicates.

