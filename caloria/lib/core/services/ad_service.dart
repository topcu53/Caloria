import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/app_config.dart';
import '../utils/app_log.dart';

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  bool _initialized = false;
  InterstitialAd? _interstitial;
  bool _loadingInterstitial = false;

  static String get bannerAdUnitId {
    if (kIsWeb) return '';
    return AppConfig.bannerAdUnitId(android: Platform.isAndroid);
  }

  static String get interstitialAdUnitId {
    if (kIsWeb) return '';
    return AppConfig.interstitialAdUnitId(android: Platform.isAndroid);
  }

  Future<void> initialize() async {
    if (_initialized || kIsWeb) return;
    if (!kDebugMode && !AppConfig.hasProductionAdUnits) {
      appLog('AdMob: release modda birim ID tanımlı değil, reklamlar kapalı.');
      return;
    }
    await MobileAds.instance.initialize();
    _initialized = true;
    preloadInterstitial();
  }

  BannerAd? createBannerAd({void Function()? onLoaded}) {
    if (kIsWeb || bannerAdUnitId.isEmpty) return null;

    final ad = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => onLoaded?.call(),
        onAdFailedToLoad: (ad, error) {
          appLog('Banner yüklenemedi: $error');
          ad.dispose();
        },
      ),
    );
    ad.load();
    return ad;
  }

  void preloadInterstitial() {
    if (!_initialized ||
        kIsWeb ||
        interstitialAdUnitId.isEmpty ||
        _interstitial != null) {
      return;
    }
    if (_loadingInterstitial) return;
    _loadingInterstitial = true;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
          _loadingInterstitial = false;
        },
        onAdFailedToLoad: (error) {
          appLog('Interstitial yüklenemedi: $error');
          _loadingInterstitial = false;
        },
      ),
    );
  }

  Future<bool> showInterstitialIfReady() async {
    if (kIsWeb || _interstitial == null) return false;

    final ad = _interstitial!;
    _interstitial = null;
    final completer = Completer<void>();

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (d) {
        d.dispose();
        if (!completer.isCompleted) completer.complete();
        preloadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (d, error) {
        appLog('Interstitial gösterilemedi: $error');
        d.dispose();
        if (!completer.isCompleted) completer.complete();
        preloadInterstitial();
      },
    );

    await ad.show();
    await completer.future.timeout(
      const Duration(seconds: 90),
      onTimeout: () {},
    );
    return true;
  }

  Future<bool> showInterstitialWhenReady({
    Duration maxWait = const Duration(seconds: 3),
  }) async {
    final deadline = DateTime.now().add(maxWait);
    while (DateTime.now().isBefore(deadline)) {
      if (await showInterstitialIfReady()) return true;
      await Future.delayed(const Duration(milliseconds: 250));
    }
    return false;
  }
}
