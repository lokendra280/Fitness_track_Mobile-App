// mood_tracking_screen.dart — Phase 2
// Sections: today banner → week bar chart → log sheet → history → correlations

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:habitflow/core/common_widget/common_svg.dart';
import 'package:habitflow/core/theme/app_theme.dart';
import 'package:habitflow/domain/entities/mood_entity.dart';
import 'package:habitflow/presentation/screens/mode_tracking/providers/mood_provider.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class MoodTrackingScreen extends ConsumerWidget {
  const MoodTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayMoodProvider);
    final summary = ref.watch(weekMoodSummaryProvider);
    final history = ref.watch(moodListProvider).value ?? [];
    final corr = ref.watch(moodCorrelationsProvider);

    return Scaffold(
      backgroundColor: context.bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App bar ────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: context.bgColor,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: context.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text('Mood', style: context.syne(20, FontWeight.w700)),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () => _showLogSheet(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: today != null
                          ? today.level.color.withOpacity(.15)
                          : context.accent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        today != null ? today.level.emoji : '+',
                        style: TextStyle(
                          fontSize: today != null ? 18 : 20,
                          color: today != null ? null : Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Today banner ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: today == null
                  ? _LogPromptCard(onTap: () => _showLogSheet(context))
                  : _TodayCard(
                      entry: today, onEdit: () => _showLogSheet(context)),
            ),
          ),

          const SliverGap(16),

          // ── Week bar chart ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _WeekChart(summary: summary),
            ),
          ),

          const SliverGap(16),

          // ── Correlations ───────────────────────────────────────────────
          if (corr.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: _SectionLabel(emoji: '🔗', title: 'Habit impact'),
              ),
            ),
            const SliverGap(10),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  separatorBuilder: (_, __) => const Gap(10),
                  itemCount: corr.length > 5 ? 5 : corr.length,
                  itemBuilder: (_, i) => _CorrelationCard(c: corr[i]),
                ),
              ),
            ),
            const SliverGap(16),
          ],

          // ── History ────────────────────────────────────────────────────
          if (history.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _SectionLabel(emoji: '📋', title: 'History'),
              ),
            ),
            const SliverGap(10),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              sliver: SliverList.separated(
                itemCount: history.length > 30 ? 30 : history.length,
                separatorBuilder: (_, __) => const Gap(8),
                itemBuilder: (_, i) => _HistoryTile(entry: history[i]),
              ),
            ),
          ],

          const SliverGap(40),
        ],
      ),
    );
  }

  void _showLogSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _LogSheet(),
    );
  }
}

// ── Log prompt card ────────────────────────────────────────────────────────────

class _LogPromptCard extends StatelessWidget {
  final VoidCallback onTap;
  const _LogPromptCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.accent.withOpacity(.9),
              context.accent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(children: [
          const Text('🌤️', style: TextStyle(fontSize: 40)),
          const Gap(16),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('How are you feeling?',
                  style:
                      context.syne(18, FontWeight.w700, color: Colors.white)),
              const Gap(4),
              Text('Tap to log today\'s mood',
                  style: context.dmSans(13, FontWeight.w400,
                      color: Colors.white.withOpacity(.8))),
            ],
          )),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
          ),
        ]),
      ),
    );
  }
}

// ── Today card ────────────────────────────────────────────────────────────────

class _TodayCard extends StatelessWidget {
  final MoodEntry entry;
  final VoidCallback onEdit;
  const _TodayCard({required this.entry, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final lvl = entry.level;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: lvl.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: lvl.color.withOpacity(.3), width: 1.5),
      ),
      child: Row(children: [
        // Big emoji + score ring
        Stack(alignment: Alignment.center, children: [
          SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator(
              value: lvl.score / 5,
              strokeWidth: 4,
              backgroundColor: lvl.color.withOpacity(.15),
              valueColor: AlwaysStoppedAnimation(lvl.color),
            ),
          ),
          Text(lvl.emoji, style: const TextStyle(fontSize: 28)),
        ]),
        const Gap(16),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text('Feeling ',
                  style: context.dmSans(14, FontWeight.w400,
                      color: context.textSecondary)),
              Text(lvl.label,
                  style: context.syne(14, FontWeight.w700, color: lvl.color)),
            ]),
            if (entry.tags.isNotEmpty) ...[
              const Gap(6),
              Wrap(
                  spacing: 6,
                  children: entry.tags
                      .map(
                        (t) => _TagChip(tag: t, color: lvl.color),
                      )
                      .toList()),
            ],
            if (entry.note.isNotEmpty) ...[
              const Gap(6),
              Text('"${entry.note}"',
                  style: context.dmSans(12, FontWeight.w400,
                      color: context.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
          ],
        )),
        GestureDetector(
          onTap: onEdit,
          child:
              Icon(Icons.edit_rounded, size: 18, color: context.textTertiary),
        ),
      ]),
    );
  }
}

// ── Week bar chart ────────────────────────────────────────────────────────────

