import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/features/ai_plan/providers/ai_plan_provider.dart';
import 'package:habitflow/features/ai_plan/screens/daily_exercise_card.dart';

/// Thin route wrapper — GoRoute.builder only gets (context, state), not
/// ref, so this Consumer bridges to aiPlanControllerProvider to get the
/// actual generated plan's weeklySchedule.
class DailyWorkoutScheduleRoute extends ConsumerWidget {
  const DailyWorkoutScheduleRoute({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(aiPlanControllerProvider);

    if (plan == null) {
      return const Scaffold(
        body: Center(child: Text('No workout plan generated yet.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Your weekly schedule')),
      body: AiSuggestedScheduleList(weeklySchedule: plan.weeklySchedule),
    );
  }
}
