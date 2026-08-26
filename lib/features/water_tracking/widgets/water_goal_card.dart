import 'package:flutter/material.dart';
import 'package:habitflow/core/constants/app_topography.dart';
import 'package:habitflow/core/theme/app_theme.dart';

/// The "Daily goal" summary card. The avg/min/max liter figures are
/// general hydration guidance, not derived from the user's own history —
/// no provider in the codebase currently supplies personalized intake
/// stats, so these stay as reference constants until one exists.
class WaterGoalCard extends StatelessWidget {
  const WaterGoalCard({super.key, required this.dailyGoalGlasses});

  final int dailyGoalGlasses;

  static const _average = '1.8';
  static const _minimum = '1.0';
  static const _maximum = '3.25';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.waterBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            bottom: -8,
            child: Icon(
              Icons.water_drop,
              size: 64,
              color: AppColors.water.withValues(alpha: 0.35),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daily goal: $dailyGoalGlasses glasses',
                style: AppTypography.h3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _StatColumn(value: '$_average l/d', label: 'AVERAGE'),
                  const SizedBox(width: 24),
                  _StatColumn(value: '$_minimum l/d', label: 'MINIMUM'),
                  const SizedBox(width: 24),
                  _StatColumn(value: '$_maximum l/d', label: 'MAXIMUM'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AppTypography.labelLarge),
        Text(label, style: AppTypography.labelSmall),
      ],
    );
  }
}
