class PeriodMetrics {
  final List<double> stepsPerDay, waterPerDay, sleepPerDay, caloriesPerDay;
  final double? weightChange;
  final int workoutCount;
  final double habitConsistency;

  PeriodMetrics({
    required this.stepsPerDay,
    required this.waterPerDay,
    required this.sleepPerDay,
    required this.caloriesPerDay,
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
  double get avgCalories => caloriesPerDay.isEmpty
      ? 0
      : caloriesPerDay.reduce((a, b) => a + b) / caloriesPerDay.length;

  Map<String, dynamic> toPromptMap() => {
        'avgSteps': avgSteps.round(),
        'avgWaterMl': avgWater.round(),
        'avgSleepHours': avgSleep.toStringAsFixed(1),
        'avgCalories': avgCalories.round(),
        'weightChangeKg': weightChange,
        'workoutCount': workoutCount,
        'habitConsistencyPct': (habitConsistency * 100).round(),
      };
}
