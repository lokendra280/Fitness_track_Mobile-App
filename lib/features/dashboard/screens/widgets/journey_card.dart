import 'package:flutter/material.dart';
import 'package:habitflow/core/theme/app_theme.dart';
import 'package:habitflow/core/widgets/animated_common.dart';

class JourneyCard extends StatelessWidget {
  final double progress;
  final double? currentWeight;
  final double? targetWeight;
  final double? weightLost;
  final int? daysRemaining;
  final int streak;
  final double? remainingWeight;
  final VoidCallback? onMenuTap;

  const JourneyCard({
    super.key,
    required this.progress,
    required this.currentWeight,
    required this.targetWeight,
    required this.weightLost,
    required this.daysRemaining,
    required this.streak,
    required this.remainingWeight,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.journeyGradientTop,
            AppColors.journeyGradientBottom
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text('Your journey',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Colors.white)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Weight Loss',
                          style: TextStyle(color: Colors.white, fontSize: 11)),
                    ),
                  ],
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onMenuTap,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.more_vert, color: Colors.white70, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedRingProgress(
                value: progress,
                size: 72,
                strokeWidth: 7,
                color: const Color(0xFFF4C04F),
                backgroundColor: Colors.white.withOpacity(0.15),
                labelStyle: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedCountUp(
                      value: currentWeight ?? 0,
                      suffix: currentWeight != null ? ' kg' : '',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700),
                    ),
                    if (currentWeight == null)
                      const Text('Log your weight',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                      targetWeight != null
                          ? 'Target: ${targetWeight!.toStringAsFixed(1)} kg'
                          : 'No target set',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    if (weightLost != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${weightLost!.abs().toStringAsFixed(1)} kg '
                        '${weightLost! >= 0 ? 'lost' : 'gained'} so far',
                        style: const TextStyle(
                            color: Color(0xFFF4C04F),
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedProgressBar(
            value: progress,
            color: const Color(0xFFF4C04F),
            backgroundColor: Colors.white.withOpacity(0.15),
            height: 6,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _JourneyStat(
                  icon: Icons.calendar_today,
                  label: 'Days left',
                  value: daysRemaining?.toString() ?? '–'),
              _divider(),
              _JourneyStat(
                  icon: Icons.local_fire_department,
                  label: 'Streak',
                  value: '${streak}d'),
              _divider(),
              _JourneyStat(
                  icon: Icons.remove_circle_outline,
                  label: 'Remaining',
                  value: remainingWeight != null
                      ? '${remainingWeight!.abs().toStringAsFixed(1)} kg'
                      : '–'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 34,
        color: Colors.white.withOpacity(0.15),
      );
}

class _JourneyStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _JourneyStat(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(color: Colors.white60, fontSize: 11)),
        ],
      ),
    );
  }
}
