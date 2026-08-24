class StepsSummary {
  final int steps;
  final int goal;
  final int calories;
  final double distanceKm;
  final Duration activeTime;
  final Map<String, int> weekly; // Mon..Sun

  const StepsSummary({
    required this.steps,
    required this.goal,
    required this.calories,
    required this.distanceKm,
    required this.activeTime,
    required this.weekly,
  });

  double get progress => (steps / goal).clamp(0.0, 1.0);
  int get remaining => (goal - steps).clamp(0, goal);
  int get percent => (progress * 100).round();
}
