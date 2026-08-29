import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/data/repositories/journey_repository_provider.dart';
import 'package:habitflow/features/auth/providers/auth_provider.dart';
import 'package:habitflow/features/personal_profile/models/personal_model.dart';

/// Combines the signed-in user (name/avatar) with the saved journey goal +
/// personal profile (weight, height, fitness level, progress) into the one
/// shape ProfileHeaderCard actually needs.
final profileViewDataProvider = Provider<ProfileViewData?>((ref) {
  final auth = ref.watch(authStateProvider);
  final user = auth.user;
  if (user == null) return null;

  final repository = ref.watch(journeyRepositoryProvider);
  final goal = repository.loadGoal();
  final profile = repository.loadProfile();

  final displayName = user.username ?? user.email.split('@').first;

  return ProfileViewData(
    fullName: displayName,
    username: user.username ?? user.email.split('@').first,
    avatarUrl: user.avatarUrl,
    fitnessLevel: profile.fitnessLevel ?? 'Beginner',
    progressPercent: goal.progressPercentage ?? 0.0,
    age: profile.age,
    gender: profile.gender,
    heightCm: profile.height,
    weightKg: goal.currentWeight,
  );
});
