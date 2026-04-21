import 'package:flutter/material.dart';

import 'package:learngeetagames/core/constants/colors.dart';
import 'package:learngeetagames/core/models/game_stats.dart';
import 'package:learngeetagames/core/models/user_progress.dart';
import 'package:learngeetagames/core/utils/xp_policy.dart';
import 'package:learngeetagames/core/widgets/app_gradient_scaffold.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/achievement.dart';
import 'progress_repository.dart';
import 'repositories/game_stats_repository.dart';
import 'services/achievements_service.dart';
import 'services/game_stats_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late final ProgressRepository _progressRepository;
  late final GameStatsRepository _gameStatsRepository;
  late final GameStatsService _gameStatsService;
  late final AchievementsService _achievementsService;
  late final SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    _progressRepository = ProgressRepository();
    _gameStatsRepository = GameStatsRepository();
    _prefs = await SharedPreferences.getInstance();
    _gameStatsService = GameStatsService(
      gameStatsRepository: _gameStatsRepository,
      prefs: _prefs,
    );
    _achievementsService = AchievementsService();
    setState(() {}); // Trigger rebuild after init
  }

  @override
  Widget build(BuildContext context) {
    return AppGradientScaffold(
      appBar: AppBar(centerTitle: true, title: const Text('Progress')),
      body: FutureBuilder(
        future: _loadData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final data = snapshot.data!;
          return _buildContent(data);
        },
      ),
    );
  }

  Future<ProgressData> _loadData() async {
    final progress = await _progressRepository.fetchProgress();
    final gameStats = await _gameStatsService.getAllGameStats();
    final achievements = _achievementsService.getAchievements(
      progress,
      gameStats,
    );
    return ProgressData(progress, gameStats, achievements);
  }

  Widget _buildContent(ProgressData data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLevelSection(data.progress),
          const SizedBox(height: 24),
          _buildStreakSection(data.progress),
          const SizedBox(height: 24),
          _buildGameStatsSection(data.gameStats),
          const SizedBox(height: 24),
          _buildAchievementsSection(data.achievements),
        ],
      ),
    );
  }

  Widget _buildLevelSection(UserProgress progress) {
    final xpProgress = progress.xp % XpPolicy.xpPerLevel;
    final progressValue = xpProgress / XpPolicy.xpPerLevel;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Level ${progress.level}: ${XpPolicy.titleForLevel(progress.level)}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('XP: ${progress.xp}'),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progressValue,
              backgroundColor: AppColors.cream.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
            ),
            const SizedBox(height: 4),
            Text('$xpProgress/${XpPolicy.xpPerLevel} to next level'),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakSection(UserProgress progress) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Daily Streak',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '${progress.streak} days',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: AppColors.saffron),
            ),
            if (progress.lastActive != null)
              Text(
                'Last active: ${progress.lastActive!.toLocal().toString().split(' ')[0]}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameStatsSection(List<GameStats> gameStats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Game Statistics',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        ...gameStats.map(
          (stat) => Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(stat.gameName),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Level: ${stat.level}'),
                      Text('Score: ${stat.score}'),
                      if (stat.maxStreak > 0)
                        Text('Max Streak: ${stat.maxStreak}'),
                      if (stat.totalGames > 0)
                        Text('Games: ${stat.totalGames}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsSection(List<Achievement> achievements) {
    final unlocked = achievements.where((a) => a.unlocked).toList();
    final locked = achievements.where((a) => !a.unlocked).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Achievements (${unlocked.length}/${achievements.length})',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        ...unlocked.map(
          (achievement) => Card(
            color: AppColors.gold.withOpacity(0.1),
            child: ListTile(
              leading: const Icon(Icons.star, color: AppColors.gold),
              title: Text(achievement.title),
              subtitle: Text(achievement.description),
            ),
          ),
        ),
        ...locked.map(
          (achievement) => Card(
            child: ListTile(
              leading: Icon(Icons.star_border, color: Colors.grey),
              title: Text(achievement.title),
              subtitle: Text(achievement.description),
            ),
          ),
        ),
      ],
    );
  }
}

class ProgressData {
  final UserProgress progress;
  final List<GameStats> gameStats;
  final List<Achievement> achievements;

  ProgressData(this.progress, this.gameStats, this.achievements);
}
