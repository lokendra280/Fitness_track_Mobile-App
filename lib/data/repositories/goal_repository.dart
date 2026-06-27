import 'package:habitflow/data/models/goal_model.dart';
import 'package:habitflow/data/models/habit_templated.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class GoalRepository {
  static const _kBox = 'goals_v1';

  Box<GoalModel> get _box => Hive.box<GoalModel>(_kBox);
  final _client = Supabase.instance.client;

  // ── Init ──────────────────────────────────────────────────────────────────
  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(GoalModelAdapter());
    }
    await Hive.openBox<GoalModel>(_kBox);
  }

  // ── Local reads ───────────────────────────────────────────────────────────
  List<Goal> getAll() => _box.values.map(_map).toList()
    ..sort((a, b) => b.startDate.compareTo(a.startDate));

  List<Goal> getActive() =>
      getAll().where((g) => g.status == GoalStatus.active).toList();

  List<Goal> getCompleted() =>
      getAll().where((g) => g.status == GoalStatus.completed).toList();

  Goal? getById(String id) {
    final m = _box.get(id);
    return m != null ? _map(m) : null;
  }

  // ── Create ────────────────────────────────────────────────────────────────
  Future<Goal> create({
    required String title,
    required String description,
    required String icon,
    required int colorIndex,
    required List<String> linkedHabitIds,
    required int targetDays,
    required GoalPeriod period,
  }) async {
    final m = GoalModel(
      id: _uuid.v4(),
      title: title,
      description: description,
      icon: icon,
      colorIndex: colorIndex,
      linkedHabitIds: linkedHabitIds,
      targetDays: targetDays,
      periodIndex: period.index,
      statusIndex: GoalStatus.active.index,
      startDate: DateTime.now(),
      isSynced: false,
    );
    await _box.put(m.id, m);
    return _map(m);
  }

  // ── Update ────────────────────────────────────────────────────────────────
  Future<Goal> updateStatus(String id, GoalStatus status) async {
    final m = _box.get(id);
    if (m == null) throw StateError('Goal not found: $id');
    m.statusIndex = status.index;
    m.completedDate = status == GoalStatus.completed ? DateTime.now() : null;
    m.isSynced = false;
    m.updatedAt = DateTime.now();
    await m.save();
    return _map(m);
  }

  Future<Goal> update(Goal g) async {
    final m = _box.get(g.id);
    if (m == null) throw StateError('Goal not found: ${g.id}');
    m.title = g.title;
    m.description = g.description;
    m.icon = g.icon;
    m.colorIndex = g.colorIndex;
    m.linkedHabitIds = g.linkedHabitIds;
    m.targetDays = g.targetDays;
    m.periodIndex = g.period.index;
    m.isSynced = false;
    m.updatedAt = DateTime.now();
    await m.save();
    return _map(m);
  }

  // ── Delete ────────────────────────────────────────────────────────────────
  Future<void> delete(String id) async {
    await _box.delete(id);
    try {
      await _client.from('goals').delete().eq('id', id);
    } catch (_) {}
  }

  // ── Evaluate: mark complete when all linked habits hit target days ─────────
  Future<List<Goal>> evaluate(Map<String, int> streaksByHabit) async {
    final changed = <Goal>[];
    for (final m in _box.values.toList()) {
      if (m.statusIndex != GoalStatus.active.index) continue;
      final g = _map(m);
      final allMet = g.linkedHabitIds.isNotEmpty &&
          g.linkedHabitIds.every(
            (hid) => (streaksByHabit[hid] ?? 0) >= g.targetDays,
          );
      if (allMet) {
        changed.add(await updateStatus(g.id, GoalStatus.completed));
      }
    }
    return changed;
  }

  // ── Cloud sync ────────────────────────────────────────────────────────────
  Future<void> pushPending(String userId) async {
    final pending = _box.values.where((g) => !g.isSynced).toList();
    if (pending.isEmpty) return;
    final rows = pending.map((m) => _map(m).toSupabase(userId)).toList();
    await _client.from('goals').upsert(rows, onConflict: 'id');
    for (final m in pending) {
      m.isSynced = true;
      await m.save();
    }
  }

  Future<void> pullFromCloud(String userId) async {
    final res = await _client
        .from('goals')
        .select()
        .eq('user_id', userId)
        .order('start_date', ascending: false);

    for (final j in res as List) {
      final r = Goal.fromSupabase(j as Map<String, dynamic>);
      if (!_box.containsKey(r.id)) {
        final m = GoalModel(
          id: r.id,
          title: r.title,
          description: r.description,
          icon: r.icon,
          colorIndex: r.colorIndex,
          linkedHabitIds: r.linkedHabitIds,
          targetDays: r.targetDays,
          periodIndex: r.period.index,
          statusIndex: r.status.index,
          startDate: r.startDate,
          completedDate: r.completedDate,
          isSynced: true,
          updatedAt: r.updatedAt,
        );
        await _box.put(m.id, m);
      } else {
        final local = _box.get(r.id)!;
        final serverTs = r.updatedAt ?? r.startDate;
        final localTs = local.updatedAt ?? local.startDate;
        if (serverTs.isAfter(localTs)) {
          local
            ..title = r.title
            ..description = r.description
            ..icon = r.icon
            ..colorIndex = r.colorIndex
            ..linkedHabitIds = r.linkedHabitIds
            ..targetDays = r.targetDays
            ..periodIndex = r.period.index
            ..statusIndex = r.status.index
            ..completedDate = r.completedDate
            ..isSynced = true
            ..updatedAt = r.updatedAt;
          await local.save();
        }
      }
    }
  }

  Future<void> fullSync(String userId) async {
    await pushPending(userId);
    await pullFromCloud(userId);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Goal _map(GoalModel m) => Goal(
        id: m.id,
        title: m.title,
        description: m.description,
        icon: m.icon,
        colorIndex: m.colorIndex,
        linkedHabitIds: List<String>.from(m.linkedHabitIds),
        targetDays: m.targetDays,
        period: GoalPeriod.values[m.periodIndex],
        status: GoalStatus.values[m.statusIndex],
        startDate: m.startDate,
        completedDate: m.completedDate,
        isSynced: m.isSynced,
        updatedAt: m.updatedAt,
      );
}
