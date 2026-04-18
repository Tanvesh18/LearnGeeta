import 'package:flutter/foundation.dart';

class ProgressSyncNotifier extends ChangeNotifier {
  void notifyProgressChanged() {
    notifyListeners();
  }
}
