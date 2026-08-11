import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/tracking_models.dart';
import '../../data/repositories/journey_repository_provider.dart';

class SleepController extends Notifier<SleepEntry?> {
  @override
  SleepEntry? build() => ref.read(journeyRepositoryProvider).sleepFor(DateTime.now());
  Future<void> syncFromHealth(SleepEntry e) async {
    state = e;
    await ref.read(journeyRepositoryProvider).saveSleep(DateTime.now(), e);
  }
}

final sleepControllerProvider = NotifierProvider<SleepController, SleepEntry?>(SleepController.new);

class SleepTrackingScreen extends ConsumerStatefulWidget {
  const SleepTrackingScreen({super.key});
  @override
  ConsumerState<SleepTrackingScreen> createState() => _State();
}

class _State extends ConsumerState<SleepTrackingScreen> {
  late TextEditingController hoursCtrl;
  TimeOfDay? bedtime, wakeTime;
  String? quality;

  @override
  void initState() {
    super.initState();
    final sleep = ref.read(sleepControllerProvider);
    hoursCtrl = TextEditingController(text: sleep?.hours.toString() ?? '');
    quality = sleep?.quality;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sleep')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Goal: 7–9 hours', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          TextField(controller: hoursCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Hours slept', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  final t = await showTimePicker(context: context, initialTime: bedtime ?? const TimeOfDay(hour: 22, minute: 30));
                  if (t != null) setState(() => bedtime = t);
                },
                child: Text(bedtime == null ? 'Bedtime' : 'Bed: ${bedtime!.format(context)}'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  final t = await showTimePicker(context: context, initialTime: wakeTime ?? const TimeOfDay(hour: 7, minute: 0));
                  if (t != null) setState(() => wakeTime = t);
                },
                child: Text(wakeTime == null ? 'Wake time' : 'Wake: ${wakeTime!.format(context)}'),
              ),
            ),
          ]),
          const SizedBox(height: 16),
          Wrap(spacing: 8, children: ['poor', 'fair', 'good', 'excellent'].map((q) => ChoiceChip(label: Text(q), selected: quality == q, onSelected: (_) => setState(() => quality = q))).toList()),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              final h = double.tryParse(hoursCtrl.text);
              if (h == null) return;
              ref.read(sleepControllerProvider.notifier).syncFromHealth(SleepEntry(
                    hours: h, quality: quality, bedtime: bedtime?.format(context), wakeTime: wakeTime?.format(context),
                  ));
            },
            child: const Text('Save'),
          ),
        ]),
      ),
    );
  }
}
