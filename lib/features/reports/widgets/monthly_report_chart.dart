import 'package:flutter/material.dart';

/// A simple animated line chart for a 30-day metric trend, drawn with
/// CustomPainter rather than a charting package. `values` must have
/// exactly 30 entries, oldest first.
class MonthlyReportChart extends StatefulWidget {
  const MonthlyReportChart({
    super.key,
    required this.values,
    required this.color,
    required this.label,
  });

  final List<int> values;
  final Color color;
  final String label;

  @override
  State<MonthlyReportChart> createState() => _MonthlyReportChartState();
}

class _MonthlyReportChartState extends State<MonthlyReportChart>
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
    final text = Theme.of(context).textTheme;
    final maxVal = widget.values.isEmpty
        ? 1
        : widget.values.reduce((a, b) => a > b ? a : b).clamp(1, 1 << 30);
    final total = widget.values.fold<int>(0, (a, b) => a + b);
    final avg =
        widget.values.isEmpty ? 0 : (total / widget.values.length).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${widget.label} · last 30 days', style: text.titleMedium),
        const SizedBox(height: 4),
        Text('Average: $avg / day', style: text.labelSmall),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          width: double.infinity,
          child: AnimatedBuilder(
            animation: _progress,
            builder: (context, _) => CustomPaint(
              painter: _LineChartPainter(
                values: widget.values,
                maxVal: maxVal.toDouble(),
                color: widget.color,
                progress: _progress.value,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.values,
    required this.maxVal,
    required this.color,
    required this.progress,
  });

  final List<int> values;
  final double maxVal;
  final Color color;
  final double progress; // 0..1, animates the line draw-in

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final points = <Offset>[];
    final stepX = size.width / (values.length - 1).clamp(1, 1 << 30);
    for (var i = 0; i < values.length; i++) {
      final x = i * stepX;
      final y = size.height - (values[i] / maxVal) * size.height;
      points.add(Offset(x, y));
    }

    // Only draw up to `progress` fraction of the path for an animated
    // "drawing in" effect.
    final visibleCount =
        (points.length * progress).ceil().clamp(1, points.length);
    final visiblePoints = points.sublist(0, visibleCount);

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()..moveTo(visiblePoints.first.dx, visiblePoints.first.dy);
    for (final p in visiblePoints.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, linePaint);

    // Fill under the line for visual weight.
    final fillPath = Path.from(path)
      ..lineTo(visiblePoints.last.dx, size.height)
      ..lineTo(visiblePoints.first.dx, size.height)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0.0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.values != values;
}
