// ─────────────────────────────────────────────────────────────────────────────
//  goal_model.dart
//  Hive model for Goal entity. TypeId = 4 (next after reminders=2, challenges=3).
//  Run: flutter pub run build_runner build --delete-conflicting-outputs
// ─────────────────────────────────────────────────────────────────────────────

import 'package:hive/hive.dart';

part 'goal_model.g.dart';

@HiveType(typeId: 4)
class GoalModel extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  String description;
  @HiveField(3)
  String icon;
  @HiveField(4)
  int colorIndex;
  @HiveField(5)
  List<String> linkedHabitIds;
  @HiveField(6)
  int targetDays;
  @HiveField(7)
  int periodIndex; // GoalPeriod.index
  @HiveField(8)
  int statusIndex; // GoalStatus.index
  @HiveField(9)
  DateTime startDate;
  @HiveField(10)
  DateTime? completedDate;
  @HiveField(11)
  bool isSynced;
  @HiveField(12)
  DateTime? updatedAt;

  GoalModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.colorIndex,
    required this.linkedHabitIds,
    required this.targetDays,
    required this.periodIndex,
    required this.statusIndex,
    required this.startDate,
    this.completedDate,
    this.isSynced = false,
    this.updatedAt,
  });
}
