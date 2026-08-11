import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/tracking_models.dart';
import '../../data/repositories/journey_repository_provider.dart';
import '../../core/safety/safety_check.dart';

class DailyCheckInController extends Notifier<DailyCheckIn> {
  @override
  DailyCheckIn build() => ref.read(journeyRepositoryProvider).checkInFor(DateTime.now()) ?? DailyCheckIn();

  Future<void> submit(DailyCheckIn checkIn) async {
    state = checkIn;
    await ref.read(journeyRepositoryProvider).saveCheckIn(DateTime.now(), checkIn);
    await ref.read(journeyRepositoryProvider).recordActivity('journey');
  }

  /// Spec: safety.professional_help_when_appropriate — pulls the last few
  /// days of check-ins and runs them through SafetyCheck.
  SafetyCheckResult runSafetyCheck() {
    final repo = ref.read(journeyRepositoryProvider);
    final today = DateTime.now();
    final recent = [for (var i = 0; i < 5; i++) repo.checkInFor(today.subtract(Duration(days: i)))].whereType<DailyCheckIn>().toList();
    return SafetyCheck.check(
      recentStressLevels: recent.map((c) => c.stress).whereType<int>().toList(),
      recentEnergyLevels: recent.map((c) => c.energy).whereType<int>().toList(),
    );
  }
}

final dailyCheckInControllerProvider = NotifierProvider<DailyCheckInController, DailyCheckIn>(DailyCheckInController.new);

class DailyCheckInScreen extends ConsumerStatefulWidget {
  const DailyCheckInScreen({super.key});
  @override
  ConsumerState<DailyCheckInScreen> createState() => _State();
}

class _State extends ConsumerState<DailyCheckInScreen> {
  String? mood, sleepFeedback;
  int energy = 3, stress = 3;
  bool exercised = false, followedPlan = false;
  final reflectionCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final safety = ref.watch(dailyCheckInControllerProvider.notifier).runSafetyCheck();
    return Scaffold(
      appBar: AppBar(title: const Text('Daily check-in')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        if (safety.shouldSuggestProfessionalHelp) ProfessionalHelpBanner(reason: safety.reason!),
        const Text('How do you feel today?'),
        Wrap(spacing: 8, children: ['😞', '😐', '🙂', '😄'].map((m) => ChoiceChip(label: Text(m), selected: mood == m, onSelected: (_) => setState(() => mood = m))).toList()),
        const SizedBox(height: 16),
        Text('Energy: $energy/5'),
        Slider(value: energy.toDouble(), min: 1, max: 5, divisions: 4, onChanged: (v) => setState(() => energy = v.round())),
        Text('Stress: $stress/5'),
        Slider(value: stress.toDouble(), min: 1, max: 5, divisions: 4, onChanged: (v) => setState(() => stress = v.round())),
        SwitchListTile(value: exercised, onChanged: (v) => setState(() => exercised = v), title: const Text('Did you exercise today?')),
        SwitchListTile(value: followedPlan, onChanged: (v) => setState(() => followedPlan = v), title: const Text('Did you follow your nutrition plan?')),
        const Text('How was your sleep?'),
        Wrap(spacing: 8, children: ['poor', 'okay', 'good', 'great'].map((q) => ChoiceChip(label: Text(q), selected: sleepFeedback == q, onSelected: (_) => setState(() => sleepFeedback = q))).toList()),
        const SizedBox(height: 12),
        TextField(controller: reflectionCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Reflection', border: OutlineInputBorder())),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: () async {
            await ref.read(dailyCheckInControllerProvider.notifier).submit(DailyCheckIn(
              mood: mood, energy: energy, stress: stress, exercised: exercised,
              followedNutritionPlan: followedPlan, sleepFeedback: sleepFeedback, reflection: reflectionCtrl.text,
            ));
            if (context.mounted) Navigator.of(context).pop();
          },
          child: const Text('Submit'),
        ),
      ]),
    );
  }
}
