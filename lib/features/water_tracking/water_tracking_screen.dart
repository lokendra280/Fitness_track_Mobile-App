import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/features/water_tracking/providers/water_tracking_provider.dart';
import 'package:habitflow/features/water_tracking/widgets/quick_add_chip.dart';
import 'package:habitflow/features/water_tracking/widgets/water_ring.dart';
import 'package:habitflow/features/water_tracking/widgets/weakly_water_chart.dart';
import '../notifications/notification_service.dart';

class WaterTrackingScreen extends ConsumerWidget {
  const WaterTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ml = ref.watch(waterControllerProvider);
    final progress = ref.watch(waterProgressProvider);
    final history = ref.watch(weeklyWaterHistoryProvider);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        title: Text('Water', style: text.headlineMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined),
            tooltip: 'Enable reminders',
            onPressed: () async {
              await ref
                  .read(notificationServiceProvider)
                  .scheduleWaterReminder();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Water reminders enabled')));
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Center(
              child: Column(children: [
                WaterRing(ml: ml, progress: progress),
                const SizedBox(height: 28),
                QuickAddChips(
                    amounts: const [250, 500, 750, 1000],
                    onAdd: (amt) => ref
                        .read(waterControllerProvider.notifier)
                        .quickAdd(amt)),
              ]),
            ),
            const SizedBox(height: 32),
            Text('Last 7 days', style: text.titleLarge),
            const SizedBox(height: 12),
            WeeklyWaterChart(history: history),
          ],
        ),
      ),
    );
  }
}
