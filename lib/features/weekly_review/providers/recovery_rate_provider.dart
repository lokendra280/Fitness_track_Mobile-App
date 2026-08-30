import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/data/repositories/journey_repository_provider.dart';
import 'package:habitflow/features/ai_plan/providers/ai_plan_provider.dart';

class RecoveryRateSeries {
  /// One value per calendar day in the requested range, oldest first,
  /// each 0-100.
  final List<double> valuesPerDay;
  final double average;

  const RecoveryRateSeries({
    required this.valuesPerDay,
    required this.average,
  });
}

typedef _DateRange = ({DateTime start, DateTime end});

/// Recovery rate = avg(weight-goal progress, exercise compliance) per
/// day, each 0-100%.
///
/// Weight-goal progress: how much of (startingWeight - targetWeight) has
/// been closed as of that day's most recent logged weight. If no weight
/// goal is set (start == target, or either is missing), this component
/// contributes 0 rather than being excluded — a missing goal isn't
/// "perfect progress."
///
/// Exercise compliance: completed exercises / planned exercises that
/// day. Rest days (or days with no plan) count as fully compliant
/// (100%) since nothing was required.
final recoveryRateProvider =
    Provider.family.autoDispose<RecoveryRateSeries, _DateRange>((ref, range) {
  final repo = ref.watch(journeyRepositoryProvider);
  final plan = ref.watch(aiPlanControllerProvider);
  final goal = repo.loadGoal();

  final startWeight = goal.startingWeight;
  final targetWeight = goal.targetWeight;
  final hasWeightGoal = startWeight != null &&
      targetWeight != null &&
      startWeight != targetWeight;
  final totalGoalDelta = hasWeightGoal ? (startWeight! - targetWeight!) : null;

  final weightLog = repo.weightLogEntriesInRange(range.start, range.end)
    ..sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));

  double? weightOnOrBefore(DateTime day) {
    double? last;
    for (final e in weightLog) {
      final d = DateTime.parse(e['date'] as String);
      if (d.isAfter(day)) break;
      last = (e['weight'] as num).toDouble();
    }
    return last;
  }

  final values = <double>[];
  var day = DateTime(range.start.year, range.start.month, range.start.day);
  final end = DateTime(range.end.year, range.end.month, range.end.day);

  while (!day.isAfter(end)) {
    // --- weight component ---
    double weightRatio = 0.0;
    if (hasWeightGoal) {
      final loggedWeight = weightOnOrBefore(day) ?? startWeight!;
      final lossSoFar = startWeight! - loggedWeight;
      weightRatio = (lossSoFar / totalGoalDelta!).clamp(0.0, 1.0);
    }

    // --- exercise component ---
    double exerciseRatio = 1.0;
    final workout = plan?.workoutForWeekday(day);
    if (workout != null && !workout.isRestDay && workout.exercises.isNotEmpty) {
      final completed = repo.completedExercisesFor(day);
      final done =
          workout.exercises.where((e) => completed.contains(e.name)).length;
      exerciseRatio = done / workout.exercises.length;
    }

    values.add(((weightRatio + exerciseRatio) / 2) * 100);
    day = day.add(const Duration(days: 1));
  }

  final avg =
      values.isEmpty ? 0.0 : values.reduce((a, b) => a + b) / values.length;
  return RecoveryRateSeries(valuesPerDay: values, average: avg);
});
