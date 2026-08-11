import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/journey_repository_provider.dart';
import '../ai_plan/providers/ai_plan_provider.dart';
import '../notifications/notification_service.dart';

class WaterController extends Notifier<int> {
  @override
  int build() => ref.read(journeyRepositoryProvider).waterFor(DateTime.now());

  Future<void> quickAdd(int ml) async {
    state += ml;
    await ref.read(journeyRepositoryProvider).saveWater(DateTime.now(), state);
    final target = ref.read(aiPlanControllerProvider)?.waterTarget ?? 2000;
    if (state >= target) await ref.read(journeyRepositoryProvider).recordActivity('water');
  }
}

final waterControllerProvider = NotifierProvider<WaterController, int>(WaterController.new);

final waterProgressProvider = Provider<double>((ref) {
  final target = ref.watch(aiPlanControllerProvider)?.waterTarget ?? 2000;
  return (ref.watch(waterControllerProvider) / target).clamp(0, 1);
});

final weeklyWaterHistoryProvider = Provider<List<int>>((ref) {
  final repo = ref.watch(journeyRepositoryProvider);
  final today = DateTime.now();
  return [for (var i = 6; i >= 0; i--) repo.waterFor(today.subtract(Duration(days: i)))];
});

class WaterTrackingScreen extends ConsumerWidget {
  const WaterTrackingScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ml = ref.watch(waterControllerProvider);
    final progress = ref.watch(waterProgressProvider);
    final history = ref.watch(weeklyWaterHistoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Water'), actions: [
        IconButton(
          icon: const Icon(Icons.notifications_active_outlined),
          tooltip: 'Enable reminders',
          onPressed: () async {
            await ref.read(notificationServiceProvider).scheduleWaterReminder();
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Water reminders enabled')));
          },
        ),
      ]),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Center(
          child: Column(children: [
            SizedBox(width: 140, height: 140, child: Stack(alignment: Alignment.center, children: [
              CircularProgressIndicator(value: progress, strokeWidth: 10),
              Text('$ml ml', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ])),
            const SizedBox(height: 24),
            Wrap(spacing: 8, children: [250, 500, 750, 1000].map((amt) =>
              OutlinedButton(onPressed: () => ref.read(waterControllerProvider.notifier).quickAdd(amt), child: Text('+$amt ml'))
            ).toList()),
          ]),
        ),
        const SizedBox(height: 32),
        const Text('Last 7 days', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: Row(children: history.map((v) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                Container(height: (v / 40).clamp(4, 60).toDouble(), decoration: BoxDecoration(color: Colors.blue[300], borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 4),
                Text('${v ~/ 1000}L', style: const TextStyle(fontSize: 10)),
              ]),
            ),
          )).toList()),
        ),
      ]),
    );
  }
}
