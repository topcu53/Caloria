import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/calendar_day_provider.dart';
import '../../data/datasources/meal_remote_datasource.dart';
import '../../domain/entities/meal_entity.dart';

final mealDataSourceProvider = Provider((ref) => MealRemoteDataSource());

/// Ana sayfa ve öğün kayıtları için aktif takvim günü.
final selectedDateProvider = Provider<DateTime>(
  (ref) => ref.watch(calendarDayProvider),
);

final mealsProvider = StreamProvider.family<List<MealEntity>, String>(
  (ref, mealType) {
    final date = ref.watch(calendarDayProvider);
    return ref.watch(mealDataSourceProvider).watchMealsForDate(date, mealType);
  },
);

final dailySummaryProvider = Provider((ref) {
  final breakfast = ref.watch(mealsProvider('breakfast')).valueOrNull ?? [];
  final lunch = ref.watch(mealsProvider('lunch')).valueOrNull ?? [];
  final dinner = ref.watch(mealsProvider('dinner')).valueOrNull ?? [];
  final snacks = ref.watch(mealsProvider('snacks')).valueOrNull ?? [];

  final allMeals = [...breakfast, ...lunch, ...dinner, ...snacks];

  return DailySummary(
    totalCalories: allMeals.fold(0, (sum, m) => sum + m.calories),
    totalProtein: allMeals.fold(0, (sum, m) => sum + m.protein),
    totalCarbs: allMeals.fold(0, (sum, m) => sum + m.carbs),
    totalFat: allMeals.fold(0, (sum, m) => sum + m.fat),
  );
});

class DailySummary {
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;

  const DailySummary({
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
  });
}