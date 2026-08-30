/// Deterministic health-math used to build an AiPlan. Kept separate from
/// GeminiService because these numbers gate real behavior (how much someone
/// eats/drinks) and should never depend on unverified LLM arithmetic.
class PlanCalculator {
  /// Basal metabolic rate via the Mifflin-St Jeor equation.
  static double bmr({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender, // 'male' | 'female' | anything else
  }) {
    final base = 10 * weightKg + 6.25 * heightCm - 5 * age;
    switch (gender.toLowerCase()) {
      case 'male':
        return base + 5;
      case 'female':
        return base - 161;
      default:
        // Non-binary / unspecified: midpoint of the male and female offsets.
        return base - 78;
    }
  }

  static const _activityMultipliers = {
    'sedentary': 1.2,
    'light': 1.375,
    'moderate': 1.55,
    'active': 1.725,
    'very_active': 1.9,
  };

  static double tdee({required double bmr, required String activityLevel}) {
    final multiplier = _activityMultipliers[activityLevel] ?? 1.375;
    return bmr * multiplier;
  }

  /// Safe daily calorie target. Deficit/surplus is capped as a fraction of
  /// TDEE, and the result never drops below an absolute floor — regardless
  /// of goal type or how aggressive the user's target date is.
  static int calorieTarget({
    required double tdee,
    required String goalType, // 'weight_loss' | 'maintenance' | 'weight_gain'
  }) {
    const absoluteFloor = 1200.0;
    const maxDeficitFraction = 0.25;
    const maxSurplusFraction = 0.15;

    double target;
    switch (goalType) {
      case 'weight_loss':
        final maxDeficit = tdee * maxDeficitFraction;
        // ~0.5–0.7kg/week (500–750 kcal/day deficit), capped at 25% of TDEE.
        final deficit = 750.0 < maxDeficit ? 750.0 : maxDeficit;
        target = tdee - deficit;
        break;
      case 'weight_gain':
        final maxSurplus = tdee * maxSurplusFraction;
        final surplus = 400.0 < maxSurplus ? 400.0 : maxSurplus;
        target = tdee + surplus;
        break;
      default:
        target = tdee;
    }

    if (target < absoluteFloor) target = absoluteFloor;
    return target.round();
  }

  /// ~35ml per kg of body weight, plus a top-up for higher activity levels.
  static int waterTargetMl({
    required double weightKg,
    required String activityLevel,
  }) {
    final base = weightKg * 35;
    final topUp = switch (activityLevel) {
      'active' => 500,
      'very_active' => 750,
      _ => 0,
    };
    return (base + topUp).round();
  }

  /// Daily step target, nudged upward for weight-loss goals.
  static int stepTarget({
    required String activityLevel,
    required String goalType,
  }) {
    final base = switch (activityLevel) {
      'sedentary' => 6000,
      'light' => 7500,
      'moderate' => 9000,
      'active' => 10000,
      'very_active' => 11000,
      _ => 8000,
    };
    return goalType == 'weight_loss' ? base + 1000 : base;
  }

  /// Recognized units for weight conversion.
  static const _weightUnits = {'kg', 'lb', 'lbs'};

  /// Recognized units for height conversion.
  static const _heightUnits = {'cm', 'in', 'inch', 'inches', 'ft_in'};

  /// Converts weight to kilograms. Throws [ArgumentError] on an
  /// unrecognized unit instead of silently guessing — these numbers gate
  /// real nutrition targets, so a typo in unit text must fail loudly.
  static double kgFrom(double weight, String unit) {
    final u = unit.toLowerCase().trim();
    if (!_weightUnits.contains(u)) {
      throw ArgumentError.value(
          unit, 'unit', 'Unrecognized weight unit — expected "kg" or "lb"');
    }
    return (u == 'lb' || u == 'lbs') ? weight * 0.45359237 : weight;
  }

  /// Converts height to centimeters. Throws [ArgumentError] on an
  /// unrecognized unit. For feet+inches input, pre-combine into a single
  /// inches value with [inchesFromFeetAndInches] and pass unit 'in'.
  static double cmFrom(double height, String unit) {
    final u = unit.toLowerCase().trim();
    if (!_heightUnits.contains(u)) {
      throw ArgumentError.value(
          unit, 'unit', 'Unrecognized height unit — expected "cm" or "in"');
    }
    final isInches = u == 'in' || u == 'inch' || u == 'inches';
    return isInches ? height * 2.54 : height;
  }

  /// Combines feet + inches into a single inches value, e.g. for a
  /// 5'8" user: `inchesFromFeetAndInches(5, 8) == 68`.
  static double inchesFromFeetAndInches(int feet, double inches) =>
      feet * 12 + inches;
}
