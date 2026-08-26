import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/constants/app_topography.dart';
import 'package:habitflow/core/theme/app_theme.dart';
import 'package:habitflow/data/repositories/journey_repository_provider.dart';

/// Statistics screen matching the reference design: activity filter
/// chips, a week-range header, a stat summary row, a smooth curved trend
/// chart with a peak callout, and a monthly intensity bar chart below.
class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  String _selectedActivity = 'Steps';

  static const _activities = ['Steps', 'Water', 'Workouts', 'Sleep'];

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(journeyRepositoryProvider);
    final today = DateTime.now();

    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    final weekly = List<double>.generate(7, (i) {
      final d = weekStart.add(Duration(days: i));
      return _valueFor(repo, _selectedActivity, d);
    });

    final monthly = List<double>.generate(30, (i) {
      final d = today.subtract(Duration(days: 29 - i));
      return _valueFor(repo, _selectedActivity, d);
    });

    final weeklyTotal = weekly.fold<double>(0, (a, b) => a + b);
    final weeklyAvgPerDay = weeklyTotal / 7;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _RoundIconButton(icon: Icons.map_outlined, onTap: () {}),
                Text('Statistics', style: AppTypography.h2),
                _RoundIconButton(icon: Icons.settings_outlined, onTap: () {}),
              ],
            ),
            const SizedBox(height: 20),
            _ActivityFilterChips(
              activities: _activities,
              selected: _selectedActivity,
              onSelected: (a) => setState(() => _selectedActivity = a),
            ),
            const SizedBox(height: 24),
            Text(
              'Week ${_formatShort(weekStart)} — ${_formatShort(weekEnd)}',
              style: AppTypography.h3,
            ),
            const SizedBox(height: 12),
            _StatSummaryRow(
              activity: _selectedActivity,
              weeklyTotal: weeklyTotal,
              weeklyAvgPerDay: weeklyAvgPerDay,
              bestDayValue:
                  weekly.isEmpty ? 0 : weekly.reduce((a, b) => a > b ? a : b),
            ),
            const SizedBox(height: 20),
            _CurvedTrendChart(
              values: weekly,
              startLabel: _formatMonthShort(weekStart),
              endLabel: _formatMonthShort(weekEnd),
              unit: _unitFor(_selectedActivity),
              color: AppColors.calories,
            ),
            const SizedBox(height: 32),
            Text('Monthly intensity', style: AppTypography.h2),
            const SizedBox(height: 4),
            Text('Your total training time', style: AppTypography.bodySmall),
            const SizedBox(height: 16),
            _MonthlyIntensityChart(values: monthly, color: AppColors.calories),
          ],
        ),
      ),
    );
  }

  double _valueFor(dynamic repo, String activity, DateTime date) {
    switch (activity) {
      case 'Water':
        return (repo.waterFor(date) as int).toDouble();
      case 'Workouts':
        return (repo.workoutsFor(date) as List).length.toDouble();
      case 'Sleep':
        return (repo.sleepFor(date)?.hours as double?) ?? 0.0;
      case 'Steps':
      default:
        return (repo.stepsFor(date) as int).toDouble();
    }
  }

  String _unitFor(String activity) {
    switch (activity) {
      case 'Water':
        return 'ml';
      case 'Workouts':
        return '';
      case 'Sleep':
        return 'h';
      case 'Steps':
      default:
        return 'steps';
    }
  }

  String _formatShort(DateTime d) {
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
    return '${d.day} ${months[d.month - 1]}.';
  }

  String _formatMonthShort(DateTime d) {
    const months = [
      'Jan.',
      'Feb.',
      'Mar.',
      'Apr.',
      'May.',
      'Jun.',
      'Jul.',
      'Aug.',
      'Sept.',
      'Oct.',
      'Nov.',
      'Dec.',
    ];
    return months[d.month - 1];
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceMuted,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 18, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _ActivityFilterChips extends StatelessWidget {
  const _ActivityFilterChips({
    required this.activities,
    required this.selected,
    required this.onSelected,
  });

  final List<String> activities;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final activity in activities) ...[
            _Chip(
              label: activity,
              isSelected: activity == selected,
              onTap: () => onSelected(activity),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.textPrimary : AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Text(
            label,
            style: AppTypography.labelLarge.copyWith(
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatSummaryRow extends StatelessWidget {
  const _StatSummaryRow({
    required this.activity,
    required this.weeklyTotal,
    required this.weeklyAvgPerDay,
    required this.bestDayValue,
  });

  final String activity;
  final double weeklyTotal;
  final double weeklyAvgPerDay;
  final double bestDayValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatColumn(label: 'Total', value: _formatTotal()),
        const SizedBox(width: 28),
        _StatColumn(label: 'Daily avg', value: _formatAvg()),
        const SizedBox(width: 28),
        _StatColumn(label: 'Best day', value: _formatBest()),
      ],
    );
  }

  String _formatTotal() {
    switch (activity) {
      case 'Water':
        return '${(weeklyTotal / 1000).toStringAsFixed(1)} L';
      case 'Sleep':
        return '${weeklyTotal.toStringAsFixed(1)} h';
      case 'Workouts':
        return weeklyTotal.toStringAsFixed(0);
      case 'Steps':
      default:
        return weeklyTotal >= 1000
            ? '${(weeklyTotal / 1000).toStringAsFixed(1)}k'
            : weeklyTotal.toStringAsFixed(0);
    }
  }

  String _formatAvg() {
    switch (activity) {
      case 'Water':
        return '${(weeklyAvgPerDay / 1000).toStringAsFixed(1)} L/d';
      case 'Sleep':
        return '${weeklyAvgPerDay.toStringAsFixed(1)} h/d';
      case 'Workouts':
        return weeklyAvgPerDay.toStringAsFixed(1);
      case 'Steps':
      default:
        return weeklyAvgPerDay >= 1000
            ? '${(weeklyAvgPerDay / 1000).toStringAsFixed(1)}k'
            : weeklyAvgPerDay.toStringAsFixed(0);
    }
  }

  String _formatBest() {
    switch (activity) {
      case 'Water':
        return '${(bestDayValue / 1000).toStringAsFixed(1)} L';
      case 'Sleep':
        return '${bestDayValue.toStringAsFixed(1)} h';
      case 'Workouts':
        return bestDayValue.toStringAsFixed(0);
      case 'Steps':
      default:
        return bestDayValue >= 1000
            ? '${(bestDayValue / 1000).toStringAsFixed(1)}k'
            : bestDayValue.toStringAsFixed(0);
    }
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelSmall),
        const SizedBox(height: 2),
        Text(value, style: AppTypography.h4),
      ],
    );
  }
}

