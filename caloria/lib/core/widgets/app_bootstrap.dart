import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/calendar_day_provider.dart';
import '../services/water_reminder_service.dart';
import '../../features/profile/presentation/providers/profile_provider.dart';

/// Su hatırlatıcısını profil ayarına göre bir kez planlar.
class AppBootstrap extends ConsumerStatefulWidget {
  final Widget child;

  const AppBootstrap({super.key, required this.child});

  @override
  ConsumerState<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends ConsumerState<AppBootstrap> {
  bool _remindersConfigured = false;

  @override
  Widget build(BuildContext context) {
    ref.watch(calendarDayProvider);

    ref.listen(userProfileProvider, (prev, next) {
      next.whenData((profile) async {
        if (_remindersConfigured || profile == null) return;
        _remindersConfigured = true;
        await WaterReminderService.instance.initialize();
        if (profile.waterReminderEnabled) {
          await WaterReminderService.instance.setEnabled(true);
        }
      });
    });

    return widget.child;
  }
}
