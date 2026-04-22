import '../../../core/models/game_stats.dart';
import '../repositories/game_stats_repository.dart';

class GameStatsService {
  GameStatsService({required IGameStatsRepository gameStatsRepository})
    : _gameStatsRepository = gameStatsRepository;

  final IGameStatsRepository _gameStatsRepository;

  Future<List<GameStats>> getAllGameStats() async {
    final remoteStats = await _gameStatsRepository.fetchAllGameStats();
    final visibleStats = remoteStats.toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    return visibleStats;
  }

  Future<GameStats> getGameStats(String gameName) async {
    final remote = await _gameStatsRepository.fetchGameStats(gameName);
    return remote ?? GameStats.empty(gameName);
  }

  Future<void> saveGameStats(GameStats stats) async {
    await _gameStatsRepository.saveGameStats(stats);
  }
}
