import 'package:flutter/material.dart';
import 'package:habitflow/data/models/tracking_models.dart';

class MealRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<FoodEntry> entries;
  final VoidCallback onLog;

  const MealRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.entries,
    required this.onLog,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final hasEntries = entries.isNotEmpty;

    final totalCal = entries.fold<double>(0, (s, e) => s + e.calories);
    final totalCarbs = entries.fold<double>(0, (s, e) => s + (e.carbs ?? 0));
    final totalFat = entries.fold<double>(0, (s, e) => s + (e.fat ?? 0));
    final totalProtein =
        entries.fold<double>(0, (s, e) => s + (e.protein ?? 0));
    final totalMacroCal =
        (totalCarbs * 4) + (totalFat * 9) + (totalProtein * 4);

    int pct(double macroCal) =>
        totalMacroCal == 0 ? 0 : ((macroCal / totalMacroCal) * 100).round();

    final subtitle = hasEntries
        ? entries.length == 1
            ? entries.first.name
            : '${entries.first.name} and ${entries.length - 1} more'
        : 'Nothing logged yet';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: text.titleMedium),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_horiz_rounded, size: 18),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      splashRadius: 16,
                    ),
                    const SizedBox(width: 8),
                    _LogChip(onTap: onLog, enabled: !hasEntries),
                  ],
                ),
                const SizedBox(height: 2),
                Text(subtitle,
                    style:
                        text.bodyMedium?.copyWith(color: Colors.grey.shade600)),
                if (hasEntries) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${totalCal.round()} cal · C ${pct(totalCarbs * 4)}% · '
                    'F ${pct(totalFat * 9)}% · P ${pct(totalProtein * 4)}%',
                    style:
                        text.bodySmall?.copyWith(color: Colors.grey.shade500),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LogChip extends StatelessWidget {
  final VoidCallback onTap;
  final bool enabled;
  const _LogChip({required this.onTap, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: enabled
              ? Colors.blue.withValues(alpha: 0.12)
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'Log',
          style: TextStyle(
            color: enabled ? Colors.blue : Colors.grey.shade400,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
