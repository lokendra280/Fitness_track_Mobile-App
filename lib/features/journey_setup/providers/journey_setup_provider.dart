import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/journey_goal.dart';
import '../../../data/repositories/journey_repository_provider.dart';

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
    state = state.copyWith(startDate: start ?? state.startDate, targetDate: target ?? state.targetDate);
  }

  void updateType(String type) => state = state.copyWith(type: type);

  void updateWeightUnit(String unit) => state = state.copyWith(weightUnit: unit);

  Future<void> saveAndContinueLater() => ref.read(journeyRepositoryProvider).saveGoal(state);

  Future<void> submit() => ref.read(journeyRepositoryProvider).saveGoal(state);
}

final journeySetupControllerProvider = NotifierProvider<JourneySetupController, JourneyGoal>(
  JourneySetupController.new,
);

/// Gates the "Continue" button on the setup screen.
final journeySetupValidProvider = Provider<bool>((ref) {
  return ref.watch(journeySetupControllerProvider).isValid;
});
