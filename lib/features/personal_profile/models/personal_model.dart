/// Plain data holder for what the Profile UI needs to render — decouples
/// the widgets below from whatever your real provider/repository shape is.
class ProfileViewData {
  final String fullName;
  final String username;
  final String? avatarUrl;
  final String fitnessLevel;
  final double progressPercent; // 0.0–1.0
  final int? age;
  final String? gender;
  final double? heightCm;
  final double? weightKg;

  const ProfileViewData({
    required this.fullName,
    required this.username,
    this.avatarUrl,
    required this.fitnessLevel,
    required this.progressPercent,
    this.age,
    this.gender,
    this.heightCm,
    this.weightKg,
  });
}
