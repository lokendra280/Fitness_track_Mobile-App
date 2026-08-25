import 'package:flutter/material.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:habitflow/core/constants/app_topography.dart';
import 'package:habitflow/core/theme/app_theme.dart';

/// One ring-stat card matching the "Daily/Weekly goals" screenshot —
/// period label + flame streak top row, a progress ring with a centered
/// icon, then a bold title and grey subtitle underneath.
class GoalRingCard extends StatelessWidget {
  final String periodLabel;
  final int streakCount;
  final IconData icon;
  final Color ringColor;
  final double progress;
  final String title;
  final String subtitle;

  const GoalRingCard({
    super.key,
    required this.periodLabel,
    required this.streakCount,
    required this.icon,
    required this.ringColor,
    required this.progress,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AdaptiveBuilder(
      defaultBuilder: (context, screen) =>
          _build(context, textTheme, ringSize: 64, padding: 14),
      layoutDelegate: AdaptiveLayoutDelegateWithMinimallScreenType(
        handset: (context, screen) =>
            _build(context, textTheme, ringSize: 64, padding: 14),
        tablet: (context, screen) =>
            _build(context, textTheme, ringSize: 84, padding: 18),
        desktop: (context, screen) =>
            _build(context, textTheme, ringSize: 100, padding: 22),
      ),
    );
  }

  Widget _build(
    BuildContext context,
    TextTheme textTheme, {
    required double ringSize,
    required double padding,
  }) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.goalCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                periodLabel,
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.grey.shade500,
                  letterSpacing: 0.4,
                ),
              ),
              const Spacer(),
              const Icon(Icons.local_fire_department_rounded,
                  color: Color(0xFFF4A73C), size: 15),
              const SizedBox(width: 2),
              Text(
                '$streakCount',
                style: AppTypography.labelLarge
                    .copyWith(color: Colors.black87, fontWeight: FontWeight.w700
                        // letterSpacing: 0.4,
                        ),
                // style: textTheme.labelMedium?.copyWith(
                //   color: Colors.black87,
                //   fontWeight: FontWeight.w700,
                // ),
              ),
            ],
          ),
          SizedBox(height: padding),
          Center(
            child: SizedBox(
              width: ringSize,
              height: ringSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: Size(ringSize, ringSize),
                    painter: _GoalRingPainter(
                      progress: progress,
                      color: ringColor,
                    ),
                  ),
                  Icon(icon, color: ringColor, size: ringSize * 0.34),
                ],
              ),
            ),
          ),
          SizedBox(height: padding * 0.7),
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade500),
          ),
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
    const strokeWidth = 5.0;
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
