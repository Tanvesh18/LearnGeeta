import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final SupabaseClient _client = Supabase.instance.client;

  // ================= FETCH PROFILE + PROGRESS =================
  Future<Map<String, dynamic>> fetchProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    // -------- PROFILE --------
    final profileList = await _client
        .from('profiles')
        .select()
        .eq('id', user.id);

    Map<String, dynamic> profile;

    if (profileList.isEmpty) {
      profile = {
        'id': user.id,
        'full_name': '',
        'email': user.email,
        'language': 'English',
      };
      await _client.from('profiles').insert(profile);
    } else {
      profile = profileList.first;
    }

    // -------- PROGRESS --------
    final progressList = await _client
        .from('progress')
        .select()
        .eq('user_id', user.id);

    Map<String, dynamic> progress;

    if (progressList.isEmpty) {
      progress = {
        'user_id': user.id,
        'level': 1,
        'xp': 0,
        'streak': 0,
      };
      await _client.from('progress').insert(progress);
    } else {
      progress = progressList.first;
    }

    return {
      'profile': profile,
      'progress': progress,
    };
  }

  // ================= UPDATE PROFILE =================
  Future<void> updateProfile({
    required String fullName,
    required String language,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    await _client
        .from('profiles')
        .update({
          'full_name': fullName,
          'language': language,
        })
        .eq('id', user.id);
  }

  // ================= DAILY STREAK =================
  Future<int> updateDailyStreak() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final progressList = await _client
        .from('progress')
        .select()
        .eq('user_id', user.id);

    Map<String, dynamic> progress;

    if (progressList.isEmpty) {
      progress = {
        'user_id': user.id,
        'level': 1,
        'xp': 0,
        'streak': 1,
        'last_active': todayDate.toIso8601String(),
      };
      await _client.from('progress').insert(progress);
      return 1;
    }

    progress = progressList.first;

    final lastActiveRaw = progress['last_active'];
    int streak = progress['streak'] ?? 0;

    if (lastActiveRaw == null) {
      streak = 1;
    } else {
      final lastActive = DateTime.parse(lastActiveRaw);
      final diff = todayDate
          .difference(DateTime(
              lastActive.year, lastActive.month, lastActive.day))
          .inDays;

      if (diff == 1) {
        streak += 1;
      } else if (diff > 1) {
        streak = 1;
      }
    }

    await _client.from('progress').update({
      'streak': streak,
      'last_active': todayDate.toIso8601String(),
    }).eq('user_id', user.id);

    return streak;
  }

  // ================= SIGN OUT =================
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}