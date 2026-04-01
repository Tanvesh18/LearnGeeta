import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      print('SIGNUP RESPONSE: $response');
      print('USER: ${response.user}');
      print('SESSION: ${response.session}');

      final user = response.user;
      if (user == null) {
        throw Exception('User is null after signup');
      }

      await _client.from('profiles').insert({
        'id': user.id,
        'full_name': name,
        'email': email,
      });

      await _client.from('progress').insert({'user_id': user.id});
    } catch (e) {
      print('SIGNUP ERROR: $e');
      rethrow;
    }
  }

  /// ✅ THIS METHOD WAS MISSING
  Future<void> signIn({required String email, required String password}) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> resetPassword({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.flutter://reset-callback',
      );
    } catch (e) {
      print('RESET PASSWORD ERROR: $e');
      rethrow;
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(UserAttributes(password: newPassword));
    } catch (e) {
      print('UPDATE PASSWORD ERROR: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? getCurrentUser() {
    return _client.auth.currentUser;
  }
}
