class DashboardData {
  final double? currentWeight;
  final double? targetWeight;
  final double? weightLost;
  final double? remainingWeight;
  final double? progressPercentage;
  final int? daysRemaining;
  final int waterTarget;
  final int stepTarget;
  final int journeyStreak;
  final double habitConsistency;
  final double calorieProgress;
  final double waterProgress;
  final double stepsProgress;
  final double sleepProgress;

  const DashboardData({
    this.currentWeight,
    this.targetWeight,
    this.weightLost,
    this.remainingWeight,
    this.progressPercentage,
    this.daysRemaining,
    this.waterTarget = 2000,
    this.stepTarget = 8000,
    this.journeyStreak = 0,
    this.habitConsistency = 0,
    this.calorieProgress = 0,
    this.waterProgress = 0,
    this.stepsProgress = 0,
    this.sleepProgress = 0,
  });
}
