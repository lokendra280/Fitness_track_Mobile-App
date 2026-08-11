import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/dashboard_data.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(dashboardDataProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Your journey')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _ProgressCard(data: data),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                  child: _StatTile(
                      icon: Icons.calendar_today,
                      label: 'Days left',
                      value: data.daysRemaining?.toString() ?? '–')),
              const SizedBox(width: 12),
              Expanded(
                  child: _StatTile(
                      icon: Icons.local_fire_department,
                      label: 'Streak',
                      value: '${data.journeyStreak}d')),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: _StatTile(
                      icon: Icons.remove_circle_outline,
                      label: 'Remaining',
                      value: data.remainingWeight != null
                          ? '${data.remainingWeight!.abs().toStringAsFixed(1)} kg'
                          : '–')),
              const SizedBox(width: 12),
              Expanded(
                  child: _StatTile(
                      icon: Icons.checklist,
                      label: 'Habits',
                      value: '${(data.habitConsistency * 100).round()}%')),
            ]),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => context.push('/weekly-review'),
              child: const _AiInsightCard(),
            ),
            const SizedBox(height: 24),
            Text('Quick actions',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            _QuickActionsRow(),
            const SizedBox(height: 24),
            Text('Today', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            _TodayProgressCard(data: data),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_view_week),
              title: const Text('Weekly summary'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/weekly-review'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.description_outlined),
              title: const Text('Reports & export'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/reports'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiInsightCard extends ConsumerWidget {
  const _AiInsightCard();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insight = ref.watch(aiInsightProvider);
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          const Icon(Icons.auto_awesome),
          const SizedBox(width: 12),
          Expanded(
            child: insight.when(
              loading: () => const Text('Generating your insight…'),
              error: (_, __) => const Text(
                  'AI insight unavailable — tap for full weekly review'),
              data: (text) =>
                  Text(text, maxLines: 3, overflow: TextOverflow.ellipsis),
            ),
          ),
        ]),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final DashboardData data;
  const _ProgressCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final pct = data.progressPercentage ?? 0.0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            SizedBox(
              width: 72,
              height: 72,
              child: Stack(alignment: Alignment.center, children: [
                CircularProgressIndicator(
                    value: pct,
                    strokeWidth: 7,
                    backgroundColor: Colors.grey[200]),
                Text('${(pct * 100).round()}%'),
              ]),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        data.currentWeight != null
                            ? '${data.currentWeight} kg'
                            : 'Log your weight',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                        data.targetWeight != null
                            ? 'Target: ${data.targetWeight} kg'
                            : 'No target set',
                        style: TextStyle(color: Colors.grey[600])),
                    if (data.weightLost != null) ...[
                      const SizedBox(height: 4),
                      Text(
                          '${data.weightLost!.abs().toStringAsFixed(1)} kg ${data.weightLost! >= 0 ? 'lost' : 'gained'} so far',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary)),
                    ],
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _StatTile(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(height: 8),
          Text(value,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ]),
      ),
    );
  }
}

class _TodayProgressCard extends StatelessWidget {
  final DashboardData data;
  const _TodayProgressCard({required this.data});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          _ProgressRow(
              label: 'Calories',
              value: data.calorieProgress,
              icon: Icons.local_fire_department),
          _ProgressRow(
              label: 'Water (${data.waterTarget}ml goal)',
              value: data.waterProgress,
              icon: Icons.water_drop),
          _ProgressRow(
              label: 'Steps (${data.stepTarget} goal)',
              value: data.stepsProgress,
              icon: Icons.directions_walk),
          _ProgressRow(
              label: 'Sleep', value: data.sleepProgress, icon: Icons.bedtime),
        ]),
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;
  const _ProgressRow(
      {required this.label, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
        SizedBox(
            width: 100,
            child: LinearProgressIndicator(
                value: value.clamp(0, 1),
                minHeight: 6,
                borderRadius: BorderRadius.circular(4))),
      ]),
    );
  }
}

class _QuickActionsRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = [
      (Icons.monitor_weight, 'Weight', () => _showLogWeightSheet(context, ref)),
      (Icons.restaurant, 'Food', () => context.push('/food')),
      (Icons.water_drop, 'Water', () => context.push('/water')),
      (Icons.directions_run, 'Workout', () => context.push('/activity')),
      (Icons.bedtime, 'Sleep', () => context.push('/sleep')),
      (Icons.straighten, 'Body', () => context.push('/body-progress')),
      (Icons.checklist, 'Habits', () => context.push('/habits')),
      (Icons.edit_calendar, 'Check-in', () => context.push('/check-in')),
      (Icons.auto_awesome, 'AI review', () => context.push('/ai-review')),
      (Icons.chat_bubble, 'Ask AI', () => context.push('/ai-coach')),
      (Icons.emoji_events, 'Milestones', () => context.push('/milestones')),
      (Icons.settings, 'Privacy', () => context.push('/privacy')),
    ];

    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final (icon, label, onTap) = actions[i];
          return InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 72,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon),
                    const SizedBox(height: 4),
                    Text(label,
                        style: const TextStyle(fontSize: 11),
                        textAlign: TextAlign.center),
                  ]),
            ),
          );
        },
      ),
    );
  }

  void _showLogWeightSheet(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Log today\'s weight',
                  style: Theme.of(ctx).textTheme.titleMedium),
              const SizedBox(height: 16),
              TextField(
                  controller: ctrl,
                  autofocus: true,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      labelText: 'Weight (kg)', border: OutlineInputBorder())),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () async {
                  final w = double.tryParse(ctrl.text);
                  if (w == null) return;
                  await ref
                      .read(weightLogControllerProvider.notifier)
                      .logWeight(w);
                  if (ctx.mounted) Navigator.of(ctx).pop();
                },
                child: const Text('Save'),
              ),
            ]),
      ),
    );
  }
}
