import 'package:flutter/material.dart';

/// Large animated water-fill ring with the current ml total in the center.
class WaterRing extends StatelessWidget {
  final int ml;
  final double progress;
  const WaterRing({super.key, required this.ml, required this.progress});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    const waterColor = Color(0xFF2FA8E0);

    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(alignment: Alignment.center, children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (_, v, __) => CircularProgressIndicator(
            value: v,
            strokeWidth: 12,
            strokeCap: StrokeCap.round,
            backgroundColor: scheme.surfaceContainerHighest,
            valueColor: const AlwaysStoppedAnimation(waterColor),
          ),
        ),
        Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.water_drop_rounded, color: waterColor, size: 26),
          const SizedBox(height: 6),
          Text('$ml ml', style: text.headlineMedium),
          Text('${(progress * 100).round()}% of goal', style: text.bodySmall),
        ]),
      ]),
    );
  }
}
