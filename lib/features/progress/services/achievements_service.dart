import 'package:learngeetagames/core/models/user_progress.dart';
import 'package:learngeetagames/core/models/game_stats.dart';
import '../models/achievement.dart';

class AchievementsService {
  List<Achievement> getAchievements(UserProgress progress, List<GameStats> gameStats) {
    final achievements = <Achievement>[];

    achievements.add(Achievement(emoji: '🌱', title: 'Beginner', description: 'Start your journey — reach level 1', unlocked: progress.level >= 1));
    achievements.add(Achievement(emoji: '🔍', title: 'Seeker', description: 'Deepen your study — reach level 7', unlocked: progress.level >= 7));
    achievements.add(Achievement(emoji: '📖', title: 'Disciple', description: 'Walk the path — reach level 15', unlocked: progress.level >= 15));
    achievements.add(Achievement(emoji: '🧘', title: 'Yogi', description: 'Still the mind — reach level 25', unlocked: progress.level >= 25));
    achievements.add(Achievement(emoji: '🌟', title: 'Sage', description: 'Attain wisdom — reach level 40', unlocked: progress.level >= 40));
    achievements.add(Achievement(emoji: '🔱', title: 'Karma Master', description: 'Act without attachment — reach level 60', unlocked: progress.level >= 60));
    achievements.add(Achievement(emoji: '🪷', title: 'Gita Guardian', description: 'Embody the teaching — reach level 100', unlocked: progress.level >= 100));

    achievements.add(Achievement(emoji: '🔥', title: 'Consistent Learner', description: 'Maintain a 7-day streak', unlocked: progress.streak >= 7));
    achievements.add(Achievement(emoji: '💎', title: 'Dedicated Student', description: 'Maintain a 30-day streak', unlocked: progress.streak >= 30));

    final totalGames = gameStats.fold<int>(0, (sum, stat) => sum + stat.totalGames);
    achievements.add(Achievement(emoji: '🎮', title: 'First Steps', description: 'Play your first 10 games', unlocked: totalGames >= 10));
    achievements.add(Achievement(emoji: '✨', title: 'Enlightened', description: 'Play 100 games across all modes', unlocked: totalGames >= 100));

    final maxLevel = gameStats.isEmpty ? 0 : gameStats.map((s) => s.level).reduce((a, b) => a > b ? a : b);
    achievements.add(Achievement(emoji: '🏆', title: 'Game Master', description: 'Reach level 10 in any game', unlocked: maxLevel >= 10));

    return achievements;
  }
}
