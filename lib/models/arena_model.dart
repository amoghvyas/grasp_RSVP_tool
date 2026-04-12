import 'reader_state.dart';

enum PlayerStatus { waiting, playing, finished }

class ArenaPlayer {
  final String id;
  final String name;
  final int score;
  final int correctAnswers;
  final Duration totalTime;
  final PlayerStatus status;

  const ArenaPlayer({
    required this.id,
    required this.name,
    this.score = 0,
    this.correctAnswers = 0,
    this.totalTime = Duration.zero,
    this.status = PlayerStatus.waiting,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'score': score,
    'correctAnswers': correctAnswers,
    'totalTimeMs': totalTime.inMilliseconds,
    'status': status.name,
  };

  factory ArenaPlayer.fromMap(Map<dynamic, dynamic> map) => ArenaPlayer(
    id: map['id'] ?? '',
    name: map['name'] ?? '',
    score: map['score'] ?? 0,
    correctAnswers: map['correctAnswers'] ?? 0,
    totalTime: Duration(milliseconds: map['totalTimeMs'] ?? 0),
    status: PlayerStatus.values.firstWhere((e) => e.name == map['status'], orElse: () => PlayerStatus.waiting),
  );

  ArenaPlayer copyWith({
    int? score,
    int? correctAnswers,
    Duration? totalTime,
    PlayerStatus? status,
  }) {
    return ArenaPlayer(
      id: id,
      name: name,
      score: score ?? this.score,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalTime: totalTime ?? this.totalTime,
      status: status ?? this.status,
    );
  }
}

class ArenaRoom {
  final String id;
  final String hostId;
  final String documentTitle;
  final String? secretKey;
  final List<ArenaPlayer> players;
  final bool isStarted;
  final int currentQuestionIndex;
  final int? startTimeMs;
  final List<InteractiveQuiz> questions;

  const ArenaRoom({
    required this.id,
    required this.hostId,
    required this.documentTitle,
    this.secretKey,
    this.players = const [],
    this.isStarted = false,
    this.currentQuestionIndex = 0,
    this.startTimeMs,
    this.questions = const [],
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'hostId': hostId,
    'documentTitle': documentTitle,
    'secretKey': secretKey,
    'players': { for (var p in players) p.id : p.toMap() },
    'isStarted': isStarted,
    'currentQuestionIndex': currentQuestionIndex,
    'startTimeMs': startTimeMs,
    'questions': questions.map((q) => {
      'question': q.question,
      'options': q.options,
      'correctIndex': q.correctIndex,
      'explanation': q.explanation,
    }).toList(),
  };

  factory ArenaRoom.fromMap(Map<dynamic, dynamic> map) {
    final playersMap = map['players'] as Map<dynamic, dynamic>? ?? {};
    final questionsList = map['questions'] as List<dynamic>? ?? [];
    
    return ArenaRoom(
      id: map['id'] ?? '',
      hostId: map['hostId'] ?? '',
      documentTitle: map['documentTitle'] ?? '',
      secretKey: map['secretKey'],
      players: playersMap.values.map((p) => ArenaPlayer.fromMap(p)).toList(),
      isStarted: map['isStarted'] ?? false,
      currentQuestionIndex: map['currentQuestionIndex'] ?? 0,
      startTimeMs: map['startTimeMs'],
      questions: questionsList.map((q) => InteractiveQuiz(
        question: q['question'],
        options: List<String>.from(q['options']),
        correctIndex: q['correctIndex'],
        explanation: q['explanation'],
      )).toList(),
    );
  }

  ArenaRoom copyWith({
    String? documentTitle,
    bool? isStarted,
    int? currentQuestionIndex,
    int? startTimeMs,
    List<ArenaPlayer>? players,
  }) {
    return ArenaRoom(
      id: id,
      hostId: hostId,
      documentTitle: documentTitle ?? this.documentTitle,
      secretKey: secretKey,
      players: players ?? this.players,
      isStarted: isStarted ?? this.isStarted,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      startTimeMs: startTimeMs ?? this.startTimeMs,
      questions: questions,
    );
  }
}
