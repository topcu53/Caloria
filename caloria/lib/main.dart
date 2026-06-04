import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/config/app_config.dart';
import 'core/services/ad_service.dart';
import 'core/services/water_reminder_service.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_log.dart';
import 'routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    appLog('Warning: .env could not be loaded: $e');
  }

  if (!kDebugMode && !AppConfig.isReleaseReady) {
    appLog(
      'UYARI: Release yapılandırması eksik. '
      'GEMINI_API_KEY ve AdMob birimlerini dart-define ile verin.',
    );
  }

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  await WaterReminderService.instance.initialize();
  await AdService.instance.initialize();
  runApp(
    const ProviderScope(
      child: CaloriaApp(),
    ),
  );
}

class CaloriaApp extends ConsumerWidget {
  const CaloriaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Caloria',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
