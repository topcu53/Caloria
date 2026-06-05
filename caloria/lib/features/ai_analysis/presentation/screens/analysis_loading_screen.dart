import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/ad_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../../../../shared/widgets/banner_ad_widget.dart';
import '../providers/ai_analysis_provider.dart';

/// Analiz sırasında tam ekran geçiş reklamı + yükleme göstergesi.
class AnalysisLoadingScreen extends ConsumerStatefulWidget {
  final String imagePath;

  const AnalysisLoadingScreen({super.key, required this.imagePath});

  @override
  ConsumerState<AnalysisLoadingScreen> createState() =>
      _AnalysisLoadingScreenState();
}

class _AnalysisLoadingScreenState extends ConsumerState<AnalysisLoadingScreen> {
  bool _interstitialShown = false;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    AdService.instance.preloadInterstitial();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    if (_started) return;
    _started = true;

    final file = File(widget.imagePath);
    await AdService.instance.ensureInitialized();
    AdService.instance.preloadInterstitial();

    final analyzeFuture =
        ref.read(aiAnalysisProvider.notifier).analyzeImage(file);
    final adFuture = AdService.instance.waitAndShowInterstitial();

    final shown = await adFuture;
    if (mounted) setState(() => _interstitialShown = shown);

    await analyzeFuture;

    if (!mounted) return;

    final state = ref.read(aiAnalysisProvider);
    if (state.hasError) {
      context.pop();
      return;
    }

    if (!AdService.instance.interstitialShownThisSession) {
      await AdService.instance.waitAndShowInterstitial(
        maxWait: const Duration(seconds: 8),
      );
    }

    if (!mounted) return;
    context.go(AppRoutes.aiResult);
  }

  @override
  Widget build(BuildContext context) {
    final analysis = ref.watch(aiAnalysisProvider);

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Analiz ediliyor'),
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          size: 56,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Yemeğiniz analiz ediliyor',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _interstitialShown
                            ? 'AI kalori ve makroları hesaplıyor…'
                            : 'Reklam yükleniyor, ardından analiz devam edecek…',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const CircularProgressIndicator(color: AppColors.primary),
                      if (analysis.hasError) ...[
                        const SizedBox(height: 20),
                        Text(
                          'Analiz başarısız. Geri dönülüyor…',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SafeArea(
              top: false,
              child: BannerAdWidget(),
            ),
          ],
        ),
      ),
    );
  }
}
