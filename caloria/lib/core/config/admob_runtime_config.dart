import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// `admob_config.json` (asset) — canlı reklam birim kimlikleri.
class AdMobRuntimeConfig {
  AdMobRuntimeConfig._();

  static final Map<String, String> _values = {};
  static bool _loaded = false;

  static Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final raw = await rootBundle.loadString('admob_config.json');
      final map = jsonDecode(raw) as Map<String, dynamic>;
      for (final entry in map.entries) {
        final v = entry.value?.toString().trim() ?? '';
        if (v.isNotEmpty && !v.startsWith('BURAYA_')) {
          _values[entry.key] = v;
        }
      }
    } catch (e) {
      debugPrint('admob_config.json yüklenemedi: $e');
    }
  }

  static String get(String key) => _values[key] ?? '';
}
