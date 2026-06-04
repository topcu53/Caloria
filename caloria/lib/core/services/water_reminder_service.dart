import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../utils/app_log.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// 09:00–22:00 arası 30 dk'da bir; 22:00–09:00 sessiz.
class WaterReminderService {
  WaterReminderService._();
  static final WaterReminderService instance = WaterReminderService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: false,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(alert: true, sound: true);

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    _initialized = true;
  }

  Future<void> setEnabled(bool enabled) async {
    await initialize();
    if (!enabled) {
      await _plugin.cancelAll();
      return;
    }
    await _scheduleSlots();
  }

  Future<void> _scheduleSlots() async {
    await _plugin.cancelAll();
    final now = tz.TZDateTime.now(tz.local);

    for (var dayOffset = 0; dayOffset < 3; dayOffset++) {
      for (var hour = 9; hour < 22; hour++) {
        for (final minute in [0, 30]) {
          final scheduled = tz.TZDateTime(
            tz.local,
            now.year,
            now.month,
            now.day + dayOffset,
            hour,
            minute,
          );
          if (!scheduled.isAfter(now)) continue;

          final id = dayOffset * 100 + hour * 2 + (minute == 30 ? 1 : 0);
          await _plugin.zonedSchedule(
            id,
            'Su içme zamanı 💧',
            'Hedeflerine ulaşmak için bir bardak su iç.',
            scheduled,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'water_reminder',
                'Su Hatırlatıcı',
                channelDescription: 'Gündüz su içme hatırlatmaları',
                importance: Importance.defaultImportance,
                priority: Priority.defaultPriority,
              ),
              iOS: DarwinNotificationDetails(),
            ),
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
        }
      }
    }
    appLog('Su hatırlatıcıları planlandı (09:00-22:00).');
  }
}
