import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/ai_plan.dart';
import '../providers/ai_plan_provider.dart';

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
          loading: () => _LoadingState(theme: theme, colorScheme: colorScheme),
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

class _LoadingState extends StatelessWidget {
  final ThemeData theme;
  final ColorScheme colorScheme;
  const _LoadingState({required this.theme, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primaryContainer,
              ),
              child: Center(
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Building your plan',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tailoring targets to what you told us…',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
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
                  colorScheme.primary.withOpacity(0.82)
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
                    color: colorScheme.onPrimary.withOpacity(0.85),
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
                    color: colorScheme.onPrimary.withOpacity(0.85),
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
              _PlanTile(
                icon: Icons.fitness_center_rounded,
                color: Colors.deepOrange,
                label: 'Exercise',
                value: plan.exerciseFrequency.replaceAll('_', ' '),
              ),
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
                _ListSection(
                  icon: Icons.check_circle_outline_rounded,
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
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
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
                        'Not medical advice — a general wellness plan based on what you told us.',
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
                  if (context.mounted) context.go('/dashboard');
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
                    fillColor:
                        colorScheme.surfaceContainerHighest.withOpacity(0.4),
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
                    fillColor:
                        colorScheme.surfaceContainerHighest.withOpacity(0.4),
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
            color: colorScheme.shadow.withOpacity(0.04),
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
              color: color.withOpacity(0.12),
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
            color: colorScheme.shadow.withOpacity(0.04),
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
