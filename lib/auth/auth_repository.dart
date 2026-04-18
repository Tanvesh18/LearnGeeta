import 'package:supabase_flutter/supabase_flutter.dart';

abstract class IAuthRepository {
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  });

  Future<void> signIn({required String email, required String password});

  Future<void> resetPassword({required String email});

  Future<void> updatePassword(String newPassword);

  Future<void> signOut();

  User? getCurrentUser();

  Session? getCurrentSession();

  Stream<AuthState> authStateChanges();
}

class AuthRepository implements IAuthRepository {
  AuthRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) {
    return _client.auth.signUp(email: email, password: password);
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> resetPassword({required String email}) {
    return _client.auth.resetPasswordForEmail(
      email,
      redirectTo: 'io.supabase.flutter://reset-callback',
    );
  }

  @override
  Future<void> updatePassword(String newPassword) {
    return _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  @override
  Future<void> signOut() {
    return _client.auth.signOut();
  }

  @override
  User? getCurrentUser() => _client.auth.currentUser;

  @override
  Session? getCurrentSession() => _client.auth.currentSession;

  @override
  Stream<AuthState> authStateChanges() => _client.auth.onAuthStateChange;
}
