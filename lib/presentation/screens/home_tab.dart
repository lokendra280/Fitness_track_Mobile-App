// home_tab.dart — Phase 1 + Phase 2 Mood card

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:habitflow/core/theme/app_theme.dart';
import 'package:habitflow/data/models/habit_templated.dart';
import 'package:habitflow/domain/entities/entities.dart';
import 'package:habitflow/domain/entities/mood_entity.dart';
import 'package:habitflow/presentation/providers/providers.dart';
import 'package:habitflow/presentation/screens/add_habit_screen.dart';
import 'package:habitflow/presentation/screens/calendar_heatmap_screen.dart';
import 'package:habitflow/presentation/screens/goal_screen.dart';
import 'package:habitflow/presentation/screens/habit_templates_screen.dart';
import 'package:habitflow/presentation/screens/mode_tracking/presentations/mode_tracking_screen.dart';
import 'package:habitflow/presentation/screens/mode_tracking/providers/mood_provider.dart';
import 'package:habitflow/presentation/widgets/empty_habit.dart';
import 'package:habitflow/presentation/widgets/habit_card.dart';

class HomeTab extends ConsumerWidget {
  final ScrollController? scrollController;
  final Future<void> Function(String, int) onCheckin;
  final VoidCallback onAddHabit;
  final void Function(Habit) onEditHabit;
  final String? justDone;
  final bool isDark;
  final AppUser? user;
  final VoidCallback onToggleTheme;

