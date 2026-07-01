// ─────────────────────────────────────────────────────────────────────────────
//  phase1_entities.dart
//  Domain entities for Phase 1: Habit Templates, Goals, Calendar Heatmap data.
//  ChallengeStatus already lives in entities.dart — imported from there.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:habitflow/core/constants/constant_assets.dart';

class HabitTemplate {
  final String id;
  final String name;
  final String icon;
  final String category;
  final int targetPerDay;
  final int colorIndex;
  final String description;
  final List<String> habitNames;
  final List<String> habitIcons;
  final List<int> habitTargets;

  const HabitTemplate({
    required this.id,
    required this.name,
    required this.icon,
    required this.category,
    required this.targetPerDay,
    required this.colorIndex,
    required this.description,
    required this.habitNames,
    required this.habitIcons,
    required this.habitTargets,
  });

  /// Built-in seed templates — no remote or Hive needed.
  static const List<HabitTemplate> seeds = [
    HabitTemplate(
      id: 'tmpl_morning',
      name: 'Morning Routine',
      icon: Assets.morning,
      category: 'Wellness',
      targetPerDay: 1,
      colorIndex: 0,
      description: 'Start every day with intention and energy.',
      habitNames: ['Drink water', 'Meditate', 'Journal', 'Stretch'],
      habitIcons: [Assets.water, Assets.yoga, Assets.journal, Assets.stretch],
      habitTargets: [1, 1, 1, 1],
    ),
    HabitTemplate(
      id: 'tmpl_fitness',
      name: 'Fitness Plan',
      icon: Assets.gym,
      category: 'Health',
      targetPerDay: 1,
      colorIndex: 1,
      description: 'Build strength and endurance step by step.',
      habitNames: ['Morning run', 'Push-ups', 'Protein shake', 'Sleep 8h'],
      habitIcons: [
        Assets.running,
        Assets.pushups,
        Assets.protein_shake,
        Assets.sleep
      ],
      habitTargets: [1, 3, 1, 1],
    ),
    HabitTemplate(
      id: 'tmpl_sleep',
      name: 'Better Sleep',
      icon: Assets.sleep,
      category: 'Recovery',
      targetPerDay: 1,
      colorIndex: 2,
      description: 'Wind down properly for deep, restorative sleep.',
      habitNames: [
        'No screens 9pm',
        'Read 20 pages',
        'Magnesium',
        'Bed by 10pm'
      ],
      habitIcons: [Assets.noPhone, Assets.book, Assets.yetCal, Assets.bed],
      habitTargets: [1, 1, 1, 1],
    ),
    HabitTemplate(
      id: 'tmpl_focus',
      name: 'Deep Work',
      icon: Assets.focus,
      category: 'Productivity',
      targetPerDay: 1,
      colorIndex: 3,
      description: 'Eliminate distractions and do your best work.',
      habitNames: ['Plan day', 'Focus block', 'Review tasks', 'Inbox zero'],
      habitIcons: [Assets.book, Assets.timer, Assets.correct, Assets.inbox],
      habitTargets: [1, 2, 1, 1],
    ),
    HabitTemplate(
      id: 'tmpl_hydration',
      name: 'Hydration',
      icon: Assets.water,
      category: 'Wellness',
      targetPerDay: 8,
      colorIndex: 4,
      description: 'Stay hydrated throughout the entire day.',
      habitNames: ['Drink water', 'Herbal tea', 'Avoid soda'],
      habitIcons: [Assets.water, Assets.yoga, Assets.protein_shake],
      habitTargets: [8, 2, 1],
    ),
    HabitTemplate(
      id: 'tmpl_mindfulness',
      name: 'Mindfulness',
      icon: Assets.yoga,
      category: 'Mental',
      targetPerDay: 1,
      colorIndex: 5,
      description: 'Cultivate calm and presence every day.',
      habitNames: ['Meditate', 'Gratitude log', 'Nature walk', 'Digital detox'],
      habitIcons: [Assets.yoga, Assets.journal, Assets.stretch, Assets.noPhone],
      habitTargets: [1, 1, 1, 1],
    ),
  ];

  static const List<String> categories = [
    'All',
    'Wellness',
    'Health',
    'Recovery',
    'Productivity',
    'Mental',
  ];
}

