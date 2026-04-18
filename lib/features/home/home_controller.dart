import 'package:flutter/foundation.dart';

import '../../core/models/user_profile.dart';
import '../../core/models/user_progress.dart';
import '../../core/utils/app_logger.dart';
import '../profile/profile_repository.dart';
import '../progress/progress_repository.dart';
import '../progress/progress_sync_notifier.dart';

typedef DailyShloka = ({String sanskrit, String meaning});

class HomeController extends ChangeNotifier {
  HomeController({
    required IProfileRepository profileRepository,
    required IProgressRepository progressRepository,
    required ProgressSyncNotifier progressSyncNotifier,
  }) : _profileRepository = profileRepository,
       _progressRepository = progressRepository,
       _progressSyncNotifier = progressSyncNotifier {
    _progressSyncNotifier.addListener(_handleProgressChanged);
  }

  final IProfileRepository _profileRepository;
  final IProgressRepository _progressRepository;
  final ProgressSyncNotifier _progressSyncNotifier;

  bool _isLoading = true;
  UserProfile? _profile;
  UserProgress? _progress;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  UserProfile? get profile => _profile;
  UserProgress? get progress => _progress;
  String? get errorMessage => _errorMessage;

  void _handleProgressChanged() {
    load();
  }

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _profileRepository.fetchProfile();
      _progress = await _progressRepository.updateDailyStreak();
    } catch (error, stackTrace) {
      AppLogger.error('Failed to load home data', error, stackTrace);
      _errorMessage = 'Unable to load your progress right now.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _progressSyncNotifier.removeListener(_handleProgressChanged);
    super.dispose();
  }
}
