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
  final List<ArenaPlayer> players;
  final bool isStarted;
  final int currentQuestionIndex;
  final DateTime? startTime;

  const ArenaRoom({
    required this.id,
    required this.hostId,
    required this.documentTitle,
    this.players = const [],
    this.isStarted = false,
    this.currentQuestionIndex = 0,
    this.startTime,
  });
}