class _WeekChart extends StatelessWidget {
  final WeekMoodSummary summary;
  const _WeekChart({required this.summary});

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.borderColor, width: 1.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Text('This week', style: context.syne(15, FontWeight.w700)),
          const Spacer(),
          if (summary.average > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _avgColor(summary.average).withOpacity(.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(children: [
                Text(_avgEmoji(summary.average),
                    style: const TextStyle(fontSize: 14)),
                const Gap(4),
                Text(summary.average.toStringAsFixed(1),
                    style: context.dmSans(13, FontWeight.w700,
                        color: _avgColor(summary.average))),
              ]),
            ),
        ]),
        const Gap(16),

        // Bars
        SizedBox(
          height: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) {
              final entry = summary.days[i];
              final score = entry?.level.score ?? 0;
              final color = entry?.level.color ?? context.surface3;
              final frac = score / 5.0;
              final isToday = i == (DateTime.now().weekday - 1);

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Score + emoji above bar
                      if (entry != null) ...[
                        Text(entry.level.emoji,
                            style: const TextStyle(fontSize: 14)),
                        const Gap(2),
                      ],
                      // Bar
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutBack,
                        height: score == 0 ? 6 : frac * 72,
                        decoration: BoxDecoration(
                          color: score == 0 ? context.surface3 : color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const Gap(6),
                      // Day label
                      Text(_dayLabels[i],
                          style: context.dmSans(11, FontWeight.w700,
                              color: isToday
                                  ? context.accent
                                  : context.textTertiary)),
                      if (isToday)
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: context.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),

        // Mood scale hint
        const Gap(12),
        Divider(color: context.borderColor, height: 1),
        const Gap(10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: MoodLevel.values
              .map((l) => Column(children: [
                    Text(l.emoji, style: const TextStyle(fontSize: 16)),
                    Text(l.label,
                        style: context.dmSans(9, FontWeight.w500,
                            color: context.textTertiary)),
                  ]))
              .toList(),
        ),
      ]),
    );
  }

  Color _avgColor(double avg) {
    if (avg < 1.5) return MoodLevel.awful.color;
    if (avg < 2.5) return MoodLevel.bad.color;
    if (avg < 3.5) return MoodLevel.okay.color;
    if (avg < 4.5) return MoodLevel.good.color;
    return MoodLevel.amazing.color;
  }

  String _avgEmoji(double avg) {
    if (avg < 1.5) return MoodLevel.awful.emoji;
    if (avg < 2.5) return MoodLevel.bad.emoji;
    if (avg < 3.5) return MoodLevel.okay.emoji;
    if (avg < 4.5) return MoodLevel.good.emoji;
    return MoodLevel.amazing.emoji;
  }
}

// ── Correlation card ──────────────────────────────────────────────────────────

class _CorrelationCard extends StatelessWidget {
  final MoodCorrelation c;
  const _CorrelationCard({required this.c});

  @override
  Widget build(BuildContext context) {
    final color =
        c.positive ? const Color(0xFF43A047) : const Color(0xFFEF5350);
    final sign = c.positive ? '+' : '';
    final uplift = c.uplift.toStringAsFixed(1);

    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(.25), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            CommonSvgWidget(
              svgName: c.habitIcon,
              height: 20,
              width: 20,
              color: context.textPrimary,
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: color.withOpacity(.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('$sign$uplift',
                  style: context.dmSans(12, FontWeight.w800, color: color)),
            ),
          ]),
          const Gap(8),
          Text(c.habitName,
              style: context.dmSans(12, FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const Gap(2),
          Text(
            c.positive
                ? 'Boosts mood by $sign$uplift pts'
                : 'Linked to lower mood',
            style: context.dmSans(10, FontWeight.w400,
                color: context.textSecondary),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

// ── History tile ──────────────────────────────────────────────────────────────

class _HistoryTile extends ConsumerWidget {
  final MoodEntry entry;
  const _HistoryTile({required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lvl = entry.level;
    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFEF5350).withOpacity(.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child:
            const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF5350)),
      ),
      onDismissed: (_) => ref.read(moodListProvider.notifier).delete(entry.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.borderColor, width: 1.5),
        ),
        child: Row(children: [
          // Emoji badge
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: lvl.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(lvl.emoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const Gap(12),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(lvl.label,
                    style:
                        context.dmSans(14, FontWeight.w700, color: lvl.color)),
                const Spacer(),
                Text(_timeLabel(entry.timestamp),
                    style: context.dmSans(11, FontWeight.w400,
                        color: context.textTertiary)),
              ]),
              if (entry.tags.isNotEmpty) ...[
                const Gap(4),
                Wrap(
                    spacing: 6,
                    children: entry.tags
                        .map(
                          (t) => _TagChip(tag: t, color: lvl.color),
                        )
                        .toList()),
              ],
              if (entry.note.isNotEmpty) ...[
                const Gap(4),
                Text('"${entry.note}"',
                    style: context.dmSans(12, FontWeight.w400,
                        color: context.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ],
          )),
        ]),
      ),
    );
  }

  String _timeLabel(DateTime t) {
    final now = DateTime.now();
    if (t.day == now.day && t.month == now.month) return 'Today';
    final y = now.subtract(const Duration(days: 1));
    if (t.day == y.day && t.month == y.month) return 'Yesterday';
    return '${t.day}/${t.month}';
  }
}

