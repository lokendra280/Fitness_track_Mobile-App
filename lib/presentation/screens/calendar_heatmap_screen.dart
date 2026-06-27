// calendar_heatmap_screen.dart — Duolingo-inspired vibrant edition
// Fixes: ConsumerStatefulWidget, unbounded Row, clean separated widgets.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:habitflow/core/theme/app_theme.dart';
import 'package:habitflow/data/models/habit_templated.dart';
import 'package:habitflow/presentation/providers/providers.dart';

// ─── Color helpers ────────────────────────────────────────────────────────────

Color _tierFill(double v, bool dk) {
  if (v <= 0) return dk ? const Color(0xFF2A2826) : const Color(0xFFEEECE6);
  if (v < .34) return dk ? const Color(0xFF5D4037) : const Color(0xFFFFE082);
  if (v < .67) return dk ? const Color(0xFF8D4E00) : const Color(0xFFFFA726);
  if (v < 1) return dk ? const Color(0xFFBF360C) : const Color(0xFFFF7043);
  return dk ? const Color(0xFF1B5E20) : const Color(0xFF43A047);
}

Color _tierText(double v, bool dk) {
  if (v <= 0) return dk ? const Color(0xFF5E5C57) : const Color(0xFFA09D98);
  if (v < .34) return const Color(0xFF795548);
  if (v < .67) return const Color(0xFFE65100);
  if (v < 1) return const Color(0xFFBF360C);
  return const Color(0xFF1B5E20);
}

String _tierEmoji(double v) {
  if (v <= 0) return '';
  if (v < .34) return '✨';
  if (v < .67) return '⚡';
  if (v < 1) return '🔥';
  return '💪';
}

const _weekdotColors = [
  Color(0xFFEF5350),
  Color(0xFFFF7043),
  Color(0xFFFFCA28),
  Color(0xFF66BB6A),
  Color(0xFF26C6DA),
  Color(0xFF7E57C2),
  Color(0xFFEC407A),
];
const _wdLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
const _monthNames = [
  '',
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class CalendarHeatmapScreen extends ConsumerWidget {
  const CalendarHeatmapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(overallStreakProvider);
    final longest = ref.watch(longestEverProvider);
    final progress = ref.watch(progressProvider);

    return Scaffold(
      backgroundColor: context.bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: context.bgColor,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: context.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text('My streak', style: context.syne(20, FontWeight.w700)),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: _XpBanner(
                streak: streak,
                longest: longest,
                done: progress.done,
                total: progress.total,
              ),
            ),
          ),
          const SliverGap(16),
          SliverToBoxAdapter(child: _MonthCalendar()),
          const SliverGap(16),
          SliverToBoxAdapter(child: _WeekStrip()),
          const SliverGap(16),
          SliverToBoxAdapter(child: _MonthStats()),
          const SliverGap(40),
        ],
      ),
    );
  }
}

// ─── XP Banner ────────────────────────────────────────────────────────────────

class _XpBanner extends StatelessWidget {
  final int streak, longest, done, total;
  const _XpBanner({
    required this.streak,
    required this.longest,
    required this.done,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : done / total;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF43A047), Color(0xFF1B5E20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(children: [
        // Left: streak + xp bar
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Day streak',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(.75),
                    fontWeight: FontWeight.w600)),
            const Gap(4),
            Text('$streak days',
                style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1)),
            const Gap(10),
            // XP bar
            Row(children: [
              Text('Today: $done/$total',
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(.8),
                      fontWeight: FontWeight.w600)),
            ]),
            const Gap(6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 10,
                backgroundColor: Colors.white.withOpacity(.2),
                valueColor: const AlwaysStoppedAnimation(Color(0xFFFFC107)),
              ),
            ),
          ],
        )),
        const Gap(16),
        // Right: best + today
        Column(children: [
          _BannerPill(emoji: '🏆', label: 'Best', value: '$longest'),
          const Gap(10),
          _BannerPill(
            emoji: done == total && total > 0 ? '🎉' : '💪',
            label: 'Today',
            value: '$done/$total',
          ),
        ]),
      ]),
    );
  }
}

