class FoodEntry {
  final String mealType, name;
  final double calories;
  final double? protein, carbs, fat, fiber, servingSize, quantity;
  FoodEntry({required this.mealType, required this.name, required this.calories, this.protein, this.carbs, this.fat, this.fiber, this.servingSize, this.quantity});
  Map<String, dynamic> toJson() => {'mealType': mealType, 'name': name, 'calories': calories, 'protein': protein, 'carbs': carbs, 'fat': fat, 'fiber': fiber, 'servingSize': servingSize, 'quantity': quantity};
  factory FoodEntry.fromJson(Map j) => FoodEntry(
        mealType: j['mealType'], name: j['name'], calories: (j['calories'] as num).toDouble(),
        protein: (j['protein'] as num?)?.toDouble(), carbs: (j['carbs'] as num?)?.toDouble(), fat: (j['fat'] as num?)?.toDouble(),
        fiber: (j['fiber'] as num?)?.toDouble(), servingSize: (j['servingSize'] as num?)?.toDouble(), quantity: (j['quantity'] as num?)?.toDouble(),
      );
}

class WorkoutEntry {
  final String type, intensity;
  final int minutes;
  final double? distanceKm;
  final int? caloriesBurned;
  WorkoutEntry({required this.type, required this.minutes, this.intensity = 'moderate', this.distanceKm, this.caloriesBurned});
  Map<String, dynamic> toJson() => {'type': type, 'minutes': minutes, 'intensity': intensity, 'distanceKm': distanceKm, 'caloriesBurned': caloriesBurned};
  factory WorkoutEntry.fromJson(Map j) => WorkoutEntry(type: j['type'], minutes: j['minutes'], intensity: j['intensity'] ?? 'moderate', distanceKm: (j['distanceKm'] as num?)?.toDouble(), caloriesBurned: j['caloriesBurned']);
}

class SleepEntry {
  final double hours;
  final String? quality, bedtime, wakeTime;
  SleepEntry({required this.hours, this.quality, this.bedtime, this.wakeTime});
  Map<String, dynamic> toJson() => {'hours': hours, 'quality': quality, 'bedtime': bedtime, 'wakeTime': wakeTime};
  factory SleepEntry.fromJson(Map j) => SleepEntry(hours: (j['hours'] as num).toDouble(), quality: j['quality'], bedtime: j['bedtime'], wakeTime: j['wakeTime']);
}

class BodyMeasurement {
  final DateTime date;
  final double? weight, waist, chest, hips, neck, arms, thighs, bodyFatPercentage;
  BodyMeasurement({required this.date, this.weight, this.waist, this.chest, this.hips, this.neck, this.arms, this.thighs, this.bodyFatPercentage});
  Map<String, dynamic> toJson() => {'date': date.toIso8601String(), 'weight': weight, 'waist': waist, 'chest': chest, 'hips': hips, 'neck': neck, 'arms': arms, 'thighs': thighs, 'bodyFatPercentage': bodyFatPercentage};
  factory BodyMeasurement.fromJson(Map j) => BodyMeasurement(
        date: DateTime.parse(j['date']), weight: (j['weight'] as num?)?.toDouble(), waist: (j['waist'] as num?)?.toDouble(),
        chest: (j['chest'] as num?)?.toDouble(), hips: (j['hips'] as num?)?.toDouble(), neck: (j['neck'] as num?)?.toDouble(),
        arms: (j['arms'] as num?)?.toDouble(), thighs: (j['thighs'] as num?)?.toDouble(), bodyFatPercentage: (j['bodyFatPercentage'] as num?)?.toDouble(),
      );
}

/// Stored as a local file path only — never uploaded. See PrivatePhotoStorage.
class ProgressPhoto {
  final DateTime date;
  final String angle; // front | side | back
  final String path;
  ProgressPhoto({required this.date, required this.angle, required this.path});
  Map<String, dynamic> toJson() => {'date': date.toIso8601String(), 'angle': angle, 'path': path};
  factory ProgressPhoto.fromJson(Map j) => ProgressPhoto(date: DateTime.parse(j['date']), angle: j['angle'], path: j['path']);
}

class Habit {
  final String name, frequency;
  final bool completedToday;
  final int streak;
  final DateTime? lastCompletedDate;
  Habit({required this.name, this.frequency = 'daily', this.completedToday = false, this.streak = 0, this.lastCompletedDate});
  Habit copyWith({bool? completedToday, int? streak, DateTime? lastCompletedDate}) => Habit(
        name: name, frequency: frequency, completedToday: completedToday ?? this.completedToday,
        streak: streak ?? this.streak, lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      );
  Map<String, dynamic> toJson() => {'name': name, 'frequency': frequency, 'completedToday': completedToday, 'streak': streak, 'lastCompletedDate': lastCompletedDate?.toIso8601String()};
  factory Habit.fromJson(Map j) => Habit(
        name: j['name'], frequency: j['frequency'] ?? 'daily', completedToday: j['completedToday'] ?? false,
        streak: j['streak'] ?? 0, lastCompletedDate: j['lastCompletedDate'] != null ? DateTime.parse(j['lastCompletedDate']) : null,
      );
}

class DailyCheckIn {
  final String? mood;
  final int? energy, stress;
  final bool? exercised, followedNutritionPlan;
  final String? sleepFeedback, reflection;
  DailyCheckIn({this.mood, this.energy, this.stress, this.exercised, this.followedNutritionPlan, this.sleepFeedback, this.reflection});
  Map<String, dynamic> toJson() => {'mood': mood, 'energy': energy, 'stress': stress, 'exercised': exercised, 'followedNutritionPlan': followedNutritionPlan, 'sleepFeedback': sleepFeedback, 'reflection': reflection};
  factory DailyCheckIn.fromJson(Map j) => DailyCheckIn(mood: j['mood'], energy: j['energy'], stress: j['stress'], exercised: j['exercised'], followedNutritionPlan: j['followedNutritionPlan'], sleepFeedback: j['sleepFeedback'], reflection: j['reflection']);
}

class ChatMessage {
  final String role, content;
  ChatMessage({required this.role, required this.content});
  Map<String, dynamic> toJson() => {'role': role, 'content': content};
  factory ChatMessage.fromJson(Map j) => ChatMessage(role: j['role'], content: j['content']);
}

class Milestone {
  final String type; // weight_loss | habit_streak | workout_count | step_count | water_consistency | meal_tracking | journey_consistency | custom
  final String label;
  final int? percent;
  final DateTime achievedAt;
  Milestone({required this.type, required this.label, this.percent, required this.achievedAt});
  Map<String, dynamic> toJson() => {'type': type, 'label': label, 'percent': percent, 'achievedAt': achievedAt.toIso8601String()};
  factory Milestone.fromJson(Map j) => Milestone(type: j['type'] ?? 'weight_loss', label: j['label'] ?? '${j['percent']}%', percent: j['percent'], achievedAt: DateTime.parse(j['achievedAt']));
}
