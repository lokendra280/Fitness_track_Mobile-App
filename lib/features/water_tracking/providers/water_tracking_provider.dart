import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/journey_repository_provider.dart';
import '../../ai_plan/providers/ai_plan_provider.dart';

class WaterController extends Notifier<int> {
  DateTime _trackedDay = DateTime.now();

  @override
  int build() {
    _trackedDay = DateTime.now();
    return ref.read(journeyRepositoryProvider).waterFor(_trackedDay);
  }

  Future<void> quickAdd(int ml) async {
    // If the day rolled over since this controller was created, reset
    // to today's persisted value first instead of adding onto yesterday's.
    final today = DateTime.now();
    if (today.day != _trackedDay.day) {
      _trackedDay = today;
      state = ref.read(journeyRepositoryProvider).waterFor(today);
    }

    state += ml;
    await ref.read(journeyRepositoryProvider).saveWater(today, state);
    final target = ref.read(aiPlanControllerProvider)?.waterTarget ?? 2000;
    if (state >= target) {
      await ref.read(journeyRepositoryProvider).recordActivity('water');
    }
  }
}

final waterControllerProvider =
    NotifierProvider<WaterController, int>(WaterController.new);

final waterTargetProvider = Provider<int>(
    (ref) => ref.watch(aiPlanControllerProvider)?.waterTarget ?? 2000);

final waterProgressProvider = Provider<double>((ref) {
  final target = ref.watch(waterTargetProvider);
  return (ref.watch(waterControllerProvider) / target).clamp(0, 1);
});

final weeklyWaterHistoryProvider = Provider<List<int>>((ref) {
  final repo = ref.watch(journeyRepositoryProvider);
  final today = DateTime.now();
  return [
    for (var i = 6; i >= 0; i--)
      repo.waterFor(today.subtract(Duration(days: i)))
  ];
});
