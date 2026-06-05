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
  bool interstitialShownThisSession = false;

  bool get isInitialized => _initialized;

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

    if (!AppConfig.hasProductionAdUnitsForCurrentPlatform()) {
      debugPrint(
        'AdMob HATA: Bu platform için reklam birimi tanımlı değil. '
        'admob_config.json kontrol edin.',
      );
      return;
    }

    final status = await MobileAds.instance.initialize();
    _initialized = true;

    if (kDebugMode) {
      debugPrint('AdMob SDK hazır.');
      debugPrint('Banner birimi: $bannerAdUnitId');
      debugPrint('Interstitial birimi: $interstitialAdUnitId');
      for (final entry in status.adapterStatuses.entries) {
        debugPrint('Adapter ${entry.key}: ${entry.value.state}');
      }
    }

    if (AppConfig.hasInterstitialForCurrentPlatform) {
      preloadInterstitial();
    }
  }

  Future<void> ensureInitialized() async {
    if (!_initialized) await initialize();
  }

  Future<BannerAd?> createBannerAd({
    required int width,
    void Function()? onLoaded,
    void Function(LoadAdError error)? onFailed,
  }) async {
    await ensureInitialized();
    if (!_initialized || kIsWeb || bannerAdUnitId.isEmpty) return null;

    final anchoredSize =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      width,
    );
    final size = anchoredSize ?? AdSize.banner;

    final ad = BannerAd(
      adUnitId: bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          appLog('AdMob: Banner yüklendi.');
          onLoaded?.call();
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint(
            'AdMob Banner HATA (kod=${error.code}): ${error.message}',
          );
          ad.dispose();
          onFailed?.call(error);
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
        _interstitial != null ||
        _loadingInterstitial) {
      return;
    }
    _loadingInterstitial = true;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
          _loadingInterstitial = false;
          appLog('AdMob: Interstitial hazır.');
        },
        onAdFailedToLoad: (error) {
          debugPrint(
            'AdMob Interstitial HATA (kod=${error.code}): ${error.message}',
          );
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
        interstitialShownThisSession = true;
        preloadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (d, error) {
        debugPrint('AdMob Interstitial gösterim HATA: ${error.message}');
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
    interstitialShownThisSession = true;
    return true;
  }

  Future<bool> waitAndShowInterstitial({
    Duration maxWait = const Duration(seconds: 20),
  }) async {
    await ensureInitialized();
    if (!_initialized) return false;

    preloadInterstitial();
    final deadline = DateTime.now().add(maxWait);
    while (DateTime.now().isBefore(deadline)) {
      if (await showInterstitialIfReady()) return true;
      if (_interstitial == null && !_loadingInterstitial) {
        preloadInterstitial();
      }
      await Future.delayed(const Duration(milliseconds: 400));
    }
    debugPrint(
      'AdMob: Interstitial ${maxWait.inSeconds}s içinde gelmedi '
      '(yeni hesaplarda / emülatörde normal olabilir).',
    );
    return false;
  }
}
