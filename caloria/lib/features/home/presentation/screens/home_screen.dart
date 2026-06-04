import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/calendar_day_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../meals/presentation/providers/daily_log_provider.dart';
import '../../../meals/presentation/providers/meal_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../widgets/calorie_summary_card.dart';
import '../widgets/meal_suggestions_app_bar_action.dart';
import '../widgets/macro_card.dart';
import '../widgets/meal_section.dart';
import '../widgets/profile_setup_banner.dart';
import '../widgets/water_tracker_card.dart';
import '../../../../core/widgets/app_bootstrap.dart';
import 'package:go_router/go_router.dart';
import '../../../../routes/app_routes.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dailySummaryProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final today = ref.watch(calendarDayProvider);
    final calorieGoal = profileAsync.valueOrNull?.dailyCalorieGoal ?? 2000;
    final proteinGoal = profileAsync.valueOrNull?.dailyProteinGoal ?? 150;
    final carbsGoal = profileAsync.valueOrNull?.dailyCarbsGoal ?? 250;
    final fatGoal = profileAsync.valueOrNull?.dailyFatGoal ?? 65;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Caloria'),
        actions: const [MealSuggestionsAppBarAction()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.camera),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.camera_alt_rounded, color: Colors.white),
        label: const Text('Analiz Et',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: AppBootstrap(
        child: RefreshIndicator(
        onRefresh: () async {
          ref.read(calendarDayProvider.notifier).syncToToday();
          ref.invalidate(mealsProvider);
          ref.invalidate(todayWaterMlProvider);
          ref.invalidate(historyDatesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Tarih
            Text(
              _todayText(today),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Günlük Özet',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 20),

            if (profileAsync.valueOrNull?.hasBodyMetrics != true)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: ProfileSetupBanner(),
              ),

            // Kalori Card
            CalorieSummaryCard(
              consumed: summary.totalCalories,
              goal: calorieGoal,
            ),
            const SizedBox(height: 16),

            // Macro Cards
            Row(
              children: [
                Expanded(
                  child: MacroCard(
                    label: 'Protein',
                    value: summary.totalProtein,
                    goal: proteinGoal,
                    color: AppColors.protein,
                    gradient: AppColors.proteinGradient,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MacroCard(
                    label: 'Karbonhidrat',
                    value: summary.totalCarbs,
                    goal: carbsGoal,
                    color: AppColors.carbs,
                    gradient: AppColors.carbsGradient,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MacroCard(
                    label: 'Yağ',
                    value: summary.totalFat,
                    goal: fatGoal,
                    color: AppColors.fat,
                    gradient: AppColors.fatGradient,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const WaterTrackerCard(),
            const SizedBox(height: 24),

            // Öğünler
            Text('Öğünler',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),

            const MealSection(
              title: 'Kahvaltı',
              mealType: 'breakfast',
              icon: Icons.free_breakfast_rounded,
            ),
            const SizedBox(height: 12),
            const MealSection(
              title: 'Öğle Yemeği',
              mealType: 'lunch',
              icon: Icons.lunch_dining_rounded,
            ),
            const SizedBox(height: 12),
            const MealSection(
              title: 'Akşam Yemeği',
              mealType: 'dinner',
              icon: Icons.dinner_dining_rounded,
            ),
            const SizedBox(height: 12),
            const MealSection(
              title: 'Ara Öğün',
              mealType: 'snacks',
              icon: Icons.cookie_rounded,
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      ),
    );
  }

  String _todayText(DateTime day) {
    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return '${day.day} ${months[day.month - 1]} ${day.year}';
  }
}
