import 'package:flutter/material.dart';
import 'package:habitflow/core/widgets/animated_common.dart';
import 'package:habitflow/data/models/dashboard_ui_models.dart';

class MetricProgressRow extends StatelessWidget {
  final ProgressMetric metric;
  const MetricProgressRow({super.key, required this.metric});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration:
                BoxDecoration(color: metric.background, shape: BoxShape.circle),
            child: Icon(metric.icon, size: 20, color: metric.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(metric.label, style: textTheme.titleSmall),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: metric.progress.clamp(0, 1)),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOutCubic,
                      builder: (context, animatedValue, _) => Text(
                        '${(animatedValue * 100).round()}%',
                        style:
                            textTheme.labelLarge?.copyWith(color: metric.color),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(metric.valueLabel, style: textTheme.bodySmall),
                const SizedBox(height: 8),
                AnimatedProgressBar(
                    value: metric.progress, color: metric.color),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
