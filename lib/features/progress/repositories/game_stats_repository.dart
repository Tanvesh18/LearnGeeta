import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

import '../../../core/models/game_stats.dart';

abstract class IGameStatsRepository {
  Future<GameStats?> fetchGameStats(String gameName);

  Future<void> saveGameStats(GameStats stats);

  Future<List<GameStats>> fetchAllGameStats();
}

class GameStatsRepository implements IGameStatsRepository {
  GameStatsRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  String _requireUserId() {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Not logged in');
    }
    return user.id;
  }

  @override
  Future<GameStats?> fetchGameStats(String gameName) async {
    final userId = _requireUserId();
    final response = await _client
        .from('game_stats')
        .select()
        .eq('user_id', userId)
        .eq('game_name', gameName)
        .maybeSingle();

    if (response == null) return null;

    return GameStats.fromMap(response);
  }

  @override
  Future<void> saveGameStats(GameStats stats) async {
    final userId = _requireUserId();
    try {
      final existing = await _client
          .from('game_stats')
          .select()
          .eq('user_id', userId)
          .eq('game_name', stats.gameName)
          .maybeSingle();

      if (existing == null) {
        final data = stats.toMap()..['user_id'] = userId;
        await _client.from('game_stats').insert(data);
        return;
      }

      final existingStats = GameStats.fromMap(existing);
      final merged = _mergeForHighScore(existingStats, stats);
      await _client
          .from('game_stats')
          .update(merged.toMap())
          .eq('user_id', userId)
          .eq('game_name', stats.gameName);
    } on PostgrestException catch (e) {
      debugPrint('game_stats save failed for ${stats.gameName}: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('game_stats save unexpected error for ${stats.gameName}: $e');
      rethrow;
    }
  }

  @override
  Future<List<GameStats>> fetchAllGameStats() async {
    final userId = _requireUserId();
    final response = await _client
        .from('game_stats')
        .select()
        .eq('user_id', userId);

    return response.map((e) => GameStats.fromMap(e)).toList();
  }

  GameStats _mergeForHighScore(GameStats existing, GameStats incoming) {
    return GameStats(
      gameName: existing.gameName,
      level: incoming.level > existing.level ? incoming.level : existing.level,
      score: incoming.score > existing.score ? incoming.score : existing.score,
      maxStreak: incoming.maxStreak > existing.maxStreak
          ? incoming.maxStreak
          : existing.maxStreak,
      totalGames: incoming.totalGames > existing.totalGames
          ? incoming.totalGames
          : existing.totalGames,
      lastPlayed: incoming.lastPlayed ?? existing.lastPlayed ?? DateTime.now(),
    );
  }
}
