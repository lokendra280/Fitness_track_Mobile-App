import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/constants/constant_assets.dart';
import 'package:habitflow/core/constants/size_constant.dart';
import 'package:habitflow/features/dashboard/screens/widgets/ai_insight_card.dart';
import 'package:habitflow/features/dashboard/screens/widgets/greeting_header.dart';
import 'package:habitflow/features/dashboard/screens/widgets/journey_card.dart';
import 'package:habitflow/features/dashboard/screens/widgets/log_weight_sheet.dart';
import 'package:habitflow/features/dashboard/screens/widgets/metric_progress_row.dart';
import 'package:habitflow/features/dashboard/screens/widgets/personal_workout_card.dart';
import 'package:habitflow/features/dashboard/screens/widgets/quick_actions_grid.dart';
import 'package:habitflow/features/dashboard/screens/widgets/today_calendar_strip.dart';
import 'package:habitflow/features/dashboard/screens/widgets/weekly_goals_row.dart';
import 'package:habitflow/features/steps/ui/step_count_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/animated_common.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/models/dashboard_data.dart';
import '../../../data/models/dashboard_ui_models.dart';
import '../providers/dashboard_providers.dart';

/// "Home Dashboard" screen — matches the first reference mock, wired to
/// the real dashboardDataProvider.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  /// dashboardDataProvider only exposes progress ratios + a couple of
  /// targets, so the four rows are built here rather than stored on the
  /// model itself.
  List<ProgressMetric> _metrics(DashboardData data, int realSteps) {
    final waterCurrent = (data.waterProgress * data.waterTarget).round();
    final stepsProgress = (realSteps / data.stepTarget).clamp(0.0, 1.0);
    return [
      ProgressMetric(
        label: 'Calories',
        valueLabel: '${(data.calorieProgress * 100).round()}% of daily goal',
        progress: data.calorieProgress,
        icon: Icons.local_fire_department,
        color: AppColors.calories,
        background: AppColors.caloriesBg,
      ),
      ProgressMetric(
        label: 'Water',
        valueLabel: '$waterCurrent / ${data.waterTarget} ml',
        progress: data.waterProgress,
        icon: Icons.water_drop,
        color: AppColors.water,
        background: AppColors.waterBg,
      ),
      ProgressMetric(
        label: 'Steps',
        valueLabel: '$realSteps / ${data.stepTarget} steps',
        progress: stepsProgress,
        icon: Icons.directions_walk,
        color: AppColors.steps,
        background: AppColors.stepsBg,
      ),
      ProgressMetric(
        label: 'Sleep',
        valueLabel: '${(data.sleepProgress * 100).round()}% of 8h goal',
        progress: data.sleepProgress,
        icon: Icons.bedtime,
        color: AppColors.sleep,
        background: AppColors.sleepBg,
      ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(dashboardDataProvider);
    final realSteps = ref.watch(todayStepsProvider).valueOrNull ?? 0;
    final metrics = _metrics(data, realSteps);

    final sections = <Widget>[
      GreetingHeader(
        userName: '',
        notificationCount: 0,
        onNotificationsTap: () {
          context.go("/personal-profile");
        },
      ),
      const SizedBox(height: 20),
      const WeeklyGoalsRow(),
      SBC.lHM,
      TodayCalendarStrip(
        selectedDate: DateTime.now(),
        onDateSelected: (DateTime value) {},
      ),
      SBC.lHM,

      PersonalWorkoutCard(
        title: "Habits",
        completedCount: 2,
        totalCount: 10,
        onTap: () {
          context.push('/habits');
        },
        // backgroundImage: Image.asset(name),
      ),
      // JourneyCard(
      //   progress: data.progressPercentage ?? 0,
      //   currentWeight: data.currentWeight,
      //   targetWeight: data.targetWeight,
      //   weightLost: data.weightLost,
      //   daysRemaining: data.daysRemaining,
      //   streak: data.journeyStreak,
      //   remainingWeight: data.remainingWeight,
      //   onMenuTap: () {},
      // ),
      // const SizedBox(height: 24),
      // SectionHeader(
      //   title: "Today's progress",
      //   actionLabel: 'View all',
      //   onActionTap: () => ref.read(bottomNavIndexProvider.notifier).state = 1,
      // ),
      // const SizedBox(height: 8),
      // Card(
      //   child: Padding(
      //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      //     child: Column(
      //       children: [
      //         for (var i = 0; i < metrics.length; i++) ...[
      //           MetricProgressRow(metric: metrics[i]),
      //           if (i != metrics.length - 1) const Divider(height: 1),
      //         ],
      //       ],
      //     ),
      //   ),
      // ),
      SBC.lHM,

      // AiInsightCard(onTap: () => context.push('/weekly-review')),
      const SizedBox(height: 24),
      Text(
        'Quick actions',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 12),
      QuickActionsGrid(
        actions: [
          QuickAction(
              icon: Icons.monitor_weight,
              label: 'Add weight',
              onTap: () => showLogWeightSheet(context, ref)),
          QuickAction(
            icon: Icons.camera_alt,
            label: 'Scan food',
            onTap: () => context.push('/food'),
          ),
          // QuickAction(
          //   icon: Icons.camera_alt,
          //   label: 'Ai Plan',
          //   onTap: () => context.push('/activity'),
          // ),
          QuickAction(
            icon: Icons.single_bed_sharp,
            label: 'Sleep Track',
            onTap: () => context.push('/sleep'),
          ),
          // QuickAction(
          //   icon: Icons.boy_rounded,
          //   label: 'Body Progress',
          //   onTap: () => context.push('/body-progress'),
          // ),
          QuickAction(
              icon: Icons.water_drop,
              label: 'Add water',
              onTap: () => context.push('/water')),
          // QuickAction(
          //     icon: Icons.directions_run,
          //     label: 'Add workout',
          //     onTap: () => context.push('/activity')),
          QuickAction(
              icon: Icons.checklist,
              label: 'Habits',
              onTap: () => context.push('/habits')),
          // QuickAction(
          //     icon: Icons.checklist,
          //     label: 'Daily CheckIn',
          //     onTap: () => context.push('/check-in')),
          // QuickAction(
          //     icon: Icons.chat_bubble,
          //     label: 'Ask AI',
          //     onTap: () => context.push('/ai-coach')),
          // QuickAction(
          //   icon: Icons.emoji_events,
          //   label: 'Milestones',
          //   onTap: () => context.push('/milestones'),
          // ),
          // QuickAction(
          //   icon: Icons.email_sharp,
          //   label: "Journey Completion",
          //   onTap: () => context.push('/journey-completion'),
          // ),
          QuickAction(
            icon: Icons.email_sharp,
            label: "StepCounter",
            onTap: () => context.push('step-counter'),
          ),
          QuickAction(
            icon: Icons.more_horiz,
            label: 'Report',
            onTap: () => context.push('/reports'),
          ),
        ],
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          children: [
            for (var i = 0; i < sections.length; i++)
              StaggerFadeIn(index: i, child: sections[i]),
          ],
        ),
      ),
    );
  }
}
