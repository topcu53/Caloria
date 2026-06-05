import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/services/ad_service.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _loaded = false;
  int _retryCount = 0;
  static const _maxRetries = 6;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startLoad());
  }

  Future<void> _startLoad() async {
    if (!mounted) return;
    final width = MediaQuery.sizeOf(context).width.truncate();
    await _loadAd(width);
  }

  Future<void> _loadAd(int width) async {
    _bannerAd?.dispose();
    if (!mounted) return;
    setState(() => _loaded = false);

    _bannerAd = await AdService.instance.createBannerAd(
      width: width,
      onLoaded: () {
        if (mounted) setState(() => _loaded = true);
      },
      onFailed: (_) => _scheduleRetry(width),
    );

    if (_bannerAd == null && _retryCount < _maxRetries) {
      _scheduleRetry(width);
    }
  }

  void _scheduleRetry(int width) {
    if (_retryCount >= _maxRetries || !mounted) return;
    _retryCount++;
    _retryTimer?.cancel();
    _retryTimer = Timer(const Duration(seconds: 6), () {
      if (mounted) _loadAd(width);
    });
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_bannerAd == null) {
      return const SizedBox.shrink();
    }

    if (!_loaded) {
      return const SizedBox(
        height: 50,
        width: double.infinity,
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: _bannerAd!.size.height.toDouble(),
      child: Center(child: AdWidget(ad: _bannerAd!)),
    );
  }
}