class _BannerPill extends StatelessWidget {
  final String emoji, label, value;
  const _BannerPill(
      {required this.emoji, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const Gap(2),
          Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(.7),
                  fontWeight: FontWeight.w600)),
        ]),
      );
}

// ─── Month Calendar ───────────────────────────────────────────────────────────

class _MonthCalendar extends ConsumerStatefulWidget {
  @override
  ConsumerState<_MonthCalendar> createState() => _MonthCalendarState();
}

class _MonthCalendarState extends ConsumerState<_MonthCalendar> {
  DateTime? _selected;

  @override
  Widget build(BuildContext context) {
    final month = ref.watch(calendarMonthProvider);
    final cells = ref.watch(monthHeatmapProvider(month));
    final isDark = context.isDark;

    // Monday-based offset
    final offset = (DateTime(month.year, month.month, 1).weekday - 1) % 7;
    final rows = ((offset + cells.length) / 7).ceil();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: context.borderColor, width: 1.5),
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(children: [
          // ── Nav ──────────────────────────────────────────────
          Row(children: [
            Text('${_monthNames[month.month]} ${month.year}',
                style: context.syne(17, FontWeight.w700)),
            const Spacer(),
            _NavBtn(
                icon: Icons.chevron_left_rounded,
                onTap: () {
                  HapticFeedback.selectionClick();
                  ref.read(calendarMonthProvider.notifier).state =
                      DateTime(month.year, month.month - 1);
                }),
            const Gap(8),
            _NavBtn(
              icon: Icons.chevron_right_rounded,
              onTap: (month.year == DateTime.now().year &&
                      month.month == DateTime.now().month)
                  ? null
                  : () {
                      HapticFeedback.selectionClick();
                      ref.read(calendarMonthProvider.notifier).state =
                          DateTime(month.year, month.month + 1);
                    },
            ),
          ]),
          const Gap(14),

          // ── Weekday headers ──────────────────────────────────
          Row(
              children: List.generate(
                  7,
                  (i) => Expanded(
                        child: Column(children: [
                          Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                  color: _weekdotColors[i],
                                  shape: BoxShape.circle)),
                          const Gap(3),
                          Text(_wdLabels[i],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _weekdotColors[i])),
                        ]),
                      ))),
          const Gap(10),

          // ── Grid ─────────────────────────────────────────────
          ...List.generate(
              rows,
              (row) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                        children: List.generate(7, (col) {
                      final idx = row * 7 + col - offset;
                      if (idx < 0 || idx >= cells.length) {
                        return const Expanded(child: SizedBox(height: 46));
                      }
                      final cell = cells[idx];
                      final isSelected = _selected?.day == cell.date.day &&
                          _selected?.month == cell.date.month;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: _DayCell(
                            cell: cell,
                            isDark: isDark,
                            isSelected: isSelected,
                            onTap: cell.date.isAfter(DateTime.now())
                                ? null
                                : () {
                                    HapticFeedback.lightImpact();
                                    setState(() => _selected =
                                        isSelected ? null : cell.date);
                                  },
                          ),
                        ),
                      );
                    })),
                  )),

          // ── Day detail ────────────────────────────────────────
          if (_selected != null) ...[
            const Gap(4),
            Divider(color: context.borderColor, height: 1),
            const Gap(12),
            _DayDetail(date: _selected!, cells: cells, isDark: isDark),
          ],
        ]),
      ),
    );
  }
}

// ─── Day Cell ─────────────────────────────────────────────────────────────────

class _DayCell extends StatefulWidget {
  final HeatmapCell cell;
  final bool isDark, isSelected;
  final VoidCallback? onTap;
  const _DayCell({
    required this.cell,
    required this.isDark,
    required this.isSelected,
    this.onTap,
  });

  @override
  State<_DayCell> createState() => _DayCellState();
}

