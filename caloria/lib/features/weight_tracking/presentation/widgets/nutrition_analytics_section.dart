import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../meals/domain/entities/daily_log_summary.dart';
import '../../../profile/domain/entities/user_profile_entity.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/nutrition_analytics_provider.dart';

enum _MacroMetric { calories, protein, carbs, fat }

class NutritionAnalyticsSection extends ConsumerStatefulWidget {
  const NutritionAnalyticsSection({super.key});

  @override
  ConsumerState<NutritionAnalyticsSection> createState() =>
      _NutritionAnalyticsSectionState();
}

class _NutritionAnalyticsSectionState
    extends ConsumerState<NutritionAnalyticsSection> {
  int _days = 7;
  _MacroMetric _metric = _MacroMetric.calories;

  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(nutritionAnalyticsProvider(_days));
    final profile = ref.watch(userProfileProvider).valueOrNull;

    return analyticsAsync.when(
      data: (summaries) {
        if (summaries.isEmpty ||
            summaries.every((s) => s.meals.isEmpty)) {
          return _EmptyAnalytics(days: _days);
        }

        final averages = NutritionAverages.fromSummaries(summaries);

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(nutritionAnalyticsProvider(_days));
          },
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Beslenme analizi',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Günlük değerler sütun grafik olarak gösterilir; kaydırarak tüm günleri görebilirsiniz.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 7, label: Text('7 gün')),
                  ButtonSegment(value: 14, label: Text('14 gün')),
                ],
                selected: {_days},
                onSelectionChanged: (s) {
                  if (s.isEmpty) return;
                  setState(() => _days = s.first);
                },
              ),
              const SizedBox(height: 20),
              _AveragesCard(averages: averages, days: _days, profile: profile),
              const SizedBox(height: 24),
              _SectionTitle('Günlük sütun grafiği'),
              const SizedBox(height: 8),
              SegmentedButton<_MacroMetric>(
                segments: const [
                  ButtonSegment(
                    value: _MacroMetric.calories,
                    label: Text('Kalori'),
                  ),
                  ButtonSegment(
                    value: _MacroMetric.protein,
                    label: Text('Protein'),
                  ),
                  ButtonSegment(
                    value: _MacroMetric.carbs,
                    label: Text('Karb.'),
                  ),
                  ButtonSegment(
                    value: _MacroMetric.fat,
                    label: Text('Yağ'),
                  ),
                ],
                selected: {_metric},
                onSelectionChanged: (s) {
                  if (s.isEmpty) return;
                  setState(() => _metric = s.first);
                },
              ),
              const SizedBox(height: 12),
              _MetricColumnChart(
                summaries: summaries,
                metric: _metric,
                profile: profile,
              ),
              const SizedBox(height: 24),
              _SectionTitle('Makrolar (günlük sütunlar)'),
              const SizedBox(height: 8),
              const _MacroLegend(),
              const SizedBox(height: 8),
              _MacroGroupedColumnChart(summaries: summaries),
              const SizedBox(height: 24),
              _SectionTitle('Kalori — hedef karşılaştırma'),
              const SizedBox(height: 8),
              _CalorieColumnChart(
                summaries: summaries,
                calorieGoal: profile?.dailyCalorieGoal ?? 2000,
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Veri yüklenemedi: $e')),
    );
  }
}

/// Y ekseni: yuvarlak üst sınır + sabit aralık → etiketler üst üste binmez.
class _ChartYScale {
  final double maxY;
  final double interval;

  const _ChartYScale({required this.maxY, required this.interval});

  factory _ChartYScale.fromPeak(double peak, {int tickCount = 5}) {
    if (peak <= 0) {
      return const _ChartYScale(maxY: 100, interval: 25);
    }
    final interval = _niceInterval(peak / (tickCount - 1));
    var maxY = interval * (tickCount - 1);
    while (maxY < peak) {
      maxY += interval;
    }
    return _ChartYScale(maxY: maxY, interval: interval);
  }

  static double _niceInterval(double raw) {
    if (raw <= 0) return 10;
    var magnitude = 1.0;
    while (magnitude * 10 < raw) {
      magnitude *= 10;
    }
    final normalized = raw / magnitude;
    double nice;
    if (normalized <= 1.5) {
      nice = 1;
    } else if (normalized <= 3) {
      nice = 2;
    } else if (normalized <= 7) {
      nice = 5;
    } else {
      nice = 10;
    }
    return nice * magnitude;
  }

  static _ChartYScale forData(Iterable<double> values, {double? extraPeak}) {
    var peak = 0.0;
    for (final v in values) {
      if (v > peak) peak = v;
    }
    if (extraPeak != null && extraPeak > peak) peak = extraPeak;
    return _ChartYScale.fromPeak(peak);
  }

