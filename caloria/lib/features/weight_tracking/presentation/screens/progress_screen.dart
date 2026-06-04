import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../domain/entities/weight_log_entity.dart';
import '../providers/weight_provider.dart';
import '../widgets/nutrition_analytics_section.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('İlerleme'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Kilo'),
              Tab(text: 'Beslenme'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _WeightProgressTab(),
            NutritionAnalyticsSection(),
          ],
        ),
      ),
    );
  }
}

class _WeightProgressTab extends ConsumerStatefulWidget {
  const _WeightProgressTab();

  @override
  ConsumerState<_WeightProgressTab> createState() => _WeightProgressTabState();
}

class _WeightProgressTabState extends ConsumerState<_WeightProgressTab> {
  final _weightController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _saveWeight() async {
    final w = double.tryParse(_weightController.text.replaceAll(',', '.'));
    if (w == null || w <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçerli bir kilo girin')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(weightNotifierProvider.notifier).saveMorningWeight(w);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sabah tartımı kaydedildi. Kalori hedefin güncellendi.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kayıt başarısız: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(weightLogsProvider);
    final todayAsync = ref.watch(todayWeightProvider);
    final profile = ref.watch(userProfileProvider).valueOrNull;

    todayAsync.whenData((log) {
      if (log != null && _weightController.text.isEmpty) {
        _weightController.text = log.weightKg.toStringAsFixed(1);
      }
    });

    final currentWeight = todayAsync.valueOrNull?.weightKg ??
        logsAsync.valueOrNull?.firstOrNull?.weightKg ??
        profile?.weight;
    final targetWeight = profile?.targetWeightKg;
    final goal = profile?.goal ?? 'maintain';

    return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (currentWeight != null && targetWeight != null)
            _WeightProgressCard(
              currentKg: currentWeight,
              targetKg: targetWeight,
              goal: goal,
              startKg: profile?.weight ?? currentWeight,
            )
          else if (targetWeight == null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade700.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber.shade800),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Hedef kilonuzu Profil sekmesinden girebilirsiniz.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          Text(
            'Sabah tartımı (isteğe bağlı)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tartım yazarsan günlük kalori hedeflerin güncellenir. Yazmazsan aynı hedef devam eder.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _weightController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Bugünkü kilo (kg)',
                    border: OutlineInputBorder(),
                    suffixText: 'kg',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: _saving ? null : _saveWeight,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(100, 52),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Kaydet'),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            'Kilo grafiği',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          logsAsync.when(
            data: (logs) {
              if (logs.length < 2) {
                return Container(
                  height: 120,
                  alignment: Alignment.center,
                  child: Text(
                    'Grafik için en az 2 gün tartım gerekir.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                );
              }
              return SizedBox(
                height: 220,
                child: _WeightChart(
                  logs: logs.reversed.toList(),
                  targetKg: targetWeight,
                ),
              );
            },
            loading: () => const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
    );
  }
}

class _WeightProgressCard extends StatelessWidget {
  final double currentKg;
  final double targetKg;
  final String goal;
  final double startKg;

  const _WeightProgressCard({
    required this.currentKg,
    required this.targetKg,
    required this.goal,
    required this.startKg,
  });

  @override
  Widget build(BuildContext context) {
    final diff = currentKg - targetKg;
    final totalToGo = (startKg - targetKg).abs();
    final done = (startKg - currentKg).abs();
    final progress = totalToGo > 0 ? (done / totalToGo).clamp(0.0, 1.0) : 0.0;

    String statusText;
    if (goal == 'lose') {
      statusText = diff > 0
          ? 'Hedefe ${diff.toStringAsFixed(1)} kg kaldı'
          : 'Hedef kiloya ulaştın veya altındasın';
    } else if (goal == 'gain') {
      statusText = diff < 0
          ? 'Hedefe ${(-diff).toStringAsFixed(1)} kg kaldı'
          : 'Hedef kiloya ulaştın veya üstündesin';
    } else {
      statusText = 'Hedef: ${targetKg.toStringAsFixed(1)} kg (koruma)';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kilo ilerlemesi',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Stat('Şimdi', '${currentKg.toStringAsFixed(1)} kg'),
              _Stat('Hedef', '${targetKg.toStringAsFixed(1)} kg'),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: goal == 'maintain' ? null : progress,
              minHeight: 10,
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _WeightChart extends StatelessWidget {
  final List<WeightLogEntity> logs;
  final double? targetKg;

  const _WeightChart({required this.logs, this.targetKg});

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];
    for (var i = 0; i < logs.length; i++) {
      spots.add(FlSpot(i.toDouble(), logs[i].weightKg));
    }

    final weights = logs.map((e) => e.weightKg).toList();
    if (targetKg != null) weights.add(targetKg!);
    final minY = weights.reduce((a, b) => a < b ? a : b) - 2;
    final maxY = weights.reduce((a, b) => a > b ? a : b) + 2;

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (v, _) => Text(
                v.toInt().toString(),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}
