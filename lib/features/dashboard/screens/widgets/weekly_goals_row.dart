import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/theme/app_theme.dart';
import 'package:habitflow/features/dashboard/providers/dashboard_providers.dart';
import 'package:habitflow/features/dashboard/screens/widgets/goal_ring_card.dart';
import 'package:habitflow/features/steps/ui/step_count_provider.dart';

class WeeklyGoalsRow extends ConsumerWidget {
  const WeeklyGoalsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    final normalized = DateTime(today.year, today.month, today.day);

    final summaryAsync = ref.watch(stepsSummaryProvider(normalized));
    final realSteps = ref.watch(todayStepsProvider).valueOrNull ?? 0;
    final stepsGoal = summaryAsync.valueOrNull?.goal ?? 10000;
    final stepsProgress = (realSteps / stepsGoal).clamp(0.0, 1.0);

    final data = ref.watch(dashboardDataProvider);
    final waterCurrentMl = (data.waterProgress * data.waterTarget).round();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: GoalRingCard(
            periodLabel: 'DAILY',
            streakCount: 0,
            ringColor: AppColors.steps,
            progress: stepsProgress,
            title: 'Steps',
            value: _formatSteps(realSteps),
            unit: 'steps',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GoalRingCard(
            periodLabel: 'DAILY',
            streakCount: 0,
            ringColor: AppColors.water,
            progress: data.waterProgress.clamp(0.0, 1.0),
            title: 'Water',
            value: waterCurrentMl >= 1000
                ? (waterCurrentMl / 1000).toStringAsFixed(1)
                : '$waterCurrentMl',
            unit: waterCurrentMl >= 1000 ? 'L' : 'ml',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GoalRingCard(
            periodLabel: 'DAILY',
            streakCount: 0,
            ringColor: AppColors.calories,
            progress: data.calorieProgress.clamp(0.0, 1.0),
            title: 'Calories',
            value: '${(data.calorieProgress * 100).round()}',
            unit: '%',
          ),
        ),
      ],
    );
  }

  String _formatSteps(int n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(1)}k';
    }
    return '$n';
  }
}