  const HomeTab({
    required this.onCheckin,
    required this.onAddHabit,
    required this.onEditHabit,
    required this.justDone,
    required this.isDark,
    required this.user,
    required this.onToggleTheme,
    required this.scrollController,
    super.key,
  });

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return '🌅 Good morning,';
    if (h < 17) return '⚡ Good afternoon,';
    return '🌙 Good evening,';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitListProvider);
    final progress = ref.watch(progressProvider);
    final streak = ref.watch(overallStreakProvider);
    final longest = ref.watch(longestEverProvider);

    return SafeArea(
      child: CustomScrollView(
        controller: scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_greeting(),
                          style: context.dmSans(14, FontWeight.w500,
                              color: context.textSecondary)),
                      if (user?.displayName != null) ...[
                        const Gap(2),
                        Text(user!.displayName!,
                            style: context.syne(22, FontWeight.w700)),
                      ],
                    ],
                  ),
                ),
                const Gap(8),
                _IconBtn(
                  onTap: onToggleTheme,
                  child: Text(isDark ? '☀️' : '🌙',
                      style: const TextStyle(fontSize: 16)),
                ),
                const Gap(8),
                _IconBtn(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CalendarHeatmapScreen())),
                  child: Icon(Icons.calendar_today_outlined,
                      size: 18, color: context.textSecondary),
                ),
              ]),
            ),
          ),

          // ── Streak card ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _StreakCard(
                streak: streak,
                longest: longest,
                done: progress.done,
                total: progress.total,
              ),
            ),
          ),

          // ── Today header + progress bar ───────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 4),
              child: Row(children: [
                Text("Today's habits",
                    style: context.syne(18, FontWeight.w700)),
                const Spacer(),
                Text('${progress.done}/${progress.total} done',
                    style: context.dmSans(12, FontWeight.w500,
                        color: context.accent)),
              ]),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value:
                      progress.total > 0 ? progress.done / progress.total : 0,
                  minHeight: 6,
                  backgroundColor: context.surface3,
                  valueColor: AlwaysStoppedAnimation(context.accent),
                ),
              ),
            ),
          ),

          // ── Phase 1 + Phase 2 dashboard section ───────────────────────────
          const SliverToBoxAdapter(child: _DashboardSection()),

          // ── Habit list ────────────────────────────────────────────────────
          habitsAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (e, _) =>
                SliverToBoxAdapter(child: Center(child: Text('$e'))),
            data: (habits) {
              if (habits.isEmpty) {
                return SliverToBoxAdapter(
                  child: EmptyHabits(
                    onAdd: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AddHabitPage())),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                sliver: SliverList.separated(
                  itemCount: habits.length,
                  separatorBuilder: (_, __) => const Gap(10),
                  itemBuilder: (_, i) {
                    final h = habits[i];
                    final done = ref.watch(todayCountProvider(h.id));
                    final s = ref.watch(streakProvider(h.id));
                    return HabitCard(
                      habit: h,
                      done: done,
                      streak: s,
                      justCompleted: justDone == h.id,
                      onCheckin: () => onCheckin(h.id, h.targetPerDay),
                      onEdit: () => onEditHabit(h),
                    );
                  },
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: Gap(120)),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  DASHBOARD SECTION  (Phase 1 + Phase 2)
//  2 × 2 grid: Routines | Calendar
//              Goals     | Mood
//  + mini heatmap strip below
// ══════════════════════════════════════════════════════════════════════════════

class _DashboardSection extends ConsumerWidget {
  const _DashboardSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeGoalsProvider);
    final cells = ref.watch(heatmapProvider);
    final todayDone = cells.isNotEmpty ? cells.last.completedHabits : 0;
    final todayTotal = cells.isNotEmpty ? cells.last.totalHabits : 0;
    final miniCells =
        cells.length > 28 ? cells.sublist(cells.length - 28) : cells;

    // Mood data
    final todayMood = ref.watch(todayMoodProvider);
    final moodLabel = todayMood != null ? todayMood.level.label : 'Not logged';
    final moodEmoji = todayMood != null ? todayMood.level.emoji : '🌤️';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section label
          Text('Quick access',
              style: context.dmSans(13, FontWeight.w600,
                  color: context.textSecondary)),
          const Gap(10),

          // ── Row 1: Routines | Calendar ───────────────────────────────────
          Row(children: [
            Expanded(
              child: _QuickCard(
                icon: '📋',
                label: 'Routines',
                subtitle: '${HabitTemplate.seeds.length} templates',
                accentColor: AppColors.purple700,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const HabitTemplatesScreen())),
              ),
            ),
            const Gap(10),
            Expanded(
              child: _QuickCard(
                icon: '📅',
                label: 'Calendar',
                subtitle: '$todayDone/$todayTotal today',
                accentColor: AppColors.blue700,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CalendarHeatmapScreen())),
              ),
            ),
          ]),

          const Gap(10),

          // ── Row 2: Goals | Mood ──────────────────────────────────────────
          Row(children: [
            Expanded(
              child: _QuickCard(
                icon: '🎯',
                label: 'Goals',
                subtitle: '${active.length} active',
                accentColor: AppColors.coral700,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const GoalsScreen())),
              ),
            ),
            const Gap(10),
            // ── Mood card (Phase 2) ──────────────────────────────────────
            Expanded(
              child: _MoodQuickCard(
                emoji: moodEmoji,
                label: 'Mood',
                subtitle: moodLabel,
                logged: todayMood != null,
                moodColor: todayMood?.level.color ?? AppColors.teal700,
              ),
            ),
          ]),

          // Mini heatmap strip
          const Gap(10),
          _MiniHeatmapStrip(cells: miniCells),
          const Gap(8),
        ],
      ),
    );
  }
}

// ── Standard quick card ───────────────────────────────────────────────────────

