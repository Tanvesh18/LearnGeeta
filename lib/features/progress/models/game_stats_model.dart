class GameStats {
  final String gameName;
  final int level;
  final int score;
  final int maxStreak;
  final int totalGames; // If available

  const GameStats({
    required this.gameName,
    required this.level,
    required this.score,
    required this.maxStreak,
    this.totalGames = 0,
  });

  factory GameStats.empty(String gameName) {
    return GameStats(
      gameName: gameName,
      level: 1,
      score: 0,
      maxStreak: 0,
      totalGames: 0,
    );
  }
}

class Achievement {
  final String title;
  final String description;
  final bool unlocked;

  const Achievement({
    required this.title,
    required this.description,
    required this.unlocked,
  });
}
