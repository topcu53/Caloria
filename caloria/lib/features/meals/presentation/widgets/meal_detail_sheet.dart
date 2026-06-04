import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/meal_entity.dart';
import '../providers/meal_provider.dart';

class MealDetailSheet extends ConsumerWidget {
  final MealEntity meal;

  const MealDetailSheet({super.key, required this.meal});

  static Future<void> show(BuildContext context, MealEntity meal) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => MealDetailSheet(meal: meal),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final time = DateFormat('HH:mm').format(meal.createdAt);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            meal.foodName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_mealTypeLabel(meal.mealType)} · $time',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          if (meal.portion.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Porsiyon: ${meal.portion}',
              style: const TextStyle(fontSize: 15),
            ),
          ],
          const SizedBox(height: 24),
          _MacroRow(
            label: 'Kalori',
            value: '${meal.calories.toInt()} kcal',
            color: AppColors.calories,
          ),
          const SizedBox(height: 12),
          _MacroRow(
            label: 'Protein',
            value: '${meal.protein.toStringAsFixed(1)} g',
            color: AppColors.protein,
          ),
          const SizedBox(height: 12),
          _MacroRow(
            label: 'Karbonhidrat',
            value: '${meal.carbs.toStringAsFixed(1)} g',
            color: AppColors.carbs,
          ),
          const SizedBox(height: 12),
          _MacroRow(
            label: 'Yağ',
            value: '${meal.fat.toStringAsFixed(1)} g',
            color: AppColors.fat,
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Kapat'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () async {
                    final date = ref.read(selectedDateProvider);
                    await ref.read(mealDataSourceProvider).deleteMeal(
                          meal.id,
                          meal.mealType,
                          date,
                        );
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
                  child: const Text('Sil'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _mealTypeLabel(String type) {
    switch (type) {
      case 'breakfast':
        return 'Kahvaltı';
      case 'lunch':
        return 'Öğle';
      case 'dinner':
        return 'Akşam';
      case 'snacks':
        return 'Ara öğün';
      default:
        return type;
    }
  }
}

class _MacroRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontSize: 15)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
