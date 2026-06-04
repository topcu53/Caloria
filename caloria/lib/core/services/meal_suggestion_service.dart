/// Günlük yenilenebilir öğün önerileri (kalori tahmini ile).
class MealSuggestionService {
  static const _breakfast = [
    _Item('Yulaf ezmesi, muz ve badem', 380),
    _Item('Haşlanmış yumurta, tam buğday ekmeği, domates', 320),
    _Item('Menemen, az zeytinyağı, tam buğday', 410),
    _Item('Yoğurt, meyve ve chia tohumu', 290),
    _Item('Peynir, zeytin, tam buğday simidi', 350),
    _Item('Smoothie (süt, yaban mersini, yulaf)', 280),
    _Item('Sebzeli omlet, yeşil çay', 340),
  ];

  static const _lunch = [
    _Item('Izgara tavuk, bulgur pilavı, salata', 520),
    _Item('Mercimek çorbası, tam buğday ekmek', 380),
    _Item('Ton balıklı salata, zeytinyağı', 420),
    _Item('Köfte, közlenmiş sebze, ayran', 580),
    _Item('Nohut yemeği, pilav, cacık', 490),
    _Item('Izgara balık, roka salatası', 450),
    _Item('Tavuk sote, kinoa, yoğurt', 510),
  ];

  static const _dinner = [
    _Item('Fırında sebze, zeytinyağlı levrek', 420),
    _Item('Izgara hindi, salata, 1 dilim ekmek', 380),
    _Item('Sebzeli çorba, az peynir', 310),
    _Item('Karnıyarık (az yağlı), yoğurt', 440),
    _Item('Mantarlı omlet, yeşil salata', 360),
    _Item('Zeytinyağlı fasulye, turşu', 400),
    _Item('Izgara köfte, köz biber, salata', 470),
  ];

  static const _snacks = [
    _Item('Elma ve 10 adet badem', 180),
    _Item('Ayran ve 2 tam buğday kraker', 150),
    _Item('Meyveli yoğurt', 140),
    _Item('Humus, havuç çubukları', 160),
    _Item('Protein bar (düşük şeker)', 190),
    _Item('Kuru kayısı ve ceviz (az)', 170),
    _Item('Tam buğday tost, labne', 200),
  ];

  static MealSuggestions forDate(DateTime date, {int refreshSeed = 0}) {
    final seed = date.year * 1000 + date.month * 50 + date.day + refreshSeed;
    return MealSuggestions(
      breakfast: _pick(_breakfast, seed),
      lunch: _pick(_lunch, seed + 7),
      dinner: _pick(_dinner, seed + 13),
      snacks: _pick(_snacks, seed + 19),
      totalCalories: _pick(_breakfast, seed).calories +
          _pick(_lunch, seed + 7).calories +
          _pick(_dinner, seed + 13).calories +
          _pick(_snacks, seed + 19).calories,
    );
  }

  static MealSuggestionItem _pick(List<_Item> items, int seed) {
    final item = items[seed.abs() % items.length];
    return MealSuggestionItem(name: item.name, calories: item.calories);
  }
}

class _Item {
  final String name;
  final int calories;
  const _Item(this.name, this.calories);
}

class MealSuggestionItem {
  final String name;
  final int calories;
  const MealSuggestionItem({required this.name, required this.calories});
}

class MealSuggestions {
  final MealSuggestionItem breakfast;
  final MealSuggestionItem lunch;
  final MealSuggestionItem dinner;
  final MealSuggestionItem snacks;
  final int totalCalories;

  const MealSuggestions({
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.snacks,
    required this.totalCalories,
  });
}
