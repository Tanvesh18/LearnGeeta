import 'package:flutter/foundation.dart';

import '../../core/models/game_definition.dart';
import '../../core/models/user_progress.dart';
import '../progress/progress_repository.dart';
import '../progress/progress_sync_notifier.dart';
import 'play_registry.dart';

class PlayController extends ChangeNotifier {
  PlayController({
    required IProgressRepository progressRepository,
    required ProgressSyncNotifier progressSyncNotifier,
  }) : _progressRepository = progressRepository,
       _progressSyncNotifier = progressSyncNotifier {
    _progressSyncNotifier.addListener(_handleProgressChanged);
  }

  final IProgressRepository _progressRepository;
  final ProgressSyncNotifier _progressSyncNotifier;

  bool _isLoading = true;
  UserProgress _progress = const UserProgress(
    userId: '',
    level: 1,
    xp: 0,
    streak: 0,
  );

  bool get isLoading => _isLoading;
  UserProgress get progress => _progress;
  List<GameDefinition> get games => GameRegistry.games;

  void _handleProgressChanged() {
    load();
  }

  Future<void> load() async {
    try {
      _progress = await _progressRepository.fetchProgress();
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
