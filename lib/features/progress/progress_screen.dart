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
  ProgressRepository? _progressRepository;
  GameStatsRepository? _gameStatsRepository;
  GameStatsService? _gameStatsService;
  AchievementsService? _achievementsService;
  SharedPreferences? _prefs;
  bool _servicesReady = false;
  Future<ProgressData>? _dataFuture;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    _progressRepository = ProgressRepository();
    _gameStatsRepository = GameStatsRepository();
    _prefs = await SharedPreferences.getInstance();
    _gameStatsService = GameStatsService(gameStatsRepository: _gameStatsRepository!, prefs: _prefs!);
    _achievementsService = AchievementsService();
    setState(() {
      _servicesReady = true;
      _dataFuture = _loadData();
    });
  }

  Future<ProgressData> _loadData() async {
    final progress = await _progressRepository!.fetchProgress();
    final gameStats = await _gameStatsService!.getAllGameStats();
    final achievements = _achievementsService!.getAchievements(progress, gameStats);
    return ProgressData(progress, gameStats, achievements);
  }

  @override
  Widget build(BuildContext context) {
    return AppGradientScaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('My Progress'),
        backgroundColor: AppColors.saffron,
        foregroundColor: Colors.white,
      ),
      body: !_servicesReady
          ? const Center(child: CircularProgressIndicator(color: AppColors.saffron))
          : FutureBuilder<ProgressData>(
              future: _dataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.saffron));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                return _buildContent(snapshot.data!);
              },
            ),
    );
  }

  Widget _buildContent(ProgressData data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLevelCard(data.progress),
          const SizedBox(height: 16),
          _buildStreakCard(data.progress),
          const SizedBox(height: 24),
          _buildSectionHeader('Games'),
          const SizedBox(height: 12),
          if (data.gameStats.isEmpty)
            _buildEmptyState('No games played yet. Start playing to track your progress!')
          else
            ...data.gameStats.map((stat) => _buildGameStatCard(stat)),
          const SizedBox(height: 24),
          _buildSectionHeader(
            'Achievements (${data.achievements.where((a) => a.unlocked).length}/${data.achievements.length})',
          ),
          const SizedBox(height: 12),
          _buildAchievementsGrid(data.achievements),
        ],
      ),
    );
  }

  Widget _buildLevelCard(UserProgress progress) {
    final xpProgress = progress.xp % XpPolicy.xpPerLevel;
    final progressValue = xpProgress / XpPolicy.xpPerLevel;
    final title = XpPolicy.titleForLevel(progress.level);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.saffron, AppColors.deepBrown],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.saffron.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${progress.level}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Level', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${progress.xp} total XP',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$xpProgress / ${XpPolicy.xpPerLevel} XP to next level',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                '${(progressValue * 100).toStringAsFixed(0)}%',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(UserProgress progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.saffron.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Center(child: Text('🔥', style: TextStyle(fontSize: 28))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Daily Streak', style: TextStyle(fontSize: 13, color: Colors.grey)),
                Text(
                  '${progress.streak} ${progress.streak == 1 ? 'day' : 'days'}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.deepBrown),
                ),
              ],
            ),
          ),
          if (progress.lastActive != null)
            Text(
              'Last: ${progress.lastActive!.toLocal().toString().split(' ')[0]}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.deepBrown,
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
      ),
    );
  }

  Widget _buildGameStatCard(GameStats stat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.saffron.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text(_gameIcon(stat.gameName), style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stat.gameName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _statChip('Lvl ${stat.level}', AppColors.saffron.withValues(alpha: 0.15), AppColors.deepBrown),
                    const SizedBox(width: 6),
                    _statChip('${stat.score} pts', AppColors.gradientEnd, AppColors.deepBrown),
                    if (stat.maxStreak > 0) ...[
                      const SizedBox(width: 6),
                      _statChip('🔥 ${stat.maxStreak}', Colors.orange.withValues(alpha: 0.12), Colors.orange.shade700),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
    );
  }

  String _gameIcon(String gameName) {
    switch (gameName) {
      case 'True False': return '⚖️';
      case 'Verse Order': return '📜';
      case 'Shloka Match': return '🔗';
      case 'Wheel of Gunas': return '🔄';
      case 'Dharma Choices': return '🧭';
      case 'Krishna Says': return '🪈';
      case 'Chapter Quest': return '📚';
      case 'Missing Word Mantra': return '🔤';
      case 'Shloka Speed Run': return '⚡';
      case 'Karma Path': return '🛤️';
      case 'Krishna Memory Cards': return '🃏';
      case 'Battlefield Debate': return '🏹';
      default: return '🎮';
    }
  }

  Widget _buildAchievementsGrid(List<Achievement> achievements) {
    final unlocked = achievements.where((a) => a.unlocked).toList();
    final locked = achievements.where((a) => !a.unlocked).toList();

    return Column(
      children: [
        ...unlocked.map((a) => _buildAchievementCard(a)),
        if (locked.isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(child: Divider(color: Colors.grey.shade300)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('${locked.length} locked', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ),
                Expanded(child: Divider(color: Colors.grey.shade300)),
              ],
            ),
          ),
          ...locked.map((a) => _buildAchievementCard(a)),
        ],
      ],
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: achievement.unlocked ? Colors.white : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: achievement.unlocked
            ? Border.all(color: AppColors.gold.withValues(alpha: 0.4))
            : Border.all(color: Colors.grey.shade200),
        boxShadow: achievement.unlocked
            ? [BoxShadow(color: AppColors.gold.withValues(alpha: 0.1), blurRadius: 6, offset: const Offset(0, 2))]
            : null,
      ),
      child: Row(
        children: [
          Text(
            achievement.unlocked ? achievement.emoji : '🔒',
            style: TextStyle(fontSize: 28, color: achievement.unlocked ? null : const Color(0xFFCCCCCC)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: achievement.unlocked ? AppColors.deepBrown : Colors.grey,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: achievement.unlocked ? Colors.grey.shade600 : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
          if (achievement.unlocked)
            const Icon(Icons.check_circle, color: AppColors.gold, size: 20),
        ],
      ),
    );
  }
}

class ProgressData {
  final UserProgress progress;
  final List<GameStats> gameStats;
  final List<Achievement> achievements;

  ProgressData(this.progress, this.gameStats, this.achievements);
}
