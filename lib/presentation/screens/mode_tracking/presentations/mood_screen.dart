import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:habitflow/core/theme/app_theme.dart';
import 'package:habitflow/domain/entities/mood_entity.dart';
import 'package:habitflow/presentation/screens/mode_tracking/presentations/mode_tracking_screen.dart';
import 'package:habitflow/presentation/screens/mode_tracking/providers/mood_provider.dart';

class MoodHomeCard extends ConsumerWidget {
  const MoodHomeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayMoodProvider);
    final summary = ref.watch(weekMoodSummaryProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MoodTrackingScreen()),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: today != null
                  ? today.level.color.withOpacity(.25)
                  : context.borderColor,
              width: 1.5,
            ),
          ),
          child: Row(children: [
            // Left: emoji + label
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: today != null ? today.level.surface : context.surface2,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  today?.level.emoji ?? '🌤️',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const Gap(12),

            // Middle: label + week dots
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  today != null
                      ? 'Feeling ${today.level.label}'
                      : 'Log today\'s mood',
                  style: context.dmSans(14, FontWeight.w700,
                      color: today?.level.color ?? context.textPrimary),
                ),
                const Gap(6),
                // 7-dot week summary
                Row(
                  children: List.generate(7, (i) {
                    final entry = summary.days[i];
                    final isToday = i == (DateTime.now().weekday - 1);
                    return Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: isToday ? 14 : 10,
                        height: isToday ? 14 : 10,
                        decoration: BoxDecoration(
                          color: entry != null
                              ? entry.level.color
                              : context.surface3,
                          shape: BoxShape.circle,
                          border: isToday
                              ? Border.all(
                                  color: context.textSecondary, width: 1.5)
                              : null,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            )),

            // Right: avg pill
            if (summary.average > 0) ...[
              const Gap(8),
              Column(children: [
                Text(
                  _avgEmoji(summary.average),
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  summary.average.toStringAsFixed(1),
                  style: context.dmSans(11, FontWeight.w700,
                      color: context.textSecondary),
                ),
                Text('avg',
                    style: context.dmSans(10, FontWeight.w400,
                        color: context.textTertiary)),
              ]),
            ],

            const Gap(4),
            Icon(Icons.chevron_right_rounded,
                size: 18, color: context.textTertiary),
          ]),
        ),
      ),
    );
  }

  String _avgEmoji(double avg) {
    if (avg < 1.5) return MoodLevel.awful.emoji;
    if (avg < 2.5) return MoodLevel.bad.emoji;
    if (avg < 3.5) return MoodLevel.okay.emoji;
    if (avg < 4.5) return MoodLevel.good.emoji;
    return MoodLevel.amazing.emoji;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PROVIDERS.DART ADDITIONS
//  Paste these blocks into your existing providers.dart file.
// ─────────────────────────────────────────────────────────────────────────────

/*
// ── ADD to imports ────────────────────────────────────────────────────────────

import 'package:habitflow/data/repositories/mood_repository.dart';
import 'package:habitflow/domain/entities/mood_entity.dart';

// ── ADD after goalRepoProvider ────────────────────────────────────────────────

final moodRepoProvider = Provider<MoodRepository>((_) => MoodRepository());

// ══════════════════════════════════════════════════════════════════════════════
//  PHASE 2 — MOOD TRACKING
// ══════════════════════════════════════════════════════════════════════════════

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

final todayMoodProvider = Provider<MoodEntry?>((ref) {
  ref.watch(moodListProvider);
  return ref.watch(moodRepoProvider).getToday();
});

final weekMoodSummaryProvider = Provider<WeekMoodSummary>((ref) {
  ref.watch(moodListProvider);
  return ref.watch(moodRepoProvider).getWeekSummary();
});

final moodCorrelationsProvider = Provider<List<MoodCorrelation>>((ref) {
  ref.watch(moodListProvider);
  final habits   = ref.watch(habitListProvider).value ?? [];
  final checkins = ref.watch(checkinProvider).value ?? [];
  return ref.watch(moodRepoProvider).correlate(
    habits: habits,
    checkins: checkins,
  );
});

// ── ADD to FullSyncOrchestrator.syncAll() ─────────────────────────────────────
//   _ref.read(moodListProvider.notifier).syncWithCloud(userId),

// ── ADD to FullSyncOrchestrator.pushAllPending() ──────────────────────────────
//   _ref.read(moodListProvider.notifier).pushPending(userId),

// ── ADD to main.dart before runApp() ─────────────────────────────────────────
//   await MoodRepository.init();
*/
