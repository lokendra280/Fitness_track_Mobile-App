import 'package:flutter/foundation.dart';

/// Matches the real dashboardDataProvider output shape — plain progress
/// ratios + targets, no history/milestones/recent-entries (those aren't
/// exposed by the provider yet, so the UI treats them as optional extras
/// rather than assuming they exist).
@immutable
class DashboardData {
  final double? currentWeight;
  final double? targetWeight;
  final double? weightLost;
  final double? remainingWeight;
  final double? progressPercentage; // 0..1
  final int? daysRemaining;
  final int waterTarget; // ml
  final int stepTarget;
  final int journeyStreak;
  final double habitConsistency; // 0..1
  final double calorieProgress; // 0..1
  final double waterProgress; // 0..1
  final double stepsProgress; // 0..1
  final double sleepProgress; // 0..1

  const DashboardData({
    required this.currentWeight,
    required this.targetWeight,
    required this.weightLost,
    required this.remainingWeight,
    required this.progressPercentage,
    required this.daysRemaining,
    required this.waterTarget,
    required this.stepTarget,
    required this.journeyStreak,
    required this.habitConsistency,
    required this.calorieProgress,
    required this.waterProgress,
    required this.stepsProgress,
    required this.sleepProgress,
  });
}
