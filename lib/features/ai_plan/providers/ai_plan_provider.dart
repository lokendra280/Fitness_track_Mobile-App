import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/features/habit_tracking/providers/habit_tracking_provider.dart';
import '../../../core/constants/api_config.dart';
import '../../../data/models/ai_plan.dart';
import '../../../data/services/gemini_service.dart';
import '../../../data/repositories/journey_repository_provider.dart';
import '../../journey_setup/providers/journey_setup_provider.dart';
import '../../personal_profile/providers/personal_profile_provider.dart';

/// The spec's default habit set — seeded once, in addition to whatever
/// habits the AI plan itself recommends.
const kDefaultRecommendedHabits = [
  'Drink enough water',
  'Walk daily',
  'Track meals',
  'Exercise',
  'Sleep 7-9 hours',
  'Avoid sugary drinks',
];

final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService(apiKey: ApiConfig.geminiApiKey);
});

/// Fires the Gemini request. Depends on goal + profile so editing either one
/// (via `ref.refresh`) triggers regeneration.
final aiPlanGenerationProvider =
    FutureProvider.autoDispose<AiPlan>((ref) async {
  final goal = ref.watch(journeySetupControllerProvider);
  final profile = ref.watch(personalProfileControllerProvider);

  if (!ApiConfig.hasGeminiKey) {
    throw GeminiServiceException(
        'No Gemini API key set. Run with --dart-define=GEMINI_API_KEY=...');
  }

  final gemini = ref.watch(geminiServiceProvider);
  return gemini.generatePlan(goal: goal, profile: profile);
});

/// Holds whichever plan the user has actually accepted (possibly edited).
/// Null until they accept one; the screen reads [aiPlanGenerationProvider]
/// for the freshly-generated candidate and this for the confirmed plan.
class AiPlanController extends Notifier<AiPlan?> {
  @override
  AiPlan? build() => ref.read(journeyRepositoryProvider).loadAiPlan();

  Future<void> acceptPlan(AiPlan plan) async {
    state = plan;
    await ref.read(journeyRepositoryProvider).saveAiPlan(plan);
    ref.read(habitControllerProvider.notifier).seedRecommended(
        [...kDefaultRecommendedHabits, ...plan.recommendedHabits]);
  }

  Future<void> customizePlan(AiPlan Function(AiPlan) edit) async {
    if (state == null) return;
    final updated = edit(state!);
    state = updated;
    await ref.read(journeyRepositoryProvider).saveAiPlan(updated);
  }

  Future<AiPlan> regenerate() async {
    final fresh = await ref.refresh(aiPlanGenerationProvider.future);
    return fresh;
  }
}

final aiPlanControllerProvider = NotifierProvider<AiPlanController, AiPlan?>(
  AiPlanController.new,
);
