class AiPlan {
  final int waterTarget; // ml
  final int stepTarget;
  final String exerciseFrequency; // e.g. '3x_week'
  final String sleepTarget; // e.g. '7-9_hours'
  final bool mealTracking;
  final List<String> recommendedHabits;
  final List<String> milestones;

  const AiPlan({
    this.waterTarget = 2000,
    this.stepTarget = 8000,
    this.exerciseFrequency = '3x_week',
    this.sleepTarget = '7-9_hours',
    this.mealTracking = true,
    this.recommendedHabits = const [],
    this.milestones = const [],
  });

  AiPlan copyWith({
    int? waterTarget,
    int? stepTarget,
    String? exerciseFrequency,
    String? sleepTarget,
    bool? mealTracking,
    List<String>? recommendedHabits,
    List<String>? milestones,
  }) {
    return AiPlan(
      waterTarget: waterTarget ?? this.waterTarget,
      stepTarget: stepTarget ?? this.stepTarget,
      exerciseFrequency: exerciseFrequency ?? this.exerciseFrequency,
      sleepTarget: sleepTarget ?? this.sleepTarget,
      mealTracking: mealTracking ?? this.mealTracking,
      recommendedHabits: recommendedHabits ?? this.recommendedHabits,
      milestones: milestones ?? this.milestones,
    );
  }

  Map<String, dynamic> toJson() => {
        'waterTarget': waterTarget,
        'stepTarget': stepTarget,
        'exerciseFrequency': exerciseFrequency,
        'sleepTarget': sleepTarget,
        'mealTracking': mealTracking,
        'recommendedHabits': recommendedHabits,
        'milestones': milestones,
      };

  factory AiPlan.fromJson(Map<String, dynamic> json) => AiPlan(
        waterTarget: json['waterTarget'] as int? ?? 2000,
        stepTarget: json['stepTarget'] as int? ?? 8000,
        exerciseFrequency: json['exerciseFrequency'] as String? ?? '3x_week',
        sleepTarget: json['sleepTarget'] as String? ?? '7-9_hours',
        mealTracking: json['mealTracking'] as bool? ?? true,
        recommendedHabits: (json['recommendedHabits'] as List?)?.cast<String>() ?? const [],
        milestones: (json['milestones'] as List?)?.cast<String>() ?? const [],
      );
}
