import 'package:flutter/material.dart';

/// Animated horizontal bars showing today's tracked metrics against a
/// goal. Goals are placeholders (TODO) until real per-user goal values
/// are available from a goals/profile provider.
class DailyReportChart extends StatelessWidget {
  const DailyReportChart({
    super.key,
    required this.waterMl,
    required this.steps,
    required this.workoutCount,
    required this.sleepHours,
  });

  final int waterMl;
  final int steps;
  final int workoutCount;
  final double? sleepHours;

  // TODO: replace with real per-user goals once available.
  static const _waterGoalMl = 2500;
  static const _stepsGoal = 10000;
  static const _workoutGoal = 1;
  static const _sleepGoal = 8.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AnimatedMetricBar(
          label: 'Water',
          valueLabel: '$waterMl / $_waterGoalMl ml',
          progress: (waterMl / _waterGoalMl).clamp(0.0, 1.0),
          color: const Color(0xFF2FA8E0),
        ),
        const SizedBox(height: 14),
        _AnimatedMetricBar(
          label: 'Steps',
          valueLabel: '$steps / $_stepsGoal steps',
          progress: (steps / _stepsGoal).clamp(0.0, 1.0),
          color: const Color(0xFFE0A72F),
        ),
        const SizedBox(height: 14),
        _AnimatedMetricBar(
          label: 'Workouts',
          valueLabel: '$workoutCount / $_workoutGoal',
          progress: (workoutCount / _workoutGoal).clamp(0.0, 1.0),
          color: const Color(0xFFE05A2F),
        ),
        const SizedBox(height: 14),
        _AnimatedMetricBar(
          label: 'Sleep',
          valueLabel: sleepHours != null
              ? '${sleepHours!.toStringAsFixed(1)} / $_sleepGoal h'
              : '– / $_sleepGoal h',
          progress: ((sleepHours ?? 0) / _sleepGoal).clamp(0.0, 1.0),
          color: const Color(0xFF6E5AE0),
        ),
      ],
    );
  }
}

class _AnimatedMetricBar extends StatelessWidget {
  const _AnimatedMetricBar({
    required this.label,
    required this.valueLabel,
    required this.progress,
    required this.color,
  });

  final String label;
  final String valueLabel;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: text.labelLarge),
            Text(valueLabel, style: text.labelSmall),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, t, _) => Stack(
              children: [
                Container(
                  height: 10,
                  color: color.withValues(alpha: 0.15),
                ),
                FractionallySizedBox(
                  widthFactor: t,
                  child: Container(height: 10, color: color),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