  bool shouldShowLabel(double value) {
    if (value < 0 || value > maxY + 0.001) return false;
    final remainder = value % interval;
    return remainder < 0.001 || (interval - remainder) < 0.001;
  }

  String formatLabel(double value) {
    if (value >= 1000 && interval >= 500) {
      final k = value / 1000;
      return k == k.roundToDouble()
          ? '${k.toInt()}k'
          : '${k.toStringAsFixed(1)}k';
    }
    return value.toInt().toString();
  }

  SideTitles leftTitles() {
    return SideTitles(
      showTitles: true,
      reservedSize: 48,
      interval: interval,
      getTitlesWidget: (value, meta) {
        if (!shouldShowLabel(value)) return const SizedBox.shrink();
        return Text(
          formatLabel(value),
          style: const TextStyle(fontSize: 10),
        );
      },
    );
  }

  FlGridData gridData() {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: interval,
      checkToShowHorizontalLine: (value) => shouldShowLabel(value),
      getDrawingHorizontalLine: (v) => FlLine(
        color: Colors.grey.withValues(alpha: 0.2),
        strokeWidth: 1,
      ),
    );
  }
}

/// Gün sayısına göre sütun genişliği ve boşluk; üst üste binmeyi önler.
class _ChartLayout {
  static double barWidth(int dayCount, {int barsPerGroup = 1}) {
    if (dayCount <= 7) return barsPerGroup == 1 ? 22 : 10;
    return barsPerGroup == 1 ? 14 : 7;
  }

  static double groupsSpace(int dayCount) {
    return dayCount <= 7 ? 20 : 12;
  }

  static double chartWidth(int dayCount) {
    final perDay = dayCount <= 7 ? 52.0 : 40.0;
    return (dayCount * perDay).clamp(280, 720);
  }

  static bool showBottomLabel(int index, int total) {
    if (total <= 7) return true;
    return index.isEven;
  }
}

class _ScrollableChart extends StatelessWidget {
  final int dayCount;
  final double height;
  final Widget child;

  const _ScrollableChart({
    required this.dayCount,
    required this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final width = _ChartLayout.chartWidth(dayCount);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: width,
        height: height,
        child: child,
      ),
    );
  }
}

class _EmptyAnalytics extends StatelessWidget {
  final int days;
  const _EmptyAnalytics({required this.days});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_rounded, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'Henüz analiz için yeterli veri yok',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Öğün ekledikçe son $days günün grafikleri burada görünür.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

class _AveragesCard extends StatelessWidget {
  final NutritionAverages averages;
  final int days;
  final UserProfileEntity? profile;

  const _AveragesCard({
    required this.averages,
    required this.days,
    this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ortalama ($days gün, ${averages.daysWithMeals} kayıtlı gün)',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _AvgRow(
            'Kalori',
            '${averages.calories.toInt()} kcal',
            AppColors.calories,
            goal: profile?.dailyCalorieGoal,
          ),
          _AvgRow(
            'Protein',
            '${averages.protein.toInt()} g',
            AppColors.protein,
            goal: profile?.dailyProteinGoal,
          ),
          _AvgRow(
            'Karbonhidrat',
            '${averages.carbs.toInt()} g',
            AppColors.carbs,
            goal: profile?.dailyCarbsGoal,
          ),
          _AvgRow(
            'Yağ',
            '${averages.fat.toInt()} g',
            AppColors.fat,
            goal: profile?.dailyFatGoal,
          ),
        ],
      ),
    );
  }
}

class _AvgRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final double? goal;

  const _AvgRow(this.label, this.value, this.color, {this.goal});

  @override
  Widget build(BuildContext context) {
    final goalText = goal != null ? ' / hedef ${goal!.toInt()}' : '';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text(
            '$value$goalText',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _MacroLegend extends StatelessWidget {
  const _MacroLegend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 6,
      children: const [
        _LegendDot(color: AppColors.protein, label: 'Protein'),
        _LegendDot(color: AppColors.carbs, label: 'Karbonhidrat'),
        _LegendDot(color: AppColors.fat, label: 'Yağ'),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
      ],
    );
  }
}

class _MetricColumnChart extends StatelessWidget {
  final List<DailyLogSummary> summaries;
  final _MacroMetric metric;
  final UserProfileEntity? profile;

  const _MetricColumnChart({
    required this.summaries,
    required this.metric,
    this.profile,
  });

  double _value(DailyLogSummary s) {
    switch (metric) {
      case _MacroMetric.calories:
        return s.totalCalories;
      case _MacroMetric.protein:
        return s.totalProtein;
      case _MacroMetric.carbs:
        return s.totalCarbs;
      case _MacroMetric.fat:
        return s.totalFat;
    }
  }