class _DayCellState extends State<_DayCell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 110));
  late final Animation<double> _scale = Tween(begin: 1.0, end: 0.86)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _tap() {
    if (widget.onTap == null) return;
    _ctrl.forward().then((_) => _ctrl.reverse());
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.cell.intensity;
    final isFuture = widget.cell.date.isAfter(DateTime.now());
    final fill = widget.isSelected
        ? context.accent
        : isFuture
            ? (widget.isDark
                ? const Color(0xFF1E1E1C)
                : const Color(0xFFF1EFE8))
            : _tierFill(v, widget.isDark);
    final em = isFuture ? '' : _tierEmoji(v);

    return GestureDetector(
      onTap: _tap,
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          height: 46,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(12),
            border: widget.cell.isToday && !widget.isSelected
                ? Border.all(color: context.accent, width: 2.5)
                : null,
            boxShadow: widget.cell.isFull && !isFuture
                ? [
                    BoxShadow(
                        color: const Color(0xFF43A047).withOpacity(.30),
                        blurRadius: 8,
                        offset: const Offset(0, 3))
                  ]
                : null,
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (em.isNotEmpty)
              Text(em, style: const TextStyle(fontSize: 12, height: 1.1)),
            Text('${widget.cell.date.day}',
                style: TextStyle(
                  fontSize: em.isEmpty ? 13 : 11,
                  fontWeight: widget.cell.isToday ||
                          widget.isSelected ||
                          widget.cell.isFull
                      ? FontWeight.w800
                      : FontWeight.w500,
                  color: widget.isSelected
                      ? Colors.white
                      : isFuture
                          ? (widget.isDark
                              ? const Color(0xFF3A3835)
                              : const Color(0xFFCCCAC3))
                          : v > 0
                              ? _tierText(v, widget.isDark)
                              : (widget.isDark
                                  ? const Color(0xFF5E5C57)
                                  : const Color(0xFF9B9790)),
                  height: 1.1,
                )),
          ]),
        ),
      ),
    );
  }
}

// ─── Day Detail (inline) ──────────────────────────────────────────────────────

class _DayDetail extends StatelessWidget {
  final DateTime date;
  final List<HeatmapCell> cells;
  final bool isDark;
  const _DayDetail(
      {required this.date, required this.cells, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cell = cells.firstWhere(
      (c) => c.date.day == date.day && c.date.month == date.month,
      orElse: () => HeatmapCell(date: date, completedHabits: 0, totalHabits: 0),
    );
    final v = cell.intensity;
    final fill = _tierFill(v, isDark);
    final pct = cell.totalHabits == 0 ? 0 : (v * 100).round();

    return Row(children: [
      Container(
        width: 48,
        height: 48,
        decoration:
            BoxDecoration(color: fill, borderRadius: BorderRadius.circular(14)),
        child: Center(
            child: Text(
          v > 0 ? _tierEmoji(v) : '😶',
          style: const TextStyle(fontSize: 24),
        )),
      ),
      const Gap(12),
      Expanded(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_label(date), style: context.dmSans(14, FontWeight.w700)),
          Text(
              cell.totalHabits == 0
                  ? 'No habits tracked'
                  : '${cell.completedHabits} of ${cell.totalHabits} done',
              style: context.dmSans(12, FontWeight.w400,
                  color: context.textSecondary)),
          const Gap(6),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: v,
              minHeight: 7,
              backgroundColor: context.surface3,
              valueColor: AlwaysStoppedAnimation(fill),
            ),
          ),
        ],
      )),
      const Gap(10),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration:
            BoxDecoration(color: fill, borderRadius: BorderRadius.circular(10)),
        child: Text('$pct%',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: v > 0 ? _tierText(v, isDark) : context.textTertiary)),
      ),
    ]);
  }

  String _label(DateTime d) {
    final now = DateTime.now();
    if (d.day == now.day && d.month == now.month) return 'Today';
    final y = now.subtract(const Duration(days: 1));
    if (d.day == y.day && d.month == y.month) return 'Yesterday';
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const mons = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${days[d.weekday - 1]}, ${mons[d.month - 1]} ${d.day}';
  }
}

