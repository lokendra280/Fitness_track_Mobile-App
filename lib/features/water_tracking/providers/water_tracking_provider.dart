import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/journey_repository_provider.dart';
import '../../ai_plan/providers/ai_plan_provider.dart';

class WaterController extends Notifier<int> {
  @override
  int build() => ref.read(journeyRepositoryProvider).waterFor(DateTime.now());

  Future<void> quickAdd(int ml) async {
    state += ml;
    await ref.read(journeyRepositoryProvider).saveWater(DateTime.now(), state);
    final target = ref.read(aiPlanControllerProvider)?.waterTarget ?? 2000;
    if (state >= target)
      await ref.read(journeyRepositoryProvider).recordActivity('water');
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
