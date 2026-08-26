import 'package:flutter/material.dart';
import 'package:habitflow/core/constants/app_topography.dart';
import 'package:habitflow/core/theme/app_theme.dart';

class CurvedTrendChart extends StatefulWidget {
  const CurvedTrendChart({
    super.key,
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
  State<CurvedTrendChart> createState() => _CurvedTrendChartState();
}

class _CurvedTrendChartState extends State<CurvedTrendChart>
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
          Text(_axisLabel(maxVal.toDouble()), style: AppTypography.labelSmall),
          const SizedBox(height: 8),
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

  String _axisLabel(double maxVal) {
    if (widget.unit == 'ml') return 'L';
    if (widget.unit.isEmpty) return '';
    return widget.unit;
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
    // Only show the callout once the line has drawn far enough to reach
    // the peak point, so it doesn't appear before the line gets there.
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
              left: x - 40,
              top: (y - 40).clamp(0, double.infinity),
              child: AnimatedOpacity(
                opacity: 1,
                duration: const Duration(milliseconds: 200),
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

    // Smooth curve through points using cubic Bezier segments between
    // each pair, with control points offset horizontally — a simple
    // Catmull-Rom-ish smoothing without extra dependencies.
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

    // Clip the path to only the animated-in portion for a "drawing" effect.
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

    // Gradient fill under the animated line.
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
              color.withValues(alpha: 0.0)
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
      );
    }

    // Dots at every data point, dashed vertical guide + solid dot on peak.
    for (var i = 0; i < points.length; i++) {
      final visible = i / (points.length - 1) <= progress + 0.001;
      if (!visible) continue;

      final isPeak = i == peakIndex;
      if (isPeak) {
        _drawDashedLine(canvas, Offset(points[i].dx, points[i].dy),
            Offset(points[i].dx, size.height), color);
      }
      canvas.drawCircle(
        points[i],
        isPeak ? 5 : 3.5,
        Paint()..color = Colors.white,
      );
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
