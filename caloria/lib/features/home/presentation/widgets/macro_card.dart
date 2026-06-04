import 'package:flutter/material.dart';

class MacroCard extends StatelessWidget {
  final String label;
  final double value;
  final double goal;
  final Color color;
  final LinearGradient gradient;

  const MacroCard({
    super.key,
    required this.label,
    required this.value,
    required this.goal,
    required this.color,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (value / goal).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              label == 'Protein'
                  ? Icons.fitness_center_rounded
                  : label == 'Karbonhidrat'
                      ? Icons.grain_rounded
                      : Icons.water_drop_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${value.toInt()}g',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          Text(
            label,
            style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Hedef: ${goal.toInt()}g',
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}