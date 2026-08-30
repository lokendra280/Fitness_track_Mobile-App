import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/features/dashboard/providers/dashboard_providers.dart';
import 'package:habitflow/data/repositories/journey_repository_provider.dart';

Future<void> showLogWeightSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => const _LogWeightSheetContent(),
  );
}

class _LogWeightSheetContent extends ConsumerStatefulWidget {
  const _LogWeightSheetContent();

  @override
  ConsumerState<_LogWeightSheetContent> createState() =>
      _LogWeightSheetContentState();
}

class _LogWeightSheetContentState
    extends ConsumerState<_LogWeightSheetContent> {
  final _ctrl = TextEditingController();
  bool _saving = false;
  String? _error;

  /// Set when a plausibility check fails and we want the user to confirm
  /// before saving — e.g. a big jump from their last logged weight,
  /// which usually means they typed a delta ("lost 5kg") instead of an
  /// absolute weight.
  bool _needsConfirmation = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final w = double.tryParse(_ctrl.text);
    if (w == null) {
      setState(() {
        _error = 'Enter a valid weight';
        _needsConfirmation = false;
      });
      return;
    }

    final last = ref.read(journeyRepositoryProvider).latestLoggedWeight();

    // If this is a big jump from the last entry and the user hasn't
    // already confirmed, flag it instead of silently saving — catches
    // someone typing "5" meaning "I lost 5kg" rather than their actual
    // current weight.
    if (!_needsConfirmation && last != null && (w - last).abs() >= 15) {
      setState(() {
        _needsConfirmation = true;
        _error = null;
      });
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(weightLogControllerProvider.notifier).logWeight(w);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = "Couldn't save — try again";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lastWeight =
        ref.watch(journeyRepositoryProvider).latestLoggedWeight();

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
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
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Text("Log today's weight",
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Enter what you weigh right now — like stepping on a scale, '
            'not how much you\'ve gained or lost.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey.shade600),
          ),
          if (lastWeight != null) ...[
            const SizedBox(height: 8),
            Text(
              'Last logged: ${lastWeight.toStringAsFixed(1)} kg',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey.shade600),
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            autofocus: true,
            enabled: !_saving,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) {
              // Any edit invalidates a pending confirmation — re-check
              // the new value fresh next time Save is pressed.
              if (_needsConfirmation) {
                setState(() => _needsConfirmation = false);
              }
            },
            decoration: InputDecoration(
              labelText: 'Your current weight (kg)',
              hintText: lastWeight != null
                  ? 'e.g. ${lastWeight.toStringAsFixed(0)}'
                  : 'e.g. 70',
              border: const OutlineInputBorder(),
              errorText: _error,
            ),
          ),
          if (_needsConfirmation) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline,
                      size: 18, color: Colors.orange.shade800),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "That's a big change from your last entry "
                      "(${lastWeight!.toStringAsFixed(1)} kg). Make sure "
                      "you entered your current weight, not the amount "
                      "lost or gained. Tap Save again to confirm.",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.orange.shade900,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text(_needsConfirmation ? 'Confirm & Save' : 'Save'),
          ),
        ],
      ),
    );
  }
}
