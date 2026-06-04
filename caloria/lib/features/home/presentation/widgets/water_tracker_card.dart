import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/calendar_day_provider.dart';
import '../../../../core/services/water_reminder_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../meals/presentation/providers/daily_log_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

class WaterTrackerCard extends ConsumerWidget {
  const WaterTrackerCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waterAsync = ref.watch(todayWaterMlProvider);
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final goal = profile?.dailyWaterGoal ?? 2500;
    final reminderOn = profile?.waterReminderEnabled ?? true;

    return waterAsync.when(
      data: (waterMl) {
        final progress = (waterMl / goal).clamp(0.0, 1.0);
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.water_drop, color: AppColors.water),
                  const SizedBox(width: 8),
                  const Text(
                    'Su takibi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Text(
                    '${waterMl.toInt()} / ${goal.toInt()} ml',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.water,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: AppColors.water.withValues(alpha: 0.15),
                  color: AppColors.water,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _WaterButton(
                    label: '+250 ml',
                    onTap: () => _addWater(ref, 250),
                  ),
                  const SizedBox(width: 8),
                  _WaterButton(
                    label: '+500 ml',
                    onTap: () => _addWater(ref, 500),
                  ),
                  const SizedBox(width: 8),
                  IconButton.outlined(
                    onPressed: () => _addWater(ref, -250),
                    icon: const Icon(Icons.remove, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Su hatırlatıcı (30 dk)',
                  style: TextStyle(fontSize: 13),
                ),
                subtitle: const Text(
                  '22:00–09:00 arası bildirim yok',
                  style: TextStyle(fontSize: 11),
                ),
                value: reminderOn,
                onChanged: (v) async {
                  await ref
                      .read(profileNotifierProvider.notifier)
                      .setWaterReminderEnabled(v);
                  await WaterReminderService.instance.setEnabled(v);
                },
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Future<void> _addWater(WidgetRef ref, double delta) async {
    final ds = ref.read(dailyLogDataSourceProvider);
    final day = ref.read(calendarDayProvider);
    if (delta > 0) {
      await ds.addWaterMl(day, delta);
      return;
    }
    final current = ref.read(todayWaterMlProvider).valueOrNull ?? 0;
    await ds.setWaterMl(
      day,
      (current + delta).clamp(0, 10000).toDouble(),
    );
  }
}

class _WaterButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _WaterButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.water.withValues(alpha: 0.9),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        child: Text(label, style: const TextStyle(fontSize: 13)),
      ),
    );
  }
}
