import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../meals/domain/entities/meal_entity.dart';
import '../../../meals/presentation/providers/meal_provider.dart';
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
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              const Spacer(),
              mealsAsync.when(
                data: (meals) => Text(
                  '${meals.fold(0.0, (s, m) => s + m.calories).toInt()} kcal',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
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
                    child: Text('Henüz yemek eklenmedi',
                        style: TextStyle(color: Colors.grey, fontSize: 13)),
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
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meal.foodName,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                Text(meal.portion,
                    style:
                        const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Text(
            '${meal.calories.toInt()} kcal',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}