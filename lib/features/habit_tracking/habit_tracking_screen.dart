import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/features/habit_tracking/providers/habit_tracking_provider.dart';
import 'package:habitflow/features/habit_tracking/widgets/add_habit_shett.dart';
import 'package:habitflow/features/habit_tracking/widgets/habit_title.dart';

class HabitTrackingScreen extends ConsumerWidget {
  const HabitTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitControllerProvider);
    final consistency = ref.watch(habitConsistencyProvider);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        title: Text('Habits', style: text.headlineMedium),
      ),
      body: SafeArea(
        child: habits.isEmpty
            ? _EmptyState(onAdd: () => showAddHabitSheet(context, ref))
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                children: [
                  _ConsistencyCard(
                    consistency: consistency,
                    total: habits.length,
                  ),
                  const SizedBox(height: 20),
                  for (final h in habits)
                    HabitTile(
                      habit: h,
                      onToggle: () => ref
                          .read(habitControllerProvider.notifier)
                          .toggleCompletion(h.name),
                    ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddHabitSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New habit'),
      ),
    );
  }
}

class _ConsistencyCard extends StatelessWidget {
  final double consistency;
  final int total;
  const _ConsistencyCard({required this.consistency, required this.total});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final done = (consistency * total).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.primary.withValues(alpha: 0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: scheme.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
      ),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TODAY',
                  style: text.labelMedium
                      ?.copyWith(color: Colors.white70, letterSpacing: 1.2)),
              const SizedBox(height: 6),
              Text('$done of $total done',
                  style: text.headlineMedium?.copyWith(color: Colors.white)),
            ],
          ),
        ),
        SizedBox(
          width: 64,
          height: 64,
          child: Stack(alignment: Alignment.center, children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: consistency),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => CircularProgressIndicator(
                value: v,
                strokeWidth: 6,
                strokeCap: StrokeCap.round,
                backgroundColor: Colors.white.withValues(alpha: 0.25),
                valueColor: const AlwaysStoppedAnimation(Colors.white),
              ),
            ),
            Text('${(consistency * 100).round()}%',
                style: text.titleSmall?.copyWith(color: Colors.white)),
          ]),
        ),
      ]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.checklist_rounded, size: 48, color: scheme.outline),
        const SizedBox(height: 12),
        Text('No habits yet', style: text.titleMedium),
        const SizedBox(height: 4),
        Text('Add one to start building your streak', style: text.bodyMedium),
        const SizedBox(height: 16),
        FilledButton.tonal(
            onPressed: onAdd, child: const Text('Add your first habit')),
      ]),
    );
  }
}
