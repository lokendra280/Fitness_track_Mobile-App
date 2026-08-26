import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/habit_daily_log_provider.dart';
import '../providers/habit_proof_provider.dart';

/// A GitHub-contributions-style horizontal strip showing completion
/// across the whole journey (default 80 days, see
/// journeyLengthDaysProvider), for a single habit. Day 1 is the
/// journey start; today is highlighted with a ring.
class HabitJourneyGrid extends ConsumerWidget {
  final String habitName;
  final DateTime journeyStart;

  const HabitJourneyGrid({
    super.key,
    required this.habitName,
    required this.journeyStart,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalDays = ref.watch(journeyLengthDaysProvider);
    final log = ref.watch(habitDailyLogProvider);
    final proofType = inferProofType(habitName);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final start =
        DateTime(journeyStart.year, journeyStart.month, journeyStart.day);
    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);

    final doneCount = List.generate(totalDays, (i) {
      final day = start.add(Duration(days: i));
      return log[DailyLogKey(habitName, day)] == true;
    }).where((d) => d).length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (proofType != HabitProofType.none)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(
                    proofType == HabitProofType.photo
                        ? Icons.camera_alt_rounded
                        : Icons.local_drink_rounded,
                    size: 16,
                    color: scheme.primary,
                  ),
                ),
              Expanded(
                child: Text(habitName, style: text.titleSmall),
              ),
              Text(
                '$doneCount / $totalDays days',
                style:
                    text.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 28,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: totalDays,
              separatorBuilder: (_, __) => const SizedBox(width: 4),
              itemBuilder: (_, i) {
                final day = start.add(Duration(days: i));
                final done = log[DailyLogKey(habitName, day)] == true;
                final isToday = day.year == todayNorm.year &&
                    day.month == todayNorm.month &&
                    day.day == todayNorm.day;
                final isFuture = day.isAfter(todayNorm);

                return Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: done
                        ? scheme.primary
                        : isFuture
                            ? scheme.surfaceContainerHighest
                            : scheme.errorContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(6),
                    border: isToday
                        ? Border.all(color: scheme.primary, width: 1.5)
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
