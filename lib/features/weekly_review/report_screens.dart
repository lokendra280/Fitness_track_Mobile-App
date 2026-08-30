import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:habitflow/core/constants/app_topography.dart';
import 'package:habitflow/core/theme/app_theme.dart';
import 'package:habitflow/core/widgets/animated_common.dart';
import 'package:habitflow/data/repositories/journey_repository_provider.dart';
import 'package:habitflow/features/weekly_review/models/daily_headline.dart';
import 'package:habitflow/features/weekly_review/models/perodic_meters.dart';
import 'package:habitflow/features/weekly_review/providers/recovery_rate_provider.dart';
import 'providers/review_providers.dart';

enum ReportPeriod { daily, weekly, monthly }

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  ReportPeriod _period = ReportPeriod.daily;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Reports', style: AppTypography.h3),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: _PeriodToggle(
                value: _period,
                onChanged: (p) => setState(() => _period = p),
              ),
            ),
            Expanded(
              child: switch (_period) {
                ReportPeriod.daily => _DailyReviewBody(day: today),
                ReportPeriod.weekly => _WeeklyReviewBody(
                    weekStart: today.subtract(const Duration(days: 7)),
                    today: today,
                  ),
                ReportPeriod.monthly => _MonthlyReviewBody(
                    monthStart: today.subtract(const Duration(days: 30)),
                    today: today,
                  ),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodToggle extends StatelessWidget {
  final ReportPeriod value;
  final ValueChanged<ReportPeriod> onChanged;
  const _PeriodToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: ReportPeriod.values.map((p) {
          final selected = p == value;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  switch (p) {
                    ReportPeriod.daily => 'Daily',
                    ReportPeriod.weekly => 'Weekly',
                    ReportPeriod.monthly => 'Monthly',
                  },
                  textAlign: TextAlign.center,
                  style: AppTypography.labelLarge.copyWith(
                    color: selected ? Colors.black87 : Colors.grey.shade500,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared: info icon → explanation sheet
// ---------------------------------------------------------------------------

/// Small (?) icon that opens a bottom sheet explaining what a metric
/// means. Used next to chart titles and stat items whose meaning isn't
/// self-evident (recovery rate, consistency, etc).
class _InfoIconButton extends StatelessWidget {
  final String title;
  final String description;
  const _InfoIconButton({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (ctx) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Text(title, style: AppTypography.h3),
              const SizedBox(height: 10),
              Text(description, style: AppTypography.body),
            ],
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(Icons.help_outline_rounded,
            size: 16, color: Colors.grey.shade400),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Daily
// ---------------------------------------------------------------------------

class _DailyReviewBody extends ConsumerWidget {
  final DateTime day;
  const _DailyReviewBody({required this.day});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final headlineAsync = ref.watch(dailyHeadlineMetricsProvider(day));
    final trendAsync = ref.watch(dailyMetricsProvider(day));
    final review = ref.watch(dailyReviewProvider(day));

    if (headlineAsync.isLoading || trendAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (headlineAsync.hasError || trendAsync.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            "Couldn't load today's activity data.",
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge,
          ),
        ),
      );
    }
    final headline = headlineAsync.value!;
    final trendMetrics = trendAsync.value!;

    final sections = <Widget>[
      _DailyHeroHeader(headline: headline),
      const SizedBox(height: 20),
      _DailyStatGrid(headline: headline),
      const SizedBox(height: 28),
      Text('Last 7 days', style: AppTypography.h2),
      const SizedBox(height: 12),
      _TrendChartCard(
        title: 'Calories',
        values: trendMetrics.caloriesPerDay,
        color: AppColors.calories,
        unit: 'kcal',
      ),
      const SizedBox(height: 16),
      _TrendChartCard(
        title: 'Steps',
        values: trendMetrics.stepsPerDay,
        color: AppColors.goalStepsColor,
        unit: 'steps',
      ),
      const SizedBox(height: 16),
      _TrendChartCard(
        title: 'Water',
        values: trendMetrics.waterPerDay,
        color: AppColors.goalCardioColor,
        unit: 'ml',
      ),
      const SizedBox(height: 16),
      _TrendChartCard(
        title: 'Sleep',
        values: trendMetrics.sleepPerDay,
        color: AppColors.goalStrengthColor,
        unit: 'h',
      ),
      const SizedBox(height: 28),
      _AiAnalysisCard(review: review),
      const SizedBox(height: 24),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        for (var i = 0; i < sections.length; i++)
          StaggerFadeIn(index: i, child: sections[i]),
      ],
    );
  }
}

class _DailyHeroHeader extends StatelessWidget {
  final DailyHeadline headline;
  const _DailyHeroHeader({required this.headline});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.goalStepsColor,
            AppColors.goalStepsColor.withValues(alpha: 0.75),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'TODAY',
            style: AppTypography.labelSmall.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: headline.steps.toDouble()),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => Text(
              '${value.round()}',
              style: AppTypography.displayLarge.copyWith(color: Colors.white),
            ),
          ),
          Text(
            'of ${headline.stepGoal} steps goal',
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: headline.stepProgress),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.22),
                valueColor: const AlwaysStoppedAnimation(Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyStatGrid extends StatelessWidget {
  final DailyHeadline headline;
  const _DailyStatGrid({required this.headline});

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatItem(
        icon: Icons.local_fire_department_rounded,
        color: AppColors.calories,
        label: 'Calories',
        value: '${headline.calories.round()}',
        unit: 'kcal',
      ),
      _StatItem(
        icon: Icons.water_drop_rounded,
        color: AppColors.goalCardioColor,
        label: 'Water',
        value: '${headline.water}',
        unit: 'ml',
      ),
      _StatItem(
        icon: Icons.bedtime_rounded,
        color: AppColors.goalStrengthColor,
        label: 'Sleep',
        value: headline.sleepHours.toStringAsFixed(1),
        unit: 'h',
      ),
      _StatItem(
        icon: Icons.fitness_center_rounded,
        color: AppColors.goalStepsColor,
        label: 'Workouts',
        value: '${headline.workoutCount}',
        unit: '',
      ),
      _StatItem(
        icon: Icons.directions_walk_rounded,
        color: AppColors.goalCardioColor,
        label: 'Steps',
        value: '${headline.steps}',
        unit: '',
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.9,
      children: items,
    );
  }
}

// ---------------------------------------------------------------------------
// Weekly
// ---------------------------------------------------------------------------

class _WeeklyReviewBody extends ConsumerWidget {
  final DateTime weekStart;
  final DateTime today;
  const _WeeklyReviewBody({required this.weekStart, required this.today});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(weeklyMetricsProvider(weekStart));
    final review = ref.watch(weeklyReviewProvider(weekStart));
    final recovery =
        ref.watch(recoveryRateProvider((start: weekStart, end: today)));

    return metricsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            "Couldn't load this week's data.",
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge,
          ),
        ),
      ),
      data: (metrics) => _PeriodicReviewBody(
        periodLabel: 'This week',
        metrics: metrics,
        review: review,
        recovery: recovery,
        showSleepTrend: true,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Monthly
// ---------------------------------------------------------------------------

class _MonthlyReviewBody extends ConsumerWidget {
  final DateTime monthStart;
  final DateTime today;
  const _MonthlyReviewBody({required this.monthStart, required this.today});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(monthlyMetricsProvider(monthStart));
    final review = ref.watch(monthlyReviewProvider(monthStart));
    final recovery =
        ref.watch(recoveryRateProvider((start: monthStart, end: today)));

    return metricsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            "Couldn't load this month's data.",
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge,
          ),
        ),
      ),
      data: (metrics) => _PeriodicReviewBody(
        periodLabel: 'Last 30 days',
        metrics: metrics,
        review: review,
        recovery: recovery,
        showSleepTrend: false,
      ),
    );
  }
}

