import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/theme/app_theme.dart';
import 'package:habitflow/features/dashboard/providers/dashboard_providers.dart';
import 'package:habitflow/features/dashboard/screens/widgets/goal_ring_card.dart';
import 'package:habitflow/features/steps/ui/step_count_provider.dart';

/// Matches the screenshot's "Steps / Water / Calories" row. All three
/// rings are wired to real providers:
///  - Steps -> stepsSummaryProvider (per-day step count/progress)
///  - Water -> dashboardDataProvider (waterProgress / waterTarget)
///  - Calories -> dashboardDataProvider (calorieProgress)
class WeeklyGoalsRow extends ConsumerWidget {
  const WeeklyGoalsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    final normalized = DateTime(today.year, today.month, today.day);

    final summaryAsync = ref.watch(stepsSummaryProvider(normalized));
    final stepsProgress = summaryAsync.valueOrNull?.progress ?? 0.0;
    final stepsGoal = summaryAsync.valueOrNull?.goal ?? 10000;

    final data = ref.watch(dashboardDataProvider);
    final waterCurrentMl = (data.waterProgress * data.waterTarget).round();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: GoalRingCard(
            periodLabel: 'DAILY',
            streakCount: 0,
            icon: Icons.directions_walk_rounded,
            ringColor: AppColors.goalStepsColor,
            progress: stepsProgress,
            title: 'Steps',
            subtitle: _formatGoal(stepsGoal),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GoalRingCard(
            periodLabel: 'DAILY',
            streakCount: 0, // TODO: wire to a real water-streak provider
            icon: Icons.water_drop_rounded,
            ringColor: AppColors.goalCardioColor,
            progress: data.waterProgress.clamp(0.0, 1.0),
            title: 'Water',
            subtitle: '$waterCurrentMl / ${data.waterTarget} ml',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GoalRingCard(
            periodLabel: 'DAILY',
            streakCount: 0, // TODO: wire to a real calorie-streak provider
            icon: Icons.local_fire_department_rounded,
            ringColor: AppColors.goalStrengthColor,
            progress: data.calorieProgress.clamp(0.0, 1.0),
            title: 'Calories',
            subtitle: '${(data.calorieProgress * 100).round()}% of goal',
          ),
        ),
      ],
    );
  }

  String _formatGoal(int n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(0)}.000';
    }
    return '$n';
  }
}
