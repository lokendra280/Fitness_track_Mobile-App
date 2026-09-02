import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/food_tracking_provider.dart';

class WeekStrip extends ConsumerWidget {
  final DateTime selectedDate;
  const WeekStrip({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    const labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    // Sunday-start week containing selectedDate.
    final weekdayFromSunday = selectedDate.weekday % 7; // Sun=0..Sat=6
    final sunday = selectedDate.subtract(Duration(days: weekdayFromSunday));

    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final day = sunday.add(Duration(days: i));
        final dayKey = DateTime(day.year, day.month, day.day);

        final isToday = dayKey == todayKey;
        final isPast = dayKey.isBefore(todayKey);
        final isFuture = dayKey.isAfter(todayKey);

        // Real per-day check: did the user actually log any food that day?
        final entries = ref.watch(foodLogProvider(dayKey));
        final tracked = entries.isNotEmpty;

        // Only past/today days can be judged as "missed" — future days
        // stay neutral since there's nothing to have tracked yet.
        final missed = !isFuture && !tracked;

        Color borderColor;
        Color? fillColor;
        Widget? child;

        if (tracked) {
          fillColor = Colors.black;
          borderColor = Colors.black;
          child =
              const Icon(Icons.check_rounded, color: Colors.white, size: 18);
        } else if (missed) {
          fillColor = Colors.red.shade50;
          borderColor = Colors.red;
          child =
              Icon(Icons.close_rounded, color: Colors.red.shade400, size: 16);
        } else {
          fillColor = Colors.transparent;
          borderColor = Colors.grey.shade300;
          child = null;
        }

        if (isToday) {
          borderColor = scheme.primary;
        }

        return Column(
          children: [
            Text(labels[i],
                style: text.bodySmall?.copyWith(color: Colors.grey.shade500)),
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: fillColor,
                border: Border.all(
                  color: borderColor,
                  width: isToday ? 2 : 1,
                ),
              ),
              child: child,
            ),
          ],
        );
      }),
    );
  }
}
