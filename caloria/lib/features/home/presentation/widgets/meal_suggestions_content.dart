import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/meal_suggestion_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/meal_suggestions_provider.dart';

/// Öğün önerilerinin tam içeriği (bildirim detayı vb.).
class MealSuggestionsContent extends ConsumerWidget {
  const MealSuggestionsContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestions = ref.watch(mealSuggestionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.lightbulb_outline, color: AppColors.primary),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Günün öğün önerileri',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              onPressed: () {
                ref.read(mealSuggestionRefreshProvider.notifier).state++;
              },
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Yenile',
              color: AppColors.primary,
            ),
          ],
        ),
        Text(
          'Tahmini toplam: ~${suggestions.totalCalories} kcal',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        MealSuggestionRow(
          icon: Icons.free_breakfast_rounded,
          label: 'Kahvaltı',
          item: suggestions.breakfast,
        ),
        const SizedBox(height: 8),
        MealSuggestionRow(
          icon: Icons.lunch_dining_rounded,
          label: 'Öğle',
          item: suggestions.lunch,
        ),
        const SizedBox(height: 8),
        MealSuggestionRow(
          icon: Icons.dinner_dining_rounded,
          label: 'Akşam',
          item: suggestions.dinner,
        ),
        const SizedBox(height: 8),
        MealSuggestionRow(
          icon: Icons.cookie_rounded,
          label: 'Ara öğün',
          item: suggestions.snacks,
        ),
      ],
    );
  }
}

class MealSuggestionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final MealSuggestionItem item;

  const MealSuggestionRow({
    super.key,
    required this.icon,
    required this.label,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    height: 1.35,
                  ),
                  children: [
                    TextSpan(
                      text: '$label: ',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(text: item.name),
                  ],
                ),
              ),
              Text(
                '~${item.calories} kcal',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
