import '../services/focus_service.dart';

/// Ephemeral and Persistent data model for an RSVP reading session.
///
/// This state manages the current text, reading position, and
/// AI-generated study aids.
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

  /// The original raw text before sanitization.
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

  // ── Active Recall (The Mastery Layer) ─────────────────────────────

  /// Whether we are currently showing an Active Recall prompt.
  final bool isRecallActive;

  /// The current AI-generated recall question.
  final String? recallQuestion;

  /// Multiple choice options for the recall question.
  final List<String> recallOptions;

  /// Index of the correct answer in [recallOptions].
  final int? recallCorrectIndex;

  /// Whether the user has answered the current recall question.
  final bool hasAnsweredRecall;

  /// Index of the user's selected option.
  final int? selectedRecallIndex;

  /// Number of words between recall prompts.
  final int recallInterval;

  // ── Multi-Modal (Audio) ───────────────────────────────────────────

  /// Current ambient sound selection.
  final FocusSound focusSound;

  /// Volume for ambient sound (0.0 to 1.0).
  final double focusVolume;

  /// Whether bimodal reading (Audio TTS) is enabled.
  final bool isTtsEnabled;

  // ── Focus Sprints (Gamification) ──────────────────────────────────

  /// Whether a timed Focus Sprint is active.
  final bool isSprintActive;

  /// Time remaining in the current sprint (in seconds).
  final int sprintTimeRemaining;

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
    this.isRecallActive = false,
    this.recallQuestion,
    this.recallOptions = const [],
    this.recallCorrectIndex,
    this.hasAnsweredRecall = false,
    this.selectedRecallIndex,
    this.recallInterval = 200,
    this.focusSound = FocusSound.none,
    this.focusVolume = 0.5,
    this.isTtsEnabled = false,
    this.isSprintActive = false,
    this.sprintTimeRemaining = 1500, // Default 25m
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
    bool? isRecallActive,
    String? recallQuestion,
    List<String>? recallOptions,
    int? recallCorrectIndex,
    bool? hasAnsweredRecall,
    int? selectedRecallIndex,
    int? recallInterval,
    // Sentinel values to allow setting nullable fields to null
    bool clearSummary = false,
    bool clearVivaQuestions = false,
    bool clearAiError = false,
    bool clearRecall = false,
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
      isRecallActive: isRecallActive ?? this.isRecallActive,
      recallQuestion: clearRecall ? null : (recallQuestion ?? this.recallQuestion),
      recallOptions: clearRecall ? const [] : (recallOptions ?? this.recallOptions),
      recallCorrectIndex: clearRecall ? null : (recallCorrectIndex ?? this.recallCorrectIndex),
      hasAnsweredRecall: clearRecall ? false : (hasAnsweredRecall ?? this.hasAnsweredRecall),
      selectedRecallIndex: clearRecall ? null : (selectedRecallIndex ?? this.selectedRecallIndex),
      recallInterval: recallInterval ?? this.recallInterval,
      focusSound: focusSound ?? this.focusSound,
      focusVolume: focusVolume ?? this.focusVolume,
      isTtsEnabled: isTtsEnabled ?? this.isTtsEnabled,
      isSprintActive: isSprintActive ?? this.isSprintActive,
      sprintTimeRemaining: sprintTimeRemaining ?? this.sprintTimeRemaining,
    );
  }

  /// Formatted sprint time (MM:SS).
  String get sprintTimeFormatted {
    final minutes = sprintTimeRemaining ~/ 60;
    final seconds = sprintTimeRemaining % 60;
    return '${minutes.toString().padLeft(2, "0")}:${seconds.toString().padLeft(2, "0")}';
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
