import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:learngeetagames/auth/auth_controller.dart';
import 'package:learngeetagames/auth/auth_repository.dart';
import 'package:learngeetagames/core/models/user_profile.dart';
import 'package:learngeetagames/core/models/user_progress.dart';
import 'package:learngeetagames/features/profile/profile_repository.dart';
import 'package:learngeetagames/features/progress/progress_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('AuthController', () {
    test('signIn succeeds without leaving an error message', () async {
      final controller = AuthController(
        authRepository: FakeAuthRepository(),
        profileRepository: FakeProfileRepository(),
        progressRepository: FakeProgressRepository(),
      );

      final success = await controller.signIn(
        email: 'test@example.com',
        password: 'Secret123!',
      );

      expect(success, isTrue);
      expect(controller.errorMessage, isNull);
      expect(controller.isLoading, isFalse);
    });

    test('signUp rejects weak passwords before hitting the backend', () async {
      final authRepository = FakeAuthRepository();
      final controller = AuthController(
        authRepository: authRepository,
        profileRepository: FakeProfileRepository(),
        progressRepository: FakeProgressRepository(),
      );

      final success = await controller.signUp(
        name: 'Learner',
        email: 'learner@example.com',
        password: 'password',
      );

      expect(success, isFalse);
      expect(controller.errorMessage, isNotNull);
      expect(authRepository.signUpCalls, 0);
    });
  });
}

class FakeAuthRepository implements IAuthRepository {
  int signUpCalls = 0;

  @override
  Stream<AuthState> authStateChanges() => const Stream.empty();

  @override
  User? getCurrentUser() => null;

  @override
  Session? getCurrentSession() => null;

  @override
  Future<void> resetPassword({required String email}) async {}

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {}

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    signUpCalls += 1;
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<void> updatePassword(String newPassword) async {}
}

class FakeProfileRepository implements IProfileRepository {
  @override
  Future<UserProfile> fetchProfile() async {
    return const UserProfile(
      id: 'user-1',
      email: 'test@example.com',
      fullName: 'Tester',
      language: 'English',
    );
  }

  @override
  Future<UserProfile> updateProfile({
    required String fullName,
    required String language,
  }) async {
    return UserProfile(
      id: 'user-1',
      email: 'test@example.com',
      fullName: fullName,
      language: language,
    );
  }

  @override
  Future<UserProfile> upsertProfile(UserProfile profile) async => profile;
}

class FakeProgressRepository implements IProgressRepository {
  @override
  Future<UserProgress> awardXp(int xp) async {
    return UserProgress(userId: 'user-1', level: 1, xp: xp, streak: 1);
  }

  @override
  Future<UserProgress> createInitialProgressForUser(String userId) async {
    return UserProgress(userId: userId, level: 1, xp: 0, streak: 0);
  }

  @override
  Future<UserProgress> fetchProgress() async {
    return const UserProgress(userId: 'user-1', level: 1, xp: 0, streak: 1);
  }

  @override
  Future<UserProgress> updateDailyStreak() async {
    return const UserProgress(userId: 'user-1', level: 1, xp: 0, streak: 2);
  }
}
