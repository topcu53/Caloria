class MealEntity {
  final String id;
  final String foodName;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String portion;
  final String mealType;
  final DateTime createdAt;

  const MealEntity({
    required this.id,
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.portion,
    required this.mealType,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'foodName': foodName,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'portion': portion,
      'mealType': mealType,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MealEntity.fromMap(Map<String, dynamic> map) {
    return MealEntity(
      id: map['id'] ?? '',
      foodName: map['foodName'] ?? '',
      calories: map['calories']?.toDouble() ?? 0,
      protein: map['protein']?.toDouble() ?? 0,
      carbs: map['carbs']?.toDouble() ?? 0,
      fat: map['fat']?.toDouble() ?? 0,
      portion: map['portion'] ?? '',
      mealType: map['mealType'] ?? 'breakfast',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}