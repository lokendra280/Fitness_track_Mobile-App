import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/theme/app_theme.dart';
import 'package:habitflow/features/steps/controller/step_count_controller.dart';
import 'package:habitflow/features/steps/models/step_counter_summery.dart';
import 'package:habitflow/features/steps/ui/step_count_provider.dart';

class StepCounterScreen extends ConsumerStatefulWidget {
  const StepCounterScreen({super.key});

  @override
  ConsumerState<StepCounterScreen> createState() => _StepCounterScreenState();
}

class _StepCounterScreenState extends ConsumerState<StepCounterScreen> {
  DateTime _selectedDate = DateTime.now();

  void _changeDay(int delta) {
    setState(() => _selectedDate = _selectedDate.add(Duration(days: delta)));
  }

  @override
  Widget build(BuildContext context) {
    final access = ref.watch(healthAccessProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Step Counter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: access.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorState(
          message: "Couldn't check Health permissions",
          onRetry: () => ref.read(healthAccessProvider.notifier).retry(),
        ),
        data: (status) {
          if (status != HealthAccessStatus.authorized) {
            return _permissionPromptFor(status);
          }
          return _buildDashboard();
        },
      ),
    );
  }

  Widget _buildDashboard() {
    final summaryAsync = ref.watch(stepsSummaryProvider(_selectedDate));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(stepsForDateProvider(_selectedDate));
        ref.invalidate(weeklyStepsProvider);
        ref.invalidate(stepsSummaryProvider(_selectedDate));
        await ref.read(stepsSummaryProvider(_selectedDate).future);
      },
      child: summaryAsync.when(
        loading: () => ListView(
          children: const [
            SizedBox(
                height: 200, child: Center(child: CircularProgressIndicator())),
          ],
        ),
        error: (e, _) => ListView(
          children: [
            _ErrorState(
              message: "Couldn't load your steps",
              onRetry: () =>
                  ref.invalidate(stepsSummaryProvider(_selectedDate)),
            ),
          ],
        ),
        data: (summary) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            _DateSelector(
              date: _selectedDate,
              onPrev: () => _changeDay(-1),
              onNext: () => _changeDay(1),
            ),
            const SizedBox(height: 20),
            _StepsRingCard(summary: summary),
            const SizedBox(height: 16),
            _QuickStatsRow(summary: summary),
            const SizedBox(height: 16),
            _DailyProgressCard(summary: summary),
            const SizedBox(height: 16),
            _WeeklyStepsCard(summary: summary),
            const SizedBox(height: 16),
            const _AchievementBanner(),
          ],
        ),
      ),
    );
  }

  Widget _permissionPromptFor(HealthAccessStatus status) {
    final controller = ref.read(stepCountControllerProvider);

    switch (status) {
      case HealthAccessStatus.healthConnectNotInstalled:
        return _PermissionPrompt(
          icon: Icons.download_rounded,
          title: 'Health Connect required',
          message:
              'Install Health Connect from the Play Store to track your steps.',
          actionLabel: 'Install',
          onAction: () async {
            await controller.openHealthConnectInstall();
          },
        );
      case HealthAccessStatus.activityRecognitionDenied:
      case HealthAccessStatus.denied:
        return _PermissionPrompt(
          icon: Icons.directions_walk_rounded,
          title: 'Permission needed',
          message:
              'We need access to your step data to show your daily progress.',
          actionLabel: 'Grant access',
          onAction: () => ref.read(healthAccessProvider.notifier).retry(),
        );
      case HealthAccessStatus.unavailable:
        return _PermissionPrompt(
          icon: Icons.error_outline_rounded,
          title: "Can't access step data",
          message: 'This device doesn\'t support health tracking.',
          actionLabel: 'Retry',
          onAction: () => ref.read(healthAccessProvider.notifier).retry(),
        );
      case HealthAccessStatus.authorized:
        return const SizedBox.shrink(); // unreachable here
    }
  }
}

// ---------------------------------------------------------------------------
// Permission prompt
// ---------------------------------------------------------------------------

