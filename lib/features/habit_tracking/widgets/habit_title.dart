import 'package:flutter/material.dart';
import '../../../data/models/tracking_models.dart';

class HabitTile extends StatelessWidget {
  final Habit habit;
  final VoidCallback onToggle;
  const HabitTile({super.key, required this.habit, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final done = habit.completedToday;

    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: done
              ? scheme.primaryContainer.withValues(alpha: 0.5)
              : scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: done
                  ? scheme.primary.withValues(alpha: 0.4)
                  : scheme.outlineVariant.withValues(alpha: 0.4)),
        ),
        child: Row(children: [
          _CheckCircle(done: done),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.name,
                  style: text.titleSmall?.copyWith(
                    decoration: done ? TextDecoration.lineThrough : null,
                    color: done ? scheme.onSurfaceVariant : scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(habit.frequency, style: text.bodySmall),
              ],
            ),
          ),
          _StreakBadge(streak: habit.streak),
        ]),
      ),
    );
  }
}

class _CheckCircle extends StatelessWidget {
  final bool done;
  const _CheckCircle({required this.done});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? scheme.primary : Colors.transparent,
        border:
            Border.all(color: done ? scheme.primary : scheme.outline, width: 2),
      ),
      child: AnimatedScale(
        scale: done ? 1 : 0,
        duration: const Duration(milliseconds: 150),
        child: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  final int streak;
  const _StreakBadge({required this.streak});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    if (streak <= 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFF8A3D).withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Text('🔥', style: TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        Text('$streak',
            style: text.labelMedium?.copyWith(
                color: const Color(0xFFFF8A3D), fontWeight: FontWeight.w700)),
      ]),
    );
  }
}
