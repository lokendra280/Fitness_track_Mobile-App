import 'package:flutter/material.dart';
import 'package:habitflow/core/widgets/animated_common.dart';
import 'package:habitflow/data/models/dashboard_ui_models.dart';

/// "Weight" card: current reading, trend badge, "+ Add" button, and an
/// animated line chart with area fill built from [history].
class WeightChartCard extends StatelessWidget {
  final double? currentWeight;
  final double changeVsYesterday;
  final List<WeightPoint> history;
  final VoidCallback onAddTap;

  const WeightChartCard({
    super.key,
    required this.currentWeight,
    required this.changeVsYesterday,
    required this.history,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final down = changeVsYesterday <= 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Weight', style: textTheme.titleMedium),
                TapScale(
                  onTap: onAddTap,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 4),
                        Text('Add',
                            style: textTheme.labelMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          AnimatedCountUp(
                            value: currentWeight ?? 0,
                            style: textTheme.headlineMedium,
                          ),
                          const SizedBox(width: 4),
                          Text('kg', style: textTheme.bodyMedium),
                        ],
                      ),
                      Text('This morning', style: textTheme.bodyMedium),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: (down ? Colors.green : Colors.red).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(down ? Icons.arrow_downward : Icons.arrow_upward,
                          size: 14, color: down ? Colors.green : Colors.red),
                      const SizedBox(width: 4),
                      Text('${changeVsYesterday.abs().toStringAsFixed(1)} kg',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: down ? Colors.green : Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text('vs yesterday', style: textTheme.bodyMedium),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: _AnimatedWeightChart(history: history),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedWeightChart extends StatefulWidget {
  final List<WeightPoint> history;
  const _AnimatedWeightChart({required this.history});

  @override
  State<_AnimatedWeightChart> createState() => _AnimatedWeightChartState();
}

class _AnimatedWeightChartState extends State<_AnimatedWeightChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..forward();

  @override
  void didUpdateWidget(covariant _AnimatedWeightChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.history.length != widget.history.length) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          size: Size.infinite,
          painter: _WeightChartPainter(
            points: widget.history,
            color: color,
            progress: Curves.easeOutCubic.transform(_controller.value),
          ),
        );
      },
    );
  }
}

class _WeightChartPainter extends CustomPainter {
  final List<WeightPoint> points;
  final Color color;
  final double progress;

  _WeightChartPainter(
      {required this.points, required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    const leftAxisWidth = 28.0;
    const bottomAxisHeight = 20.0;
    final chartWidth = size.width - leftAxisWidth;
    final chartHeight = size.height - bottomAxisHeight;

    final weights = points.map((p) => p.weightKg).toList();
    final minW = weights.reduce((a, b) => a < b ? a : b) - 1;
    final maxW = weights.reduce((a, b) => a > b ? a : b) + 1;

    double xFor(int i) =>
        leftAxisWidth + (chartWidth * i / (points.length - 1));
    double yFor(double w) =>
        chartHeight - ((w - minW) / (maxW - minW)) * chartHeight;

    // Y-axis labels
    final labelStyle = TextStyle(color: Colors.grey.shade500, fontSize: 10);
    for (final w in [minW, (minW + maxW) / 2, maxW]) {
      final tp = TextPainter(
        text: TextSpan(text: w.round().toString(), style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, yFor(w) - tp.height / 2));
    }

    final visibleCount =
        (points.length * progress).clamp(1, points.length).toDouble();
    final fullSegments = visibleCount.floor();

    final path = Path();
    final fillPath = Path();
    Offset? lastPoint;

    for (var i = 0; i < points.length; i++) {
      if (i > fullSegments) break;
      var x = xFor(i);
      var y = yFor(weights[i]);

      if (i == fullSegments && fullSegments < points.length - 1) {
        final frac = visibleCount - fullSegments;
        final nextX = xFor(i + 1);
        final nextY = yFor(weights[i + 1]);
        x = x + (nextX - x) * frac;
        y = y + (nextY - y) * frac;
      }

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, chartHeight);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
      lastPoint = Offset(x, y);
    }

    if (lastPoint != null) {
      fillPath.lineTo(lastPoint.dx, chartHeight);
      fillPath.close();

      canvas.drawPath(
        fillPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withOpacity(0.18), color.withOpacity(0.0)],
          ).createShader(Rect.fromLTWH(0, 0, size.width, chartHeight)),
      );

      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round,
      );

      // small dots along the line, larger dot on the last visible point
      for (var i = 0; i <= fullSegments && i < points.length; i++) {
        final isLast = i == fullSegments && progress >= 0.999;
        canvas.drawCircle(
          Offset(xFor(i), yFor(weights[i])),
          isLast ? 5 : 2.4,
          Paint()..color = color,
        );
        if (isLast) {
          canvas.drawCircle(
            Offset(xFor(i), yFor(weights[i])),
            8,
            Paint()..color = color.withOpacity(0.2),
          );
        }
      }
    }

    // X-axis labels (first, middle, last)
    final labelIdxs = <int>{0, points.length ~/ 2, points.length - 1};
    for (final i in labelIdxs) {
      final d = points[i].date;
      final text = '${_month(d.month)} ${d.day}';
      final tp = TextPainter(
        text: TextSpan(text: text, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      var dx = xFor(i) - tp.width / 2;
      dx = dx.clamp(leftAxisWidth, size.width - tp.width);
      tp.paint(canvas, Offset(dx, chartHeight + 4));
    }
  }

  String _month(int m) => const [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m - 1];

  @override
  bool shouldRepaint(covariant _WeightChartPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.points != points;
}
