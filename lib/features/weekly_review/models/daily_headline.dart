class DailyHeadline {
  final int steps;
  final int stepGoal;
  final double stepProgress; // 0.0–1.0
  final double calories;
  final int calorieTarget;
  final double calorieProgress; // 0.0–1.0
  final int water;
  final double sleepHours;
  final int workoutCount;

  const DailyHeadline({
    required this.steps,
    required this.stepGoal,
    required this.stepProgress,
    required this.calories,
    required this.calorieTarget,
    required this.calorieProgress,
    required this.water,
    required this.sleepHours,
    required this.workoutCount,
  });
}
