import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CalorieSummaryCard extends StatelessWidget {
  final double consumed;
  final double goal;

  const CalorieSummaryCard({
    super.key,
    required this.consumed,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = goal - consumed;
    final progress = (consumed / goal).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatItem(
                label: 'Tüketilen',
                value: consumed.toInt().toString(),
                unit: 'kcal',
                color: Colors.white,
              ),
              _CircularCalorie(progress: progress, remaining: remaining),
              _StatItem(
                label: 'Hedef',
                value: goal.toInt().toString(),
                unit: 'kcal',
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircularCalorie extends StatelessWidget {
  final double progress;
  final double remaining;

  const _CircularCalorie({required this.progress, required this.remaining});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            valueColor: const AlwaysStoppedAnimation(Colors.white),
            strokeWidth: 8,
          ),
        ),
        Column(
          children: [
            Text(
              remaining.toInt().toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Text(
              'kalan',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
              color: color, fontSize: 22, fontWeight: FontWeight.w800),
        ),
        Text(unit, style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 11)),
      ],
    );
  }
}