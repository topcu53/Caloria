import 'package:flutter/foundation.dart';

/// Yalnızca debug modda log yazar (release APK/IPA şişmez).
void appLog(String message) {
  if (kDebugMode) {
    debugPrint(message);
  }
}
