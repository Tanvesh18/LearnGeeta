import '../../core/utils/app_logger.dart';
import 'progress_repository.dart';
import 'progress_sync_notifier.dart';

class LevelUpEvent {
  const LevelUpEvent({
    required this.oldLevel,
    required this.newLevel,
    required this.xpGained,
  });

  final int oldLevel;
  final int newLevel;
  final int xpGained;
}

class XpService {
  XpService({
    required IProgressRepository progressRepository,
    required ProgressSyncNotifier progressSyncNotifier,
  }) : _progressRepository = progressRepository,
       _progressSyncNotifier = progressSyncNotifier;

  final IProgressRepository _progressRepository;
  final ProgressSyncNotifier _progressSyncNotifier;

  Future<void> awardXp(int amount) async {
    if (amount <= 0) return;

    try {
      final current = await _progressRepository.fetchProgress();
      final oldLevel = current.level;
      final updated = await _progressRepository.awardXp(amount);
      final newLevel = updated.level;

      _progressSyncNotifier.notifyProgressChanged();

      if (newLevel > oldLevel) {
        _progressSyncNotifier.notifyLevelUp(
          LevelUpEvent(
            oldLevel: oldLevel,
            newLevel: newLevel,
            xpGained: amount,
          ),
        );
      }
    } catch (error, stackTrace) {
      AppLogger.error('Failed to award XP', error, stackTrace);
    }
  }
}
