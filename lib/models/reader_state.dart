import '../services/focus_service.dart';

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

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'correctIndex': correctIndex,
    };
  }

  factory RecallQuestion.fromMap(Map<dynamic, dynamic> map) {
    return RecallQuestion(
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctIndex: map['correctIndex'] ?? 0,
    );
  }
}

class InteractiveQuiz {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final int? selectedIndex;

  InteractiveQuiz({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.selectedIndex,
  });

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'correctIndex': correctIndex,
      'explanation': explanation,
    };
  }

  factory InteractiveQuiz.fromMap(Map<dynamic, dynamic> map) {
    return InteractiveQuiz(
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctIndex: map['correctIndex'] ?? 0,
      explanation: map['explanation'] ?? '',
    );
  }

  InteractiveQuiz copyWith({int? selectedIndex}) {
    return InteractiveQuiz(
      question: question,
      options: options,
      correctIndex: correctIndex,
      explanation: explanation,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }
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
  final List<InteractiveQuiz>? quizzes;
  final bool isSummaryLoading;
  final bool isVivaLoading;
  final bool isQuizLoading;
  final String? aiError;

  final bool isRecallActive;
  final String? recallQuestion;
  final List<String> recallOptions;
  final int? recallCorrectIndex;
  final bool hasAnsweredRecall;
  final int? selectedRecallIndex;
  
  final int recallInterval;
  final int lastRecallIndex;
  final int recallCount;
  final String recallDifficulty;
  final List<RecallQuestion>? preGeneratedRecalls;
  final Set<int> recallTriggeredIndices;
  final Map<String, DateTime> shownAnnouncements;
  final FocusSound focusSound;
  final double focusVolume;
  final bool isListening;
  final bool isSprintActive;
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
    this.quizzes,
    this.isSummaryLoading = false,
    this.isVivaLoading = false,
    this.isQuizLoading = false,
    this.aiError,
    this.isRecallActive = false,
    this.recallQuestion,
    this.recallOptions = const [],
    this.recallCorrectIndex,
    this.hasAnsweredRecall = false,
    this.selectedRecallIndex,
    this.recallInterval = 200,
    this.lastRecallIndex = -1,
    this.recallCount = 5,
    this.recallDifficulty = 'Intermediate',
    this.preGeneratedRecalls,
    this.recallTriggeredIndices = const {},
    this.shownAnnouncements = const {},
    this.focusSound = FocusSound.none,
    this.focusVolume = 0.5,
    this.isListening = false,
    this.isSprintActive = false,
    this.sprintTimeRemaining = 1500,
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
    List<InteractiveQuiz>? quizzes,
    bool? isSummaryLoading,
    bool? isVivaLoading,
    bool? isQuizLoading,
    String? aiError,
    bool? isRecallActive,
    String? recallQuestion,
    List<String>? recallOptions,
    int? recallCorrectIndex,
    bool? hasAnsweredRecall,
    int? selectedRecallIndex,
    int? recallInterval,
    int? lastRecallIndex,
    int? recallCount,
    String? recallDifficulty,
    List<RecallQuestion>? preGeneratedRecalls,
    Set<int>? recallTriggeredIndices,
    Map<String, DateTime>? shownAnnouncements,
    FocusSound? focusSound,
    double? focusVolume,
    bool? isListening,
    bool? isSprintActive,
    int? sprintTimeRemaining,
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
      quizzes: quizzes ?? this.quizzes,
      isSummaryLoading: isSummaryLoading ?? this.isSummaryLoading,
      isVivaLoading: isVivaLoading ?? this.isVivaLoading,
      isQuizLoading: isQuizLoading ?? this.isQuizLoading,
      aiError: clearAiError ? null : (aiError ?? this.aiError),
      isRecallActive: isRecallActive ?? this.isRecallActive,
      recallQuestion: clearRecall ? null : (recallQuestion ?? this.recallQuestion),
      recallOptions: clearRecall ? const [] : (recallOptions ?? this.recallOptions),
      recallCorrectIndex: clearRecall ? null : (recallCorrectIndex ?? this.recallCorrectIndex),
      hasAnsweredRecall: clearRecall ? false : (hasAnsweredRecall ?? this.hasAnsweredRecall),
      selectedRecallIndex: clearRecall ? null : (selectedRecallIndex ?? this.selectedRecallIndex),
      recallInterval: recallInterval ?? this.recallInterval,
      lastRecallIndex: lastRecallIndex ?? this.lastRecallIndex,
      recallCount: recallCount ?? this.recallCount,
      recallDifficulty: recallDifficulty ?? this.recallDifficulty,
      preGeneratedRecalls: preGeneratedRecalls ?? this.preGeneratedRecalls,
      recallTriggeredIndices: recallTriggeredIndices ?? this.recallTriggeredIndices,
      shownAnnouncements: shownAnnouncements ?? this.shownAnnouncements,
      focusSound: focusSound ?? this.focusSound,
      focusVolume: focusVolume ?? this.focusVolume,
      isListening: isListening ?? this.isListening,
      isSprintActive: isSprintActive ?? this.isSprintActive,
      sprintTimeRemaining: sprintTimeRemaining ?? this.sprintTimeRemaining,
    );
  }

  String get sprintTimeFormatted {
    final minutes = sprintTimeRemaining ~/ 60;
    final seconds = sprintTimeRemaining % 60;
    return '${minutes.toString().padLeft(2, "0")}:${seconds.toString().padLeft(2, "0")}';
  }

  String get estimatedRemainingTimeFormatted {
    final remainingWords = words.length - currentIndex;
    if (remainingWords <= 0) return '0 min';
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