  double? _goal() {
    switch (metric) {
      case _MacroMetric.calories:
        return profile?.dailyCalorieGoal;
      case _MacroMetric.protein:
        return profile?.dailyProteinGoal;
      case _MacroMetric.carbs:
        return profile?.dailyCarbsGoal;
      case _MacroMetric.fat:
        return profile?.dailyFatGoal;
    }
  }

  Color get _color {
    switch (metric) {
      case _MacroMetric.calories:
        return AppColors.calories;
      case _MacroMetric.protein:
        return AppColors.protein;
      case _MacroMetric.carbs:
        return AppColors.carbs;
      case _MacroMetric.fat:
        return AppColors.fat;
    }
  }

  @override
  Widget build(BuildContext context) {
    final n = summaries.length;
    final values = summaries.map(_value).toList();
    final goal = _goal();
    final scale = _ChartYScale.forData(values, extraPeak: goal);

    return _ScrollableChart(
      dayCount: n,
      height: 240,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: scale.maxY,
          minY: 0,
          groupsSpace: _ChartLayout.groupsSpace(n),
          gridData: scale.gridData(),
          extraLinesData: goal != null
              ? ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: goal,
                      color: Colors.grey.withValues(alpha: 0.55),
                      strokeWidth: 1.5,
                      dashArray: [6, 4],
                    ),
                  ],
                )
              : null,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: scale.leftTitles()),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= n) return const SizedBox();
                  if (!_ChartLayout.showBottomLabel(i, n)) {
                    return const SizedBox();
                  }
                  final d = summaries[i].date;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${d.day}/${d.month}',
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(n, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: _value(summaries[i]),
                  width: _ChartLayout.barWidth(n),
                  color: _color,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

/// Her gün için yan yana 3 sütun: protein, karbonhidrat, yağ.
class _MacroGroupedColumnChart extends StatelessWidget {
  final List<DailyLogSummary> summaries;

  const _MacroGroupedColumnChart({required this.summaries});

  @override
  Widget build(BuildContext context) {
    final n = summaries.length;
    final allValues = <double>[];
    for (final s in summaries) {
      allValues.addAll([s.totalProtein, s.totalCarbs, s.totalFat]);
    }
    final scale = _ChartYScale.forData(allValues);

    final barW = _ChartLayout.barWidth(n, barsPerGroup: 3);

    return _ScrollableChart(
      dayCount: n,
      height: 240,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: scale.maxY,
          minY: 0,
          groupsSpace: _ChartLayout.groupsSpace(n),
          gridData: scale.gridData(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: scale.leftTitles()),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= n) return const SizedBox();
                  if (!_ChartLayout.showBottomLabel(i, n)) {
                    return const SizedBox();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '${summaries[i].date.day}',
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(n, (i) {
            final s = summaries[i];
            return BarChartGroupData(
              x: i,
              barsSpace: 4,
              barRods: [
                BarChartRodData(
                  toY: s.totalProtein,
                  width: barW,
                  color: AppColors.protein,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
                BarChartRodData(
                  toY: s.totalCarbs,
                  width: barW,
                  color: AppColors.carbs,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
                BarChartRodData(
                  toY: s.totalFat,
                  width: barW,
                  color: AppColors.fat,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _CalorieColumnChart extends StatelessWidget {
  final List<DailyLogSummary> summaries;
  final double calorieGoal;

  const _CalorieColumnChart({
    required this.summaries,
    required this.calorieGoal,
  });

  @override
  Widget build(BuildContext context) {
    final n = summaries.length;
    final scale = _ChartYScale.forData(
      summaries.map((s) => s.totalCalories),
      extraPeak: calorieGoal,
    );

    return _ScrollableChart(
      dayCount: n,
      height: 220,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: scale.maxY,
          minY: 0,
          groupsSpace: _ChartLayout.groupsSpace(n),
          gridData: scale.gridData(),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: calorieGoal,
                color: AppColors.primary.withValues(alpha: 0.6),
                strokeWidth: 2,
                dashArray: [5, 5],
              ),
            ],
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: scale.leftTitles()),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= n) return const SizedBox();
                  if (!_ChartLayout.showBottomLabel(i, n)) {
                    return const SizedBox();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '${summaries[i].date.day}',
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(n, (i) {
            final cal = summaries[i].totalCalories;
            final over = cal > calorieGoal;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: cal,
                  width: _ChartLayout.barWidth(n),
                  color: over ? AppColors.warning : AppColors.calories,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
    );
  }
}
