import 'package:flutter/foundation.dart';

class AppLogger {
  const AppLogger._();

  static void error(String message, Object error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('$message: $error');
      if (stackTrace != null) {
        debugPrintStack(stackTrace: stackTrace);
      }
    }
  }
}
