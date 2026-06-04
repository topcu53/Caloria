import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Ortam değişkenleri: önce `--dart-define`, sonra `.env` (geliştirme).
class AppConfig {
  AppConfig._();

  static String _env(String key) {
    final fromDefine = String.fromEnvironment(key);
    if (fromDefine.isNotEmpty) return fromDefine;
    return dotenv.env[key]?.trim() ?? '';
  }

  static String get geminiApiKey => _env('GEMINI_API_KEY');

  static String get admobAppIdAndroid => _env('ADMOB_APP_ID_ANDROID');
  static String get admobAppIdIos => _env('ADMOB_APP_ID_IOS');

  static String admobBannerId({required bool android}) =>
      _env(android ? 'ADMOB_BANNER_ANDROID' : 'ADMOB_BANNER_IOS');

  static String admobInterstitialId({required bool android}) =>
      _env(android ? 'ADMOB_INTERSTITIAL_ANDROID' : 'ADMOB_INTERSTITIAL_IOS');

  /// Mağaza yayını öncesi gerçek AdMob birimleri tanımlı mı?
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

  static bool _isProductionAdUnitId(String id) {
    if (id.isEmpty) return false;
    return !id.contains('3940256099942544');
  }

  static const _testBannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const _testBannerIos = 'ca-app-pub-3940256099942544/2934735716';
  static const _testInterstitialAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  static const _testInterstitialIos = 'ca-app-pub-3940256099942544/4411468910';

  static String bannerAdUnitId({required bool android}) {
    final configured = admobBannerId(android: android);
    if (configured.isNotEmpty) return configured;
    if (kDebugMode) return android ? _testBannerAndroid : _testBannerIos;
    return '';
  }

  static String interstitialAdUnitId({required bool android}) {
    final configured = admobInterstitialId(android: android);
    if (configured.isNotEmpty) return configured;
    if (kDebugMode) {
      return android ? _testInterstitialAndroid : _testInterstitialIos;
    }
    return '';
  }

  static String admobAppId({required bool android}) {
    final configured = android ? admobAppIdAndroid : admobAppIdIos;
    if (configured.isNotEmpty) return configured;
    if (kDebugMode) {
      return android
          ? 'ca-app-pub-3940256099942544~3347511713'
          : 'ca-app-pub-3940256099942544~1458002511';
    }
    return '';
  }
}
