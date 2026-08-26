import 'package:flutter/material.dart';
import 'package:habitflow/core/constants/app_topography.dart';

class StatSummaryRow extends StatelessWidget {
  const StatSummaryRow({
    super.key,
    required this.activity,
    required this.weeklyTotal,
    required this.weeklyAvgPerDay,
    required this.bestDayValue,
  });

  final String activity;
  final double weeklyTotal;
  final double weeklyAvgPerDay;
  final double bestDayValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatColumn(label: 'Total', value: _formatTotal()),
        const SizedBox(width: 28),
        _StatColumn(label: 'Daily avg', value: _formatAvg()),
        const SizedBox(width: 28),
        _StatColumn(label: 'Best day', value: _formatBest()),
      ],
    );
  }

  String _formatTotal() {
    switch (activity) {
      case 'Water':
        return '${(weeklyTotal / 1000).toStringAsFixed(1)} L';
      case 'Sleep':
        return '${weeklyTotal.toStringAsFixed(1)} h';
      case 'Workouts':
        return '${weeklyTotal.toStringAsFixed(0)}';
      case 'Steps':
      default:
        return weeklyTotal >= 1000
            ? '${(weeklyTotal / 1000).toStringAsFixed(1)}k'
            : weeklyTotal.toStringAsFixed(0);
    }
  }

  String _formatAvg() {
    switch (activity) {
      case 'Water':
        return '${(weeklyAvgPerDay / 1000).toStringAsFixed(1)} L/d';
      case 'Sleep':
        return '${weeklyAvgPerDay.toStringAsFixed(1)} h/d';
      case 'Workouts':
        return weeklyAvgPerDay.toStringAsFixed(1);
      case 'Steps':
      default:
        return weeklyAvgPerDay >= 1000
            ? '${(weeklyAvgPerDay / 1000).toStringAsFixed(1)}k'
            : weeklyAvgPerDay.toStringAsFixed(0);
    }
  }

  String _formatBest() {
    switch (activity) {
      case 'Water':
        return '${(bestDayValue / 1000).toStringAsFixed(1)} L';
      case 'Sleep':
        return '${bestDayValue.toStringAsFixed(1)} h';
      case 'Workouts':
        return bestDayValue.toStringAsFixed(0);
      case 'Steps':
      default:
        return bestDayValue >= 1000
            ? '${(bestDayValue / 1000).toStringAsFixed(1)}k'
            : bestDayValue.toStringAsFixed(0);
    }
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelSmall),
        const SizedBox(height: 2),
        Text(value, style: AppTypography.h4),
      ],
    );
  }
}
