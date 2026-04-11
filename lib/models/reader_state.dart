import '../services/focus_service.dart';

enum AiProvider { gemini, openRouter }

/// Simple DTO for Active Recall questions.
class RecallQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  const RecallQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}

/// Ephemeral and Persistent data model for an RSVP reading session.
class ReaderState {
  final List<String> words;
  final int currentIndex;
  final int wpm;
  final double fontSize;
  final bool isPlaying;
  final bool isReading;
  final String? fileName;
  final String rawText;
  
  final String? summary;
  final String? vivaQuestions;
  final bool isSummaryLoading;
  final bool isVivaLoading;
  final String? aiError;

  final bool isRecallActive;
  final String? recallQuestion;
  final List<String> recallOptions;
  final int? recallCorrectIndex;
  final bool hasAnsweredRecall;
  final int? selectedRecallIndex;
  
  final int recallInterval;
  final FocusSound focusSound;
  final double focusVolume;
  final bool isTtsEnabled;
  final bool isSprintActive;
  final int sprintTimeRemaining;
  final AiProvider aiProvider;

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
    this.sprintTimeRemaining = 1500,
    this.aiProvider = AiProvider.gemini,
  });

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
    FocusSound? focusSound,
    double? focusVolume,
    bool? isTtsEnabled,
    bool? isSprintActive,
    int? sprintTimeRemaining,
    AiProvider? aiProvider,
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
      aiProvider: aiProvider ?? this.aiProvider,
    );
  }

  String get sprintTimeFormatted {
    final minutes = sprintTimeRemaining ~/ 60;
    final seconds = sprintTimeRemaining % 60;
    return '${minutes.toString().padLeft(2, "0")}:${seconds.toString().padLeft(2, "0")}';
  }

  String get estimatedTimeFormatted {
    final remainingWords = words.length - currentIndex;
    final totalSeconds = (remainingWords / wpm * 60).round();
    final minutes = totalSeconds ~/ 60;
    if (minutes < 1) return '< 1 min';
    return '$minutes min';
  }

  bool get hasContent => words.isNotEmpty;
  int get totalWords => words.length;
  String get currentWord => currentIndex < words.length ? words[currentIndex] : '';
  double get progress => totalWords > 0 ? currentIndex / totalWords : 0.0;
}
