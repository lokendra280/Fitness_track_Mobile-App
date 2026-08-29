import 'exercise_item.dart';

/// One day's worth of the weekly exercise schedule — either a rest day,
/// or a list of specific exercises to do that day.
class DailyWorkout {
  final String day; // 'Monday', 'Tuesday', ... 'Sunday'
  final bool isRestDay;
  final String?
      focus; // e.g. "Upper body strength", "Cardio", null on rest days
  final List<ExerciseItem> exercises;

  const DailyWorkout({
    required this.day,
    this.isRestDay = false,
    this.focus,
    this.exercises = const [],
  });

  Map<String, dynamic> toJson() => {
        'day': day,
        'isRestDay': isRestDay,
        'focus': focus,
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };

  factory DailyWorkout.fromJson(Map<String, dynamic> json) => DailyWorkout(
        day: json['day'] as String? ?? '',
        isRestDay: json['isRestDay'] as bool? ?? false,
        focus: json['focus'] as String?,
        exercises: (json['exercises'] as List?)
                ?.map((e) =>
                    ExerciseItem.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList() ??
            const [],
      );
}
