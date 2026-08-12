import 'package:flutter/material.dart';
import 'package:habitflow/data/models/tracking_models.dart';
import 'package:habitflow/features/food_tracking/providers/food_tracking_provider.dart';

/// A single logged food entry row.
class FoodCard extends StatelessWidget {
  final FoodEntry entry;
  const FoodCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12)),
          child: Icon(mealIcons[entry.mealType] ?? Icons.restaurant,
              color: scheme.onSecondaryContainer, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(entry.name, style: text.titleMedium),
            Text(entry.mealType, style: text.labelMedium),
          ]),
        ),
        Text('${entry.calories.round()} kcal',
            style: text.titleMedium?.copyWith(color: scheme.primary)),
      ]),
    );
  }
}