// ── Tag chip ──────────────────────────────────────────────────────────────────

class _TagChip extends StatelessWidget {
  final MoodTag tag;
  final Color color;
  const _TagChip({required this.tag, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(.10),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text('${tag.emoji} ${tag.label}',
            style: context.dmSans(10, FontWeight.w600, color: color)),
      );
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String emoji, title;
  const _SectionLabel({required this.emoji, required this.title});

  @override
  Widget build(BuildContext context) => Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const Gap(6),
        Text(title, style: context.syne(15, FontWeight.w700)),
      ]);
}

// ══════════════════════════════════════════════════════════════════════════════
//  LOG SHEET
// ══════════════════════════════════════════════════════════════════════════════

class _LogSheet extends ConsumerStatefulWidget {
  const _LogSheet();

  @override
  ConsumerState<_LogSheet> createState() => _LogSheetState();
}

class _LogSheetState extends ConsumerState<_LogSheet> {
  MoodLevel? _level;
  final Set<MoodTag> _tags = {};
  final _noteCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill if today already logged
    final today = ref.read(todayMoodProvider);
    if (today != null) {
      _level = today.level;
      _tags.addAll(today.tags);
      _noteCtrl.text = today.note;
    }
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_level == null) return;
    setState(() => _saving = true);
    HapticFeedback.mediumImpact();
    await ref.read(moodListProvider.notifier).logMood(
          level: _level!,
          tags: _tags.toList(),
          note: _noteCtrl.text.trim(),
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          // Handle
          Center(
              child: Container(
            margin: const EdgeInsets.only(top: 12),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: context.border2,
              borderRadius: BorderRadius.circular(2),
            ),
          )),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(children: [
              Text('How are you feeling?',
                  style: context.syne(18, FontWeight.w700)),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.close_rounded,
                    color: context.textTertiary, size: 22),
              ),
            ]),
          ),

          Expanded(
              child: ListView(
            controller: ctrl,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            children: [
              // ── Mood selector ─────────────────────────────────────
              Row(
                  children: MoodLevel.values.map((lvl) {
                final sel = _level == lvl;
                return Expanded(
                    child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _level = lvl);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: sel ? lvl.color : lvl.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: sel ? lvl.color : lvl.color.withOpacity(.2),
                        width: sel ? 2 : 1,
                      ),
                      boxShadow: sel
                          ? [
                              BoxShadow(
                                  color: lvl.color.withOpacity(.30),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4))
                            ]
                          : null,
                    ),
                    child: Column(children: [
                      Text(lvl.emoji,
                          style: TextStyle(fontSize: sel ? 28 : 22)),
                      const Gap(4),
                      Text(lvl.label,
                          style: context.dmSans(
                            10,
                            FontWeight.w700,
                            color: sel ? Colors.white : lvl.color,
                          )),
                    ]),
                  ),
                ));
              }).toList()),

              const Gap(24),

              // ── Tags ──────────────────────────────────────────────
              Text('What\'s going on?',
                  style: context.dmSans(13, FontWeight.w600,
                      color: context.textSecondary)),
              const Gap(10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: MoodTag.values.map((tag) {
                  final sel = _tags.contains(tag);
                  final color = _level?.color ?? context.accent;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => sel ? _tags.remove(tag) : _tags.add(tag));
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? color.withOpacity(.15) : context.surface2,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: sel ? color : context.borderColor,
                          width: 1.5,
                        ),
                      ),
                      child: Text('${tag.emoji} ${tag.label}',
                          style: context.dmSans(
                            12,
                            FontWeight.w600,
                            color: sel ? color : context.textSecondary,
                          )),
                    ),
                  );
                }).toList(),
              ),

              const Gap(20),

              // ── Note ──────────────────────────────────────────────
              Text('Add a note (optional)',
                  style: context.dmSans(13, FontWeight.w600,
                      color: context.textSecondary)),
              const Gap(8),
              TextField(
                controller: _noteCtrl,
                maxLines: 3,
                style: context.dmSans(14, FontWeight.w400),
                decoration: InputDecoration(
                  hintText: 'What\'s on your mind today?',
                  filled: true,
                  fillColor: context.surface2,
                  contentPadding: const EdgeInsets.all(14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        BorderSide(color: context.borderColor, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        BorderSide(color: context.borderColor, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: context.accent, width: 2),
                  ),
                ),
              ),
            ],
          )),

          // Save button
          Padding(
            padding: EdgeInsets.fromLTRB(
                20, 0, 20, MediaQuery.of(context).padding.bottom + 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_level == null || _saving) ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _level?.color ?? context.accent,
                  disabledBackgroundColor: context.surface3,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text('Save mood',
                        style: context.syne(15, FontWeight.w700,
                            color: Colors.white)),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
