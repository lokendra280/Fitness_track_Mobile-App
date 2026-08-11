import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/journey_setup_provider.dart';

class JourneySetupScreen extends ConsumerStatefulWidget {
  const JourneySetupScreen({super.key});

  @override
  ConsumerState<JourneySetupScreen> createState() => _JourneySetupScreenState();
}

class _JourneySetupScreenState extends ConsumerState<JourneySetupScreen> {
  late final TextEditingController _startCtrl;
  late final TextEditingController _targetCtrl;

  @override
  void initState() {
    super.initState();
    final goal = ref.read(journeySetupControllerProvider);
    _startCtrl =
        TextEditingController(text: goal.startingWeight?.toString() ?? '');
    _targetCtrl =
        TextEditingController(text: goal.targetWeight?.toString() ?? '');
  }

  @override
  void dispose() {
    _startCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(journeySetupControllerProvider.notifier);
    final goal = ref.watch(journeySetupControllerProvider);
    final isValid = ref.watch(journeySetupValidProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Start your journey')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Goal',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'lose_weight', label: Text('Lose')),
                ButtonSegment(value: 'maintain', label: Text('Maintain')),
                ButtonSegment(value: 'gain_muscle', label: Text('Gain muscle')),
              ],
              selected: {goal.type},
              onSelectionChanged: (s) => controller.updateType(s.first),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _startCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Starting weight (${goal.weightUnit})',
                border: const OutlineInputBorder(),
              ),
              onChanged: (v) => controller.updateWeights(
                start: double.tryParse(v),
                current:
                    double.tryParse(v), // current defaults to starting weight
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _targetCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Target weight (${goal.weightUnit})',
                border: const OutlineInputBorder(),
              ),
              onChanged: (v) =>
                  controller.updateWeights(target: double.tryParse(v)),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(goal.targetDate == null
                  ? 'Pick a target date'
                  : 'Target date: ${goal.targetDate!.toLocal().toString().split(' ').first}'),
              trailing: const Icon(Icons.calendar_month),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 90)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 730)),
                );
                if (picked != null) controller.updateDates(target: picked);
              },
            ),
            if (goal.weightToLose != null) ...[
              const SizedBox(height: 8),
              Text(
                '${goal.weightToLose!.abs().toStringAsFixed(1)} ${goal.weightUnit} to '
                '${goal.weightToLose! >= 0 ? 'lose' : 'gain'}',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ],
            const SizedBox(height: 32),
            FilledButton(
              onPressed: isValid
                  ? () async {
                      await controller.submit();
                      if (context.mounted) context.push('/personal-profile');
                    }
                  : null,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Continue'),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () async {
                await controller.saveAndContinueLater();
                if (context.mounted) context.go('/dashboard');
              },
              child: const Text('Save & continue later'),
            ),
          ],
        ),
      ),
    );
  }
}
