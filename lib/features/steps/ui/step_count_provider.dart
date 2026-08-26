import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/features/steps/controller/step_count_controller.dart';
import 'package:habitflow/features/steps/models/step_counter_summery.dart';

final stepCountControllerProvider = Provider<StepCountController>((ref) {
  return StepCountController.instance;
});

/// Runs the permission flow once per app session and caches the result.
/// Every other steps provider below watches this and short-circuits to
/// zero/empty data if access isn't granted, instead of each one
/// independently prompting for permission.
final healthAccessProvider =
    AsyncNotifierProvider<HealthAccessNotifier, HealthAccessStatus>(
  HealthAccessNotifier.new,
);

class HealthAccessNotifier extends AsyncNotifier<HealthAccessStatus> {
  @override
  Future<HealthAccessStatus> build() {
    return ref.read(stepCountControllerProvider).requestAccess();
  }

  /// Call from a "Grant access" / "Install Health Connect" button.
  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(stepCountControllerProvider).requestAccess(),
    );
  }
}

/// TODO: replace with a real per-user goal from settings/profile once
/// that exists — hardcoded for now, same default as before.
final stepGoalProvider = Provider<int>((ref) => 10000);

/// Real step count for a single calendar day (normalized to midnight,
/// so callers don't need to worry about time-of-day components).
final stepsForDateProvider =
    FutureProvider.autoDispose.family<int, DateTime>((ref, date) async {
  final access = await ref.watch(healthAccessProvider.future);
  if (access != HealthAccessStatus.authorized) return 0;

  final controller = ref.watch(stepCountControllerProvider);
  final normalized = DateTime(date.year, date.month, date.day);
  final now = DateTime.now();
  final isToday = normalized.year == now.year &&
      normalized.month == now.month &&
      normalized.day == now.day;

  final steps = isToday
      ? await controller.fetchTodaySteps()
      : await controller.fetchStepsForDate(normalized);
  return steps ?? 0;
});

/// Convenience shortcut for "today" specifically — this is what the
/// dashboard's Steps row should watch.
final todayStepsProvider = FutureProvider.autoDispose<int>((ref) {
  return ref.watch(stepsForDateProvider(_todayKey()).future);
});

/// Real per-day totals for the current week's bar chart.
final weeklyStepsProvider =
    FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final access = await ref.watch(healthAccessProvider.future);
  if (access != HealthAccessStatus.authorized) {
    return const {
      'Mon': 0,
      'Tue': 0,
      'Wed': 0,
      'Thu': 0,
      'Fri': 0,
      'Sat': 0,
      'Sun': 0
    };
  }
  final controller = ref.watch(stepCountControllerProvider);
  return controller.fetchWeeklySteps();
});

/// Full summary for the Step Counter screen — real steps + weekly data,
/// goal from [stepGoalProvider]. Calories/distance/active-time are still
/// derived estimates (see TODO) since those need separate HealthDataTypes
/// (ACTIVE_ENERGY_BURNED, DISTANCE_WALKING_RUNNING) that aren't wired up
/// yet — swap the formulas below once you add those permissions/queries.
final stepsSummaryProvider = FutureProvider.autoDispose
    .family<StepsSummary, DateTime>((ref, date) async {
  final steps = await ref.watch(stepsForDateProvider(date).future);
  final weekly = await ref.watch(weeklyStepsProvider.future);
  final goal = ref.watch(stepGoalProvider);

  return StepsSummary(
    steps: steps,
    goal: goal,
    calories: (steps * 0.0645).round(),
    distanceKm: double.parse((steps * 0.00069).toStringAsFixed(1)),
    activeTime: Duration(minutes: (steps / 105).round()),
    weekly: weekly,
  );
});

DateTime _todayKey() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

final stepsProgressProvider = Provider<double>((ref) {
  final steps = ref.watch(todayStepsProvider).valueOrNull ?? 0;
  final goal = ref.watch(stepGoalProvider);
  if (goal <= 0) return 0.0;
  return (steps / goal).clamp(0.0, 1.0);
});
