import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/data/repositories/journey_repository_provider.dart';
import 'package:habitflow/features/ai_plan/providers/ai_plan_provider.dart';

class PeriodMetrics {
  final List<double> stepsPerDay, waterPerDay, sleepPerDay;
  final double? weightChange;
  final int workoutCount;
  final double habitConsistency;
  PeriodMetrics({
    required this.stepsPerDay,
    required this.waterPerDay,
    required this.sleepPerDay,
    this.weightChange,
    required this.workoutCount,
    required this.habitConsistency,
  });

  double get avgSteps => stepsPerDay.isEmpty
      ? 0
      : stepsPerDay.reduce((a, b) => a + b) / stepsPerDay.length;
  double get avgWater => waterPerDay.isEmpty
      ? 0
      : waterPerDay.reduce((a, b) => a + b) / waterPerDay.length;
  double get avgSleep => sleepPerDay.isEmpty
      ? 0
      : sleepPerDay.reduce((a, b) => a + b) / sleepPerDay.length;

  Map<String, dynamic> toPromptMap() => {
        'avgSteps': avgSteps.round(),
        'avgWaterMl': avgWater.round(),
        'avgSleepHours': avgSleep.toStringAsFixed(1),
        'weightChangeKg': weightChange,
        'workoutCount': workoutCount,
        'habitConsistencyPct': (habitConsistency * 100).round(),
      };
}

PeriodMetrics _computeMetrics(dynamic repo, DateTime start, int days) {
  final steps = <double>[], water = <double>[], sleep = <double>[];
  int workouts = 0;
  for (var i = 0; i < days; i++) {
    final day = start.add(Duration(days: i));
    steps.add((repo.stepsFor(day) as int).toDouble());
    water.add((repo.waterFor(day) as int).toDouble());
    sleep.add((repo.sleepFor(day)?.hours as double?) ?? 0);
    workouts += (repo.workoutsFor(day) as List).length;
  }
  final habits = repo.habits() as List;
  final consistency = habits.isEmpty
      ? 0.0
      : habits.where((h) => h.streak > 0).length / habits.length;
  return PeriodMetrics(
    stepsPerDay: steps,
    waterPerDay: water,
    sleepPerDay: sleep,
    workoutCount: workouts,
    habitConsistency: consistency,
  );
}

final weeklyMetricsProvider =
    Provider.family<PeriodMetrics, DateTime>((ref, weekStart) {
  final repo = ref.watch(journeyRepositoryProvider);
  return _computeMetrics(repo, weekStart, 7);
});

final monthlyMetricsProvider =
    Provider.family<PeriodMetrics, DateTime>((ref, monthStart) {
  final repo = ref.watch(journeyRepositoryProvider);
  return _computeMetrics(repo, monthStart, 30);
});

final weeklyReviewProvider =
    FutureProvider.autoDispose.family<String, DateTime>((ref, weekStart) async {
  final metrics = ref.watch(weeklyMetricsProvider(weekStart));
  final gemini = ref.watch(geminiServiceProvider);
  return gemini.summarizeWeek(metrics.toPromptMap());
});

final monthlyReviewProvider = FutureProvider.autoDispose
    .family<String, DateTime>((ref, monthStart) async {
  final metrics = ref.watch(monthlyMetricsProvider(monthStart));
  final gemini = ref.watch(geminiServiceProvider);
  return gemini.summarizeMonth(metrics.toPromptMap());
});
