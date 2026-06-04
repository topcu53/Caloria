import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../meals/domain/entities/meal_entity.dart';
import '../../../meals/presentation/providers/meal_provider.dart';
import '../../../meals/presentation/widgets/meal_detail_sheet.dart';
import '../../../../core/theme/app_colors.dart';

class MealSection extends ConsumerWidget {
  final String title;
  final String mealType;
  final IconData icon;

  const MealSection({
    super.key,
    required this.title,
    required this.mealType,
    required this.icon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealsAsync = ref.watch(mealsProvider(mealType));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              mealsAsync.when(
                data: (meals) => Text(
                  '${meals.fold(0.0, (s, m) => s + m.calories).toInt()} kcal',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),
            ],
          ),
          mealsAsync.when(
            data: (meals) => meals.isEmpty
                ? const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      'Henüz yemek eklenmedi',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  )
                : Column(
                    children: meals
                        .map((meal) => _MealItem(meal: meal))
                        .toList(),
                  ),
            loading: () => const Padding(
              padding: EdgeInsets.only(top: 12),
              child: CircularProgressIndicator(),
            ),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
    );
  }
}

class _MealItem extends StatelessWidget {
  final MealEntity meal;

  const _MealItem({required this.meal});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => MealDetailSheet.show(context, meal),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal.foodName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (meal.portion.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          meal.portion,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${meal.calories.toInt()} kcal',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.primary,
                      ),
                    ),
                    const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _MacroChip(
                  label: 'P',
                  value: '${meal.protein.toInt()}g',
                  color: AppColors.protein,
                ),
                _MacroChip(
                  label: 'K',
                  value: '${meal.carbs.toInt()}g',
                  color: AppColors.carbs,
                ),
                _MacroChip(
                  label: 'Y',
                  value: '${meal.fat.toInt()}g',
                  color: AppColors.fat,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label $value',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
