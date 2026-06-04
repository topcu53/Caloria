import 'meal_entity.dart';

class DailyLogSummary {
  final String dateKey;
  final DateTime date;
  final List<MealEntity> meals;
  final double waterMl;

  const DailyLogSummary({
    required this.dateKey,
    required this.date,
    required this.meals,
    this.waterMl = 0,
  });

  double get totalCalories =>
      meals.fold(0, (sum, m) => sum + m.calories);

  double get totalProtein => meals.fold(0, (sum, m) => sum + m.protein);

  double get totalCarbs => meals.fold(0, (sum, m) => sum + m.carbs);

  double get totalFat => meals.fold(0, (sum, m) => sum + m.fat);
}