class _PeriodicReviewBody extends StatelessWidget {
  const _PeriodicReviewBody({
    required this.periodLabel,
    required this.metrics,
    required this.review,
    required this.recovery,
    required this.showSleepTrend,
  });

  final String periodLabel;
  final PeriodMetrics metrics;
  final AsyncValue<String> review;
  final RecoveryRateSeries recovery;
  final bool showSleepTrend;

  @override
  Widget build(BuildContext context) {
    final sections = <Widget>[
      _HeroHeader(periodLabel: periodLabel, metrics: metrics),
      const SizedBox(height: 20),
      _StatGrid(metrics: metrics, recoveryAvg: recovery.average),
      const SizedBox(height: 28),
      Row(
        children: [
          Text('Trends', style: AppTypography.h2),
          const SizedBox(width: 4),
          _InfoIconButton(
            title: 'Trends',
            description:
                'Daily values over this period for the metrics you track. '
                'Use these to spot patterns — e.g. steps dropping on '
                'weekends, or water intake trailing off later in the week.',
          ),
        ],
      ),
      const SizedBox(height: 12),
      _TrendChartCard(
        title: 'Recovery rate',
        values: recovery.valuesPerDay,
        color: AppColors.goalStrengthColor,
        unit: '%',
        infoText: 'A combined score (0-100%) of two things: how much of your '
            'weight goal you\'ve closed so far, and how consistently '
            'you\'ve completed your planned exercises each day. Rest days '
            'count as fully compliant. It\'s meant as a single at-a-glance '
            'read on how "on track" you are — not a medical or '
            'physiological measure of recovery.',
      ),
      const SizedBox(height: 16),
      _TrendChartCard(
        title: 'Calories',
        values: metrics.caloriesPerDay,
        color: AppColors.calories,
        unit: 'kcal',
      ),
      const SizedBox(height: 16),
      _TrendChartCard(
        title: 'Steps',
        values: metrics.stepsPerDay,
        color: AppColors.goalStepsColor,
        unit: 'steps',
      ),
      const SizedBox(height: 16),
      _TrendChartCard(
        title: 'Water',
        values: metrics.waterPerDay,
        color: AppColors.goalCardioColor,
        unit: 'ml',
      ),
      if (showSleepTrend) ...[
        const SizedBox(height: 16),
        _TrendChartCard(
          title: 'Sleep',
          values: metrics.sleepPerDay,
          color: AppColors.goalStrengthColor,
          unit: 'h',
        ),
      ],
      const SizedBox(height: 28),
      _AiAnalysisCard(review: review),
      const SizedBox(height: 24),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        for (var i = 0; i < sections.length; i++)
          StaggerFadeIn(index: i, child: sections[i]),
      ],
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.periodLabel, required this.metrics});

  final String periodLabel;
  final PeriodMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.goalStepsColor,
            AppColors.goalStepsColor.withValues(alpha: 0.75),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  periodLabel.toUpperCase(),
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 6),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: metrics.avgSteps),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => Text(
                    '${value.round()}',
                    style: AppTypography.displayLarge
                        .copyWith(color: Colors.white),
                  ),
                ),
                Text(
                  'avg steps / day',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.metrics, required this.recoveryAvg});

  final PeriodMetrics metrics;
  final double recoveryAvg;

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatItem(
        icon: Icons.local_fire_department_rounded,
        color: AppColors.calories,
        label: 'Avg calories',
        value: '${metrics.avgCalories.round()}',
        unit: 'kcal',
      ),
      _StatItem(
        icon: Icons.water_drop_rounded,
        color: AppColors.goalCardioColor,
        label: 'Avg water',
        value: '${metrics.avgWater.round()}',
        unit: 'ml',
      ),
      _StatItem(
        icon: Icons.bedtime_rounded,
        color: AppColors.goalStrengthColor,
        label: 'Avg sleep',
        value: metrics.avgSleep.toStringAsFixed(1),
        unit: 'h',
      ),
      _StatItem(
        icon: Icons.fitness_center_rounded,
        color: AppColors.goalStepsColor,
        label: 'Workouts',
        value: '${metrics.workoutCount}',
        unit: '',
      ),
      _StatItem(
        icon: Icons.checklist_rounded,
        color: AppColors.goalCardioColor,
        label: 'Consistency',
        value: '${(metrics.habitConsistency * 100).round()}',
        unit: '%',
        infoText: 'Percentage of your tracked habits you completed, averaged '
            'across this period.',
      ),
      _StatItem(
        icon: Icons.favorite_rounded,
        color: AppColors.goalStrengthColor,
        label: 'Recovery rate',
        value: '${recoveryAvg.round()}',
        unit: '%',
        infoText: 'A combined score of weight-goal progress and exercise '
            'compliance, averaged across this period. See the chart '
            'below for the day-by-day breakdown.',
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.9,
      children: items,
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.unit,
    this.infoText,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String unit;
  final String? infoText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        label,
                        style: AppTypography.labelSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (infoText != null)
                      _InfoIconButton(title: label, description: infoText!),
                  ],
                ),
                const SizedBox(height: 1),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        value,
                        style: AppTypography.h4
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                      if (unit.isNotEmpty) ...[
                        const SizedBox(width: 2),
                        Text(unit, style: AppTypography.labelSmall),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendChartCard extends StatelessWidget {
  const _TrendChartCard({
    required this.title,
    required this.values,
    required this.color,
    required this.unit,
    this.infoText,
  });

  final String title;
  final List<double> values;
  final Color color;
  final String unit;
  final String? infoText;

  @override
  Widget build(BuildContext context) {
    final maxVal =
        values.isEmpty ? 1.0 : values.reduce((a, b) => a > b ? a : b);
    final avg =
        values.isEmpty ? 0.0 : values.reduce((a, b) => a + b) / values.length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(title, style: AppTypography.h4),
                  if (infoText != null)
                    _InfoIconButton(title: title, description: infoText!),
                ],
              ),
              Text(
                'avg ${avg.toStringAsFixed(avg >= 100 ? 0 : 1)} $unit',
                style: AppTypography.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: values.isEmpty
                ? Center(
                    child: Text('No data yet', style: AppTypography.bodySmall))
                : LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      minY: 0,
                      maxY: maxVal * 1.15,
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) => color,
                          getTooltipItems: (spots) => spots
                              .map((s) => LineTooltipItem(
                                    '${s.y.round()} $unit',
                                    AppTypography.labelSmall
                                        .copyWith(color: Colors.white),
                                  ))
                              .toList(),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            for (var i = 0; i < values.length; i++)
                              FlSpot(i.toDouble(), values[i]),
                          ],
                          isCurved: true,
                          curveSmoothness: 0.35,
                          color: color,
                          barWidth: 3,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                color.withValues(alpha: 0.25),
                                color.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                  ),
          ),
        ],
      ),
    );
  }
}

class _AiAnalysisCard extends StatelessWidget {
  const _AiAnalysisCard({required this.review});

  final AsyncValue<String> review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.goalStepsColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(24),
        border:
            Border.all(color: AppColors.goalStepsColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.goalStepsColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Text('AI coach analysis', style: AppTypography.h4),
            ],
          ),
          const SizedBox(height: 14),
          review.when(
            loading: () => const _AnalysisLoading(),
            error: (e, _) => Text(
              'Could not load your analysis right now.',
              style: AppTypography.bodySmall,
            ),
            data: (text) => AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(
                text,
                key: ValueKey(text),
                style: AppTypography.body,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalysisLoading extends StatefulWidget {
  const _AnalysisLoading();

  @override
  State<_AnalysisLoading> createState() => _AnalysisLoadingState();
}

class _AnalysisLoadingState extends State<_AnalysisLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = (_controller.value - i * 0.15) % 1.0;
              final opacity =
                  (0.3 + 0.4 * (1 - (t - 0.5).abs() * 2)).clamp(0.3, 0.7);
              return Container(
                height: 12,
                width: i == 2 ? 140 : double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.goalStepsColor.withValues(alpha: opacity),
                  borderRadius: BorderRadius.circular(6),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
