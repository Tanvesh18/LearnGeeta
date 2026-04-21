import 'package:supabase_flutter/supabase_flutter.dart';

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
    final data = stats.toMap()..['user_id'] = userId;

    await _client.from('game_stats').upsert(data);
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
}
