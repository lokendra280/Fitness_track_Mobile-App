import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/data/models/journey_goal.dart';
import 'package:habitflow/data/models/personal_profile.dart';
import 'package:habitflow/data/repositories/journey_repository_provider.dart';
import 'package:habitflow/features/journey_setup/services/journey_supabase_service.dart';
import 'package:habitflow/features/personal_profile/providers/personal_profile_provider.dart';

final journeySupabaseServiceProvider = Provider<JourneySupabaseService>((ref) {
  return JourneySupabaseService();
});

class JourneySetupController extends Notifier<JourneyGoal> {
  @override
  JourneyGoal build() => ref.read(journeyRepositoryProvider).loadGoal();

  void updateWeights({double? start, double? current, double? target}) {
    state = state.copyWith(
      startingWeight: start ?? state.startingWeight,
      currentWeight: current ?? state.currentWeight,
      targetWeight: target ?? state.targetWeight,
    );
  }

  void updateDates({DateTime? start, DateTime? target}) {
    state = state.copyWith(
        startDate: start ?? state.startDate ?? DateTime.now(),
        targetDate: target ?? state.targetDate);
  }

  void updateType(String type) => state = state.copyWith(type: type);

  void updateWeightUnit(String unit) =>
      state = state.copyWith(weightUnit: unit);

  Future<void> _syncCombined() async {
    try {
      final profile = ref.read(personalProfileControllerProvider);
      await ref.read(journeySupabaseServiceProvider).syncProfile(
            goal: state,
            profile: profile,
          );
    } catch (_) {}
  }

  Future<void> saveAndContinueLater() async {
    await ref.read(journeyRepositoryProvider).saveGoal(state);
    await _syncCombined();
  }

  Future<void> submit() async {
    await ref.read(journeyRepositoryProvider).saveGoal(state);
    await _syncCombined();
  }
}

final journeySetupControllerProvider =
    NotifierProvider<JourneySetupController, JourneyGoal>(
  JourneySetupController.new,
);

/// Gates the "Continue" button on the setup screen.
final journeySetupValidProvider = Provider<bool>((ref) {
  return ref.watch(journeySetupControllerProvider).isValid;
});

final journeyProfileAboutProvider =
    FutureProvider<({JourneyGoal goal, PersonalProfile profile})>((ref) async {
  final remote = await ref.read(journeySupabaseServiceProvider).fetchProfile();
  if (remote != null) return remote;

  return (
    goal: ref.read(journeyRepositoryProvider).loadGoal(),
    profile: ref.read(journeyRepositoryProvider).loadProfile(),
  );
});
