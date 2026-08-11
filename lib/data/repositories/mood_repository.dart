// // mood_repository.dart — Hive-backed mood storage + Supabase sync

// import 'package:habitflow/domain/entities/entities.dart';
// import 'package:habitflow/domain/entities/mood_entity.dart';
// import 'package:habitflow/presentation/screens/mode_tracking/models/mood_model.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:uuid/uuid.dart';

// const _uuid = Uuid();

// class MoodRepository {
//   static const _kBox = 'moods_v1';

//   Box<MoodModel> get _box => Hive.box<MoodModel>(_kBox);
//   final _client = Supabase.instance.client;

//   // ── Init ──────────────────────────────────────────────────────────────────
//   static Future<void> init() async {
//     if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(MoodModelAdapter());
//     await Hive.openBox<MoodModel>(_kBox);
//   }

//   // ── CRUD ──────────────────────────────────────────────────────────────────

//   List<MoodEntry> getAll() => _box.values.map(_map).toList()
//     ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

//   /// Today's entry (null if not logged yet).
//   MoodEntry? getToday() {
//     final key = _dk(DateTime.now());
//     try {
//       return _box.values.map(_map).firstWhere((e) => e.dateKey == key);
//     } catch (_) {
//       return null;
//     }
//   }

//   /// All entries in a date range (inclusive).
//   List<MoodEntry> getRange(DateTime from, DateTime to) {
//     return _box.values
//         .map(_map)
//         .where((e) => !e.timestamp.isBefore(from) && !e.timestamp.isAfter(to))
//         .toList()
//       ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
//   }

//   /// Last 7 days aligned to Mon–Sun of the current week.
//   WeekMoodSummary getWeekSummary() {
//     final now = DateTime.now();
//     final mon = now.subtract(Duration(days: now.weekday - 1));
//     final days = List.generate(7, (i) {
//       final date = DateTime(mon.year, mon.month, mon.day + i);
//       final key = _dk(date);
//       try {
//         return _box.values.map(_map).firstWhere((e) => e.dateKey == key);
//       } catch (_) {
//         return null;
//       }
//     });

//     final filled = days.whereType<MoodEntry>().toList();
//     final avg = filled.isEmpty
//         ? 0.0
//         : filled.map((e) => e.level.score).reduce((a, b) => a + b) /
//             filled.length;

//     final dominant = filled.isEmpty
//         ? null
//         : (filled..sort((a, b) => b.level.score.compareTo(a.level.score)))
//             .first
//             .level;

//     return WeekMoodSummary(
//       average: avg,
//       dominantMood: dominant,
//       entriesCount: filled.length,
//       days: days,
//     );
//   }

//   Future<MoodEntry> logMood({
//     required MoodLevel level,
//     required List<MoodTag> tags,
//     required String note,
//   }) async {
//     // Replace today's entry if it exists
//     final existing = getToday();
//     if (existing != null) await _box.delete(existing.id);

//     final m = MoodModel(
//       id: _uuid.v4(),
//       levelIndex: level.index,
//       tagIndexes: tags.map((t) => t.index).toList(),
//       note: note,
//       timestamp: DateTime.now(),
//       isSynced: false,
//     );
//     await _box.put(m.id, m);
//     return _map(m);
//   }

//   Future<void> delete(String id) async {
//     await _box.delete(id);
//     try {
//       await _client.from('moods').delete().eq('id', id);
//     } catch (_) {}
//   }

//   // ── Correlation ───────────────────────────────────────────────────────────

//   /// For each habit, compute average mood on days it was completed vs not.
//   List<MoodCorrelation> correlate({
//     required List<Habit> habits,
//     required List<Checkin> checkins,
//   }) {
//     final entries = getAll();
//     if (entries.isEmpty || habits.isEmpty) return [];

//     return habits
//         .map((h) {
//           final completedDays = checkins
//               .where((c) => c.habitId == h.id)
//               .map((c) => _dk(c.timestamp))
//               .toSet();

//           final withHabit =
//               entries.where((e) => completedDays.contains(e.dateKey));
//           final withoutHabit =
//               entries.where((e) => !completedDays.contains(e.dateKey));

//           final avgWith = withHabit.isEmpty
//               ? 0.0
//               : withHabit.map((e) => e.level.score).reduce((a, b) => a + b) /
//                   withHabit.length;
//           final avgWithout = withoutHabit.isEmpty
//               ? 0.0
//               : withoutHabit.map((e) => e.level.score).reduce((a, b) => a + b) /
//                   withoutHabit.length;

//           return MoodCorrelation(
//             habitId: h.id,
//             habitName: h.name,
//             habitIcon: h.icon,
//             avgMoodWithHabit: avgWith,
//             avgMoodWithout: avgWithout,
//           );
//         })
//         .where((c) => c.avgMoodWithHabit > 0)
//         .toList()
//       ..sort((a, b) => b.uplift.abs().compareTo(a.uplift.abs()));
//   }

//   // ── Cloud sync ────────────────────────────────────────────────────────────

//   Future<void> pushPending(String userId) async {
//     final pending = _box.values.where((m) => !m.isSynced).toList();
//     if (pending.isEmpty) return;
//     final rows = pending.map((m) => _map(m).toSupabase(userId)).toList();
//     await _client.from('moods').upsert(rows, onConflict: 'id');
//     for (final m in pending) {
//       m.isSynced = true;
//       await m.save();
//     }
//   }

//   Future<void> pullFromCloud(String userId) async {
//     final res = await _client
//         .from('moods')
//         .select()
//         .eq('user_id', userId)
//         .order('timestamp', ascending: false);

//     for (final j in res as List) {
//       final r = MoodEntry.fromSupabase(j as Map<String, dynamic>);
//       if (!_box.containsKey(r.id)) {
//         await _box.put(
//             r.id,
//             MoodModel(
//               id: r.id,
//               levelIndex: r.level.index,
//               tagIndexes: r.tags.map((t) => t.index).toList(),
//               note: r.note,
//               timestamp: r.timestamp,
//               isSynced: true,
//               updatedAt: r.updatedAt,
//             ));
//       } else {
//         final local = _box.get(r.id)!;
//         final serverTs = r.updatedAt ?? r.timestamp;
//         final localTs = local.updatedAt ?? local.timestamp;
//         if (serverTs.isAfter(localTs)) {
//           local
//             ..levelIndex = r.level.index
//             ..tagIndexes = r.tags.map((t) => t.index).toList()
//             ..note = r.note
//             ..isSynced = true
//             ..updatedAt = r.updatedAt;
//           await local.save();
//         }
//       }
//     }
//   }

//   Future<void> fullSync(String userId) async {
//     await pushPending(userId);
//     await pullFromCloud(userId);
//   }

//   // ── Helpers ───────────────────────────────────────────────────────────────

//   MoodEntry _map(MoodModel m) => MoodEntry(
//         id: m.id,
//         level: MoodLevel.values[m.levelIndex],
//         tags: m.tagIndexes.map((i) => MoodTag.values[i]).toList(),
//         note: m.note,
//         timestamp: m.timestamp,
//         isSynced: m.isSynced,
//         updatedAt: m.updatedAt,
//       );

//   String _dk(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-'
//       '${d.day.toString().padLeft(2, '0')}';
// }
