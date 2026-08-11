import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ai_plan/providers/ai_plan_provider.dart';
import '../journey_setup/providers/journey_setup_provider.dart';
import '../food_tracking/food_tracking_screen.dart';
import '../water_tracking/water_tracking_screen.dart';
import '../activity_tracking/activity_tracking_screen.dart';
import '../sleep_tracking/sleep_tracking_screen.dart';
import '../habit_tracking/habit_tracking_screen.dart';
import '../daily_check_in/daily_check_in_screen.dart';

final aiDailyReviewProvider = FutureProvider.autoDispose<String>((ref) async {
  final day = DateTime.now();
  final gemini = ref.watch(geminiServiceProvider);
  return gemini.reviewDay(
    weight: ref.watch(journeySetupControllerProvider).currentWeight,
    food: ref.watch(foodLogProvider(day)),
    water: ref.watch(waterControllerProvider),
    steps: ref.watch(stepsControllerProvider),
    workouts: ref.watch(workoutLogControllerProvider),
    sleep: ref.watch(sleepControllerProvider),
    habits: ref.watch(habitControllerProvider),
    checkIn: ref.watch(dailyCheckInControllerProvider),
  );
});

class AiDailyReviewScreen extends ConsumerWidget {
  const AiDailyReviewScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final review = ref.watch(aiDailyReviewProvider);
    return Scaffold(
      appBar: AppBar(title: const Text("Today's AI review")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: review.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Could not generate review: $e')),
          data: (text) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: SingleChildScrollView(child: Text(text))),
            Text('Not medical advice.', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ]),
        ),
      ),
    );
  }
}
