import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../journey_setup/providers/journey_setup_provider.dart';
import '../../data/repositories/journey_repository_provider.dart';

String _toCsv(List<List<dynamic>> rows) =>
    rows.map((r) => r.map((c) => '"$c"').join(',')).join('\n');

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(journeyRepositoryProvider);
    final goal = ref.watch(journeySetupControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        ListTile(
            leading: const Icon(Icons.today),
            title: const Text('Daily report'),
            subtitle: const Text('Today\'s tracked data'),
            onTap: () => _showDaily(context, repo)),
        ListTile(
            leading: const Icon(Icons.calendar_view_week),
            title: const Text('Weekly report'),
            subtitle: Text(
                '${repo.streaks()['journey'] ?? 0}-day streak, see Weekly review')),
        ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text('Monthly report'),
            subtitle: const Text('See Monthly review')),
        const Divider(),
        ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export as CSV'),
            onTap: () => _exportCsv(context, repo, goal)),
      ]),
    );
  }

  void _showDaily(BuildContext context, dynamic repo) {
    final today = DateTime.now();
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('Today'),
              content: Text(
                  'Water: ${repo.waterFor(today)}ml\nSteps: ${repo.stepsFor(today)}\nFood entries: ${(repo.foodEntriesFor(today) as List).length}\nWorkouts: ${(repo.workoutsFor(today) as List).length}\nSleep: ${repo.sleepFor(today)?.hours ?? '–'}h'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close'))
              ],
            ));
  }

  Future<void> _exportCsv(
      BuildContext context, dynamic repo, dynamic goal) async {
    final today = DateTime.now();
    final rows = <List<dynamic>>[
      ['date', 'water_ml', 'steps', 'workouts', 'sleep_hours'],
      for (var i = 29; i >= 0; i--)
        () {
          final d = today.subtract(Duration(days: i));
          return [
            d.toIso8601String().split('T').first,
            repo.waterFor(d),
            repo.stepsFor(d),
            (repo.workoutsFor(d) as List).length,
            repo.sleepFor(d)?.hours ?? ''
          ];
        }(),
    ];
    final dir = await getApplicationDocumentsDirectory();
    final file =
        File('${dir.path}/journey_export_${today.millisecondsSinceEpoch}.csv');
    await file.writeAsString(_toCsv(rows));
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Saved to ${file.path}')));
    }
  }
}

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