// ══════════════════════════════════════════════════════════════════════════════
//  GOAL
// ══════════════════════════════════════════════════════════════════════════════

enum GoalStatus { active, completed, paused }

enum GoalPeriod { weekly, monthly, yearly }

class Goal {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int colorIndex;
  final List<String> linkedHabitIds;
  final int targetDays; // e.g. 30 days of consistency
  final GoalPeriod period;
  final GoalStatus status;
  final DateTime startDate;
  final DateTime? completedDate;
  final bool isSynced;
  final DateTime? updatedAt;

  const Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.colorIndex,
    required this.linkedHabitIds,
    required this.targetDays,
    required this.period,
    required this.status,
    required this.startDate,
    this.completedDate,
    this.isSynced = false,
    this.updatedAt,
  });

  int get daysElapsed =>
      DateTime.now().difference(startDate).inDays.clamp(0, targetDays);

  double get progressFraction =>
      targetDays == 0 ? 0 : (daysElapsed / targetDays).clamp(0.0, 1.0);

  int get daysRemaining => (targetDays - daysElapsed).clamp(0, targetDays);

  Goal copyWith({
    String? title,
    String? description,
    String? icon,
    int? colorIndex,
    List<String>? linkedHabitIds,
    int? targetDays,
    GoalPeriod? period,
    GoalStatus? status,
    DateTime? completedDate,
    bool? isSynced,
    DateTime? updatedAt,
  }) =>
      Goal(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        icon: icon ?? this.icon,
        colorIndex: colorIndex ?? this.colorIndex,
        linkedHabitIds: linkedHabitIds ?? this.linkedHabitIds,
        targetDays: targetDays ?? this.targetDays,
        period: period ?? this.period,
        status: status ?? this.status,
        startDate: startDate,
        completedDate: completedDate ?? this.completedDate,
        isSynced: isSynced ?? this.isSynced,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toSupabase(String userId) => {
        'id': id,
        'user_id': userId,
        'title': title,
        'description': description,
        'icon': icon,
        'color_index': colorIndex,
        'linked_habit_ids': linkedHabitIds,
        'target_days': targetDays,
        'period': period.name,
        'status': status.name,
        'start_date': startDate.toIso8601String(),
        'completed_date': completedDate?.toIso8601String(),
        'updated_at': (updatedAt ?? DateTime.now()).toIso8601String(),
      };

  factory Goal.fromSupabase(Map<String, dynamic> j) => Goal(
        id: j['id'] as String,
        title: j['title'] as String,
        description: j['description'] as String? ?? '',
        icon: j['icon'] as String? ?? '🎯',
        colorIndex: (j['color_index'] as num?)?.toInt() ?? 0,
        linkedHabitIds: (j['linked_habit_ids'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        targetDays: (j['target_days'] as num?)?.toInt() ?? 30,
        period: GoalPeriod.values.firstWhere(
          (e) => e.name == j['period'],
          orElse: () => GoalPeriod.monthly,
        ),
        status: GoalStatus.values.firstWhere(
          (e) => e.name == j['status'],
          orElse: () => GoalStatus.active,
        ),
        startDate: DateTime.parse(j['start_date'] as String),
        completedDate: j['completed_date'] != null
            ? DateTime.parse(j['completed_date'] as String)
            : null,
        isSynced: true,
        updatedAt: j['updated_at'] != null
            ? DateTime.parse(j['updated_at'] as String)
            : null,
      );
}

// ══════════════════════════════════════════════════════════════════════════════
//  HEATMAP DATA
// ══════════════════════════════════════════════════════════════════════════════

/// One cell in the calendar heatmap — pure derivation, never stored.
class HeatmapCell {
  final DateTime date;
  final int completedHabits;
  final int totalHabits;

  const HeatmapCell({
    required this.date,
    required this.completedHabits,
    required this.totalHabits,
  });

  double get intensity =>
      totalHabits == 0 ? 0 : (completedHabits / totalHabits).clamp(0.0, 1.0);

  bool get isEmpty => completedHabits == 0;
  bool get isFull => completedHabits >= totalHabits && totalHabits > 0;
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
