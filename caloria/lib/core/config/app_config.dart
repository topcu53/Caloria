import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'admob_runtime_config.dart';

/// Ortam değişkenleri: dart-define → admob_config.json → .env
class AppConfig {
  AppConfig._();

  static String _env(String key) {
    final fromDefine = String.fromEnvironment(key);
    if (fromDefine.isNotEmpty) return fromDefine;
    final fromAsset = AdMobRuntimeConfig.get(key);
    if (fromAsset.isNotEmpty) return fromAsset;
    return dotenv.env[key]?.trim() ?? '';
  }

  static String get geminiApiKey => _env('GEMINI_API_KEY');

  static String get admobAppIdAndroid => _env('ADMOB_APP_ID_ANDROID');
  static String get admobAppIdIos => _env('ADMOB_APP_ID_IOS');

  static String admobBannerId({required bool android}) =>
      _env(android ? 'ADMOB_BANNER_ANDROID' : 'ADMOB_BANNER_IOS');

  static String admobInterstitialId({required bool android}) =>
      _env(android ? 'ADMOB_INTERSTITIAL_ANDROID' : 'ADMOB_INTERSTITIAL_IOS');

  static bool hasProductionAdUnitsForCurrentPlatform() {
    if (kIsWeb) return false;
    final android = Platform.isAndroid;
    return hasBannerForCurrentPlatform || hasInterstitialForCurrentPlatform;
  }

  static bool get hasBannerForCurrentPlatform {
    if (kIsWeb) return false;
    return _isProductionAdUnitId(admobBannerId(android: Platform.isAndroid));
  }

  static bool get hasInterstitialForCurrentPlatform {
    if (kIsWeb) return false;
    return _isProductionAdUnitId(
      admobInterstitialId(android: Platform.isAndroid),
    );
  }

  static bool get hasProductionAdUnits {
    final ids = [
      admobBannerId(android: true),
      admobBannerId(android: false),
      admobInterstitialId(android: true),
      admobInterstitialId(android: false),
    ];
    return ids.every(_isProductionAdUnitId);
  }

  static bool get isReleaseReady {
    if (kDebugMode) return true;
    return geminiApiKey.isNotEmpty && hasProductionAdUnits;
  }

  static bool get isUsingTestAdUnits => false;

  static bool _isProductionAdUnitId(String id) {
    if (id.isEmpty) return false;
    return !id.contains('3940256099942544');
  }

  static String bannerAdUnitId({required bool android}) {
    final configured = admobBannerId(android: android);
    return _isProductionAdUnitId(configured) ? configured : '';
  }

  static String interstitialAdUnitId({required bool android}) {
    final configured = admobInterstitialId(android: android);
    return _isProductionAdUnitId(configured) ? configured : '';
  }
}
