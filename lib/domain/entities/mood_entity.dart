// mood_entity.dart — Phase 2 Mood Tracking domain entity

import 'package:flutter/material.dart';

// ── Mood levels (5-point scale like Duolingo streaks) ─────────────────────────

enum MoodLevel {
  awful, // 1 — 😞
  bad, // 2 — 😕
  okay, // 3 — 😐
  good, // 4 — 🙂
  amazing, // 5 — 🤩
}

extension MoodLevelX on MoodLevel {
  String get emoji {
    const e = ['😞', '😕', '😐', '🙂', '🤩'];
    return e[index];
  }

  String get label {
    const l = ['Awful', 'Bad', 'Okay', 'Good', 'Amazing'];
    return l[index];
  }

  Color get color {
    const c = [
      Color(0xFFEF5350), // red
      Color(0xFFFF7043), // orange
      Color(0xFFFFCA28), // amber
      Color(0xFF66BB6A), // green
      Color(0xFF42A5F5), // blue
    ];
    return c[index];
  }

  Color get surface {
    const c = [
      Color(0xFFFFEBEE),
      Color(0xFFFBE9E7),
      Color(0xFFFFF8E1),
      Color(0xFFE8F5E9),
      Color(0xFFE3F2FD),
    ];
    return c[index];
  }

  int get score => index + 1; // 1–5
}

// ── Mood tags ─────────────────────────────────────────────────────────────────

enum MoodTag {
  productive,
  tired,
  stressed,
  happy,
  anxious,
  focused,
  motivated,
  calm,
  sad,
  energetic,
}

extension MoodTagX on MoodTag {
  String get label {
    const l = [
      'Productive',
      'Tired',
      'Stressed',
      'Happy',
      'Anxious',
      'Focused',
      'Motivated',
      'Calm',
      'Sad',
      'Energetic',
    ];
    return l[index];
  }

  String get emoji {
    const e = ['💼', '😴', '😰', '😄', '😟', '🎯', '🚀', '😌', '😢', '⚡'];
    return e[index];
  }
}

// ── MoodEntry ─────────────────────────────────────────────────────────────────

class MoodEntry {
  final String id;
  final MoodLevel level;
  final List<MoodTag> tags;
  final String note;
  final DateTime timestamp;
  final bool isSynced;
  final DateTime? updatedAt;

  const MoodEntry({
    required this.id,
    required this.level,
    required this.tags,
    required this.note,
    required this.timestamp,
    this.isSynced = false,
    this.updatedAt,
  });

  String get dateKey => '${timestamp.year}-'
      '${timestamp.month.toString().padLeft(2, '0')}-'
      '${timestamp.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toSupabase(String userId) => {
        'id': id,
        'user_id': userId,
        'level': level.index,
        'tags': tags.map((t) => t.index).toList(),
        'note': note,
        'timestamp': timestamp.toIso8601String(),
        'updated_at': (updatedAt ?? DateTime.now()).toIso8601String(),
      };

  factory MoodEntry.fromSupabase(Map<String, dynamic> j) => MoodEntry(
        id: j['id'] as String,
        level: MoodLevel.values[(j['level'] as num).toInt()],
        tags: ((j['tags'] as List?) ?? [])
            .map((t) => MoodTag.values[(t as num).toInt()])
            .toList(),
        note: j['note'] as String? ?? '',
        timestamp: DateTime.parse(j['timestamp'] as String),
        isSynced: true,
        updatedAt: j['updated_at'] != null
            ? DateTime.parse(j['updated_at'] as String)
            : null,
      );
}

// ── MoodCorrelation — derived, never stored ───────────────────────────────────

class MoodCorrelation {
  final String habitId;
  final String habitName;
  final String habitIcon;

  /// Average mood score (1–5) on days when this habit was completed.
  final double avgMoodWithHabit;

  /// Average mood score on days when this habit was NOT completed.
  final double avgMoodWithout;

  const MoodCorrelation({
    required this.habitId,
    required this.habitName,
    required this.habitIcon,
    required this.avgMoodWithHabit,
    required this.avgMoodWithout,
  });

  double get uplift => avgMoodWithHabit - avgMoodWithout;
  bool get positive => uplift > 0;
}

// ── Weekly mood summary ───────────────────────────────────────────────────────

class WeekMoodSummary {
  final double average; // 1–5
  final MoodLevel? dominantMood;
  final int entriesCount;
  final List<MoodEntry?> days; // 7 entries, null if no log that day

  const WeekMoodSummary({
    required this.average,
    required this.dominantMood,
    required this.entriesCount,
    required this.days,
  });
}
