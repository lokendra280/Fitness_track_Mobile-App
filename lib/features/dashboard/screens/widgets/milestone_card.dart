import 'package:flutter/material.dart';
import 'package:habitflow/core/theme/app_theme.dart';
import 'package:habitflow/core/widgets/animated_common.dart';
import 'package:habitflow/data/models/dashboard_ui_models.dart';

/// "Upcoming milestone" card with trophy icon and an animated progress bar.
class MilestoneCard extends StatelessWidget {
  final MilestoneInfo milestone;
  const MilestoneCard({super.key, required this.milestone});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.milestoneBg,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.emoji_events,
                  color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Upcoming milestone',
                      style: textTheme.bodyMedium?.copyWith(fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(milestone.title, style: textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(milestone.subtitle, style: textTheme.bodyMedium),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: AnimatedProgressBar(
                          value: milestone.progress,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${milestone.current.toStringAsFixed(1)} / '
                        '${milestone.target.toStringAsFixed(1)} kg',
                        style: textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
