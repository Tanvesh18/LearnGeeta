import '../../core/utils/app_logger.dart';
import 'progress_repository.dart';
import 'progress_sync_notifier.dart';

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
      await _progressRepository.awardXp(amount);
      _progressSyncNotifier.notifyProgressChanged();
    } catch (error, stackTrace) {
      AppLogger.error('Failed to award XP', error, stackTrace);
    }
  }
}
