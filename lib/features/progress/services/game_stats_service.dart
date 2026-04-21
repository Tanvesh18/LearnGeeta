import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/models/game_stats.dart';
import '../repositories/game_stats_repository.dart';

class GameStatsService {
  GameStatsService({
    required IGameStatsRepository gameStatsRepository,
    required SharedPreferences prefs,
  }) : _gameStatsRepository = gameStatsRepository,
       _prefs = prefs;

  final IGameStatsRepository _gameStatsRepository;
  final SharedPreferences _prefs;

  Future<List<GameStats>> getAllGameStats() async {
    try {
      // Try to fetch from Supabase first
      final remoteStats = await _gameStatsRepository.fetchAllGameStats();
      if (remoteStats.isNotEmpty) {
        return remoteStats;
      }
    } catch (e) {
      // Fall back to local if Supabase fails
    }

    // Fall back to local SharedPreferences
    final stats = <GameStats>[];
    stats.add(await _getTrueFalseStats());
    stats.add(await _getDharmaChoicesStats());
    stats.add(await _getShlokaMatchStats());
    stats.add(await _getVerseOrderStats());
    stats.add(await _getKarmaPathStats());
    return stats;
  }

  Future<GameStats> getGameStats(String gameName) async {
    try {
      final remote = await _gameStatsRepository.fetchGameStats(gameName);
      if (remote != null) return remote;
    } catch (e) {
      // Fall back to local
    }

    // Local fallback
    switch (gameName) {
      case 'True False':
        return _getTrueFalseStats();
      case 'Dharma Choices':
        return _getDharmaChoicesStats();
      case 'Shloka Match':
        return _getShlokaMatchStats();
      case 'Verse Order':
        return _getVerseOrderStats();
      case 'Karma Path':
        return _getKarmaPathStats();
      default:
        return GameStats.empty('Unknown');
    }
  }

  Future<void> saveGameStats(GameStats stats) async {
    try {
      await _gameStatsRepository.saveGameStats(stats);
    } catch (e) {
      // If Supabase fails, save locally as backup
      await _saveLocally(stats);
    }
  }

  Future<GameStats> _getTrueFalseStats() async {
    return GameStats(
      gameName: 'True False',
      level: _prefs.getInt('trueFalseLevel') ?? 1,
      score: _prefs.getInt('trueFalseScore') ?? 0,
      maxStreak: _prefs.getInt('trueFalseMaxStreak') ?? 0,
      totalGames: _prefs.getInt('trueFalseTotal') ?? 0,
    );
  }

  Future<GameStats> _getDharmaChoicesStats() async {
    return GameStats(
      gameName: 'Dharma Choices',
      level: _prefs.getInt('dharmaLevel') ?? 1,
      score: _prefs.getInt('dharmaScore') ?? 0,
      maxStreak: _prefs.getInt('dharmaMaxStreak') ?? 0,
      totalGames: 0, // Not tracked
    );
  }

  Future<GameStats> _getShlokaMatchStats() async {
    final savedState = _prefs.getString('shlokaMatchGameState');
    if (savedState != null) {
      final map = savedState.split(',').asMap().entries.fold(
        <String, dynamic>{},
        (map, entry) {
          final parts = entry.value.split(':');
          if (parts.length == 2) {
            map[parts[0].trim()] = int.tryParse(parts[1].trim());
          }
          return map;
        },
      );
      return GameStats(
        gameName: 'Shloka Match',
        level: map['level'] ?? 1,
        score: map['score'] ?? 0,
        maxStreak: map['maxStreak'] ?? 0,
        totalGames: 0,
      );
    }
    return GameStats.empty('Shloka Match');
  }

  Future<GameStats> _getVerseOrderStats() async {
    final savedStateJson = _prefs.getString('verseOrderGameState');
    if (savedStateJson != null) {
      final map = Map<String, dynamic>.from(
        savedStateJson.split(',').asMap().entries.fold(<String, dynamic>{}, (
          map,
          entry,
        ) {
          final parts = entry.value.split(':');
          if (parts.length == 2) {
            map[parts[0].trim()] = int.tryParse(parts[1].trim());
          }
          return map;
        }),
      );
      return GameStats(
        gameName: 'Verse Order',
        level: map['level'] ?? 1,
        score: map['score'] ?? 0,
        maxStreak: map['maxStreak'] ?? 0,
        totalGames: 0,
      );
    }
    return GameStats.empty('Verse Order');
  }

  Future<GameStats> _getKarmaPathStats() async {
    return GameStats(
      gameName: 'Karma Path',
      level: 1, // Not leveled
      score: _prefs.getInt('karmaPathScore') ?? 0,
      maxStreak: 0,
      totalGames: _prefs.getInt('karmaPathTotal') ?? 0,
    );
  }

  Future<void> _saveLocally(GameStats stats) async {
    // This is a placeholder - in practice, you'd update the specific prefs keys
    // But since the games handle their own saving, this is mainly for fallback
  }
}
