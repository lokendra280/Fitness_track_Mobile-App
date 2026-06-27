// phase2_providers.dart — Mood tracking Riverpod providers
// Add to providers.dart or import separately.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/data/repositories/mood_repository.dart';
import 'package:habitflow/domain/entities/mood_entity.dart';
import 'package:habitflow/presentation/providers/providers.dart';

// ── Repository singleton ──────────────────────────────────────────────────────

final moodRepoProvider = Provider<MoodRepository>((_) => MoodRepository());

// ── Mood list notifier ────────────────────────────────────────────────────────

final moodListProvider =
    StateNotifierProvider<MoodNotifier, AsyncValue<List<MoodEntry>>>(
  (ref) => MoodNotifier(
    ref.watch(moodRepoProvider),
    ref.watch(authStateProvider),
  ),
);

class MoodNotifier extends StateNotifier<AsyncValue<List<MoodEntry>>> {
  final MoodRepository _repo;
  final AppAuthState _auth;

  MoodNotifier(this._repo, this._auth) : super(const AsyncValue.loading()) {
    _load();
  }

  void _load() => state = AsyncValue.data(_repo.getAll());

  Future<void> logMood({
    required MoodLevel level,
    required List<MoodTag> tags,
    required String note,
  }) async {
    await _repo.logMood(level: level, tags: tags, note: note);
    _load();
    _push();
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    _load();
    _push();
  }

  Future<void> syncWithCloud(String userId) async {
    await _repo.fullSync(userId);
    _load();
  }

  Future<void> pushPending(String userId) async => _repo.pushPending(userId);

  void refresh() => _load();

  void _push() {
    final uid = _auth.user?.id;
    if (uid != null) _repo.pushPending(uid).catchError((_) {});
  }
}

// ── Today's mood (null = not logged yet) ─────────────────────────────────────

final todayMoodProvider = Provider<MoodEntry?>((ref) {
  ref.watch(moodListProvider);
  return ref.watch(moodRepoProvider).getToday();
});

// ── Week summary ──────────────────────────────────────────────────────────────

final weekMoodSummaryProvider = Provider<WeekMoodSummary>((ref) {
  ref.watch(moodListProvider);
  return ref.watch(moodRepoProvider).getWeekSummary();
});

// ── Mood correlations with habits ─────────────────────────────────────────────

final moodCorrelationsProvider = Provider<List<MoodCorrelation>>((ref) {
  ref.watch(moodListProvider);
  final habits = ref.watch(habitListProvider).value ?? [];
  final checkins = ref.watch(checkinProvider).value ?? [];
  return ref.watch(moodRepoProvider).correlate(
        habits: habits,
        checkins: checkins,
      );
});

// ── Last 30 days for chart ────────────────────────────────────────────────────

final moodChartDataProvider = Provider<List<MoodEntry>>((ref) {
  ref.watch(moodListProvider);
  final from = DateTime.now().subtract(const Duration(days: 29));
  final to = DateTime.now();
  return ref.watch(moodRepoProvider).getRange(from, to);
});

// ── Selected chart range ──────────────────────────────────────────────────────

enum MoodChartRange { week, month }

final moodChartRangeProvider =
    StateProvider<MoodChartRange>((_) => MoodChartRange.week);
