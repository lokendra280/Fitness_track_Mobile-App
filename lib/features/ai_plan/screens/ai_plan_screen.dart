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

    return Scaffold(
      appBar: AppBar(title: const Text('Your AI-generated plan')),
      body: SafeArea(
        child: generation.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Building a plan tailored to you…'),
                ],
              ),
            ),
          ),
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

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40, color: Colors.red),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
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

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _PlanCard(icon: Icons.water_drop, label: 'Water target', value: '${plan.waterTarget} ml/day'),
        _PlanCard(icon: Icons.directions_walk, label: 'Step target', value: '${plan.stepTarget} steps/day'),
        _PlanCard(icon: Icons.fitness_center, label: 'Exercise', value: plan.exerciseFrequency.replaceAll('_', ' ')),
        _PlanCard(icon: Icons.bedtime, label: 'Sleep target', value: plan.sleepTarget.replaceAll('_', ' ')),
        _PlanCard(
          icon: Icons.restaurant,
          label: 'Meal tracking',
          value: plan.mealTracking ? 'Enabled' : 'Disabled',
        ),
        const SizedBox(height: 16),
        if (plan.recommendedHabits.isNotEmpty) ...[
          Text('Recommended habits', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          ...plan.recommendedHabits.map((h) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(children: [const Icon(Icons.check, size: 18), const SizedBox(width: 8), Expanded(child: Text(h))]),
              )),
          const SizedBox(height: 16),
        ],
        if (plan.milestones.isNotEmpty) ...[
          Text('Milestones', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          ...plan.milestones.map((m) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(children: [const Icon(Icons.flag, size: 18), const SizedBox(width: 8), Expanded(child: Text(m))]),
              )),
        ],
        const SizedBox(height: 4),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Not medical advice — a general wellness plan based on what you told us.',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () async {
            await controller.acceptPlan(plan);
            if (context.mounted) context.go('/dashboard');
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Accept plan'),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => ref.invalidate(aiPlanGenerationProvider),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Regenerate'),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => _showCustomizeSheet(context, ref, plan),
          child: const Text('Customize'),
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
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Customize plan', style: Theme.of(ctx).textTheme.titleMedium),
            const SizedBox(height: 16),
            TextField(
              controller: waterCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Water target (ml)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: stepCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Step target', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () async {
                final water = int.tryParse(waterCtrl.text) ?? plan.waterTarget;
                final steps = int.tryParse(stepCtrl.text) ?? plan.stepTarget;
                await ref.read(aiPlanControllerProvider.notifier).acceptPlan(
                      plan.copyWith(waterTarget: water, stepTarget: steps),
                    );
                if (ctx.mounted) Navigator.of(ctx).pop();
                if (context.mounted) context.go('/dashboard');
              },
              child: const Text('Save & accept'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _PlanCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
