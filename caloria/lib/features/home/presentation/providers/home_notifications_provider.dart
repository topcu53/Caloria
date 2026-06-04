import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/calendar_day_provider.dart';

String _dayKey(DateTime day) => '${day.year}-${day.month}-${day.day}';

/// Günün öğün önerisi bildirimi görüldü mü (gün bazlı).
final mealSuggestionNotificationReadProvider =
    StateProvider<String?>((ref) => null);

final mealSuggestionNotificationUnreadProvider = Provider<bool>((ref) {
  final day = ref.watch(calendarDayProvider);
  final readKey = ref.watch(mealSuggestionNotificationReadProvider);
  return readKey != _dayKey(day);
});

void markMealSuggestionNotificationRead(WidgetRef ref) {
  final day = ref.read(calendarDayProvider);
  ref.read(mealSuggestionNotificationReadProvider.notifier).state =
      _dayKey(day);
}
