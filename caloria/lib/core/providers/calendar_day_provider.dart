import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Yerel takvim günü (saat 00:00). Gece yarısı veya uygulama ön plana gelince güncellenir.
DateTime normalizeCalendarDay(DateTime dateTime) =>
    DateTime(dateTime.year, dateTime.month, dateTime.day);

bool isSameCalendarDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

final calendarDayProvider =
    NotifierProvider<CalendarDayNotifier, DateTime>(CalendarDayNotifier.new);

class CalendarDayNotifier extends Notifier<DateTime> with WidgetsBindingObserver {
  Timer? _midnightTimer;

  @override
  DateTime build() {
    ref.onDispose(_dispose);
    WidgetsBinding.instance.addObserver(this);
    _scheduleMidnightTimer();
    return normalizeCalendarDay(DateTime.now());
  }

  void _dispose() {
    _midnightTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      syncToToday();
    }
  }

  /// Gece yarısı veya uygulama açılışında bugünün tarihine geçer; önceki günün verisi ana sayfada görünmez.
  void syncToToday() {
    final today = normalizeCalendarDay(DateTime.now());
    if (!isSameCalendarDay(state, today)) {
      state = today;
    }
    _scheduleMidnightTimer();
  }

  void _scheduleMidnightTimer() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    _midnightTimer = Timer(nextMidnight.difference(now), syncToToday);
  }
}
