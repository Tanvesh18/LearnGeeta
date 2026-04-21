import 'package:learngeetagames/core/models/user_progress.dart';
import 'package:learngeetagames/core/models/game_stats.dart';
import '../models/achievement.dart';

class AchievementsService {
  List<Achievement> getAchievements(
    UserProgress progress,
    List<GameStats> gameStats,
  ) {
    final achievements = <Achievement>[];

    // Level-based
    achievements.add(
      Achievement(
        title: 'Beginner',
        description: 'Reach level 1',
        unlocked: progress.level >= 1,
      ),
    );
    achievements.add(
      Achievement(
        title: 'Seeker',
        description: 'Reach level 7',
        unlocked: progress.level >= 7,
      ),
    );
    achievements.add(
      Achievement(
        title: 'Disciple',
        description: 'Reach level 15',
        unlocked: progress.level >= 15,
      ),
    );
    achievements.add(
      Achievement(
        title: 'Yogi',
        description: 'Reach level 25',
        unlocked: progress.level >= 25,
      ),
    );
    achievements.add(
      Achievement(
        title: 'Sage',
        description: 'Reach level 40',
        unlocked: progress.level >= 40,
      ),
    );
    achievements.add(
      Achievement(
        title: 'Karma Master',
        description: 'Reach level 60',
        unlocked: progress.level >= 60,
      ),
    );
    achievements.add(
      Achievement(
        title: 'Gita Guardian',
        description: 'Reach level 100',
        unlocked: progress.level >= 100,
      ),
    );

    // Streak-based
    achievements.add(
      Achievement(
        title: 'Consistent Learner',
        description: 'Maintain a 7-day streak',
        unlocked: progress.streak >= 7,
      ),
    );
    achievements.add(
      Achievement(
        title: 'Dedicated Student',
        description: 'Maintain a 30-day streak',
        unlocked: progress.streak >= 30,
      ),
    );

    // Game-specific
    final totalGames = gameStats.fold<int>(
      0,
      (sum, stat) => sum + stat.totalGames,
    );
    achievements.add(
      Achievement(
        title: 'First Steps',
        description: 'Play 10 games',
        unlocked: totalGames >= 10,
      ),
    );
    achievements.add(
      Achievement(
        title: 'Enlightened',
        description: 'Play 100 games',
        unlocked: totalGames >= 100,
      ),
    );

    final maxLevel = gameStats
        .map((s) => s.level)
        .reduce((a, b) => a > b ? a : b);
    achievements.add(
      Achievement(
        title: 'Game Master',
        description: 'Reach level 10 in any game',
        unlocked: maxLevel >= 10,
      ),
    );

    return achievements;
  }
}
