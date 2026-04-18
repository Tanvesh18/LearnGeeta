import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learngeetagames/core/models/user_progress.dart';
import 'package:learngeetagames/features/games/shloka_match/shloka_match_screen.dart';
import 'package:learngeetagames/features/play/play_controller.dart';
import 'package:learngeetagames/features/play/play_screen.dart';
import 'package:learngeetagames/features/progress/progress_repository.dart';
import 'package:learngeetagames/features/progress/progress_sync_notifier.dart';

void main() {
  testWidgets('PlayScreen opens the game screen from the registry', (
    tester,
  ) async {
    final controller = PlayController(
      progressRepository: _FakeProgressRepository(),
      progressSyncNotifier: ProgressSyncNotifier(),
    );

    await tester.pumpWidget(
      MaterialApp(home: PlayScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Shloka Match'), findsOneWidget);

    await tester.tap(find.text('Shloka Match'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(ShlokaMatchScreen), findsOneWidget);
  });
}

class _FakeProgressRepository implements IProgressRepository {
  @override
  Future<UserProgress> awardXp(int xp) async {
    return const UserProgress(userId: 'user-1', level: 3, xp: 150, streak: 4);
  }

  @override
  Future<UserProgress> createInitialProgressForUser(String userId) async {
    return UserProgress(userId: userId, level: 1, xp: 0, streak: 0);
  }

  @override
  Future<UserProgress> fetchProgress() async {
    return const UserProgress(userId: 'user-1', level: 3, xp: 150, streak: 4);
  }

  @override
  Future<UserProgress> updateDailyStreak() async {
    return const UserProgress(userId: 'user-1', level: 3, xp: 150, streak: 5);
  }
}