class _CurvedTrendChart extends StatefulWidget {
  const _CurvedTrendChart({
    required this.values,
    required this.startLabel,
    required this.endLabel,
    required this.unit,
    required this.color,
  });

  final List<double> values;
  final String startLabel;
  final String endLabel;
  final String unit;
  final Color color;

  @override
  State<_CurvedTrendChart> createState() => _CurvedTrendChartState();
}

class _CurvedTrendChartState extends State<_CurvedTrendChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _progress =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.values.isEmpty) {
      return const SizedBox(height: 220);
    }

    final maxVal =
        widget.values.reduce((a, b) => a > b ? a : b).clamp(1, double.infinity);
    var peakIndex = 0;
    for (var i = 1; i < widget.values.length; i++) {
      if (widget.values[i] > widget.values[peakIndex]) peakIndex = i;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 180,
            width: double.infinity,
            child: AnimatedBuilder(
              animation: _progress,
              builder: (context, _) => CustomPaint(
                painter: _CurvedChartPainter(
                  values: widget.values,
                  maxVal: maxVal.toDouble(),
                  color: widget.color,
                  progress: _progress.value,
                  peakIndex: peakIndex,
                ),
                child: _PeakCallout(
                  values: widget.values,
                  maxVal: maxVal.toDouble(),
                  peakIndex: peakIndex,
                  progress: _progress.value,
                  unit: widget.unit,
                  color: widget.color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.startLabel, style: AppTypography.labelSmall),
              Text(widget.endLabel, style: AppTypography.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _PeakCallout extends StatelessWidget {
  const _PeakCallout({
    required this.values,
    required this.maxVal,
    required this.peakIndex,
    required this.progress,
    required this.unit,
    required this.color,
  });

  final List<double> values;
  final double maxVal;
  final int peakIndex;
  final double progress;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final revealThreshold =
        peakIndex / (values.length - 1).clamp(1, double.infinity);
    if (progress < revealThreshold) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final stepX = constraints.maxWidth /
            (values.length - 1).clamp(1, double.infinity);
        final x = peakIndex * stepX;
        final y = constraints.maxHeight -
            (values[peakIndex] / maxVal) * constraints.maxHeight;
        final peakValue = values[peakIndex];
        final valueLabel = unit == 'ml'
            ? '${(peakValue / 1000).toStringAsFixed(1)} L'
            : unit.isEmpty
                ? peakValue.toStringAsFixed(0)
                : '${peakValue.toStringAsFixed(0)} $unit';

        return Stack(
          children: [
            Positioned(
              left: (x - 40).clamp(0, constraints.maxWidth),
              top: (y - 40).clamp(0, constraints.maxHeight),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  valueLabel,
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CurvedChartPainter extends CustomPainter {
  _CurvedChartPainter({
    required this.values,
    required this.maxVal,
    required this.color,
    required this.progress,
    required this.peakIndex,
  });

  final List<double> values;
  final double maxVal;
  final Color color;
  final double progress;
  final int peakIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final stepX = size.width / (values.length - 1);
    final points = <Offset>[
      for (var i = 0; i < values.length; i++)
        Offset(i * stepX, size.height - (values[i] / maxVal) * size.height),
    ];

    final fullPath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlOffset = (p1.dx - p0.dx) * 0.5;
      fullPath.cubicTo(
        p0.dx + controlOffset,
        p0.dy,
        p1.dx - controlOffset,
        p1.dy,
        p1.dx,
        p1.dy,
      );
    }

    final metrics = fullPath.computeMetrics().toList();
    final animatedPath = Path();
    for (final metric in metrics) {
      animatedPath.addPath(
        metric.extractPath(0, metric.length * progress),
        Offset.zero,
      );
    }

    canvas.drawPath(
      animatedPath,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    if (metrics.isNotEmpty) {
      final fillPath = Path.from(animatedPath);
      final lastMetric = metrics.last;
      final endPos = lastMetric
              .getTangentForOffset(lastMetric.length * progress)
              ?.position ??
          points.last;
      fillPath
        ..lineTo(endPos.dx, size.height)
        ..lineTo(points.first.dx, size.height)
        ..close();
      canvas.drawPath(
        fillPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: 0.25),
              color.withValues(alpha: 0.0),
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
      );
    }

    for (var i = 0; i < points.length; i++) {
      final visible = i / (points.length - 1) <= progress + 0.001;
      if (!visible) continue;

      final isPeak = i == peakIndex;
      if (isPeak) {
        _drawDashedLine(
          canvas,
          Offset(points[i].dx, points[i].dy),
          Offset(points[i].dx, size.height),
          color,
        );
      }
      canvas.drawCircle(
          points[i], isPeak ? 5 : 3.5, Paint()..color = Colors.white);
      canvas.drawCircle(
        points[i],
        isPeak ? 5 : 3.5,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Color color) {
    const dashWidth = 4.0;
    const dashSpace = 4.0;
    final totalDistance = (end.dy - start.dy).abs();
    var covered = 0.0;
    final paint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..strokeWidth = 1.5;

    while (covered < totalDistance) {
      final segmentStart = Offset(start.dx, start.dy + covered);
      final segmentEnd = Offset(
          start.dx, (start.dy + covered + dashWidth).clamp(start.dy, end.dy));
      canvas.drawLine(segmentStart, segmentEnd, paint);
      covered += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _CurvedChartPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.values != values;
}

class _MonthlyIntensityChart extends StatelessWidget {
  const _MonthlyIntensityChart({required this.values, required this.color});

  final List<double> values;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox(height: 140);

    final maxVal =
        values.reduce((a, b) => a > b ? a : b).clamp(1, double.infinity);
    var peakIndex = 0;
    for (var i = 1; i < values.length; i++) {
      if (values[i] > values[peakIndex]) peakIndex = i;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 24, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(24),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final barAreaWidth = constraints.maxWidth;
          final peakX = (peakIndex / values.length) * barAreaWidth;

          return SizedBox(
            height: 130,
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(values.length, (i) {
                    final heightFraction = values[i] / maxVal;
                    final isPeak = i == peakIndex;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1.5),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(
                              begin: 0, end: heightFraction.clamp(0.02, 1)),
                          duration: Duration(milliseconds: 500 + i * 15),
                          curve: Curves.easeOutCubic,
                          builder: (_, t, __) => Container(
                            height: 90 * t,
                            decoration: BoxDecoration(
                              color:
                                  isPeak ? color : color.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                Positioned(
                  left: (peakX - 14).clamp(0, barAreaWidth),
                  top: 0,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      values[peakIndex].toStringAsFixed(0),
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
