/// Phase 1 — personal_profile
class PersonalProfile {
  final int? age;
  final String? gender;
  final double? height;
  final String heightUnit; // 'cm' | 'in'
  final String? activityLevel; // sedentary/light/moderate/active/very_active
  final String? fitnessLevel; // beginner/intermediate/advanced
  final String? dietPreference; // omnivore/vegetarian/vegan/keto/...
  final List<String> foodAllergies;
  final List<String> foodRestrictions;

  const PersonalProfile({
    this.age,
    this.gender,
    this.height,
    this.heightUnit = 'cm',
    this.activityLevel,
    this.fitnessLevel,
    this.dietPreference,
    this.foodAllergies = const [],
    this.foodRestrictions = const [],
  });

  bool get isComplete =>
      age != null &&
      gender != null &&
      height != null &&
      activityLevel != null &&
      fitnessLevel != null;

  PersonalProfile copyWith({
    int? age,
    String? gender,
    double? height,
    String? heightUnit,
    String? activityLevel,
    String? fitnessLevel,
    String? dietPreference,
    List<String>? foodAllergies,
    List<String>? foodRestrictions,
  }) {
    return PersonalProfile(
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      heightUnit: heightUnit ?? this.heightUnit,
      activityLevel: activityLevel ?? this.activityLevel,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      dietPreference: dietPreference ?? this.dietPreference,
      foodAllergies: foodAllergies ?? this.foodAllergies,
      foodRestrictions: foodRestrictions ?? this.foodRestrictions,
    );
  }

  Map<String, dynamic> toJson() => {
        'age': age,
        'gender': gender,
        'height': height,
        'heightUnit': heightUnit,
        'activityLevel': activityLevel,
        'fitnessLevel': fitnessLevel,
        'dietPreference': dietPreference,
        'foodAllergies': foodAllergies,
        'foodRestrictions': foodRestrictions,
      };

  factory PersonalProfile.fromJson(Map<String, dynamic> json) =>
      PersonalProfile(
        age: json['age'] as int?,
        gender: json['gender'] as String?,
        height: (json['height'] as num?)?.toDouble(),
        heightUnit: json['heightUnit'] as String? ?? 'cm',
        activityLevel: json['activityLevel'] as String?,
        fitnessLevel: json['fitnessLevel'] as String?,
        dietPreference: json['dietPreference'] as String?,
        foodAllergies:
            (json['foodAllergies'] as List?)?.cast<String>() ?? const [],
        foodRestrictions:
            (json['foodRestrictions'] as List?)?.cast<String>() ?? const [],
      );
}
