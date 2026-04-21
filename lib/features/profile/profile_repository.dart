import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/models/user_profile.dart';

abstract class IProfileRepository {
  Future<UserProfile> fetchProfile();

  Future<UserProfile> updateProfile({
    required String fullName,
    required String language,
  });

  Future<UserProfile> upsertProfile(UserProfile profile);
}

class ProfileRepository implements IProfileRepository {
  ProfileRepository({SupabaseClient? client})
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
  Future<UserProfile> fetchProfile() async {
    final user = _requireUser();
    final profileList = await _client
        .from('profiles')
        .select()
        .eq('id', user.id);

    if (profileList.isEmpty) {
      final fullName =
          (user.userMetadata?['full_name'] as String?)?.trim() ?? '';
      final profile = UserProfile(
        id: user.id,
        email: user.email ?? '',
        fullName: fullName,
        language: 'English',
      );
      await _client.from('profiles').insert(profile.toMap());
      return profile;
    }

    return UserProfile.fromMap(profileList.first);
  }

  @override
  Future<UserProfile> updateProfile({
    required String fullName,
    required String language,
  }) async {
    final user = _requireUser();
    final profile = UserProfile(
      id: user.id,
      email: user.email ?? '',
      fullName: fullName,
      language: language,
    );
    await _client.from('profiles').upsert(profile.toMap());
    return profile;
  }

  @override
  Future<UserProfile> upsertProfile(UserProfile profile) async {
    await _client.from('profiles').upsert(profile.toMap());
    return profile;
  }
}
