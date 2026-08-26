import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../journey_setup/providers/journey_setup_provider.dart';
import '../../data/repositories/journey_repository_provider.dart';

String _toCsv(List<List<dynamic>> rows) =>
    rows.map((r) => r.map((c) => '"$c"').join(',')).join('\n');


class JourneyCompletionController extends Notifier<bool> {
  @override
  bool build() {
    final goal = ref.watch(journeySetupControllerProvider);
    final reachedWeight = goal.currentWeight != null &&
        goal.targetWeight != null &&
        goal.currentWeight! <= goal.targetWeight!;
    final reachedDate =
        goal.targetDate != null && DateTime.now().isAfter(goal.targetDate!);
    return reachedWeight ||
        reachedDate ||
        ref.read(journeyRepositoryProvider).isCompleted;
  }

  Future<void> completeManually() async {
    await ref.read(journeyRepositoryProvider).markCompleted();
    state = true;
  }
}

final journeyCompletionControllerProvider =
    NotifierProvider<JourneyCompletionController, bool>(
        JourneyCompletionController.new);

class JourneyCompletionScreen extends ConsumerWidget {
  const JourneyCompletionScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = ref.watch(journeySetupControllerProvider);
    final repo = ref.watch(journeyRepositoryProvider);
    final habits = repo.habits() as List;
    final habitConsistency = habits.isEmpty
        ? 0.0
        : habits.where((h) => h.completedToday == true).length / habits.length;
    int totalWorkouts = 0, totalSteps = 0;
    final start =
        goal.startDate ?? DateTime.now().subtract(const Duration(days: 30));
    final days = DateTime.now().difference(start).inDays.clamp(0, 3650);
    for (var i = 0; i <= days; i++) {
      final d = start.add(Duration(days: i));
      totalWorkouts += (repo.workoutsFor(d) as List).length;
      totalSteps += repo.stepsFor(d) as int;
    }
    final milestones = repo.achievedMilestones() as List;

    return Scaffold(
      appBar: AppBar(title: const Text('Journey complete')),
      body: ListView(padding: const EdgeInsets.all(24), children: [
        const Icon(Icons.emoji_events, size: 64, color: Colors.amber),
        const SizedBox(height: 16),
        Center(
            child: Text(
                '${goal.weightToLose?.abs().toStringAsFixed(1) ?? '–'} kg lost',
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w700))),
        Center(child: Text('Final weight: ${goal.currentWeight ?? '–'} kg')),
        const SizedBox(height: 20),
        Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              Text('Duration: $days days'),
              Text('Habit consistency: ${(habitConsistency * 100).round()}%'),
              Text('Total workouts: $totalWorkouts'),
              Text('Total steps: $totalSteps'),
            ]),
        const SizedBox(height: 20),
        const Text('Achievements',
            style: TextStyle(fontWeight: FontWeight.w700)),
        ...milestones.map((m) => ListTile(
            leading: const Icon(Icons.emoji_events, color: Colors.amber),
            title: Text(m.label as String))),
        const SizedBox(height: 20),
        FilledButton(
            onPressed: () => ref
                .read(journeyCompletionControllerProvider.notifier)
                .completeManually(),
            child: const Text('Mark journey complete')),
      ]),
    );
  }
}
