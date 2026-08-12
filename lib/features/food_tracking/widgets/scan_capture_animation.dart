import 'dart:io';
import 'package:flutter/material.dart';

/// Scanner-style animation over a captured photo: pulsing corner frame +
/// a light beam sweeping top-to-bottom, shown while the AI scan is in flight.
class FoodScanAnimation extends StatefulWidget {
  final File image;
  const FoodScanAnimation({super.key, required this.image});

  @override
  State<FoodScanAnimation> createState() => _FoodScanAnimationState();
}

class _FoodScanAnimationState extends State<FoodScanAnimation>
    with SingleTickerProviderStateMixin {
  late final _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1600))
    ..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AspectRatio(
        aspectRatio: 1.4,
        child: Stack(fit: StackFit.expand, children: [
          Image.file(widget.image, fit: BoxFit.cover),
          Container(color: Colors.black.withValues(alpha: 0.18)),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Stack(children: [
              for (final a in const [
                Alignment.topLeft,
                Alignment.topRight,
                Alignment.bottomLeft,
                Alignment.bottomRight
              ])
                Align(
                    alignment: a,
                    child: _Corner(color: scheme.primary, alignment: a)),
            ]),
          ),
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => Align(
              alignment: Alignment(-1, -1 + 2 * _ctrl.value),
              child: Container(
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    scheme.primary.withValues(alpha: 0),
                    scheme.primary,
                    scheme.primary.withValues(alpha: 0),
                  ]),
                  boxShadow: [
                    BoxShadow(
                        color: scheme.primary.withValues(alpha: 0.8),
                        blurRadius: 10)
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  final Color color;
  final Alignment alignment;
  const _Corner({required this.color, required this.alignment});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(
          painter: _CornerPainter(
              color: color, top: alignment.y < 0, left: alignment.x < 0)),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final bool top, left;
  _CornerPainter({required this.color, required this.top, required this.left});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final x = left ? 0.0 : size.width;
    final y = top ? 0.0 : size.height;
    canvas.drawLine(Offset(x, y), Offset(x, top ? size.height : 0), paint);
    canvas.drawLine(Offset(x, y), Offset(left ? size.width : 0, y), paint);
  }

  @override
  bool shouldRepaint(covariant _CornerPainter oldDelegate) => false;
}
