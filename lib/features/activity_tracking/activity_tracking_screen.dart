import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/tracking_models.dart';
import '../../data/repositories/journey_repository_provider.dart';
import '../ai_plan/providers/ai_plan_provider.dart';

class StepsController extends Notifier<int> {
  @override
  int build() => ref.read(journeyRepositoryProvider).stepsFor(DateTime.now());
  Future<void> syncFromHealth(int steps) async {
    state = steps;
    await ref.read(journeyRepositoryProvider).saveSteps(DateTime.now(), steps);
  }
}

final stepsControllerProvider = NotifierProvider<StepsController, int>(StepsController.new);

final stepsProgressProvider = Provider<double>((ref) {
  final target = ref.watch(aiPlanControllerProvider)?.stepTarget ?? 8000;
  return (ref.watch(stepsControllerProvider) / target).clamp(0, 1);
});

class WorkoutLogController extends Notifier<List<WorkoutEntry>> {
  @override
  List<WorkoutEntry> build() => ref.read(journeyRepositoryProvider).workoutsFor(DateTime.now());
  Future<void> logWorkout(WorkoutEntry w) async {
    await ref.read(journeyRepositoryProvider).logWorkout(DateTime.now(), w);
    state = [...state, w];
    await ref.read(journeyRepositoryProvider).recordActivity('exercise');
  }
}

final workoutLogControllerProvider = NotifierProvider<WorkoutLogController, List<WorkoutEntry>>(WorkoutLogController.new);

class ActivityTrackingScreen extends ConsumerWidget {
  const ActivityTrackingScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final steps = ref.watch(stepsControllerProvider);
    final progress = ref.watch(stepsProgressProvider);
    final workouts = ref.watch(workoutLogControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Activity')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        LinearProgressIndicator(value: progress),
        const SizedBox(height: 8),
        Text('$steps steps today'),
        const SizedBox(height: 20),
        const Text('Workouts', style: TextStyle(fontWeight: FontWeight.w600)),
        ...workouts.map((w) => ListTile(title: Text(w.type), subtitle: Text('${w.minutes} min'), trailing: w.caloriesBurned != null ? Text('${w.caloriesBurned} kcal') : null)),
      ]),
      floatingActionButton: FloatingActionButton(onPressed: () => _logWorkout(context, ref), child: const Icon(Icons.add)),
    );
  }

  void _logWorkout(BuildContext context, WidgetRef ref) {
    const types = ['walking', 'running', 'cycling', 'gym', 'strength_training', 'home_workout', 'yoga', 'swimming', 'sports', 'other'];
    const intensities = ['light', 'moderate', 'intense'];
    String type = types.first, intensity = intensities[1];
    final minCtrl = TextEditingController();
    final distCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            DropdownButtonFormField<String>(value: type, items: types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(), onChanged: (v) => setState(() => type = v ?? type), decoration: const InputDecoration(labelText: 'Type')),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(value: intensity, items: intensities.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(), onChanged: (v) => setState(() => intensity = v ?? intensity), decoration: const InputDecoration(labelText: 'Intensity')),
            const SizedBox(height: 8),
            TextField(controller: minCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Minutes')),
            const SizedBox(height: 8),
            TextField(controller: distCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Distance (km, optional)')),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                final mins = int.tryParse(minCtrl.text);
                if (mins == null) return;
                ref.read(workoutLogControllerProvider.notifier).logWorkout(WorkoutEntry(type: type, minutes: mins, intensity: intensity, distanceKm: double.tryParse(distCtrl.text)));
                Navigator.of(ctx).pop();
              },
              child: const Text('Log'),
            ),
          ]),
        ),
      ),
    );
  }
}
