import '../auth/auth_repository.dart';
import '../features/profile/profile_repository.dart';
import '../features/progress/progress_repository.dart';
import '../features/progress/progress_sync_notifier.dart';
import '../features/progress/xp_service.dart';

class AppDependencies {
  AppDependencies._();

  static final authRepository = AuthRepository();
  static final profileRepository = ProfileRepository();
  static final progressRepository = ProgressRepository();
  static final progressSyncNotifier = ProgressSyncNotifier();
  static final xpService = XpService(
    progressRepository: progressRepository,
    progressSyncNotifier: progressSyncNotifier,
  );
}
