import 'package:flutter/foundation.dart';

import 'xp_service.dart';

class ProgressSyncNotifier extends ChangeNotifier {
  void notifyProgressChanged() {
    notifyListeners();
  }

  void notifyLevelUp(LevelUpEvent event) {
    // Store the event for listeners
    _lastLevelUpEvent = event;
    notifyListeners();
  }

  LevelUpEvent? _lastLevelUpEvent;

  LevelUpEvent? get lastLevelUpEvent => _lastLevelUpEvent;

  void clearLevelUpEvent() {
    _lastLevelUpEvent = null;
  }
}
