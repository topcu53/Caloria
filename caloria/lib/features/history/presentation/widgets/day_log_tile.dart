import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../meals/domain/entities/daily_log_summary.dart';
import '../../../meals/domain/entities/meal_entity.dart';
import '../../../meals/presentation/providers/daily_log_provider.dart';
import '../../../meals/presentation/widgets/meal_detail_sheet.dart';

class DayLogTile extends ConsumerWidget {
  final String dateKey;

  const DayLogTile({super.key, required this.dateKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(daySummaryProvider(dateKey));

    return summaryAsync.when(
      data: (summary) {
        if (summary.meals.isEmpty && summary.waterMl <= 0) {
          return const SizedBox.shrink();
        }
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            title: Text(
              _formatDate(summary.date),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${summary.totalCalories.toInt()} kcal · ${summary.meals.length} öğün'
              '${summary.waterMl > 0 ? ' · ${summary.waterMl.toInt()} ml su' : ''}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            children: [
              if (summary.waterMl > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(Icons.water_drop, size: 16, color: AppColors.water),
                      const SizedBox(width: 6),
                      Text('Su: ${summary.waterMl.toInt()} ml'),
                    ],
                  ),
                ),
              if (summary.meals.isNotEmpty) ...[
                _DayTotalsRow(summary: summary),
                const SizedBox(height: 12),
                ...summary.meals.map((m) => _HistoryMealRow(meal: m)),
              ],
            ],
          ),
        );
      },
      loading: () => const Card(
        child: ListTile(
          title: Text('Yükleniyor...'),
          trailing: CircularProgressIndicator(),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return 'Bugün';
    if (d == today.subtract(const Duration(days: 1))) return 'Dün';
    return '${date.day}.${date.month}.${date.year}';
  }
}

class _DayTotalsRow extends StatelessWidget {
  final DailyLogSummary summary;
  const _DayTotalsRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _Chip('P ${summary.totalProtein.toInt()}g', AppColors.protein),
        _Chip('K ${summary.totalCarbs.toInt()}g', AppColors.carbs),
        _Chip('Y ${summary.totalFat.toInt()}g', AppColors.fat),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;
  const _Chip(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _HistoryMealRow extends StatelessWidget {
  final MealEntity meal;
  const _HistoryMealRow({required this.meal});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => MealDetailSheet.show(context, meal),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(meal.foodName, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    '${_mealLabel(meal.mealType)} · ${meal.portion}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'P ${meal.protein.toInt()}g · K ${meal.carbs.toInt()}g · Y ${meal.fat.toInt()}g',
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
            Text(
              '${meal.calories.toInt()} kcal',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  static String _mealLabel(String type) {
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
