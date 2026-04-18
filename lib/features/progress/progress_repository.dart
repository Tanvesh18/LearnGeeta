import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/xp_policy.dart';
import '../../core/models/user_progress.dart';

abstract class IProgressRepository {
  Future<UserProgress> fetchProgress();

  Future<UserProgress> createInitialProgressForUser(String userId);

  Future<UserProgress> updateDailyStreak();

  Future<UserProgress> awardXp(int xp);
}

class ProgressRepository implements IProgressRepository {
  ProgressRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  User _requireUser() {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Not logged in');
    }
    return user;
  }

  @override
  Future<UserProgress> fetchProgress() async {
    final user = _requireUser();
    final progressList = await _client
        .from('progress')
        .select()
        .eq('user_id', user.id);

    if (progressList.isEmpty) {
      final progress = UserProgress(
        userId: user.id,
        level: 1,
        xp: 0,
        streak: 0,
      );
      await _client.from('progress').insert(progress.toMap());
      return progress;
    }

    return UserProgress.fromMap(progressList.first);
  }

  @override
  Future<UserProgress> createInitialProgressForUser(String userId) async {
    final progress = UserProgress(userId: userId, level: 1, xp: 0, streak: 0);
    await _client.from('progress').insert(progress.toMap());
    return progress;
  }

  @override
  Future<UserProgress> updateDailyStreak() async {
    final current = await fetchProgress();
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    var streak = current.streak;
    if (current.lastActive == null) {
      streak = 1;
    } else {
      final lastActive = current.lastActive!;
      final diff = todayDate
          .difference(
            DateTime(lastActive.year, lastActive.month, lastActive.day),
          )
          .inDays;
      if (diff == 1) {
        streak += 1;
      } else if (diff > 1) {
        streak = 1;
      }
    }

    final updated = current.copyWith(streak: streak, lastActive: todayDate);
    await _client
        .from('progress')
        .update({
          'streak': updated.streak,
          'last_active': updated.lastActive?.toIso8601String(),
        })
        .eq('user_id', updated.userId);
    return updated;
  }

  @override
  Future<UserProgress> awardXp(int xp) async {
    final current = await fetchProgress();
    final nextXp = current.xp + xp;
    final nextLevel = XpPolicy.levelForXp(nextXp);
    final updated = current.copyWith(xp: nextXp, level: nextLevel);

    await _client
        .from('progress')
        .update({'xp': updated.xp, 'level': updated.level})
        .eq('user_id', updated.userId);

    return updated;
  }
}
