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
      food: map['food'] ?? '',
      calories: (map['calories'] ?? 0).toDouble(),
      protein: (map['protein'] ?? 0).toDouble(),
      carbs: (map['carbs'] ?? 0).toDouble(),
      fat: (map['fat'] ?? 0).toDouble(),
      portion: map['portion'] ?? '',
    );
  }
}