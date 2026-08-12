import 'package:flutter/material.dart';
import 'package:habitflow/core/widgets/animated_common.dart';
import 'package:habitflow/core/widgets/section_header.dart';
import 'package:habitflow/data/models/dashboard_ui_models.dart';

/// "Habits" card: ring showing weekly consistency + a strip of 7 day dots.
class HabitsSummaryCard extends StatelessWidget {
  final double consistency;
  final int completed;
  final int total;
  final List<HabitDay> week;
  final VoidCallback? onViewAll;

  const HabitsSummaryCard({
    super.key,
    required this.consistency,
    required this.completed,
    required this.total,
    required this.week,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primary = Theme.of(context).colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
                title: 'Habits',
                actionLabel: 'View all',
                onActionTap: onViewAll),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedRingProgress(
                  value: consistency,
                  size: 76,
                  strokeWidth: 7,
                  color: primary,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: consistency.clamp(0, 1)),
                        duration: const Duration(milliseconds: 1100),
                        curve: Curves.easeOutCubic,
                        builder: (context, v, _) => Text(
                          '${(v * 100).round()}%',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
                      Text('This week',
                          style: textTheme.bodyMedium?.copyWith(fontSize: 10)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Great job! You completed $completed of $total habits '
                        'this week.',
                        style: textTheme.bodyMedium
                            ?.copyWith(color: Colors.black87),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: week
                            .asMap()
                            .entries
                            .map((e) => Padding(
                                  padding: EdgeInsets.only(
                                      right: e.key == week.length - 1 ? 0 : 8),
                                  child: _HabitDot(day: e.value),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitDot extends StatelessWidget {
  final HabitDay day;
  const _HabitDot({required this.day});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Widget icon;
    switch (day.status) {
      case HabitDayStatus.completed:
        bg = Colors.green.shade100;
        icon = Icon(Icons.check, size: 14, color: Colors.green.shade700);
        break;
      case HabitDayStatus.partial:
        bg = Colors.green.shade100;
        icon = Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.check, size: 14, color: Colors.green.shade700),
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                    color: Colors.orange, shape: BoxShape.circle),
              ),
            ),
          ],
        );
        break;
      case HabitDayStatus.missed:
        bg = Colors.grey.shade200;
        icon = Icon(Icons.close, size: 14, color: Colors.grey.shade500);
        break;
      case HabitDayStatus.upcoming:
        bg = Colors.grey.shade200;
        icon = const SizedBox.shrink();
        break;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      builder: (context, v, child) => Transform.scale(scale: v, child: child),
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: icon,
      ),
    );
  }
}
