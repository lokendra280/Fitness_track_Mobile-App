import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/constants/app_topography.dart';
import 'package:habitflow/core/router/app_router.dart';
import 'package:habitflow/core/theme/app_theme.dart';
import 'package:habitflow/core/widgets/animated_common.dart';
import 'package:habitflow/data/models/ai_plan.dart';
import 'package:habitflow/data/models/daily_workout.dart';
import 'package:habitflow/data/models/exercise_item.dart';
import 'package:habitflow/features/ai_plan/providers/ai_plan_provider.dart';
import 'package:habitflow/features/habit_tracking/providers/habit_proof_provider.dart';

class AiPlanScreen extends ConsumerWidget {
  const AiPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final generation = ref.watch(aiPlanGenerationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: generation.when(
          loading: () => const _LoadingState(),
          error: (err, _) => _ErrorState(
            message: err.toString(),
            onRetry: () => ref.invalidate(aiPlanGenerationProvider),
          ),
          data: (plan) => _PlanReview(plan: plan),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Loading
// ---------------------------------------------------------------------------

class _LoadingState extends StatefulWidget {
  const _LoadingState();

  @override
  State<_LoadingState> createState() => _LoadingStateState();
}

class _LoadingStateState extends State<_LoadingState> {
  static const _steps = [
    (Icons.water_drop_rounded, 'Calculating your water target'),
    (Icons.directions_walk_rounded, 'Setting a daily step goal'),
    (Icons.fitness_center_rounded, 'Planning your exercise routine'),
    (Icons.bedtime_rounded, 'Balancing your sleep schedule'),
    (Icons.checklist_rounded, 'Choosing habits that fit'),
  ];

  int _index = 0;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1400), (_) {
      if (mounted) setState(() => _index = (_index + 1) % _steps.length);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (icon, label) = _steps[_index];

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 96,
              height: 96,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 96,
                    height: 96,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppColors.goalStepsColor,
                      backgroundColor:
                          AppColors.goalStepsColor.withValues(alpha: 0.12),
                    ),
                  ),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.goalStepsColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      transitionBuilder: (child, anim) => ScaleTransition(
                        scale: anim,
                        child: FadeTransition(opacity: anim, child: child),
                      ),
                      child: Icon(
                        icon,
                        key: ValueKey(icon),
                        size: 28,
                        color: AppColors.goalStepsColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Building your plan',
              style: AppTypography.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                label,
                key: ValueKey(label),
                style:
                    AppTypography.body.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error
// ---------------------------------------------------------------------------

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.goalCardioColor.withValues(alpha: 0.12),
              ),
              child: Icon(Icons.error_outline_rounded,
                  size: 32, color: AppColors.goalCardioColor),
            ),
            const SizedBox(height: 20),
            Text('Something went wrong', style: AppTypography.h3),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.steps,
                minimumSize: const Size(160, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Plan review
// ---------------------------------------------------------------------------

class _PlanReview extends ConsumerStatefulWidget {
  final AiPlan plan;
  const _PlanReview({required this.plan});

  @override
  ConsumerState<_PlanReview> createState() => _PlanReviewState();
}

class _PlanReviewState extends ConsumerState<_PlanReview> {
  bool _accepting = false;

  Future<void> _accept() async {
    setState(() => _accepting = true);
    try {
      await ref.read(aiPlanControllerProvider.notifier).acceptPlan(widget.plan);
      if (mounted) context.go(AppRoutes.bottomNavbar);
    } catch (e) {
      if (mounted) {
        setState(() => _accepting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save your plan: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;

    final sections = <Widget>[
      _HeroHeader(plan: plan),
      const SizedBox(height: 20),
      _TargetStatGrid(plan: plan),
      if (plan.weeklySchedule.isNotEmpty) ...[
        const SizedBox(height: 20),
        _WeeklyScheduleSection(schedule: plan.weeklySchedule),
      ],
      const SizedBox(height: 20),
      _PlanTile(
        icon: Icons.bedtime_rounded,
        color: AppColors.goalStrengthColor,
        label: 'Sleep target',
        value: plan.sleepTarget.replaceAll('_', ' '),
      ),
      const SizedBox(height: 10),
      _PlanTile(
        icon: Icons.restaurant_rounded,
        color: AppColors.goalCardioColor,
        label: 'Meal tracking',
        value: plan.mealTracking ? 'Enabled' : 'Disabled',
      ),
      if (plan.recommendedHabits.isNotEmpty) ...[
        const SizedBox(height: 20),
        _HabitListSection(
          title: 'Recommended habits',
          items: plan.recommendedHabits,
        ),
      ],
      if (plan.milestones.isNotEmpty) ...[
        const SizedBox(height: 20),
        _ListSection(
          icon: Icons.flag_outlined,
          title: 'Milestones',
          items: plan.milestones,
        ),
      ],
      const SizedBox(height: 20),
      _InfoBanner(),
      // Bottom padding so content clears the fixed action bar.
      const SizedBox(height: 140),
    ];

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  for (var i = 0; i < sections.length; i++)
                    StaggerFadeIn(index: i, child: sections[i]),
                ]),
              ),
            ),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _BottomActionBar(
            accepting: _accepting,
            onAccept: _accept,
            onRegenerate: () => ref.invalidate(aiPlanGenerationProvider),
            onCustomize: () => _showCustomizeSheet(context, ref, plan),
          ),
        ),
      ],
    );
  }

  void _showCustomizeSheet(BuildContext context, WidgetRef ref, AiPlan plan) {
    final waterCtrl = TextEditingController(text: plan.waterTarget.toString());
    final stepCtrl = TextEditingController(text: plan.stepTarget.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text('Customize plan', style: AppTypography.h3),
                const SizedBox(height: 20),
                TextField(
                  controller: waterCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Water target (ml)',
                    prefixIcon: const Icon(Icons.water_drop_rounded, size: 20),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: stepCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Step target',
                    prefixIcon:
                        const Icon(Icons.directions_walk_rounded, size: 20),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () async {
                    final water =
                        int.tryParse(waterCtrl.text) ?? plan.waterTarget;
                    final steps =
                        int.tryParse(stepCtrl.text) ?? plan.stepTarget;
                    await ref
                        .read(aiPlanControllerProvider.notifier)
                        .acceptPlan(
                          plan.copyWith(waterTarget: water, stepTarget: steps),
                        );
                    if (ctx.mounted) Navigator.of(ctx).pop();
                    if (context.mounted) context.go(AppRoutes.bottomNavbar);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.steps,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Save & accept'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Hero header
// ---------------------------------------------------------------------------

class _HeroHeader extends StatelessWidget {
  final AiPlan plan;
  const _HeroHeader({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.steps,
            AppColors.steps.withValues(alpha: 0.78),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'AI-GENERATED PLAN',
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Your plan is ready',
            style: AppTypography.displayMedium.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            'Built around your goals, activity, and diet.',
            style: AppTypography.body.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Target stat grid — replaces stacked water/step tiles with a 2-up grid
// ---------------------------------------------------------------------------

class _TargetStatGrid extends StatelessWidget {
  final AiPlan plan;
  const _TargetStatGrid({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.water_drop_rounded,
            color: AppColors.goalCardioColor,
            label: 'Water',
            value: '${plan.waterTarget}',
            unit: 'ml/day',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.directions_walk_rounded,
            color: AppColors.goalStepsColor,
            label: 'Steps',
            value: '${plan.stepTarget}',
            unit: '/day',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String unit;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: value, style: AppTypography.h2),
                TextSpan(text: ' $unit', style: AppTypography.labelSmall),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTypography.bodySmall),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Generic plan tile (sleep / meal tracking)
// ---------------------------------------------------------------------------

class _PlanTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _PlanTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: AppTypography.body)),
          Text(value, style: AppTypography.labelLarge),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// List sections
// ---------------------------------------------------------------------------

class _ListSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> items;

  const _ListSection({
    required this.icon,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.h4),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, size: 18, color: AppColors.steps),
                    const SizedBox(width: 10),
                    Expanded(child: Text(item, style: AppTypography.body)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _HabitListSection extends StatelessWidget {
  final String title;
  final List<String> items;

  const _HabitListSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.h4),
          const SizedBox(height: 12),
          ...items.map((item) {
            final proofType = inferProofType(item);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_outline_rounded,
                      size: 18, color: AppColors.steps),
                  const SizedBox(width: 10),
                  Expanded(child: Text(item, style: AppTypography.body)),
                  if (proofType != HabitProofType.none)
                    Icon(
                      proofType == HabitProofType.photo
                          ? Icons.camera_alt_rounded
                          : Icons.local_drink_rounded,
                      size: 16,
                      color: AppColors.goalCardioColor,
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Info banner
// ---------------------------------------------------------------------------

class _InfoBanner extends StatelessWidget {
  const _InfoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.steps.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.steps.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: AppColors.steps),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Habits marked with a camera or water icon will ask for a '
              'quick photo or glass count when you complete them — '
              'everything else is a simple tap.',
              style: AppTypography.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Fixed bottom action bar — replaces the three stacked inline buttons
// ---------------------------------------------------------------------------

class _BottomActionBar extends StatelessWidget {
  final bool accepting;
  final VoidCallback onAccept;
  final VoidCallback onRegenerate;
  final VoidCallback onCustomize;

  const _BottomActionBar({
    required this.accepting,
    required this.onAccept,
    required this.onRegenerate,
    required this.onCustomize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: accepting ? null : onAccept,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.steps,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: accepting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Accept plan',
                              style: AppTypography.labelLarge
                                  .copyWith(color: Colors.white)),
                          const SizedBox(width: 6),
                          const Icon(Icons.check_rounded,
                              size: 18, color: Colors.white),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 10),
            // Row(
            //   children: [
            //     Expanded(
            //       child: OutlinedButton(
            //         onPressed: accepting ? null : onRegenerate,
            //         style: OutlinedButton.styleFrom(
            //           minimumSize: const Size.fromHeight(46),
            //           side: BorderSide(color: Colors.grey.shade300),
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(14),
            //           ),
            //         ),
            //         child: Row(
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           children: [
            //             const Icon(Icons.refresh_rounded,
            //                 size: 16, color: AppColors.steps),
            //             const SizedBox(width: 6),
            //             Text('Regenerate',
            //                 style: AppTypography.bodySmall
            //                     .copyWith(color: AppColors.steps)),
            //           ],
            //         ),
            //       ),
            //     ),
            //     const SizedBox(width: 10),
            //     Expanded(
            //       child: TextButton(
            //         onPressed: accepting ? null : onCustomize,
            //         style: TextButton.styleFrom(
            //           minimumSize: const Size.fromHeight(46),
            //         ),
            //         child: Text('Customize', style: AppTypography.bodySmall),
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Weekly schedule (unchanged logic, restyled to AppColors/AppTypography)
// ---------------------------------------------------------------------------

class _WeeklyScheduleSection extends StatefulWidget {
  final List<DailyWorkout> schedule;
  const _WeeklyScheduleSection({required this.schedule});

  @override
  State<_WeeklyScheduleSection> createState() => _WeeklyScheduleSectionState();
}

class _WeeklyScheduleSectionState extends State<_WeeklyScheduleSection> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    final todayName = const [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ][DateTime.now().weekday - 1];
    final idx = widget.schedule.indexWhere((d) => d.day == todayName);
    _selectedIndex = idx == -1 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.schedule[_selectedIndex];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly schedule', style: AppTypography.h4),
          const SizedBox(height: 14),
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.schedule.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final day = widget.schedule[i];
                final isSelected = i == _selectedIndex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 52,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.steps
                          : day.isRestDay
                              ? Colors.grey.shade100
                              : AppColors.steps.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          day.day.substring(0, 3).toUpperCase(),
                          style: AppTypography.labelSmall.copyWith(
                            color: isSelected
                                ? Colors.white
                                : day.isRestDay
                                    ? Colors.grey.shade500
                                    : AppColors.steps,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Icon(
                          day.isRestDay
                              ? Icons.self_improvement_rounded
                              : Icons.fitness_center_rounded,
                          size: 16,
                          color: isSelected
                              ? Colors.white
                              : day.isRestDay
                                  ? Colors.grey.shade400
                                  : AppColors.steps,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          if (selected.isRestDay)
            Row(
              children: [
                Icon(Icons.self_improvement_rounded,
                    size: 18, color: Colors.grey.shade500),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Rest day — recovery is part of the plan.',
                    style: AppTypography.body,
                  ),
                ),
              ],
            )
          else ...[
            if (selected.focus != null) ...[
              Text(
                selected.focus!,
                style:
                    AppTypography.labelLarge.copyWith(color: AppColors.steps),
              ),
              const SizedBox(height: 10),
            ],
            ...selected.exercises.map((e) => _ExerciseRow(exercise: e)),
          ],
        ],
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  final ExerciseItem exercise;
  const _ExerciseRow({required this.exercise});

  Color get _categoryColor {
    switch (exercise.category) {
      case ExerciseCategory.cardio:
        return AppColors.goalCardioColor;
      case ExerciseCategory.mobility:
        return AppColors.goalStrengthColor;
      case ExerciseCategory.strength:
        return AppColors.calories;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration:
                BoxDecoration(color: _categoryColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(exercise.name, style: AppTypography.body)),
          Text(exercise.sets, style: AppTypography.bodySmall),
        ],
      ),
    );
  }
}
