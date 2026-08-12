import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/features/dashboard/screens/widgets/day_selector.dart';
import 'package:habitflow/features/dashboard/screens/widgets/habits_summary_card.dart';
import 'package:habitflow/features/dashboard/screens/widgets/log_weight_sheet.dart';
import 'package:habitflow/features/dashboard/screens/widgets/metric_progress_row.dart';
import 'package:habitflow/features/dashboard/screens/widgets/weight_chart_card.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/animated_common.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/models/dashboard_data.dart';
import '../../../data/models/dashboard_ui_models.dart';
import '../providers/dashboard_providers.dart';

/// "Today & Progress" screen — matches the second reference mock, wired to
/// the real dashboardDataProvider. The milestone and recent-entries
/// sections from the mock aren't shown yet: there's no provider for them
/// today, and it's better to leave them out than fake the data.
class TodayProgressScreen extends ConsumerWidget {
  const TodayProgressScreen({super.key});

  List<ProgressMetric> _metrics(DashboardData data) {
    final waterCurrent = (data.waterProgress * data.waterTarget).round();
    final stepsCurrent = (data.stepsProgress * data.stepTarget).round();
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
        valueLabel: '$stepsCurrent / ${data.stepTarget} steps',
        progress: data.stepsProgress,
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

  List<DayItem> _weekDays() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return List.generate(7, (i) {
      final d = monday.add(Duration(days: i));
      return DayItem(weekday: names[i], dayNumber: d.day);
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(dashboardDataProvider);
    final metrics = _metrics(data);
    final selectedDay = ref.watch(selectedDayIndexProvider);
    final days = _weekDays();

    final sections = <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Today', style: Theme.of(context).textTheme.headlineMedium),
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            elevation: 1,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {},
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.calendar_today_outlined),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      DaySelector(
        days: days,
        selectedIndex: selectedDay,
        onSelected: (i) =>
            ref.read(selectedDayIndexProvider.notifier).state = i,
      ),
      const SizedBox(height: 20),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: "Today's progress"),
              const SizedBox(height: 4),
              for (var i = 0; i < metrics.length; i++) ...[
                MetricProgressRow(metric: metrics[i]),
                if (i != metrics.length - 1) const Divider(height: 1),
              ],
            ],
          ),
        ),
      ),
      const SizedBox(height: 20),
      WeightChartCard(
        currentWeight: data.currentWeight,
        // No weight-history provider yet — card shows a graceful empty
        // state instead of a fabricated trend/chart.
        onAddTap: () => showLogWeightSheet(context, ref),
        changeVsYesterday: 0, history: [],
      ),
      const SizedBox(height: 20),
      HabitsSummaryCard(
        consistency: data.habitConsistency,
        onViewAll: () => context.push('/habits'),
        completed: 0,
        total: 0,
        week: [],
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            for (var i = 0; i < sections.length; i++)
              StaggerFadeIn(index: i, child: sections[i]),
          ],
        ),
      ),
    );
  }
}
