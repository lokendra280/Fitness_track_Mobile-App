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
