import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/dashboard_data.dart';
import '../../../data/repositories/journey_repository_provider.dart';
import '../../journey_setup/providers/journey_setup_provider.dart';
import '../../ai_plan/providers/ai_plan_provider.dart';
import '../../habit_tracking/habit_tracking_screen.dart';
import '../../water_tracking/water_tracking_screen.dart';
import '../../activity_tracking/activity_tracking_screen.dart';
import '../../food_tracking/food_tracking_screen.dart';

final dashboardDataProvider = Provider<DashboardData>((ref) {
  final goal = ref.watch(journeySetupControllerProvider);
  final plan = ref.watch(aiPlanControllerProvider);
  final repo = ref.watch(journeyRepositoryProvider);

  final weightLost = (goal.startingWeight != null && goal.currentWeight != null)
      ? goal.startingWeight! - goal.currentWeight!
      : null;
  final remaining = (goal.currentWeight != null && goal.targetWeight != null)
      ? goal.currentWeight! - goal.targetWeight!
      : null;

  final today = DateTime.now();
  final calorieTarget = 2000; // no explicit calorie target field yet — reasonable default
  final caloriesToday = ref.watch(foodLogProvider(today)).fold<double>(0, (s, e) => s + e.calories);

  return DashboardData(
    currentWeight: goal.currentWeight,
    targetWeight: goal.targetWeight,
    weightLost: weightLost,
    remainingWeight: remaining,
    progressPercentage: goal.progressPercentage,
    daysRemaining: repo.daysRemaining,
    waterTarget: plan?.waterTarget ?? 2000,
    stepTarget: plan?.stepTarget ?? 8000,
    journeyStreak: repo.streaks()['journey'] ?? 0,
    habitConsistency: ref.watch(habitConsistencyProvider),
    calorieProgress: (caloriesToday / calorieTarget).clamp(0, 1),
    waterProgress: ref.watch(waterProgressProvider),
    stepsProgress: ref.watch(stepsProgressProvider),
    sleepProgress: ((repo.sleepFor(today)?.hours ?? 0) / 8).clamp(0, 1),
  );
});

/// Phase 3: a one-line AI takeaway shown on the dashboard card. Kept
/// separate from the full ai_daily_review screen (which is more detailed).
final aiInsightProvider = FutureProvider.autoDispose<String>((ref) async {
  final data = ref.watch(dashboardDataProvider);
  final gemini = ref.watch(geminiServiceProvider);
  return gemini.summarizeWeek({
    'progress': data.progressPercentage,
    'habitConsistency': data.habitConsistency,
    'waterProgress': data.waterProgress,
    'stepsProgress': data.stepsProgress,
  });
});

class WeightLogController extends Notifier<void> {
  @override
  void build() {}

  Future<void> logWeight(double weight) async {
    await ref.read(journeyRepositoryProvider).logWeight(weight);
    ref.invalidateSelf();
    ref.invalidate(journeySetupControllerProvider);
  }
}

final weightLogControllerProvider = NotifierProvider<WeightLogController, void>(
  WeightLogController.new,
);
