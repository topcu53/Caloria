import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/calendar_day_provider.dart';
import '../../data/datasources/daily_log_remote_datasource.dart';
import '../../domain/entities/daily_log_summary.dart';

final dailyLogDataSourceProvider =
    Provider((ref) => DailyLogRemoteDataSource());

final todayWaterMlProvider = StreamProvider<double>((ref) {
  final day = ref.watch(calendarDayProvider);
  return ref.watch(dailyLogDataSourceProvider).watchWaterMl(day);
});

final historyDatesProvider = FutureProvider<List<String>>((ref) async {
  return ref.watch(dailyLogDataSourceProvider).fetchRecentDateKeys(limit: 45);
});

final daySummaryProvider =
    FutureProvider.family<DailyLogSummary, String>((ref, dateKey) async {
  final parts = dateKey.split('-');
  final date = DateTime(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
  return ref.watch(dailyLogDataSourceProvider).fetchDaySummary(date);
});
