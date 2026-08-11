import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/tracking_models.dart';
import '../../data/repositories/journey_repository_provider.dart';

class HabitController extends Notifier<List<Habit>> {
  @override
  List<Habit> build() => ref.read(journeyRepositoryProvider).habits();

  void toggleCompletion(String name) {
    final today = DateTime.now();
    state = [
      for (final h in state)
        if (h.name == name)
          h.completedToday
              ? h.copyWith(completedToday: false, streak: (h.streak - 1).clamp(0, 1 << 30))
              : h.copyWith(completedToday: true, streak: h.streak + 1, lastCompletedDate: today)
        else
          h
    ];
    ref.read(journeyRepositoryProvider).saveHabits(state);
    if (state.every((h) => h.completedToday)) {
      ref.read(journeyRepositoryProvider).recordActivity('habit');
    }
  }

  void addCustomHabit(String name) {
    state = [...state, Habit(name: name)];
    ref.read(journeyRepositoryProvider).saveHabits(state);
  }

  /// Called once when an AI plan is accepted — seeds `recommended_habits`
  /// from the spec without duplicating any the user already has.
  void seedRecommended(List<String> names) {
    final existing = state.map((h) => h.name).toSet();
    final toAdd = names.where((n) => !existing.contains(n)).map((n) => Habit(name: n)).toList();
    if (toAdd.isEmpty) return;
    state = [...state, ...toAdd];
    ref.read(journeyRepositoryProvider).saveHabits(state);
  }
}

final habitControllerProvider = NotifierProvider<HabitController, List<Habit>>(HabitController.new);

final habitConsistencyProvider = Provider<double>((ref) {
  final habits = ref.watch(habitControllerProvider);
  if (habits.isEmpty) return 0;
  return habits.where((h) => h.completedToday).length / habits.length;
});

class HabitTrackingScreen extends ConsumerWidget {
  const HabitTrackingScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Habits')),
      body: ListView.builder(
        itemCount: habits.length,
        itemBuilder: (_, i) {
          final h = habits[i];
          return CheckboxListTile(
            value: h.completedToday,
            onChanged: (_) => ref.read(habitControllerProvider.notifier).toggleCompletion(h.name),
            title: Text(h.name),
            subtitle: Text('🔥 ${h.streak} day streak · ${h.frequency}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final ctrl = TextEditingController();
          showDialog(context: context, builder: (ctx) => AlertDialog(
            title: const Text('New habit'),
            content: TextField(controller: ctrl, autofocus: true),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              FilledButton(onPressed: () {
                if (ctrl.text.isNotEmpty) ref.read(habitControllerProvider.notifier).addCustomHabit(ctrl.text);
                Navigator.pop(ctx);
              }, child: const Text('Add')),
            ],
          ));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
