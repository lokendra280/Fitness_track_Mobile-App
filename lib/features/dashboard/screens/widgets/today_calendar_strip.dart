import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/theme/app_theme.dart';

/// The "Today" week strip from the reference design: shows the current
/// week (Mon–Sun), highlights the selected day, and shows a small dot
/// under days that have completed activity.
///
/// [selectedDate] / [onDateSelected] make this controlled so the parent
/// screen owns which day is active. [daysWithActivity] should come from
/// a real provider (e.g. a set of dates with logged workouts) — passed
/// in here rather than faked, since no such data exists in the shared
/// code yet.
class TodayCalendarStrip extends ConsumerWidget {
  const TodayCalendarStrip({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.daysWithActivity = const {},
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final Set<DateTime> daysWithActivity;

  static const _dayLabels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

  DateTime _stripTime(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = _stripTime(DateTime.now());
    final selected = _stripTime(selectedDate);

    // Monday of the week containing `selected`.
    final weekStart = selected.subtract(Duration(days: selected.weekday - 1));
    final weekDates = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var i = 0; i < 7; i++)
          _DayCell(
            label: _dayLabels[i],
            date: weekDates[i],
            isToday: weekDates[i] == today,
            isSelected: weekDates[i] == selected,
            hasActivity: daysWithActivity.contains(weekDates[i]),
            onTap: () => onDateSelected(weekDates[i]),
          ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.label,
    required this.date,
    required this.isToday,
    required this.isSelected,
    required this.hasActivity,
    required this.onTap,
  });

  final String label;
  final DateTime date;
  final bool isToday;
  final bool isSelected;
  final bool hasActivity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.calories : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${date.day}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            // Filled dot for a day with logged activity, hollow ring for
            // today/no-activity, nothing for past days with no activity —
            // matches the filled/hollow dots in the reference screenshot.
            if (hasActivity)
              _Dot(
                  filled: true,
                  color: isSelected ? Colors.white : AppColors.calories)
            else if (isToday || isSelected)
              _Dot(
                  filled: false,
                  color: isSelected ? Colors.white : AppColors.calories)
            else
              const SizedBox(height: 6, width: 6),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.filled, required this.color});

  final bool filled;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? color : Colors.transparent,
        border: filled ? null : Border.all(color: color, width: 1),
      ),
    );
  }
}