// ─── Nav button ───────────────────────────────────────────────────────────────

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _NavBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: onTap != null
                ? context.accent.withOpacity(.12)
                : context.surface2,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: onTap != null
                  ? context.accent.withOpacity(.3)
                  : context.borderColor,
              width: 1.5,
            ),
          ),
          child: Icon(icon,
              size: 18,
              color: onTap != null ? context.accent : context.textTertiary),
        ),
      );
}

// ─── 12-Week Strip ────────────────────────────────────────────────────────────

class _WeekStrip extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cells = ref.watch(heatmapProvider);
    final isDark = context.isDark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.borderColor, width: 1.5),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('📈', style: const TextStyle(fontSize: 16)),
            const Gap(6),
            Text('12-week history', style: context.syne(14, FontWeight.w700)),
          ]),
          const Gap(10),
          SizedBox(
            height: 88,
            child: Row(
              children: List.generate(
                  12,
                  (w) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1.5),
                          child: Column(
                            children: List.generate(7, (d) {
                              final idx = w * 7 + d;
                              if (idx >= cells.length) {
                                return const Expanded(child: SizedBox());
                              }
                              final cell = cells[idx];
                              return Expanded(
                                  child: Padding(
                                padding: const EdgeInsets.all(1.5),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 400),
                                  decoration: BoxDecoration(
                                    color: _tierFill(cell.intensity, isDark),
                                    borderRadius: BorderRadius.circular(4),
                                    border: cell.isToday
                                        ? Border.all(
                                            color: context.accent, width: 1.5)
                                        : null,
                                  ),
                                ),
                              ));
                            }),
                          ),
                        ),
                      )),
            ),
          ),
          const Gap(8),
          // Legend
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Text('Less',
                style: context.dmSans(10, FontWeight.w400,
                    color: context.textTertiary)),
            const Gap(4),
            ...[0.0, 0.2, 0.5, 0.8, 1.0].map((v) => Container(
                  margin: const EdgeInsets.only(left: 3),
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: _tierFill(v, isDark),
                    borderRadius: BorderRadius.circular(3),
                  ),
                )),
            const Gap(4),
            Text('More',
                style: context.dmSans(10, FontWeight.w400,
                    color: context.textTertiary)),
          ]),
        ]),
      ),
    );
  }
}

// ─── Monthly Stats ────────────────────────────────────────────────────────────

class _MonthStats extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(calendarMonthProvider);
    final cells = ref.watch(monthHeatmapProvider(month));
    final now = DateTime.now();
    final past = cells.where((c) => !c.date.isAfter(now)).toList();

    final perfect = past.where((c) => c.isFull).length;
    final active = past.where((c) => c.completedHabits > 0).length;
    final zero = past.where((c) => c.completedHabits == 0).length;
    final pct = past.isEmpty ? 0 : (perfect / past.length * 100).round();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('🏅', style: const TextStyle(fontSize: 16)),
          const Gap(6),
          Text('This month', style: context.syne(14, FontWeight.w700)),
        ]),
        const Gap(10),
        Row(children: [
          _Stat(
              emoji: '💪',
              value: '$perfect',
              label: 'Perfect',
              color: const Color(0xFF43A047)),
          const Gap(8),
          _Stat(
              emoji: '⚡',
              value: '$active',
              label: 'Active',
              color: const Color(0xFFFFA726)),
          const Gap(8),
          _Stat(
              emoji: '😴',
              value: '$zero',
              label: 'Rest',
              color: const Color(0xFF7E57C2)),
          const Gap(8),
          _Stat(
              emoji: '🏅',
              value: '$pct%',
              label: 'Done',
              color: const Color(0xFF26C6DA)),
        ]),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  final String emoji, value, label;
  final Color color;
  const _Stat(
      {required this.emoji,
      required this.value,
      required this.label,
      required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
          child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.borderColor, width: 1.5),
        ),
        child: Column(children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const Gap(4),
          Text(value,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800, color: color)),
          const Gap(2),
          Text(label,
              style: context.dmSans(10, FontWeight.w500,
                  color: context.textSecondary)),
        ]),
      ));
}
