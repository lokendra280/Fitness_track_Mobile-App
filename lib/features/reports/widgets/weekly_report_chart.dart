import 'package:flutter/material.dart';

class WeeklyReportChart extends StatefulWidget {
  const WeeklyReportChart({
    super.key,
    required this.waterHistory,
    required this.stepsHistory,
  });

  /// Both lists must have exactly 7 entries, oldest first, today last.
  final List<int> waterHistory;
  final List<int> stepsHistory;

  @override
  State<WeeklyReportChart> createState() => _WeeklyReportChartState();
}

class _WeeklyReportChartState extends State<WeeklyReportChart> {
  int _metricIndex = 0; // 0 = water, 1 = steps

  static const _dayLabels = ['6d', '5d', '4d', '3d', '2d', '1d', 'Today'];

  @override
  Widget build(BuildContext context) {
    final history =
        _metricIndex == 0 ? widget.waterHistory : widget.stepsHistory;
    final color =
        _metricIndex == 0 ? const Color(0xFF2FA8E0) : const Color(0xFFE0A72F);
    final maxVal =
        (history.isEmpty ? 1 : history.reduce((a, b) => a > b ? a : b))
            .clamp(1, 1 << 30);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 0, label: Text('Water')),
            ButtonSegment(value: 1, label: Text('Steps')),
          ],
          selected: {_metricIndex},
          onSelectionChanged: (s) => setState(() => _metricIndex = s.first),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(history.length, (i) {
              final v = history[i];
              final heightFraction = v / maxVal;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        v > 0
                            ? (_metricIndex == 0
                                ? '${(v / 1000).toStringAsFixed(1)}L'
                                : '$v')
                            : '',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(height: 4),
                      TweenAnimationBuilder<double>(
                        key: ValueKey('$_metricIndex-$i'),
                        tween:
                            Tween(begin: 0, end: heightFraction.clamp(0.03, 1)),
                        duration: Duration(milliseconds: 600 + i * 60),
                        curve: Curves.easeOutCubic,
                        builder: (_, t, __) => Container(
                          height: 70 * t,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [color, color.withValues(alpha: 0.55)],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(_dayLabels[i],
                          style: Theme.of(context).textTheme.labelSmall),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
