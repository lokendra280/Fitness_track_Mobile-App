import 'package:flutter/material.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:habitflow/core/constants/app_topography.dart';
import 'package:habitflow/core/theme/app_theme.dart';

/// One ring-stat card matching the Jogging/Cycling/Swim reference design:
/// a solid-color pill badge up top, and a progress ring with the value +
/// unit text centered inside it (no icon in the ring).
class GoalRingCard extends StatelessWidget {
  final String periodLabel;
  final int streakCount;
  final Color ringColor;
  final double progress;
  final String title;
  final String value;
  final String unit;

  const GoalRingCard({
    super.key,
    required this.periodLabel,
    required this.streakCount,
    required this.ringColor,
    required this.progress,
    required this.title,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      defaultBuilder: (context, screen) => _build(ringSize: 90, padding: 14),
      layoutDelegate: AdaptiveLayoutDelegateWithMinimallScreenType(
        handset: (context, screen) => _build(ringSize: 90, padding: 14),
        tablet: (context, screen) => _build(ringSize: 110, padding: 18),
        desktop: (context, screen) => _build(ringSize: 130, padding: 22),
      ),
    );
  }

  Widget _build({required double ringSize, required double padding}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Solid-color pill badge, white text, no icon — matches the
          // "Jogging" / "Cycling" / "Swim" chips exactly.
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 6,
              horizontal: 10,
            ),
            decoration: BoxDecoration(
              color: ringColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              title,
              style: AppTypography.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: padding * 1.1),

          // Ring with value + unit centered inside — no icon.
          SizedBox(
            width: ringSize,
            height: ringSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(ringSize, ringSize),
                  painter:
                      _GoalRingPainter(progress: progress, color: ringColor),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value,
                      style: AppTypography.h3.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      unit,
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (streakCount > 0) ...[
            SizedBox(height: padding * 0.6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  periodLabel,
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.grey.shade500,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.local_fire_department_rounded,
                    color: Color(0xFFF4A73C), size: 12),
                const SizedBox(width: 2),
                Text(
                  '$streakCount',
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _GoalRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  _GoalRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 6.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;

    final track = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, track);

    const start = -1.5708; // top
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      6.28319 * progress.clamp(0.0, 1.0),
      false,
      fill,
    );
  }

  @override
  bool shouldRepaint(covariant _GoalRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
