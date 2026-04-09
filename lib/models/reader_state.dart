/// Ephemeral data model for a single RSVP reading session.
///
/// This state lives only for the current browser tab session.
/// Closing the tab resets everything — no persistence layer is used.
class ReaderState {
  /// The tokenized list of words to display.
  final List<String> words;

  /// Index of the currently displayed word in [words].
  final int currentIndex;

  /// Reading speed in Words Per Minute.
  final int wpm;

  /// Font size for the RSVP display in logical pixels.
  final double fontSize;

  /// Whether the RSVP engine is currently advancing words.
  final bool isPlaying;

  /// Whether the app is in reading mode (vs. input dashboard).
  final bool isReading;

  /// Name of the loaded file (null if text was pasted directly).
  final String? fileName;

  // ── AI Study Tools ────────────────────────────────────────────────

  /// The original raw text before sanitization (sent to Gemini as-is
  /// for better context than tokenized words).
  final String rawText;

  /// AI-generated summary text (markdown-formatted).
  final String? summary;

  /// AI-generated viva/exam questions and answers (markdown-formatted).
  final String? vivaQuestions;

  /// Whether a summary generation request is in progress.
  final bool isSummaryLoading;

  /// Whether a viva questions generation request is in progress.
  final bool isVivaLoading;

  /// Error message from the last AI operation (null if no error).
  final String? aiError;

  const ReaderState({
    this.words = const [],
    this.currentIndex = 0,
    this.wpm = 300,
    this.fontSize = 48.0,
    this.isPlaying = false,
    this.isReading = false,
    this.fileName,
    this.rawText = '',
    this.summary,
    this.vivaQuestions,
    this.isSummaryLoading = false,
    this.isVivaLoading = false,
    this.aiError,
  });

  /// Creates a copy of this state with the specified fields overridden.
  ReaderState copyWith({
    List<String>? words,
    int? currentIndex,
    int? wpm,
    double? fontSize,
    bool? isPlaying,
    bool? isReading,
    String? fileName,
    String? rawText,
    String? summary,
    String? vivaQuestions,
    bool? isSummaryLoading,
    bool? isVivaLoading,
    String? aiError,
    // Sentinel values to allow setting nullable fields to null
    bool clearSummary = false,
    bool clearVivaQuestions = false,
    bool clearAiError = false,
  }) {
    return ReaderState(
      words: words ?? this.words,
      currentIndex: currentIndex ?? this.currentIndex,
      wpm: wpm ?? this.wpm,
      fontSize: fontSize ?? this.fontSize,
      isPlaying: isPlaying ?? this.isPlaying,
      isReading: isReading ?? this.isReading,
      fileName: fileName ?? this.fileName,
      rawText: rawText ?? this.rawText,
      summary: clearSummary ? null : (summary ?? this.summary),
      vivaQuestions: clearVivaQuestions ? null : (vivaQuestions ?? this.vivaQuestions),
      isSummaryLoading: isSummaryLoading ?? this.isSummaryLoading,
      isVivaLoading: isVivaLoading ?? this.isVivaLoading,
      aiError: clearAiError ? null : (aiError ?? this.aiError),
    );
  }

  /// Whether any text has been loaded (from paste or file upload).
  bool get hasContent => words.isNotEmpty;

  /// Total number of words in the loaded text.
  int get totalWords => words.length;

  /// The currently active word, or empty string if no words loaded.
  String get currentWord =>
      (currentIndex >= 0 && currentIndex < words.length)
          ? words[currentIndex]
          : '';

  /// Reading progress as a fraction from 0.0 to 1.0.
  double get progress =>
      words.isEmpty ? 0.0 : (currentIndex + 1) / words.length;

  /// Estimated total reading time in seconds at the current WPM.
  double get estimatedTimeSeconds => words.isEmpty ? 0 : words.length / wpm * 60;

  /// Formatted estimated reading time (e.g., "2m 30s").
  String get estimatedTimeFormatted {
    final totalSeconds = estimatedTimeSeconds.round();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    if (minutes == 0) return '${seconds}s';
    return '${minutes}m ${seconds}s';
  }
}
