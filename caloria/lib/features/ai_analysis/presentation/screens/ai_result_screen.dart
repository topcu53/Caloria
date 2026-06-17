import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/calendar_day_provider.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../meals/data/datasources/meal_remote_datasource.dart';
import '../../../meals/domain/entities/meal_entity.dart';
import '../providers/ai_analysis_provider.dart';

class AiResultScreen extends ConsumerWidget {
  const AiResultScreen({super.key});

  static String formatError(Object? error) {
    if (error == null) return 'Analiz başarısız. Tekrar deneyin.';
    final text = error.toString();
    if (text.startsWith('Exception: ')) {
      return text.replaceFirst('Exception: ', '');
    }
    return text;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisState = ref.watch(aiAnalysisProvider);
    final analysis = analysisState.valueOrNull;

    if (analysisState.hasError) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hata')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  formatError(analysisState.error),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    ref.read(aiAnalysisProvider.notifier).reset();
                    context.go(AppRoutes.home);
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Geri dön'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (analysis == null) {
      return const Scaffold(body: Center(child: Text('Sonuç bulunamadı')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analiz Sonucu'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            ref.read(aiAnalysisProvider.notifier).reset();
            context.go(AppRoutes.home);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Yemek adı kartı
              Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.restaurant_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    analysis.food,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    analysis.portion,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Kalori
            _NutritionRow(
              label: 'Kalori',
              value: '${analysis.calories.toInt()} kcal',
              color: AppColors.calories,
              icon: Icons.local_fire_department_rounded,
            ),
            const Divider(),
            _NutritionRow(
              label: 'Protein',
              value: '${analysis.protein.toInt()} g',
              color: AppColors.protein,
              icon: Icons.fitness_center_rounded,
            ),
            const Divider(),
            _NutritionRow(
              label: 'Karbonhidrat',
              value: '${analysis.carbs.toInt()} g',
              color: AppColors.carbs,
              icon: Icons.grain_rounded,
            ),
            const Divider(),
            _NutritionRow(
              label: 'Yağ',
              value: '${analysis.fat.toInt()} g',
              color: AppColors.fat,
              icon: Icons.water_drop_rounded,
            ),

            const SizedBox(height: 28),

            // Kaydet butonları
            Text(
              'Hangi öğüne eklensin?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SaveButton(
                    label: 'Kahvaltı',
                    mealType: 'breakfast',
                    analysis: analysis,
                    ref: ref,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SaveButton(
                    label: 'Öğle',
                    mealType: 'lunch',
                    analysis: analysis,
                    ref: ref,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _SaveButton(
                    label: 'Akşam',
                    mealType: 'dinner',
                    analysis: analysis,
                    ref: ref,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SaveButton(
                    label: 'Ara Öğün',
                    mealType: 'snacks',
                    analysis: analysis,
                    ref: ref,
                  ),
                ),
              ],
            ),
          ],
          ),
        ),
      ),
    );
  }
}

class _NutritionRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _NutritionRow({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final String label;
  final String mealType;
  final dynamic analysis;
  final WidgetRef ref;

  const _SaveButton({
    required this.label,
    required this.mealType,
    required this.analysis,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final meal = MealEntity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          foodName: analysis.food,
          calories: analysis.calories,
          protein: analysis.protein,
          carbs: analysis.carbs,
          fat: analysis.fat,
          portion: analysis.portion,
          mealType: mealType,
          createdAt: DateTime.now(),
        );
        final day = ref.read(calendarDayProvider);
        await MealRemoteDataSource().saveMeal(meal, day);
        ref.read(aiAnalysisProvider.notifier).reset();
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('$label\'a kaydedildi!')));
          context.go(AppRoutes.home);
        }
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 13)),
    );
  }
}
