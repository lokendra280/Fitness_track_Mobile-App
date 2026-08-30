import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/router/app_router.dart';
import 'package:habitflow/data/models/ai_plan.dart';
import 'package:habitflow/data/models/daily_workout.dart';
import 'package:habitflow/data/models/exercise_item.dart';
import 'package:habitflow/features/ai_plan/providers/ai_plan_provider.dart';
import 'package:habitflow/features/habit_tracking/providers/habit_proof_provider.dart';

class AiPlanScreen extends ConsumerWidget {
  const AiPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final generation = ref.watch(aiPlanGenerationProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: generation.when(
          loading: () => const _LoadingState(),
          error: (err, _) => _ErrorState(
            message: err.toString(),
            onRetry: () => ref.invalidate(aiPlanGenerationProvider),
          ),
          data: (plan) => _PlanReview(plan: plan),
        ),
      ),
    );
  }
}

/// Cycles through the plan's target categories while it generates —
/// reads as "actively building something" rather than a static spinner.
class _LoadingState extends StatefulWidget {
  const _LoadingState();

  @override
  State<_LoadingState> createState() => _LoadingStateState();
}

class _LoadingStateState extends State<_LoadingState>
    with SingleTickerProviderStateMixin {
  static const _steps = [
    (Icons.water_drop_rounded, 'Calculating your water target'),
    (Icons.directions_walk_rounded, 'Setting a daily step goal'),
    (Icons.fitness_center_rounded, 'Planning your exercise routine'),
    (Icons.bedtime_rounded, 'Balancing your sleep schedule'),
    (Icons.checklist_rounded, 'Choosing habits that fit'),
  ];

  int _index = 0;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1400), (_) {
      if (mounted) setState(() => _index = (_index + 1) % _steps.length);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final (icon, label) = _steps[_index];

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 88,
              height: 88,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const SizedBox(
                    width: 88,
                    height: 88,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (child, anim) => ScaleTransition(
                      scale: anim,
                      child: FadeTransition(opacity: anim, child: child),
                    ),
                    child: Icon(
                      icon,
                      key: ValueKey(icon),
                      size: 32,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Building your plan',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                label,
                key: ValueKey(label),
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.errorContainer,
              ),
              child: Icon(Icons.error_outline_rounded,
                  size: 32, color: colorScheme.onErrorContainer),
            ),
            const SizedBox(height: 20),
            Text('Something went wrong', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                minimumSize: const Size(160, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanReview extends ConsumerWidget {
  final AiPlan plan;
  const _PlanReview({required this.plan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(aiPlanControllerProvider.notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withValues(alpha: 0.82)
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step 3 of 3',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onPrimary.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your plan is ready',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Built around your goals, activity, and diet.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimary.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _PlanTile(
                icon: Icons.water_drop_rounded,
                color: Colors.blue,
                label: 'Water target',
                value: '${plan.waterTarget} ml/day',
              ),
              _PlanTile(
                icon: Icons.directions_walk_rounded,
                color: Colors.green,
                label: 'Step target',
                value: '${plan.stepTarget} steps/day',
              ),
              if (plan.weeklySchedule.isNotEmpty) ...[
                const SizedBox(height: 20),
                _WeeklyScheduleSection(schedule: plan.weeklySchedule),
              ],
              _PlanTile(
                icon: Icons.bedtime_rounded,
                color: Colors.indigo,
                label: 'Sleep target',
                value: plan.sleepTarget.replaceAll('_', ' '),
              ),
              _PlanTile(
                icon: Icons.restaurant_rounded,
                color: Colors.teal,
                label: 'Meal tracking',
                value: plan.mealTracking ? 'Enabled' : 'Disabled',
              ),
              if (plan.recommendedHabits.isNotEmpty) ...[
                const SizedBox(height: 20),
                _HabitListSection(
                  title: 'Recommended habits',
                  items: plan.recommendedHabits,
                ),
              ],
              if (plan.milestones.isNotEmpty) ...[
                const SizedBox(height: 20),
                _ListSection(
                  icon: Icons.flag_outlined,
                  title: 'Milestones',
                  items: plan.milestones,
                ),
              ],
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 18, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Habits marked with a camera or water icon will '
                        'ask for a quick photo or glass count when you '
                        'complete them — everything else is a simple tap.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: () async {
                  await controller.acceptPlan(plan);
                  if (context.mounted) context.go(AppRoutes.bottomNavbar);
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Accept plan', style: theme.textTheme.labelLarge),
                    const SizedBox(width: 6),
                    const Icon(Icons.check_rounded, size: 18),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => ref.invalidate(aiPlanGenerationProvider),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  side: BorderSide(color: colorScheme.outlineVariant),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh_rounded,
                        size: 18, color: colorScheme.primary),
                    const SizedBox(width: 6),
                    Text('Regenerate',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.primary,
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => _showCustomizeSheet(context, ref, plan),
                child: const Text('Customize'),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  void _showCustomizeSheet(BuildContext context, WidgetRef ref, AiPlan plan) {
    final waterCtrl = TextEditingController(text: plan.waterTarget.toString());
    final stepCtrl = TextEditingController(text: plan.stepTarget.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text('Customize plan',
                    style: Theme.of(ctx).textTheme.titleMedium),
                const SizedBox(height: 20),
                TextField(
                  controller: waterCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Water target (ml)',
                    prefixIcon: const Icon(Icons.water_drop_rounded, size: 20),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: stepCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Step target',
                    prefixIcon:
                        const Icon(Icons.directions_walk_rounded, size: 20),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () async {
                    final water =
                        int.tryParse(waterCtrl.text) ?? plan.waterTarget;
                    final steps =
                        int.tryParse(stepCtrl.text) ?? plan.stepTarget;
                    await ref
                        .read(aiPlanControllerProvider.notifier)
                        .acceptPlan(
                          plan.copyWith(waterTarget: water, stepTarget: steps),
                        );
                    if (ctx.mounted) Navigator.of(ctx).pop();
                    if (context.mounted) context.go('/dashboard');
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Save & accept'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PlanTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _PlanTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
          Text(value, style: theme.textTheme.titleSmall),
        ],
      ),
    );
  }
}

class _ListSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> items;

  const _ListSection({
    required this.icon,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleSmall),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, size: 18, color: colorScheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(item, style: theme.textTheme.bodyMedium)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

/// Same shape as _ListSection but adds a proof-type icon (camera/water)
/// next to any recommended habit that inferProofType() flags as needing
/// evidence — makes it visible upfront, before the user even accepts.
class _HabitListSection extends StatelessWidget {
  final String title;
  final List<String> items;

  const _HabitListSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleSmall),
          const SizedBox(height: 12),
          ...items.map((item) {
            final proofType = inferProofType(item);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_outline_rounded,
                      size: 18, color: colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(item, style: theme.textTheme.bodyMedium)),
                  if (proofType != HabitProofType.none)
                    Icon(
                      proofType == HabitProofType.photo
                          ? Icons.camera_alt_rounded
                          : Icons.local_drink_rounded,
                      size: 16,
                      color: colorScheme.secondary,
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Day-by-day workout view: a horizontal day selector (rest days visibly
/// dimmed) with the selected day's focus + exercises below.
class _WeeklyScheduleSection extends StatefulWidget {
  final List<DailyWorkout> schedule;
  const _WeeklyScheduleSection({required this.schedule});

  @override
  State<_WeeklyScheduleSection> createState() => _WeeklyScheduleSectionState();
}

class _WeeklyScheduleSectionState extends State<_WeeklyScheduleSection> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    // Default to today's weekday if it's in the schedule, else day 0.
    final todayName = const [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ][DateTime.now().weekday - 1];
    final idx = widget.schedule.indexWhere((d) => d.day == todayName);
    _selectedIndex = idx == -1 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selected = widget.schedule[_selectedIndex];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly schedule', style: theme.textTheme.titleSmall),
          const SizedBox(height: 14),
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.schedule.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final day = widget.schedule[i];
                final isSelected = i == _selectedIndex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 52,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary
                          : day.isRestDay
                              ? colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.4)
                              : colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          day.day.substring(0, 3).toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isSelected
                                ? colorScheme.onPrimary
                                : day.isRestDay
                                    ? colorScheme.onSurfaceVariant
                                    : colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Icon(
                          day.isRestDay
                              ? Icons.self_improvement_rounded
                              : Icons.fitness_center_rounded,
                          size: 16,
                          color: isSelected
                              ? colorScheme.onPrimary
                              : day.isRestDay
                                  ? colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.5)
                                  : colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          if (selected.isRestDay)
            SingleChildScrollView(
              child: Row(
                children: [
                  Icon(Icons.self_improvement_rounded,
                      size: 18, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Rest day — recovery is part of the plan.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            if (selected.focus != null) ...[
              Text(
                selected.focus!,
                style: theme.textTheme.titleSmall
                    ?.copyWith(color: colorScheme.primary),
              ),
              const SizedBox(height: 10),
            ],
            ...selected.exercises.map((e) => _ExerciseRow(exercise: e)),
          ],
        ],
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  final ExerciseItem exercise;
  const _ExerciseRow({required this.exercise});

  Color _categoryColor(BuildContext context) {
    switch (exercise.category) {
      case ExerciseCategory.cardio:
        return Colors.redAccent;
      case ExerciseCategory.mobility:
        return Colors.purpleAccent;
      case ExerciseCategory.strength:
        return Colors.blueAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _categoryColor(context),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(exercise.name, style: theme.textTheme.bodyMedium),
          ),
          Text(
            exercise.sets,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
