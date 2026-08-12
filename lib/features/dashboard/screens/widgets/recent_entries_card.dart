import 'package:flutter/material.dart';
import 'package:habitflow/core/widgets/section_header.dart';
import 'package:habitflow/data/models/dashboard_ui_models.dart';

/// "Recent entries" card: a simple list of meals/workouts/weight logs.
class RecentEntriesCard extends StatelessWidget {
  final List<RecentEntry> entries;
  final VoidCallback? onViewAll;

  const RecentEntriesCard({super.key, required this.entries, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
                title: 'Recent entries',
                actionLabel: 'View all',
                onActionTap: onViewAll),
            const SizedBox(height: 8),
            AnimatedList_(entries: entries),
          ],
        ),
      ),
    );
  }
}

/// Small helper that animates newly-inserted rows sliding in from the top
/// (used when a fresh weight log is added).
class AnimatedList_ extends StatelessWidget {
  final List<RecentEntry> entries;
  const AnimatedList_({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: entries
          .map((e) => TweenAnimationBuilder<double>(
                key: ValueKey('${e.category}-${e.time}-${e.trailing}'),
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOut,
                builder: (context, v, child) => Opacity(
                  opacity: v,
                  child: Transform.translate(
                    offset: Offset(0, (1 - v) * -8),
                    child: child,
                  ),
                ),
                child: _EntryRow(entry: e),
              ))
          .toList(),
    );
  }
}

class _EntryRow extends StatelessWidget {
  final RecentEntry entry;
  const _EntryRow({required this.entry});

  Color get _bg {
    switch (entry.type) {
      case RecentEntryType.meal:
        return const Color(0xFFFDEEDA);
      case RecentEntryType.workout:
        return const Color(0xFFDCF3E4);
      case RecentEntryType.weight:
        return const Color(0xFFDCEEFA);
    }
  }

  Color get _fg {
    switch (entry.type) {
      case RecentEntryType.meal:
        return const Color(0xFFF6A23A);
      case RecentEntryType.workout:
        return const Color(0xFF3FAE6A);
      case RecentEntryType.weight:
        return const Color(0xFF3B9EDB);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: _bg, shape: BoxShape.circle),
            child: Icon(entry.icon, color: _fg, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    style: textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                    children: [
                      TextSpan(text: entry.typeLabel),
                      if (entry.category.isNotEmpty &&
                          entry.category != entry.typeLabel)
                        TextSpan(
                          text: ' • ${entry.category}',
                          style: const TextStyle(fontWeight: FontWeight.w400),
                        ),
                    ],
                  ),
                ),
                if (entry.subtitle.isNotEmpty)
                  Text(entry.subtitle, style: textTheme.bodyMedium),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(entry.trailing,
                  style: textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(entry.time,
                  style: textTheme.bodyMedium?.copyWith(fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
