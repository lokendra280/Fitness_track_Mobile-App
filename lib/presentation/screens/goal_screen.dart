// ─────────────────────────────────────────────────────────────────────────────
//  goals_screen.dart
//  Goals & Milestones — active/completed tabs, arc-ring progress cards,
//  create-goal bottom sheet with habit linking.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:habitflow/core/theme/app_theme.dart';
import 'package:habitflow/data/models/habit_templated.dart';
import 'package:habitflow/presentation/providers/providers.dart';

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});
  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = ref.watch(activeGoalsProvider);
    final completed = ref.watch(completedGoalsProvider);

    return Scaffold(
      backgroundColor: context.bgColor,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true,
            expandedHeight: 110,
            backgroundColor: context.bgColor,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: context.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () => _showCreateSheet(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: context.accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text('Goals', style: context.syne(22, FontWeight.w700)),
              background: Container(color: context.bgColor),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(44),
              child: _TabBar(controller: _tab),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tab,
          children: [
            // Active
            active.isEmpty
                ? _EmptyState(
                    icon: '🎯',
                    title: 'No active goals',
                    subtitle: 'Tap + to set your first goal',
                    onTap: () => _showCreateSheet(context),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    itemCount: active.length,
                    separatorBuilder: (_, __) => const Gap(12),
                    itemBuilder: (_, i) => _GoalCard(goal: active[i]),
                  ),

            // Completed
            completed.isEmpty
                ? const _EmptyState(
                    icon: '🏆',
                    title: 'No completed goals yet',
                    subtitle: 'Keep going — you\'ll get there',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    itemCount: completed.length,
                    separatorBuilder: (_, __) => const Gap(12),
                    itemBuilder: (_, i) => _GoalCard(goal: completed[i]),
                  ),
          ],
        ),
      ),
    );
  }

  void _showCreateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateGoalSheet(),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  GOAL CARD
// ══════════════════════════════════════════════════════════════════════════════

class _GoalCard extends ConsumerWidget {
  final Goal goal;
  const _GoalCard({required this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.habitPalette;
    final accent = colors[goal.colorIndex % colors.length];
    final habits = ref.watch(habitListProvider).value ?? [];
    final linked = habits.where((h) => goal.linkedHabitIds.contains(h.id));
    final isDone = goal.status == GoalStatus.completed;

    return GestureDetector(
      onLongPress: () => _showOptions(context, ref),
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isDone ? context.accent.withOpacity(0.4) : context.borderColor,
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            // ── Arc ring progress ─────────────────────────────────────────
            SizedBox(
              width: 64,
              height: 64,
              child: Stack(
                children: [
                  CustomPaint(
                    size: const Size(64, 64),
                    painter: _ArcPainter(
                      progress: goal.progressFraction,
                      color: accent,
                      trackColor: accent.withOpacity(0.12),
                    ),
                  ),
                  Center(
                    child: isDone
                        ? Icon(Icons.check_rounded, color: accent, size: 22)
                        : Text(
                            goal.icon,
                            style: const TextStyle(fontSize: 22),
                          ),
                  ),
                ],
              ),
            ),

            const Gap(14),

            // ── Content ───────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(goal.title,
                            style: context.syne(15, FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      if (isDone)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: context.accentSurf,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('Done',
                              style: context.dmSans(11, FontWeight.w700,
                                  color: context.accentText)),
                        ),
                    ],
                  ),
                  const Gap(3),
                  Text(
                    goal.description,
                    style: context.dmSans(12, FontWeight.w400,
                        color: context.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(8),

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: goal.progressFraction,
                      minHeight: 4,
                      backgroundColor: accent.withOpacity(0.12),
                      valueColor: AlwaysStoppedAnimation(accent),
                    ),
                  ),
                  const Gap(6),

                  // Days / linked habits row
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 11, color: context.textTertiary),
                      const Gap(3),
                      Text(
                        isDone
                            ? '${goal.targetDays} days completed'
                            : '${goal.daysRemaining} days left',
                        style: context.dmSans(11, FontWeight.w500,
                            color: context.textSecondary),
                      ),
                      const Spacer(),
                      if (linked.isNotEmpty)
                        Row(
                          children: linked.take(3).map((h) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 2),
                              child: Text(h.icon,
                                  style: const TextStyle(fontSize: 13)),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptions(BuildContext context, WidgetRef ref) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _GoalOptionsSheet(goal: goal, ref: ref),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  ARC PAINTER
// ══════════════════════════════════════════════════════════════════════════════

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;
  const _ArcPainter(
      {required this.progress, required this.color, required this.trackColor});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = (size.width / 2) - 5;
    final stroke = 5.0;

    // Track
    canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = trackColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke);

