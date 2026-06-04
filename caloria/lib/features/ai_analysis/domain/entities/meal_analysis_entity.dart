class MealAnalysisEntity {
  final String food;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String portion;

  const MealAnalysisEntity({
    required this.food,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.portion,
  });

  factory MealAnalysisEntity.fromMap(Map<String, dynamic> map) {
    return MealAnalysisEntity(
      food: map['food']?.toString() ?? '',
      calories: _toDouble(map['calories']),
      protein: _toDouble(map['protein']),
      carbs: _toDouble(map['carbs']),
      fat: _toDouble(map['fat']),
      portion: map['portion']?.toString() ?? '',
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.replaceAll(',', '.')) ?? 0;
    return 0;
  }
}