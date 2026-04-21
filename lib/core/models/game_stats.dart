class GameStats {
  const GameStats({
    required this.gameName,
    required this.level,
    required this.score,
    required this.maxStreak,
    this.totalGames = 0,
    this.lastPlayed,
  });

  final String gameName;
  final int level;
  final int score;
  final int maxStreak;
  final int totalGames;
  final DateTime? lastPlayed;

  factory GameStats.fromMap(Map<String, dynamic> map) {
    return GameStats(
      gameName: map['game_name'] as String,
      level: (map['level'] as num?)?.toInt() ?? 1,
      score: (map['score'] as num?)?.toInt() ?? 0,
      maxStreak: (map['max_streak'] as num?)?.toInt() ?? 0,
      totalGames: (map['total_games'] as num?)?.toInt() ?? 0,
      lastPlayed: map['last_played'] == null
          ? null
          : DateTime.tryParse(map['last_played'] as String),
    );
  }

  factory GameStats.empty(String gameName) {
    return GameStats(
      gameName: gameName,
      level: 1,
      score: 0,
      maxStreak: 0,
      totalGames: 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'game_name': gameName,
      'level': level,
      'score': score,
      'max_streak': maxStreak,
      'total_games': totalGames,
      'last_played': lastPlayed?.toIso8601String(),
    };
  }

  GameStats copyWith({
    String? gameName,
    int? level,
    int? score,
    int? maxStreak,
    int? totalGames,
    DateTime? lastPlayed,
  }) {
    return GameStats(
      gameName: gameName ?? this.gameName,
      level: level ?? this.level,
      score: score ?? this.score,
      maxStreak: maxStreak ?? this.maxStreak,
      totalGames: totalGames ?? this.totalGames,
      lastPlayed: lastPlayed ?? this.lastPlayed,
    );
  }
}