class _QuickCard extends StatelessWidget {
  final String icon;
  final String label;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  const _QuickCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.borderColor, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 17)),
              ),
            ),
            const Gap(8),
            Text(label,
                style: context.dmSans(13, FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text(subtitle,
                style: context.dmSans(11, FontWeight.w400,
                    color: context.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

// ── Mood quick card — adapts to logged / not-logged state ─────────────────────

class _MoodQuickCard extends ConsumerWidget {
  final String emoji;
  final String label;
  final String subtitle;
  final bool logged;
  final Color moodColor;

  const _MoodQuickCard({
    required this.emoji,
    required this.label,
    required this.subtitle,
    required this.logged,
    required this.moodColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 7-dot week summary
    final summary = ref.watch(weekMoodSummaryProvider);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MoodTrackingScreen()),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: logged ? moodColor.withOpacity(0.07) : context.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: logged ? moodColor.withOpacity(0.35) : context.borderColor,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon badge
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: moodColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 17)),
              ),
            ),
            const Gap(8),

            // Label
            Text(label,
                style: context.dmSans(13, FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),

            // Subtitle: mood name OR week dots
            if (!logged)
              Text('Tap to log',
                  style: context.dmSans(11, FontWeight.w400,
                      color: context.textSecondary))
            else
              // 7 mini dots showing week mood colors
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: List.generate(7, (i) {
                    final entry = summary.days[i];
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 2),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 5,
                          decoration: BoxDecoration(
                            color: entry != null
                                ? entry.level.color
                                : context.surface3,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Mini 4-week heatmap strip ─────────────────────────────────────────────────

class _MiniHeatmapStrip extends ConsumerWidget {
  final List<HeatmapCell> cells;
  const _MiniHeatmapStrip({required this.cells});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CalendarHeatmapScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.borderColor, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text('Last 4 weeks',
                  style: context.dmSans(12, FontWeight.w600,
                      color: context.textSecondary)),
              const Spacer(),
              Text('View all',
                  style: context.dmSans(12, FontWeight.w600,
                      color: context.accent)),
              const Gap(2),
              Icon(Icons.chevron_right_rounded,
                  size: 14, color: context.accent),
            ]),
            const Gap(8),
            SizedBox(
              height: 28,
              child: Row(
                children: List.generate(
                  cells.length > 28 ? 28 : cells.length,
                  (i) {
                    final cell = cells[i];
                    final Color fill;
                    if (cell.totalHabits == 0 || cell.completedHabits == 0) {
                      fill = context.surface3;
                    } else {
                      final v = (cell.completedHabits / cell.totalHabits)
                          .clamp(0.0, 1.0);
                      fill = context.accent.withOpacity(v < 0.34
                          ? 0.22
                          : v < 0.67
                              ? 0.55
                              : 1.0);
                    }
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(1.5),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: fill,
                            borderRadius: BorderRadius.circular(3),
                            border: cell.isToday
                                ? Border.all(color: context.accent, width: 1.5)
                                : null,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const Gap(4),
            Row(children: [
              Expanded(
                child: Text('Mon',
                    style: context.dmSans(10, FontWeight.w400,
                        color: context.textTertiary)),
              ),
              Text('Thu',
                  style: context.dmSans(10, FontWeight.w400,
                      color: context.textTertiary)),
              const Expanded(child: SizedBox()),
            ]),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  SHARED SMALL WIDGETS
// ══════════════════════════════════════════════════════════════════════════════

class _StreakCard extends StatelessWidget {
  final int streak, longest, done, total;
  const _StreakCard({
    required this.streak,
    required this.longest,
    required this.done,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF52B788), Color(0xFF2D6A4F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF52B788).withOpacity(0.30),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current streak',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(.75),
                      fontWeight: FontWeight.w500)),
              const Gap(6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$streak',
                      style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.0)),
                  const Gap(4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('days',
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(.75),
                            fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
              const Gap(8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Today $done/$total habits',
                    style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.15),
            shape: BoxShape.circle,
          ),
          child:
              const Center(child: Text('🔥', style: TextStyle(fontSize: 32))),
        ),
        const Gap(16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Best streak',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(.75),
                    fontWeight: FontWeight.w500)),
            const Gap(4),
            Text('$longest',
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1)),
            Text('days',
                style: TextStyle(
                    fontSize: 12, color: Colors.white.withOpacity(.75))),
          ],
        ),
      ]),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _IconBtn({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: context.surfaceColor,
          shape: BoxShape.circle,
          border: Border.all(color: context.border2, width: 1.5),
        ),
        child: Center(child: child),
      ),
    );
  }
}
