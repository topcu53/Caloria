import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../meals/domain/entities/daily_log_summary.dart';
import '../../../meals/presentation/providers/daily_log_provider.dart';

/// Son [days] günün günlük beslenme özetleri (eskiden yeniye).
final nutritionAnalyticsProvider =
    FutureProvider.family<List<DailyLogSummary>, int>((ref, days) async {
  final ds = ref.watch(dailyLogDataSourceProvider);
  final keys = await ds.fetchRecentDateKeys(limit: days);
  if (keys.isEmpty) return [];

  final summaries = <DailyLogSummary>[];
  for (final key in keys.reversed) {
    final parts = key.split('-');
    final date = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
    summaries.add(await ds.fetchDaySummary(date));
  }
  return summaries;
});

class NutritionAverages {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final int daysWithMeals;

  const NutritionAverages({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.daysWithMeals,
  });

  factory NutritionAverages.fromSummaries(List<DailyLogSummary> summaries) {
    final withData =
        summaries.where((s) => s.meals.isNotEmpty).toList();
    if (withData.isEmpty) {
      return const NutritionAverages(
        calories: 0,
        protein: 0,
        carbs: 0,
        fat: 0,
        daysWithMeals: 0,
      );
    }
    final n = withData.length;
    return NutritionAverages(
      calories: withData.fold(0.0, (s, d) => s + d.totalCalories) / n,
      protein: withData.fold(0.0, (s, d) => s + d.totalProtein) / n,
      carbs: withData.fold(0.0, (s, d) => s + d.totalCarbs) / n,
      fat: withData.fold(0.0, (s, d) => s + d.totalFat) / n,
      daysWithMeals: n,
    );
  }
}
