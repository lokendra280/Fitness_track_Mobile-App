import 'package:habitflow/data/models/daily_workout.dart';

class AiPlan {
  final int calorieTarget; // kcal/day
  final int waterTarget; // ml
  final int stepTarget;
  final List<DailyWorkout> weeklySchedule; // 7 entries, Monday–Sunday
  final String sleepTarget; // e.g. '7-9_hours'
  final bool mealTracking;
  final List<String> recommendedHabits;
  final List<String> milestones;

  const AiPlan({
    this.calorieTarget = 2000,
    this.waterTarget = 2000,
    this.stepTarget = 8000,
    this.weeklySchedule = const [],
    this.sleepTarget = '7-9_hours',
    this.mealTracking = true,
    this.recommendedHabits = const [],
    this.milestones = const [],
  });

  /// How many non-rest days are in the schedule — handy for display
  /// without needing a separate exerciseFrequency string anymore.
  int get workoutDaysPerWeek =>
      weeklySchedule.where((d) => !d.isRestDay).length;

  /// Today's workout, matched by weekday name. Returns null if the
  /// schedule doesn't have an entry for today (shouldn't happen once
  /// the model returns all 7 days, but keeps this safe).
  DailyWorkout? workoutForWeekday(DateTime date) {
    const names = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final name = names[date.weekday - 1];
    try {
      return weeklySchedule.firstWhere((d) => d.day == name);
    } catch (_) {
      return null;
    }
  }

  AiPlan copyWith({
    int? calorieTarget,
    int? waterTarget,
    int? stepTarget,
    List<DailyWorkout>? weeklySchedule,
    String? sleepTarget,
    bool? mealTracking,
    List<String>? recommendedHabits,
    List<String>? milestones,
  }) {
    return AiPlan(
      calorieTarget: calorieTarget ?? this.calorieTarget,
      waterTarget: waterTarget ?? this.waterTarget,
      stepTarget: stepTarget ?? this.stepTarget,
      weeklySchedule: weeklySchedule ?? this.weeklySchedule,
      sleepTarget: sleepTarget ?? this.sleepTarget,
      mealTracking: mealTracking ?? this.mealTracking,
      recommendedHabits: recommendedHabits ?? this.recommendedHabits,
      milestones: milestones ?? this.milestones,
    );
  }

  Map<String, dynamic> toJson() => {
        'calorieTarget': calorieTarget,
        'waterTarget': waterTarget,
        'stepTarget': stepTarget,
        'weeklySchedule': weeklySchedule.map((d) => d.toJson()).toList(),
        'sleepTarget': sleepTarget,
        'mealTracking': mealTracking,
        'recommendedHabits': recommendedHabits,
        'milestones': milestones,
      };

  factory AiPlan.fromJson(Map<String, dynamic> json) => AiPlan(
        calorieTarget: json['calorieTarget'] as int? ?? 2000,
        waterTarget: json['waterTarget'] as int? ?? 2000,
        stepTarget: json['stepTarget'] as int? ?? 8000,
        weeklySchedule: (json['weeklySchedule'] as List?)
                ?.map((d) =>
                    DailyWorkout.fromJson(Map<String, dynamic>.from(d as Map)))
                .toList() ??
            const [],
        sleepTarget: json['sleepTarget'] as String? ?? '7-9_hours',
        mealTracking: json['mealTracking'] as bool? ?? true,
        recommendedHabits:
            (json['recommendedHabits'] as List?)?.cast<String>() ?? const [],
        milestones: (json['milestones'] as List?)?.cast<String>() ?? const [],
      );
}
