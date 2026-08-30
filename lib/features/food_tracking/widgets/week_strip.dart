import 'package:flutter/material.dart';

class WeekStrip extends StatelessWidget {
  final DateTime selectedDate;
  const WeekStrip({required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    const labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    // Sunday-start week containing selectedDate.
    final weekdayFromSunday = selectedDate.weekday % 7; // Sun=0..Sat=6
    final sunday = selectedDate.subtract(Duration(days: weekdayFromSunday));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final day = sunday.add(Duration(days: i));
        final isToday = day.year == selectedDate.year &&
            day.month == selectedDate.month &&
            day.day == selectedDate.day;
        final isPast = day.isBefore(
            DateTime(selectedDate.year, selectedDate.month, selectedDate.day));

        // TODO: replace with a real "was this day fully logged" check
        // once a per-day completion provider exists — currently just
        // marks past days as done and future days as empty, matching
        // the screenshot's visual pattern without real data behind it.
        final done = isPast;

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
                color: done ? Colors.black : Colors.transparent,
                border: Border.all(
                  color: isToday
                      ? scheme.primary
                      : done
                          ? Colors.black
                          : Colors.grey.shade300,
                  width: isToday ? 2 : 1,
                ),
              ),
              child: done
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 18)
                  : null,
            ),
          ],
        );
      }),
    );
  }
}
