import 'package:flutter/material.dart';
import 'package:habitflow/core/widgets/animated_common.dart';

class DayItem {
  final String weekday; // Mon, Tue...
  final int dayNumber; // 12, 13...
  const DayItem({required this.weekday, required this.dayNumber});
}

/// Horizontal week strip ("Mon 12" ... "Sun 18") with an animated
/// selection pill that slides between days.
class DaySelector extends StatelessWidget {
  final List<DayItem> days;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const DaySelector({
    super.key,
    required this.days,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return SizedBox(
      height: 74,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final day = days[i];
          final selected = i == selectedIndex;
          return TapScale(
            onTap: () => onSelected(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              width: 56,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: selected ? primary : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: selected ? primary : Colors.grey.shade300),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(day.weekday,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? Colors.white70
                              : Colors.grey.shade600)),
                  const SizedBox(height: 4),
                  Text('${day.dayNumber}',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: selected ? Colors.white : Colors.black87)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
