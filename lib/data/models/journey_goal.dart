class JourneyGoal {
  final String type; // e.g. 'lose_weight', 'gain_muscle', 'maintain'
  final double? startingWeight;
  final double? currentWeight;
  final double? targetWeight;
  final String weightUnit; // 'kg' | 'lb'
  final DateTime? startDate;
  final DateTime? targetDate;

  const JourneyGoal({
    this.type = 'lose_weight',
    this.startingWeight,
    this.currentWeight,
    this.targetWeight,
    this.weightUnit = 'kg',
    this.startDate,
    this.targetDate,
  });

  double? get weightToLose {
    if (startingWeight == null || targetWeight == null) return null;
    return startingWeight! - targetWeight!;
  }

  double? get progressPercentage {
    final toLose = weightToLose;
    if (toLose == null ||
        toLose == 0 ||
        currentWeight == null ||
        startingWeight == null) {
      return null;
    }
    final lostSoFar = startingWeight! - currentWeight!;
    return (lostSoFar / toLose).clamp(0.0, 1.0);
  }

  int? get daysRemaining {
    if (targetDate == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target =
        DateTime(targetDate!.year, targetDate!.month, targetDate!.day);
    return target.difference(today).inDays;
  }

  bool get isValid =>
      startingWeight != null &&
      targetWeight != null &&
      targetDate != null &&
      startingWeight! > 0 &&
      targetWeight! > 0;

  JourneyGoal copyWith({
    String? type,
    double? startingWeight,
    double? currentWeight,
    double? targetWeight,
    String? weightUnit,
    DateTime? startDate,
    DateTime? targetDate,
  }) {
    return JourneyGoal(
      type: type ?? this.type,
      startingWeight: startingWeight ?? this.startingWeight,
      currentWeight: currentWeight ?? this.currentWeight,
      targetWeight: targetWeight ?? this.targetWeight,
      weightUnit: weightUnit ?? this.weightUnit,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'startingWeight': startingWeight,
        'currentWeight': currentWeight,
        'targetWeight': targetWeight,
        'weightUnit': weightUnit,
        'startDate': startDate?.toIso8601String(),
        'targetDate': targetDate?.toIso8601String(),
      };

  factory JourneyGoal.fromJson(Map<String, dynamic> json) => JourneyGoal(
        type: json['type'] as String? ?? 'lose_weight',
        startingWeight: (json['startingWeight'] as num?)?.toDouble(),
        currentWeight: (json['currentWeight'] as num?)?.toDouble(),
        targetWeight: (json['targetWeight'] as num?)?.toDouble(),
        weightUnit: json['weightUnit'] as String? ?? 'kg',
        startDate: json['startDate'] != null
            ? DateTime.parse(json['startDate'] as String)
            : null,
        targetDate: json['targetDate'] != null
            ? DateTime.parse(json['targetDate'] as String)
            : null,
      );

  Map<String, dynamic> toSupabaseRow(String userId) => {
        'user_id': userId,
        'type': type,
        'starting_weight': startingWeight,
        'current_weight': currentWeight,
        'target_weight': targetWeight,
        'weight_unit': weightUnit,
        'start_date': startDate?.toIso8601String(),
        'target_date': targetDate?.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

  factory JourneyGoal.fromSupabaseRow(Map<String, dynamic> row) => JourneyGoal(
        type: row['type'] as String? ?? 'lose_weight',
        startingWeight: (row['starting_weight'] as num?)?.toDouble(),
        currentWeight: (row['current_weight'] as num?)?.toDouble(),
        targetWeight: (row['target_weight'] as num?)?.toDouble(),
        weightUnit: row['weight_unit'] as String? ?? 'kg',
        startDate: row['start_date'] != null
            ? DateTime.parse(row['start_date'] as String)
            : null,
        targetDate: row['target_date'] != null
            ? DateTime.parse(row['target_date'] as String)
            : null,
      );
}