    // Arc
    if (progress > 0) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ArcPainter o) => o.progress != progress;
}

// ══════════════════════════════════════════════════════════════════════════════
//  CREATE GOAL SHEET
// ══════════════════════════════════════════════════════════════════════════════

class _CreateGoalSheet extends ConsumerStatefulWidget {
  @override
  ConsumerState<_CreateGoalSheet> createState() => _CreateGoalSheetState();
}

class _CreateGoalSheetState extends ConsumerState<_CreateGoalSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _icon = '🎯';
  int _colorIdx = 0;
  int _targetDays = 30;
  GoalPeriod _period = GoalPeriod.monthly;
  List<String> _selectedHabitIds = [];
  bool _loading = false;

  static const _icons = [
    '🎯',
    '💪',
    '📚',
    '🏃',
    '🧘',
    '💧',
    '😴',
    '🌟',
    '❤️',
    '🌿'
  ];
  static const _periods = ['Weekly', 'Monthly', 'Yearly'];
  static const _targetOptions = [7, 14, 21, 30, 60, 90];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    HapticFeedback.mediumImpact();
    await ref.read(goalListProvider.notifier).create(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          icon: _icon,
          colorIndex: _colorIdx,
          linkedHabitIds: _selectedHabitIds,
          targetDays: _targetDays,
          period: _period,
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(habitListProvider).value ?? [];

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      maxChildSize: 0.95,
      minChildSize: 0.6,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
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
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Text('New goal', style: context.syne(18, FontWeight.w700)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close_rounded,
                        color: context.textTertiary, size: 22),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                controller: ctrl,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  // Icon row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _icons.map((ic) {
                        final sel = ic == _icon;
                        return GestureDetector(
                          onTap: () => setState(() => _icon = ic),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.only(right: 8),
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: sel
                                  ? context.accent.withOpacity(0.12)
                                  : context.surface2,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    sel ? context.accent : context.borderColor,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(ic,
                                  style: const TextStyle(fontSize: 22)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const Gap(16),

                  // Title
                  _FieldLabel('Title'),
                  const Gap(8),
                  _GoalTextField(
                    controller: _titleCtrl,
                    hint: 'e.g., Build a reading habit',
                  ),
                  const Gap(14),

                  // Description
                  _FieldLabel('Description (optional)'),
                  const Gap(8),
                  _GoalTextField(
                    controller: _descCtrl,
                    hint: 'What will achieving this goal mean to you?',
                    maxLines: 2,
                  ),
                  const Gap(16),

                  // Target duration
                  _FieldLabel('Duration'),
                  const Gap(8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _targetOptions.map((d) {
                      final sel = _targetDays == d;
                      return GestureDetector(
                        onTap: () => setState(() => _targetDays = d),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: sel ? context.accent : context.surface2,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: sel ? context.accent : context.borderColor,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            '$d days',
                            style: context.dmSans(
                              13,
                              FontWeight.w600,
                              color: sel ? Colors.white : context.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const Gap(16),

                  // Color
                  _FieldLabel('Color'),
                  const Gap(8),
                  Row(
                    children: List.generate(AppColors.habitPalette.length, (i) {
                      final sel = _colorIdx == i;
                      return GestureDetector(
                        onTap: () => setState(() => _colorIdx = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 10),
                          width: sel ? 36 : 30,
                          height: sel ? 36 : 30,
                          decoration: BoxDecoration(
                            color: AppColors.habitPalette[i],
                            shape: BoxShape.circle,
                          ),
                          child: sel
                              ? const Icon(Icons.check_rounded,
                                  color: Colors.white, size: 16)
                              : null,
                        ),
                      );
                    }),
                  ),
                  const Gap(16),

                  // Link habits
                  if (habits.isNotEmpty) ...[
                    _FieldLabel('Link habits (optional)'),
                    const Gap(8),
                    ...habits.map((h) {
                      final linked = _selectedHabitIds.contains(h.id);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => linked
                              ? _selectedHabitIds.remove(h.id)
                              : _selectedHabitIds.add(h.id)),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: linked
                                  ? context.accent.withOpacity(0.06)
                                  : context.surface2,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: linked
                                    ? context.accent
                                    : context.borderColor,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(h.icon,
                                    style: const TextStyle(fontSize: 18)),
                                const Gap(10),
                                Expanded(
                                  child: Text(h.name,
                                      style:
                                          context.dmSans(14, FontWeight.w500)),
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: linked
                                        ? context.accent
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: linked
                                          ? context.accent
                                          : context.border2,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: linked
                                      ? const Icon(Icons.check_rounded,
                                          size: 13, color: Colors.white)
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    const Gap(8),
                  ],
                ],
              ),
            ),

            // Save button
            Padding(
              padding: EdgeInsets.fromLTRB(
                  20, 0, 20, MediaQuery.of(context).padding.bottom + 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.accent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text('Set goal',
                          style: context.syne(15, FontWeight.w700,
                              color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  GOAL OPTIONS SHEET (long-press)
// ══════════════════════════════════════════════════════════════════════════════

class _GoalOptionsSheet extends StatelessWidget {
  final Goal goal;
  final WidgetRef ref;
  const _GoalOptionsSheet({required this.goal, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: context.border2,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Gap(16),
          Text(goal.title, style: context.syne(16, FontWeight.w700)),
          const Gap(16),
          if (goal.status == GoalStatus.active) ...[
            _OptionTile(
              icon: Icons.check_circle_outline_rounded,
              label: 'Mark as completed',
              color: context.accent,
              onTap: () {
                ref
                    .read(goalListProvider.notifier)
                    .updateStatus(goal.id, GoalStatus.completed);
                Navigator.pop(context);
              },
            ),
            const Gap(8),
            _OptionTile(
              icon: Icons.pause_circle_outline_rounded,
              label: 'Pause goal',
              color: AppColors.amber400,
              onTap: () {
                ref
                    .read(goalListProvider.notifier)
                    .updateStatus(goal.id, GoalStatus.paused);
                Navigator.pop(context);
              },
            ),
            const Gap(8),
          ],
          _OptionTile(
            icon: Icons.delete_outline_rounded,
            label: 'Delete goal',
            color: context.red,
            onTap: () {
              ref.read(goalListProvider.notifier).delete(goal.id);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _OptionTile(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const Gap(10),
            Text(label,
                style: context.dmSans(14, FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}

// ── Shared small widgets ──────────────────────────────────────────────────────

class _TabBar extends StatelessWidget {
  final TabController controller;
  const _TabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TabBar(
          controller: controller,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          dividerColor: Colors.transparent,
          indicatorColor: context.accent,
          indicatorWeight: 2.5,
          labelStyle: context.dmSans(14, FontWeight.w700),
          unselectedLabelStyle:
              context.dmSans(14, FontWeight.w400, color: context.textSecondary),
          labelColor: context.accent,
          unselectedLabelColor: context.textSecondary,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  const _EmptyState(
      {required this.icon,
      required this.title,
      required this.subtitle,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 48)),
            const Gap(16),
            Text(title,
                style: context.syne(18, FontWeight.w700),
                textAlign: TextAlign.center),
            const Gap(8),
            Text(subtitle,
                style: context.dmSans(14, FontWeight.w400,
                    color: context.textSecondary),
                textAlign: TextAlign.center),
            if (onTap != null) ...[
              const Gap(20),
              GestureDetector(
                onTap: onTap,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: context.accent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text('Set a goal',
                      style: context.dmSans(14, FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style:
            context.dmSans(13, FontWeight.w600, color: context.textSecondary),
      );
}

class _GoalTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  const _GoalTextField(
      {required this.controller, required this.hint, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: context.dmSans(14, FontWeight.w400),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: context.surface2,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.borderColor, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.borderColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.accent, width: 2),
        ),
      ),
    );
  }
}

// ── StepBtn (reused from add_habit_screen) ─────────────────────────────────
Widget StepBtn(IconData icon, VoidCallback onTap) => GestureDetector(
      onTap: onTap,
      child: Builder(
          builder: (context) => Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: context.surface2,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.borderColor, width: 1.5),
                ),
                child: Icon(icon, size: 16, color: context.textPrimary),
              )),
    );
