import 'package:flutter/material.dart';

/// Last-7-days water bar chart — animated rounded gradient bars instead of
/// plain flat blue rectangles.
class WeeklyWaterChart extends StatelessWidget {
  final List<int> history;
  const WeeklyWaterChart({super.key, required this.history});

  static const _dayLabels = ['6d', '5d', '4d', '3d', '2d', '1d', 'Today'];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    const waterColor = Color(0xFF2FA8E0);
    final maxVal =
        (history.isEmpty ? 1 : history.reduce((a, b) => a > b ? a : b))
            .clamp(1, 1 << 30);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: SizedBox(
        height: 100,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(history.length, (i) {
            final v = history[i];
            final heightFraction = v / maxVal;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child:
                    Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Text(v > 0 ? '${(v / 1000).toStringAsFixed(1)}L' : '',
                      style: text.labelSmall),
                  const SizedBox(height: 4),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: heightFraction.clamp(0.03, 1)),
                    duration: Duration(milliseconds: 600 + i * 60),
                    curve: Curves.easeOutCubic,
                    builder: (_, t, __) => Container(
                      height: 56 * t,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            waterColor,
                            waterColor.withValues(alpha: 0.55)
                          ],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(_dayLabels[i], style: text.labelSmall),
                ]),
              ),
            );
          }),
        ),
      ),
    );
  }
}
