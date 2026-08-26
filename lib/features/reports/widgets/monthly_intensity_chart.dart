import 'package:flutter/material.dart';
import 'package:habitflow/core/constants/app_topography.dart';
import 'package:habitflow/core/theme/app_theme.dart';

class MonthlyIntensityChart extends StatelessWidget {
  const MonthlyIntensityChart({
    super.key,
    required this.values,
    required this.color,
  });

  final List<double> values;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox(height: 140);

    final maxVal =
        values.reduce((a, b) => a > b ? a : b).clamp(1, double.infinity);
    var peakIndex = 0;
    for (var i = 1; i < values.length; i++) {
      if (values[i] > values[peakIndex]) peakIndex = i;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 24, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(24),
      ),
      child: SizedBox(
        height: 130,
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(values.length, (i) {
                final heightFraction = values[i] / maxVal;
                final isPeak = i == peakIndex;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1.5),
                    child: TweenAnimationBuilder<double>(
                      tween:
                          Tween(begin: 0, end: heightFraction.clamp(0.02, 1)),
                      duration: Duration(milliseconds: 500 + i * 15),
                      curve: Curves.easeOutCubic,
                      builder: (_, t, __) => Container(
                        height: 90 * t,
                        decoration: BoxDecoration(
                          color: isPeak ? color : color.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            Positioned(
              left: (peakIndex / values.length) *
                      (MediaQuery.of(context).size.width - 64) -
                  14,
              top: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  values[peakIndex].toStringAsFixed(0),
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