class _PermissionPrompt extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _PermissionPrompt({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.stepsBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.steps, size: 32),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message,
                style: textTheme.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.steps,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Date selector
// ---------------------------------------------------------------------------

class _DateSelector extends StatelessWidget {
  final DateTime date;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _DateSelector(
      {required this.date, required this.onPrev, required this.onNext});

  String _label() {
    final today = DateTime.now();
    final isToday = date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
    const months = [
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
      'Dec',
    ];
    final formatted = '${months[date.month - 1]} ${date.day}, ${date.year}';
    return isToday ? 'Today, $formatted' : formatted;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded, color: AppColors.steps),
          onPressed: onPrev,
        ),
        Row(
          children: [
            const Icon(Icons.calendar_today_rounded,
                size: 16, color: AppColors.steps),
            const SizedBox(width: 8),
            Text(_label(),
                style: textTheme.titleMedium?.copyWith(color: AppColors.steps)),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded, color: AppColors.steps),
          onPressed: onNext,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Big ring card
// ---------------------------------------------------------------------------

class _StepsRingCard extends StatelessWidget {
  final StepsSummary summary;
  const _StepsRingCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: SizedBox(
            width: 260,
            height: 260,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(260, 260),
                  painter: _RingPainter(progress: summary.progress),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.directions_walk_rounded,
                        color: AppColors.steps, size: 30),
                    const SizedBox(height: 8),
                    Text(_formatNumber(summary.steps),
                        style: textTheme.displayLarge),
                    Text('steps', style: textTheme.bodyMedium),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: textTheme.bodyMedium,
                        children: [
                          const TextSpan(text: 'of '),
                          TextSpan(
                            text: '${_formatNumber(summary.goal)} goal',
                            style: const TextStyle(
                                color: AppColors.steps,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.stepsBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${summary.percent}%',
                        style: textTheme.titleMedium
                            ?.copyWith(color: AppColors.steps),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 14.0;
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.shortestSide - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = AppColors.stepsTrack
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = AppColors.steps
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    const startAngle = -1.5708;
    final sweep = 6.28319 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweep,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

String _formatNumber(int n) {
  final s = n.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i != 0 && (s.length - i) % 3 == 0) buffer.write(',');
    buffer.write(s[i]);
  }
  return buffer.toString();
}

// ---------------------------------------------------------------------------
// Quick stats row
// ---------------------------------------------------------------------------

class _QuickStatsRow extends StatelessWidget {
  final StepsSummary summary;
  const _QuickStatsRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    final h = summary.activeTime.inHours;
    final m = summary.activeTime.inMinutes % 60;
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.local_fire_department_rounded,
            value: '${summary.calories}',
            unit: 'kcal',
            label: 'Calories',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.place_rounded,
            value: summary.distanceKm.toStringAsFixed(1),
            unit: 'km',
            label: 'Distance',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.timer_outlined,
            value: '${h}h ${m}m',
            unit: '',
            label: 'Active Time',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String unit;
  final String label;

  const _StatCard(
      {required this.icon,
      required this.value,
      required this.unit,
      required this.label});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: AppColors.steps, size: 22),
            const SizedBox(height: 8),
            Text(value, style: textTheme.titleLarge),
            if (unit.isNotEmpty) Text(unit, style: textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              label,
              style: textTheme.labelMedium?.copyWith(
                  color: AppColors.steps, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Daily progress card
// ---------------------------------------------------------------------------

class _DailyProgressCard extends StatelessWidget {
  final StepsSummary summary;
  const _DailyProgressCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Daily Progress', style: textTheme.titleMedium),
                RichText(
                  text: TextSpan(
                    style: textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: _formatNumber(summary.steps),
                        style: const TextStyle(
                            color: AppColors.steps,
                            fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: ' / ${_formatNumber(summary.goal)} steps'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: summary.progress,
                      minHeight: 10,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation(AppColors.steps),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text('${summary.percent}%',
                    style:
                        textTheme.titleSmall?.copyWith(color: AppColors.steps)),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                      color: AppColors.stepsBg, shape: BoxShape.circle),
                  child: const Icon(Icons.directions_run_rounded,
                      size: 16, color: AppColors.steps),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style:
                          textTheme.bodyMedium?.copyWith(color: Colors.black87),
                      children: [
                        TextSpan(
                          text: '${_formatNumber(summary.remaining)} steps ',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const TextSpan(text: 'remaining to reach your goal'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Weekly steps bar chart
// ---------------------------------------------------------------------------

class _WeeklyStepsCard extends StatelessWidget {
  final StepsSummary summary;
  const _WeeklyStepsCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final days = summary.weekly.keys.toList();
    final values = summary.weekly.values.toList();
    const maxAxis = 12000.0;
    final today = DateTime.now();
    const weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final todayLabel = weekdayNames[today.weekday - 1];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Weekly Steps', style: textTheme.titleMedium),
                Text('Steps', style: textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 160,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 30,
                    height: 160,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        Text('12K',
                            style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text('8K',
                            style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text('4K',
                            style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text('0',
                            style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Stack(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            4,
                            (_) => Container(
                                height: 1, color: AppColors.chartGridline),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(days.length, (i) {
                              final isToday = days[i] == todayLabel;
                              final heightFraction =
                                  (values[i] / maxAxis).clamp(0.0, 1.0);
                              return _Bar(
                                heightFraction: heightFraction,
                                highlighted: isToday,
                                tooltip:
                                    isToday ? _formatNumber(values[i]) : null,
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 38),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: days
                    .map((d) => Text(d, style: textTheme.bodySmall))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double heightFraction;
  final bool highlighted;
  final String? tooltip;

  const _Bar(
      {required this.heightFraction, required this.highlighted, this.tooltip});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26,
      height: 160,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          if (tooltip != null)
            Positioned(
              top: -8,
              child: FractionalTranslation(
                translation: const Offset(0, -1),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: AppColors.steps,
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    tooltip!,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          FractionallySizedBox(
            heightFactor: heightFraction.clamp(0.03, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: highlighted ? AppColors.steps : AppColors.chartBarMuted,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Achievement banner
// ---------------------------------------------------------------------------

class _AchievementBanner extends StatelessWidget {
  const _AchievementBanner();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      color: AppColors.milestoneBg,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                  color: AppColors.steps, shape: BoxShape.circle),
              child: const Icon(Icons.emoji_events_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Great job! 👏', style: textTheme.titleSmall),
                  Text("You're doing awesome. Keep it up!",
                      style: textTheme.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 40, color: Colors.redAccent),
          const SizedBox(height: 12),
          Text(message),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
