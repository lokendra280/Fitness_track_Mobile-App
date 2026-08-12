import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/data/models/tracking_models.dart';
import 'package:habitflow/features/food_tracking/providers/food_tracking_provider.dart';

/// Opens the "add food manually" bottom sheet.
void showAddFoodSheet(BuildContext context, WidgetRef ref, DateTime day) {
  final nameCtrl = TextEditingController();
  final calCtrl = TextEditingController();
  final fiberCtrl = TextEditingController();
  final servingCtrl = TextEditingController();
  final qtyCtrl = TextEditingController();
  String meal = 'breakfast';
  final recents = ref.read(recentFoodsProvider);
  final favorites = ref.read(favoriteFoodsProvider);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => Padding(
        padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: SingleChildScrollView(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Add food', style: Theme.of(ctx).textTheme.titleLarge),
                const SizedBox(height: 12),
                if (favorites.isNotEmpty) ...[
                  Text('Favorites', style: Theme.of(ctx).textTheme.labelMedium),
                  Wrap(
                    spacing: 6,
                    children: favorites
                        .map((f) => ActionChip(
                            avatar: const Icon(Icons.star, size: 14),
                            label: Text(f),
                            onPressed: () => nameCtrl.text = f))
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                ],
                if (recents.isNotEmpty) ...[
                  Text('Recent', style: Theme.of(ctx).textTheme.labelMedium),
                  Wrap(
                      spacing: 6,
                      children: recents
                          .take(8)
                          .map((f) => ActionChip(
                              label: Text(f),
                              onPressed: () => nameCtrl.text = f))
                          .toList()),
                  const SizedBox(height: 12),
                ],
                DropdownButtonFormField<String>(
                  value: meal,
                  items: mealIcons.keys
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (v) => setState(() => meal = v ?? meal),
                  decoration: const InputDecoration(
                      labelText: 'Meal', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Food name', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(
                    controller: calCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Calories', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                      child: TextField(
                          controller: servingCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'Serving size (g)',
                              border: OutlineInputBorder()))),
                  const SizedBox(width: 8),
                  Expanded(
                      child: TextField(
                          controller: qtyCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'Quantity',
                              border: OutlineInputBorder()))),
                ]),
                const SizedBox(height: 12),
                TextField(
                    controller: fiberCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Fiber (g)', border: OutlineInputBorder())),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        final cal = double.tryParse(calCtrl.text);
                        if (nameCtrl.text.isEmpty || cal == null) return;
                        ref
                            .read(foodLogProvider(day).notifier)
                            .addEntry(FoodEntry(
                              mealType: meal,
                              name: nameCtrl.text,
                              calories: cal,
                              fiber: double.tryParse(fiberCtrl.text),
                              servingSize: double.tryParse(servingCtrl.text),
                              quantity: double.tryParse(qtyCtrl.text),
                            ));
                        Navigator.of(ctx).pop();
                      },
                      child: const Text('Add'),
                    ),
                  ),
                  IconButton(
                    icon: Icon(favorites.contains(nameCtrl.text)
                        ? Icons.star
                        : Icons.star_border),
                    onPressed: nameCtrl.text.isEmpty
                        ? null
                        : () => ref
                            .read(favoriteFoodControllerProvider.notifier)
                            .toggle(nameCtrl.text),
                  ),
                ]),
              ]),
        ),
      ),
    ),
  );
}
