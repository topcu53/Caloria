import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/calendar_day_provider.dart';
import '../../../../core/services/meal_suggestion_service.dart';

final mealSuggestionRefreshProvider = StateProvider<int>((ref) => 0);

final mealSuggestionsProvider = Provider<MealSuggestions>((ref) {
  final refresh = ref.watch(mealSuggestionRefreshProvider);
  final day = ref.watch(calendarDayProvider);
  return MealSuggestionService.forDate(day, refreshSeed: refresh);
});
