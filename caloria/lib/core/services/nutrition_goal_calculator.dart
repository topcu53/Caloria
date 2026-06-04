/// Boy, kilo ve aktiviteye göre günlük kalori ve makro hedefleri.
class NutritionGoals {
  final double bmi;
  final String bmiCategory;
  final double dailyCalories;
  final double dailyProtein;
  final double dailyCarbs;
  final double dailyFat;

  const NutritionGoals({
    required this.bmi,
    required this.bmiCategory,
    required this.dailyCalories,
    required this.dailyProtein,
    required this.dailyCarbs,
    required this.dailyFat,
  });
}

class NutritionGoalCalculator {
  NutritionGoalCalculator._();

  static NutritionGoals calculate({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender,
    required String activityLevel,
    required String goal,
  }) {
    if (weightKg <= 0 || heightCm <= 0 || age <= 0) {
      throw ArgumentError('Geçerli boy, kilo ve yaş girin.');
    }

    final heightM = heightCm / 100;
    final bmi = weightKg / (heightM * heightM);
    final bmr = _bmrMifflinStJeor(
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
      isMale: gender == 'male',
    );
    final tdee = bmr * _activityMultiplier(activityLevel);
    final dailyCalories = _adjustCaloriesForGoal(tdee, goal);

    final macros = _macroSplit(
      calories: dailyCalories,
      weightKg: weightKg,
      goal: goal,
    );

    return NutritionGoals(
      bmi: double.parse(bmi.toStringAsFixed(1)),
      bmiCategory: _bmiCategory(bmi),
      dailyCalories: dailyCalories.roundToDouble(),
      dailyProtein: macros.protein.roundToDouble(),
      dailyCarbs: macros.carbs.roundToDouble(),
      dailyFat: macros.fat.roundToDouble(),
    );
  }

  static double _bmrMifflinStJeor({
    required double weightKg,
    required double heightCm,
    required int age,
    required bool isMale,
  }) {
    final base = 10 * weightKg + 6.25 * heightCm - 5 * age;
    return isMale ? base + 5 : base - 161;
  }

  static double _activityMultiplier(String level) {
    switch (level) {
      case 'light':
        return 1.375;
      case 'moderate':
        return 1.55;
      case 'active':
        return 1.725;
      case 'very_active':
        return 1.9;
      case 'sedentary':
      default:
        return 1.2;
    }
  }

  static double _adjustCaloriesForGoal(double tdee, String goal) {
    switch (goal) {
      case 'lose':
        return (tdee - 500).clamp(1200, 10000);
      case 'gain':
        return (tdee + 300).clamp(1200, 10000);
      case 'maintain':
      default:
        return tdee.clamp(1200, 10000);
    }
  }

  static _MacroGrams _macroSplit({
    required double calories,
    required double weightKg,
    required String goal,
  }) {
    final proteinPerKg = switch (goal) {
      'lose' => 2.0,
      'gain' => 1.8,
      _ => 1.6,
    };
    var proteinG = weightKg * proteinPerKg;
    var proteinCal = proteinG * 4;

    final fatRatio = goal == 'lose' ? 0.28 : 0.25;
    var fatCal = calories * fatRatio;
    var fatG = fatCal / 9;

    var carbsCal = calories - proteinCal - fatCal;
    if (carbsCal < 0) {
      proteinG = (calories * 0.3) / 4;
      proteinCal = proteinG * 4;
      fatG = (calories * 0.25) / 9;
      fatCal = fatG * 9;
      carbsCal = calories - proteinCal - fatCal;
    }
    final carbsG = carbsCal / 4;

    return _MacroGrams(
      protein: proteinG,
      carbs: carbsG,
      fat: fatG,
    );
  }

  static String _bmiCategory(double bmi) {
    if (bmi < 18.5) return 'Zayıf';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Fazla kilolu';
    return 'Obez';
  }
}

class _MacroGrams {
  final double protein;
  final double carbs;
  final double fat;

  const _MacroGrams({
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}
