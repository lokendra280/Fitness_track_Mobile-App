import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/tracking_models.dart';
import '../../data/repositories/journey_repository_provider.dart';
import 'progress_photos.dart';

class BodyProgressController extends Notifier<List<BodyMeasurement>> {
  @override
  List<BodyMeasurement> build() => ref.read(journeyRepositoryProvider).measurements();
  Future<void> addMeasurement(BodyMeasurement m) async {
    await ref.read(journeyRepositoryProvider).addMeasurement(m);
    state = [...state, m];
  }
}

final bodyProgressControllerProvider = NotifierProvider<BodyProgressController, List<BodyMeasurement>>(BodyProgressController.new);

class BodyProgressScreen extends ConsumerWidget {
  const BodyProgressScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(bodyProgressControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Body progress')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Progress photos', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const PhotoComparisonWidget(),
          const SizedBox(height: 20),
          const Text('Measurements', style: TextStyle(fontWeight: FontWeight.w600)),
          ...list.reversed.map((m) => Card(
                child: ListTile(
                  title: Text(m.date.toLocal().toString().split(' ').first),
                  subtitle: Text('waist ${m.waist ?? '–'} · chest ${m.chest ?? '–'} · hips ${m.hips ?? '–'} · neck ${m.neck ?? '–'} · arms ${m.arms ?? '–'} · thighs ${m.thighs ?? '–'} · bf% ${m.bodyFatPercentage ?? '–'}'),
                  trailing: m.weight != null ? Text('${m.weight} kg') : null,
                ),
              )),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => _add(context, ref), child: const Icon(Icons.add)),
    );
  }

  void _add(BuildContext context, WidgetRef ref) {
    final ctrls = {for (final f in ['weight', 'waist', 'chest', 'hips', 'neck', 'arms', 'thighs', 'bodyFatPercentage']) f: TextEditingController()};
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          ...ctrls.entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextField(controller: e.value, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: e.key)),
              )),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () {
              ref.read(bodyProgressControllerProvider.notifier).addMeasurement(BodyMeasurement(
                    date: DateTime.now(),
                    weight: double.tryParse(ctrls['weight']!.text),
                    waist: double.tryParse(ctrls['waist']!.text),
                    chest: double.tryParse(ctrls['chest']!.text),
                    hips: double.tryParse(ctrls['hips']!.text),
                    neck: double.tryParse(ctrls['neck']!.text),
                    arms: double.tryParse(ctrls['arms']!.text),
                    thighs: double.tryParse(ctrls['thighs']!.text),
                    bodyFatPercentage: double.tryParse(ctrls['bodyFatPercentage']!.text),
                  ));
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ]),
      ),
    );
  }
}
