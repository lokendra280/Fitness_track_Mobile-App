import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../ai_plan/providers/ai_plan_provider.dart';
import '../../data/repositories/journey_repository_provider.dart';

class PeriodMetrics {
  final List<double> stepsPerDay, waterPerDay, sleepPerDay;
  final double? weightChange;
  final int workoutCount;
  final double habitConsistency;
  PeriodMetrics({required this.stepsPerDay, required this.waterPerDay, required this.sleepPerDay, this.weightChange, required this.workoutCount, required this.habitConsistency});

  double get avgSteps => stepsPerDay.isEmpty ? 0 : stepsPerDay.reduce((a, b) => a + b) / stepsPerDay.length;
  double get avgWater => waterPerDay.isEmpty ? 0 : waterPerDay.reduce((a, b) => a + b) / waterPerDay.length;
  double get avgSleep => sleepPerDay.isEmpty ? 0 : sleepPerDay.reduce((a, b) => a + b) / sleepPerDay.length;

  Map<String, dynamic> toPromptMap() => {
        'avgSteps': avgSteps.round(), 'avgWaterMl': avgWater.round(), 'avgSleepHours': avgSleep.toStringAsFixed(1),
        'weightChangeKg': weightChange, 'workoutCount': workoutCount, 'habitConsistencyPct': (habitConsistency * 100).round(),
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
  final consistency = habits.isEmpty ? 0.0 : habits.where((h) => h.streak > 0).length / habits.length;
  return PeriodMetrics(stepsPerDay: steps, waterPerDay: water, sleepPerDay: sleep, workoutCount: workouts, habitConsistency: consistency);
}

final weeklyMetricsProvider = Provider.family<PeriodMetrics, DateTime>((ref, weekStart) {
  final repo = ref.watch(journeyRepositoryProvider);
  return _computeMetrics(repo, weekStart, 7);
});

final monthlyMetricsProvider = Provider.family<PeriodMetrics, DateTime>((ref, monthStart) {
  final repo = ref.watch(journeyRepositoryProvider);
  return _computeMetrics(repo, monthStart, 30);
});

final weeklyReviewProvider = FutureProvider.autoDispose.family<String, DateTime>((ref, weekStart) async {
  final metrics = ref.watch(weeklyMetricsProvider(weekStart));
  final gemini = ref.watch(geminiServiceProvider);
  return gemini.summarizeWeek(metrics.toPromptMap());
});

final monthlyReviewProvider = FutureProvider.autoDispose.family<String, DateTime>((ref, monthStart) async {
  final metrics = ref.watch(monthlyMetricsProvider(monthStart));
  final gemini = ref.watch(geminiServiceProvider);
  return gemini.summarizeMonth(metrics.toPromptMap());
});

class _TrendChart extends StatelessWidget {
  final String title;
  final List<double> values;
  const _TrendChart({required this.title, required this.values});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      SizedBox(
        height: 120,
        child: LineChart(LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [for (var i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i])],
              isCurved: true,
              dotData: const FlDotData(show: false),
              color: Theme.of(context).colorScheme.primary,
              barWidth: 3,
            ),
          ],
        )),
      ),
      const SizedBox(height: 20),
    ]);
  }
}

class WeeklyReviewScreen extends ConsumerWidget {
  const WeeklyReviewScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekStart = DateTime.now().subtract(const Duration(days: 7));
    final metrics = ref.watch(weeklyMetricsProvider(weekStart));
    final review = ref.watch(weeklyReviewProvider(weekStart));
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly review')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Wrap(spacing: 16, runSpacing: 8, children: [
          Text('Avg steps: ${metrics.avgSteps.round()}'),
          Text('Avg water: ${metrics.avgWater.round()}ml'),
          Text('Avg sleep: ${metrics.avgSleep.toStringAsFixed(1)}h'),
          Text('Workouts: ${metrics.workoutCount}'),
          Text('Habit consistency: ${(metrics.habitConsistency * 100).round()}%'),
        ]),
        const SizedBox(height: 20),
        _TrendChart(title: 'Steps trend', values: metrics.stepsPerDay),
        _TrendChart(title: 'Water trend', values: metrics.waterPerDay),
        _TrendChart(title: 'Sleep trend', values: metrics.sleepPerDay),
        const Text('AI analysis', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 8),
        review.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('$e'),
          data: (text) => Text(text),
        ),
      ]),
    );
  }
}

class MonthlyReviewScreen extends ConsumerWidget {
  const MonthlyReviewScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthStart = DateTime.now().subtract(const Duration(days: 30));
    final metrics = ref.watch(monthlyMetricsProvider(monthStart));
    final review = ref.watch(monthlyReviewProvider(monthStart));
    return Scaffold(
      appBar: AppBar(title: const Text('Monthly review')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Wrap(spacing: 16, runSpacing: 8, children: [
          Text('Avg steps: ${metrics.avgSteps.round()}'),
          Text('Avg water: ${metrics.avgWater.round()}ml'),
          Text('Avg sleep: ${metrics.avgSleep.toStringAsFixed(1)}h'),
          Text('Workouts: ${metrics.workoutCount}'),
          Text('Habit consistency: ${(metrics.habitConsistency * 100).round()}%'),
        ]),
        const SizedBox(height: 20),
        _TrendChart(title: 'Steps trend', values: metrics.stepsPerDay),
        _TrendChart(title: 'Water trend', values: metrics.waterPerDay),
        const Text('AI analysis', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 8),
        review.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('$e'),
          data: (text) => Text(text),
        ),
      ]),
    );
  }
}
