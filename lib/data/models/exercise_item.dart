enum ExerciseCategory { strength, cardio, mobility }

ExerciseCategory _categoryFromString(String? value) {
  switch (value) {
    case 'cardio':
      return ExerciseCategory.cardio;
    case 'mobility':
      return ExerciseCategory.mobility;
    case 'strength':
    default:
      return ExerciseCategory.strength;
  }
}

class ExerciseItem {
  final String name; // e.g. "Squats", "Brisk walk"
  final String sets; // e.g. "3 sets x 12 reps" or "20 min"
  final ExerciseCategory category;

  const ExerciseItem({
    required this.name,
    required this.sets,
    this.category = ExerciseCategory.strength,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'sets': sets,
        'category': category.name,
      };

  factory ExerciseItem.fromJson(Map<String, dynamic> json) => ExerciseItem(
        name: json['name'] as String? ?? '',
        sets: json['sets'] as String? ?? '',
        category: _categoryFromString(json['category'] as String?),
      );
}
