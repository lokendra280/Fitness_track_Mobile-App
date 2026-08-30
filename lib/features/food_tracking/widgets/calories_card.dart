import 'package:flutter/material.dart';

class CalorieCard extends StatelessWidget {
  final double eaten;
  final double target;
  const CalorieCard({super.key, required this.eaten, required this.target});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final remaining = (target - eaten).clamp(0, target);
    final progress = target == 0 ? 0.0 : (eaten / target).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Calories', style: text.titleMedium),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('${eaten.round()} cal',
                  style: text.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(width: 6),
              Text('/ ${target.round()}',
                  style:
                      text.bodyMedium?.copyWith(color: Colors.grey.shade500)),
              const Spacer(),
              Text('${remaining.round()} left',
                  style:
                      text.bodyMedium?.copyWith(color: Colors.grey.shade500)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation(Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
