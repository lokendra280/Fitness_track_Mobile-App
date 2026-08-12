import 'package:flutter/material.dart';

/// UI-only helper models for widgets that CAN show richer detail (weight
/// history, weekly habit dots, milestones, a recent-entries feed) once a
/// provider exposes that data. None of these are on [DashboardData] today,
/// so every widget that takes one of these takes it as an optional param
/// and degrades gracefully to a simpler view when it's null/empty.

enum HabitDayStatus { completed, partial, missed, upcoming }

class HabitDay {
  final String label;
  final HabitDayStatus status;
  const HabitDay({required this.label, required this.status});
}

class WeightPoint {
  final DateTime date;
  final double weightKg;
  const WeightPoint({required this.date, required this.weightKg});
}

class MilestoneInfo {
  final String title;
  final String subtitle;
  final double current;
  final double target;
  const MilestoneInfo({
    required this.title,
    required this.subtitle,
    required this.current,
    required this.target,
  });

  double get progress => target == 0 ? 0 : (current / target).clamp(0, 1);
}

enum RecentEntryType { meal, workout, weight }

class RecentEntry {
  final RecentEntryType type;
  final String category;
  final String subtitle;
  final String trailing;
  final String time;
  const RecentEntry({
    required this.type,
    required this.category,
    required this.subtitle,
    required this.trailing,
    required this.time,
  });

  IconData get icon {
    switch (type) {
      case RecentEntryType.meal:
        return Icons.restaurant;
      case RecentEntryType.workout:
        return Icons.directions_walk;
      case RecentEntryType.weight:
        return Icons.monitor_weight_outlined;
    }
  }

  String get typeLabel {
    switch (type) {
      case RecentEntryType.meal:
        return 'Meal';
      case RecentEntryType.workout:
        return 'Workout';
      case RecentEntryType.weight:
        return 'Weight';
    }
  }
}

/// A single ring/bar metric row, built from whatever fields DashboardData
/// does have (see `_buildMetrics` in the dashboard screens).
class ProgressMetric {
  final String label;
  final String valueLabel;
  final double progress; // 0..1
  final IconData icon;
  final Color color;
  final Color background;
  const ProgressMetric({
    required this.label,
    required this.valueLabel,
    required this.progress,
    required this.icon,
    required this.color,
    required this.background,
  });
}
