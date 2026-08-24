import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/features/food_tracking/providers/food_tracking_provider.dart';
import '../../../data/models/tracking_models.dart';

class BarcodeScanResultSheet extends ConsumerStatefulWidget {
  final String barcode;
  final DateTime day;
  const BarcodeScanResultSheet(
      {super.key, required this.barcode, required this.day});

  @override
  ConsumerState<BarcodeScanResultSheet> createState() =>
      _BarcodeScanResultSheetState();
}

class _BarcodeScanResultSheetState
    extends ConsumerState<BarcodeScanResultSheet> {
  String _mealType = 'snack';
  double _servings = 1.0;

  @override
  Widget build(BuildContext context) {
    final lookup = ref.watch(barcodeFoodLookupProvider(widget.barcode));
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.55,
        maxChildSize: 0.85,
        minChildSize: 0.35,
        expand: false,
        builder: (ctx, scrollCtrl) => lookup.when(
          loading: () => const _Loading(),
          error: (e, _) => _Error(message: '$e'),
          data: (entry) {
            final scaled = FoodEntry(
              name: entry.name,
              calories: (entry.calories) * _servings,
              protein: (entry.protein ?? 0) * _servings,
              carbs: (entry.carbs ?? 0) * _servings,
              fat: (entry.fat ?? 0) * _servings,
              fiber: entry.fiber != null ? entry.fiber! * _servings : null,
              mealType: _mealType,
              servingSize: (entry.servingSize ?? 100) * _servings,
            );

            return ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              children: [
                Row(children: [
                  Text('Scanned item', style: text.titleLarge),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(999)),
                    child: Text('${scaled.calories.round()} kcal',
                        style: text.labelMedium?.copyWith(
                            color: scheme.onPrimaryContainer,
                            fontWeight: FontWeight.w700)),
                  ),
                ]),
                const SizedBox(height: 14),
                _ScannedItem(entry: scaled, perBase: entry),
                const SizedBox(height: 18),
                DropdownButtonFormField<String>(
                  initialValue: _mealType,
                  decoration: const InputDecoration(
                    labelText: 'Meal',
                    border: OutlineInputBorder(),
                  ),
                  items: mealIcons.keys
                      .map((m) => DropdownMenuItem(
                          value: m,
                          child: Text(m[0].toUpperCase() + m.substring(1))))
                      .toList(),
                  onChanged: (v) => setState(() => _mealType = v ?? _mealType),
                ),
                const SizedBox(height: 16),
                Row(children: [
                  Text('Servings', style: text.bodyMedium),
                  Expanded(
                    child: Slider(
                      value: _servings,
                      min: 0.25,
                      max: 5,
                      divisions: 19,
                      label: _servings.toStringAsFixed(2),
                      onChanged: (v) => setState(() => _servings = v),
                    ),
                  ),
                  Text(_servings.toStringAsFixed(2), style: text.bodyMedium),
                ]),
                const SizedBox(height: 8),
                FilledButton(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () async {
                    await ref
                        .read(foodLogProvider(widget.day).notifier)
                        .addEntry(scaled);
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  child: const Text('Add to log'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 48),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.qr_code_scanner_rounded, size: 44),
        const SizedBox(height: 20),
        Text('Looking up product…', style: text.bodyLarge),
        const SizedBox(height: 4),
        Text('Matching barcode to nutrition data', style: text.bodyMedium),
      ]),
    );
  }
}

class _Error extends StatelessWidget {
  final String message;
  const _Error({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.search_off_rounded, color: Colors.red, size: 40),
        const SizedBox(height: 12),
        Text(message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 16),
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close')),
      ]),
    );
  }
}

class _ScannedItem extends StatelessWidget {
  final FoodEntry entry; // scaled by current servings
  final FoodEntry perBase; // original per-100g values, for the subtitle
  const _ScannedItem({required this.entry, required this.perBase});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              borderRadius: BorderRadius.circular(11)),
          child: Icon(mealIcons[entry.mealType] ?? Icons.restaurant,
              color: scheme.onSecondaryContainer, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(entry.name, style: text.titleMedium),
            const SizedBox(height: 2),
            Wrap(spacing: 6, children: [
              _Badge(text: '${entry.calories.round()} kcal'),
              if (entry.servingSize != null)
                _Badge(text: '${entry.servingSize!.round()}g'),
              if (entry.fiber != null)
                _Badge(text: '${entry.fiber!.toStringAsFixed(1)}g fiber'),
            ]),
            const SizedBox(height: 4),
            Text(
              'Per 100g: ${perBase.calories.round()} kcal · '
              '${perBase.protein!.round()}g protein · '
              '${perBase.carbs!.round()}g carbs · '
              '${perBase.fat!.round()}g fat',
              style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}
